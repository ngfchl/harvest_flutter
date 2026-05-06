import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/response_interceptor.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl, connectTimeout: const Duration(seconds: 10)))
    ..interceptors.add(AuthInterceptor())
    ..interceptors.add(ResponseInterceptor());

  static void setBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }
}
