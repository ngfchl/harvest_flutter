import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../utils/storage.dart';
import '../routes/app_pages.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
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
          GFIconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black38,
            ),
            onPressed: () {
              Get.toNamed(Routes.SEARCH);
            },
            type: GFButtonType.transparent,
          ),
        ],
      ),
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          controller.initPage.value = index;
          controller.update();
        },
        children: controller.pages,
      ),
      drawer: GFDrawer(
        elevation: 10,
        color: Colors.teal.shade600,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 60,
            ),
            GFDrawerHeader(
              centerAlign: true,
              closeButton: null,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              currentAccountPicture: const GFAvatar(
                radius: 80.0,
                backgroundImage: NetworkImage(
                    "https://cdn.pixabay.com/photo/2017/12/03/18/04/christmas-balls-2995437_960_720.jpg"),
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
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    // Text('admin@admin.com'),
                    Text(
                      '当前服务器：${SPUtil.getString('server')}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: const Text(
                '仪表盘',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '系统设置',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '修改密码',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '运行日志',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '支持站点',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '反馈帮助',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                '关于',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      drawerEdgeDragWidth: 0.0,
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
}
