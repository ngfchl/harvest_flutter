import 'package:dio/dio.dart';
import 'package:harvest/core/utils/utils.dart';

class ResponseInterceptor extends Interceptor {
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

    /// 👉 你的后端规范
    if (data is Map &&
        data['succeed'] == true &&
        (data['code'] == 0 || allowAnySucceed)) {
      return handler.next(response);
    }

    final msg = data is Map ? data['msg'] : null;
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
}
