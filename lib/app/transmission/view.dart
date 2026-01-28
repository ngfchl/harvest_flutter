import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:random_color/random_color.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../common/form_widgets.dart';
import '../../models/common_response.dart';
import '../../theme/background_container.dart';
import '../../theme/color_storage.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/storage.dart';
import '../../utils/string_utils.dart';
import '../home/pages/download/download_form.dart';
import '../home/pages/download/tr_tree_file_view.dart';
import '../home/pages/models/transmission_base_torrent.dart';
import 'controller.dart';

class TrPage extends StatelessWidget {
  const TrPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchKeyController = TextEditingController();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    return GetBuilder<TrController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          Get.defaultDialog(
            backgroundColor: shadColorScheme.background,
            title: "退出",
            content: Text(
              '确定要退出  Transmission 吗？',
              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            ),
            middleTextStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            titleStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
            radius: 10,
            cancel: ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
              child: const Text('取消'),
            ),
            confirm: ShadButton.destructive(
              size: ShadButtonSize.sm,
              onPressed: () async {
                controller.timerToStop();
                Navigator.of(context).pop(false);
                Get.back();
              },
              child: const Text('确定'),
            ),
            textCancel: '退出',
            textConfirm: '取消',
          );
        },
        child: BackgroundContainer(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: shadColorScheme.background,
              title: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '${controller.downloader.name} - ${controller.torrentCount}',
                        style: TextStyle(color: shadColorScheme.foreground),
                      ),
                    ),
                  ),
                  if (controller.trStats != null)
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextTag(
                              icon: Icon(
                                Icons.keyboard_arrow_up_outlined,
                                color: Colors.green,
                                size: 14,
                              ),
                              mainAxisAlignment: MainAxisAlignment.start,
                              backgroundColor: Colors.transparent,
                              labelColor: Colors.green,
                              labelText:
                                  "${FileSizeConvert.parseToFileSize(controller.trStats?.uploadSpeed)}/s[${FileSizeConvert.parseToFileSize((controller.prefs?.speedLimitUp ?? 0) * 1024)}]"),
                          CustomTextTag(
                              icon: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: shadColorScheme.destructive,
                                size: 14,
                              ),
                              mainAxisAlignment: MainAxisAlignment.start,
                              backgroundColor: Colors.transparent,
                              labelColor: shadColorScheme.destructive,
                              labelText:
                                  "${FileSizeConvert.parseToFileSize(controller.trStats?.downloadSpeed)}/s[${FileSizeConvert.parseToFileSize((controller.prefs?.speedLimitDown ?? 0) * 1024)}]"),
                        ],
                      ),
                    ),
                ],
              ),
              foregroundColor: shadColorScheme.foreground,
            ),
            backgroundColor: Colors.transparent,
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
                          CustomCard(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: GetBuilder<TrController>(builder: (controller) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: searchKeyController,
                                      textAlignVertical: TextAlignVertical.center,
                                      style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: '请输入搜索关键字',
                                        hintStyle:
                                            TextStyle(fontSize: 14, color: shadColorScheme.foreground.withAlpha(122)),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                                        constraints: const BoxConstraints(maxHeight: 30),
                                        suffixIcon: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Text('计数：${controller.showTorrents.length}',
                                                  style: TextStyle(fontSize: 12, color: shadColorScheme.primary)),
                                            ),
                                          ],
                                        ),
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
                                          borderRadius: BorderRadius.circular(5.0),
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
                                  if (controller.torrentCount > controller.torrents.length)
                                    SizedBox(
                                        height: 14,
                                        width: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: shadColorScheme.foreground,
                                        )),
                                  if (controller.searchKey.isNotEmpty)
                                    ShadIconButton.ghost(
                                        onPressed: () {
                                          if (searchKeyController.text.isNotEmpty) {
                                            searchKeyController.text = searchKeyController.text
                                                .substring(0, searchKeyController.text.length - 1);
                                            controller.searchKey = searchKeyController.text;
                                            controller.filterTorrents();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.backspace_outlined,
                                          size: 13,
                                        ))
                                ],
                              );
                            }),
                          ),
                          Expanded(
                            child: controller.isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: shadColorScheme.foreground,
                                  ))
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    itemCount: controller.showTorrents.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      TrTorrent torrentInfo = controller.showTorrents[index];
                                      return RepaintBoundary(child: _buildTrTorrentCard(torrentInfo, context));
                                    }),
                          ),
                        ],
                      ),
                    ),
                    _buildActionButtons(context),
                  ],
                )),
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            // floatingActionButton: _buildActionButtons(context),
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<TrController>(builder: (controller) {
      return CustomCard(
        padding: const EdgeInsets.all(0),
        width: double.infinity,
        child: Center(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [
              InkWell(
                onTap: () {
                  logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                  controller.sortReversed = !controller.sortReversed;
                  controller.filterTorrents();
                  logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                },
                child: CustomTextTag(
                  fontSize: 12,
                  icon: controller.sortReversed
                      ? Icon(
                          Icons.sim_card_download_outlined,
                          size: 13,
                          color: shadColorScheme.foreground,
                        )
                      : Icon(
                          Icons.upload_file_outlined,
                          size: 13,
                          color: shadColorScheme.foreground,
                        ),
                  labelText: controller.sortReversed ? '「正序」' : '「倒序」',
                  labelColor: shadColorScheme.foreground,
                  backgroundColor: Colors.transparent,
                ),
              ),
              GetBuilder<TrController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.trSortOptions
                            .map((item) => PopupMenuItem<String>(
                                  height: 32,
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: shadColorScheme.foreground,
                                      fontSize: 12,
                                    ),
                                  ),
                                  onTap: () async {
                                    logger_helper.Logger.instance
                                        .d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                                    controller.sortKey = item.value;
                                    logger_helper.Logger.instance.d('当前排序字段: ${controller.sortKey}');
                                    SPUtil.setLocalStorage(
                                        '${controller.downloader.externalHost}-sortKey-DIRECT', controller.sortKey);
                                  },
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  child: CustomTextTag(
                    fontSize: 12,
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.sort_by_alpha_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText:
                        '【${controller.trSortOptions.firstWhereOrNull((item) => item.value == controller.sortKey)?.name ?? "无"}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                );
              }),
              GetBuilder<TrController>(builder: (controller) {
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
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedLabel = null;
                              controller.showTorrents.clear();
                              controller.filterTorrents();
                            },
                          ),
                          ...controller.labels.map((item) => PopupMenuItem<String>(
                                height: 32,
                                child: Text(
                                  '$item[${controller.torrents.where((element) => element.labels.contains(item)).length}]',
                                  style: TextStyle(
                                    color: shadColorScheme.foreground,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () async {
                                  controller.selectedLabel = item;
                                  controller.filterTorrents();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: CustomTextTag(
                    fontSize: 12,
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.tag,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText: '【${controller.selectedLabel ?? "全部"}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                );
              }),
              GetBuilder<TrController>(builder: (controller) {
                TextEditingController searchKey = TextEditingController();
                List<String> keys = controller.trackerHashes.keys
                    .where((element) => element.toLowerCase().contains(searchKey.text.toLowerCase()))
                    .toList();
                keys.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('站点筛选', style: TextStyle(color: shadColorScheme.foreground)),
                          CustomTextField(
                            controller: searchKey,
                            labelText: '筛选',
                            onChanged: (String value) {
                              // searchKey.text = value;
                              controller.update();
                            },
                          ),
                          PopupMenuItem<String>(
                            height: 32,
                            child: Text(
                              '全部[${controller.torrents.length}]',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedTracker = '全部';
                              controller.showTorrents.clear();
                              controller.filterTorrents();
                            },
                          ),
                          PopupMenuItem<String>(
                            height: 32,
                            child: Text(
                              '红种[${controller.torrents.where((element) => element.error == 2).toList().length}]',
                              style: TextStyle(
                                color: shadColorScheme.destructive,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              controller.selectedTracker = '红种';
                              controller.filterTorrents();
                            },
                          ),
                          ...keys.map((item) => PopupMenuItem<String>(
                                height: 32,
                                child: Text(
                                  '$item[${controller.trackerHashes[item]?.toSet().length ?? 0}]',
                                  style: TextStyle(
                                    color: shadColorScheme.foreground,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () async {
                                  controller.selectedTracker = item;
                                  controller.filterTorrents();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: CustomTextTag(
                    fontSize: 12,
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.language_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText: controller.trackerToWebSiteMap[controller.selectedTracker]?.name ??
                        controller.selectedTracker?.trim() ??
                        "未知",
                    labelColor: shadColorScheme.foreground,
                  ),
                );
              }),
              GetBuilder<TrController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 180,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(
                              "全部[${controller.torrents.length}]",
                            ),
                            style: ListTileStyle.list,
                            titleTextStyle: TextStyle(
                              color: shadColorScheme.foreground,
                              fontSize: 12,
                            ),
                            selected: controller.selectedCategory == '全部',
                            selectedColor: shadColorScheme.destructive,
                            selectedTileColor: Colors.amber,
                            onTap: () {
                              Get.back();
                              controller.selectedCategory = '全部';

                              controller.showTorrents.clear();

                              controller.filterTorrents();
                            },
                          ),
                          ...controller.categoryMap.values.map((item) => ListTile(
                                dense: true,
                                title: Text(
                                  "${item.name}[${controller.torrents.where((torrent) => torrent.downloadDir.contains(item.savePath!.substring(0, item.savePath!.length - 1))).toList().length}]",
                                ),
                                style: ListTileStyle.list,
                                titleTextStyle: TextStyle(
                                  color: shadColorScheme.foreground,
                                  fontSize: 12,
                                ),
                                selected: controller.selectedCategory == item.name,
                                selectedColor: shadColorScheme.destructive,
                                selectedTileColor: Colors.amber,
                                onTap: () {
                                  Get.back();
                                  controller.selectedCategory = item.name!;
                                  controller.filterTorrents();
                                },
                              )),
                        ],
                      ),
                    ),
                  ),
                  child: CustomTextTag(
                    fontSize: 12,
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
                );
              }),
              GetBuilder<TrController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  backgroundColor: shadColorScheme.background,
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: controller.trStatus.map((state) {
                          var torrentsMatchingState = [];
                          if (state.value == 'all') {
                            torrentsMatchingState = controller.torrents;
                          } else if (state.value == 'active') {
                            torrentsMatchingState = controller.torrents
                                .where((torrent) =>
                                    [
                                      4,
                                      2,
                                    ].contains(torrent.status) ||
                                    (torrent.rateDownload + torrent.rateUpload) > 0)
                                .toList();
                          } else {
                            torrentsMatchingState = controller.torrents
                                .where((torrent) => state.value != null ? torrent.status == state.value : true)
                                .toList();
                          }
                          return PopupMenuItem(
                            child: Text(
                              '${state.name}(${torrentsMatchingState.length})',
                              style: TextStyle(
                                color: shadColorScheme.foreground,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              // Get.back();
                              logger_helper.Logger.instance.d("状态筛选...${state.name}");
                              controller.trTorrentState = state.value;
                              controller.filterTorrents();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  child: CustomTextTag(
                    fontSize: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    icon: Icon(
                      Icons.info_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    backgroundColor: Colors.transparent,
                    labelText:
                        '【${controller.trStatus.firstWhereOrNull((item) => item.value == controller.trTorrentState)?.name ?? "全部"}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                );
              }),
              GetBuilder<TrController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  contentDecoration: BoxDecoration(
                    color: shadColorScheme.background,
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            dense: true,
                            title: Text(
                              '全部【${controller.torrents.length}】',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            selected: controller.selectedError == '',
                            selectedColor: shadColorScheme.foreground,
                            onTap: () {
                              Get.back();
                              controller.selectedError = '';
                              controller.filterTorrents();
                            },
                          ),
                          ListTile(
                            dense: true,
                            title: Text(
                              '错误【${controller.torrents.where((torrent) => torrent.errorString.isNotEmpty || torrent.trackerList?.isEmpty == true).length}】',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            selected: controller.selectedError == '错误',
                            selectedColor: shadColorScheme.destructive,
                            onTap: () {
                              Get.back();
                              controller.selectedError = '错误';
                              controller.filterTorrents();
                            },
                          ),
                          ...controller.errors.map((error) {
                            int count;
                            if (error == 'NoTracker') {
                              count = controller.torrents
                                  .where((torrent) => torrent.trackerList?.isEmpty == true)
                                  .toList()
                                  .length;
                            } else {
                              count = controller.torrents
                                  .where((torrent) => torrent.errorString.contains(error))
                                  .toList()
                                  .length;
                            }
                            bool selected = controller.selectedError == error;
                            return ListTile(
                              dense: true,
                              title: Text(
                                '$error($count)',
                              ),
                              titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                              selected: selected,
                              selectedColor: shadColorScheme.destructive,
                              onTap: () {
                                Get.back();
                                controller.selectedError = error;
                                controller.filterTorrents();
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  child: Tooltip(
                    message: controller.selectedError == ''
                        ? '全部种子【${controller.torrents.length}】'
                        : '错误筛选【${controller.selectedError}】',
                    child: CustomTextTag(
                      fontSize: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      icon: Icon(
                        Icons.warning_amber_outlined,
                        size: 13,
                        color:
                            controller.selectedError == '' ? shadColorScheme.foreground : shadColorScheme.destructive,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor:
                          controller.selectedError == '' ? shadColorScheme.foreground : shadColorScheme.destructive,
                      labelText: controller.selectedError == '' ? '全部' : '错误',
                    ),
                  ),
                );
              }),
              CustomPopup(
                backgroundColor: shadColorScheme.background,
                content: SizedBox(
                  width: 80,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuItem(
                          onTap: () {
                            controller.selectedTorrents.addAll(controller.showTorrents.map((t) => t.hashString));
                            controller.selectedTorrents = controller.selectedTorrents.toSet().toList();
                            controller.update();
                          },
                          child: Text('全选', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () {
                            List<String> temp = controller.showTorrents
                                .where((t) => !controller.selectedTorrents.contains(t.hashString))
                                .map((t) => t.hashString)
                                .toSet()
                                .toList();
                            controller.selectedTorrents.clear();
                            controller.selectedTorrents.addAll(temp);
                            controller.update();
                          },
                          child: Text('反选', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () => _removeTorrent(controller.selectedTorrents, context),
                          child: Text('删除', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await controller.controlTorrents(
                                command: 'torrentReannounce', ids: controller.selectedTorrents);
                            controller.selectedTorrents.clear();
                            controller.getAllTorrents();
                          },
                          child: Text('汇报', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await controller.controlTorrents(
                                command: 'torrentStartNow', ids: controller.selectedTorrents);
                            controller.selectedTorrents.clear();
                            controller.getAllTorrents();
                          },
                          child: Text('强制开始', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await controller.controlTorrents(command: 'torrentStart', ids: controller.selectedTorrents);
                            controller.selectedTorrents.clear();
                            controller.getAllTorrents();
                          },
                          child: Text('开始', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            await controller.controlTorrents(command: 'torrentStop', ids: controller.selectedTorrents);
                            controller.selectedTorrents.clear();
                            controller.getAllTorrents();
                          },
                          child: Text('停止', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                        ),
                        controller.selectMode
                            ? PopupMenuItem(
                                onTap: () {
                                  controller.selectMode = false;
                                  controller.selectedTorrents.clear();
                                  controller.update();
                                },
                                child: Text('取消', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                              )
                            : PopupMenuItem(
                                onTap: () {
                                  controller.selectMode = true;
                                  controller.selectedTorrents.clear();
                                  controller.update();
                                },
                                child: Text('多选', style: TextStyle(color: shadColorScheme.foreground, fontSize: 12)),
                              ),
                      ]),
                ),
                child: CustomTextTag(
                  fontSize: 12,
                  icon: Icon(
                    Icons.more_vert,
                    size: 13,
                    color: controller.selectMode ? shadColorScheme.destructive : shadColorScheme.foreground,
                  ),
                  backgroundColor: Colors.transparent,
                  labelColor: controller.selectMode ? shadColorScheme.destructive : shadColorScheme.foreground,
                  labelText: '多选${controller.selectMode ? '「${controller.selectedTorrents.length}」' : ''}',
                ),
              ),
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
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                          ),
                          onTap: () async {
                            RxBool doing = false.obs;
                            List<String> toRemoveTorrentList = [];
                            var groupedTorrents = groupBy(controller.torrents, (t) => t.name);
                            for (var group in groupedTorrents.values) {
                              group.sort((t1, t2) => t2.percentDone.compareTo(t1.percentDone));
                              toRemoveTorrentList.addAll(group
                                  .skip(1)
                                  .where((t) => t.trackerList?.isEmpty == true || t.error > 0)
                                  .map((t) => t.hashString));
                            }
                            logger_helper.Logger.instance.i(toRemoveTorrentList);
                            logger_helper.Logger.instance.i(toRemoveTorrentList.length);
                            if (toRemoveTorrentList.isEmpty) {
                              ShadToaster.of(context).show(
                                ShadToast.destructive(
                                  title: const Text('出错啦'),
                                  description: Text('没有需要清理的种子！'),
                                ),
                              );
                              return;
                            }
                            Get.defaultDialog(
                              title: '确定要清理红种吗？',
                              content: Text('将清理掉有错误或无Tracker的种子，\n所有辅种的种子都会保留最后一份。'
                                  '\n本次将清理${toRemoveTorrentList.length}个种子。'),
                              radius: 10,
                              backgroundColor: shadColorScheme.background,
                              actions: [
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: Text('取消'),
                                ),
                                ShadButton.destructive(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    doing.value = true;
                                    CommonResponse res = await controller.removeErrorTracker(toRemoveTorrentList);
                                    doing.value = false;
                                    if (res.succeed) {
                                      Get.back();
                                      ShadToaster.of(context).show(
                                        ShadToast(title: const Text('成功啦'), description: Text(res.msg)),
                                      );
                                      await controller.getAllTorrents();
                                    } else {
                                      ShadToaster.of(context).show(
                                        ShadToast.destructive(
                                          title: const Text('出错啦'),
                                          description: Text(res.msg),
                                        ),
                                      );
                                    }
                                  },
                                  leading: Obx(() => doing.value
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(color: shadColorScheme.primary))
                                      : SizedBox.shrink()),
                                  child: Text('确定'),
                                ),
                              ],
                            );
                          },
                        ),
                        PopupMenuItem<String>(
                          child: Center(
                            child: Text(
                              '切换限速',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                          ),
                          onTap: () async {
                            CommonResponse res = await controller.toggleSpeedLimit();
                            ShadToaster.of(context).show(
                              res.succeed
                                  ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                                  : ShadToast.destructive(title: const Text('出错啦'), description: Text(res.msg)),
                            );
                          },
                        ),
                        PopupMenuItem<String>(
                          child: Center(
                              child: Text(
                            '替换Tracker',
                            style: TextStyle(color: shadColorScheme.destructive),
                          )),
                          onTap: () async {
                            TextEditingController keyController = TextEditingController(text: '');
                            TextEditingController valueController = TextEditingController(text: '');
                            List<String> sites =
                                controller.trackerHashes.keys.where((e) => e != ' All' && e != ' 红种').toList();
                            sites.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                            Get.bottomSheet(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0), // 圆角半径
                              ),
                              backgroundColor: shadColorScheme.background,
                              SizedBox(
                                height: 240,
                                // width: 240,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: double.infinity),
                                        child: ShadSelect<String>(
                                            placeholder: const Text('要替换的站点'),
                                            trailing: Text('替换站点', style: TextStyle(color: shadColorScheme.foreground)),
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
                                        ShadButton.ghost(
                                          onPressed: () {
                                            Get.back(result: false);
                                          },
                                          child: const Text('取消'),
                                        ),
                                        ShadButton.destructive(
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
                                            ShadToaster.of(context).show(
                                              res.succeed
                                                  ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                                                  : ShadToast.destructive(
                                                      title: const Text('出错啦'), description: Text(res.msg)),
                                            );
                                          },
                                          leading: controller.trackerLoading
                                              ? SizedBox(
                                                  height: 18, width: 18, child: const CircularProgressIndicator())
                                              : null,
                                          child: const Text('确认'),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 13,
                    color: shadColorScheme.foreground,
                  )),
              ShadIconButton.ghost(
                icon: Icon(
                  Icons.add_outlined,
                  size: 13,
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
                          child: Text('添加种子', style: TextStyle(color: shadColorScheme.foreground)),
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

  Widget _buildTrTorrentCard(TrTorrent torrentInfo, context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final trackerHost = getTrackerHost(torrentInfo);
    return GetBuilder<TrController>(builder: (controller) {
      return CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        margin: const EdgeInsets.all(2.5),
        child: Slidable(
          key: ValueKey(torrentInfo.id.toString()),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    backgroundColor: Colors.white54,
                    radius: 5,
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                    middleText: '确定要重新校验种子吗？',
                    actions: [
                      ShadButton.ghost(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton.destructive(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                            command: 'recheck',
                            ids: [torrentInfo.hashString],
                          );
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                flex: 2,
                backgroundColor: const Color(0xFF0A9D96),
                foregroundColor: Colors.white,
                icon: Icons.checklist,
                label: '校验',
              ),
              SlidableAction(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    middleText: '您确定要执行这个操作吗？',
                    actions: [
                      ShadButton.ghost(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton.destructive(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(command: 'reannounce', ids: [torrentInfo.hashString]);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                flex: 2,
                backgroundColor: const Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.campaign,
                label: '汇报',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    middleText: '您确定要执行这个操作吗？',
                    actions: [
                      ShadButton.ghost(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton.destructive(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                              command: torrentInfo.status == 0 ? 'resume' : 'pause', ids: [torrentInfo.hashString]);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                backgroundColor: torrentInfo.status == 0 ? shadColorScheme.primary : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: torrentInfo.status == 0 ? Icons.play_arrow : Icons.pause,
                label: torrentInfo.status == 0 ? '继续' : '暂停',
              ),
              SlidableAction(
                onPressed: (context) async {
                  await _removeTorrent([torrentInfo.hashString], context);
                },
                flex: 2,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                backgroundColor: shadColorScheme.destructive,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
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
                  size: 14,
                  Icons.double_arrow_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '强制开始'),
                onPressed: () => controller.controlTorrents(
                  command: 'torrentStartNow',
                  ids: [torrentInfo.hashString],
                ),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.play_arrow_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '开始种子'),
                onPressed: () => controller.controlTorrents(
                  command: 'torrentStart',
                  ids: [torrentInfo.hashString],
                ),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.pause_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '暂停种子'),
                onPressed: () => controller.controlTorrents(
                  command: 'torrentStop',
                  ids: [torrentInfo.hashString],
                ),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.delete_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '删除种子'),
                onPressed: () {
                  RxBool deleteFiles = false.obs;
                  RxBool doDeleteWithOutOthers = true.obs;
                  Get.defaultDialog(
                    title: '确认',
                    radius: 5,
                    middleText: '您确定要执行这个操作吗？',
                    content: Obx(() {
                      return Column(
                        children: [
                          SwitchTile(
                              title: '删除种子文件？',
                              value: deleteFiles.value,
                              onChanged: (value) {
                                deleteFiles.value = value;
                              }),
                          SwitchTile(
                              title: '无其他站点保种删除数据？',
                              value: doDeleteWithOutOthers.value,
                              onChanged: (value) {
                                doDeleteWithOutOthers.value = value;
                              }),
                        ],
                      );
                    }),
                    actions: [
                      ShadButton.ghost(
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
                          // 判断尤其其他站点做种
                          if (doDeleteWithOutOthers.value) {
                            // 删除其他站点的种子数据
                            deleteFiles.value = controller.torrents.map((t) => t.hashString).isEmpty;
                          }
                          var res = await controller.controlTorrents(
                              command: 'torrentRemove', enable: deleteFiles.value, ids: [torrentInfo.hashString]);
                          // if (res.succeed) {
                          controller.showTorrents
                              .removeWhere((element) => element.hashString == torrentInfo.hashString);
                          controller.update();
                          // }
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 5),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.checklist_rtl_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '重新校验'),
                onPressed: () => Get.defaultDialog(
                  title: '确认',
                  backgroundColor: shadColorScheme.background,
                  radius: 5,
                  middleText: '确定要重新校验种子吗？',
                  actions: [
                    ShadButton.ghost(
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
                        await controller.controlTorrents(
                          command: 'torrentVerify',
                          ids: [torrentInfo.hashString],
                        );
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.announcement_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '重新汇报'),
                onPressed: () =>
                    controller.controlTorrents(command: 'torrentReannounce', ids: [torrentInfo.hashString]),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.folder_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '修改目录'),
                onPressed: () {
                  RxBool changeDataDir = false.obs;
                  TextEditingController newPathController = TextEditingController(text: torrentInfo.downloadDir);
                  Get.defaultDialog(
                    title: '修改目录',
                    radius: 5,
                    backgroundColor: shadColorScheme.background,
                    contentPadding: EdgeInsets.all(16),
                    content: Obx(() {
                      return Column(
                        spacing: 8.0,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '当前种子：${torrentInfo.name}',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          CustomTextField(
                            controller: newPathController,
                            labelText: '新目录',
                          ),
                          SwitchTile(
                              title: '同时移动数据？',
                              subtitle: '不勾选则从新目录下查找文件数据',
                              value: changeDataDir.value,
                              onChanged: (value) {
                                changeDataDir.value = value;
                              }),
                        ],
                      );
                    }),
                    actions: [
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton.destructive(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'torrentSetLocation',
                              ids: [torrentInfo.hashString],
                              location: torrentInfo.downloadDir,
                              enable: changeDataDir.value);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
              ),
              const Divider(height: 8),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.copy_rounded,
                  color: shadColorScheme.foreground,
                ),
                trailing: Icon(
                  size: 14,
                  Icons.keyboard_arrow_right_outlined,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.file_copy_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '复制名称'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.name));
                      ShadToaster.of(context).show(
                        ShadToast(title: const Text('成功啦'), description: Text('种子名称复制成功！')),
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.copy_rounded,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '复制哈希'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.hashString));
                      ShadToaster.of(context).show(
                        ShadToast(title: const Text('成功啦'), description: Text('种子HASH复制成功！')),
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.folder_copy_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '复制路径'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text:
                              '${torrentInfo.downloadDir.endsWith('/') ? torrentInfo.downloadDir : '${torrentInfo.downloadDir}/'}${torrentInfo.name}'));
                      ShadToaster.of(context).show(
                        ShadToast(title: const Text('成功啦'), description: Text('种子路径复制成功！')),
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.content_copy_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '复制磁力'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: torrentInfo.magnetLink));
                      ShadToaster.of(context).show(
                        ShadToast(title: const Text('成功啦'), description: Text('种子磁力链接复制成功！')),
                      );
                    },
                  ),
                ],
                child: Text(style: TextStyle(fontSize: 12), '复制'),
              ),
              const Divider(height: 8),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.view_list_outlined,
                  color: shadColorScheme.foreground,
                ),
                trailing: Icon(
                  size: 14,
                  Icons.keyboard_arrow_right_outlined,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列顶部'),
                    onPressed: () async {
                      var response = await controller.controlTorrents(
                        command: 'queueMoveTop',
                        ids: [torrentInfo.hashString],
                      );
                      logger_helper.Logger.instance.i(response);
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列向上'),
                    onPressed: () async {
                      var response = await controller.controlTorrents(
                        command: 'queueMoveUp',
                        ids: [torrentInfo.hashString],
                      );
                      logger_helper.Logger.instance.i(response);
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列向下'),
                    onPressed: () async {
                      var response = await controller.controlTorrents(
                        command: 'queueMoveDown',
                        ids: [torrentInfo.hashString],
                      );
                      logger_helper.Logger.instance.i(response);
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列底部'),
                    onPressed: () async {
                      var response = await controller.controlTorrents(
                        command: 'queueMoveBottom',
                        ids: [torrentInfo.hashString],
                      );
                      logger_helper.Logger.instance.i(response);
                    },
                  ),
                ],
                child: Text(style: TextStyle(fontSize: 12), '队列'),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.tag_outlined,
                  color: shadColorScheme.foreground,
                ),
                trailing: Icon(
                  size: 14,
                  Icons.keyboard_arrow_right_outlined,
                  color: shadColorScheme.foreground,
                ),
                items: [
                  ...controller.labels.map((label) => ShadContextMenuItem(
                        leading: Icon(
                          size: 14,
                          torrentInfo.labels.contains(label) == true
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: shadColorScheme.foreground,
                        ),
                        onPressed: () async {
                          List<String> labels = torrentInfo.labels;
                          labels.contains(label) == true ? labels.remove(label) : labels.add(label);
                          logger_helper.Logger.instance.d('设置标签中...$labels');

                          var response = await controller.controlTorrents(
                            command: 'torrentSetLabels',
                            ids: [torrentInfo.hashString],
                            labels: labels,
                          );
                          logger_helper.Logger.instance.i(response);
                        },
                        child: Text(style: TextStyle(fontSize: 12), label),
                      ))
                ],
                child: Text(style: TextStyle(fontSize: 12), '标签'),
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.language_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '修改Tracker'),
                onPressed: () {
                  logger_helper.Logger.instance.d(torrentInfo.trackerList);
                  TextEditingController trackerController = TextEditingController(
                      text: torrentInfo.trackerStats.map((tracker) => tracker.announce).join('\n'));
                  Get.defaultDialog(
                    title: '修改Tracker',
                    radius: 5,
                    backgroundColor: shadColorScheme.background,
                    contentPadding: EdgeInsets.all(16),
                    content: Column(
                      spacing: 8.0,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '当前种子：${torrentInfo.name}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        CustomTextField(
                          controller: trackerController,
                          labelText: 'Tracker地址',
                          maxLines: 5,
                        ),
                      ],
                    ),
                    actions: [
                      ShadButton.ghost(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton.destructive(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          var response = await controller.controlTorrents(
                            command: 'torrentSetTrackerList',
                            ids: [torrentInfo.hashString],
                            trackerList: trackerController.text,
                          );
                          logger_helper.Logger.instance.i(response);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
              ),
              // ShadContextMenuItem(
              //   leading: Icon(
              //     size: 14,
              //     Icons.speed_outlined,
              //     color: shadColorScheme.foreground,
              //   ),
              //   child: Text(style: TextStyle(fontSize: 12), '设置限速'),
              //   onPressed: () {},
              // ),
            ],
            child: InkWell(
                onTap: () {
                  _openTorrentInfoDetail(torrentInfo, context);
                },
                onDoubleTap: () {
                  controller.selectMode = !controller.selectMode;
                  controller.selectedTorrents.clear();
                  controller.update();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    spacing: 8.0,
                    children: [
                      if (controller.selectMode)
                        ShadCheckbox(
                          value: controller.selectedTorrents.contains(torrentInfo.hashString),
                          onChanged: (v) {
                            if (v == true) {
                              controller.selectedTorrents.add(torrentInfo.hashString);
                            } else {
                              controller.selectedTorrents.remove(torrentInfo.hashString);
                            }
                            controller.update();
                            logger_helper.Logger.instance.i('选中的种子：${controller.selectedTorrents.length}');
                          },
                        ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                torrentInfo.trackerStats.isNotEmpty
                                    ? CustomTextTag(
                                        labelText: controller
                                                .trackerToWebSiteMap[controller.trackerToWebSiteMap.keys
                                                    .firstWhereOrNull(
                                                        (String element) => element.contains(trackerHost))]
                                                ?.name ??
                                            trackerHost,
                                        icon: const Icon(
                                          Icons.link_outlined,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      )
                                    : CustomTextTag(
                                        labelText: trackerHost,
                                        backgroundColor: shadColorScheme.destructive,
                                        icon: Icon(
                                          Icons.link_off_outlined,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        FileSizeConvert.parseToFileSize(torrentInfo.totalSize),
                                        style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                                      ),
                                      SizedBox(
                                        height: 12,
                                        child: Text(
                                          controller.trStatus
                                              .firstWhere((element) => element.value == torrentInfo.status,
                                                  orElse: () => MetaDataItem(name: "未知状态", value: null))
                                              .name,
                                          style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                  width: 235,
                                  child: Tooltip(
                                    message: torrentInfo.name,
                                    child: Text(
                                      torrentInfo.name,
                                      style: TextStyle(
                                          fontSize: 11, color: shadColorScheme.foreground, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                                Text(
                                  torrentInfo.downloadDir.isNotEmpty ? torrentInfo.downloadDir : '未分类',
                                  style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                          Icon(Icons.upload, size: 12, color: shadColorScheme.foreground),
                                          Text(FileSizeConvert.parseToFileSize(torrentInfo.rateUpload),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.cloud_upload, size: 12, color: shadColorScheme.foreground),
                                          Text(FileSizeConvert.parseToFileSize(torrentInfo.uploadedEver),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                          Icon(Icons.download, size: 12, color: shadColorScheme.foreground),
                                          Text(FileSizeConvert.parseToFileSize(torrentInfo.rateDownload),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.cloud_download, size: 12, color: shadColorScheme.foreground),
                                          Text(FileSizeConvert.parseToFileSize(torrentInfo.downloadedEver),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                          Icon(
                                            Icons.timer,
                                            size: 12,
                                            color: shadColorScheme.foreground,
                                          ),
                                          EllipsisText(
                                            text: formatDuration(torrentInfo.activityDate).toString(),
                                            style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                                .format(
                                                    DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedDate * 1000))
                                                .toString(),
                                            style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: SizedBox(
                                height: 4,
                                // width: 100,
                                child: ShadProgress(
                                  value: torrentInfo.percentDone.toDouble(),
                                  color: shadColorScheme.primary,
                                  backgroundColor: shadColorScheme.background,
                                ),
                              ),
                            ),
                            if (torrentInfo.error > 0)
                              EllipsisText(
                                text: '${torrentInfo.error} - ${torrentInfo.errorString}',
                                ellipsis: '...',
                                maxLines: 1,
                                style: TextStyle(
                                  color: shadColorScheme.destructive,
                                  fontSize: 10,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      );
    });
  }

  void _openTorrentInfoDetail(TrTorrent torrentInfo, context) async {
    logger_helper.Logger.instance.i(torrentInfo.files);
    logger_helper.Logger.instance.i(torrentInfo.trackerList?.isEmpty);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      backgroundColor: shadColorScheme.background,
      isScrollControlled: true,
      enableDrag: true,
      Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(torrentInfo.name, style: TextStyle(fontSize: 16, color: shadColorScheme.foreground)),
            Text(torrentInfo.error.toString(), style: TextStyle(fontSize: 16, color: shadColorScheme.foreground)),
            Expanded(
              child: GetBuilder<TrController>(builder: (controller) {
                var repeatTorrents = controller.torrents.where((element) => element.name == torrentInfo.name).map((e) {
                  final entry =
                      controller.trackers.entries.firstWhereOrNull((entry) => entry.value.contains(e.hashString));

                  String name;
                  if (entry == null) {
                    name = "Unknown";
                  } else {
                    name = controller.trackerToWebSiteMap[entry.key]?.name ?? entry.key;
                  }

                  return MetaDataItem.fromJson({
                    "name": name,
                    "value": e,
                  });
                }).map((e) {
                  final trackerHost = getTrackerHost(e.value);
                  return Tooltip(
                    message: e.value.error > 0 ? '$trackerHost 错误信息：${e.value.errorString ?? "未知错误"}' : trackerHost,
                    child: InputChip(
                      labelPadding: EdgeInsets.zero,
                      backgroundColor:
                          RandomColor().randomColor(colorHue: ColorHue.orange, colorBrightness: ColorBrightness.dark),
                      shadowColor: Colors.orangeAccent,
                      elevation: 3,
                      label: SizedBox(
                        width: 52,
                        child: Text(
                          e.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      avatar: e.value.error == 0
                          ? const Icon(Icons.link, color: Colors.green)
                          : const Icon(Icons.link_off, color: Colors.red),
                      onPressed: () {
                        _openTorrentInfoDetail(e.value, context);
                      },
                      onDeleted: () {
                        _removeTorrent([e.value.hashString], context);
                      },
                    ),
                  );
                }).toList();
                return ShadAccordion<String>.multiple(
                  initialValue: [
                    'torrentInfo',
                    'repeatInfo',
                  ],
                  maintainState: true,
                  children: [
                    ShadAccordionItem<String>(
                      value: 'torrentInfo',
                      title: Center(child: const Text('种子信息')),
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Wrap(
                          runSpacing: 4,
                          spacing: 12,
                          children: [
                            CustomCard(
                              child: ListTile(
                                dense: true,
                                title: Tooltip(
                                  message: torrentInfo.name,
                                  child: Text(
                                    torrentInfo.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold, color: shadColorScheme.foreground),
                                  ),
                                ),
                                subtitle: SizedBox(
                                  height: 8,
                                  // width: 100,
                                  child: ShadProgress(
                                    value: torrentInfo.percentDone.toDouble(),
                                    color: shadColorScheme.primary,
                                    backgroundColor: shadColorScheme.background,
                                  ),
                                ),
                                trailing: torrentInfo.status.toString().contains('pause') ||
                                        torrentInfo.trackerStats.isEmpty == true
                                    ? const Icon(Icons.pause, color: Colors.red)
                                    : const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Colors.green,
                                      ),
                              ),
                            ),
                            if (torrentInfo.error > 0)
                              Center(
                                child: Text(
                                  torrentInfo.errorString,
                                  style: TextStyle(fontSize: 8, color: shadColorScheme.destructive),
                                ),
                              ),
                            CustomCard(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              child: Wrap(
                                alignment: WrapAlignment.spaceAround,
                                children: [
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '做种时间',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          formatDuration(torrentInfo.doneDate),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // CustomCard(
                                  //   color: RandomColor().randomColor(
                                  //       colorHue: ColorHue.green,
                                  //       colorBrightness: ColorBrightness.primary),
                                  //   width: 100,
                                  //   child: Column(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       const Text(
                                  //         '状态',
                                  //         style: TextStyle(
                                  //             color: Colors.white, fontSize: 12),
                                  //       ),
                                  //       Text(
                                  //         controller.status
                                  //             .firstWhere(
                                  //               (element) =>
                                  //                   element.value ==
                                  //                   torrentInfo.state!,
                                  //               orElse: () => MetaDataItem(
                                  //                 name: "未知状态",
                                  //                 value: TorrentState.unknown,
                                  //               ),
                                  //             )
                                  //             .name,
                                  //         style: const TextStyle(
                                  //             color: Colors.white, fontSize: 12),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '大小',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          FileSizeConvert.parseToFileSize(torrentInfo.totalSize),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '已上传',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          FileSizeConvert.parseToFileSize(torrentInfo.uploadedEver),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '上传速度',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          '${FileSizeConvert.parseToFileSize(torrentInfo.rateUpload)}/S',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '上传限速',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          '${FileSizeConvert.parseToFileSize(torrentInfo.rateUpload)}/S',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '已下载',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          FileSizeConvert.parseToFileSize(torrentInfo.downloadedEver),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  CustomCard(
                                    color: RandomColor().randomColor(
                                        colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          '分享率',
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                        Text(
                                          torrentInfo.uploadRatio.toStringAsFixed(2),
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // CustomCard(
                                  //   color: RandomColor().randomColor(
                                  //       colorHue: ColorHue.green,
                                  //       colorBrightness: ColorBrightness.primary),
                                  //   width: 100,
                                  //   child: Column(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       const Text(
                                  //         '分享率限制',
                                  //         style: TextStyle(
                                  //             color: Colors.white, fontSize: 12),
                                  //       ),
                                  //       Text(
                                  //         '${torrentInfo.uploadRatio}',
                                  //         style: const TextStyle(
                                  //             color: Colors.white, fontSize: 14),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),

                            // CustomCard(
                            //     padding: const EdgeInsets.all(8),
                            //     child: Column(
                            //       mainAxisAlignment:
                            //           MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         ...trackers.map((Tracker e) => Padding(
                            //               padding: const EdgeInsets.all(8.0),
                            //               child: Column(
                            //                 children: [
                            //                   Row(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment
                            //                             .spaceBetween,
                            //                     children: [
                            //                       Tooltip(
                            //                         message: e.url.toString(),
                            //                         child: CustomTextTag(
                            //                           backgroundColor:
                            //                               Theme.of(context)
                            //                                   .colorScheme
                            //                                   .primary,
                            //                           labelText: controller
                            //                                   .mySiteController
                            //                                   .webSiteList
                            //                                   .values
                            //                                   .firstWhereOrNull(
                            //                                     (element) => element
                            //                                         .tracker
                            //                                         .contains(Uri.parse(e
                            //                                                 .url
                            //                                                 .toString())
                            //                                             .host),
                            //                                   )
                            //                                   ?.name ??
                            //                               Uri.parse(e.url
                            //                                       .toString())
                            //                                   .host,
                            //                         ),
                            //                       ),
                            //                       CustomTextTag(
                            //                           backgroundColor:
                            //                               Theme.of(context)
                            //                                   .colorScheme
                            //                                   .scrim,
                            //                           icon: const Icon(
                            //                               Icons.download_done,
                            //                               size: 10,
                            //                               color: Colors.white),
                            //                           labelText:
                            //                               '完成：${e.numDownloaded! > 0 ? e.numDownloaded.toString() : '0'}'),
                            //                       CustomTextTag(
                            //                           backgroundColor:
                            //                               Theme.of(context)
                            //                                   .colorScheme
                            //                                   .tertiary,
                            //                           icon: const Icon(
                            //                               Icons.download_outlined,
                            //                               size: 10,
                            //                               color: Colors.white),
                            //                           labelText:
                            //                               '下载：${e.numLeeches.toString()}'),
                            //                       CustomTextTag(
                            //                           backgroundColor:
                            //                               Theme.of(context)
                            //                                   .colorScheme
                            //                                   .surfaceTint,
                            //                           icon: const Icon(
                            //                               Icons.insert_link,
                            //                               size: 10,
                            //                               color: Colors.white),
                            //                           labelText:
                            //                               '连接：${e.numPeers.toString()}'),
                            //                       CustomTextTag(
                            //                           backgroundColor:
                            //                               Theme.of(context)
                            //                                   .colorScheme
                            //                                   .secondary,
                            //                           icon: const Icon(
                            //                               Icons
                            //                                   .cloud_upload_outlined,
                            //                               size: 10,
                            //                               color: Colors.white),
                            //                           labelText:
                            //                               '做种：${e.numSeeds.toString()}'),
                            //                     ],
                            //                   ),
                            //                   const SizedBox(height: 5),
                            //                   Row(
                            //                     mainAxisAlignment:
                            //                         MainAxisAlignment
                            //                             .spaceBetween,
                            //                     children: [
                            //                       CustomTextTag(
                            //                           backgroundColor: e.status ==
                            //                                   TrackerStatus
                            //                                       .working
                            //                               ? Colors.green
                            //                               : Colors.red,
                            //                           labelText: controller
                            //                               .qbTrackerStatus
                            //                               .firstWhere((element) =>
                            //                                   element.value ==
                            //                                   e.status)
                            //                               .name),
                            //                       if (e.msg != null &&
                            //                           e.msg!.isNotEmpty)
                            //                         CustomTextTag(
                            //                           icon: const Icon(
                            //                             Icons.message_outlined,
                            //                             size: 10,
                            //                             color: Colors.white,
                            //                           ),
                            //                           labelText: e.msg.toString(),
                            //                         ),
                            //                     ],
                            //                   ),
                            //                 ],
                            //               ),
                            //             )),
                            //       ],
                            //     )),

                            // Wrap(runSpacing: 12, spacing: 12, children: [
                            // CustomTextTag(
                            //   labelText: '可用性: ${torrentInfo.availability}',
                            // ),

                            // CustomTextTag(
                            //labelText:
                            //   '文件路径: ${torrentInfo.contentPath}',
                            //
                            // ),

                            // CustomTextTag(
                            //   labelText: '下载路径: ${torrentInfo.downloadPath}',
                            // ),

                            // CustomTextTag(
                            //   labelText:
                            //       'FL Piece Prio: ${torrentInfo.fLPiecePrio}',
                            // ),

                            // CustomTextTag(
                            //labelText:
                            //   '磁力链接: ${torrentInfo.magnetUri}',
                            //
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     CustomTextTag(
                            //       labelText: '最大分享比率: ${torrentInfo.maxRatio}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText:
                            //           '最大做种时间: ${formatDuration(torrentInfo.maxSeedingTime!)}',
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     CustomTextTag(
                            //       labelText: '完成数量: ${torrentInfo.numComplete}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText:
                            //           '未完成数量: ${torrentInfo.numIncomplete}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText: '正在做种数量: ${torrentInfo.numLeechs}',
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     CustomTextTag(
                            //       labelText: '做种数量: ${torrentInfo.numSeeds}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText: '优先级: ${torrentInfo.priority}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText: '保存路径: ${torrentInfo.savePath}',
                            //     ),
                            //   ],
                            // ),

                            // CustomTextTag(
                            //   labelText: '做种时间限制: ${torrentInfo.seedingTimeLimit}',
                            // ),

                            // CustomTextTag(
                            //   labelText: 'Seq DL: ${torrentInfo.seqDl}',
                            // ),
                            // CustomTextTag(
                            //   labelText: 'HASH: ${torrentInfo.hashString}',
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     CustomTextTag(
                            //       labelText:
                            //           '添加时间: ${formatTimestampToDateTime(torrentInfo.addedOn!)}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText:
                            //           '最后完整可见：${calcDurationFromTimeStamp(torrentInfo.seenComplete!)}',
                            //     ),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     CustomTextTag(
                            //       labelText:
                            //           '耗时: ${formatDuration(torrentInfo.eta!)}',
                            //     ),
                            //     CustomTextTag(
                            //       labelText:
                            //           '最后活动时间: ${calcDurationFromTimeStamp(torrentInfo.lastActivity!)}',
                            //     ),
                            //   ],
                            // ),
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       CustomTextTag(
                            //         labelText:
                            //             '已完成: ${FileSizeConvert.parseToFileSize(torrentInfo.completed)}',
                            //       ),
                            //       CustomTextTag(
                            //         labelText:
                            //             '完成时间: ${calcDurationFromTimeStamp(torrentInfo.completionOn!)}',
                            //       ),
                            //     ],
                            //   ),
                            //   if (torrentInfo.amountLeft! > 0)
                            //     CustomTextTag(
                            //       labelText:
                            //           '剩余大小: ${FileSizeConvert.parseToFileSize(torrentInfo.amountLeft)}',
                            //     ),
                            // ]),
                            // CustomTextTag(
                            //   labelText: '标签: ${torrentInfo.tags}',
                            // ),
                            // CustomTextTag(
                            //   labelText:
                            //       '活跃时间: ${formatDuration(torrentInfo.timeActive!)}',
                            // ),
                          ],
                        ),
                      ),
                    ),
                    ShadAccordionItem<String>(
                        value: 'files',
                        title: Center(child: const Text('文件列表')),
                        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        padding: EdgeInsets.zero,
                        child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 300,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TransmissionTreeView(torrentInfo.files),
                            ))),
                    ShadAccordionItem<String>(
                      value: 'repeatInfo',
                      title: Center(child: const Text('辅种信息')),
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      padding: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            spacing: 8,
                            children: [
                              Center(
                                  child: Text(
                                'Tracker数量：${repeatTorrents.length}',
                                style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                              )),
                              if (repeatTorrents.isNotEmpty)
                                Column(
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
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String getTrackerHost(TrTorrent torrent) {
    if (torrent.trackerStats.isEmpty) {
      return "无 Tracker";
    }
    try {
      final uri = Uri.parse(torrent.trackerStats.first.announce);
      return uri.host;
    } catch (e) {
      return "无效 Tracker";
    }
  }

  Future<void> _removeTorrent(List<String> ids, BuildContext context) async {
    final deleteFile = false.obs;
    final deleteLoading = false.obs;

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
      title: '确认',
      backgroundColor: shadColorScheme.background,
      radius: 5,
      titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: shadColorScheme.foreground),
      middleText: '确定要删除「${ids.length}」个种子吗？',
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Obx(() {
            return ShadCheckbox(
              size: 13,
              onChanged: (value) {
                deleteFile.value = value;
              },
              value: deleteFile.value,
            );
          }),
          const Text('删除文件？'),
        ],
      ),
      actions: [
        ShadButton.ghost(
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text('取消'),
        ),
        GetBuilder<TrController>(builder: (controller) {
          return Obx(() {
            return ShadButton.destructive(
              leading: deleteLoading.value
                  ? SizedBox(
                      width: 18,
                      child: CircularProgressIndicator(
                        color: shadColorScheme.foreground,
                      ),
                    )
                  : null,
              onPressed: () async {
                Get.back(result: true);
                deleteLoading.value = true;
                var response =
                    await controller.controlTorrents(command: 'torrentRemove', ids: ids, deleteFiles: deleteFile.value);
                logger_helper.Logger.instance.i(response);
                if (response['result'] == 'success') {
                  controller.selectedTorrents.clear();
                  controller.getAllTorrents();
                  controller.update();
                  ShadToaster.of(context).show(
                    ShadToast(title: const Text('成功啦'), description: Text('种子已删除！')),
                  );
                } else {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('出错啦'),
                      description: Text('种子删除失败，${response['message']}'),
                    ),
                  );
                }
                deleteLoading.value = false;
              },
              child: const Text('确认'),
            );
          });
        }),
      ],
    );
  }
}
