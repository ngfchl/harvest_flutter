import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:harvest/models/authinfo.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:harvest/utils/storage.dart';

class CustomInterceptors extends Interceptor {
  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if ([401, 403].contains(err.response?.statusCode)) {
      SPUtil.setBool("isLogin", false);
      Get.offAndToNamed("/login");
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        error: "登录已过期，请重新登录！",
        message: "登录已过期，请重新登录！",
        type: DioExceptionType.badResponse,
        response: err.response,
      ));
    } else {
      return super.onError(err, handler);
    }
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
        return status != null && status < 600; // 所有状态码都当作正常返回
      },
    ));

    // 请求拦截器动态加 Authorization
    dio.interceptors.insert(0, InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (token.isEmpty) {
          token = await _loadTokenFromStorage();
        }
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['User-Agent'] = SPUtil.getString("CustomUA",
            defaultValue: "Harvest APP Client/1.0");
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
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3)
      ],
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
  Future<Response<T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await dio.get<T>(url,
        queryParameters: queryParameters,
        options: options ?? await _buildRequestOptions());
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic formData,
    Options? options,
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
    );
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    return await dio.put(
      url,
      queryParameters: queryParameters,
      data: formData,
      options: options ?? await _buildRequestOptions(),
    );
  }

  Future<Response> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    return await dio.delete(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options ?? await _buildRequestOptions(),
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
