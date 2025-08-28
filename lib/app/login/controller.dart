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
  bool canConnectInternet = false;
  bool showPassword = true;
  bool switchServerLoading = false;
  DioUtil dioUtil = DioUtil();
  String backgroundImage = '';
  bool useLocalBackground = false;
  bool useBackground = false;
  bool useImageProxy = false;

  @override
  void onInit() async {
    Logger.instance.i('初始化登录页面');

    useBackground = SPUtil.getBool('useBackground');
    if (useBackground) {
      useImageProxy = SPUtil.getBool('useImageProxy');
      useLocalBackground = SPUtil.getBool('useLocalBackground');

      backgroundImage = SPUtil.getString('backgroundImage',
          defaultValue:
              'https://cci1.yiimii.com/uploads/2023/11/20231114005921427.jpg');
      Logger.instance.d('背景图：$backgroundImage');
    }
    await serverRepository.init();
    Logger.instance.i(serverRepository.serverList);
    initServerList();
    await getNetworkPermission();
    super.onInit();
  }

  ///@title 获取网络权限
  ///@description 获取网络权限
  ///@updateTime
  Future<void> getNetworkPermission() async {
    canConnectInternet =
        SPUtil.getBool('canConnectInternet', defaultValue: false);
    // 触发 网络权限授权
    if (!kIsWeb && !canConnectInternet) {
      Logger.instance.i('触发网络访问权限中...');
      var res = await Dio().get('https://www.baidu.com');
      if (res.statusCode == 200) {
        canConnectInternet = true;
        SPUtil.setBool('canConnectInternet', true);
      }
    }
  }

  ///@title 初始化服务器列表
  ///@description 初始化服务器列表
  ///@updateTime
  initServerList() {
    Logger.instance.i('开始读取服务器列表');
    serverList = serverRepository.serverList;
    Logger.instance.i('读取完毕，共有${serverList.length}个服务器');
    // 寻找selected为true的服务器，并赋值给selectedServer
    selectedServer = serverList.firstWhereOrNull((server) => server.selected);
    Logger.instance.i('选中服务器：${selectedServer?.name.toString()}');
    if (selectedServer != null) {
      initDio(selectedServer!);
    }
  }

  ////@title 判断是否有选中的服务器
  ///@description
  ///@updateTime
  bool get hasSelectedServer {
    return serverList.any((server) => server.selected);
  }

  ////@title 初始化服务器连接
  ///@description
  ///@updateTime
  void initDio(Server server) async {
    await dioUtil.initialize(server.entry);
    SPUtil.setString('server', server.entry);
    update();
  }

  ////@title 测试服务器连接
  ///@description
  ///@updateTime
  Future<CommonResponse> testServerConnection(Server server) async {
    try {
      await dioUtil.initialize(server.entry);
      LoginUser loginUser = LoginUser(
        username: server.username,
        password: server.password,
      );
      CommonResponse response = await connectToServer(loginUser);
      return response;
    } catch (e) {
      // 发生错误，如网络问题或服务器不可达
      String msg = '服务器访问失败: $e';
      Logger.instance.e(msg);
      return CommonResponse.error(msg: msg);
    }
  }

  ////@title 选择服务器
  ///@description
  ///@updateTime
  void selectServer(Server server, {bool shouldSave = true}) async {
    switchServerLoading = true;
    update();
    selectedServer = server;

    if (shouldSave) {
      server = server.copyWith(selected: true);
      saveServer(server);
    }
    await Future.delayed(Duration(milliseconds: 1000), () {
      switchServerLoading = false;
      update();
      initServerList();
    });
  }

  ///@title 删除服务器
  ///@description
  ///@updateTime
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

  ///@title 保存服务器
  ///@description
  ///@updateTime
  Future<CommonResponse> saveServer(Server server) async {
    try {
      CommonResponse response;
      if (server.id == 0) {
        // 判断是否为新添加的服务器
        Logger.instance.i('添加服务器');
        if (selectedServer == null || server.selected) {
          server = server.copyWith(selected: true);
          selectServer(server, shouldSave: false);
        }
        response = await serverRepository.insertServer(server);
      } else {
        // 根据ID更新服务器
        Logger.instance.i('更新服务器: ${server.selected}');
        response = await serverRepository.updateServer(server);
      }

      serverList = serverRepository.serverList;
      update(); // 更新UI，重新获取服务器列表
      return response;
    } catch (e, trace) {
      String errMsg = "更新服务器出错啦：$e";
      Logger.instance.e(errMsg);
      Logger.instance.e(trace);
      update();
      return CommonResponse.error(msg: errMsg);
    }
  }

  ///@title 登录服务器
  ///@description
  ///@updateTime
  Future<CommonResponse> connectToServer(LoginUser loginUser) async {
    try {
      await SPUtil.remove('userinfo');
      SPUtil.setBool('isLogin', false);
      DioUtil.instance.clearAuthToken();
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

  ///@title 登录操作
  ///@description
  ///@updateTime
  Future<CommonResponse> doLogin() async {
    isLoading = true;
    update();

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

  ///@title 清除服务器记录
  ///@description TODO
  ///@updateTime
  clearServerCache() async {
    return await serverRepository.clearServer();
  }
}
