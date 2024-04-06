import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

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
          GFIconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.black38,
            ),
            onPressed: () {
              controller.logout();
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
      drawer: SizedBox(
        width: 220,
        child: GFDrawer(
          semanticLabel: 'Harvest',
          elevation: 10,
          color: Colors.grey.shade500,
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
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
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
                  '数据图表',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
              ),
              ListTile(
                title: const Text(
                  '站点数据',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
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
                  controller.changePage(5);
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
                onTap: () {},
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
                onTap: () {},
              ),
              // ListTile(
              //   title: const Text(
              //     '支持站点',
              //     style: TextStyle(
              //       color: Colors.white70,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              //   onTap: () {},
              // ),
              ListTile(
                title: const Text(
                  '标签管理',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
              ),

              ListTile(
                title: const Text(
                  'RSS订阅',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () {},
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
      drawerEdgeDragWidth: 200,
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
