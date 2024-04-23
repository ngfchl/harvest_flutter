import 'package:app_service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/api/mysite.dart';

import 'controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      extendBody: true,
      // backgroundColor: Colors.white54,
      appBar: GFAppBar(
        backgroundColor: Colors.white54,
        elevation: 1.5,
        iconTheme: const IconThemeData(color: Colors.black38),
        // flexibleSpace: Container(
        //   decoration: BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.centerLeft,
        //       end: Alignment.centerRight,
        //       colors: [
        //         Colors.white38.withOpacity(0.3),
        //         Colors.white54.withOpacity(0.4),
        //         Colors.white70.withOpacity(0.6),
        //       ],
        //     ),
        //   ),
        // ),

        actions: <Widget>[
          _actionButtonList(context),
        ],
      ),
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          // controller.initPage.value = index;
          // controller.update();
        },
        children: controller.pages,
      ),
      drawer: SizedBox(
        width: 220,
        child: GFDrawer(
          semanticLabel: 'Harvest',
          elevation: 10,
          color: Colors.black87,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 30,
              ),
              GFDrawerHeader(
                centerAlign: true,
                closeButton: null,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                currentAccountPicture: const GFAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                // otherAccountsPictures: [
                //   Image(
                //     image: NetworkImage(
                //         "https://cdn.pixabay.com/photo/2019/12/20/00/03/road-4707345_960_720.jpg"),
                //     fit: BoxFit.cover,
                //   ),
                //   GFAvatar(
                //     child: Text("ab"),
                //   )
                // ],
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        controller.userinfo['user'],
                        style: const TextStyle(color: Colors.white70),
                      ),
                      // Text('admin@admin.com'),
                      Text(
                        '${controller.box.read('server')}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  '豆瓣影视',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(11);
                },
              ),
              ListTile(
                title: const Text(
                  '站点数据',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.changePage(1);
                },
              ),
              ListTile(
                title: const Text(
                  '计划任务',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.changePage(4);
                },
              ),
              ListTile(
                title: const Text(
                  '下载管理',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.changePage(3);
                },
              ),
              ListTile(
                title: const Text(
                  '修改密码',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  '订阅管理',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(7);
                },
              ),
              ListTile(
                title: const Text(
                  '订阅历史',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(9);
                },
              ),
              ListTile(
                title: const Text(
                  '标签管理',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(8);
                },
              ),
              ListTile(
                title: const Text(
                  'RSS订阅',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(6);
                },
              ),
              ListTile(
                title: const Text(
                  '系统设置',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  Get.back();
                  controller.pageController.jumpToPage(5);
                },
              ),
              ListTile(
                title: const Text(
                  '更换账号',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {
                  controller.logout();
                },
              ),
            ],
          ),
        ),
      ),
      drawerEdgeDragWidth: 280,
      drawerEnableOpenDragGesture: false,
      drawerScrimColor: Colors.white.withOpacity(0.6),
      // floatingActionButton: GFIconButton(
      //   icon: const Icon(Icons.menu_outlined),
      //   color: Colors.teal.shade700,
      //   size: 18,
      //   onPressed: () {
      //     _globalKey.currentState?.openDrawer();
      //   },
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white54.withOpacity(0.85),
            elevation: 0,
            // showSelectedLabels: false,
            // showUnselectedLabels: false,
            currentIndex: controller.initPage.value,
            onTap: controller.changePage,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            // backgroundColor: Colors.blueGrey,
            iconSize: 18,
            selectedItemColor: Colors.teal.shade300,
            unselectedItemColor: Colors.grey[150],
            items: controller.menuItems,
          )),
    );
  }

  Widget _actionButtonList(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // const Wen(),
        const ThemeModal(
          itemSize: 28,
        ),
        GFIconButton(
          icon: Icon(
            Icons.exit_to_app,
            size: 22,
            color: Colors.red.shade500,
          ),
          onPressed: () {
            controller.logout();
          },
          type: GFButtonType.transparent,
        ),
        CustomPopup(
          showArrow: false,
          // contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          barrierColor: Colors.transparent,
          content: SizedBox(
            width: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuItem<String>(
                  child: const Text('全员签到'),
                  onTap: () async {
                    await signAllSiteButton();
                  },
                ),
                PopupMenuItem<String>(
                  child: const Text('站点数据'),
                  onTap: () async {
                    await getAllStatusButton();
                  },
                ),
                PopupMenuItem<String>(
                  child: const Text('PTPP'),
                  onTap: () async {
                    await importFromPTPP();
                  },
                ),
                PopupMenuItem<String>(
                  child: const Text('CC 同步'),
                  onTap: () async {
                    await importFromCookieCloud();
                  },
                ),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.add_box_outlined,
              size: 24,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> signAllSiteButton() async {
    final res = await signIn(null);
    Get.back();
    if (res.code == 0) {
      Get.snackbar(
        '签到任务',
        '签到任务信息：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.green.withOpacity(0.7),
      );
    } else {
      Get.snackbar(
        '签到失败',
        '签到任务执行出错啦：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
      );
    }
  }

  Future<void> importFromPTPP() async {
    final res = await importFromPTPPApi();
    Get.back();
    if (res.code == 0) {
      Get.snackbar(
        'PTPP导入任务',
        'PTPP导入任务信息：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.green.withOpacity(0.7),
      );
    } else {
      Get.snackbar(
        'PTPP导入任务失败',
        'PTPP导入任务执行出错啦：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
      );
    }
  }

  Future<void> importFromCookieCloud() async {
    final res = await importFromCookieCloudApi();
    Get.back();
    if (res.code == 0) {
      Get.snackbar(
        'CookieCloud任务',
        'CookieCloud任务信息：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.green.withOpacity(0.7),
      );
    } else {
      Get.snackbar(
        'CookieCloud失败',
        'CookieCloud任务执行出错啦：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
      );
    }
  }

  Future<void> getAllStatusButton() async {
    final res = await getNewestStatus(null);
    Get.back();
    if (res.code == 0) {
      Get.snackbar(
        '更新数据',
        '更新数据任务信息：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.green.withOpacity(0.7),
      );
    } else {
      Get.snackbar(
        '更新数据',
        '更新数据执行出错啦：${res.msg}',
        colorText: Colors.white,
        backgroundColor: Colors.red.withOpacity(0.7),
      );
    }
  }
}
