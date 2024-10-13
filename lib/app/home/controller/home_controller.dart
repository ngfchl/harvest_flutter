import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/agg_search/view.dart';
import 'package:harvest/app/home/pages/dash_board/view.dart';
import 'package:harvest/app/home/pages/dou_ban/view.dart';
import 'package:harvest/app/home/pages/download/download.dart';
import 'package:harvest/app/home/pages/my_rss/view.dart';
import 'package:harvest/app/home/pages/my_site/view.dart';
import 'package:harvest/app/home/pages/subscribe/view.dart';
import 'package:harvest/app/home/pages/subscribe_history/view.dart';
import 'package:harvest/app/home/pages/subscribe_tag/view.dart';
import 'package:harvest/app/home/pages/task/view.dart';
import 'package:harvest/models/common_response.dart';

import '../../../api/api.dart';
import '../../../api/login.dart';
import '../../../models/authinfo.dart';
import '../../../utils/dio_util.dart';
import '../../../utils/logger_helper.dart';
import '../../../utils/platform.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';
import '../pages/download/download_controller.dart';
import '../pages/models/AuthPeriod.dart';
import '../pages/setting/setting.dart';
import '../pages/ssh/view.dart';

class HomeController extends GetxController {
  int initPage = 0;
  AuthInfo? userinfo;
  TextEditingController searchController = TextEditingController();
  DioUtil dioUtil = DioUtil();
  bool isDarkMode = false;
  bool isPhone = false;
  UpdateLogState? updateLogState;
  AuthPeriod? authInfo;

  // final mySiteController = Get.put(MySiteController());

  final PageController pageController = PageController(initialPage: 0);

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  final List<Widget> pages = [
    const DashBoardPage(),
  ];

  @override
  void onReady() {
    pages.addAll([
      const AggSearchPage(),
      const MySitePage(),
      const DownloadPage(),
      TaskPage(),
      SettingPage(),
      const SubscribePage(),
      const MyRssPage(),
      const SubscribeHistoryPage(),
      const SubscribeTagPage(),
      const DouBanPage(),
      SshWidget(),
    ]);
    update();
  }

  @override
  void onInit() async {
    try {
      await getAuthInfo();

      isPhone = PlatformTool.isPhone();
      Logger.instance.d('手机端：$isPhone');
      isDarkMode = Get.isDarkMode;
      initDio();
      userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo'));
      update();
    } catch (e) {
      Logger.instance.e('初始化失败 $e');
      Get.offAllNamed(Routes.LOGIN);
    }
    // await mySiteController.initData();
    // pageController.jumpToPage(pages.length - 1);
    await initUpdateLogState();
    super.onInit();
  }

  void initDio() async {
    String? baseUrl = SPUtil.getLocalStorage('server');
    if (baseUrl == null) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // 初始化dio
      await dioUtil.initialize(baseUrl);
    }
  }

  getAuthInfo() async {
    final response = await DioUtil().get(Api.AUTH_INFO);
    if (response.statusCode == 200) {
      // Logger.instance.d(response.data['data']);
      final data = response.data;
      String msg = '成功获取到授权信息：$data';
      Logger.instance.i(msg);
      if (data['code'] == 0) {
        authInfo = AuthPeriod.fromJson(data['data']);
      }
    } else {
      String msg = '获取数据列表失败: ${response.statusCode}';
      Logger.instance.e(msg);
    }
    update();
  }

  void logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    Get.delete<DownloadController>();
    Get.delete<HomeController>();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> initUpdateLogState() async {
    final res = await getGitUpdateLog();
    if (res.code == 0) {
      updateLogState = res.data;
    } else {
      Get.snackbar('更新日志', '获取更新日志失败！', colorText: Colors.red);
    }
    Logger.instance.d(updateLogState?.localLogs);
  }

  Future<CommonResponse> doDockerUpdate() async {
    return await doDockerUpdateApi();
  }

  Future<void> changePage(int index) async {
    Get.back();

    pageController.jumpToPage(index);
    initPage = index;

    update();
  }
}
