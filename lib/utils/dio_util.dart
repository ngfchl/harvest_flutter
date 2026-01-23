import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:harvest/models/authinfo.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:harvest/utils/storage.dart';

class CustomInterceptors extends Interceptor {
  // @override
  // Future<void> onError(
  //     DioException err, ErrorInterceptorHandler handler) async {
  //   if ([401, 403].contains(err.response?.statusCode)) {
  //     SPUtil.setBool("isLogin", false);
  //     Get.offAndToNamed("/login");
  //     handler.reject(DioException(
  //       requestOptions: err.requestOptions,
  //       error: "登录已过期，请重新登录！",
  //       message: "登录已过期，请重新登录！",
  //       type: DioExceptionType.badResponse,
  //       response: err.response,
  //     ));
  //   } else {
  //     return super.onError(err, handler);
  //   }
  // }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('CustomInterceptors.onError: status=${err.response?.statusCode}, url=${err.requestOptions.uri}');
    final status = err.response?.statusCode ?? 0;
    if ([302, 401, 403].contains(status)) {
      // 如果 SPUtil.setBool 是异步，建议 await；若为同步可直接调用
      // 若为 Future，则可以: await SPUtil.setBool(...); 但 onError 不是 async，这里用微任务
      SPUtil.setBool('isLogin', false);

      // 延后到下一个 microtask/post frame 去导航，避免在 build/渲染时立即导航的问题
      Future.microtask(() {
        // 使用 offAllNamed 更安全（替换所有路由）
        Get.offAllNamed('/login');
      });

      // 将原始错误继续传递给调用方（也可以自定义错误信息）
      handler.reject(err);
      return;
    }

    // 其他错误交由下一个拦截器或 Dio 处理
    handler.next(err);
  }
}

class DioUtil {
  DioUtil._privateConstructor();

  static final DioUtil _instance = DioUtil._privateConstructor();

  static DioUtil get instance => _instance;

  late Dio dio;
  String token = '';
  late Options _defaultOptions;

  factory DioUtil() => _instance;

  Future<void> initialize(String server) async {
    await _initDio(server);
  }

  Future<void> _initDio(String server) async {
    String baseUrl = '$server/api/';
    _defaultOptions = await _buildRequestOptions();

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 75),
      receiveTimeout: const Duration(seconds: 90),
      responseType: ResponseType.json,
      validateStatus: (status) {
        Logger.instance.d('dio.status: $status');
        return status != null && ![401, 403].contains(status); // 所有状态码都当作正常返回
      },
      // 开启连接池
      extra: {
        'connection_pool': true,
      },
    ));

    // 请求拦截器动态加 Authorization
    dio.interceptors.insert(0, InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (token.isEmpty) {
          token = await _loadTokenFromStorage();
        }
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token   ';
        }
        options.headers['User-Agent'] = SPUtil.getString("CustomUA", defaultValue: "Harvest APP Client/1.0");
        handler.next(options);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      error: true,
    ));

    dio.interceptors.add(CustomInterceptors());

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 3,
      logPrint: (message) => Logger.instance.w(message),
      retryDelays: const [Duration(seconds: 1), Duration(seconds: 2), Duration(seconds: 3)],
      retryEvaluator: (DioException err, int count) {
        if (err.response!.statusCode.toString().startsWith('5')) {
          return false;
        }
        return [
          DioExceptionType.connectionTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.unknown,
        ].contains(err.type);
      },
    ));
  }

  // 请求方法
  Future<Response<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get<T>(
      url,
      queryParameters: queryParameters,
      options: options ?? await _buildRequestOptions(),
      cancelToken: cancelToken,
    );
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic formData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final mergedOptions = options ?? await _buildRequestOptions();
    if (formData is FormData) {
      mergedOptions.headers?.remove('Content-Type');
    }

    return await dio.post(
      url,
      queryParameters: queryParameters,
      data: formData,
      options: mergedOptions,
      cancelToken: cancelToken,
    );
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.put(
      url,
      queryParameters: queryParameters,
      data: formData,
      options: options ?? await _buildRequestOptions(),
      cancelToken: cancelToken,
    );
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options ?? await _buildRequestOptions(),
      cancelToken: cancelToken,
    );
  }

  // 动态构建请求头
  Map<String, dynamic> _buildAuthHeaders() {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    String proxyToken = SPUtil.getString('ProxyToken');
    if (proxyToken.isNotEmpty) {
      headers['cookie'] = SPUtil.getString('ProxyToken');
    }
    return headers;
  }

  Future<Options> _buildRequestOptions() async {
    if (token.isEmpty) {
      token = await _loadTokenFromStorage();
    }
    return Options(
      headers: _buildAuthHeaders(),
      receiveDataWhenStatusError: true,
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    );
  }

  Future<String> _loadTokenFromStorage() async {
    final userinfo = SPUtil.getLocalStorage('userinfo') ?? {};
    if (userinfo.isNotEmpty) {
      final authInfo = AuthInfo.fromJson(userinfo);
      return authInfo.authToken ?? '';
    }
    return '';
  }

  void updateAuthToken(String newToken) {
    token = newToken;
    _updateDefaultHeader();
  }

  void clearAuthToken() {
    token = '';
    _updateDefaultHeader();
  }

  void _updateDefaultHeader() {
    _defaultOptions.headers = _buildAuthHeaders();
  }

  void dispose() {
    dio.interceptors.clear();
    dio.close();
  }
}
