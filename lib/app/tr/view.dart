import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:intl/intl.dart';

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
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: '请输入搜索关键字',
                                    hintStyle: const TextStyle(fontSize: 14),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 5),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      // 不绘制边框
                                      borderRadius: BorderRadius.circular(0.0),
                                      // 确保角落没有圆角
                                      gapPadding: 0.0, // 移除边框与hintText之间的间距
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        width: 1.0,
                                      ),
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
                                  TransmissionBaseTorrent torrentInfo =
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
                          textColor: Theme.of(context).colorScheme.onBackground,
                          dividerColor:
                              Theme.of(context).colorScheme.onBackground,
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
                          textColor: Theme.of(context).colorScheme.onBackground,
                          dividerColor:
                              Theme.of(context).colorScheme.onBackground,
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
                            textColor:
                                Theme.of(context).colorScheme.onBackground,
                            dividerColor:
                                Theme.of(context).colorScheme.onBackground,
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
                                      '${state.name}(${controller.torrents.where((TransmissionBaseTorrent torrent) => state.value != null ? torrent.status == state.value : true).toList().length})',
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
                          // ListTile(
                          //   title: Text(
                          //     '活动中(${controller.torrents.where((torrent) => [
                          //           trTorrentState.downloading,
                          //           trTorrentState.uploading,
                          //           trTorrentState.checkingUP,
                          //           trTorrentState.forcedUP,
                          //           trTorrentState.moving,
                          //         ].contains(torrent.state)).toList().length})',
                          //   ),
                          //   style: ListTileStyle.list,
                          //   selected: controller.torrentFilter ==
                          //       TorrentFilter.active,
                          //   selectedColor:
                          //       Theme.of(context).colorScheme.primary,
                          //   onTap: () {
                          //     Get.back();
                          //     controller.trTorrentState = null;
                          //     controller.torrentFilter = TorrentFilter.active;
                          //     controller.subTorrentList();
                          //     controller.update();
                          //   },
                          // ),
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
                          textColor: Theme.of(context).colorScheme.onBackground,
                          dividerColor:
                              Theme.of(context).colorScheme.onBackground,
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
                          await controller.toggleSpeedLimit();
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
                          textColor: Theme.of(context).colorScheme.onBackground,
                          dividerColor:
                              Theme.of(context).colorScheme.onBackground,
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

  Widget _buildTrTorrentCard(TransmissionBaseTorrent torrentInfo, context) {
    bool deleteFile = false;
    LoggerHelper.Logger.instance
        .i('${torrentInfo.error} - ${torrentInfo.errorString}');
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
                  Get.defaultDialog(
                    title: '确认',
                    backgroundColor: Colors.white54,
                    radius: 5,
                    titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple),
                    middleText: '确定要删除种子吗？',
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatefulBuilder(builder: (context, setInnerState) {
                          return GFCheckbox(
                            size: 18,
                            activeBgColor: GFColors.DANGER,
                            onChanged: (value) {
                              setInnerState(() => deleteFile = value);
                            },
                            value: deleteFile,
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
                      ElevatedButton(
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTorrents(
                              command: 'delete',
                              hashes: [torrentInfo.hashString],
                              deleteFiles: deleteFile);
                        },
                        child: const Text('确认'),
                      ),
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
                Get.snackbar('单击', '单击！',
                    colorText: Theme.of(context).colorScheme.primary);
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
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
                                        .onBackground),
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
                                          .onBackground),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
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
                              color:
                                  Theme.of(context).colorScheme.onBackground),
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
                                        .onBackground),
                                Text(filesize(torrentInfo.rateUpload),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground))
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.cloud_upload,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                Text(filesize(torrentInfo.uploadedEver),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground))
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
                                        .onBackground),
                                Text(filesize(torrentInfo.rateDownload),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground))
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.cloud_download,
                                    size: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground),
                                Text(filesize(torrentInfo.downloadedEver),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground))
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                ),
                                EllipsisText(
                                  text: formatDuration(torrentInfo.activityDate)
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
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
                                          .onBackground),
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
                              color:
                                  Theme.of(context).colorScheme.onBackground),
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
}
