import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api.dart';
import '../../models/common_response.dart';
import '../../models/login_user.dart';
import '../../utils/dio_util.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../routes/app_pages.dart';
import 'models/server.dart';
import 'models/sp_repository.dart';

class LoginController extends GetxController {
  List<Server> serverList = [];
  Server? selectedServer;
  final ServerRepository serverRepository = ServerRepository();
  bool isLoading = false;
  bool showPassword = true;
  DioUtil dioUtil = DioUtil();
  GetStorage box = GetStorage();

  @override
  void onInit() async {
    await serverRepository.init();
    Logger.instance.i(serverRepository.serverList);
    serverList = serverRepository.serverList;
    // 寻找selected为true的服务器，并赋值给selectedServer
    selectedServer = serverList.firstWhereOrNull((server) => server.selected);
    if (selectedServer != null) {
      initDio(selectedServer!);
    }
    update();

    super.onInit();
  }

  bool get hasSelectedServer {
    return serverList.any((server) => server.selected);
  }

  void initDio(Server server) async {
    String baseUrl = '${server.protocol}://${server.domain}:${server.port}';
    await dioUtil.initialize(baseUrl);
    box.write('server', baseUrl);
    update();
  }

  Future<bool> testServerConnection(Server server) async {
    Dio dio = Dio();
    isLoading = true; // 开始加载状态
    update();
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
        isLoading = false; // 结束加载状态
        update();
        return true;
      } else {
        // 连接失败或响应码非正常范围
        Logger.instance
            .e('Failed to connect to server: ${response.statusCode}');
        isLoading = false; // 结束加载状态
        update();
        return false;
      }
    } catch (e) {
      // 发生错误，如网络问题或服务器不可达
      Logger.instance.e('An error occurred while connecting to the server: $e');
      isLoading = false; // 结束加载状态
      update();
      return false;
    }
  }

  void selectServer(Server server) async {
    selectedServer = server;
    server.selected = true;
    await saveServer(server);
    initDio(server);
    update();
  }

  Future<CommonResponse> deleteServer(Server server) async {
    try {
      if (server.selected) {
        selectedServer = null;
        SPUtil.remove('SelectedServer');
      }
      CommonResponse response = await serverRepository.deleteServer(server.id);
      if (response.code == 0) {
        serverList = serverRepository.serverList;
        Get.snackbar(
          '删除',
          '服务器已成功删除',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade400,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '删除',
          '删除服务器失败',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 3),
        );
      }
      update();
      return response;
    } on Exception catch (e) {
      String msg = '删除服务器失败: $e';
      Get.snackbar(
        '删除',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      );
      update();
      return CommonResponse.error(msg: msg);
    }
  }

  Future<CommonResponse> saveServer(Server server) async {
    try {
      CommonResponse response;
      if (server.id == 0) {
        // 判断是否为新添加的服务器
        Logger.instance.i('添加服务器');
        response = await serverRepository.insertServer(server);
      } else {
        // 根据ID更新服务器
        Logger.instance.i('更新服务器');
        response = await serverRepository.updateServer(server);
      }
      serverList = serverRepository.serverList;
      update(); // 更新UI，重新获取服务器列表
      return response;
    } catch (e) {
      String errMsg = "更新服务器出错啦：$e";
      update();
      return CommonResponse.error(msg: errMsg);
    }
  }

  void connectToServer() async {
    isLoading = true;
    update();
    // 连接到服务器
    if (selectedServer == null ||
        selectedServer?.id == 0 ||
        selectedServer!.username.isEmpty ||
        selectedServer!.password.isEmpty) {
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
    initDio(selectedServer!);
    LoginUser loginUser = LoginUser(
      username: selectedServer?.username,
      password: selectedServer?.password,
    );
    await doLogin(loginUser);
    isLoading = false;
    update();
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
    isLoading = false;
    update();
    return false;
  }
}
