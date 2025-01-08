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

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 指定不重试的 URL 或路径
    List<String> noRetryUrls = [
      '/api/no-retry-endpoint', // 替换为实际的 URL 或路径
    ];

    if (noRetryUrls.any((url) => options.path.contains(url))) {
      // 如果请求的 URL 在 noRetryUrls 列表中，则不进行重试
      handler.next(options);
    } else {
      // 否则，调用父类的方法进行重试
      super.onRequest(options, handler);
    }
  }
}

class DioUtil {
  DioUtil._privateConstructor();

  static final DioUtil _instance = DioUtil._privateConstructor();

  late String token;
  late Options _defaultOptions;
  late Dio? dio;

  factory DioUtil() {
    return _instance;
  }

  Future<void> initialize(String server) async {
    await _initDio(server);
  }

  Future<void> _initDio(String server) async {
    String baseUrl = '$server/api/';
    _defaultOptions = await _buildRequestOptions();
    dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 12),
        responseType: ResponseType.json,
        headers: {
          "User-Agent": SPUtil.getString("CustomUA",
              defaultValue: "Harvest APP Client/1.0"),
        }));

    dio?.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
    )); // Add logging interceptor for debugging purposes
    dio?.interceptors.add(CustomInterceptors());
    dio?.interceptors.add(RetryInterceptor(
      dio: dio!,
      retries: 3,
      logPrint: (message) {
        Logger.instance.w(message);
      },
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 3)
      ],
      retryEvaluator: (DioException err, int count) {
        // 不重试 401 和 403 错误
        if ([401, 403].contains(err.response?.statusCode)) {
          return true;
        }
        return false;
      },
    ));
  }

  Future<Response<T>> get<T>(String url,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    final response = await dio!.get<T>(url,
        queryParameters: queryParameters,
        options: options ?? await _buildRequestOptions());
    return response;
  }

  // 同样修改post, put, delete方法中的options参数类型为RequestOptions?
  Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    final resp = await dio!.post(url,
        queryParameters: queryParameters,
        data: formData,
        options: options ?? await _buildRequestOptions());
    Logger.instance.i(resp);
    return resp;
  }

  Future<Response> put(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    return await dio!.put(
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
    return await dio!.delete(
      url,
      queryParameters: queryParameters,
      data: formData != null ? FormData.fromMap(formData) : null,
      options: options ?? await _buildRequestOptions(),
    );
  }

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
    Map<String, dynamic> userinfo = SPUtil.getLocalStorage('userinfo') ?? {};
    if (userinfo.isNotEmpty) {
      AuthInfo authInfo = AuthInfo.fromJson(userinfo);
      token = authInfo.authToken ?? '';
    } else {
      token = '';
    }

    return Options(
      headers: _buildAuthHeaders(),
      receiveDataWhenStatusError: true,
      sendTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    );
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

  // 增加释放资源的方法
  void dispose() {
    dio!.interceptors.clear();
    dio!.close();
  }
}
