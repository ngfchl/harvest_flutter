import '../app/home/pages/models/option.dart';
import '../models/common_response.dart';
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
