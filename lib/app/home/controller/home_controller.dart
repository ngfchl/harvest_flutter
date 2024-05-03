import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
import 'package:url_launcher/url_launcher.dart';

import '../../../api/api.dart';
import '../../../utils/dio_util.dart';
import '../../../utils/logger_helper.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';
import '../pages/download/download_controller.dart';
import '../pages/setting/setting.dart';

class HomeController extends GetxController {
  int initPage = 0;
  final userinfo = RxMap();
  GetStorage box = GetStorage();
  TextEditingController searchController = TextEditingController();
  DioUtil dioUtil = DioUtil();
  bool isDarkMode = false;

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
  ];

  @override
  void onInit() async {
    try {
      isDarkMode = Get.isDarkMode;
      initDio();
      userinfo.value = box.read('userinfo');
      update();
    } catch (e) {
      Logger.instance.e('初始化失败 $e');
      Get.offAllNamed(Routes.LOGIN);
    }
    // await mySiteController.initData();
    // pageController.jumpToPage(pages.length - 1);
    super.onInit();
  }

  void initDio() async {
    String? baseUrl = box.read('server');
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
    box.remove("userinfo");
    box.remove("isLogin");
    Get.delete<DownloadController>();
    Get.delete<HomeController>();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> changePage(int index, context) async {
    Get.back();
    if (index == 11) {
      String url =
          '${box.read('server')}/api/${Api.SYSTEM_LOGGING}/tail.html?processname=uvicorn&limit=10240';
      if (!Platform.isIOS && !Platform.isAndroid) {
        Logger.instance.i('Explorer');
        Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
              colorText: Theme.of(context).colorScheme.error);
        }
      } else {
        Get.toNamed(Routes.WEBVIEW, arguments: {
          'url': url,
        });
      }
    } else if (index == 12) {
      String url =
          '${box.read('server')}/api/${Api.SYSTEM_LOGGING}/tail.html?processname=celery-worker&limit=10240';
      if (!Platform.isIOS && !Platform.isAndroid) {
        Logger.instance.i('Explorer');
        Uri uri = Uri.parse(url);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
              colorText: Theme.of(context).colorScheme.error);
        }
      } else {
        Get.toNamed(Routes.WEBVIEW, arguments: {
          'url': url,
        });
      }
    } else if (index == 13) {
      logout();
    } else {
      pageController.jumpToPage(index);
      initPage = index;
    }

    update();
  }
}
