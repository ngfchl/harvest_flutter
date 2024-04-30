import 'package:app_service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/api/mysite.dart';
import 'package:harvest/models/common_response.dart';

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.orange.withOpacity(0.4),
                Colors.grey.withOpacity(0.3),
                Colors.brown.withOpacity(0.1),
              ],
            ),
          ),
        ),
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
        width: 200,
        child: GFDrawer(
          semanticLabel: 'Harvest',
          elevation: 10,
          color: Colors.brown.shade100,
          child: _buildMenuBar(context),
        ),
      ),
      drawerEdgeDragWidth: 200,
      // drawerEnableOpenDragGesture: false,
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
      // bottomNavigationBar: Obx(() => BottomNavigationBar(
      //       type: BottomNavigationBarType.fixed,
      //       backgroundColor: Colors.white54.withOpacity(0.85),
      //       elevation: 0,
      //       // showSelectedLabels: false,
      //       // showUnselectedLabels: false,
      //       currentIndex: controller.initPage,
      //       onTap: controller.changePage,
      //       selectedFontSize: 12,
      //       unselectedFontSize: 12,
      //       // backgroundColor: Colors.blueGrey,
      //       iconSize: 18,
      //       selectedItemColor: Colors.teal.shade300,
      //       unselectedItemColor: Colors.grey[150],
      //       items: controller.menuItems,
      //     )),
    );
  }

  Widget _buildMenuBar(context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width, // 确保宽度适配屏幕
          ),
          child: IntrinsicHeight(
            child: NavigationRail(
              useIndicator: true,
              extended: true,
              selectedIndex: controller.initPage,
              onDestinationSelected: (index) => controller.changePage(index),
              backgroundColor: Colors.brown.shade100,
              labelType: NavigationRailLabelType.none,
              leading: GFDrawerHeader(
                centerAlign: true,
                closeButton: null,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                currentAccountPicture: const GFAvatar(
                  radius: 80.0,
                  backgroundImage: AssetImage('assets/images/launch_image.png'),
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
                      Tooltip(
                        message: '${controller.box.read('server')}',
                        child: Text(
                          '${controller.box.read('server')}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home, size: 18),
                  label: Text('仪表盘'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search, size: 18),
                  label: Text('聚合搜索'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.language, size: 18),
                  label: Text('站点数据'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.cloud_download, size: 18),
                  label: Text('下载管理'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.task, size: 18),
                  label: Text('计划任务'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings, size: 18),
                  label: Text('系统设置'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.subscriptions_outlined, size: 18),
                  label: Text('订阅管理'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.rss_feed, size: 18),
                  label: Text('站点RSS'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history, size: 18),
                  label: Text('订阅历史'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.tag, size: 18),
                  label: Text('订阅标签'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.theaters, size: 18),
                  label: Text('豆瓣影视'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.list_alt, size: 18),
                  label: Text('访问日志'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.description, size: 18),
                  label: Text('任务日志'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_box_rounded, size: 18),
                  label: Text('更换账号'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _actionButtonList(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const Wen(),
        SizedBox(
          height: 20,
          width: 20,
          child: GetBuilder<HomeController>(builder: (controller) {
            return InkWell(
              onTap: () {
                Get.changeTheme(controller.isDarkMode
                    ? ThemeData.light()
                    : ThemeData.dark());
                controller.isDarkMode = !controller.isDarkMode;
                controller.update();
              },
              child: Icon(
                  controller.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            );
          }),
        ),
        const SizedBox(width: 15),
        const SizedBox(
          height: 20,
          width: 20,
          child: ThemeModal(
            itemSize: 28,
          ),
        ),
        // GFIconButton(
        //   icon: Icon(
        //     Icons.exit_to_app,
        //     size: 22,
        //     color: Colors.red.shade500,
        //   ),
        //   onPressed: () {
        //     controller.logout();
        //   },
        //   type: GFButtonType.transparent,
        // ),
        const SizedBox(width: 15),
        CustomPopup(
          showArrow: false,
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
                PopupMenuItem<String>(
                  child: const Text('清除缓存'),
                  onTap: () async {
                    CommonResponse res = await clearMyCacheApi();
                    Get.snackbar(
                      '清除缓存',
                      '清除缓存：${res.msg}',
                      colorText: Colors.white,
                      backgroundColor: Colors.green.shade300,
                    );
                  },
                ),
              ],
            ),
          ),
          child: Icon(
            Icons.add_box_outlined,
            size: 24,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 20)
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
