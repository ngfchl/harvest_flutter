import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/dash_board/controller.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/date_time_utils.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api/mysite.dart';
import '../../../../common/card_view.dart';
import '../../../../common/corner_badge.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/utils.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/format_number.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/screenshot.dart';
import '../../../../utils/storage.dart';
import '../../../../utils/string_utils.dart';
import '../../../routes/app_pages.dart';
import '../models/color_storage.dart';
import '../models/my_site.dart';
import '../models/website.dart';
import 'controller.dart';

class MySitePage extends StatefulWidget {
  const MySitePage({super.key});

  @override
  State<MySitePage> createState() => _MySitePagePageState();
}

class _MySitePagePageState extends State<MySitePage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final controller = Get.put(MySiteController());
  FocusNode blankNode = FocusNode();
  Map<String, Color> mySiteLevelColorMap = const {
    'StaffLeader': Color(0xFF8B0000),
    'SysOp': Color(0xFFA0522D),
    'Administrator': Color(0xFF4B0082),
    'Moderator': Color(0xFF6495ED),
    'Assistant': Color(0xFF806DEC),
    'Editor': Color(0xFF9ACD32),
    'Honor': Color(0xFFE03C8A),
    'ForumModerator': Color(0xFF1CC6D5),
    'Retiree': Color(0xFF1CC6D5),
    'Uploader': Color(0xFFDC143C),
    'VIP': Color(0xFF009F00),
    'SVIP': Color(0xFF009F00),
    'NexusGod': Color(0xFF9C4F96),
    'God': Color(0xFF9C4F96),
    'Master': Color(0xFF003366),
    'NexusMaster': Color(0xFF38ACEC),
    'UltimateUser': Color(0xFF006400),
    'ExtremeUser': Color(0xFFFF8C00),
    'VeteranUser': Color(0xFF483D8B),
    'InsaneUser': Color(0xFF8B008B),
    'CrazyUser': Color(0xFF00BFFF),
    'EliteUser': Color(0xFF008B8B),
    'PowerUser': Color(0xFFDAA520),
    // 'User': Color(0xFF000000),
    'Peasant': Color(0xFF708090),
  };

  @override
  bool get wantKeepAlive => true;

  double get opacity => SPUtil.getDouble("cardOpacity", defaultValue: 0.7);
  final GlobalKey captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<MySiteController>(builder: (controller) {
      return SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                child: Column(
                  children: [
                    if (controller.loadingFromServer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 10,
                              height: 10,
                              child: Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: shadColorScheme.foreground,
                              ))),
                          const SizedBox(width: 5),
                          Text(
                            '当前为缓存数据，正在从服务器加载',
                            style: TextStyle(
                              fontSize: 10,
                              color: shadColorScheme.foreground,
                            ),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        GetBuilder<MySiteController>(
                            id: Key('showSearchBar'),
                            builder: (controller) {
                              return Expanded(
                                child: InkWell(
                                  onTap: () {
                                    FocusScope.of(context).requestFocus(blankNode);
                                  },
                                  child: TextField(
                                    focusNode: blankNode,
                                    scrollPhysics: const NeverScrollableScrollPhysics(),
                                    // 禁止滚动
                                    maxLines: 1,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(20),
                                    ],
                                    controller: controller.searchController,
                                    style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      // labelText: '搜索',
                                      isDense: true,
                                      fillColor: Colors.transparent,
                                      constraints: BoxConstraints(maxHeight: 32),
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hintText: '输入关键词...',
                                      labelStyle: const TextStyle(fontSize: 12),
                                      hintStyle: const TextStyle(fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                                      prefixIcon: Icon(
                                        Icons.search,
                                        size: 14,
                                        color: shadColorScheme.foreground,
                                      ),
                                      // suffix: ,
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('计数：${controller.showStatusList.length}',
                                                style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                          ],
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // 不绘制边框
                                        borderRadius: BorderRadius.circular(5.0),
                                        // 确保角落没有圆角
                                        gapPadding: 0.0, // 移除边框与hintText之间的间距
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(width: 1.0, color: shadColorScheme.foreground),
                                        // 仅在聚焦时绘制底部边框
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                    ),
                                    onChanged: (value) async {
                                      controller.searching = true;
                                      controller.update();
                                      Logger.instance.d('搜索框内容变化：$value');
                                      controller.searchKey = value;
                                      await Future.delayed(Duration(milliseconds: 300));
                                      controller.filterByKey();
                                      controller.searching = false;
                                      controller.update();
                                    },
                                  ),
                                ),
                              );
                            }),
                        if (controller.searchKey.isNotEmpty)
                          ShadIconButton.ghost(
                              onPressed: () {
                                controller.searchController.text = controller.searchController.text
                                    .substring(0, controller.searchController.text.length - 1);
                                controller.searchKey = controller.searchController.text;
                                controller.filterByKey();
                                controller.update();
                              },
                              icon: controller.searching
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        color: shadColorScheme.foreground,
                                      )),
                                    )
                                  : Icon(Icons.backspace_outlined, size: 18, color: shadColorScheme.foreground))
                      ],
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          // mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          direction: Axis.horizontal,
                          spacing: 10,
                          children: [
                            CustomPopup(
                              showArrow: false,
                              backgroundColor: shadColorScheme.background,
                              barrierColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                              content: SizedBox(
                                width: 120,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...controller.filterOptions.map(
                                        (item) => PopupMenuItem(
                                          height: 40,
                                          onTap: () {
                                            controller.filterKey = item.value!;
                                            controller.filterByKey();
                                          },
                                          child: Text(item.name,
                                              style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_tilt_shift,
                                      size: 13,
                                      color: shadColorScheme.foreground,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      controller.filterOptions
                                          .firstWhere((item) => item.value == controller.filterKey)
                                          .name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: shadColorScheme.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            CustomPopup(
                              showArrow: false,
                              backgroundColor: shadColorScheme.background,
                              barrierColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                              content: SizedBox(
                                width: 100,
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ...controller.siteSortOptions.map(
                                        (item) => PopupMenuItem(
                                          height: 40,
                                          onTap: () {
                                            controller.sortKey = item.value!;
                                            controller.filterByKey();
                                          },
                                          child: Text(item.name,
                                              style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sort_by_alpha_outlined,
                                      size: 13,
                                      color: shadColorScheme.foreground,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      controller.siteSortOptions
                                          .firstWhere((item) => item.value == controller.sortKey)
                                          .name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: shadColorScheme.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                controller.sortReversed = !controller.sortReversed;
                                controller.sortStatusList();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    controller.sortReversed
                                        ? Icon(
                                            Icons.sim_card_download_sharp,
                                            size: 13,
                                            color: shadColorScheme.foreground,
                                          )
                                        : Icon(
                                            Icons.upload_file_sharp,
                                            size: 13,
                                            color: shadColorScheme.foreground,
                                          ),
                                    SizedBox(width: 3),
                                    controller.sortReversed
                                        ? Text(
                                            '正序',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: shadColorScheme.foreground,
                                            ),
                                          )
                                        : Text(
                                            '倒序',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: shadColorScheme.foreground,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            CustomPopup(
                              showArrow: false,
                              backgroundColor: shadColorScheme.background,
                              content: SizedBox(
                                width: 120,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PopupMenuItem<String>(
                                        height: 32,
                                        child: Text(
                                          '全部',
                                          style: TextStyle(
                                            color: shadColorScheme.foreground,
                                          ),
                                        ),
                                        onTap: () async {
                                          Get.back();
                                          controller.selectTag = '全部';
                                          controller.filterByKey();
                                          // await controller.mySiteController.initData();
                                        },
                                      ),
                                      ...controller.tagList.map((item) => PopupMenuItem<String>(
                                            height: 32,
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                color: shadColorScheme.foreground,
                                              ),
                                            ),
                                            onTap: () async {
                                              Get.back();
                                              controller.selectTag = item;
                                              controller.filterByKey();
                                              // await controller.mySiteController.initData();
                                            },
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tag,
                                      size: 13,
                                      color: shadColorScheme.foreground,
                                    ),
                                    Text(
                                      '【${controller.selectTag}】',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: shadColorScheme.foreground,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              ),

              Expanded(
                child: EasyRefresh(
                  header: ClassicHeader(
                    dragText: '下拉刷新...',
                    readyText: '松开刷新',
                    processingText: '正在刷新...',
                    processedText: '刷新完成',
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: shadColorScheme.foreground,
                      fontWeight: FontWeight.bold,
                    ),
                    messageStyle: TextStyle(
                      fontSize: 12,
                      color: shadColorScheme.foreground,
                    ),
                  ),
                  onRefresh: () async {
                    controller.initFlag = false;
                    controller.getSiteStatusFromServer();
                  },
                  child: controller.loading
                      ? Center(
                          child: CircularProgressIndicator(
                          color: shadColorScheme.primary,
                        ))
                      : controller.showStatusList.isEmpty
                          ? LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints) {
                                double height = constraints.maxHeight;
                                return ListView(
                                  physics: const AlwaysScrollableScrollPhysics(), // 或根据需求保留默认
                                  children: [
                                    SizedBox(
                                      height: height,
                                      child: Center(
                                        child: Text(
                                          '没有符合条件的数据！',
                                          style: TextStyle(color: shadColorScheme.foreground),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            )
                          : GetBuilder<MySiteController>(
                              builder: (controller) {
                                return ReorderableListView.builder(
                                  onReorder: (int oldIndex, int newIndex) async {
                                    final item = controller.showStatusList.removeAt(oldIndex);
                                    Logger.instance.d('本站排序 ID：${item.sortId}');
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1; // 移动时修正索引，因为item已被移除
                                    }

                                    final nextItem = controller.showStatusList[newIndex];
                                    MySite newItem;
                                    if (controller.sortReversed) {
                                      newItem =
                                          item.copyWith(sortId: nextItem.sortId - 1 > 0 ? nextItem.sortId - 1 : 0);
                                    } else {
                                      newItem = item.copyWith(sortId: nextItem.sortId + 1);
                                    }
                                    controller.showStatusList.insert(newIndex, item);
                                    controller.update();
                                    CommonResponse response = await controller.saveMySiteToServer(newItem);
                                    if (response.succeed) {
                                      await controller.getSiteStatusFromServer();
                                    }
                                  },
                                  itemCount: controller.showStatusList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    MySite mySite = controller.showStatusList[index];
                                    return GetBuilder<MySiteController>(
                                      id: "SingleSite-${mySite.id}",
                                      key: ValueKey("SingleSite-${mySite.id}"),
                                      builder: (controller) {
                                        return RepaintBoundary(child: showSiteDataInfo(mySite));
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ),

              // if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
              // const SizedBox(height: 50),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _buildBottomButtonBarFloat(),
        ),
      );
    });
  }

  Widget _buildBottomButtonBarFloat() {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShadIconButton.ghost(
          height: 40,
          onPressed: () async {
            List<MySite> canInviteSiteList = controller.mySiteList
                .where((item) => item.available && (item.latestStatusInfo?.invitation ?? 0) > 0)
                .sorted((a, b) => b.latestStatusInfo!.invitation.compareTo(a.latestStatusInfo!.invitation))
                .toList();
            Logger.instance.d('canInviteSiteList: ${canInviteSiteList.length}');
            if (canInviteSiteList.isEmpty) {
            } else {
              Get.bottomSheet(
                backgroundColor: shadColorScheme.background,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                RepaintBoundary(
                  key: captureKey,
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text('可邀请站点[${canInviteSiteList.length}]',
                          style:
                              TextStyle(fontSize: 16, color: shadColorScheme.foreground, fontWeight: FontWeight.bold)),
                      toolbarHeight: 40,
                      actions: [
                        ShadIconButton.ghost(
                          icon: Icon(Icons.camera_alt_outlined, size: 24, color: shadColorScheme.foreground),
                          onPressed: () => ScreenshotSaver.captureAndSave(captureKey),
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      child: Column(children: [
                        ...canInviteSiteList.map((item) {
                          var webSite = controller.webSiteList[item.site];
                          return ListTile(
                            dense: true,
                            leading: siteLogo('${controller.baseUrl}local/icons/${webSite?.name}.png', webSite!, item),
                            title: Text(item.nickname),
                            trailing: Text(item.latestStatusInfo?.invitation.toString() ?? ''),
                          );
                        }),
                      ]),
                    ),
                  ),
                ),
              );
            }
          },
          icon: Icon(
            Icons.man_2_outlined,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
        ShadIconButton.ghost(
          height: 40,
          onPressed: () async {
            Get.back();
            Future.microtask(() async {
              Logger.instance.i('开始从数据库加载数据...');
              controller.loadingFromServer = true;
              controller.update(); // UI 更新
              // 模拟后台获取数据
              await controller.getWebSiteListFromServer();
              await controller.getSiteStatusFromServer();
              controller.loadingFromServer = false;
              Logger.instance.i('从数据库加载数据完成！');
              controller.update(); // UI 更新
            });
          },
          icon: Icon(
            Icons.refresh_outlined,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
        ShadIconButton.ghost(
          onPressed: () async {
            Get.back();
            await _showEditBottomSheet();
          },
          icon: Icon(
            Icons.add_outlined,
            size: 24,
            color: shadColorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    Get.delete<MySiteController>();
    super.dispose();
  }

  Future<void> _openSitePage(MySite mySite, WebSite website, bool openByInnerExplorer) async {
    String path;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (mySite.mail! > 0 && !website.pageMessage.contains('api')) {
      path = website.pageMessage.replaceFirst("{}", mySite.userId.toString());
    } else {
      path = website.pageIndex;
    }
    String url = '${mySite.mirror!.endsWith('/') ? mySite.mirror : '${mySite.mirror}/'}$path';
    if (mySite.mirror!.contains('m-team')) {
      url = url.replaceFirst("api", "next");
    }
    if (kIsWeb || !openByInnerExplorer) {
      Logger.instance.d('使用外部浏览器打开');
      Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？', colorText: shadColorScheme.foreground);
      }
    } else {
      Logger.instance.d('使用内置浏览器打开');
      Get.toNamed(Routes.WEBVIEW, arguments: {'url': url, 'info': null, 'mySite': mySite, 'website': website});
    }
  }

  Widget showSiteDataInfo(MySite mySite) {
    StatusInfo? status;
    WebSite? website = controller.webSiteList[mySite.site];
    RxBool showLoading = false.obs;
    // Logger.instance.d('${mySite.nickname} - ${website?.name}');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    if (website == null) {
      return Obx(() {
        return CustomCard(
          key: Key("${mySite.id}-${mySite.site}"),
          color: siteColorConfig.siteCardColor.value.withOpacity(opacity),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            leading: const Image(
              image: AssetImage('assets/images/avatar.png'),
              width: 32,
              height: 32,
            ),
            title: Text(
              mySite.nickname,
              style: TextStyle(
                fontSize: 13,
                color: shadColorScheme.foreground,
              ),
            ),
            subtitle: Text(
              '没有找到这个站点的配置文件，请清理站点配置缓存后重新加载数据！',
              style: TextStyle(
                color: shadColorScheme.destructive,
                fontSize: 10,
              ),
            ),
            trailing: ShadIconButton.ghost(
                onPressed: () async {
                  await _showEditBottomSheet(mySite: mySite);
                },
                icon: Icon(
                  Icons.edit,
                  color: shadColorScheme.destructive,
                )),
          ),
        );
      });
    }
    if (mySite.statusInfo.isNotEmpty) {
      status = mySite.latestStatusInfo;
    }
    if (status == null) {
      Logger.instance.d('${mySite.nickname} - ${mySite.statusInfo}');
    }
    LevelInfo? level = website.level?[status?.myLevel];
    List<LevelInfo> rights = [];
    LevelInfo? nextLevel;
    if (level?.levelId == 0) {
      rights = [...?website.level?.values];
    } else if (level == null) {
    } else {
      rights = [...?website.level?.values.where((item) => item.levelId > 0 && item.levelId <= level.levelId)];
      rights.sort((a, b) => b.levelId.compareTo(a.levelId));
      nextLevel = website.level?.values.firstWhereOrNull((item) => item.levelId == level.levelId + 1);
    }

    int nextLevelToDownloadedByte = FileSizeConvert.parseToByte(nextLevel?.downloaded ?? "0");
    int nextLevelToUploadedByte = FileSizeConvert.parseToByte(nextLevel?.uploaded ?? "0");
    int calcToUploaded = (max(nextLevelToDownloadedByte, status?.downloaded ?? 0) * (nextLevel?.ratio ?? 0)).toInt();
    nextLevelToUploadedByte = max(nextLevelToUploadedByte, calcToUploaded);
    // Logger.instance.d(
    //     '${FileSizeConvert.parseToFileSize(status?.uploaded)}(${status?.uploaded})/${FileSizeConvert.parseToFileSize(nextLevelToUploadedByte)}($nextLevelToUploadedByte)');
    String iconUrl = '${controller.baseUrl}/local/icons/${website.name}.png';
    // Logger.instance.d('${website.name} - $iconUrl');
    var toUpgradeTime = DateTime.parse(mySite.timeJoin).add(Duration(days: (nextLevel?.days ?? 0) * 7));
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    bool signed = mySite.getSignMaxKey() == today || mySite.signIn == false;
    RxBool siteRefreshing = false.obs;
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          return CustomCard(
            key: Key("${mySite.id}-${mySite.site}"),
            color: siteColorConfig.siteCardColor.value.withOpacity(opacity),
            child: Slidable(
              key: ValueKey('${mySite.id}_${mySite.nickname}'),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: GetPlatform.isMobile ? 1 : 0.4,
                children: [
                  SlidableAction(
                    icon: Icons.refresh_outlined,
                    label: '更新',
                    backgroundColor: Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    borderRadius: !mySite.repeatTorrents && !mySite.signIn
                        ? const BorderRadius.all(Radius.circular(8))
                        : const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    onPressed: (context) async {
                      showLoading.value = true;
                      await refreshSiteData(siteRefreshing, mySite, shadColorScheme);
                      showLoading.value = false;
                    },
                  ),
                  if (website.signIn == true && mySite.signIn && !signed)
                    SlidableAction(
                      icon: Icons.edit_calendar_outlined,
                      label: '签到',
                      backgroundColor: Color(0xFF1565C0),
                      borderRadius: mySite.repeatTorrents
                          ? BorderRadius.zero
                          : BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      foregroundColor: Colors.white,
                      onPressed: (context) async {
                        showLoading.value = true;
                        await signSite(siteRefreshing, mySite, shadColorScheme);
                        showLoading.value = false;
                      },
                    ),
                  if (website.repeatTorrents == true && mySite.repeatTorrents)
                    SlidableAction(
                      flex: 1,
                      backgroundColor: Color(0xFF00838F),
                      foregroundColor: Colors.white,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      onPressed: (context) async {
                        showLoading.value = true;
                        await repeatSite(mySite, shadColorScheme);
                        showLoading.value = false;
                      },
                      icon: Icons.copy_outlined,
                      label: '辅种',
                    ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: GetPlatform.isMobile ? 1 : 0.4,
                children: [
                  if (website.signIn == true && mySite.signIn)
                    SlidableAction(
                      flex: 1,
                      borderRadius:
                          const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                      onPressed: (context) async {
                        showLoading.value = true;
                        _showSignHistory(mySite);
                        showLoading.value = false;
                      },
                      backgroundColor: Color(0xFF5D4037),
                      foregroundColor: Colors.white,
                      icon: Icons.manage_history_outlined,
                      label: '签到历史',
                    ),
                  SlidableAction(
                    flex: 1,
                    borderRadius: mySite.signIn
                        ? BorderRadius.zero
                        : const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                    onPressed: (context) async {
                      showLoading.value = true;
                      _showStatusHistory(mySite);
                      showLoading.value = false;
                    },
                    backgroundColor: Color(0xFFF57C00),
                    foregroundColor: Colors.white,
                    icon: Icons.history_outlined,
                    label: '历史数据',
                  ),
                  SlidableAction(
                    flex: 1,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                    onPressed: (context) async {
                      showLoading.value = true;
                      await _showEditBottomSheet(mySite: mySite);
                    },
                    backgroundColor: Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: '编辑',
                  ),
                ],
              ),
              child: Column(children: [
                CornerBadge(
                  color: signed == true ? Color(0xFF388E3C) : Color(0xFFF44336),
                  label: mySite.signIn == false
                      ? '无签到'
                      : mySite.getSignMaxKey() == today
                          ? '已签到'
                          : '未签到',
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    leading: InkWell(
                      onTap: () => _openSitePage(mySite, website, true),
                      onLongPress: () => _openSitePage(mySite, website, false),
                      child: siteLogo(iconUrl, website, mySite),
                    ),
                    onTap: () {
                      Get.defaultDialog(
                        title: '站点信息 - ${mySite.nickname}',
                        radius: 8,
                        titleStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                        backgroundColor: shadColorScheme.background,
                        content: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '站点地址：',
                              style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
                            ),
                            ...website.url.map((item) => ShadButton.link(
                                  size: ShadButtonSize.sm,
                                  onPressed: () => launchUrl(Uri.parse(item), mode: LaunchMode.externalApplication),
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 13, color: shadColorScheme.primary),
                                  ),
                                )),
                            Text(
                              '搜索地址：',
                              style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
                            ),
                            ...website.pageSearch.map((item) => ShadButton.link(
                                  size: ShadButtonSize.sm,
                                  child: Text(
                                    item,
                                    style: TextStyle(fontSize: 13, color: shadColorScheme.primary),
                                  ),
                                )),
                            Text(
                              '上传限速：${website.limitSpeed}MB/s',
                              style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
                            ),
                            Text(
                              '最后访问时间：${calculateTimeElapsed(mySite.latestActive.toString())}',
                              style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
                            ),
                          ],
                        ),
                        actions: [
                          ShadButton.ghost(
                            size: ShadButtonSize.sm,
                            child: Text('关闭'),
                            onPressed: () => Get.back(),
                          ),
                          ShadButton.secondary(
                            size: ShadButtonSize.sm,
                            child: Text(
                              '打开',
                              style: TextStyle(color: shadColorScheme.primary),
                            ),
                            onPressed: () {
                              Get.back();
                              _openSitePage(mySite, website, true);
                            },
                          ),
                          ShadButton.outline(
                            size: ShadButtonSize.sm,
                            child: Text('浏览器'),
                            onPressed: () => _openSitePage(mySite, website, false),
                          ),
                        ],
                      );
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        mySite.latestActive != null
                            ? Tooltip(
                                message:
                                    '最后访问时间：${calculateTimeElapsed(mySite.latestActive.toString())}  上传限速：${website.limitSpeed}MB/s \n 搜索地址：${website.pageSearch}',
                                child: Text(
                                  mySite.nickname,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: siteColorConfig.siteNameColor.value,
                                  ),
                                ),
                              )
                            : Text(
                                mySite.nickname,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: siteColorConfig.siteNameColor.value,
                                ),
                              ),
                        if (mySite.mail! > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.mail,
                                size: 12,
                                color: siteColorConfig.mailColor.value,
                              ),
                              Text(
                                '${mySite.mail}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.mailColor.value,
                                ),
                              ),
                            ],
                          ),
                        if (mySite.notice! > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.notifications,
                                size: 12,
                                color: siteColorConfig.noticeColor.value,
                              ),
                              Text(
                                '${mySite.notice}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: siteColorConfig.noticeColor.value,
                                ),
                              ),
                            ],
                          ),
                        if (status != null && level == null)
                          Text(
                            website.level?[status.myLevel]?.level ?? status.myLevel,
                            style: TextStyle(
                              fontSize: 10,
                              color: mySiteLevelColorMap[status.myLevel] ?? shadColorScheme.foreground,
                            ),
                          ),
                        if (status != null && level != null)
                          CustomPopup(
                            showArrow: false,
                            barrierColor: Colors.transparent,
                            backgroundColor: shadColorScheme.background,
                            content: SingleChildScrollView(
                              child: SizedBox(
                                  width: 200,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (nextLevel != null) ...[
                                        PopupMenuItem<String>(
                                          height: 13,
                                          child: Text("下一等级：${nextLevel.level}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    mySiteLevelColorMap[nextLevel.level] ?? shadColorScheme.foreground,
                                              )),
                                        ),
                                        // if (status.uploaded < nextLevelToUploadedByte)
                                        PopupMenuItem<String>(
                                          height: 13,
                                          child: Text(
                                              '上传量：${FileSizeConvert.parseToFileSize(status.uploaded)}/${FileSizeConvert.parseToFileSize(nextLevelToUploadedByte)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: status.uploaded < max(nextLevelToUploadedByte, calcToUploaded)
                                                    ? shadColorScheme.destructive
                                                    : shadColorScheme.foreground,
                                              )),
                                        ),
                                        // if (status.downloaded < nextLevelToDownloadedByte)
                                        PopupMenuItem<String>(
                                          height: 13,
                                          child: Text(
                                              '下载量：${FileSizeConvert.parseToFileSize(status.downloaded)}/${FileSizeConvert.parseToFileSize(nextLevelToDownloadedByte)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: status.downloaded < nextLevelToDownloadedByte
                                                    ? shadColorScheme.destructive
                                                    : shadColorScheme.foreground,
                                              )),
                                        ),
                                        // if (status.uploaded / status.downloaded <
                                        //     nextLevel.ratio)
                                        //   PopupMenuItem<String>(
                                        //     height: 13,
                                        //     child: Text(
                                        //         '分享率：${(status.uploaded / status.downloaded).toStringAsFixed(2)}/${nextLevel.ratio}',
                                        //         style: TextStyle(
                                        //           fontSize: 10,
                                        //           color:
                                        //               ShadTheme.of(context).colorScheme.destructive,
                                        //         )),
                                        //   ),
                                        if (nextLevel.torrents > 0)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text('需发种数量：${status.published}/${nextLevel.torrents}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: status.published < nextLevel.torrents
                                                      ? shadColorScheme.destructive
                                                      : shadColorScheme.foreground,
                                                )),
                                          ),
                                        if (nextLevel.score > 0)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text(
                                                '做种积分：${formatNumber(status.myScore)}/${formatNumber(nextLevel.score)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: status.myScore < nextLevel.score
                                                      ? shadColorScheme.destructive
                                                      : shadColorScheme.foreground,
                                                )),
                                          ),
                                        if (nextLevel.bonus > 0)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text(
                                                '魔力值：${formatNumber(status.myBonus)}/${formatNumber(nextLevel.bonus)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: status.myBonus < nextLevel.bonus
                                                      ? shadColorScheme.destructive
                                                      : shadColorScheme.foreground,
                                                )),
                                          ),
                                        if (nextLevel.days > 0)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text(
                                                '升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/${DateFormat('yyyy-MM-dd').format(toUpgradeTime)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: DateTime.now().isBefore(toUpgradeTime)
                                                      ? shadColorScheme.destructive
                                                      : shadColorScheme.foreground,
                                                )),
                                          ),
                                        if (level.keepAccount != true && nextLevel.keepAccount)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text('保留账号：${nextLevel.keepAccount}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: shadColorScheme.destructive,
                                                )),
                                          ),
                                        if (level.graduation != true && nextLevel.graduation)
                                          PopupMenuItem<String>(
                                            height: 13,
                                            child: Text('毕业：${nextLevel.graduation}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: shadColorScheme.destructive,
                                                )),
                                          ),
                                        PopupMenuItem<String>(
                                          height: 13,
                                          child: Text('即将获得：${nextLevel.rights}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: shadColorScheme.destructive,
                                              )),
                                        ),
                                      ],
                                      ...rights
                                          .where((el) =>
                                              el.rights.trim() != '无' &&
                                              !el.rights.trim().startsWith('同') &&
                                              !el.rights.trim().contains('同上'))
                                          .map((LevelInfo item) => PopupMenuItem<String>(
                                                height: 13,
                                                child: Text(item.rights,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          item.graduation ? Colors.orange : shadColorScheme.foreground,
                                                    )),
                                              ))
                                    ],
                                  )),
                            ),
                            child: Text(
                              website.level?[status.myLevel]?.level ?? status.myLevel,
                              style: TextStyle(
                                fontSize: 11,
                                color: mySiteLevelColorMap[status.myLevel] ?? shadColorScheme.foreground,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: status == null
                        ? Text(
                            '新站点，还没有数据哦',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                              fontSize: 10,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DateTime.parse(mySite.timeJoin) != DateTime(2024, 2, 1)
                                  ? Text(
                                      '⌚️${calcWeeksDays(mySite.timeJoin)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: siteColorConfig.regTimeColor.value,
                                      ),
                                    )
                                  : Text(
                                      '⌚️获取失败！',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: siteColorConfig.regTimeColor.value,
                                      ),
                                    ),
                              if (level?.keepAccount == true)
                                Text(
                                  '🔥保号',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: siteColorConfig.keepAccountColor.value,
                                  ),
                                ),
                              if (level?.graduation == true)
                                Text(
                                  '🎓毕业',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: siteColorConfig.graduationColor.value,
                                  ),
                                ),
                              if (status.invitation > 0)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_outlined,
                                      size: 12,
                                      color: siteColorConfig.inviteColor.value,
                                    ),
                                    Text(
                                      '${status.invitation}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: siteColorConfig.inviteColor.value,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                    trailing: Obx(() {
                      return siteRefreshing.value
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: siteColorConfig.loadingColor.value,
                                strokeWidth: 2,
                              )))
                          : SizedBox.shrink();
                    }),
                  ),
                ),
                if (status != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    textBaseline: TextBaseline.ideographic,
                                    children: [
                                      Icon(
                                        Icons.upload_outlined,
                                        color: siteColorConfig.uploadIconColor.value,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${FileSizeConvert.parseToFileSize(status.uploaded)} (${status.seed})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.uploadNumColor.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.download_outlined,
                                        color: siteColorConfig.downloadIconColor.value,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${FileSizeConvert.parseToFileSize(status.downloaded)} (${status.leech})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.downloadIconColor.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.ios_share,
                                        color: status.ratio > 1
                                            ? siteColorConfig.ratioIconColor.value
                                            : shadColorScheme.destructive,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${status.published}(${formatNumber(status.ratio, fixed: status.ratio >= 1000 ? 0 : 2)})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: status.ratio > 1
                                              ? siteColorConfig.ratioNumColor.value
                                              : shadColorScheme.destructive,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 14,
                                        color: siteColorConfig.seedIconColor.value,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        FileSizeConvert.parseToFileSize(status.seedVolume),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.seedNumColor.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    textBaseline: TextBaseline.ideographic,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: siteColorConfig.perBonusIconColor.value,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        formatNumber(status.bonusHour),
                                        // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.perBonusIconColor.value,
                                        ),
                                      ),
                                      if (website.spFull > 0 && status.bonusHour > 0)
                                        Text(
                                          // formatNumber(status.bonusHour),
                                          '(${((status.bonusHour / website.spFull) * 100).toStringAsFixed((status.bonusHour / website.spFull) * 100 > 1 ? 0 : 2)}%)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: siteColorConfig.perBonusIconColor.value,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    textBaseline: TextBaseline.ideographic,
                                    children: [
                                      Icon(
                                        Icons.score_outlined,
                                        size: 14,
                                        color: siteColorConfig.bonusIconColor.value,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${formatNumber(status.myBonus, fixed: 0)}(${formatNumber(status.myScore, fixed: 0)})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: siteColorConfig.bonusNumColor.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '最近更新：${calculateTimeElapsed(status.updatedAt.toString())}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: siteColorConfig.updatedAtColor.value,
                              ),
                            ),
                            if (status.myHr != '' && status.myHr != "0")
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'HR: ${status.myHr.replaceAll('区', '').replaceAll('专', '').replaceAll('H&R', '').trim()}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: siteColorConfig.hrColor.value,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ]),
            ),
          );
        }),
        Obx(() {
          if (showLoading.value) {
            return Center(
                child: CircularProgressIndicator(
              strokeWidth: 4,
              color: shadColorScheme.foreground,
            ));
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Future<void> repeatSite(MySite mySite, ShadColorScheme shadColorScheme) async {
    CommonResponse res = await repeatSiteApi(mySite.id);

    if (res.succeed) {
      Get.snackbar('辅种任务发送成功', '${mySite.nickname} ${res.msg}', colorText: shadColorScheme.foreground);
    } else {
      Get.snackbar('辅种任务发送失败', '${mySite.nickname} 辅种出错啦：${res.msg}', colorText: shadColorScheme.destructive);
    }
  }

  Future<void> signSite(RxBool siteRefreshing, MySite mySite, ShadColorScheme shadColorScheme) async {
    siteRefreshing.value = true;
    CommonResponse res = await signIn(mySite.id);
    if (res.succeed) {
      Get.snackbar('签到成功', '${mySite.nickname} 签到信息：${res.msg}', colorText: shadColorScheme.foreground);
      SignInInfo? info = SignInInfo(updatedAt: getTodayString(), info: res.msg);
      Map<String, SignInInfo>? signInInfo = mySite.signInInfo;
      signInInfo.assign(getTodayString(), info);
      Logger.instance.d(signInInfo);
      MySite newSite = mySite.copyWith(signInInfo: signInInfo);
      controller.mySiteList = controller.mySiteList.map<MySite>((item) {
        if (item.id == mySite.id) {
          return newSite;
        }
        return item;
      }).toList();
      // controller.filterByKey();
      controller.update();
    } else {
      Get.snackbar('签到失败', '${mySite.nickname} 签到任务执行出错啦：${res.msg}', colorText: shadColorScheme.destructive);
    }
    siteRefreshing.value = false;
  }

  Future<void> refreshSiteData(RxBool siteRefreshing, MySite mySite, ShadColorScheme shadColorScheme) async {
    siteRefreshing.value = true;
    CommonResponse res = await getNewestStatus(mySite.id);
    if (res.succeed) {
      Get.snackbar('站点数据刷新成功', '${mySite.nickname} 数据刷新：${res.msg}', colorText: shadColorScheme.foreground);
      StatusInfo? status = StatusInfo.fromJson(res.data);
      Map<String, StatusInfo>? statusInfo = mySite.statusInfo;
      statusInfo.assign(getTodayString(), status);
      Logger.instance.d(statusInfo);
      MySite newSite = mySite.copyWith(statusInfo: statusInfo);
      controller.mySiteList = controller.mySiteList.map<MySite>((item) {
        if (item.id == mySite.id) {
          return newSite;
        }
        return item;
      }).toList();
      // controller.filterByKey();
      controller.update();

      Future.delayed(Duration(microseconds: 500), () async {
        controller.getSiteStatusFromServer();
        DashBoardController dController = Get.find();
        dController.initChartData();
        dController.update();
      });
    } else {
      Get.snackbar('站点数据刷新失败', '${mySite.nickname} 数据刷新出错啦：${res.msg}', colorText: shadColorScheme.destructive);
    }
    siteRefreshing.value = false;
  }

  ClipRRect siteLogo(String iconUrl, WebSite website, MySite mySite) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: iconUrl,
        cacheKey: iconUrl,
        fit: BoxFit.fill,
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: website.logo.startsWith('http') ? website.logo : '${mySite.mirror}${website.logo}',
          fit: BoxFit.fill,
          httpHeaders: {
            "user-agent": mySite.userAgent.toString(),
            "Cookie": mySite.cookie.toString(),
          },
          errorWidget: (context, url, error) => const Image(image: AssetImage('assets/images/avatar.png')),
          width: 32,
          height: 32,
        ),
        width: 32,
        height: 32,
      ),
    );
  }

  Future<void> _showEditBottomSheet({MySite? mySite, RxBool? showLoading}) async {
    var shadThemeData = ShadTheme.of(context);
    var shadColorScheme = shadThemeData.colorScheme;
    if (mySite != null) {
      showLoading?.value = true;
      controller.update(["SingleSite-${mySite.id}"]);
      CommonResponse res = await getMySiteByIdApi(mySite.id);
      showLoading?.value = false;
      controller.update(["SingleSite-${mySite.id}"]);
      if (!res.succeed) {
        Get.snackbar('获取站点信息失败', "获取站点信息失败，请更新站点列表后重试！${res.msg}", colorText: shadColorScheme.destructive);
        return;
      }
      mySite = res.data;
    }

    // 获取已添加的站点名称
    List<String> hasKeys = controller.mySiteList.map((element) => element.site).toList();
    // 筛选活着的和未添加过的站点
    List<WebSite> webSiteList = controller.webSiteList.values.where((item) => item.alive).toList();
    // 如果是编辑模式，
    if (mySite == null) {
      webSiteList.removeWhere((item) => hasKeys.contains(item.name));
    }
    webSiteList.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final siteController = TextEditingController(text: mySite?.site ?? '');
    final apiKeyController = TextEditingController(text: mySite?.authKey ?? '');
    final sortIdController = TextEditingController(text: mySite?.sortId.toString() ?? '1');
    RxBool isLoading = false.obs;
    final nicknameController = TextEditingController(text: mySite?.nickname ?? '');
    final passkeyController = TextEditingController(text: mySite?.passkey ?? '');
    final userIdController = TextEditingController(text: mySite?.userId ?? '');
    final usernameController = TextEditingController(text: mySite?.username ?? '');
    final emailController = TextEditingController(text: mySite?.email ?? '');
    final userAgentController = TextEditingController(
        text: mySite?.userAgent ??
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0');
    final rssController = TextEditingController(text: mySite?.rss ?? '');
    final proxyController = TextEditingController(text: mySite?.proxy ?? '');
    final torrentsController = TextEditingController(text: mySite?.torrents ?? '');
    final cookieController = TextEditingController(text: mySite?.cookie ?? '');
    final tagController = TextEditingController(text: '');
    Rx<WebSite?> selectedSite =
        (mySite != null ? controller.webSiteList[mySite.site] : (webSiteList.isNotEmpty ? webSiteList.first : null))
            .obs;
    RxList<String>? urlList = selectedSite.value != null ? selectedSite.value?.url.obs : <String>[].obs;
    final mirrorController = TextEditingController(text: mySite?.mirror ?? urlList?.first ?? '');
    RxBool getInfo = mySite != null ? mySite.getInfo.obs : true.obs;
    RxBool available = mySite != null ? mySite.available.obs : (selectedSite.value?.alive ?? false).obs;
    RxList<String> tags = mySite != null ? mySite.tags.obs : (selectedSite.value?.tags.split(',') ?? []).obs;
    Logger.instance.d(tags);
    RxBool signIn = mySite != null ? mySite.signIn.obs : true.obs;
    RxBool brushRss = mySite != null ? mySite.brushRss.obs : false.obs;
    RxBool brushFree = mySite != null ? mySite.brushFree.obs : false.obs;
    RxBool packageFile = mySite != null ? mySite.packageFile.obs : false.obs;
    RxBool repeatTorrents = mySite != null ? mySite.repeatTorrents.obs : true.obs;
    RxBool hrDiscern = mySite != null ? mySite.hrDiscern.obs : false.obs;
    RxBool showInDash = mySite != null ? mySite.showInDash.obs : true.obs;
    RxBool searchTorrents = mySite != null ? mySite.searchTorrents.obs : true.obs;
    RxBool manualInput = false.obs;
    RxBool doSaveLoading = false.obs;
    final RxList<WebSite> filteredList = <WebSite>[].obs;
    filteredList.value = webSiteList;
    final GlobalKey<FormFieldState> chipFieldKey = GlobalKey();
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      isScrollControlled: true,
      backgroundColor: shadColorScheme.background,
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          spacing: 5,
          children: [
            ListTile(
              title: Text(
                mySite != null ? '编辑站点：${mySite.nickname}' : '添加站点',
                style: shadThemeData.textTheme.h4.copyWith(
                  color: shadColorScheme.foreground,
                ),
              ),
              trailing: Obx(() {
                return isLoading.value
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: shadColorScheme.foreground,
                          )),
                        ))
                    : ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          isLoading.value = true;
                          await controller.getWebSiteListFromServer();
                          controller.update();
                          isLoading.value = false;
                        },
                        leading: Icon(
                          Icons.cloud_download_outlined,
                          size: 18,
                          color: shadColorScheme.foreground,
                        ),
                        child: Text(
                          '刷新站点列表',
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                      );
              }),
            ),
            LayoutBuilder(builder: (context, constraints) {
              // constraints.maxWidth 就是控件自身宽度
              double popupWidth = constraints.maxWidth;
              return Obx(() {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: ShadSelect<WebSite>.withSearch(
                      searchPlaceholder: Text(
                        '搜索站点',
                        style: TextStyle(color: shadColorScheme.foreground),
                      ),
                      placeholder: Text(
                        '请选择站点',
                        style: TextStyle(color: shadColorScheme.foreground),
                      ),
                      decoration: ShadDecoration(
                        border: ShadBorder(
                          merge: false,
                          bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      initialValue: selectedSite.value,
                      itemCount: filteredList.length,
                      minWidth: 200,
                      // 弹窗最小宽度
                      maxWidth: popupWidth,
                      // 弹窗最大宽度
                      maxHeight: 400,
                      // 弹窗最大高度
                      optionsBuilder: (BuildContext context, int index) {
                        var item = filteredList[index];
                        return ShadOption(
                          value: item,
                          padding: EdgeInsets.zero,
                          child: ListTile(
                            leading: SizedBox(
                              height: 28,
                              width: 28,
                              child: CircleAvatar(
                                backgroundColor: shadColorScheme.selection,
                                child: Text(
                                  item.name.substring(0, 1),
                                  style: TextStyle(
                                    color: shadColorScheme.foreground,
                                  ),
                                ),
                              ),
                            ),
                            // selected: isSelected,
                            title: Text(
                              item.name,
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                          ),
                        );
                      },
                      selectedOptionBuilder: (BuildContext context, WebSite website) {
                        return Text(
                          website.name,
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        );
                      },
                      onSearchChanged: (keyword) {
                        Logger.instance.d(keyword);
                        filteredList.value = webSiteList
                            .where((item) =>
                                item.name.toLowerCase().contains(keyword.toLowerCase()) ||
                                item.nickname.toLowerCase().contains(keyword.toLowerCase()) ||
                                item.url.any((e) => e.toLowerCase().contains(keyword.toLowerCase())))
                            .toList();
                        Logger.instance.d(filteredList.length);
                      },
                      onChanged: (item) {
                        if (item == null) return;
                        siteController.text = item.name;
                        selectedSite.value = item;
                        urlList?.value = selectedSite.value!.url;
                        mirrorController.text = urlList![0];
                        nicknameController.text = selectedSite.value!.name;
                        signIn.value = selectedSite.value!.signIn;
                        getInfo.value = selectedSite.value!.getInfo;
                        repeatTorrents.value = selectedSite.value!.repeatTorrents;
                        searchTorrents.value = selectedSite.value!.searchTorrents;
                        available.value = selectedSite.value!.alive;
                        tags.value = selectedSite.value!.tags
                            .split(',')
                            .map((item) => item.trim())
                            .where((el) => el.isNotEmpty)
                            .toList();
                        chipFieldKey.currentState?.reset();
                      },
                    ),
                  ),
                );
              });
            }),
            if (selectedSite.value != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Obx(() {
                    return Column(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (urlList!.isNotEmpty)
                          Obx(() {
                            return Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: double.infinity),
                                      child: ShadSelect<String>(
                                          placeholder: Text(
                                            '选择网址',
                                            style: TextStyle(color: shadColorScheme.foreground),
                                          ),
                                          trailing: Text(
                                            '选择网址',
                                            style: TextStyle(color: shadColorScheme.foreground),
                                          ),
                                          initialValue: mirrorController.text,
                                          decoration: ShadDecoration(
                                            border: ShadBorder(
                                              merge: false,
                                              bottom: ShadBorderSide(
                                                  color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                            ),
                                          ),
                                          options:
                                              urlList.map((key) => ShadOption(value: key, child: Text(key))).toList(),
                                          selectedOptionBuilder: (context, value) {
                                            return Text(value);
                                          },
                                          onChanged: (String? value) {
                                            mirrorController.text = value!;
                                          }),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    manualInput.value = !manualInput.value;
                                    controller.update();
                                  },
                                  icon: Icon(
                                    manualInput.value ? Icons.back_hand_outlined : Icons.front_hand,
                                    color: shadColorScheme.foreground,
                                    size: 16,
                                  ),
                                )
                              ],
                            );
                          }),
                        Obx(() => manualInput.value
                            ? CustomTextField(
                                controller: mirrorController,
                                labelText: '手动输入 - 注意：浏览器插件自动导入可能无法识别',
                              )
                            : SizedBox.shrink()),
                        CustomTextField(
                          controller: nicknameController,
                          labelText: '站点昵称',
                        ),

                        CustomTextField(
                          controller: usernameController,
                          maxLength: 128,
                          labelText: '用户名称',
                        ),
                        CustomTextField(
                          controller: userIdController,
                          maxLength: 128,
                          labelText: 'User ID',
                        ),
                        CustomTextField(
                          controller: emailController,
                          maxLength: 128,
                          labelText: '邮箱地址',
                        ),
                        CustomTextField(
                          controller: sortIdController,
                          labelText: '排序 ID',
                        ),
                        CustomTextField(
                          controller: passkeyController,
                          maxLength: 128,
                          labelText: 'Passkey',
                        ),
                        CustomTextField(
                          controller: apiKeyController,
                          maxLength: 128,
                          labelText: 'AuthKey',
                        ),
                        CustomTextField(
                          controller: userAgentController,
                          labelText: 'User Agent',
                          scrollPhysics: const BouncingScrollPhysics(),
                          maxLines: 2,
                        ),
                        // CustomTextField(
                        //   controller: rssController,
                        //   labelText: 'RSS',
                        // ),
                        // CustomTextField(
                        //   controller: torrentsController,
                        //   labelText: 'Torrents',
                        // ),
                        CustomTextField(
                          controller: cookieController,
                          labelText: 'Cookie',
                          scrollPhysics: const BouncingScrollPhysics(),
                          maxLines: 5,
                        ),
                        CustomTextField(
                          controller: proxyController,
                          labelText: 'HTTP代理',
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: tagController,
                                labelText: '添加标签',
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (tagController.text.isEmpty) {
                                  return;
                                }
                                controller.tagList.add(tagController.text);
                                controller.updateTagList();
                                controller.update();
                              },
                              icon: Icon(
                                Icons.plus_one_sharp,
                                size: 20,
                              ),
                            )
                          ],
                        ),

                        GetBuilder<MySiteController>(builder: (controller) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                            child: Obx(() {
                              return MultiSelectChipField(
                                key: chipFieldKey,
                                items: controller.tagList.map((tag) => MultiSelectItem<String?>(tag, tag)).toList(),
                                textStyle: TextStyle(fontSize: 11, color: shadColorScheme.foreground),
                                selectedTextStyle: TextStyle(fontSize: 8, color: shadColorScheme.foreground),
                                chipColor: shadColorScheme.background,
                                selectedChipColor: shadColorScheme.primary,
                                scroll: false,
                                initialValue: [...tags],
                                title: Text(
                                  " 站点标签",
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w800, color: shadColorScheme.foreground),
                                  textAlign: TextAlign.center,
                                ),
                                headerColor: Colors.transparent,
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(color: Colors.transparent, width: 0),
                                ),
                                chipShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                onTap: (List<String?> values) {
                                  Logger.instance.d(values);
                                  // tags.value = values;
                                  tags.value = values.where((value) => value != null).whereType<String>().toList();
                                  tags.value = tags.toSet().toList();
                                  Logger.instance.d(tags);
                                },
                              );
                            }),
                          );
                        }),
                        const SizedBox(height: 15),
                      ],
                    );
                  }),
                ),
              ),
            const SizedBox(height: 5),
            Obx(() {
              return Wrap(spacing: 12, runSpacing: 8, children: [
                selectedSite.value!.alive
                    ? ChoiceChip(
                        backgroundColor: shadColorScheme.background,
                        selectedColor: shadColorScheme.primary,
                        checkmarkColor: shadColorScheme.foreground,
                        selectedShadowColor: shadColorScheme.primary,
                        elevation: 2,
                        label: Text('可用', style: TextStyle(color: shadColorScheme.foreground)),
                        selected: selectedSite.value!.alive ? available.value : false,
                        onSelected: (value) {
                          selectedSite.value!.alive ? available.value = value : available.value = false;
                        },
                      )
                    : ChoiceChip(
                        backgroundColor: shadColorScheme.background,
                        selectedColor: shadColorScheme.primary,
                        checkmarkColor: shadColorScheme.foreground,
                        selectedShadowColor: shadColorScheme.primary,
                        elevation: 2,
                        label: Text('可用', style: TextStyle(color: shadColorScheme.foreground)),
                        selected: false,
                        onSelected: (value) {
                          Logger.instance.d("站点可用性：${selectedSite.value!.alive}");
                          available.value = selectedSite.value!.alive;
                        },
                      ),
                ChoiceChip(
                  backgroundColor: shadColorScheme.background,
                  selectedColor: shadColorScheme.primary,
                  checkmarkColor: shadColorScheme.foreground,
                  selectedShadowColor: shadColorScheme.primary,
                  elevation: 2,
                  label: Text('Dash', style: TextStyle(color: shadColorScheme.foreground)),
                  selected: showInDash.value,
                  onSelected: (value) {
                    showInDash.value = value;
                  },
                ),
                ChoiceChip(
                  backgroundColor: shadColorScheme.background,
                  selectedColor: shadColorScheme.primary,
                  checkmarkColor: shadColorScheme.foreground,
                  selectedShadowColor: shadColorScheme.primary,
                  elevation: 2,
                  label: Text('数据', style: TextStyle(color: shadColorScheme.foreground)),
                  selected: getInfo.value,
                  onSelected: (value) {
                    getInfo.value = value;
                  },
                ),
                if (selectedSite.value!.searchTorrents)
                  ChoiceChip(
                    backgroundColor: shadColorScheme.background,
                    selectedColor: shadColorScheme.primary,
                    checkmarkColor: shadColorScheme.foreground,
                    selectedShadowColor: shadColorScheme.primary,
                    elevation: 2,
                    label: Text('搜索', style: TextStyle(color: shadColorScheme.foreground)),
                    selected: searchTorrents.value,
                    onSelected: (value) {
                      searchTorrents.value = value;
                    },
                  ),
                if (selectedSite.value!.signIn)
                  ChoiceChip(
                    backgroundColor: shadColorScheme.background,
                    selectedColor: shadColorScheme.primary,
                    checkmarkColor: shadColorScheme.foreground,
                    selectedShadowColor: shadColorScheme.primary,
                    elevation: 2,
                    label: Text('签到', style: TextStyle(color: shadColorScheme.foreground)),
                    selected: signIn.value,
                    onSelected: (value) {
                      signIn.value = value;
                    },
                  ),
                if (selectedSite.value!.repeatTorrents)
                  ChoiceChip(
                    backgroundColor: shadColorScheme.background,
                    selectedColor: shadColorScheme.primary,
                    checkmarkColor: shadColorScheme.foreground,
                    selectedShadowColor: shadColorScheme.primary,
                    elevation: 2,
                    label: Text('辅种', style: TextStyle(color: shadColorScheme.foreground)),
                    selected: repeatTorrents.value,
                    onSelected: (value) {
                      repeatTorrents.value = value;
                    },
                  ),
              ]);
            }),
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ShadButton.ghost(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    Get.back();
                  },
                  leading: Icon(
                    Icons.cancel,
                    size: 16,
                  ),
                  child: Text('取消'),
                ),
                if (mySite != null)
                  ShadButton.secondary(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      Get.defaultDialog(
                        title: '删除站点：${mySite?.nickname}',
                        radius: 5,
                        backgroundColor: shadColorScheme.background,
                        middleTextStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                        titleStyle:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: shadColorScheme.foreground),
                        middleText: '确定要删除吗？',
                        actions: [
                          ShadButton.outline(
                            size: ShadButtonSize.sm,
                            onPressed: () {
                              Get.back(result: false);
                            },
                            child: const Text('取消'),
                          ),
                          ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            onPressed: () async {
                              Get.back(result: true);
                              var res = await controller.removeSiteFromServer(mySite!);
                              if (res.succeed) {
                                Get.back(result: true);
                                Get.snackbar(
                                  '删除站点',
                                  res.msg.toString(),
                                  colorText: shadColorScheme.foreground,
                                );
                                controller.showStatusList.removeWhere((item) => mySite?.id == item.id);
                                controller.update();
                                await controller.getSiteStatusFromServer();
                              } else {
                                Logger.instance.e(res.msg);
                                Get.snackbar(
                                  '删除站点',
                                  res.msg.toString(),
                                  colorText: shadColorScheme.destructive,
                                );
                              }
                            },
                            child: const Text('确认'),
                          ),
                        ],
                      );
                    },
                    foregroundColor: shadColorScheme.destructive,
                    leading: Icon(Icons.delete, size: 16),
                    child: Text('删除'),
                  ),
                if (selectedSite.value != null)
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    leading: Obx(
                      () {
                        return doSaveLoading.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: Center(
                                    child: CircularProgressIndicator(
                                  color: shadColorScheme.foreground,
                                )))
                            : Icon(Icons.save, size: 16);
                      },
                    ),
                    child: Text('保存'),
                    onPressed: () async {
                      doSaveLoading.value = true;
                      if (mySite != null) {
                        mySite = mySite?.copyWith(
                          site: siteController.text.trim(),
                          mirror: mirrorController.text.trim(),
                          nickname: nicknameController.text.trim(),
                          tags: tags,
                          passkey: passkeyController.text.trim(),
                          authKey: apiKeyController.text.trim(),
                          userId: userIdController.text.trim(),
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          sortId: int.parse(sortIdController.text.trim()),
                          userAgent: userAgentController.text.trim(),
                          proxy: proxyController.text.trim(),
                          rss: rssController.text.trim(),
                          torrents: torrentsController.text.trim(),
                          cookie: cookieController.text.trim(),
                          getInfo: getInfo.value,
                          signIn: signIn.value,
                          brushRss: brushRss.value,
                          brushFree: brushFree.value,
                          packageFile: packageFile.value,
                          repeatTorrents: repeatTorrents.value,
                          hrDiscern: hrDiscern.value,
                          showInDash: showInDash.value,
                          searchTorrents: searchTorrents.value,
                          available: available.value,
                        );
                      } else {
                        // 如果 mySite 为空，表示是添加操作
                        mySite = MySite(
                          site: siteController.text.trim(),
                          mirror: mirrorController.text.trim(),
                          nickname: nicknameController.text.trim(),
                          tags: tags,
                          passkey: passkeyController.text.trim(),
                          authKey: apiKeyController.text.trim(),
                          userId: userIdController.text.trim(),
                          username: usernameController.text.trim(),
                          email: emailController.text.trim(),
                          sortId: int.parse(sortIdController.text.trim()),
                          userAgent: userAgentController.text.trim(),
                          proxy: proxyController.text.trim(),
                          rss: rssController.text.trim(),
                          torrents: torrentsController.text.trim(),
                          cookie: cookieController.text.trim(),
                          getInfo: getInfo.value,
                          signIn: signIn.value,
                          brushRss: brushRss.value,
                          brushFree: brushFree.value,
                          packageFile: packageFile.value,
                          repeatTorrents: repeatTorrents.value,
                          hrDiscern: hrDiscern.value,
                          showInDash: showInDash.value,
                          searchTorrents: searchTorrents.value,
                          available: available.value,
                          id: 0,
                          removeTorrentRules: {},
                          timeJoin: '',
                          mail: 0,
                          notice: 0,
                          signInInfo: {},
                          statusInfo: {},
                        );
                      }
                      Logger.instance.d(mySite?.toJson());
                      CommonResponse response = await controller.saveMySiteToServer(mySite!);

                      if (response.succeed) {
                        Get.back();
                        controller.initFlag = false;
                        controller.getSiteStatusFromServer();
                        Future.delayed(Duration(seconds: 2), () async {
                          DashBoardController dController = Get.find();
                          dController.initChartData();
                          dController.update();
                        });
                        Get.snackbar('保存成功！', response.msg, snackPosition: SnackPosition.TOP);
                        controller.update();
                        Future.microtask(() => controller.getSiteStatusFromServer());
                      } else {
                        Get.snackbar('保存出错啦！', response.msg,
                            snackPosition: SnackPosition.TOP, colorText: shadColorScheme.destructive);
                      }
                      doSaveLoading.value = false;
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSignHistory(MySite mySite) async {
    CommonResponse res = await getMySiteByIdApi(mySite.id);
    if (!res.succeed) {
      Logger.instance.e('获取站点信息失败');
      Get.snackbar('获取站点信息失败', res.msg, colorText: ShadTheme.of(context).colorScheme.destructive);
      return;
    }
    mySite = res.data;
    List<String> signKeys = mySite.signInInfo.keys.toList();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    signKeys.sort((a, b) => b.compareTo(a));
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        isScrollControlled: true, GetBuilder<MySiteController>(builder: (controller) {
      return CustomCard(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(children: [
            Text(
              "${mySite.nickname} [累计自动签到${mySite.signInInfo.length}天]",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: shadColorScheme.foreground),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: signKeys.length,
                    itemBuilder: (context, index) {
                      String signKey = signKeys[index];
                      SignInInfo? item = mySite.signInInfo[signKey];
                      var scheme = ShadTheme.of(context).colorScheme;
                      return CustomCard(
                        child: ListTile(
                            title: Text(
                              item!.info,
                              style:
                                  TextStyle(fontSize: 12, color: signKey == today ? Colors.amber : scheme.foreground),
                            ),
                            subtitle: Text(
                              item.updatedAt,
                              style:
                                  TextStyle(fontSize: 10, color: signKey == today ? Colors.amber : scheme.foreground),
                            ),
                            selected: signKey == today,
                            selectedColor: Colors.amber,
                            onTap: () {}),
                      );
                    }))
          ]));
    }));
  }

  void _showStatusHistory(MySite mySite) async {
    CommonResponse res = await getMySiteByIdApi(mySite.id);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (!res.succeed) {
      Logger.instance.e('获取站点信息失败');
      Get.snackbar('获取站点信息失败', res.msg, colorText: shadColorScheme.destructive);
      return;
    }
    mySite = res.data;
    List<StatusInfo> transformedData = mySite.statusInfo.values.toList();
    Logger.instance.d(transformedData);
    Rx<RangeValues> rangeValues =
        RangeValues(transformedData.length > 7 ? transformedData.length - 7 : 0, transformedData.length.toDouble() - 1)
            .obs;
    Logger.instance.d(rangeValues.value);
    RxList<StatusInfo> showData =
        transformedData.sublist(rangeValues.value.start.toInt(), rangeValues.value.end.toInt() + 1).obs;
    Logger.instance.d(showData);
    Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      // isScrollControlled: true,
      Obx(() {
        return SafeArea(
          child: CustomCard(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Column(children: [
                Text(
                  "${mySite.nickname} [站点数据累计${mySite.statusInfo.length}天]",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: shadColorScheme.foreground),
                ),
                SfCartesianChart(
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      animationDuration: 100,
                      shouldAlwaysShow: false,
                      tooltipPosition: TooltipPosition.pointer,
                      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                        StatusInfo? lastData = pointIndex > 0 ? series.dataSource[pointIndex - 1] : null;
                        return Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8),
                            width: 200,
                            child: SingleChildScrollView(child: StatusToolTip(data: data, lastData: lastData)));
                      },
                    ),
                    zoomPanBehavior: ZoomPanBehavior(
                      /// To enable the pinch zooming as true.
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                      enablePanning: true,
                      enableMouseWheelZooming: true,
                    ),
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    primaryXAxis: const CategoryAxis(
                      majorGridLines: MajorGridLines(width: 0),
                    ),
                    primaryYAxis: const NumericAxis(
                      isVisible: false,
                    ),
                    axes: <ChartAxis>[
                      NumericAxis(
                        name: 'PrimaryYAxis',
                        labelPosition: ChartDataLabelPosition.inside,
                        numberFormat: NumberFormat.compact(),
                        majorTickLines: const MajorTickLines(width: 0),
                        minorTickLines: const MinorTickLines(width: 0),
                        labelStyle: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                      ),
                      NumericAxis(
                        name: 'SecondaryYAxis',
                        isVisible: false,
                        tickPosition: TickPosition.inside,
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                        labelStyle: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                      ),
                      NumericAxis(
                        name: 'ThirdYAxis',
                        isVisible: false,
                        tickPosition: TickPosition.inside,
                        majorTickLines: MajorTickLines(width: 0),
                        minorTickLines: MinorTickLines(width: 0),
                        labelStyle: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                      ),
                    ],
                    series: <CartesianSeries>[
                      LineSeries<StatusInfo, String>(
                          name: '做种体积',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.seedVolume),
                      LineSeries<StatusInfo, String>(
                          name: '上传量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.uploaded),
                      ColumnSeries<StatusInfo, String>(
                        name: '上传增量',
                        dataSource: showData,
                        yAxisName: 'ThirdYAxis',
                        xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                        yValueMapper: (StatusInfo item, index) =>
                            index > 0 && item.uploaded > showData[index - 1].uploaded
                                ? item.uploaded - showData[index - 1].uploaded
                                : 0,
                        dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            textStyle: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                              return point.y > 0
                                  ? Text(
                                      FileSizeConvert.parseToFileSize((point.y).toInt()),
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                                    )
                                  : const SizedBox.shrink();
                            }),
                      ),
                      LineSeries<StatusInfo, String>(
                          name: '下载量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.downloaded),
                      LineSeries<StatusInfo, String>(
                          name: '时魔',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.bonusHour),
                      LineSeries<StatusInfo, String>(
                          name: '做种积分',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.myScore),
                      LineSeries<StatusInfo, String>(
                          name: '魔力值',
                          yAxisName: 'PrimaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.myBonus),
                      LineSeries<StatusInfo, String>(
                          name: '做种数量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.seed),
                      LineSeries<StatusInfo, String>(
                          name: '吸血数量',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.leech),
                      LineSeries<StatusInfo, String>(
                          name: '邀请',
                          yAxisName: 'SecondaryYAxis',
                          dataSource: showData,
                          xValueMapper: (StatusInfo item, _) => formatCreatedTimeToDateString(item),
                          yValueMapper: (StatusInfo item, _) => item.invitation),
                    ]),
                Text(
                  "${rangeValues.value.end.toInt() - rangeValues.value.start.toInt() + 1}日数据",
                  style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                ),
                RangeSlider(
                  min: 0,
                  max: transformedData.length * 1.0 - 1,
                  divisions: transformedData.length - 1,
                  labels: RangeLabels(
                    formatCreatedTimeToDateString(transformedData[rangeValues.value.start.toInt()]),
                    formatCreatedTimeToDateString(transformedData[rangeValues.value.end.toInt()]),
                  ),
                  onChanged: (value) {
                    rangeValues.value = value;
                    showData.value =
                        transformedData.sublist(rangeValues.value.start.toInt(), rangeValues.value.end.toInt() + 1);
                  },
                  values: rangeValues.value,
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 当应用程序重新打开时，重新加载数据
      controller.initData();
    }
  }
}

class StatusToolTip extends StatelessWidget {
  final StatusInfo data;
  final StatusInfo? lastData;

  const StatusToolTip({super.key, required this.data, required this.lastData});

  @override
  Widget build(BuildContext context) {
    int difference = (lastData == null || lastData!.uploaded > data.uploaded) ? 0 : data.uploaded - lastData!.uploaded;
    return Column(
      children: [
        _buildDataRow('创建时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(data.createdAt)),
        _buildDataRow('更新时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(data.updatedAt)),
        _buildDataRow('做种量', FileSizeConvert.parseToFileSize(data.seedVolume)),
        _buildDataRow('等级', data.myLevel),
        _buildDataRow('上传量', FileSizeConvert.parseToFileSize(data.uploaded)),
        _buildDataRow('上传增量', FileSizeConvert.parseToFileSize(difference)),
        _buildDataRow('下载量', FileSizeConvert.parseToFileSize(data.downloaded)),
        _buildDataRow('分享率', data.ratio.toStringAsFixed(3)),
        _buildDataRow('魔力', formatNumber(data.myBonus)),
        if (data.myScore > 0) _buildDataRow('积分', formatNumber(data.myScore)),
        if (data.bonusHour > 0) _buildDataRow('时魔', formatNumber(data.bonusHour)),
        _buildDataRow('做种中', data.seed),
        _buildDataRow('吸血中', data.leech),
        if (data.invitation > 0) _buildDataRow('邀请', data.invitation),
        if (data.seedDays > 0) _buildDataRow('做种时间', data.seedDays),
        _buildDataRow('HR', data.myHr),
        if (data.published > 0) _buildDataRow('已发布', data.published),
      ],
    );
  }

  Widget _buildDataRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
