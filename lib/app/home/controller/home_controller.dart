import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/app/home/pages/agg_search/view.dart';
import 'package:harvest/app/home/pages/dash_board/view.dart';
import 'package:harvest/app/home/pages/download/download.dart';
import 'package:harvest/app/home/pages/my_rss/view.dart';
import 'package:harvest/app/home/pages/my_site/view.dart';
import 'package:harvest/app/home/pages/option/view.dart';
import 'package:harvest/app/home/pages/setting/setting.dart';
import 'package:harvest/app/home/pages/subscribe/view.dart';
import 'package:harvest/app/home/pages/subscribe_history/view.dart';
import 'package:harvest/app/home/pages/subscribe_tag/view.dart';
import 'package:harvest/app/home/pages/task/view.dart';

import '../../../utils/dio_util.dart';
import '../../../utils/logger_helper.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';

class HomeController extends GetxController {
  var initPage = 4.obs;
  final userinfo = RxMap();
  GetStorage box = GetStorage();
  TextEditingController searchController = TextEditingController();
  DioUtil dioUtil = DioUtil();

  // final mySiteController = Get.put(MySiteController());

  final PageController pageController = PageController(initialPage: 4);
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
    const AggSearchPage(),
    const MySitePage(),
    const DashBoardPage(),
    const DownloadPage(),
    TaskPage(),
    SettingPage(),
    const MyRssPage(),
    const SubscribePage(),
    const SubscribeTagPage(),
    const SubscribeHistoryPage(),
    const OptionPage(),
  ];

  @override
  void onInit() async {
    try {
      initDio();
      userinfo.value = box.read('userinfo');
      update();
    } catch (e) {
      Logger.instance.e('初始化失败 $e');
      Get.offAllNamed(Routes.LOGIN);
    }
    // await mySiteController.initData();
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

  logout() {
    SPUtil.remove("userinfo");
    SPUtil.remove("isLogin");
    box.remove("userinfo");
    box.remove("isLogin");
    Get.offAllNamed(Routes.LOGIN);
  }

  void changePage(int index) {
    pageController.jumpToPage(index);
    initPage.value = index;
  }
}
