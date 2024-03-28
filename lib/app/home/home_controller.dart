import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage.dart';
import 'pages/index.dart';

class HomeController extends GetxController {
  var initPage = 2.obs;
  Map userinfo = {};
  TextEditingController searchController = TextEditingController();

  final PageController pageController = PageController(initialPage: 2);
  final List<BottomNavigationBarItem> menuItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.task),
      label: '计划任务',
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
      icon: Icon(Icons.settings),
      label: '系统设置',
    ),
  ];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  final List<Widget> pages = [
    // TaskPage(),
    // const MySitePage(),
    // const DashBoard(),
    // const DownloadPage(),
    // SettingPage(),
  ];

  @override
  void onInit() {
    userinfo = SPUtil.getMap('userinfo');
    // todo
    // 获取信息后向服务器申请校验
    update();
    super.onInit();
  }

  void changePage(int index) {
    pageController.jumpToPage(index);
    initPage.value = index;
  }
}
