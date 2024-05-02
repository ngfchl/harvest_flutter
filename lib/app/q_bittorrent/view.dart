import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/meta_item.dart';
import '../../utils/date_time_utils.dart';
import '../home/pages/agg_search/download_form.dart';
import 'controller.dart';

class QBittorrentPage extends GetView<QBittorrentController> {
  const QBittorrentPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchKeyController = TextEditingController();

    return GetBuilder<QBittorrentController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
              '${controller.downloader.name} - ${controller.allTorrents.length}'),
        ),
        body: EasyRefresh(
            controller: EasyRefreshController(),
            onRefresh: () async {
              await controller.initData();
            },
            child: Column(
              children: [
                Expanded(
                  child: controller.torrents.isEmpty
                      ? const GFLoader()
                      : Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: GetBuilder<QBittorrentController>(
                                  builder: (controller) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: searchKeyController,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: '请输入搜索关键字',
                                          hintStyle:
                                              const TextStyle(fontSize: 14),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 5),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            // 不绘制边框
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            // 确保角落没有圆角
                                            gapPadding:
                                                0.0, // 移除边框与hintText之间的间距
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              width: 1.0,
                                            ),
                                            // 仅在聚焦时绘制底部边框
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          controller.searchKey = value;
                                          controller.searchTorrents();
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    if (controller.searchKey.isNotEmpty)
                                      IconButton(
                                          onPressed: () {
                                            controller.searchController.text =
                                                controller.searchController.text
                                                    .substring(
                                                        0,
                                                        controller
                                                                .searchController
                                                                .text
                                                                .length -
                                                            1);
                                            controller.searchKey = controller
                                                .searchController.text;
                                            controller.searchTorrents();
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
                              child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  itemCount: controller.showTorrents.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    TorrentInfo torrentInfo =
                                        controller.showTorrents[index];
                                    return _buildQbTorrentCard(
                                        torrentInfo, context);
                                  }),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 70),
              ],
            )),
        endDrawer: _buildGfDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildActionButtons(controller, context),
      );
    });
  }

  GFDrawer _buildGfDrawer() {
    return GFDrawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GFDrawerHeader(
            centerAlign: true,
            currentAccountPicture: GFAvatar(
              radius: 80.0,
              backgroundImage: AssetImage(
                  'assets/images/${controller.downloader.category.toLowerCase()}.png'),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    '${controller.downloader.protocol}://${controller.downloader.host}:${controller.downloader.port}'),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              tooltipBehavior: TooltipBehavior(
                enable: true,
                shared: true,
                decimalPlaces: 1,
                builder: (dynamic data, dynamic point, dynamic series,
                    int pointIndex, int seriesIndex) {
                  // Logger.instance.w(data);
                  return Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade300,
                      border: Border.all(width: 2, color: Colors.teal.shade400),
                    ),
                    child: Text(
                      '${series.name}: ${filesize(point.y)}',
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
              primaryXAxis: const CategoryAxis(
                  isVisible: false,
                  majorGridLines: MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift),
              primaryYAxis: NumericAxis(
                  axisLine: const AxisLine(width: 0),
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    return ChartAxisLabel(
                      filesize(details.value),
                      const TextStyle(
                        fontSize: 10,
                      ),
                    );
                  },
                  majorTickLines: const MajorTickLines(size: 0)),
              series: [
                AreaSeries<ServerState, int>(
                  animationDuration: 0,
                  dataSource: controller.statusList,
                  enableTooltip: true,
                  xValueMapper: (ServerState sales, index) => index,
                  yValueMapper: (ServerState sales, _) => sales.dlInfoSpeed,
                  color: Colors.red.withOpacity(0.5),
                  name: '下载速度',
                  borderWidth: 1,
                ),
                AreaSeries<ServerState, int>(
                  animationDuration: 0,
                  dataSource: controller.statusList,
                  enableTooltip: true,
                  xValueMapper: (ServerState sales, index) => index,
                  yValueMapper: (ServerState sales, _) => sales.upInfoSpeed,
                  color: Colors.blue.withOpacity(0.9),
                  name: '上传速度',
                  borderWidth: 1,
                  borderDrawMode: BorderDrawMode.all,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(QBittorrentController controller, context) {
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
                        child: GetBuilder<QBittorrentController>(
                            builder: (controller) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.qbSortOptions.length,
                              itemBuilder: (context, index) {
                                MetaDataItem item =
                                    controller.qbSortOptions[index];
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
                                  onTap: () {
                                    Get.back();
                                    controller.sortReversed =
                                        controller.sortKey == item.value
                                            ? !controller.sortReversed
                                            : false;
                                    controller.sortKey = item.value;
                                    controller.subTorrentList();
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
                        child: GetBuilder<QBittorrentController>(
                            builder: (controller) {
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.categoryMap.length,
                              itemBuilder: (context, index) {
                                String c =
                                    controller.categoryMap.keys.toList()[index];
                                Category? category = controller
                                    .categoryMap.values
                                    .toList()[index];
                                int count = 0;
                                if (category?.savePath == null) {
                                  count = controller.allTorrents.length;
                                } else {
                                  count = controller.allTorrents
                                      .where((torrent) =>
                                          torrent.category == category?.name)
                                      .toList()
                                      .length;
                                }
                                bool selected = controller.category ==
                                    (category?.savePath != null
                                        ? category?.name!
                                        : null);
                                return ListTile(
                                  title: Text(
                                    '$c($count)',
                                  ),
                                  selected: selected,
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  onTap: () {
                                    Get.back();
                                    controller.torrentFilter =
                                        TorrentFilter.all;
                                    controller.category =
                                        category?.savePath != null
                                            ? category?.name!
                                            : null;
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
                  child:
                      GetBuilder<QBittorrentController>(builder: (controller) {
                    return Column(
                      children: [
                        GFTypography(
                          text: '种子状态',
                          icon: const Icon(Icons.info),
                          dividerWidth: 108,
                          textColor: Theme.of(context).colorScheme.onBackground,
                          dividerColor:
                              Theme.of(context).colorScheme.onBackground,
                        ),
                        SizedBox(
                          height: 340,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: controller.status.length,
                              itemBuilder: (context, index) {
                                MetaDataItem state = controller.status[index];
                                return ListTile(
                                  title: Text(
                                    '${state.name}(${controller.allTorrents.where((torrent) => state.value != null ? torrent.state == state.value : true).toList().length})',
                                  ),
                                  style: ListTileStyle.list,
                                  selected:
                                      controller.torrentState == state.value,
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  onTap: () {
                                    Get.back();
                                    controller.torrentState = state.value;
                                    controller.torrentFilter =
                                        TorrentFilter.all;
                                    controller.subTorrentList();
                                    controller.update();
                                  },
                                );
                              }),
                        ),
                        ListTile(
                          title: Text(
                            '活动中(${controller.allTorrents.where((torrent) => [
                                  TorrentState.downloading,
                                  TorrentState.uploading,
                                  TorrentState.checkingUP,
                                  TorrentState.forcedUP,
                                  TorrentState.moving,
                                ].contains(torrent.state)).toList().length})',
                          ),
                          style: ListTileStyle.list,
                          selected:
                              controller.torrentFilter == TorrentFilter.active,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          onTap: () {
                            Get.back();
                            controller.torrentState = null;
                            controller.torrentFilter = TorrentFilter.active;
                            controller.subTorrentList();
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
                        child: GetBuilder<QBittorrentController>(
                            builder: (controller) {
                          List<String> keys = controller.trackers.keys
                              .where((element) => element
                                  .toLowerCase()
                                  .contains(searchKey.text.toLowerCase()))
                              .toList();
                          keys.sort((a, b) =>
                              a.toLowerCase().compareTo(b.toLowerCase()));
                          return ListView.builder(
                              shrinkWrap: true,
                              itemCount: keys.length,
                              itemBuilder: (context, index) {
                                String? key = keys[index];
                                List<String>? hashList;
                                if (key == ' 红种') {
                                  hashList = controller.allTorrents
                                      .where((element) =>
                                          element.tracker?.isEmpty == true)
                                      .map((e) => e.hash.toString())
                                      .toList();
                                } else {
                                  hashList = controller.trackers[key];
                                }
                                return ListTile(
                                  title: Text(
                                    '${key.trim()}(${key == ' All' ? controller.allTorrents.length : hashList?.length})',
                                  ),
                                  style: ListTileStyle.list,
                                  selected: controller.selectedTracker == key,
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  onTap: () {
                                    Get.back();
                                    // controller.torrentState = null;
                                    controller.torrentFilter =
                                        TorrentFilter.all;
                                    controller.selectedTracker = key;
                                    controller.subTorrentList();
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
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 18,
            ),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                // 按钮形状
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {},
          ),
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
                  child: ListView(children: [
                    GFTypography(
                      text: '添加种子',
                      icon: const Icon(Icons.add),
                      dividerWidth: 108,
                      textColor: Theme.of(context).colorScheme.onBackground,
                      dividerColor: Theme.of(context).colorScheme.onBackground,
                    ),
                    DownloadForm(
                      categories: controller.categoryMap.values.fold({},
                          (map, element) {
                        map[element!.name!] = element.savePath ?? '';
                        return map;
                      }),
                      downloader: controller.downloader,
                      info: null,
                    ),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQbTorrentCard(TorrentInfo torrentInfo, context) {
    RxBool paused = torrentInfo.state.toString().contains('pause').obs;
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.all(2.5),
      child: GetBuilder<QBittorrentController>(builder: (controller) {
        return Slidable(
          key: ValueKey(torrentInfo.infohashV1),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  _removeTorrent(controller, torrentInfo);
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
                      hashes: [torrentInfo.hash!]);
                },
                flex: 2,
                backgroundColor: paused.value
                    ? const Color(0xFF0392CF)
                    : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: paused.value ? Icons.play_arrow : Icons.pause,
                label: paused.value ? '开始' : '暂停',
              ),
            ],
          ),

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
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
                            hashes: [torrentInfo.hash!],
                          );
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                icon: Icons.checklist,
                label: '校验',
              ),
              SlidableAction(
                onPressed: (context) async {
                  await controller.controlTorrents(
                      command: 'AutoManagement',
                      hashes: [torrentInfo.hash!],
                      enable: !torrentInfo.autoTmm!);
                },
                flex: 2,
                backgroundColor: torrentInfo.autoTmm!
                    ? Colors.lightBlue
                    : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: torrentInfo.autoTmm! ? Icons.auto_awesome : Icons.man,
                label: torrentInfo.autoTmm! ? '自动' : '手动',
              ),
            ],
          ),
          child: GestureDetector(
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
                                    .firstWhere((entry) =>
                                        entry.value.contains(torrentInfo.hash))
                                    .key,
                                icon: const Icon(Icons.file_upload_outlined,
                                    size: 10, color: Colors.white),
                              )
                            : CustomTextTag(
                                labelText: controller.trackers.entries
                                    .firstWhere((entry) =>
                                        entry.value.contains(torrentInfo.hash))
                                    .key,
                                icon: const Icon(Icons.link_off,
                                    size: 10, color: Colors.white),
                                backgroundColor: Colors.red,
                              ),
                        const SizedBox(width: 10),
                      ]),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              filesize(torrentInfo.size),
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                            SizedBox(
                              height: 12,
                              child: GFButton(
                                text: controller.status
                                    .firstWhere(
                                        (element) =>
                                            element.value == torrentInfo.state!,
                                        orElse: () => MetaDataItem(
                                            name: "未知状态",
                                            value: TorrentState.unknown))
                                    .name,
                                type: GFButtonType.transparent,
                                elevation: 0,
                                hoverColor: Colors.green,
                                textStyle: const TextStyle(
                                  fontSize: 10,
                                ),
                                onPressed: () {},
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
                          message: torrentInfo.name!,
                          child: Text(
                            torrentInfo.name!,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Text(
                        torrentInfo.category!.isNotEmpty
                            ? torrentInfo.category!
                            : '未分类',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
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
                              const Icon(
                                Icons.upload,
                                size: 12,
                              ),
                              Text(filesize(torrentInfo.upSpeed),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.cloud_upload,
                                size: 12,
                              ),
                              Text(filesize(torrentInfo.uploaded),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ))
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.download,
                                size: 12,
                              ),
                              Text(filesize(torrentInfo.dlSpeed),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.cloud_download,
                                size: 12,
                              ),
                              Text(filesize(torrentInfo.downloaded),
                                  style: const TextStyle(
                                    fontSize: 10,
                                  ))
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 12,
                              ),
                              EllipsisText(
                                text: formatDuration(torrentInfo.timeActive!)
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                ellipsis: '...',
                              )
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.timer,
                                size: 12,
                              ),
                              EllipsisText(
                                text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        torrentInfo.addedOn! * 1000))
                                    .toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
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
                      percentage: torrentInfo.progress!,
                      progressHeadType: GFProgressHeadType.square,
                      trailing: Text(
                        '${(torrentInfo.progress! * 100).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      alignment: MainAxisAlignment.center,
                      progressBarColor: Colors.green),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _removeTorrent(
      QBittorrentController controller, TorrentInfo torrentInfo) {
    RxBool deleteFile = false.obs;
    Get.defaultDialog(
      title: '确认',
      // backgroundColor: Colors.white54,
      radius: 5,
      titleStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
      middleText: '确定要删除种子吗？',
      content: Obx(() {
        return SwitchListTile(
            title: const Text('是否删除种子文件？'),
            value: deleteFile.value,
            onChanged: (value) {
              deleteFile.value = value;
            });
      }),
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
                hashes: [torrentInfo.hash!],
                deleteFiles: deleteFile.value);
          },
          child: const Text('确认'),
        ),
      ],
    );
  }

  void _openTorrentInfoDetail(TorrentInfo torrentInfo, context) async {
    // List<TorrentContents> contents =
    //     await controller.client.torrents.getContents(hash: torrentInfo.hash!);

    List<MetaDataItem> seedTrackers = controller.torrents
        .where((element) =>
            // element.hash != torrentInfo.hash &&
            element.contentPath == torrentInfo.contentPath)
        .map((e) => MetaDataItem.fromJson({
              "name": controller.trackers.entries
                  .firstWhere(
                      (entry) => entry.value.contains(e.hash ?? e.infohashV1))
                  .key,
              "value": e,
            }))
        .toList();

    // TorrentProperties prop =
    //     await controller.client.torrents.getProperties(hash: torrentInfo.hash!);
    List<Tracker> trackers =
        await controller.client.torrents.getTrackers(hash: torrentInfo.hash!);
    trackers =
        trackers.where((element) => element.url!.startsWith('http')).toList();
    // Logger.instance.i(prop.toJson());
    // for (Tracker tracker in trackers) {
    //   Logger.instance.i(tracker.toJson());
    // }
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
          child: GetBuilder<QBittorrentController>(builder: (controller) {
            return ListView(
              children: [
                Wrap(
                  runSpacing: 4,
                  spacing: 12,
                  children: [
                    CustomCard(
                      child: ListTile(
                        dense: true,
                        title: Tooltip(
                          message: torrentInfo.name!,
                          child: Text(
                            torrentInfo.name!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        subtitle: GFProgressBar(
                          margin: EdgeInsets.zero,
                          percentage: torrentInfo.progress!,
                          lineHeight: 12,
                          progressHeadType: GFProgressHeadType.square,
                          progressBarColor: GFColors.SUCCESS,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                '${torrentInfo.progress! * 100}%',
                                style: const TextStyle(
                                    fontSize: 8, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        trailing:
                            torrentInfo.state.toString().contains('pause') ||
                                    torrentInfo.tracker?.isEmpty == true
                                ? const Icon(Icons.pause, color: Colors.red)
                                : const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.green,
                                  ),
                      ),
                    ),

                    CustomCard(
                      child: ListTile(
                        dense: true,
                        title: Text(
                          torrentInfo.category!.isNotEmpty
                              ? torrentInfo.category!
                              : '未分类',
                          style: const TextStyle(fontSize: 12),
                        ),
                        subtitle: Tooltip(
                          message: torrentInfo.contentPath!,
                          child: Text(
                            torrentInfo.contentPath!,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        leading: const Icon(Icons.category_outlined),
                        trailing: IconButton(
                          icon: const Icon(Icons.swap_horiz),
                          onPressed: () {},
                        ),
                      ),
                    ),

                    Center(
                      child: CustomCard(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        child: Wrap(
                          spacing: 28,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            GFButton(
                              text: '重新校验',
                              color: GFColors.DANGER,
                              onPressed: () async {
                                Get.defaultDialog(
                                    title: '',
                                    middleText: '重新校验种子？',
                                    onConfirm: () async {
                                      await controller.controlTorrents(
                                          command: 'recheck',
                                          hashes: [torrentInfo.hash!]);
                                    },
                                    cancel: const Text('取消'),
                                    confirm: const Text('确定'));
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
                                    hashes: [torrentInfo.hash!]);
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
                                Clipboard.setData(
                                    ClipboardData(text: torrentInfo.hash!));
                                Get.snackbar('复制种子HASH', '种子HASH复制成功！');
                              },
                              icon: const Icon(
                                Icons.copy,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            GFButton(
                              text: '自动管理',
                              padding: EdgeInsets.zero,
                              color: torrentInfo.autoTmm!
                                  ? GFColors.SUCCESS
                                  : GFColors.DANGER,
                              onPressed: () async {
                                await controller.controlTorrents(
                                    command: 'AutoManagement',
                                    hashes: [torrentInfo.hash!],
                                    enable: !torrentInfo.autoTmm!);
                              },
                              icon: torrentInfo.autoTmm!
                                  ? const Icon(
                                      Icons.hdr_auto_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : const Icon(
                                      Icons.sports_handball_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                            GFButton(
                              text: '超级做种',
                              color: torrentInfo.superSeeding!
                                  ? GFColors.SUCCESS
                                  : GFColors.DANGER,
                              onPressed: () async {
                                await controller.controlTorrents(
                                    command: 'SuperSeeding',
                                    hashes: [torrentInfo.hash!],
                                    enable: !torrentInfo.superSeeding!);
                              },
                              icon: torrentInfo.superSeeding!
                                  ? const Icon(
                                      Icons.supervisor_account_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : const Icon(
                                      Icons.accessibility_sharp,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                            GFButton(
                              text: '强制开始',
                              color: torrentInfo.forceStart!
                                  ? GFColors.SUCCESS
                                  : GFColors.DANGER,
                              onPressed: () async {
                                await controller.controlTorrents(
                                    command: 'ForceStart',
                                    hashes: [torrentInfo.hash!],
                                    enable: !torrentInfo.forceStart!);
                              },
                              icon: torrentInfo.forceStart!
                                  ? const Icon(
                                      Icons.double_arrow_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : const Icon(
                                      Icons.play_arrow_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Center(
                      child: CustomCard(
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
                                    formatDuration(torrentInfo.seedingTime!),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
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
                                    '状态',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    controller.status
                                        .firstWhere(
                                          (element) =>
                                              element.value ==
                                              torrentInfo.state!,
                                          orElse: () => MetaDataItem(
                                            name: "未知状态",
                                            value: TorrentState.unknown,
                                          ),
                                        )
                                        .name,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
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
                                    '大小',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    filesize(torrentInfo.size!),
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
                                    filesize(torrentInfo.uploaded),
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
                                    '${filesize(torrentInfo.upSpeed)}/S',
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
                                    '${filesize(torrentInfo.upLimit)}/S',
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
                                    filesize(torrentInfo.downloaded),
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
                                    '${torrentInfo.ratio?.toStringAsFixed(2)}',
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
                                    '分享率限制',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    '${torrentInfo.ratioLimit}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (seedTrackers.length > 1)
                      Center(
                        child: CustomCard(
                            padding: const EdgeInsets.all(12),
                            width: double.infinity,
                            child: Column(
                              children: [
                                const Text(
                                  '已辅种种子',
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...seedTrackers.map((e) => InputChip(
                                          labelPadding: EdgeInsets.zero,
                                          backgroundColor: RandomColor()
                                              .randomColor(
                                                  colorHue: ColorHue.orange,
                                                  colorBrightness:
                                                      ColorBrightness.dark),
                                          shadowColor: Colors.orangeAccent,
                                          elevation: 3,
                                          label: SizedBox(
                                            width: 52,
                                            child: Text(
                                              e.name,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          avatar: e.value.tracker.isNotEmpty
                                              ? const Icon(Icons.link,
                                                  color: Colors.green)
                                              : const Icon(Icons.link_off,
                                                  color: Colors.red),
                                          onPressed: () {
                                            _openTorrentInfoDetail(
                                                e.value, context);
                                          },
                                          onDeleted: () {
                                            _removeTorrent(controller, e.value);
                                          },
                                        )),
                                  ],
                                ),
                              ],
                            )),
                      ),
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
                    //   labelText: 'HASH: ${torrentInfo.hash!}',
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
                    // CustomTextTag(
                    //labelText:
                    //   '追踪器: ${torrentInfo.tracker}',
                    //
                    // ),

                    // CustomTextTag(
                    //labelText:
                    //   '追踪器数量: ${torrentInfo.trackersCount}',
                    //
                    // ),
                  ],
                ),
              ],
            );
          }),
        ));
  }
}
