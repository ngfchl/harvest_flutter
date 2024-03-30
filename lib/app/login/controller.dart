import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api.dart';
import '../../models/login_user.dart';
import '../../utils/dio_util.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../routes/app_pages.dart';
import 'models/server.dart';
import 'models/server_repository.dart';

class LoginController extends GetxController {
  var serversList = RxList<Server>();
  var selectedServer = Rx<Server?>(null);
  final ServerRepository serverRepository = ServerRepository();
  RxBool isLoading = false.obs;
  RxBool showPassword = true.obs;
  DioUtil dioUtil = DioUtil();
  GetStorage box = GetStorage();

  @override
  void onInit() async {
    super.onInit();
    await serverRepository.init();
    serversList.value = await serverRepository.getServers();
    // 寻找selected为true的服务器，并赋值给selectedServer
    selectedServer.value =
        serversList.firstWhereOrNull((server) => server.selected);
    if (selectedServer.value != null) {
      Server? server = selectedServer.value;
      initDio(server!);
    }
  }

  bool get hasSelectedServer {
    return serversList.any((server) => server.selected);
  }

  void initDio(Server server) {
    String baseUrl = '${server.protocol}://${server.domain}:${server.port}';
    dioUtil.initialize(baseUrl);
    box.write('server', baseUrl);
  }

  Future<bool> testServerConnection(Server server) async {
    Dio dio = Dio();
    isLoading.value = true; // 开始加载状态
    try {
      String baseUrl = '${server.protocol}://${server.domain}:${server.port}';
      Options options = Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      );

      final response = await dio.get(baseUrl, options: options);

      if (response.statusCode == 200) {
        // 连接成功
        Logger.instance
            .i('Succeed to connect to server: ${response.statusCode}');
        isLoading.value = false; // 结束加载状态
        return true;
      } else {
        // 连接失败或响应码非正常范围
        Logger.instance
            .e('Failed to connect to server: ${response.statusCode}');
        isLoading.value = false; // 结束加载状态
        return false;
      }
    } catch (e) {
      // 发生错误，如网络问题或服务器不可达
      Logger.instance.e('An error occurred while connecting to the server: $e');
      isLoading.value = false; // 结束加载状态
      return false;
    }
  }

  void selectServer(Server server) async {
    selectedServer.value = server;
    server.selected = true;
    await saveServer(server);
    update();
  }

  Future<bool> deleteServer(Server server) async {
    try {
      if (server.selected) {
        selectedServer.value = null;
        SPUtil.remove('SelectedServer');
      }
      serverRepository.deleteServer(server.id);
      serversList.value = await serverRepository.getServers();
      Get.snackbar(
        '删除',
        '服务器已成功删除',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 3),
      );
      update();
      return true;
    } on Exception catch (e) {
      String errMsg = e.toString();
      if (e.toString().contains('UNIQUE constraint')) {
        errMsg = "该服务器已存在！";
      }
      Logger.instance.e(e);
      Get.snackbar(
        '删除',
        '删除服务器失败: $errMsg',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> saveServer(Server server) async {
    try {
      if (server.id == 0) {
        // 判断是否为新添加的服务器
        await serverRepository.insertServer(server);
      } else {
        // 根据ID更新服务器
        await serverRepository.updateServer(server);
      }
      serversList.value = await serverRepository.getServers();

      update(); // 更新UI，重新获取服务器列表
      return {"flag": true, "message": "保存成功!"};
    } catch (e) {
      String errMsg = "";
      if (e.toString().contains('UNIQUE constraint')) {
        errMsg = "该服务器已存在！";
      }

      return {
        "flag": false,
        "message": errMsg,
      };
    }
  }

  void connectToServer() async {
    // 连接到服务器
    Server? server = selectedServer.value;
    if (server == null ||
        server.id == 0 ||
        server.username.isEmpty ||
        server.password.isEmpty) {
      // 判断是否为新添加的服务器
      Get.snackbar(
        '服务器信息设置有误',
        '无法连接到服务器，请检查用户名和密码',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    initDio(server);
    LoginUser loginUser = LoginUser(
      username: server.username,
      password: server.password,
    );
    await doLogin(loginUser);
  }

  Future<bool> doLogin(LoginUser loginUser) async {
    try {
      var res = await dioUtil.post(Api.LOGIN_URL, formData: loginUser.toJson());
      Logger.instance.i(res.statusCode);
      Logger.instance.i(res.data);
      if (res.data['code'] == 0) {
        box.write('userinfo', res.data["data"]);
        box.write('isLogin', true);
        Get.snackbar(
          '登录成功！',
          "欢迎 ${loginUser.username} 回来",
          backgroundColor: Colors.green.shade400,
        );
        Get.offNamed(Routes.HOME);
        return true;
      }
      Get.snackbar(
        '登录失败',
        res.data['msg'],
        backgroundColor: Colors.amber.shade400,
      );
    } catch (e, stackTrace) {
      Logger.instance.e(stackTrace.toString());
      Get.snackbar(
        '登录失败',
        e.toString(),
        backgroundColor: Colors.red.shade400,
      );
    }
    box.write('isLogin', false);
    return false;
  }
}
