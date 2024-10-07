import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/models/common_response.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/meta_item.dart';
import '../../utils/date_time_utils.dart';
import '../../utils/storage.dart';
import '../home/pages/agg_search/download_form.dart';
import 'controller.dart';

class QBittorrentPage extends GetView<QBittorrentController> {
  const QBittorrentPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController searchKeyController = TextEditingController();

    return GetBuilder<QBittorrentController>(builder: (controller) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: GetBuilder<QBittorrentController>(
                              builder: (controller) {
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 5),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // 不绘制边框
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        // 确保角落没有圆角
                                        gapPadding: 0.0, // 移除边框与hintText之间的间距
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        // 仅在聚焦时绘制底部边框
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                      ),
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
                                        if (controller
                                            .searchController.text.isNotEmpty) {
                                          controller.searchController.text =
                                              controller.searchController.text
                                                  .substring(
                                                      0,
                                                      controller
                                                              .searchController
                                                              .text
                                                              .length -
                                                          1);
                                          controller.searchKey =
                                              controller.searchController.text;
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
          endDrawer: _buildGfDrawer(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildActionButtons(controller, context),
        ),
      );
    });
  }

  Widget _buildGfDrawer(context) {
    return GetBuilder<QBittorrentController>(builder: (controller) {
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
              height: 80,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(width: 1),
                      ),
                      child: Text(
                        '${series.name}: ${filesize(point.y)}',
                        style: const TextStyle(fontSize: 12),
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
            if (controller.serverState != null)
              SizedBox(
                  height: 300,
                  child: ListView(
                    children: [
                      ListTile(
                        dense: true,
                        title: Center(
                            child: Text(
                          '剩余空间',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        )),
                        subtitle: Container(
                          color: Colors.blue,
                          child: Center(
                            child: Text(
                              filesize(controller.serverState!.freeSpaceOnDisk),
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        title: Center(
                            child: Text(
                          '上传下载数据',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        )),
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
                                labelText:
                                    '${filesize(controller.serverState!.alltimeUl)}[${filesize(controller.serverState!.upInfoData)}]'),
                            CustomTextTag(
                                icon: const Icon(
                                  Icons.download_outlined,
                                  color: Colors.red,
                                  size: 14,
                                ),
                                backgroundColor: Colors.transparent,
                                labelColor: Colors.red,
                                labelText:
                                    '${filesize(controller.serverState!.alltimeDl)}[${filesize(controller.serverState!.dlInfoData)}]'),
                          ],
                        ),
                      ),
                      ListTile(
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
                                labelText:
                                    '[${filesize(controller.serverState!.upRateLimit)}/S]'),
                            CustomTextTag(
                                icon: const Icon(
                                  Icons.download_outlined,
                                  color: Colors.red,
                                  size: 14,
                                ),
                                backgroundColor: Colors.transparent,
                                labelColor: Colors.red,
                                labelText:
                                    '[${filesize(controller.serverState!.dlRateLimit)}/S]'),
                          ],
                        ),
                        title: Center(
                          child: Text(
                            '切换限速模式',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        dense: true,
                        trailing: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            CupertinoSwitch(
                                value:
                                    controller.serverState!.useAltSpeedLimits ==
                                        true,
                                onChanged: (value) async {
                                  await controller.toggleSpeedLimit();
                                }),
                            if (controller.toggleSpeedLimitLoading)
                              const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(child: GFLoader()))
                          ],
                        ),
                      ),
                    ],
                  ))
          ],
        ),
      );
    });
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
                        textColor: Theme.of(context).colorScheme.onSurface,
                        dividerColor: Theme.of(context).colorScheme.onSurface,
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
                                    SPUtil.setLocalStorage(
                                        '${controller.downloader.host}:${controller.downloader.port}-sortKey',
                                        controller.sortKey.toString());
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
                        textColor: Theme.of(context).colorScheme.onSurface,
                        dividerColor: Theme.of(context).colorScheme.onSurface,
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
                          textColor: Theme.of(context).colorScheme.onSurface,
                          dividerColor: Theme.of(context).colorScheme.onSurface,
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
                                  // TorrentState.checkingUP,
                                  TorrentState.forcedUP,
                                  TorrentState.moving,
                                  // TorrentState.checkingDL,
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
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      onTap: () async {
                        CommonResponse res =
                            await controller.removeErrorTracker();
                        Get.snackbar('清理红种', res.msg!,
                            colorText: res.code == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error);
                        controller.subTorrentList();
                        controller.update();
                      },
                    ),
                    PopupMenuItem<String>(
                      child: Center(
                        child: Text(
                          '切换限速',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.primary),
                      )),
                      onTap: () {
                        TextEditingController keyController =
                            TextEditingController(text: '');
                        TextEditingController valueController =
                            TextEditingController(text: '');
                        List<String> sites = controller.trackers.keys
                            .where((e) => e != ' All' && e != ' 红种')
                            .toList();
                        sites.sort((a, b) =>
                            a.toLowerCase().compareTo(b.toLowerCase()));
                        Get.bottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 圆角半径
                          ),
                          SizedBox(
                            height: 240,
                            // width: 240,
                            child: Scaffold(
                              body: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomPickerField(
                                    controller: keyController,
                                    labelText: '要替换的站点',
                                    data: sites,
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
                                            borderRadius: BorderRadius.circular(
                                                8.0), // 圆角半径
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        8.0), // 圆角半径
                                              ),
                                            ),
                                            onPressed: () async {
                                              controller.trackerLoading = true;
                                              controller.update();
                                              CommonResponse res =
                                                  await controller
                                                      .replaceTrackers(
                                                          site: keyController
                                                              .text,
                                                          newTracker:
                                                              valueController
                                                                  .text);
                                              controller.trackerLoading = false;
                                              controller.update();
                                              if (res.code == 0) {
                                                Get.back(result: true);
                                              }
                                              Get.snackbar(
                                                  'Tracker替换ing', res.msg!,
                                                  colorText: res.code == 0
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .error);
                                            },
                                            child: const Text('确认'),
                                          ),
                                          if (controller.trackerLoading)
                                            const Center(child: GFLoader()),
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
                          map[element!.name!] = element.savePath ?? '';
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
                            Text(
                              controller.status
                                  .firstWhere(
                                      (element) =>
                                          element.value == torrentInfo.state!,
                                      orElse: () => MetaDataItem(
                                          name: "未知状态",
                                          value: TorrentState.unknown))
                                  .name,
                              style: const TextStyle(
                                fontSize: 10,
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
            controller.showTorrents
                .removeWhere((element) => element.hash == torrentInfo.hash);
            await controller.controlTorrents(
                command: 'delete',
                hashes: [torrentInfo.hash!],
                deleteFiles: deleteFile.value);
            controller.update();
          },
          child: const Text('确认'),
        ),
      ],
    );
  }

  void _openTorrentInfoDetail(TorrentInfo torrentInfo, context) async {
    List<TorrentContents> contents =
        await controller.client.torrents.getContents(hash: torrentInfo.hash!);

    // TorrentProperties prop =
    //     await controller.client.torrents.getProperties(hash: controller.selectedTorrent.hash!);
    List<Tracker> trackers =
        await controller.client.torrents.getTrackers(hash: torrentInfo.hash!);
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
          trackers = trackers
              .where((element) => element.url!.startsWith('http'))
              .toList();
          var repeatTorrents = controller.torrents
              .where(
                  (element) => element.contentPath == torrentInfo.contentPath)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller.trackers.entries
                        .firstWhere((entry) =>
                            entry.value.contains(e.hash ?? e.infohashV1))
                        .key,
                    "value": e,
                  }))
              .map((e) => InputChip(
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
                    avatar: e.value.tracker.isNotEmpty
                        ? const Icon(Icons.link, color: Colors.green)
                        : const Icon(Icons.link_off, color: Colors.red),
                    onPressed: () {
                      _openTorrentInfoDetail(e.value, context);
                    },
                    onDeleted: () {
                      _removeTorrent(controller, e.value);
                    },
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
                                message: torrentInfo.name!,
                                child: Text(
                                  torrentInfo.name!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: GFProgressBar(
                                margin: EdgeInsets.zero,
                                percentage: torrentInfo.progress!,
                                lineHeight: 12,
                                progressHeadType: GFProgressHeadType.square,
                                progressBarColor: GFColors.SUCCESS,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '${torrentInfo.progress! * 100}%',
                                      style: const TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: torrentInfo.state
                                          .toString()
                                          .contains('pause') ||
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
                              trailing: CustomPopup(
                                showArrow: false,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                barrierColor: Colors.transparent,
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: controller.categoryMap.values
                                        .map((value) => PopupMenuItem(
                                              child: ListTile(
                                                title: Text(value!.name!),
                                                subtitle: Text(
                                                    value.savePath.toString()),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                child: const Icon(
                                    Icons.swap_horizontal_circle_outlined),
                              ),
                            ),
                          ),

                          CustomCard(
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
                                                hashes: [torrentInfo.hash!]);
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
                                    Get.back();
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
                                GFButton(
                                  text: '自动管理',
                                  padding: EdgeInsets.zero,
                                  color: torrentInfo.autoTmm!
                                      ? GFColors.SUCCESS
                                      : GFColors.DANGER,
                                  onPressed: () async {
                                    Get.back();
                                    await controller.controlTorrents(
                                        command: 'AutoManagement',
                                        hashes: [torrentInfo.hash!],
                                        enable: !torrentInfo.autoTmm!);
                                    controller.update();
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
                                    Get.back();
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
                                    Get.back();
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
                                        formatDuration(
                                            torrentInfo.seedingTime!),
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

                          CustomCard(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ...trackers.map((Tracker e) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Tooltip(
                                                  message: e.url.toString(),
                                                  child: CustomTextTag(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    labelText: controller
                                                            .mySiteController
                                                            .webSiteList
                                                            .values
                                                            .firstWhereOrNull(
                                                              (element) => element
                                                                  .tracker
                                                                  .contains(Uri.parse(e
                                                                          .url
                                                                          .toString())
                                                                      .host),
                                                            )
                                                            ?.name ??
                                                        Uri.parse(e.url
                                                                .toString())
                                                            .host,
                                                  ),
                                                ),
                                                CustomTextTag(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .scrim,
                                                    icon: const Icon(
                                                        Icons.download_done,
                                                        size: 10,
                                                        color: Colors.white),
                                                    labelText:
                                                        '完成：${e.numDownloaded! > 0 ? e.numDownloaded.toString() : '0'}'),
                                                CustomTextTag(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .tertiary,
                                                    icon: const Icon(
                                                        Icons.download_outlined,
                                                        size: 10,
                                                        color: Colors.white),
                                                    labelText:
                                                        '下载：${e.numLeeches.toString()}'),
                                                CustomTextTag(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .surfaceTint,
                                                    icon: const Icon(
                                                        Icons.insert_link,
                                                        size: 10,
                                                        color: Colors.white),
                                                    labelText:
                                                        '连接：${e.numPeers.toString()}'),
                                                CustomTextTag(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                    icon: const Icon(
                                                        Icons
                                                            .cloud_upload_outlined,
                                                        size: 10,
                                                        color: Colors.white),
                                                    labelText:
                                                        '做种：${e.numSeeds.toString()}'),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CustomTextTag(
                                                    backgroundColor: e.status ==
                                                            TrackerStatus
                                                                .working
                                                        ? Colors.green
                                                        : Colors.red,
                                                    labelText: controller
                                                        .qbTrackerStatus
                                                        .firstWhere((element) =>
                                                            element.value ==
                                                            e.status)
                                                        .name),
                                                if (e.msg != null &&
                                                    e.msg!.isNotEmpty)
                                                  CustomTextTag(
                                                    icon: const Icon(
                                                      Icons.message_outlined,
                                                      size: 10,
                                                      color: Colors.white,
                                                    ),
                                                    labelText: e.msg.toString(),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              )),

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
                        ],
                      ),
                    ],
                  ),
                  TreeView(contents),
                  ListView(
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TreeNode {
  String name;
  Map<String, TreeNode> children;
  TorrentContents? content;

  TreeNode(this.name)
      : children = {},
        content = null;

  @override
  String toString() => name;
}

void printTree(TreeNode node, String indent) {
  print(indent + node.name);
  for (var child in node.children.values) {
    printTree(child, '$indent  ');
  }
}

class TreeView extends StatelessWidget {
  final List<TorrentContents> contents;

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

  List<TreeNode> generateTreeNodes(List<TorrentContents> contents) {
    Map<String, TreeNode> nodesMap = {};

    for (TorrentContents content in contents) {
      List<String> filePathParts = content.name!.split('/');
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
            CustomTextTag(labelText: node.content!.index.toString()),
            CustomTextTag(
              labelText: filesize(node.content!.size),
              icon: const Icon(Icons.download_done,
                  size: 10, color: Colors.white),
            ),
            CustomTextTag(
                icon: const Icon(Icons.cloud_upload_outlined,
                    size: 10, color: Colors.white),
                labelText: node.content!.isSeed.toString()),
            CustomTextTag(
                icon: const Icon(Icons.download_outlined,
                    size: 10, color: Colors.white),
                labelText: node.content!.priority.toString()),
            CustomTextTag(
                icon: const Icon(Icons.download_outlined,
                    size: 10, color: Colors.white),
                labelText: node.content!.progress.toString()),
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
