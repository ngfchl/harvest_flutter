import 'package:dio/dio.dart';

bool isSilentAuthCancel(Object error) {
  return error is DioException &&
      error.type == DioExceptionType.cancel &&
      error.error?.toString() == 'token_expired';
}
