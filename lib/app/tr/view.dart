import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:intl/intl.dart';
import 'package:random_color/random_color.dart';

import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../common/form_widgets.dart';
import '../../models/common_response.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/storage.dart';
import '../home/pages/agg_search/download_form.dart';
import '../torrent/models/transmission_base_torrent.dart';
import 'controller.dart';

class TrPage extends StatelessWidget {
  const TrPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchKeyController = TextEditingController();

    return GetBuilder<TrController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${controller.downloader.name} - ${controller.torrents.length}'),
        ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        child: GetBuilder<TrController>(builder: (controller) {
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    suffixIcon: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                              '计数：${controller.showTorrents.length}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.orange)),
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
                                      borderRadius: BorderRadius.circular(0.0),
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
                                IconButton(
                                    onPressed: () {
                                      if (searchKeyController.text.isNotEmpty) {
                                        searchKeyController.text =
                                            searchKeyController.text.substring(
                                                0,
                                                searchKeyController
                                                        .text.length -
                                                    1);
                                        controller.searchKey =
                                            searchKeyController.text;
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
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                itemCount: controller.showTorrents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  TrTorrent torrentInfo =
                                      controller.showTorrents[index];
                                  return _buildTrTorrentCard(
                                      torrentInfo, context);
                                }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 70),
              ],
            )),
        endDrawer: _buildGfDrawer(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildActionButtons(context),
      );
    });
  }

  _buildGfDrawer(BuildContext context) {}

  Widget _buildActionButtons(context) {
    return GetBuilder<TrController>(builder: (controller) {
      return CustomCard(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(
                Icons.sort_by_alpha,
                size: 18,
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  // 按钮形状
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                Get.bottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        GFTypography(
                          text: '种子排序',
                          icon: const Icon(Icons.sort_by_alpha),
                          dividerWidth: 108,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          dividerColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(
                          height: 400,
                          child:
                              GetBuilder<TrController>(builder: (controller) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.trSortOptions.length,
                                itemBuilder: (context, index) {
                                  MetaDataItem item =
                                      controller.trSortOptions[index];
                                  bool isSelected =
                                      controller.sortKey == item.value;
                                  return ListTile(
                                    title: Text(
                                      item.name,
                                    ),
                                    style: ListTileStyle.list,
                                    trailing: Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                    ),
                                    selected: isSelected,
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    selectedTileColor: Colors.amber,
                                    onTap: () async {
                                      Get.back();
                                      controller.sortReversed =
                                          controller.sortKey == item.value
                                              ? !controller.sortReversed
                                              : false;
                                      controller.sortKey = item.value;
                                      SPUtil.setLocalStorage(
                                          '${controller.downloader.host}:${controller.downloader.port}-sortKey',
                                          controller.sortKey);
                                      controller.sortTorrents();
                                      controller.update();
                                      await controller.getAllTorrents();
                                    },
                                  );
                                });
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.category_outlined,
                size: 18,
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  // 按钮形状
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                Get.bottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        GFTypography(
                          text: '种子分类',
                          icon: const Icon(Icons.category),
                          dividerWidth: 108,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          dividerColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        SizedBox(
                          height: 400,
                          child:
                              GetBuilder<TrController>(builder: (controller) {
                            List<String> keys =
                                controller.categoryMap.keys.toList();
                            keys.remove('全部');
                            keys.sort();
                            keys.insert(0, '全部');

                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: keys.length,
                                itemBuilder: (context, index) {
                                  String c = keys[index];
                                  String? category = controller.categoryMap[c];
                                  int count = 0;
                                  if (category == '全部') {
                                    count = controller.torrents.length;
                                  } else {
                                    count = controller.torrents
                                        .where((torrent) =>
                                            torrent.downloadDir.contains(
                                                category.toString()) ==
                                            true)
                                        .toList()
                                        .length;
                                  }
                                  return ListTile(
                                    title: Text(
                                      '$c($count)',
                                    ),
                                    subtitle:
                                        c != '全部' ? Text(category!) : null,
                                    selected: controller.category == category,
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () {
                                      Get.back();
                                      controller.category = category!;
                                      controller.filterTorrents();
                                    },
                                  );
                                });
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 18,
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                Get.bottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: GetBuilder<TrController>(builder: (controller) {
                      return Column(
                        children: [
                          GFTypography(
                            text: '种子状态',
                            icon: const Icon(Icons.info),
                            dividerWidth: 108,
                            textColor: Theme.of(context).colorScheme.onSurface,
                            dividerColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          SizedBox(
                            height: 340,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.trStatus.length,
                                itemBuilder: (context, index) {
                                  MetaDataItem state =
                                      controller.trStatus[index];
                                  return ListTile(
                                    title: Text(
                                      '${state.name}(${controller.torrents.where((TrTorrent torrent) => state.value != null ? state.value == 99 ? torrent.error > 0 : torrent.status == state.value : true).toList().length})',
                                    ),
                                    style: ListTileStyle.list,
                                    selected: controller.trTorrentState ==
                                        state.value,
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () async {
                                      Get.back();
                                      controller.trTorrentState = state.value;
                                      controller.filterTorrents();
                                      controller.update();
                                      await controller.getAllTorrents();
                                    },
                                  );
                                }),
                          ),
                          ListTile(
                            title: Text(
                              '活动中(${controller.torrents.where((torrent) => torrent.rateUpload > 0 || torrent.rateDownload > 0).toList().length})',
                            ),
                            style: ListTileStyle.list,
                            selected: controller.trTorrentState == 100,
                            selectedColor:
                                Theme.of(context).colorScheme.primary,
                            onTap: () {
                              Get.back();
                              controller.trTorrentState = 100;
                              controller.filterTorrents();
                              controller.update();
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.language,
                size: 18,
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  // 按钮形状
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                TextEditingController searchKey = TextEditingController();
                Get.bottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        GFTypography(
                          text: '站点筛选',
                          icon: const Icon(Icons.language),
                          dividerWidth: 108,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          dividerColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        CustomTextField(
                          controller: searchKey,
                          labelText: '筛选',
                          onChanged: (String value) {
                            searchKey.text = value;
                            controller.update();
                          },
                        ),
                        SizedBox(
                          height: 400,
                          child:
                              GetBuilder<TrController>(builder: (controller) {
                            List<String> keys = controller.trackers.keys
                                .where((element) => element
                                    .toLowerCase()
                                    .contains(searchKey.text.toLowerCase()))
                                .toList();
                            keys.sort((a, b) =>
                                a.toLowerCase().compareTo(b.toLowerCase()));
                            keys.insert(0, '全部');
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: keys.length,
                                itemBuilder: (context, index) {
                                  String? key = keys[index];
                                  List<String>? hashList;
                                  if (key == '全部') {
                                    hashList = controller.torrents
                                        .map((e) => e.hashString)
                                        .toList();
                                  } else {
                                    hashList = controller.trackers[key];
                                  }
                                  return ListTile(
                                    title: Text(
                                      '${controller.trackerToWebSiteMap[controller.trackerToWebSiteMap.keys.firstWhereOrNull((String element) => element.contains(key))]?.name ?? key.trim()}(${hashList?.length})',
                                    ),
                                    style: ListTileStyle.list,
                                    selected: controller.selectedTracker == key,
                                    selectedColor:
                                        Theme.of(context).colorScheme.primary,
                                    onTap: () async {
                                      Get.back();
                                      controller.trTorrentState = null;

                                      controller.selectedTracker = key;
                                      controller.filterTorrents();
                                      controller.update();
                                    },
                                  );
                                });
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            CustomPopup(
                showArrow: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                barrierColor: Colors.transparent,
                content: SizedBox(
                  width: 100,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuItem<String>(
                        child: Text(
                          '清除红种',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onTap: () async {
                          CommonResponse res =
                              await controller.removeErrorTracker();
                          Get.snackbar('清理红种', res.msg!,
                              colorText: res.code == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error);
                          await controller.getAllTorrents();
                          controller.update();
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Text(
                          '切换限速',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onTap: () async {
                          CommonResponse res =
                              await controller.toggleSpeedLimit();
                          if (res.code == 0) {
                            Get.snackbar('限速切换成功', res.msg!,
                                colorText:
                                    Theme.of(context).colorScheme.primary);
                          } else {
                            Get.snackbar('限速切换失败', res.msg!,
                                colorText: Theme.of(context).colorScheme.error);
                          }
                        },
                      ),
                      // PopupMenuItem<String>(
                      //   child: Text(
                      //     'PTPP',
                      //     style: TextStyle(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //     ),
                      //   ),
                      //   onTap: () async {
                      //     await importFromPTPP();
                      //   },
                      // ),
                      // PopupMenuItem<String>(
                      //   child: Text(
                      //     'CC 同步',
                      //     style: TextStyle(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //     ),
                      //   ),
                      //   onTap: () async {
                      //     await importFromCookieCloud();
                      //   },
                      // ),
                      // PopupMenuItem<String>(
                      //   child: Text(
                      //     '清除缓存',
                      //     style: TextStyle(
                      //       color: Theme.of(context).colorScheme.secondary,
                      //     ),
                      //   ),
                      //   onTap: () async {
                      //     CommonResponse res = await clearMyCacheApi();
                      //     Get.snackbar(
                      //       '清除缓存',
                      //       '清除缓存：${res.msg}',colorText: Theme.of(context).colorScheme.primary
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.settings,
                  size: 18,
                )),
            IconButton(
              icon: const Icon(
                Icons.add,
                size: 18,
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  // 按钮形状
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onPressed: () {
                Get.bottomSheet(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  enableDrag: true,
                  CustomCard(
                    height: 400,
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GFTypography(
                          text: '添加种子',
                          icon: const Icon(Icons.add),
                          dividerWidth: 108,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          dividerColor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Expanded(
                        child: DownloadForm(
                          categories: controller.categoryMap.values.fold({},
                              (map, element) {
                            map[element] = element;
                            return map;
                          }),
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
      );
    });
  }

  Widget _buildTrTorrentCard(TrTorrent torrentInfo, context) {
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
                onPressed: (context) async {
                  await _removeTorrent(torrentInfo);
                },
                flex: 2,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              ),
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    middleText: '您确定要执行这个操作吗？',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                              command:
                                  torrentInfo.status == 0 ? 'resume' : 'pause',
                              hashes: [torrentInfo.hashString]);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                backgroundColor: torrentInfo.status == 0
                    ? const Color(0xFF0392CF)
                    : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: torrentInfo.status == 0 ? Icons.play_arrow : Icons.pause,
                label: torrentInfo.status == 0 ? '继续' : '暂停',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    backgroundColor: Colors.white54,
                    radius: 5,
                    titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple),
                    middleText: '确定要重新校验种子吗？',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                            command: 'recheck',
                            hashes: [torrentInfo.hashString],
                          );
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                flex: 2,
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                icon: Icons.checklist,
                label: '校验',
              ),
              SlidableAction(
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    middleText: '您确定要执行这个操作吗？',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                              command: 'reannounce',
                              hashes: [torrentInfo.hashString]);
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
          child: InkWell(
              onTap: () {
                _openTorrentInfoDetail(torrentInfo, context);
              },
              // onLongPress: () {
              //   Get.snackbar('长按', '长按！',colorText: Theme.of(context).colorScheme.primary);
              // },
              // onDoubleTap: () {
              //   Get.snackbar('双击', '双击！',colorText: Theme.of(context).colorScheme.primary);
              // },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (torrentInfo.trackerStats.isNotEmpty)
                          Row(children: [
                            const Icon(
                              Icons.link,
                              size: 10,
                            ),
                            Text(
                              controller
                                      .trackerToWebSiteMap[controller
                                          .trackerToWebSiteMap.keys
                                          .firstWhereOrNull((String element) =>
                                              element.contains(Uri.parse(
                                                      torrentInfo.trackerStats
                                                          .first!.announce)
                                                  .host))]
                                      ?.name ??
                                  Uri.parse(torrentInfo
                                          .trackerStats.first!.announce)
                                      .host,
                              style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(width: 10),
                          ]),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                filesize(torrentInfo.totalSize),
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              SizedBox(
                                height: 12,
                                child: Text(
                                  controller.trStatus
                                      .firstWhere(
                                          (element) =>
                                              element.value ==
                                              torrentInfo.status,
                                          orElse: () => MetaDataItem(
                                              name: "未知状态", value: null))
                                      .name,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
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
                          width: 220,
                          child: Tooltip(
                            message: torrentInfo.name,
                            child: Text(
                              torrentInfo.name,
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Text(
                          torrentInfo.downloadDir.isNotEmpty
                              ? torrentInfo.downloadDir
                              : '未分类',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.upload,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                Text(filesize(torrentInfo.rateUpload),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.cloud_upload,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                Text(filesize(torrentInfo.uploadedEver),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.download,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                Text(filesize(torrentInfo.rateDownload),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.cloud_download,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                Text(filesize(torrentInfo.downloadedEver),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface))
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer,
                                  size: 12,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                EllipsisText(
                                  text: formatDuration(torrentInfo.activityDate)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
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
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                EllipsisText(
                                  text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              torrentInfo.addedDate * 1000))
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  maxLines: 1,
                                  ellipsis: '...',
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    GFProgressBar(
                        margin: EdgeInsets.zero,
                        percentage: torrentInfo.percentDone.toDouble(),
                        progressHeadType: GFProgressHeadType.square,
                        trailing: Text(
                          '${(torrentInfo.percentDone * 100).toStringAsFixed(2)}%',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onSurface),
                          textAlign: TextAlign.center,
                        ),
                        alignment: MainAxisAlignment.center,
                        progressBarColor: Colors.green),
                    if (torrentInfo.error > 0)
                      EllipsisText(
                        text:
                            '${torrentInfo.error} - ${torrentInfo.errorString}',
                        ellipsis: '...',
                        maxLines: 1,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 10,
                        ),
                      )
                  ],
                ),
              )),
        ),
      );
    });
  }

  void _openTorrentInfoDetail(TrTorrent torrentInfo, context) async {
    LoggerHelper.Logger.instance.i(torrentInfo.files);

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
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: GetBuilder<TrController>(builder: (controller) {
          var repeatTorrents = controller.torrents
              .where((element) => element.name == torrentInfo.name)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller
                            .trackerToWebSiteMap[controller.trackers.entries
                                .firstWhere((entry) =>
                                    entry.value.contains(e.hashString))
                                .key]
                            ?.name ??
                        controller.trackers.entries
                            .firstWhere(
                                (entry) => entry.value.contains(e.hashString))
                            .key,
                    "value": e,
                  }))
              .map((e) => Tooltip(
                    message: e.value.error > 0
                        ? '${Uri.parse(e.value.trackerStats[0].announce).host} 错误信息： ${e.value.errorString}'
                        : Uri.parse(e.value.trackerStats[0].announce).host,
                    child: InputChip(
                      labelPadding: EdgeInsets.zero,
                      backgroundColor: RandomColor().randomColor(
                          colorHue: ColorHue.orange,
                          colorBrightness: ColorBrightness.dark),
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
                        _removeTorrent(e.value);
                      },
                    ),
                  ))
              .toList();
          const List<Tab> tabs = [
            Tab(text: '种子信息'),
            Tab(text: '文件信息'),
            Tab(text: '辅种信息'),
          ];
          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('种子详情'),
                bottom: const TabBar(tabs: tabs),
              ),
              body: TabBarView(
                children: [
                  ListView(
                    children: [
                      Wrap(
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
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: GFProgressBar(
                                margin: EdgeInsets.zero,
                                percentage: torrentInfo.percentDone.toDouble(),
                                lineHeight: 12,
                                progressHeadType: GFProgressHeadType.square,
                                progressBarColor: GFColors.SUCCESS,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '${torrentInfo.percentDone * 100}%',
                                      style: const TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: torrentInfo.status
                                          .toString()
                                          .contains('pause') ||
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
                                style: TextStyle(
                                    fontSize: 8,
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          // CustomCard(
                          //   child: ListTile(
                          //     dense: true,
                          //     title: Text(
                          //       torrentInfo.downloadDir,
                          //       style: const TextStyle(fontSize: 12),
                          //     ),
                          //     subtitle: Tooltip(
                          //       message: torrentInfo.downloadDir,
                          //       child: Text(
                          //         torrentInfo.downloadDir!,
                          //         style: const TextStyle(
                          //             overflow: TextOverflow.ellipsis),
                          //       ),
                          //     ),
                          //     leading: const Icon(Icons.category_outlined),
                          //     trailing: CustomPopup(
                          //       showArrow: false,
                          //       backgroundColor:
                          //           Theme.of(context).colorScheme.background,
                          //       barrierColor: Colors.transparent,
                          //       content: SingleChildScrollView(
                          //         child: Column(
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: controller.categoryMap.values
                          //               .map((value) => PopupMenuItem(
                          //                     child: ListTile(
                          //                       title: Text(value),
                          //                       subtitle: Text(
                          //                           value.savePath.toString()),
                          //                     ),
                          //                   ))
                          //               .toList(),
                          //         ),
                          //       ),
                          //       child: const Icon(
                          //           Icons.swap_horizontal_circle_outlined),
                          //     ),
                          //   ),
                          // ),

                          CustomCard(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            child: Wrap(
                              spacing: 18,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                GFButton(
                                  text: '重新校验',
                                  color: GFColors.DANGER,
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: '',
                                      middleText: '重新校验种子？',
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.back(result: false);
                                          },
                                          child: const Text('取消'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            Get.back(result: true);
                                            await controller.controlTorrents(
                                                command: 'recheck',
                                                hashes: [
                                                  torrentInfo.hashString
                                                ]);
                                            Get.back();
                                            controller.update();
                                          },
                                          child: const Text('确认'),
                                        ),
                                      ],
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.announcement_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                GFButton(
                                  text: '强制汇报',
                                  color: GFColors.SUCCESS,
                                  onPressed: () async {
                                    await controller.controlTorrents(
                                        command: 'reannounce',
                                        hashes: [torrentInfo.hashString]);
                                    Get.back();
                                  },
                                  icon: const Icon(
                                    Icons.campaign,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                GFButton(
                                  text: '复制哈希',
                                  color: GFColors.SECONDARY,
                                  onPressed: () async {
                                    Clipboard.setData(ClipboardData(
                                        text: torrentInfo.hashString));
                                    Get.snackbar('复制种子HASH', '种子HASH复制成功！',
                                        colorText: Theme.of(context)
                                            .colorScheme
                                            .primary);
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
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
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '做种时间',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        formatDuration(torrentInfo.doneDate),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
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
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '大小',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        filesize(torrentInfo.totalSize),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCard(
                                  color: RandomColor().randomColor(
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '已上传',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        filesize(torrentInfo.uploadedEver),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCard(
                                  color: RandomColor().randomColor(
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '上传速度',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        '${filesize(torrentInfo.rateUpload)}/S',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCard(
                                  color: RandomColor().randomColor(
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '上传限速',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        '${filesize(torrentInfo.rateUpload)}/S',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCard(
                                  color: RandomColor().randomColor(
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '已下载',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        filesize(torrentInfo.downloadedEver),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomCard(
                                  color: RandomColor().randomColor(
                                      colorHue: ColorHue.green,
                                      colorBrightness: ColorBrightness.primary),
                                  width: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '分享率',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        torrentInfo.uploadRatio
                                            .toStringAsFixed(2),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
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
                          //             '已完成: ${filesize(torrentInfo.completed)}',
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
                          //           '剩余大小: ${filesize(torrentInfo.amountLeft)}',
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
                    ],
                  ),
                  TreeView(torrentInfo.files),
                  ListView(
                    children: [
                      Center(child: Text('Tracker数量：${repeatTorrents.length}')),
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<void> _removeTorrent(TrTorrent torrentInfo) async {
    final deleteFile = false.obs;

    Get.defaultDialog(
      title: '确认',
      backgroundColor: Colors.white54,
      radius: 5,
      titleStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
      middleText: '确定要删除种子吗？',
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return GFCheckbox(
              size: 18,
              activeBgColor: GFColors.DANGER,
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
        ElevatedButton(
          onPressed: () {
            Get.back(result: false);
          },
          child: const Text('取消'),
        ),
        GetBuilder<TrController>(builder: (controller) {
          return ElevatedButton(
            onPressed: () async {
              Get.back(result: true);
              await controller.controlTorrents(
                  command: 'delete',
                  hashes: [torrentInfo.hashString],
                  deleteFiles: deleteFile.value);
            },
            child: const Text('确认'),
          );
        }),
      ],
    );
  }
}

class TreeNode {
  String name;
  Map<String, TreeNode> children;
  TorrentFile? content;

  TreeNode(this.name)
      : children = {},
        content = null;

  @override
  String toString() => name;
}

void printTree(TreeNode node, String indent) {
  LoggerHelper.Logger.instance.i(indent + node.name);
  for (var child in node.children.values) {
    printTree(child, '$indent  ');
  }
}

class TreeView extends StatelessWidget {
  final List<TorrentFile> contents;

  const TreeView(this.contents, {super.key});

  @override
  Widget build(BuildContext context) {
    List<TreeNode> nodes = generateTreeNodes(contents);
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        TreeNode node = nodes[index];
        return _buildTreeTile(node, 0);
      },
    );
  }

  List<TreeNode> generateTreeNodes(List<TorrentFile> contents) {
    Map<String, TreeNode> nodesMap = {};

    for (TorrentFile content in contents) {
      List<String> filePathParts = content.name.split('/');
      TreeNode currentNode = nodesMap.putIfAbsent(
          filePathParts.first, () => TreeNode(filePathParts.first));
      for (int i = 1; i < filePathParts.length; i++) {
        String part = filePathParts[i];
        if (currentNode.children.containsKey(part)) {
          currentNode = currentNode.children[part]!;
        } else {
          TreeNode newNode = TreeNode(part);
          currentNode.children[part] = newNode;
          currentNode = newNode;
        }
      }
      if (currentNode.children.isEmpty) {
        currentNode.content = content; // 只有叶子节点才赋值 content
      }
    }

    return nodesMap.values.toList();
  }

  Widget _buildTreeTile(TreeNode node, int level) {
    EdgeInsetsGeometry padding = EdgeInsets.only(left: level * 16.0);
    if (node.content != null) {
      return ListTile(
        // contentPadding: padding,
        leading: const Icon(Icons.file_copy_sharp),
        dense: true,
        title: Text(
          node.name,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextTag(
              labelText: filesize(node.content!.length),
              icon: const Icon(Icons.download_done,
                  size: 10, color: Colors.white),
            ),
            CustomTextTag(
                icon: const Icon(Icons.download_outlined,
                    size: 10, color: Colors.white),
                labelText: (node.content!.bytesCompleted / node.content!.length)
                    .toStringAsFixed(2)),
          ],
        ),
        // 添加其他内容字段
      );
    }
    return ExpansionTile(
      childrenPadding: padding,
      dense: true,
      leading: const Icon(
        Icons.folder,
        color: Colors.deepOrangeAccent,
      ),
      key: PageStorageKey<String>(node.name),
      title: Text(
        node.name,
        overflow: TextOverflow.ellipsis,
      ),
      children: [
        ...node.children.values
            .map((child) => _buildTreeTile(child, level + 1)),
      ],
    );
  }
}
