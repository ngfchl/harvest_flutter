import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:get/route_manager.dart';
import 'package:harvest/utils/storage.dart';

import '../models/authinfo.dart';
import 'logger_helper.dart';

class DioClient {
  late String token;

  static final DioClient _singleton = DioClient._internal();

  factory DioClient() {
    return _singleton;
  }

  DioClient._internal() {
    _init();
  }

  final Dio dio = Dio();

  void _init() {
    var server = SPUtil.getString("server") ?? '';
    if (server.isEmpty) {
      Get.snackbar('出错啦！', '请先设置并选择服务器地址！');
      return;
    }
    String baseUrl = '$server/api/';
    Logger.instance.i(baseUrl);
    BaseOptions options = BaseOptions(
      //请求基地址,可以包含子路径
      baseUrl: baseUrl,
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: const Duration(seconds: 120),
      //响应流上前后两次接受到数据的间隔，单位为毫秒。
      receiveTimeout: const Duration(seconds: 12),
    );
    dio.options = options;

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      retries: 3,
      logPrint: (message) {
        Logger.instance.w(message);
      },
      retryDelays: const [
        Duration(seconds: 1), // wait 1 sec before first retry
        Duration(seconds: 2), // wait 2 sec before second retry
        Duration(seconds: 3), // wait 3 sec before third retry
      ],
    ));
  }

  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Logger.instance.w(url);
    final response = await dio.get(url,
        queryParameters: queryParameters,
        options: options ?? await _buildRequestOptions());
    return response;
  }

  Future<Response> post(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? formData,
    Options? options,
  }) async {
    Logger.instance.w('正在请求：$url');
    final resp = await dio.post(
      url,
      queryParameters: queryParameters,
      data: formData,
      options: options ?? await _buildRequestOptions(),
    );
    Logger.instance.w('请求结束：${resp.data}');
    return resp;
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

  Map<String, dynamic> _buildAuthHeaders() {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json; charset=utf-8'
    };

    if (token == '') {
      return headers;
    }

    headers['Authorization'] = token;

    return headers;
  }

  Future<Options> _buildRequestOptions() async {
    Map userinfo = SPUtil.getMap('userinfo');

    if (userinfo.isNotEmpty) {
      AuthInfo authInfo = AuthInfo.fromJson(userinfo as Map<String, dynamic>);
      if (authInfo.authToken != '') {
        token = authInfo.authToken!;
      }
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
}
