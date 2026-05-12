import 'package:dio/dio.dart';
import 'package:harvest/core/utils/utils.dart';

class ResponseInterceptor extends Interceptor {
  static const String responseMessageKey = '__response_message__';

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    // 流式响应直接放行，不解析 JSON
    if (response.data is ResponseBody) {
      AppLogger.debug(
        '[HTTP] stream response accepted: ${response.requestOptions.path}',
      );
      return handler.next(response);
    }

    final allowAnySucceed =
        response.requestOptions.extra['allowAnySucceed'] == true;
    final message = extractMessage(data);
    if (message != null && message.isNotEmpty) {
      response.extra[responseMessageKey] = message;
      response.requestOptions.extra[responseMessageKey] = message;
    }

    /// 👉 你的后端规范
    if (data is Map &&
        data['succeed'] == true &&
        (data['code'] == 0 || allowAnySucceed)) {
      return handler.next(response);
    }

    final msg = message;
    AppLogger.warn(
      '[HTTP] business failure: ${response.requestOptions.method} '
      '${response.requestOptions.path} status=${response.statusCode} '
      'code=${data is Map ? data['code'] : '-'} msg=${msg ?? '-'}',
    );
    Toast.error(msg ?? '请求失败');

    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: msg,
      ),
    );
  }

  static String? extractMessage(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.trim().isEmpty ? null : value.trim();
    if (value is Map) {
      for (final key in const ['message', 'msg', 'info', 'detail', 'result']) {
        final message = extractMessage(value[key]);
        if (message != null) return message;
      }
      return extractMessage(value['data']);
    }
    if (value is Iterable) {
      final messages = value
          .map(extractMessage)
          .whereType<String>()
          .where((message) => message.trim().isNotEmpty)
          .toList();
      return messages.isEmpty ? null : messages.join('\n');
    }
    return null;
  }
}
