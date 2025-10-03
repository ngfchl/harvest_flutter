import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/web_socket_logging/view.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/mysite.dart';
import '../../api/option.dart';
import '../../common/custom_ua.dart';
import '../../common/custom_upgrade.dart';
import '../../common/invite_user.dart';
import '../../common/logging.dart';
import '../../common/site_map.dart';
import '../../common/video_player_page/video_page.dart';
import '../../models/common_response.dart';
import '../../theme/theme_view.dart';
import '../../utils/screenshot.dart';
import '../../utils/storage.dart';
import '../../utils/string_utils.dart';
import 'controller/common_api.dart';
import 'controller/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String cacheServer = 'https://images.weserv.nl/?url=';
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<HomeController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          Get.defaultDialog(
            title: "退出",
            content: const Text('确定要退出收割机吗？'),
            // onConfirm: () {
            //   exit(0);
            // },
            cancel: ShadButton.destructive(
                size: ShadButtonSize.sm,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text(
                  '取消',
                )),
            confirm: ShadButton(
                size: ShadButtonSize.sm,
                onPressed: () {
                  exit(0);
                },
                child: const Text(
                  '退出',
                )),
            textCancel: '取消',
            // textConfirm: '退出',
            // confirmTextColor: Colors.red,
            // buttonColor: Colors.red,
          );
        },
        child: RepaintBoundary(
          key: _captureKey,
          child: Stack(
            children: [
              GetBuilder<HomeController>(
                  id: 'home_view_background_image',
                  builder: (controller) {
                    // Logger.instance.d(
                    //     "useBackground: ${controller.useBackground} useLocalBackground: ${controller.useLocalBackground} backgroundImage: ${controller.backgroundImage}");
                    if (controller.useBackground) {
                      return Positioned.fill(
                        child: controller.useLocalBackground && !controller.backgroundImage.startsWith('http')
                            ? Image.file(
                                File(controller.backgroundImage.isNotEmpty
                                    ? controller.backgroundImage
                                    : 'assets/images/background.png'),
                                fit: BoxFit.cover,
                              )
                            : controller.useImageCache
                                ? CachedNetworkImage(
                                    imageUrl:
                                        '${controller.useImageProxy ? cacheServer : ''}${controller.backgroundImage}',
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/background.png',
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (context, url, error) => Image.asset(
                                      'assets/images/background.png',
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                    cacheKey: controller.backgroundImage,
                                  )
                                : Image.network(
                                    '${controller.useImageProxy ? cacheServer : ''}${controller.backgroundImage}',
                                    fit: BoxFit.cover,
                                  ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
              Scaffold(
                key: _globalKey,
                backgroundColor: controller.useBackground
                    ? Colors.transparent
                    : shadColorScheme.background.withOpacity(opacity * 1.2),
                extendBody: true,
                appBar: AppBar(
                  backgroundColor: shadColorScheme.background.withOpacity(opacity),
                  iconTheme: IconThemeData(color: shadColorScheme.foreground),
                  toolbarHeight: 40,
                  elevation: 0,
                  actions: <Widget>[
                    _actionButtonList(context),
                  ],
                ),
                body: GetBuilder<HomeController>(builder: (controller) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!controller.isPortrait)
                        controller.isSmallHorizontalScreen
                            ? SizedBox(
                                width: 120,
                                // height: double.infinity,
                                child: _buildMenuBar(context),
                              )
                            : CustomCard(
                                width: 200,
                                // height: double.infinity,
                                child: _buildMenuBar(context),
                              ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 3),
                        child: PageView(
                          controller: controller.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            // controller.initPage.value = index;
                            // controller.update();
                          },
                          children: controller.pages,
                        ),
                      ))
                    ],
                  );
                }),
                drawer: controller.isPortrait
                    ? SizedBox(
                        width: 200,
                        child: Drawer(
                          semanticLabel: 'Harvest',
                          elevation: 10,
                          backgroundColor: shadColorScheme.background,
                          child: _buildMenuBar(context),
                        ),
                      )
                    : null,
                drawerEdgeDragWidth: 100,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMenuBar(BuildContext context) {
    var colorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<HomeController>(builder: (controller) {
      return IntrinsicHeight(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height, // 确保宽度适配屏幕
          ),
          child: Column(
            children: [
              GetBuilder<HomeController>(builder: (controller) {
                if (!controller.isSmallHorizontalScreen) {
                  var baseUrl = SPUtil.getLocalStorage('server');

                  return DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const ShadAvatar(
                          'assets/images/avatar.png',
                          size: Size(50, 50),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${controller.userinfo?.isStaff == true ? '👑' : '🎩'}${controller.userinfo?.user.toString()}',
                              style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                            ),
                            InkWell(
                              onTap: () {
                                controller.logout();
                                controller.update();
                              },
                              child: Icon(Icons.exit_to_app, size: 16, color: colorScheme.foreground),
                            ),
                          ],
                        ),
                        if (controller.authInfo != null) ...[
                          Text(
                            'VIP: ${controller.authInfo?.username.toString()}',
                            style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                          ),
                          Text(
                            'Expire: ${controller.authInfo?.timeExpire.toString()}',
                            style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                          )
                        ],
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: baseUrl));
                          },
                          child: Text(
                            '$baseUrl',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: colorScheme.foreground),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }),
              Expanded(
                child: SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      useIndicator: true,
                      extended: !controller.isSmallHorizontalScreen,
                      selectedIndex: controller.initPage,
                      selectedLabelTextStyle: TextStyle(color: ShadTheme.of(context).colorScheme.foreground),
                      selectedIconTheme: Theme.of(context)
                          .iconTheme
                          .copyWith(color: ShadTheme.of(context).colorScheme.primaryForeground),
                      indicatorColor: ShadTheme.of(context).colorScheme.primary,
                      unselectedLabelTextStyle: TextStyle(color: colorScheme.foreground.withOpacity(0.7)),
                      unselectedIconTheme:
                          Theme.of(context).iconTheme.copyWith(color: colorScheme.foreground.withOpacity(0.7)),
                      backgroundColor: Colors.transparent,
                      onDestinationSelected: (index) => controller.changePage(index),
                      labelType: controller.isSmallHorizontalScreen
                          ? NavigationRailLabelType.selected
                          : NavigationRailLabelType.none,
                      destinations: controller.destinations,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _actionButtonList(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (kDebugMode) ...[
            const LoggingView(),
            const SizedBox(width: 15),
          ],
          const WebSocketLoggingWidget(),
          const SizedBox(width: 15),
          ThemeIconButton(
            icon: Icon(LucideIcons.palette, size: 20, color: shadColorScheme.foreground),
          ),
          const SizedBox(width: 15),
          if (controller.userinfo?.isStaff == true) ...[
            CustomUpgradeWidget(),
            const SizedBox(width: 15),
            SiteMap(
              icon: Icon(
                Icons.map,
                size: 20,
                color: shadColorScheme.foreground,
              ),
            ),
          ],
          if (controller.userinfo?.isStaff == true) ...[
            const SizedBox(width: 15),
            CustomPopup(
              showArrow: false,
              backgroundColor: shadColorScheme.background,
              barrierColor: Colors.transparent,
              content: SizedBox(
                width: 150,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuItem<String>(
                        child: Text(
                          '播放视频',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          final urlController = TextEditingController();
                          showShadDialog(
                            context: context,
                            builder: (context) => ShadDialog(
                              title: const Text('播放网络视频'),
                              // description: const Text("测试链接"),
                              actions: [
                                ShadButton(
                                  child: Text('播放'),
                                  onPressed: () {
                                    if (urlController.text.isEmpty == true || !urlController.text.startsWith("http")) {
                                      return;
                                    } else {
                                      Get.back();
                                      Get.dialog(CustomCard(
                                          child: VideoPlayerPage(
                                        initialUrl: urlController.text,
                                      )));
                                    }
                                  },
                                )
                              ],
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 320),
                                child: ShadInput(
                                  controller: urlController,
                                  placeholder: Text('输入视频URL',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: shadColorScheme.foreground,
                                      )),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          '全员签到',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
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
                            color: shadColorScheme.foreground,
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
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          const List<Tab> tabs = [
                            Tab(text: '批量修改'),
                            Tab(text: '清理数据'),
                          ];
                          TextEditingController keyController = TextEditingController(text: '');
                          TextEditingController valueController = TextEditingController(text: '');
                          Map<String, String> selectOptions = {"站点UA": "user_agent", "网络代理": "proxy"};
                          const operateList = ["站点UA", "网络代理"];
                          Get.bottomSheet(
                            backgroundColor: shadColorScheme.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0), // 圆角半径
                            ),
                            SizedBox(
                              height: 240,
                              // width: 240,
                              child: DefaultTabController(
                                length: tabs.length,
                                child: Scaffold(
                                  backgroundColor: Colors.transparent,
                                  resizeToAvoidBottomInset: false,
                                  appBar: const TabBar(tabs: tabs),
                                  body: TabBarView(
                                    children: [
                                      SingleChildScrollView(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          spacing: 10,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ConstrainedBox(
                                                constraints: const BoxConstraints(minWidth: double.infinity),
                                                child: ShadSelect<String>(
                                                    placeholder: const Text('选择操作'),
                                                    decoration: ShadDecoration(border: ShadBorder.none),
                                                    trailing: const Text('选择操作'),
                                                    initialValue: operateList.first,
                                                    options: operateList
                                                        .map((key) => ShadOption(value: key, child: Text(key)))
                                                        .toList(),
                                                    selectedOptionBuilder: (context, value) {
                                                      return Text(value);
                                                    },
                                                    onChanged: (String? value) {
                                                      keyController.text = value!;
                                                    }),
                                              ),
                                            ),
                                            CustomTextField(controller: valueController, labelText: "替换为"),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                ShadButton.destructive(
                                                  size: ShadButtonSize.sm,
                                                  onPressed: () {
                                                    Get.back(result: false);
                                                  },
                                                  child: const Text('取消'),
                                                ),
                                                ShadButton(
                                                  size: ShadButtonSize.sm,
                                                  onPressed: () async {
                                                    Get.back(result: true);
                                                    await bulkUpgradeHandler({
                                                      "key": selectOptions[keyController.text]!,
                                                      "value":
                                                          StringUtils.parseJsonOrReturnString(valueController.text),
                                                    });
                                                  },
                                                  child: const Text('确认'),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            CustomTextTag(
                                                labelText: "慎用，清理后数据无法恢复",
                                                backgroundColor: shadColorScheme.destructive),
                                            ShadButton.destructive(
                                                size: ShadButtonSize.sm,
                                                child: Text("精简历史数据"),
                                                onPressed: () async {
                                                  Get.defaultDialog(
                                                    title: "确认吗？",
                                                    middleText: "本操作会精简站点数据，只保留最近15天的历史数据，确认精简数据吗？",
                                                    actions: [
                                                      ShadButton.destructive(
                                                        size: ShadButtonSize.sm,
                                                        onPressed: () async {
                                                          Get.back(result: false);
                                                        },
                                                        child: const Text('取消'),
                                                      ),
                                                      ShadButton(
                                                        size: ShadButtonSize.sm,
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
                                            ShadButton.destructive(
                                                size: ShadButtonSize.sm,
                                                child: Text("清除历史数据"),
                                                onPressed: () async {
                                                  Get.defaultDialog(
                                                    title: "确认吗？",
                                                    middleText: "确认清除站点历史数据吗？",
                                                    actions: [
                                                      ShadButton.destructive(
                                                        size: ShadButtonSize.sm,
                                                        onPressed: () async {
                                                          Get.back(result: false);
                                                        },
                                                        child: const Text('取消'),
                                                      ),
                                                      ShadButton(
                                                        size: ShadButtonSize.sm,
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
                                            ShadButton.destructive(
                                                size: ShadButtonSize.sm,
                                                child: Text("清除签到数据"),
                                                onPressed: () async {
                                                  Get.defaultDialog(
                                                    title: "确认吗？",
                                                    middleText: "确认清除站点签到数据吗？",
                                                    actions: [
                                                      ShadButton.destructive(
                                                        size: ShadButtonSize.sm,
                                                        onPressed: () {
                                                          Get.back(result: false);
                                                        },
                                                        child: const Text('取消'),
                                                      ),
                                                      ShadButton(
                                                        size: ShadButtonSize.sm,
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
                              color: shadColorScheme.foreground,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        child: InviteUser(
                          child: Text(
                            '试用邀请',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          'PTPP',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async => pickAndUpload(),
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          'CC 同步',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          await importFromCookieCloud();
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          'CF 测速',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          CommonResponse res = await speedTestApi();
                          if (res.code == 0) {
                            Get.back();
                            Get.snackbar('测速任务发送成功', res.msg, colorText: shadColorScheme.foreground);
                          } else {
                            Get.snackbar('测速任务发送失败', '测速任务执行出错啦：${res.msg}', colorText: shadColorScheme.destructive);
                          }
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          '截图分享',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          await ScreenshotSaver.captureAndSave(_captureKey);
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          '退出登录',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onTap: () async {
                          controller.logout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              child: Icon(
                Icons.add_box_outlined,
                size: 24,
                color: shadColorScheme.foreground,
              ),
            )
          ],
          const SizedBox(width: 15)
        ],
      );
    });
  }

  void pickAndUpload() async {
    Get.defaultDialog(
      title: "选择 PTPP 备份文件",
      content: Center(
        child: ShadButton.link(
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
            if (result != null) {
              PlatformFile file = result.files.single;
              Logger.instance.d(result.files.single.path!);
              Logger.instance.d(file);
              Logger.instance.d(file.path);
              if (!kIsWeb && file.path?.contains('PT-Plugin-Plus-Backup') != true) {
                Get.snackbar(
                  '错误',
                  '请选择正确的PTPP备份文件【“PT-Plugin-Plus-Backup”开头的 ZIP 文件】！',
                  colorText: Colors.deepOrange,
                  duration: const Duration(seconds: 3),
                );
                return;
              }
              // return;
              CommonResponse res = await importFromPTPPApi(file);
              Get.back();
              if (res.succeed) {
                Get.snackbar(
                  'PTPP导入任务',
                  'PTPP导入任务信息：${res.msg}',
                );
              } else {
                Get.snackbar(
                  'PTPP导入任务失败',
                  'PTPP导入任务执行出错啦：${res.msg}',
                );
              }
            } else {
              Get.snackbar(
                'PTPP导入任务失败',
                'PTPP导入任务执行出错啦：未发现你所选择的文件！',
              );
            }
          },
          child: const Text("选择文件"),
        ),
      ),
    );
    return;
  }
}
