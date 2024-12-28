import '../models/common_response.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';

Future<CommonResponse<List<T>>> fetchDataList<T>(
    String apiEndpoint, T Function(Map<String, dynamic>) fromJson,
    {Map<String, dynamic>? queryParameters}) async {
  final response =
      await DioUtil().get(apiEndpoint, queryParameters: queryParameters);
  if (response.statusCode == 200) {
    // Logger.instance.d(response.data['data']);
    final dataList = (response.data['data'] as List)
        .map<T>((item) => fromJson(item))
        .toList();
    String msg = '成功获取到${dataList.length}条数据';
    // Logger.instance.i(msg);
    return CommonResponse<List<T>>.success(data: dataList, msg: msg);
  } else {
    String msg = '获取数据列表失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse<List<T>>.error(msg: msg);
  }
}

Future<CommonResponse<List?>> fetchBasicList<T>(String apiEndpoint,
    {Map<String, dynamic>? queryParameters}) async {
  final response =
      await DioUtil().get(apiEndpoint, queryParameters: queryParameters);
  if (response.statusCode == 200) {
    if (response.data['data'] != null) {
      final dataList = response.data['data'] as List;
      String msg = '成功获取到${dataList.length}条数据';
      return CommonResponse<List>.success(data: dataList, msg: msg);
    } else {
      return CommonResponse.fromJson(response.data, (p0) => null);
    }
  } else {
    String msg = '获取数据列表失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse<List<T>>.error(msg: msg);
  }
}

Future<CommonResponse> fetchBasicData<T>(String apiEndpoint,
    {Map<String, dynamic>? queryParameters}) async {
  final response =
      await DioUtil().get(apiEndpoint, queryParameters: queryParameters);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(
        response.data, (p0) => p0 != null ? p0 as Map<String, dynamic> : p0);
  } else {
    String msg = '获取数据列表失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> editData<T>(
    String apiUrl, Map<String, dynamic> formData) async {
  try {
    final response = await DioUtil().put(apiUrl, formData: formData);
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '编辑数据失败: ${response.statusCode}';
      return CommonResponse.error(msg: msg);
    }
  } catch (e) {
    String msg = '请求失败: $e';
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> addData(String apiUrl, Map<String, dynamic> data) async {
  try {
    final response = await DioUtil().post(apiUrl, formData: data..remove('id'));
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '保存数据失败: ${response.statusCode}';
      return CommonResponse.error(msg: msg);
    }
  } catch (e) {
    String msg = '请求失败: $e';
    Logger.instance.e(msg);
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> removeData(String apiUrl,
    {Map<String, dynamic>? queryParameters}) async {
  final response =
      await DioUtil().delete(apiUrl, queryParameters: queryParameters);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '数据删除失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}
