import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/string_utils.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../common/meta_item.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logger_helper.dart' as logger_helper;
import '../../utils/storage.dart';
import '../home/pages/download/download_form.dart';
import '../home/pages/download/qb_file_tree_view.dart';
import 'controller.dart';

class QBittorrentPage extends GetView<QBittorrentController> {
  const QBittorrentPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchKeyController = TextEditingController();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<QBittorrentController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          Get.defaultDialog(
            backgroundColor: shadColorScheme.background,
            title: "退出",
            content: Text(
              '确定要退出内置浏览器？',
              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            ),
            middleTextStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            titleStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            radius: 10,
            cancel: ShadButton.destructive(
              size: ShadButtonSize.sm,
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: const Text('取消'),
            ),
            confirm: ShadButton(
              size: ShadButtonSize.sm,
              onPressed: () async {
                Navigator.of(context).pop(false);
                Get.back();
              },
              child: const Text('确定'),
            ),
            textCancel: '退出',
            textConfirm: '取消',
          );
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              '${controller.downloader.name} - ${controller.allTorrents.length}',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
          ),
          backgroundColor: shadColorScheme.background,
          body: EasyRefresh(
              controller: EasyRefreshController(),
              onRefresh: () async {
                await controller.initData();
              },
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: GetBuilder<QBittorrentController>(builder: (controller) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: searchKeyController,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: '请输入搜索关键字',
                                      hintStyle: const TextStyle(fontSize: 14),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // 不绘制边框
                                        borderRadius: BorderRadius.circular(0.0),
                                        // 确保角落没有圆角
                                        gapPadding: 0.0, // 移除边框与hintText之间的间距
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // 仅在聚焦时绘制底部边框
                                        borderRadius: BorderRadius.circular(0.0),
                                      ),
                                      suffixIcon: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text('计数：${controller.showTorrents.length}',
                                                style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onChanged: (value) {
                                      controller.searchKey = value;
                                      controller.filterTorrents();
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                if (controller.searchKey.isNotEmpty)
                                  ShadIconButton.ghost(
                                      onPressed: () {
                                        if (controller.searchController.text.isNotEmpty) {
                                          controller.searchController.text = controller.searchController.text
                                              .substring(0, controller.searchController.text.length - 1);
                                          controller.searchKey = controller.searchController.text;
                                          controller.filterTorrents();
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.backspace_outlined,
                                        size: 18,
                                      ))
                              ],
                            );
                          }),
                        ),
                        Expanded(
                          child: controller.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : Stack(
                                  children: [
                                    ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        itemCount: controller.showTorrents.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          TorrentInfo torrentInfo = controller.showTorrents[index];
                                          return _buildQbTorrentCard(torrentInfo, context);
                                        }),
                                    if (controller.showDetailsLoading) const Center(child: CircularProgressIndicator())
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  _buildActionButtons(context),
                ],
              )),
          endDrawer: _buildGfDrawer(context),
          // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          // floatingActionButton: _buildActionButtons(context),
        ),
      );
    });
  }

  Widget _buildGfDrawer(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<QBittorrentController>(builder: (controller) {
      return Drawer(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        width: 300,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 48.0,
                    width: 48.0,
                    child: CircleAvatar(
                      radius: 80.0,
                      backgroundImage: AssetImage('assets/images/${controller.downloader.category.toLowerCase()}.png'),
                    ),
                  ),
                  Text(
                    '${controller.downloader.protocol}://${controller.downloader.host}:${controller.downloader.port}',
                    style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(child: SizedBox()),
            if (controller.serverState != null) ...[
              ListTile(
                dense: true,
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomTextTag(
                        icon: const Icon(
                          Icons.upload_outlined,
                          color: Colors.green,
                          size: 14,
                        ),
                        backgroundColor: Colors.transparent,
                        labelColor: Colors.green,
                        labelText: '[${FileSizeConvert.parseToFileSize(controller.serverState!.upRateLimit)}/S]'),
                    CustomTextTag(
                        icon: const Icon(
                          Icons.download_outlined,
                          color: Colors.red,
                          size: 14,
                        ),
                        backgroundColor: Colors.transparent,
                        labelColor: Colors.red,
                        labelText: '[${FileSizeConvert.parseToFileSize(controller.serverState!.dlRateLimit)}/S]'),
                  ],
                ),
                title: Center(
                  child: Text(
                    '限速模式',
                    style: TextStyle(color: shadColorScheme.foreground),
                  ),
                ),
                trailing: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    CupertinoSwitch(
                        value: controller.serverState!.useAltSpeedLimits == true,
                        onChanged: (value) async {
                          await controller.toggleSpeedLimit();
                        }),
                    if (controller.toggleSpeedLimitLoading)
                      const SizedBox(
                          height: 16,
                          width: 16,
                          child: Center(
                              child: CircularProgressIndicator(
                            strokeWidth: 1,
                          )))
                  ],
                ),
              ),
              ListTile(
                dense: true,
                style: ListTileStyle.drawer,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomTextTag(
                        icon: const Icon(
                          Icons.upload_outlined,
                          color: Colors.green,
                          size: 14,
                        ),
                        backgroundColor: Colors.transparent,
                        labelColor: Colors.green,
                        labelText:
                            '${FileSizeConvert.parseToFileSize(controller.serverState!.alltimeUl)}[${FileSizeConvert.parseToFileSize(controller.serverState!.upInfoData)}]'),
                    CustomTextTag(
                        icon: const Icon(
                          Icons.download_outlined,
                          color: Colors.red,
                          size: 14,
                        ),
                        backgroundColor: Colors.transparent,
                        labelColor: Colors.red,
                        labelText:
                            '${FileSizeConvert.parseToFileSize(controller.serverState!.alltimeDl)}[${FileSizeConvert.parseToFileSize(controller.serverState!.dlInfoData)}]'),
                  ],
                ),
              ),
              ListTile(
                dense: true,
                title: Container(
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      '剩余空间: ${FileSizeConvert.parseToFileSize(controller.serverState!.freeSpaceOnDisk)}',
                      style: TextStyle(color: shadColorScheme.foreground, fontSize: 9),
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<QBittorrentController>(builder: (controller) {
      return CustomCard(
        color: shadColorScheme.background,
        padding: const EdgeInsets.all(0),
        width: double.infinity,
        child: Center(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                  controller.sortReversed = !controller.sortReversed;
                  controller.filterTorrents();
                  logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
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
              GetBuilder<QBittorrentController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.qbSortOptions
                            .map((item) => PopupMenuItem<String>(
                                  height: 32,
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: shadColorScheme.foreground,
                                    ),
                                  ),
                                  onTap: () async {
                                    logger_helper.Logger.instance
                                        .d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                                    controller.sortKey = item.value;
                                    logger_helper.Logger.instance.d('当前排序字段: ${controller.sortKey}');
                                    SPUtil.setLocalStorage(
                                        '${controller.downloader.host}:${controller.downloader.port}-sortKey-DIRECT',
                                        controller.sortKey?.name);
                                    controller.subTorrentList();
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      backgroundColor: Colors.transparent,
                      icon: Icon(
                        Icons.sort_by_alpha_outlined,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      labelText:
                          '【${controller.qbSortOptions.firstWhereOrNull((item) => item.value == controller.sortKey)?.name ?? "无"}】',
                      labelColor: shadColorScheme.foreground,
                    ),
                  ),
                );
              }),
              GetBuilder<QBittorrentController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 180,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuItem<String>(
                            height: 32,
                            child: Text(
                              '全部[${controller.torrents.length}]',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedTag = null;
                              controller.showTorrents.clear();
                              controller.subTorrentList();
                            },
                          ),
                          ...controller.tags.map((item) => PopupMenuItem<String>(
                                height: 32,
                                child: Text(
                                  '$item[${controller.allTorrents.where((element) => element.tags?.contains(item) ?? false).length}]',
                                  style: TextStyle(
                                    color: shadColorScheme.foreground,
                                  ),
                                ),
                                onTap: () async {
                                  controller.selectedTag = item;
                                  controller.subTorrentList();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      backgroundColor: Colors.transparent,
                      icon: Icon(
                        Icons.tag,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      labelText: '【${controller.selectedTag ?? "全部"}】',
                      labelColor: shadColorScheme.foreground,
                    ),
                  ),
                );
              }),
              GetBuilder<QBittorrentController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 120,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuItem<String>(
                            height: 32,
                            child: Text(
                              '全部[${controller.allTorrents.length}]',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedTracker = '全部';
                              controller.showTorrents.clear();
                              controller.subTorrentList();
                            },
                          ),
                          PopupMenuItem<String>(
                            height: 32,
                            child: Text(
                              '红种[${controller.allTorrents.where((element) => element.tracker?.isEmpty == true).toList().length}]',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedTracker = '红种';
                              controller.subTorrentList();
                            },
                          ),
                          ...controller.trackers.keys.map((item) => PopupMenuItem<String>(
                                height: 32,
                                child: Text(
                                  '$item[${controller.trackers[item]?.length ?? 0}]',
                                  style: TextStyle(
                                    color: shadColorScheme.foreground,
                                  ),
                                ),
                                onTap: () async {
                                  controller.selectedTracker = item;
                                  controller.subTorrentList();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      backgroundColor: Colors.transparent,
                      icon: Icon(
                        Icons.language_outlined,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      labelText: '【${controller.selectedTracker}】',
                      labelColor: shadColorScheme.foreground,
                    ),
                  ),
                );
              }),
              GetBuilder<QBittorrentController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 180,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...controller.categoryMap.values.map((item) => ListTile(
                                dense: true,
                                title: Text(
                                  "${item?.name ?? '未分类'}[${item?.name == '全部' ? controller.allTorrents.length : controller.allTorrents.where((torrent) => torrent.category == (item?.name != '未分类' ? item?.name : '')).toList().length}]",
                                ),
                                style: ListTileStyle.list,
                                titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                selected:
                                    controller.selectedCategory == (item?.savePath != null ? (item?.name ?? '') : null),
                                selectedColor: shadColorScheme.destructive,
                                selectedTileColor: Colors.amber,
                                onTap: () {
                                  Get.back();
                                  controller.selectedCategory = item?.savePath != null ? (item?.name ?? '') : null;
                                  if (controller.selectedCategory == '全部') {
                                    controller.showTorrents.clear();
                                  }
                                  controller.subTorrentList();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      mainAxisAlignment: MainAxisAlignment.center,
                      icon: Icon(
                        Icons.category_outlined,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: shadColorScheme.foreground,
                      labelText:
                          '【${controller.categoryMap.keys.firstWhereOrNull((item) => item == controller.selectedCategory) ?? "全部"}】',
                    ),
                  ),
                );
              }),
              GetBuilder<QBittorrentController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.qBitStatus.map((state) {
                          var torrentsMatchingState = [];
                          if (state.value == 'all') {
                            torrentsMatchingState = controller.torrents;
                          } else if (state.value == 'active') {
                            torrentsMatchingState = controller.allTorrents
                                .where((torrent) =>
                                    [
                                      "downloading",
                                      "uploading",
                                      "checkingUP",
                                      "forcedUP",
                                      "moving",
                                      "checkingDL",
                                    ].contains(torrent.state?.name) ||
                                    ((torrent.upSpeed ?? 0) + (torrent.dlSpeed ?? 0)) > 0)
                                .toList();
                          } else {
                            torrentsMatchingState = controller.allTorrents
                                .where((torrent) => state.value != null ? torrent.state == state.value : true)
                                .toList();
                          }
                          return PopupMenuItem(
                            child: Text(
                              '${state.name}(${torrentsMatchingState.length})',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                            onTap: () {
                              // Get.back();
                              logger_helper.Logger.instance.d("状态筛选...${state.name}");
                              controller.torrentState = state.value;
                              controller.subTorrentList();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      mainAxisAlignment: MainAxisAlignment.center,
                      icon: Icon(
                        Icons.info_outlined,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      backgroundColor: Colors.transparent,
                      labelText:
                          '【${controller.qBitStatus.firstWhereOrNull((item) => item.value == controller.torrentState)?.name ?? "全部"}】',
                      labelColor: shadColorScheme.foreground,
                    ),
                  ),
                );
              }),
              CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  barrierColor: Colors.transparent,
                  content: SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuItem<String>(
                          child: Center(
                            child: Text(
                              '清除红种',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                          ),
                          onTap: () async {
                            CommonResponse res = await controller.removeErrorTracker();
                            Get.snackbar('清理红种', res.msg,
                                colorText: res.code == 0 ? shadColorScheme.foreground : shadColorScheme.destructive);
                            controller.subTorrentList();
                            controller.update();
                          },
                        ),
                        PopupMenuItem<String>(
                          child: Center(
                            child: Text(
                              '切换限速',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await controller.toggleSpeedLimit();
                          },
                        ),
                        PopupMenuItem<String>(
                          child: Center(
                              child: Text(
                            '替换Tracker',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                            ),
                          )),
                          onTap: () {
                            TextEditingController keyController = TextEditingController(text: '');
                            TextEditingController valueController = TextEditingController(text: '');
                            List<String> sites =
                                controller.trackers.keys.where((e) => e != ' All' && e != ' 红种').toList();
                            sites.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                            Get.bottomSheet(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0), // 圆角半径
                              ),
                              SizedBox(
                                height: 240,
                                child: Scaffold(
                                  body: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text('Tracker替换',
                                          style: TextStyle(
                                              color: shadColorScheme.foreground,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(minWidth: double.infinity),
                                          child: ShadSelect<String>(
                                              placeholder: const Text('要替换的站点'),
                                              trailing: const Text('要替换的站点'),
                                              initialValue: sites.first,
                                              decoration: ShadDecoration(
                                                border: ShadBorder(
                                                  merge: false,
                                                  bottom: ShadBorderSide(
                                                      color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                ),
                                              ),
                                              options:
                                                  sites.map((key) => ShadOption(value: key, child: Text(key))).toList(),
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
                                          Stack(
                                            children: [
                                              ShadButton(
                                                size: ShadButtonSize.sm,
                                                onPressed: () async {
                                                  controller.trackerLoading = true;
                                                  controller.update();
                                                  CommonResponse res = await controller.replaceTrackers(
                                                      site: keyController.text, newTracker: valueController.text);
                                                  controller.trackerLoading = false;
                                                  controller.update();
                                                  if (res.succeed) {
                                                    Get.back(result: true);
                                                  }
                                                  Get.snackbar('Tracker替换ing', res.msg,
                                                      colorText: res.succeed
                                                          ? shadColorScheme.foreground
                                                          : shadColorScheme.destructive);
                                                },
                                                leading: controller.trackerLoading
                                                    ? const Center(child: CircularProgressIndicator())
                                                    : null,
                                                child: const Text('确认'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.settings,
                    size: 18,
                    color: shadColorScheme.foreground,
                  )),
              ShadIconButton.ghost(
                icon: Icon(
                  Icons.add,
                  size: 18,
                  color: shadColorScheme.foreground,
                ),
                onPressed: () {
                  Get.bottomSheet(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    backgroundColor: shadColorScheme.background,
                    enableDrag: true,
                    CustomCard(
                      height: 400,
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '添加种子',
                          ),
                        ),
                        Expanded(
                          child: DownloadForm(
                            categories: controller.categoryMap,
                            downloader: controller.downloader,
                            info: null,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQbTorrentCard(TorrentInfo torrentInfo, context) {
    RxBool paused = torrentInfo.state.toString().contains('pause').obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return CustomCard(
      color: shadColorScheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.all(2.5),
      child: GetBuilder<QBittorrentController>(builder: (controller) {
        return Slidable(
          key: ValueKey(torrentInfo.infohashV1),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.5,
            children: [
              SlidableAction(
                onPressed: (context) async {
                  RxBool deleteFiles = false.obs;
                  Get.defaultDialog(
                    title: '确认',
                    middleText: '您确定要执行这个操作吗？',
                    content: Obx(() {
                      return SwitchListTile(
                          title: const Text('是否删除种子文件？'),
                          value: deleteFiles.value,
                          onChanged: (value) {
                            deleteFiles.value = value;
                          });
                    }),
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
                          await controller.controlTorrents(
                              command: 'delete', hashes: [torrentInfo.infohashV1!], enable: deleteFiles.value);

                          controller.showTorrents.removeWhere((element) => element.hash == torrentInfo.hash);
                          controller.update();
                        },
                        child: const Text('删除'),
                      )
                    ],
                  );
                },
                flex: 2,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              ),
              SlidableAction(
                onPressed: (context) async {
                  await controller.controlTorrents(
                    command: paused.value ? 'resume' : 'pause',
                    hashes: [torrentInfo.infohashV1!],
                  );
                },
                flex: 2,
                backgroundColor: paused.value ? const Color(0xFF0392CF) : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: paused.value ? Icons.play_arrow : Icons.pause,
                label: paused.value ? '开始' : '暂停',
              ),
            ],
          ),
          child: ShadContextMenuRegion(
            decoration: ShadDecoration(
              labelStyle: TextStyle(),
              descriptionStyle: TextStyle(),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 100),
            items: [
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.stop_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('停止'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  torrentInfo.forceStart == true ? Icons.double_arrow : Icons.play_arrow,
                  color: shadColorScheme.foreground,
                ),
                child: Text('强制启动'),
                onPressed: () => controller.controlTorrents(
                    command: 'set_force_start', hashes: [torrentInfo.infohashV1!], enable: !torrentInfo.forceStart!),
              ),
              // ShadContextMenuItem(
              //   leading: Icon(
              //     size: 18,
              //     Icons.delete_outline,
              //     color: shadColorScheme.foreground,
              //   ),
              //   child: Text('删除'),
              //   onPressed: () {},
              // ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.edit_location_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('更改保存位置'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.drive_file_rename_outline_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('重命名'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.drive_file_rename_outline,
                  color: shadColorScheme.foreground,
                ),
                child: Text('重命名文件'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.category_outlined,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ...controller.categoryMap.values.map((value) => ShadContextMenuItem(
                        leading: Icon(
                          size: 18,
                          value?.name == torrentInfo.category || (torrentInfo.category == '' && value?.name == '未分类')
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: shadColorScheme.foreground,
                        ),
                        onPressed: () => controller.controlTorrents(
                          command: 'set_category',
                          hashes: [torrentInfo.infohashV1!],
                          category: value.name != '未分类' ? value.name! : '',
                        ),
                        child: Text(value!.name!),
                      )),
                ],
                child: Text('分类'),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.tag_outlined,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ...controller.tags.where((item) => item != '全部').map((value) => ShadContextMenuItem(
                        leading: Icon(
                          size: 18,
                          torrentInfo.tags?.contains(value) == true
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: shadColorScheme.foreground,
                        ),
                        onPressed: () => controller.controlTorrents(
                          command: torrentInfo.tags!.contains(value) == true ? 'add_tags' : 'remove_tags',
                          hashes: [torrentInfo.infohashV1!],
                          tag: value,
                        ),
                        child: Text(value),
                      ))
                ],
                child: Text('标签'),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.copy_rounded,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 18,
                      Icons.copy_rounded,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text('名称'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.name!));
                      Get.snackbar('复制种子名称', '种子名称复制成功！', colorText: shadColorScheme.foreground);
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 18,
                      Icons.copy_rounded,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text('哈希'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.infohashV1!));
                      Get.snackbar('复制种子HASH', '种子HASH复制成功！', colorText: shadColorScheme.foreground);
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 18,
                      Icons.copy_rounded,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text('磁力链接'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.magnetUri!));
                      Get.snackbar('复制种子磁力链接', '种子磁力链接复制成功！', colorText: shadColorScheme.foreground);
                    },
                  ),
                  // ShadContextMenuItem(
                  //   child: Text('Torrent ID'),
                  //   onPressed: () {},
                  // ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 18,
                      Icons.copy_rounded,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text('Tracker 地址'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.tracker!));
                      Get.snackbar('复制种子Tracker', '种子Tracker复制成功！', colorText: shadColorScheme.foreground);
                    },
                  ),
                  // ShadContextMenuItem(
                  //   leading: Icon(
                  //     size: 18,
                  //     Icons.copy_rounded,
                  //     color: shadColorScheme.foreground,
                  //   ),
                  //   child: Text('注释'),
                  //   onPressed: () {
                  //     Clipboard.setData(ClipboardData(text: torrentInfo.comment!));
                  //     Get.snackbar('复制种子注释', '种子注释复制成功！', colorText: shadColorScheme.foreground);
                  //   },
                  // ),
                ],
                child: Text('复制'),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  torrentInfo.autoTmm == true ? Icons.check_box_outlined : Icons.motion_photos_auto_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('自动管理'),
                onPressed: () => controller.controlTorrents(
                    command: 'set_auto_management', hashes: [torrentInfo.infohashV1!], enable: !torrentInfo.autoTmm!),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.upload_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('限制上传速度'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.mobile_screen_share,
                  color: shadColorScheme.foreground,
                ),
                child: Text('限制分享率'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  torrentInfo.superSeeding == true
                      ? Icons.keyboard_double_arrow_up_outlined
                      : Icons.keyboard_arrow_up_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('超级做种'),
                onPressed: () => controller.controlTorrents(
                    command: 'set_super_seeding',
                    hashes: [torrentInfo.infohashV1!],
                    enable: !torrentInfo.superSeeding!),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.fact_check,
                  color: shadColorScheme.foreground,
                ),
                child: Text('重新校验'),
                onPressed: () => Get.defaultDialog(
                  title: '',
                  middleText: '重新校验种子？',
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
                        // 重新校验种子
                        Get.back(result: true);
                        await controller.controlTorrents(
                          command: 'recheck',
                          hashes: [torrentInfo.infohashV1!],
                        );
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.announcement_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text('重新汇报'),
                onPressed: () => controller.controlTorrents(command: 'reannounce', hashes: [torrentInfo.infohashV1!]),
              ),

              ShadContextMenuItem(
                leading: Icon(
                  size: 18,
                  Icons.import_export,
                  color: shadColorScheme.foreground,
                ),
                child: Text('导出.torrent'),
                onPressed: () {},
              ),
            ],
            child: InkWell(
              onTap: () {
                _openTorrentInfoDetail(torrentInfo, context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Row(children: [
                          torrentInfo.tracker!.isNotEmpty
                              ? CustomTextTag(
                                  labelText: controller.trackers.entries
                                          .firstWhereOrNull((entry) => entry.value.contains(torrentInfo.hash))
                                          ?.key ??
                                      '未知',
                                  icon: Icon(Icons.file_upload_outlined, size: 10, color: shadColorScheme.foreground),
                                )
                              : CustomTextTag(
                                  labelText: controller.trackers.entries
                                      .firstWhere((entry) => entry.value.contains(torrentInfo.hash))
                                      .key,
                                  icon: Icon(Icons.link_off, size: 10, color: shadColorScheme.foreground),
                                  backgroundColor: Colors.red,
                                ),
                          const SizedBox(width: 10),
                        ]),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FileSizeConvert.parseToFileSize(torrentInfo.size),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: shadColorScheme.foreground,
                                ),
                              ),
                              Text(
                                controller.qBitStatus
                                    .firstWhere((element) => element.value == torrentInfo.state!,
                                        orElse: () => MetaDataItem(name: "未知状态", value: TorrentState.unknown))
                                    .name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: shadColorScheme.foreground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 255,
                          child: Tooltip(
                            message: torrentInfo.name!,
                            child: Text(
                              torrentInfo.name!,
                              style: TextStyle(
                                fontSize: 11,
                                color: shadColorScheme.foreground,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Text(
                          torrentInfo.category!.isNotEmpty ? torrentInfo.category! : '未分类',
                          style: TextStyle(
                            fontSize: 10,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.upload,
                                    size: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.upSpeed),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: shadColorScheme.foreground,
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.cloud_upload,
                                    size: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.uploaded),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: shadColorScheme.foreground,
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.download,
                                    size: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.dlSpeed),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: shadColorScheme.foreground,
                                      ))
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.cloud_download,
                                    size: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.downloaded),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: shadColorScheme.foreground,
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 128,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 12,
                                  ),
                                  EllipsisText(
                                    text: formatDuration(torrentInfo.timeActive!).toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: shadColorScheme.foreground,
                                    ),
                                    maxLines: 1,
                                    ellipsis: '...',
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                  EllipsisText(
                                    text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                        .format(DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedOn! * 1000))
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: shadColorScheme.foreground,
                                    ),
                                    maxLines: 1,
                                    ellipsis: '...',
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                      // width: 100,
                      child: ShadProgress(
                        value: torrentInfo.progress!,
                        color: ShadTheme.of(context).colorScheme.primary,
                        backgroundColor: ShadTheme.of(context).colorScheme.background,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openTorrentInfoDetail(TorrentInfo torrentInfo, context) async {
    if (controller.showDetails) {
      return;
    }
    controller.showDetails = true;
    controller.selectedTorrent = torrentInfo;
    controller.showDetailsLoading = true;
    controller.update();
    List<TorrentContents> contents = await controller.client.torrents.getContents(hash: torrentInfo.infohashV1!);
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    // TorrentProperties prop =
    //     await controller.client.torrents.getProperties(hash: controller.selectedTorrent.hash!);
    List<Tracker> selectedTorrentTrackers = await controller.client.torrents.getTrackers(hash: torrentInfo.infohashV1!);
    controller.showDetailsLoading = false;
    controller.update();
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      CustomCard(
        height: MediaQuery.of(context).size.height * 0.9,
        color: shadColorScheme.background,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: GetBuilder<QBittorrentController>(
            // id: '${downloader.host} - ${downloader.port} - ${controller.selectedTorrent.hash} - details',
            builder: (controller) {
          List<Tracker> trackers =
              selectedTorrentTrackers.where((Tracker element) => element.url?.startsWith('http') ?? false).toList();
          var repeatTorrents = controller.torrents
              .where((element) => element.contentPath == controller.selectedTorrent?.contentPath)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller.trackers.entries.firstWhere((entry) => entry.value.contains(e.infohashV1)).key,
                    "value": e,
                  }))
              .map((e) => InputChip(
                    labelPadding: EdgeInsets.zero,
                    backgroundColor: e.value.tracker.isNotEmpty ? shadColorScheme.primary : shadColorScheme.destructive,
                    deleteIconColor: e.value.tracker.isNotEmpty
                        ? shadColorScheme.primaryForeground
                        : shadColorScheme.destructiveForeground,
                    elevation: 1,
                    deleteButtonTooltipMessage: '删除种子',
                    label: SizedBox(
                      width: 52,
                      child: Center(
                        child: Text(
                          e.name,
                          style: TextStyle(
                            color: e.value.tracker.isNotEmpty
                                ? shadColorScheme.primaryForeground
                                : shadColorScheme.destructiveForeground,
                          ),
                        ),
                      ),
                    ),
                    avatar: e.value.tracker.isNotEmpty
                        ? Icon(Icons.link, color: shadColorScheme.primaryForeground)
                        : Icon(Icons.link_off, color: shadColorScheme.destructiveForeground),
                    // onPressed: () async {
                    // },
                    onDeleted: () async {
                      RxBool deleteFiles = false.obs;
                      Get.defaultDialog(
                        title: '确认',
                        radius: 10,
                        titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        middleText: '您确定要执行这个操作吗？',
                        backgroundColor: shadColorScheme.background,
                        content: Obx(() {
                          return ShadSwitch(
                            value: deleteFiles.value,
                            onChanged: (v) => deleteFiles.value = v,
                            label: const Text('是否删除种子文件？'),
                          );
                        }),
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
                              await controller.controlTorrents(
                                  command: 'delete', hashes: [e.value.hash], enable: false);

                              controller.showTorrents.removeWhere((element) => element.hash == e.value.hash);
                              controller.update();
                            },
                            child: const Text('删除'),
                          )
                        ],
                      );
                    },
                  ))
              .toList();

          return ShadTabs(
            value: controller.selectTab,
            padding: EdgeInsets.zero,
            tabBarConstraints: const BoxConstraints(maxWidth: 600, maxHeight: 40),
            contentConstraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            tabs: [
              ShadTab(
                value: 'torrentInfo',
                onPressed: () {
                  controller.selectTab = 'torrentInfo';
                },
                content: ListView(
                  children: [
                    CustomCard(
                      color: shadColorScheme.background,
                      child: ListTile(
                        dense: true,
                        title: Tooltip(
                          message: controller.selectedTorrent?.contentPath ?? '',
                          child: Text(
                            controller.selectedTorrent?.contentPath ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        leading: Text('资源路径'),
                        trailing: Text(torrentInfo.category ?? '未分类'),
                      ),
                    ),
                    CustomCard(
                      color: shadColorScheme.background,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '已上传: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.uploaded)}',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '上传速度: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.upSpeed)}/S',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '上传限速: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.upLimit)}/S',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '已下载: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.downloaded)}',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                          if ((torrentInfo.progress ?? 0) < 1) ...[
                            ShadBadge(
                              backgroundColor: Colors.transparent,
                              child: Text(
                                '下载速度: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.dlSpeed)}',
                                style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                              ),
                            ),
                            ShadBadge(
                              backgroundColor: Colors.transparent,
                              child: Text(
                                '下载限速: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent?.dlLimit)}',
                                style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                              ),
                            ),
                          ],
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '分享率: ${controller.selectedTorrent?.ratio?.toStringAsFixed(2)}',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                          ShadBadge(
                            backgroundColor: Colors.transparent,
                            child: Text(
                              '分享率限制: ${controller.selectedTorrent?.ratioLimit}',
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...trackers.map((Tracker e) => CustomCard(
                              color: shadColorScheme.background,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Tooltip(
                                        message: e.url.toString(),
                                        child: InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(text: e.url.toString()));
                                          },
                                          child: CustomTextTag(
                                            backgroundColor: shadColorScheme.foreground,
                                            labelColor: shadColorScheme.background,
                                            labelText: controller.mySiteController.webSiteList.values
                                                    .firstWhereOrNull(
                                                      (element) =>
                                                          element.tracker.contains(Uri.parse(e.url.toString()).host),
                                                    )
                                                    ?.name ??
                                                Uri.parse(e.url.toString()).host,
                                          ),
                                        ),
                                      ),
                                      CustomTextTag(
                                          backgroundColor: Colors.transparent,
                                          labelColor: shadColorScheme.foreground,
                                          icon: const Icon(Icons.download_done, size: 10, color: Colors.white),
                                          labelText: '完成：${e.numDownloaded! > 0 ? e.numDownloaded.toString() : '0'}'),
                                      CustomTextTag(
                                          backgroundColor: Colors.transparent,
                                          labelColor: shadColorScheme.foreground,
                                          icon: const Icon(Icons.download_outlined, size: 10, color: Colors.white),
                                          labelText: '下载：${e.numLeeches.toString()}'),
                                      CustomTextTag(
                                          backgroundColor: Colors.transparent,
                                          labelColor: shadColorScheme.foreground,
                                          icon: const Icon(Icons.insert_link, size: 10, color: Colors.white),
                                          labelText: '连接：${e.numPeers.toString()}'),
                                      CustomTextTag(
                                          backgroundColor: Colors.transparent,
                                          labelColor: shadColorScheme.foreground,
                                          icon: const Icon(Icons.cloud_upload_outlined, size: 10, color: Colors.white),
                                          labelText: '做种：${e.numSeeds.toString()}'),
                                    ],
                                  ),
                                  if (e.msg != null && e.msg!.isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextTag(
                                            backgroundColor: e.status == TrackerStatus.working
                                                ? Colors.transparent
                                                : shadColorScheme.destructiveForeground,
                                            labelColor: e.status == TrackerStatus.working
                                                ? shadColorScheme.foreground
                                                : shadColorScheme.destructive,
                                            labelText: controller.qbTrackerStatus
                                                    .firstWhereOrNull((element) => element.value == e.status)
                                                    ?.name ??
                                                '未知'),
                                        CustomTextTag(
                                          backgroundColor: shadColorScheme.destructive,
                                          labelColor: shadColorScheme.destructiveForeground,
                                          icon: Icon(
                                            Icons.message_outlined,
                                            size: 10,
                                            color: shadColorScheme.background,
                                          ),
                                          labelText: e.msg.toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                child: const Text('种子信息'),
              ),
              ShadTab(
                  value: 'files',
                  onPressed: () {
                    controller.selectTab = 'files';
                  },
                  content: QBittorrentTreeView(contents),
                  child: const Text('文件列表')),
              ShadTab(
                value: 'repeatInfo',
                onPressed: () {
                  controller.selectTab = 'repeatInfo';
                },
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (repeatTorrents.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: repeatTorrents,
                                ),
                              ],
                            )),
                    ],
                  ),
                ),
                child: const Text('辅种信息'),
              ),
            ],
          );
        }),
      ),
    ).whenComplete(() {
      controller.selectTab = 'torrentInfo';
      controller.showDetails = false;
    });
  }
}
