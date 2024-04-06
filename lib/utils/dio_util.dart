import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/models/authinfo.dart';
import 'package:harvest/utils/logger_helper.dart';

class CustomInterceptors extends Interceptor {
  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if ([403, 401].contains(response.statusCode)) {
      GetStorage box = GetStorage();
      box.write("isLogin", false);
    }
    return super.onResponse(response, handler);
  }
}

class DioUtil {
  DioUtil._privateConstructor();

  static final DioUtil _instance = DioUtil._privateConstructor();

  late String token;
  late Options _defaultOptions;
  late Dio? dio;
  late GetStorage box;

  factory DioUtil() {
    return _instance;
  }

  Future<void> initialize(String server) async {
    await _initDio(server);
  }

  Future<void> _initDio(String server) async {
    String baseUrl = '$server/api/';
    box = GetStorage();
    _defaultOptions = await _buildRequestOptions();
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 12),
      responseType: ResponseType.json,
    ));

    dio?.interceptors.add(LogInterceptor(
      requestHeader: true,
      responseBody: false,
      responseHeader: true,
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
    Map<String, dynamic> userinfo = box.read('userinfo') ?? {};
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
