import '../app/home/pages/models/option.dart';
import '../models/common_response.dart';
import '../utils/dio_util.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getOptionListApi() async {
  return await fetchDataList(Api.OPTION_OPERATE, (p0) => Option.fromJson(p0));
}

///  修改下载器信息
editOptionApi(Option option) async {
  String apiUrl = '${Api.OPTION_OPERATE}/${option.id}';
  return await editData(apiUrl, option.toJson());
}

/// 保存下载器信息
addOptionApi(Option option) async {
  String apiUrl = Api.OPTION_OPERATE;
  return await addData(apiUrl, option.toJson());
}

///  修改下载器信息
removeOptionApi(Option option) async {
  String apiUrl = '${Api.OPTION_OPERATE}/${option.id}';
  return await removeData(apiUrl);
}

/// 通知测试
Future<CommonResponse> noticeTestApi(
    Map<String, dynamic>? queryParameters) async {
  return await fetchBasicList(Api.NOTICE_TEST,
      queryParameters: queryParameters);
}

/// 订阅标签 导入
importBaseSubTag() async {
  try {
    final response = await DioUtil().get(
      Api.IMPORT_SUB_TAG,
    );
    if (response.statusCode == 200) {
      return CommonResponse.fromJson(response.data, (p0) => null);
    } else {
      String msg = '订阅标签 导入失败！: ${response.statusCode}';
      return CommonResponse.error(msg: msg);
    }
  } catch (e) {
    String msg = '订阅标签 导入失败！: $e';
    return CommonResponse.error(msg: msg);
  }
}
