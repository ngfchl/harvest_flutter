import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../utils/http.dart';
import '../../api/api.dart';
import '../../models/login_user.dart';
import '../../utils/storage.dart';
import '../routes/app_pages.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  bool isChecked = false;

  bool isServerEdit = false;
  final box = GetStorage();
  List<String> serverList = [...SPUtil.getStringList('ServerList')];
  TextEditingController serverController = TextEditingController(text: '');

  TextEditingController usernameController =
      TextEditingController(text: 'admin');
  TextEditingController passwordController =
      TextEditingController(text: 'adminadmin');

  void doLogin() async {
    String baseUrl = SPUtil.getString('server') ?? '';
    if (baseUrl.isEmpty) {
      Get.snackbar(
        "错误",
        "服务器配置出错啦，请先配置服务器再登录！",
        colorText: Colors.orange,
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 5,
      );
      return;
    }
    LoginUser loginUser = LoginUser(
      username: usernameController.text,
      password: passwordController.text,
    );
    try {
      await DioClient()
          .post(Api.LOGIN_URL, formData: loginUser.toJson())
          .then((res) => {
                if (res.data['code'] != 0)
                  {
                    Get.snackbar('登录失败', res.data['msg']),
                  }
                else
                  {
                    SPUtil.setMap("userinfo", res.data['data']),
                    SPUtil.setString("server", serverController.text),
                    SPUtil.setBool("isLogin", true),
                    box.write("isChecked", isChecked),
                    if (isChecked)
                      {
                        box.write('userData', loginUser.toJson()),
                      },
                    Get.offNamed(Routes.HOME)
                  }
              });
    } catch (e, stackTrace) {
      print(stackTrace.toString());
      Get.snackbar('登录失败', e.toString());
    }
  }

  void saveServer() {
    SPUtil.setString("server", serverController.text);
    // serverController.text = box.read("server");
    isServerEdit = true;
    update();
  }

  void editServer() {
    serverController.text = SPUtil.getString("server") ?? '';
    isServerEdit = false;
    update();
  }

  handleFogotPassword() {
    Get.snackbar('忘记密码', '找回密码中。。。');
  }

  @override
  void onInit() {
    isChecked = SPUtil.getBool("isChecked") ?? false;
    serverList = serverList.toSet().toList();
    if (serverList.isEmpty) {
      serverList = [serverController.text];
    }
    SPUtil.setStringList('ServerList', serverList);
    super.onInit();
  }

  void saveServerList() {
    serverList.insert(0, serverController.text);
    serverList = serverList.toSet().toList();
    SPUtil.setStringList('ServerList', serverList);
    update();
    Get.back();
  }

  void clearServerList() {
    SPUtil.remove('ServerList');
    serverList = [serverController.text];
    // serverList = serverList.toSet().toList();
    update();
    Get.back();
  }
}
