import 'package:get/get.dart';
import 'package:harvest/api/user.dart';
import 'package:harvest/app/home/pages/user/UserModel.dart';

import '../../../../models/authinfo.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';

class UserController extends GetxController {
  bool isLoading = false;
  List<UserModel> userList = <UserModel>[];
  AuthInfo? userinfo;

  Future<void> getUserListFromServer() async {
    Logger.instance.i('从服务器拉取用户列表');
    CommonResponse response = await getUserModelListApi();
    if (response.code == 0) {
      if (userinfo?.isSuperUser == true) {
        userList = response.data;
      } else if (userinfo?.isStaff == true) {
        userList = response.data
            .where((UserModel item) =>
                item.username == userinfo?.user || !item.isStaff)
            .toList();
      } else {
        userList = response.data
            .where((UserModel item) => item.username == userinfo?.user)
            .toList();
      }
    } else {
      Get.snackbar('用户列表获取失败', "用户列表获取失败");
    }
    Logger.instance.i('从服务器拉取用户列表完成');
    update();
  }

  Future<CommonResponse> saveUserModel(UserModel user) async {
    CommonResponse res;
    Logger.instance.i(user.toJson());
    if (user.id == 0) {
      res = await addUserModelApi(user);
    } else {
      res = await editUserModelApi(user);
    }
    if (res.code == 0) {
      await getUserListFromServer();
    }
    return res;
  }

  Future<CommonResponse> removeUserModel(UserModel user) async {
    CommonResponse res = await removeUserModelApi(user);
    if (res.code == 0) {
      await getUserListFromServer();
    }
    return res;
  }

  Future<void> initData() async {
    isLoading = true;
    update();
    await getUserListFromServer();
    isLoading = false;
    update();
  }

  @override
  void onInit() async {
    super.onInit();
    userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo'));
    await initData();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
