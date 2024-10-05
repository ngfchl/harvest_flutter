import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../api/login.dart';
import '../../models/common_response.dart';
import '../../models/login_user.dart';
import '../../utils/dio_util.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import 'models/server.dart';
import 'models/sp_repository.dart';

class LoginController extends GetxController {
  List<Server> serverList = [];
  Server? selectedServer;
  final ServerRepository serverRepository = ServerRepository();
  bool isLoading = false;
  bool showPassword = true;
  bool testRes = false;
  DioUtil dioUtil = DioUtil();

  @override
  void onInit() async {
    // 触发 网络权限授权
    if (!kIsWeb) await Dio().get('https://ptools.fun');
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
    SPUtil.setString('server', baseUrl);
    update();
  }

  Future<CommonResponse> testServerConnection(Server server) async {
    isLoading = true; // 开始加载状态
    update();
    try {
      String baseUrl = '${server.protocol}://${server.domain}:${server.port}';
      await dioUtil.initialize(baseUrl);
      LoginUser loginUser = LoginUser(
        username: server.username,
        password: server.password,
      );
      CommonResponse response = await connectToServer(loginUser);

      update();
      return response;
    } catch (e) {
      // 发生错误，如网络问题或服务器不可达
      String msg = '服务器访问失败: $e';
      Logger.instance.e(msg);
      isLoading = false; // 结束加载状态
      update();
      return CommonResponse.error(msg: msg);
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
      serverList = serverRepository.serverList;
      update();
      return response;
    } on Exception catch (e) {
      String msg = '删除服务器失败: $e';
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

  Future<CommonResponse> connectToServer(LoginUser loginUser) async {
    isLoading = true;
    update();

    try {
      CommonResponse res = await UserAPI.login(loginUser);
      Logger.instance.i(res.code);
      Logger.instance.i(res.data);
      if (res.code == 0) {
        SPUtil.setMap('userinfo', res.data.toJson());
        SPUtil.setBool('isLogin', true);
      }
      return res;
    } catch (e, stackTrace) {
      Logger.instance.e(stackTrace.toString());
      SPUtil.setBool('isLogin', false);
      return CommonResponse.error(msg: "登录失败：${e.toString()}");
    }
  }

  Future<CommonResponse> doLogin() async {
    // 连接到服务器
    if (selectedServer == null ||
        selectedServer?.id == 0 ||
        selectedServer!.username.isEmpty ||
        selectedServer!.password.isEmpty) {
      // 判断是否为新添加的服务器

      return CommonResponse.error(msg: '服务器信息有误！');
    }
    initDio(selectedServer!);
    LoginUser loginUser = LoginUser(
      username: selectedServer?.username,
      password: selectedServer?.password,
    );
    return connectToServer(loginUser);
  }
}
