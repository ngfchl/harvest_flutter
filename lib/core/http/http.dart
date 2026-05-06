import 'package:dio/dio.dart';
import 'package:harvest/core/utils/utils.dart';

import 'dio_client.dart';

class Http {
  /// 通用底层请求方法
  static Future<T> request<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    final mergedOptions = (options ?? Options()).copyWith(
      method: method,
      headers: headers,
    );
    final stopwatch = Stopwatch()..start();
    final responseType = mergedOptions.responseType;

    AppLogger.debug(
      '[HTTP] -> $method $path'
      '${_querySummary(queryParameters)}'
      '${responseType == null ? '' : ' responseType=$responseType'}',
    );

    try {
      final res = await DioClient.dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: mergedOptions,
      );
      stopwatch.stop();

      AppLogger.debug(
        '[HTTP] <- $method $path status=${res.statusCode} '
        'elapsed=${stopwatch.elapsedMilliseconds}ms data=${_shape(res.data)}',
      );

      // 流式响应直接返回原始数据（ResponseBody）
      if (mergedOptions.responseType == ResponseType.stream) {
        return res.data as T;
      }

      return res.data['data'] as T;
    } on DioException catch (e, st) {
      stopwatch.stop();
      final status = e.response?.statusCode;
      final log = _isNetworkDioError(e) || e.type == DioExceptionType.cancel
          ? AppLogger.warn
          : (dynamic message) => AppLogger.error(message, e, st);
      log(
        '[HTTP] !! $method $path status=${status ?? '-'} '
        'type=${e.type.name} elapsed=${stopwatch.elapsedMilliseconds}ms '
        'response=${_shape(e.response?.data)}',
      );
      rethrow;
    } catch (e, st) {
      stopwatch.stop();
      AppLogger.error(
        '[HTTP] !! $method $path elapsed=${stopwatch.elapsedMilliseconds}ms',
        e,
        st,
      );
      rethrow;
    }
  }

  static Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path,
      method: 'GET',
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<T> post<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path,
      method: 'POST',
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<T> put<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path,
      method: 'PUT',
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path,
      method: 'PATCH',
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
    Options? options,
  }) {
    return request<T>(
      path,
      method: 'DELETE',
      queryParameters: queryParameters,
      data: data,
      headers: headers,
      cancelToken: cancelToken,
      options: options,
    );
  }

  static bool _isNetworkDioError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  static String _querySummary(Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return '';
    final sanitized = query.map((key, value) {
      return MapEntry(key, _isSensitiveKey(key) ? '***' : value);
    });
    return ' query=$sanitized';
  }

  static bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('token') ||
        lower.contains('password') ||
        lower.contains('secret') ||
        lower.contains('cookie') ||
        lower.contains('passkey') ||
        lower.contains('auth');
  }

  static String _shape(dynamic value) {
    if (value == null) return 'null';
    if (value is ResponseBody) return 'stream';
    if (value is List) return 'List(${value.length})';
    if (value is Map) {
      final keys = value.keys.take(8).join(',');
      return 'Map(${value.length})[$keys]';
    }
    if (value is String) return 'String(${value.length})';
    return value.runtimeType.toString();
  }
}
