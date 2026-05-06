import 'package:dio/dio.dart';
import 'package:harvest/core/utils/utils.dart';

import 'http.dart';

/// =============================
/// 🔹 查询类
/// =============================

/// List + Model
Future<List<T>> fetchModelList<T>(
  String apiEndpoint,
  T Function(Map<String, dynamic>) fromJson, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  final list = await Http.get<List>(
    apiEndpoint,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  try {
    final result = list
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
    AppLogger.debug(
      '[Data] parsed ${result.length} ${T.toString()} items from $apiEndpoint',
    );
    return result;
  } catch (e, st) {
    AppLogger.error(
      '[Data] failed to parse ${T.toString()} list from $apiEndpoint '
      'items=${list.length}',
      e,
      st,
    );
    rethrow;
  }
}

/// List（不转模型）
Future<List> fetchBasicList(
  String apiEndpoint, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  final list = await Http.get<List>(
    apiEndpoint,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  AppLogger.debug(
    '[Data] fetched basic list from $apiEndpoint items=${list.length}',
  );
  return list;
}

/// 单对象 Map
Future<Map<String, dynamic>?> fetchBasic(
  String apiEndpoint, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  final data = await Http.get<Map<String, dynamic>?>(
    apiEndpoint,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  AppLogger.debug(
    '[Data] fetched basic object from $apiEndpoint keys=${data?.length ?? 0}',
  );
  return data;
}

/// 单对象 + Model
Future<T?> fetchModel<T>(
  String apiEndpoint,
  T Function(Map<String, dynamic>) fromJson, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  final data = await Http.get<Map<String, dynamic>?>(
    apiEndpoint,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  if (data == null) {
    AppLogger.debug('[Data] $apiEndpoint returned null ${T.toString()}');
    return null;
  }

  try {
    final model = fromJson(data);
    AppLogger.debug('[Data] parsed ${T.toString()} from $apiEndpoint');
    return model;
  } catch (e, st) {
    AppLogger.error(
      '[Data] failed to parse ${T.toString()} from $apiEndpoint',
      e,
      st,
    );
    rethrow;
  }
}

/// =============================
/// 🔹 写操作（增删改）
/// =============================

/// 新增
Future<void> addData(
  String apiUrl,
  Map<String, dynamic>? data, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  final payload = data?..remove('id');
  await Http.post(
    apiUrl,
    data: payload,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  AppLogger.info('[Data] created resource via $apiUrl');
}

/// 修改
Future<void> editData(
  String apiUrl,
  Map<String, dynamic> data, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  await Http.put(
    apiUrl,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  AppLogger.info('[Data] updated resource via $apiUrl');
}

/// 删除
Future<void> removeData(
  String apiUrl, {
  Map<String, dynamic>? queryParameters,
  CancelToken? cancelToken,
}) async {
  await Http.delete(
    apiUrl,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
  AppLogger.warn('[Data] deleted resource via $apiUrl');
}
