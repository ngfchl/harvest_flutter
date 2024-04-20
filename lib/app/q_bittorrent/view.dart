import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/meta_item.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/logger_helper.dart';
import '../home/pages/agg_search/download_form.dart';
import 'controller.dart';

class QBittorrentPage extends GetView<QBittorrentController> {
  const QBittorrentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QBittorrentController>(builder: (controller) {
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
                  child: controller.torrents.isEmpty
                      ? const GFLoader()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          itemCount: controller.showTorrents.length,
                          itemBuilder: (BuildContext context, int index) {
                            TorrentInfo torrentInfo =
                                controller.showTorrents[index];
                            return _buildQbTorrentCard(torrentInfo);
                          }),
                ),
                const SizedBox(height: 70),
              ],
            )),
        endDrawer: _buildGfDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildActionButtons(controller),
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
                        color: Colors.black38,
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
                      const TextStyle(fontSize: 10, color: Colors.black38),
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
                  borderColor: Colors.black38,
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
                  borderColor: Colors.black38,
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

  Widget _buildActionButtons(QBittorrentController controller) {
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
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                // 按钮形状
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {
              Get.bottomSheet(
                SizedBox(
                  width: double.infinity,
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        const GFTypography(
                          text: '排序',
                          icon: Icon(Icons.info),
                          dividerWidth: 108,
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
                                    selectedColor: Colors.purple,
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
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                // 按钮形状
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {
              Get.bottomSheet(
                SizedBox(
                  width: double.infinity,
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        const GFTypography(
                          text: '种子分类',
                          icon: Icon(Icons.category),
                          dividerWidth: 108,
                        ),
                        SizedBox(
                          height: 400,
                          child: GetBuilder<QBittorrentController>(
                              builder: (controller) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.categoryMap.length,
                                itemBuilder: (context, index) {
                                  String c = controller.categoryMap.keys
                                      .toList()[index];
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
                                    selectedColor: Colors.purple,
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
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {
              Get.bottomSheet(
                SizedBox(
                  width: double.infinity,
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: GetBuilder<QBittorrentController>(
                        builder: (controller) {
                      return Column(
                        children: [
                          const GFTypography(
                            text: '种子状态',
                            icon: Icon(Icons.info),
                            dividerWidth: 108,
                          ),
                          SizedBox(
                            height: 340,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.status.length,
                                itemBuilder: (context, index) {
                                  Map state = controller.status[index];
                                  return ListTile(
                                    title: Text(
                                      '${state['name']}(${controller.allTorrents.where((torrent) => state['value'] != null ? torrent.state == state['value'] : true).toList().length})',
                                    ),
                                    style: ListTileStyle.list,
                                    selected: controller.torrentState ==
                                        state['value'],
                                    selectedColor: Colors.purple,
                                    onTap: () {
                                      Get.back();
                                      controller.torrentState = state['value'];
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
                            selected: controller.torrentFilter ==
                                TorrentFilter.active,
                            selectedColor: Colors.purple,
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
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                // 按钮形状
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {
              Get.bottomSheet(
                SizedBox(
                  width: double.infinity,
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      children: [
                        const GFTypography(
                          text: '站点筛选',
                          icon: Icon(Icons.language),
                          dividerWidth: 108,
                        ),
                        SizedBox(
                          height: 400,
                          child: GetBuilder<QBittorrentController>(
                              builder: (controller) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.trackers.keys.length,
                                itemBuilder: (context, index) {
                                  String? key =
                                      controller.trackers.keys.toList()[index];
                                  List<String>? hashList =
                                      controller.trackers[key];
                                  return ListTile(
                                    title: Text(
                                      '$key(${key == 'all' ? controller.allTorrents.length : hashList?.length})',
                                    ),
                                    style: ListTileStyle.list,
                                    selected: controller.selectedTracker == key,
                                    selectedColor: Colors.purple,
                                    onTap: () {
                                      Get.back();
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
              foregroundColor: Colors.blue,
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
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontSize: 12),
              shape: RoundedRectangleBorder(
                // 按钮形状
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            onPressed: () {
              Get.bottomSheet(
                enableDrag: true,
                SizedBox(
                  height: 400,
                  child: CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: ListView(children: [
                      const GFTypography(
                        text: '添加种子',
                        icon: Icon(Icons.add),
                        dividerWidth: 108,
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQbTorrentCard(TorrentInfo torrentInfo) {
    RxBool paused = torrentInfo.state.toString().contains('pause').obs;
    RxBool deleteFile = false.obs;
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
                        GFCheckbox(
                          size: 18,
                          activeBgColor: GFColors.DANGER,
                          onChanged: (value) {
                            deleteFile.value = value;
                          },
                          value: deleteFile.value,
                        ),
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
                          // await controller.controlTorrents(
                          //     command: 'delete',
                          //     hashes: [torrentInfo.hash!],
                          //     deleteFiles: deleteFile);
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
              _openTorrentInfoDetail(torrentInfo);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (torrentInfo.tracker!.isNotEmpty)
                        Row(children: [
                          const Icon(
                            Icons.link,
                            size: 10,
                          ),
                          Text(
                            Uri.parse(torrentInfo.tracker!).host,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold),
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
                              filesize(torrentInfo.size),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.black38),
                            ),
                            SizedBox(
                              height: 12,
                              child: GFButton(
                                text: controller.status.firstWhere(
                                  (element) =>
                                      element['value'] == torrentInfo.state!,
                                  orElse: () => {
                                    "name": "未知状态",
                                    "value": TorrentState.unknown
                                  },
                                )['name'],
                                type: GFButtonType.transparent,
                                elevation: 0,
                                hoverColor: Colors.green,
                                textStyle: const TextStyle(
                                    fontSize: 10, color: Colors.black38),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      torrentInfo.tracker!.isNotEmpty
                          ? const Icon(Icons.upload,
                              size: 14, color: Colors.green)
                          : const Icon(Icons.link_off,
                              size: 14, color: Colors.red),
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
                                fontSize: 11, color: Colors.black38),
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
                            fontSize: 10, color: Colors.black38),
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
                              const Icon(Icons.upload,
                                  size: 12, color: Colors.black38),
                              Text(filesize(torrentInfo.upSpeed),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38))
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.cloud_upload,
                                  size: 12, color: Colors.black38),
                              Text(filesize(torrentInfo.uploaded),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38))
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.download,
                                  size: 12, color: Colors.black38),
                              Text(filesize(torrentInfo.dlSpeed),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38))
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.cloud_download,
                                  size: 12, color: Colors.black38),
                              Text(filesize(torrentInfo.downloaded),
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38))
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
                                color: Colors.black38,
                              ),
                              EllipsisText(
                                text: formatDuration(torrentInfo.timeActive!)
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black38),
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
                                color: Colors.black38,
                              ),
                              EllipsisText(
                                text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        torrentInfo.addedOn! * 1000))
                                    .toString(),
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black38),
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
                            fontSize: 10, color: Colors.black38),
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

  void _openTorrentInfoDetail(TorrentInfo torrentInfo) async {
    TorrentProperties prop =
        await controller.client.torrents.getProperties(hash: torrentInfo.hash!);
    // List<Tracker> trackers =
    //     await controller.client.torrents.getTrackers(hash: torrentInfo.hash!);
    Logger.instance.i(prop.toJson());
    // Logger.instance.i(trackers.toString());
    Get.bottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(2),
          ),
        ),
        isScrollControlled: true,
        enableDrag: true,
        SizedBox(
          height: double.infinity,
          child: CustomCard(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: GetBuilder<QBittorrentController>(builder: (controller) {
              return ListView(
                children: [
                  Tooltip(
                    message: torrentInfo.name!,
                    child: Text(
                      torrentInfo.name!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    'HASH: ${torrentInfo.hash!}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),

                  Tooltip(
                    message: torrentInfo.contentPath!,
                    child: Text(
                      '路径：${torrentInfo.contentPath!}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  Text(torrentInfo.state
                      .toString()
                      .contains('pause')
                      .toString()),
                  Text(
                    '最后完整可见：${formatTimestampToDateTime(torrentInfo.seenComplete!)}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '添加时间: ${formatTimestampToDateTime(torrentInfo.addedOn!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '耗时: ${formatDuration(torrentInfo.eta!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '最后活动时间: ${formatTimestampToDateTime(torrentInfo.lastActivity!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '已完成: ${filesize(torrentInfo.completed)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '完成时间: ${formatTimestampToDateTime(torrentInfo.completionOn!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  if (torrentInfo.amountLeft! > 0)
                    Text(
                      '剩余大小: ${filesize(torrentInfo.amountLeft)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  GFProgressBar(
                    margin: EdgeInsets.zero,
                    percentage: torrentInfo.progress!,
                    lineHeight: GFSize.SMALL,
                    progressHeadType: GFProgressHeadType.square,
                    backgroundColor: Colors.black26,
                    progressBarColor: GFColors.SUCCESS,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '${torrentInfo.progress! * 100}%',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        icon: const Icon(Icons.auto_mode, size: 10),
                      ),
                      GFButton(
                        text: '强制汇报',
                        color: GFColors.SUCCESS,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'reannounce',
                              hashes: [torrentInfo.hash!]);
                        },
                        icon: const Icon(Icons.campaign, size: 10),
                      ),
                      GFButton(
                        text: '复制哈希',
                        color: GFColors.SECONDARY,
                        onPressed: () async {
                          Clipboard.setData(
                              ClipboardData(text: torrentInfo.hash!));
                          Get.snackbar('复制种子HASH', '种子HASH复制成功！');
                        },
                        icon: const Icon(Icons.copy, size: 10),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GFButton(
                        text: '自动TMM: ${torrentInfo.autoTmm! ? "✔" : "✖"}',
                        color: torrentInfo.autoTmm!
                            ? GFColors.SUCCESS
                            : GFColors.DANGER,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'AutoManagement',
                              hashes: [torrentInfo.hash!],
                              enable: !torrentInfo.autoTmm!);
                        },
                      ),
                      GFButton(
                        text: '超级做种: ${torrentInfo.superSeeding! ? "✔" : "✖"}',
                        color: torrentInfo.superSeeding!
                            ? GFColors.SUCCESS
                            : GFColors.DANGER,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'SuperSeeding',
                              hashes: [torrentInfo.hash!],
                              enable: !torrentInfo.superSeeding!);
                        },
                      ),
                      GFButton(
                        text: '强制开始: ${torrentInfo.forceStart! ? "✔" : "✖"}',
                        color: torrentInfo.forceStart!
                            ? GFColors.SUCCESS
                            : GFColors.DANGER,
                        onPressed: () async {
                          await controller.controlTorrents(
                              command: 'ForceStart',
                              hashes: [torrentInfo.hash!],
                              enable: !torrentInfo.forceStart!);
                        },
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 200,
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                      ),
                      padding: EdgeInsets.zero,
                      children: [
                        Card(
                          color: Colors.purple,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('做种时间'),
                              Text(
                                torrentInfo.category!.isNotEmpty
                                    ? torrentInfo.category!
                                    : '未分类',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.purple,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('做种时间'),
                              Text(
                                formatDuration(torrentInfo.seedingTime!),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.redAccent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('状态'),
                              Text(
                                controller.status.firstWhere(
                                  (element) =>
                                      element['value'] == torrentInfo.state!,
                                  orElse: () => {
                                    "name": "未知状态",
                                    "value": TorrentState.unknown
                                  },
                                )['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.brown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('大小'),
                              Text(
                                filesize(torrentInfo.totalSize!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                filesize(torrentInfo.size!),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.deepOrange,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('已上传'),
                              Text(
                                '本次: ${filesize(torrentInfo.uploadedSession)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                '共: ${filesize(torrentInfo.uploaded)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.green,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('上传速度'),
                              Text(
                                '速度: ${filesize(torrentInfo.upSpeed)}/S',
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                '限速: ${filesize(torrentInfo.upLimit)}/S',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: GFColors.SUCCESS,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('已下载'),
                              Text(
                                '已下载: ${filesize(torrentInfo.downloaded)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                '本次已下载: ${filesize(torrentInfo.downloadedSession)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Colors.deepOrangeAccent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('分享率'),
                              Text(
                                '分享率: ${torrentInfo.ratio?.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 10),
                              ),
                              Text(
                                '限制: ${torrentInfo.ratioLimit}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '可用性: ${torrentInfo.availability}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  // Text(
                  //   '文件路径: ${torrentInfo.contentPath}',
                  //   style: const TextStyle(fontSize: 10),
                  // ),

                  Text(
                    '下载路径: ${torrentInfo.downloadPath}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    'FL Piece Prio: ${torrentInfo.fLPiecePrio}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  // Text(
                  //   '磁力链接: ${torrentInfo.magnetUri}',
                  //   style: const TextStyle(fontSize: 10),
                  // ),
                  Text(
                    '最大分享比率: ${torrentInfo.maxRatio}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '最大做种时间: ${formatDuration(torrentInfo.maxSeedingTime!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '完成数量: ${torrentInfo.numComplete}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '未完成数量: ${torrentInfo.numIncomplete}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '正在做种数量: ${torrentInfo.numLeechs}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '做种数量: ${torrentInfo.numSeeds}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '优先级: ${torrentInfo.priority}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    '保存路径: ${torrentInfo.savePath}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    '做种时间限制: ${torrentInfo.seedingTimeLimit}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    'Seq DL: ${torrentInfo.seqDl}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    '标签: ${torrentInfo.tags}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '活跃时间: ${formatDuration(torrentInfo.timeActive!)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  Text(
                    '追踪器: ${torrentInfo.tracker}',
                    style: const TextStyle(fontSize: 10),
                  ),

                  Text(
                    '追踪器数量: ${torrentInfo.trackersCount}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              );
            }),
          ),
        ));
  }
}
