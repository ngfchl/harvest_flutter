import '../models/common_response.dart';
import '../utils/dio_util.dart';

Future<CommonResponse> editData<T>(
    String apiUrl, Map<String, dynamic> formData) async {
  try {
    final response = await DioUtil().put(apiUrl, formData: formData);
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '编辑数据失败: ${response.statusCode}';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } catch (e) {
    String msg = '请求失败: $e';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> saveData(
    String apiUrl, Map<String, dynamic> data) async {
  try {
    final response = await DioUtil().post(apiUrl, formData: data);
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '保存数据失败: ${response.statusCode}';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } catch (e) {
    String msg = '请求失败: $e';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
