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
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:random_color/random_color.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../common/form_widgets.dart';
import '../../models/common_response.dart';
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

    return GetBuilder<TrController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          Get.defaultDialog(
            title: "退出",
            content: Text('确定要退出 ${controller.downloader.name}？'),
            onCancel: () {
              Navigator.of(context).pop(true);
            },
            onConfirm: () {
              Navigator.of(context).pop(false);
            },
            textCancel: '退出',
            textConfirm: '取消',
          );
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${controller.downloader.name} - ${controller.torrentCount}'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                                if (controller.torrentCount > controller.torrents.length)
                                  const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()),
                                if (controller.searchKey.isNotEmpty)
                                  IconButton(
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
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  itemCount: controller.showTorrents.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    TrTorrent torrentInfo = controller.showTorrents[index];
                                    return _buildTrTorrentCard(torrentInfo, context);
                                  }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              )),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButtons(context),
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    var shadowColorScheme = ShadTheme.of(context).colorScheme;
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: shadowColorScheme.background,
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('种子排序'),
                        Expanded(
                          child: GetBuilder<TrController>(builder: (controller) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.trSortOptions.length,
                                itemBuilder: (context, index) {
                                  MetaDataItem item = controller.trSortOptions[index];
                                  bool isSelected = controller.sortKey == item.value;
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      item.name,
                                    ),
                                    style: ListTileStyle.list,
                                    trailing: Icon(
                                      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    ),
                                    selected: isSelected,
                                    onTap: () async {
                                      Get.back();
                                      controller.sortReversed =
                                          controller.sortKey == item.value ? !controller.sortReversed : false;
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: shadowColorScheme.background,
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('种子分类'),
                        Expanded(
                          child: GetBuilder<TrController>(builder: (controller) {
                            List<String> keys = controller.categoryMap.keys.toList();
                            keys.remove('全部');
                            keys.sort();
                            keys.insert(0, '全部');

                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: keys.length,
                                itemBuilder: (context, index) {
                                  String c = keys[index];
                                  Category? category = controller.categoryMap[c];
                                  int count = 0;
                                  if (category?.name == '全部') {
                                    count = controller.torrents.length;
                                  } else {
                                    count = controller.torrents
                                        .where((torrent) => torrent.downloadDir.contains(category.toString()) == true)
                                        .toList()
                                        .length;
                                  }
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '$c($count)',
                                    ),
                                    subtitle: c != '全部' ? Text(category?.name ?? '未知') : null,
                                    selected: controller.category == category?.name,
                                    selectedColor: Theme.of(context).colorScheme.primary,
                                    onTap: () {
                                      Get.back();
                                      controller.category = category?.name ?? '未知';
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: shadowColorScheme.background,
                  GetBuilder<TrController>(builder: (controller) {
                    return Column(
                      children: [
                        Text('种子状态'),
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.trStatus.length,
                              itemBuilder: (context, index) {
                                MetaDataItem state = controller.trStatus[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${state.name}(${controller.torrents.where((TrTorrent torrent) => state.value != null ? state.value == 99 ? torrent.error > 0 : torrent.status == state.value : true).toList().length})',
                                  ),
                                  style: ListTileStyle.list,
                                  selected: controller.trTorrentState == state.value,
                                  selectedColor: Theme.of(context).colorScheme.primary,
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
                          dense: true,
                          title: Text(
                            '活动中(${controller.torrents.where((torrent) => torrent.rateUpload > 0 || torrent.rateDownload > 0).toList().length})',
                          ),
                          style: ListTileStyle.list,
                          selected: controller.trTorrentState == 100,
                          selectedColor: Theme.of(context).colorScheme.primary,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: shadowColorScheme.background,
                  CustomCard(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text('站点筛选'),
                        CustomTextField(
                          controller: searchKey,
                          labelText: '筛选',
                          onChanged: (String value) {
                            // searchKey.text = value;
                            controller.update();
                          },
                        ),
                        Expanded(
                          child: GetBuilder<TrController>(builder: (controller) {
                            List<String> keys = controller.trackers.keys
                                .where((element) => element.toLowerCase().contains(searchKey.text.toLowerCase()))
                                .toList();
                            keys.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                            keys.insert(0, '全部');
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: keys.length,
                                itemBuilder: (context, index) {
                                  String? key = keys[index];
                                  List<String>? hashList;
                                  if (key == '全部') {
                                    hashList = controller.torrents.map((e) => e.hashString).toList();
                                  } else {
                                    hashList = controller.trackers[key];
                                  }
                                  return ListTile(
                                    dense: true,
                                    title: Text(
                                      '${controller.trackerToWebSiteMap[controller.trackerToWebSiteMap.keys.firstWhereOrNull((String element) => element.contains(key))]?.name ?? key.trim()}(${hashList?.length})',
                                    ),
                                    style: ListTileStyle.list,
                                    selected: controller.selectedTracker == key,
                                    selectedColor: Theme.of(context).colorScheme.primary,
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
                backgroundColor: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        onTap: () async {
                          CommonResponse res = await controller.removeErrorTracker();
                          Get.snackbar('清理红种', res.msg,
                              colorText: res.code == 0
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error);
                          await controller.getAllTorrents();
                          controller.update();
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Center(
                          child: Text(
                            '切换限速',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        onTap: () async {
                          CommonResponse res = await controller.toggleSpeedLimit();
                          if (res.code == 0) {
                            Get.snackbar('限速切换成功', res.msg, colorText: Theme.of(context).colorScheme.primary);
                          } else {
                            Get.snackbar('限速切换失败', res.msg, colorText: Theme.of(context).colorScheme.error);
                          }
                        },
                      ),
                      PopupMenuItem<String>(
                        child: Center(
                            child: Text(
                          '替换Tracker',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        )),
                        onTap: () async {
                          TextEditingController keyController = TextEditingController(text: '');
                          TextEditingController valueController = TextEditingController(text: '');
                          List<String> sites =
                              controller.trackerHashes.keys.where((e) => e != ' All' && e != ' 红种').toList();
                          sites.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
                          var shadColorScheme = ShadTheme.of(context).colorScheme;
                          Get.bottomSheet(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0), // 圆角半径
                            ),
                            backgroundColor: shadowColorScheme.background,
                            SizedBox(
                              height: 240,
                              // width: 240,
                              child: Scaffold(
                                body: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
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
                                        ElevatedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0), // 圆角半径
                                            ),
                                          ),
                                          onPressed: () {
                                            Get.back(result: false);
                                          },
                                          child: const Text('取消'),
                                        ),
                                        Stack(
                                          children: [
                                            ElevatedButton(
                                              style: OutlinedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0), // 圆角半径
                                                ),
                                              ),
                                              onPressed: () async {
                                                controller.trackerLoading = true;
                                                controller.update();
                                                CommonResponse res = await controller.replaceTrackers(
                                                    site: keyController.text, newTracker: valueController.text);
                                                controller.trackerLoading = false;
                                                controller.update();
                                                if (res.code == 0) {
                                                  Get.back(result: true);
                                                }
                                                Get.snackbar('Tracker替换ing', res.msg,
                                                    colorText: res.code == 0
                                                        ? Theme.of(context).colorScheme.primary
                                                        : Theme.of(context).colorScheme.error);
                                              },
                                              child: const Text('确认'),
                                            ),
                                            if (controller.trackerLoading)
                                              const Center(child: CircularProgressIndicator()),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  backgroundColor: shadowColorScheme.background,
                  enableDrag: true,
                  CustomCard(
                    height: 400,
                    padding: const EdgeInsets.all(12),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('添加种子'),
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
      );
    });
  }

  Widget _buildTrTorrentCard(TrTorrent torrentInfo, context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
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
                              command: torrentInfo.status == 0 ? 'resume' : 'pause', ids: [torrentInfo.hashString]);
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                backgroundColor: torrentInfo.status == 0 ? const Color(0xFF0392CF) : Colors.deepOrangeAccent,
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
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
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
                            ids: [torrentInfo.hashString],
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
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.play_arrow_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '开始种子'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.pause_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '暂停种子'),
                onPressed: () {},
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
                          SwitchListTile(
                              dense: true,
                              title: const Text(
                                '删除种子文件？',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: deleteFiles.value,
                              activeColor: shadColorScheme.primary,
                              onChanged: (value) {
                                deleteFiles.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              title: const Text(
                                '无其他站点保种删除数据？',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: doDeleteWithOutOthers.value,
                              activeColor: shadColorScheme.primary,
                              onChanged: (value) {
                                doDeleteWithOutOthers.value = value;
                              }),
                        ],
                      );
                    }),
                    actions: [
                      ShadButton(
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
                              command: 'remove_torrent', enable: deleteFiles.value, ids: [torrentInfo.hashString]);
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
                    ShadButton(
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
                          command: 'verify_torrent',
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
                    controller.controlTorrents(command: 'reannounce_torrent', ids: [torrentInfo.hashString]),
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
                          SwitchListTile(
                              dense: true,
                              title: const Text(
                                '同时移动数据？',
                                style: TextStyle(fontSize: 12),
                              ),
                              subtitle: const Text(
                                '不勾选则从新目录下查找文件数据',
                                style: TextStyle(fontSize: 8),
                              ),
                              activeColor: shadColorScheme.primary,
                              value: changeDataDir.value,
                              onChanged: (value) {
                                changeDataDir.value = value;
                              }),
                        ],
                      );
                    }),
                    actions: [
                      ShadButton.destructive(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'move_torrent_data',
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
                      Get.snackbar('复制种子名称', '种子名称复制成功！', colorText: shadColorScheme.foreground);
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
                      Get.snackbar('复制种子HASH', '种子HASH复制成功！', colorText: shadColorScheme.foreground);
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
                      Clipboard.setData(ClipboardData(text: '${torrentInfo.torrentFile}'));
                      Get.snackbar('复制路径', '种子路径复制成功！', colorText: shadColorScheme.foreground);
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
                      Get.snackbar('复制磁力链接', '磁力链接复制成功！', colorText: shadColorScheme.foreground);
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
                    onPressed: () {
                      controller.controlTorrents(
                        command: 'queue_top',
                        ids: [torrentInfo.hashString],
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列向上'),
                    onPressed: () {
                      controller.controlTorrents(
                        command: 'queue_up',
                        ids: [torrentInfo.hashString],
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列向下'),
                    onPressed: () {
                      controller.controlTorrents(
                        command: 'queue_down',
                        ids: [torrentInfo.hashString],
                      );
                    },
                  ),
                  ShadContextMenuItem(
                    leading: Icon(
                      size: 14,
                      Icons.tag_outlined,
                      color: shadColorScheme.foreground,
                    ),
                    child: Text(style: TextStyle(fontSize: 12), '队列底部'),
                    onPressed: () {
                      controller.controlTorrents(
                        command: 'queue_bottom',
                        ids: [torrentInfo.hashString],
                      );
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
                child: Text(style: TextStyle(fontSize: 12), '标签'),
                onPressed: () {},
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.language_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '修改Tracker'),
                onPressed: () {
                  logger_helper.Logger.instance.d(torrentInfo.torrentFile);
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
                      ShadButton.destructive(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          await controller.controlTorrents(
                            command: 'change_torrent',
                            ids: [torrentInfo.hashString],
                            trackerList: trackerController.text.split('\n'),
                          );
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
              ),
              ShadContextMenuItem(
                leading: Icon(
                  size: 14,
                  Icons.speed_outlined,
                  color: shadColorScheme.foreground,
                ),
                child: Text(style: TextStyle(fontSize: 12), '设置限速'),
                onPressed: () {},
              ),
            ],
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
                                        .trackerToWebSiteMap[controller.trackerToWebSiteMap.keys.firstWhereOrNull(
                                            (String element) => element
                                                .contains(Uri.parse(torrentInfo.trackerStats.first.announce).host))]
                                        ?.name ??
                                    Uri.parse(torrentInfo.trackerStats.first.announce).host,
                                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                                  FileSizeConvert.parseToFileSize(torrentInfo.totalSize),
                                  style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
                                ),
                                SizedBox(
                                  height: 12,
                                  child: Text(
                                    controller.trStatus
                                        .firstWhere((element) => element.value == torrentInfo.status,
                                            orElse: () => MetaDataItem(name: "未知状态", value: null))
                                        .name,
                                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Text(
                            torrentInfo.downloadDir.isNotEmpty ? torrentInfo.downloadDir : '未分类',
                            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                                    Icon(Icons.upload, size: 12, color: Theme.of(context).colorScheme.onSurface),
                                    Text(FileSizeConvert.parseToFileSize(torrentInfo.rateUpload),
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.cloud_upload, size: 12, color: Theme.of(context).colorScheme.onSurface),
                                    Text(FileSizeConvert.parseToFileSize(torrentInfo.uploadedEver),
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface))
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
                                    Icon(Icons.download, size: 12, color: Theme.of(context).colorScheme.onSurface),
                                    Text(FileSizeConvert.parseToFileSize(torrentInfo.rateDownload),
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.cloud_download,
                                        size: 12, color: Theme.of(context).colorScheme.onSurface),
                                    Text(FileSizeConvert.parseToFileSize(torrentInfo.downloadedEver),
                                        style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface))
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
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    EllipsisText(
                                      text: formatDuration(torrentInfo.activityDate).toString(),
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    EllipsisText(
                                      text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                          .format(DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedDate * 1000))
                                          .toString(),
                                      style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
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
                          value: torrentInfo.percentDone.toDouble(),
                          color: ShadTheme.of(context).colorScheme.primary,
                          backgroundColor: ShadTheme.of(context).colorScheme.background,
                        ),
                      ),
                      if (torrentInfo.error > 0)
                        EllipsisText(
                          text: '${torrentInfo.error} - ${torrentInfo.errorString}',
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
        ),
      );
    });
  }

  void _openTorrentInfoDetail(TrTorrent torrentInfo, context) async {
    logger_helper.Logger.instance.i(torrentInfo.files);
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
      CustomCard(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: GetBuilder<TrController>(builder: (controller) {
          var repeatTorrents = controller.torrents
              .where((element) => element.name == torrentInfo.name)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller
                            .trackerToWebSiteMap[controller.trackers.entries
                                .firstWhere((entry) => entry.value.contains(e.hashString))
                                .key]
                            ?.name ??
                        controller.trackers.entries.firstWhere((entry) => entry.value.contains(e.hashString)).key,
                    "value": e,
                  }))
              .map((e) => Tooltip(
                    message: e.value.error > 0
                        ? '${Uri.parse(e.value.trackerStats[0].announce).host} 错误信息： ${e.value.errorString}'
                        : Uri.parse(e.value.trackerStats[0].announce).host,
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
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: SizedBox(
                                height: 8,
                                // width: 100,
                                child: ShadProgress(
                                  value: torrentInfo.percentDone.toDouble(),
                                  color: ShadTheme.of(context).colorScheme.primary,
                                  backgroundColor: ShadTheme.of(context).colorScheme.background,
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
                                style: TextStyle(fontSize: 8, color: Theme.of(context).colorScheme.error),
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
                          //                     dense: true,
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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            child: Wrap(
                              spacing: 18,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                ShadButton(
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
                                            await controller
                                                .controlTorrents(command: 'recheck', ids: [torrentInfo.hashString]);
                                            Get.back();
                                            controller.update();
                                          },
                                          child: const Text('确认'),
                                        ),
                                      ],
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.announcement_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  child: Text('重新校验'),
                                ),
                                ShadButton(
                                  onPressed: () async {
                                    await controller
                                        .controlTorrents(command: 'reannounce', ids: [torrentInfo.hashString]);
                                    Get.back();
                                  },
                                  leading: const Icon(
                                    Icons.campaign,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  child: Text('强制汇报'),
                                ),
                                ShadButton(
                                  onPressed: () async {
                                    Clipboard.setData(ClipboardData(text: torrentInfo.hashString));
                                    Get.snackbar('复制种子HASH', '种子HASH复制成功！',
                                        colorText: Theme.of(context).colorScheme.primary);
                                  },
                                  leading: const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  child: Text('复制哈希'),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                                  color: RandomColor()
                                      .randomColor(colorHue: ColorHue.green, colorBrightness: ColorBrightness.primary),
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
                    ],
                  ),
                  TransmissionTreeView(torrentInfo.files),
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
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
      middleText: '确定要删除种子吗？',
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return ShadCheckbox(
              size: 18,
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
                  command: 'delete', ids: [torrentInfo.hashString], deleteFiles: deleteFile.value);
            },
            child: const Text('确认'),
          );
        }),
      ],
    );
  }
}
