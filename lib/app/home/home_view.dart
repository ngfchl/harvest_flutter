import 'dart:io';

import 'package:app_service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/pages/web_socket_logging/view.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';

import '../../common/custom_ua.dart';
import '../../common/custom_upgrade.dart';
import '../../common/logging.dart';
import '../../common/site_map.dart';
import '../../utils/storage.dart';
import '../../utils/string_utils.dart';
import 'controller/common_api.dart';
import 'controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          Get.defaultDialog(
            title: "退出",
            content: const Text('确定要退出收割机吗？'),
            // onConfirm: () {
            //   exit(0);
            // },
            onCancel: () {
              Navigator.of(context).pop(false);
            },
            confirm: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.redAccent.withAlpha(250)),
                ),
                onPressed: () {
                  exit(0);
                },
                child: const Text(
                  '退出',
                  style: TextStyle(color: Colors.white),
                )),
            textCancel: '取消',
            // textConfirm: '退出',
            // confirmTextColor: Colors.red,
            // buttonColor: Colors.red,
          );
        },
        child: Scaffold(
          key: _globalKey,
          extendBody: true,
          appBar: GFAppBar(
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
          body: controller.isPhone
              ? PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    // controller.initPage.value = index;
                    // controller.update();
                  },
                  children: controller.pages,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomCard(
                      width: 200,
                      height: double.infinity,
                      child: _buildMenuBar(context),
                    ),
                    Expanded(
                        child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        // controller.initPage.value = index;
                        // controller.update();
                      },
                      children: controller.pages,
                    ))
                  ],
                ),
          drawer: controller.isPhone
              ? SizedBox(
                  width: 200,
                  child: GFDrawer(
                    semanticLabel: 'Harvest',
                    elevation: 10,
                    color: Theme.of(context).colorScheme.surface,
                    child: _buildMenuBar(context),
                  ),
                )
              : null,
          drawerEdgeDragWidth: 100,
        ),
      );
    });
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
              selectedLabelTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              selectedIconTheme: Theme.of(context)
                  .iconTheme
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              unselectedLabelTextStyle:
                  TextStyle(color: Theme.of(context).colorScheme.secondary),
              unselectedIconTheme: Theme.of(context)
                  .iconTheme
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
              backgroundColor: Colors.transparent,
              onDestinationSelected: (index) => controller.changePage(index),
              labelType: NavigationRailLabelType.none,
              leading: GFDrawerHeader(
                centerAlign: true,
                closeButton: const SizedBox.shrink(),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${controller.userinfo?.isStaff == true ? '👑' : '🎩'}${controller.userinfo?.user.toString()}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          IconButton(
                            onPressed: () {
                              controller.logout();
                              controller.update();
                            },
                            icon: Icon(Icons.exit_to_app,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                      if (controller.authInfo != null)
                        Text(
                          'VIP：${controller.authInfo?.timeExpire.toString()}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      Tooltip(
                        message: '${SPUtil.getLocalStorage('server')}',
                        child: Text(
                          '${SPUtil.getLocalStorage('server')}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              destinations: controller.destinations,
            ),
          ),
        ),
      );
    });
  }

  Widget _actionButtonList(context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const LoggingView(),
          const SizedBox(width: 15),
          const WebSocketLoggingWidget(),
          const SizedBox(width: 15),
          if (controller.userinfo?.isStaff == true) ...[
            CustomUpgradeWidget(),
            SizedBox(width: 15),
            SiteMap(
              child: Icon(
                Icons.map,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 15),
          ],
          // const Wen(),

          DarkModeSwitch(
            borderColor: Theme.of(context).colorScheme.primary,
            height: 24,
            slideSize: 19,
            borderWidth: 2,
          ),

          const SizedBox(width: 15),
          const SizedBox(
            height: 24,
            width: 24,
            child: ThemeModal(
              itemSize: 32,
            ),
          ),
          if (controller.userinfo?.isStaff == true) ...[
            const SizedBox(width: 15),
            CustomPopup(
              showArrow: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              barrierColor: Colors.transparent,
              content: SizedBox(
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuItem<String>(
                      child: Text(
                        '全员签到',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () async {
                        await signAllSiteButton();
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(
                        '站点数据',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () async {
                        await getAllStatusButton();
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(
                        '批量操作',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () async {
                        const List<Tab> tabs = [
                          Tab(text: '批量修改'),
                          Tab(text: '清理数据'),
                        ];
                        TextEditingController keyController =
                            TextEditingController(text: '');
                        TextEditingController valueController =
                            TextEditingController(text: '');
                        Map<String, String> selectOptions = {
                          "站点UA": "user_agent",
                          "网络代理": "proxy"
                        };
                        Get.bottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 圆角半径
                          ),
                          SizedBox(
                            height: 240,
                            // width: 240,
                            child: DefaultTabController(
                              length: tabs.length,
                              child: Scaffold(
                                appBar: const TabBar(tabs: tabs),
                                body: TabBarView(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomPickerField(
                                          controller: keyController,
                                          labelText: '要替换的属性',
                                          data: const ["站点UA", "网络代理"],
                                          // onChanged: (p, position) {
                                          //   keyController.text = selectOptions[p]!;
                                          // },
                                        ),
                                        CustomTextField(
                                            controller: valueController,
                                            labelText: "替换为"),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // 圆角半径
                                                ),
                                              ),
                                              onPressed: () {
                                                Get.back(result: false);
                                              },
                                              child: const Text('取消'),
                                            ),
                                            ElevatedButton(
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // 圆角半径
                                                ),
                                              ),
                                              onPressed: () async {
                                                Get.back(result: true);
                                                await bulkUpgradeHandler({
                                                  "key": selectOptions[
                                                      keyController.text]!,
                                                  "value": StringUtils
                                                      .parseJsonOrReturnString(
                                                          valueController.text),
                                                });
                                              },
                                              child: const Text('确认'),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 28.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          CustomTextTag(
                                              labelText: "慎用，清理后数据无法恢复",
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error),
                                          FullWidthButton(
                                              text: "精简历史数据",
                                              onPressed: () async {
                                                Get.defaultDialog(
                                                  title: "确认吗？",
                                                  middleText:
                                                      "本操作会精简站点数据，只保留最近15天的历史数据，确认精简数据吗？",
                                                  actions: [
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Get.back(result: false);
                                                      },
                                                      child: const Text('取消'),
                                                    ),
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Get.back(result: true);
                                                        await bulkUpgradeHandler({
                                                          "key": "status_15",
                                                          "value": {},
                                                        });
                                                      },
                                                      child: const Text('确认'),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          FullWidthButton(
                                              text: "清除历史数据",
                                              onPressed: () async {
                                                Get.defaultDialog(
                                                  title: "确认吗？",
                                                  middleText: "确认清除站点历史数据吗？",
                                                  actions: [
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Get.back(result: false);
                                                      },
                                                      child: const Text('取消'),
                                                    ),
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Get.back(result: true);
                                                        await bulkUpgradeHandler({
                                                          "key": "status",
                                                          "value": {},
                                                        });
                                                      },
                                                      child: const Text('确认'),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          FullWidthButton(
                                              text: "清除签到数据",
                                              onPressed: () async {
                                                Get.defaultDialog(
                                                  title: "确认吗？",
                                                  middleText: "确认清除站点签到数据吗？",
                                                  actions: [
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Get.back(result: false);
                                                      },
                                                      child: const Text('取消'),
                                                    ),
                                                    ElevatedButton(
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0), // 圆角半径
                                                        ),
                                                      ),
                                                      onPressed: () async {
                                                        Get.back(result: true);
                                                        await bulkUpgradeHandler({
                                                          "key": "sign_info",
                                                          "value": {},
                                                        });
                                                      },
                                                      child: const Text('确认'),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: CustomUAWidget(
                        child: Text(
                          '自定义UA',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuItem<String>(
                      child: Text(
                        'PTPP',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () async {
                        await importFromPTPP();
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Text(
                        'CC 同步',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      onTap: () async {
                        await importFromCookieCloud();
                      },
                    ),
                  ],
                ),
              ),
              child: Icon(
                Icons.add_box_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
          const SizedBox(width: 20)
        ],
      );
    });
  }
}
