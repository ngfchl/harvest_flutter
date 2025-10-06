import '../models/common_response.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getSourceListApi({String path = '/downloads', bool noCache = false}) async {
  return await fetchBasicData(Api.SOURCE_LIST, queryParameters: {"path": path, "no_cache": noCache});
}

/// 获取
Future<CommonResponse> getSourceUrlApi({required String path}) async {
  return await fetchData(Api.SOURCE_URL, queryParameters: {"file_path": path});
}

///  删除资源
Future<CommonResponse> removeSourceApi(String path) async {
  return await removeData(Api.SOURCE_OPERATE, queryParameters: {"file_path": path});
}

///  重命名资源
Future<CommonResponse> editSourceApi(String path, String newName) async {
  return await editData(Api.SOURCE_OPERATE, {}, queryParameters: {"file_path": path, "new_name": newName});
}
//
// /// 保存用户信息
// addUserModelApi(UserModel user) async {
//   String apiUrl = Api.AUTH_USER;
//   return await addData(apiUrl, user.toJson());
// }
//
// ///  修改用户信息
// removeUserModelApi(UserModel user) async {
//   String apiUrl = '${Api.AUTH_USER}/${user.id}';
//   return await removeData(apiUrl);
// }
