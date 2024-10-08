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
import 'package:url_launcher/url_launcher.dart';

import '../../../api/login.dart';
import '../../../models/authinfo.dart';
import '../../../utils/dio_util.dart';
import '../../../utils/logger_helper.dart';
import '../../../utils/platform.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';
import '../pages/download/download_controller.dart';
import '../pages/logging/view.dart';
import '../pages/setting/setting.dart';

class HomeController extends GetxController {
  int initPage = 0;
  final userinfo = RxMap();
  TextEditingController searchController = TextEditingController();
  DioUtil dioUtil = DioUtil();
  bool isDarkMode = false;
  bool isPhone = false;
  UpdateLogState? updateLogState;

  // final mySiteController = Get.put(MySiteController());

  final PageController pageController = PageController(initialPage: 0);
  final List<BottomNavigationBarItem> menuItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: '聚合搜索',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings_input_composite_sharp),
      label: '我的站点',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '仪表盘',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.task_outlined),
      label: '下载器',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: '计划任务',
    ),
  ];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  final List<Widget> pages = [
    const DashBoardPage(),
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
    LoggingPage(),
  ];

  @override
  void onInit() async {
    try {
      isPhone = PlatformTool.isPhone();
      Logger.instance.i('手机端：$isPhone');
      isDarkMode = Get.isDarkMode;
      initDio();
      userinfo.value = SPUtil.getLocalStorage('userinfo');
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
    Logger.instance.i(updateLogState?.localLogs);
  }

  Future<CommonResponse> doDockerUpdate() async {
    return await doDockerUpdateApi();
  }

  Future<void> changePage(int index) async {
    Get.back();
    if (index == 11) {
      if (PlatformTool.isWeb()) {
        Logger.instance.i('Explorer');
        Get.defaultDialog(
            title: '选择日志',
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      String url =
                          '${SPUtil.getLocalStorage('server')}/flower/tasks';
                      await openUrl(url);
                    },
                    child: const Text('任务列表')),
                ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      String url =
                          '${SPUtil.getLocalStorage('server')}/supervisor';
                      await openUrl(url);
                    },
                    child: const Text('服务日志')),
              ],
            ));
      } else {
        pageController.jumpToPage(index);
        initPage = index;
      }
    } else if (index == 12) {
      logout();
    } else {
      pageController.jumpToPage(index);
      initPage = index;
    }

    update();
  }

  Future<void> openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        '打开网页出错',
        '打开网页出错，不支持的客户端？',
      );
    }
  }
}
