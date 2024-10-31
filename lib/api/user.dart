import '../app/home/pages/user/UserModel.dart';
import '../models/common_response.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getUserModelListApi() async {
  return await fetchDataList(Api.AUTH_USER, (p0) => UserModel.fromJson(p0));
}

///  修改用户信息
editUserModelApi(UserModel user) async {
  String apiUrl = '${Api.AUTH_USER}/${user.id}';
  return await editData(apiUrl, user.toJson());
}

/// 保存用户信息
addUserModelApi(UserModel user) async {
  String apiUrl = Api.AUTH_USER;
  return await addData(apiUrl, user.toJson());
}

///  修改用户信息
removeUserModelApi(UserModel user) async {
  String apiUrl = '${Api.AUTH_USER}/${user.id}';
  return await removeData(apiUrl);
}
