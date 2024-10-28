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

  List<Widget> pages = [
    const DashBoardPage(),
    const AggSearchPage(),
    const DownloadPage(),
    TaskPage(),
    const SubscribePage(),
    const SubscribeHistoryPage(),
    const DouBanPage(),
  ];
  List<NavigationRailDestination> destinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.home, size: 18),
      label: Text('仪表盘'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.search, size: 18),
      label: Text('聚合搜索'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.cloud_download, size: 18),
      label: Text('下载管理'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.subscriptions_outlined, size: 18),
      label: Text('订阅管理'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.history, size: 18),
      label: Text('订阅历史'),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.theaters, size: 18),
      label: Text('豆瓣影视'),
    ),
  ];

  @override
  void onReady() async {
    await getAuthInfo();
    initMenus();
    await initUpdateLogState();
    update();
  }

  @override
  void onInit() async {
    try {
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

  initMenus() {
    pages = [
      const DashBoardPage(),
      const AggSearchPage(),
      if (userinfo?.isStaff == true) const MySitePage(),
      const DownloadPage(),
      TaskPage(),
      if (userinfo?.isStaff == true) SettingPage(),
      const SubscribePage(),
      if (userinfo?.isStaff == true) const MyRssPage(),
      const SubscribeHistoryPage(),
      if (userinfo?.isStaff == true) const SubscribeTagPage(),
      const DouBanPage(),
      if (userinfo?.isStaff == true) SshWidget(),
    ];
    destinations = [
      const NavigationRailDestination(
        icon: Icon(Icons.home, size: 18),
        label: Text('仪表盘'),
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.search, size: 18),
        label: Text('聚合搜索'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.language, size: 18),
          label: Text('站点数据'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.cloud_download, size: 18),
        label: Text('下载管理'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.task, size: 18),
          label: Text('计划任务'),
        ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.settings, size: 18),
          label: Text('系统设置'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.subscriptions_outlined, size: 18),
        label: Text('订阅管理'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.rss_feed, size: 18),
          label: Text('站点RSS'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.history, size: 18),
        label: Text('订阅历史'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.tag, size: 18),
          label: Text('订阅标签'),
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.theaters, size: 18),
        label: Text('豆瓣影视'),
      ),
      if (userinfo?.isStaff == true)
        const NavigationRailDestination(
          icon: Icon(Icons.description, size: 18),
          label: Text('SSH终端'),
        ),
    ];
  }

  void logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    dioUtil.dio?.close();
    Get.delete<DownloadController>();
    Get.delete<HomeController>();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> initUpdateLogState() async {
    final res = await getGitUpdateLog();
    if (res.code == 0) {
      updateLogState = res.data;
    } else {
      Get.snackbar('更新日志', '获取更新日志失败！${res.msg}', colorText: Colors.red);
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
