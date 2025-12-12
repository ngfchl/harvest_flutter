import 'package:basic_utils/basic_utils.dart' as basic_utils;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/utils/string_utils.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../utils/logger_helper.dart' as LoggerHelper;
import '../../utils/date_time_utils.dart';
import '../../utils/logger_helper.dart';
import '../home/pages/download/download_form.dart';
import '../home/pages/models/transmission.dart';
import '../home/pages/models/transmission_base_torrent.dart';
import 'controller.dart';

class TorrentView extends GetView<TorrentController> {
  const TorrentView({super.key});

  @override
  Widget build(BuildContext context) {
    var tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      decimalPlaces: 1,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        // Logger.instance.d(data);
        return Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.teal.shade300,
            border: Border.all(width: 2, color: Colors.teal.shade400),
          ),
          child: Text(
            '${series.name}: ${FileSizeConvert.parseToFileSize(point.y)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
          ),
        );
      },
    );
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: GetBuilder<TorrentController>(builder: (controller) {
          return Text(controller.downloader.name);
        }),
        centerTitle: true,
      ),
      body: GetBuilder<TorrentController>(builder: (controller) {
        return controller.torrents.isEmpty
            ? const CircularProgressIndicator()
            : EasyRefresh(
                controller: EasyRefreshController(),
                onRefresh: () async {
                  controller.cancelPeriodicTimer();
                  controller.startPeriodicTimer();
                },
                child: Column(
                  children: [
                    if (controller.downloader.category.toLowerCase() == 'qb')
                      Container(
                        height: 20,
                        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
                        child: Row(
                          children: [
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: double.infinity),
                                  child: ShadSelect<String>(
                                      placeholder: const Text('要替换的站点'),
                                      trailing: const Text('要替换的站点'),
                                      initialValue: controller.sortKey.value,
                                      decoration: ShadDecoration(
                                        border: ShadBorder(
                                          merge: false,
                                          bottom: ShadBorderSide(
                                              color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                      ),
                                      options: controller.qbSortOptions
                                          .map((item) => ShadOption(value: item['value'], child: Text(item['name']!)))
                                          .toList(),
                                      selectedOptionBuilder: (context, value) {
                                        return Text(value);
                                      },
                                      onChanged: (String? newValue) {
                                        if (controller.sortKey.value == newValue) {
                                          controller.sortReversed.value = !controller.sortReversed.value;
                                        } else {
                                          controller.sortReversed.value = false;
                                        }
                                        LoggerHelper.Logger.instance.d(controller.sortReversed.value);
                                        controller.sortKey.value = newValue!;
                                        controller.getAllTorrents();
                                        controller.update();
                                      }),
                                ),
                              );
                            }),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Obx(
                                () => TextField(
                                  controller: controller.searchController.value,
                                  style: const TextStyle(fontSize: 10),
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    // labelText: '搜索',
                                    hintText: '输入关键词...',
                                    labelStyle: TextStyle(fontSize: 10),
                                    hintStyle: TextStyle(fontSize: 10),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // 在这里处理搜索框输入的内容变化

                                    Logger.instance.i('搜索框内容变化：$value');
                                    controller.searchKey.value = value;
                                    controller.filterTorrents();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    if (controller.downloader.category.toLowerCase() == 'tr')
                      Container(
                        height: 20,
                        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                        child: Row(
                          children: [
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: double.infinity),
                                  child: ShadSelect<String>(
                                      placeholder: const Text('要替换的站点'),
                                      trailing: const Text('要替换的站点'),
                                      initialValue: controller.sortKey.value,
                                      decoration: ShadDecoration(
                                        border: ShadBorder(
                                          merge: false,
                                          bottom: ShadBorderSide(
                                              color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                        ),
                                      ),
                                      options: controller.trSortOptions
                                          .map((item) => ShadOption(value: item['value'], child: Text(item['name']!)))
                                          .toList(),
                                      selectedOptionBuilder: (context, value) {
                                        return Text(value);
                                      },
                                      onChanged: (String? newValue) {
                                        if (controller.sortKey.value == newValue) {
                                          controller.sortReversed.value = !controller.sortReversed.value;
                                        } else {
                                          controller.sortReversed.value = false;
                                        }
                                        LoggerHelper.Logger.instance.d(controller.sortReversed.value);
                                        controller.sortKey.value = newValue!;
                                        controller.getAllTorrents();
                                        controller.update();
                                      }),
                                ),
                              );
                            }),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Obx(
                                () => TextField(
                                  controller: controller.searchController.value,
                                  style: const TextStyle(fontSize: 10),
                                  textAlignVertical: TextAlignVertical.bottom,
                                  decoration: const InputDecoration(
                                    // labelText: '搜索',
                                    hintText: '输入关键词...',
                                    isDense: true,
                                    labelStyle: TextStyle(fontSize: 10),
                                    hintStyle: TextStyle(fontSize: 10),
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    Logger.instance.i('搜索框内容变化：$value');
                                    controller.searchKey.value = value;
                                    controller.filterTorrents();
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    Expanded(
                      child: Obx(() {
                        return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            itemCount: controller.showTorrents.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (controller.downloader.category.toLowerCase() == 'qb') {
                                TorrentInfo torrentInfo = controller.showTorrents[index];
                                return RepaintBoundary(child: _buildQbTorrentCard(torrentInfo, context));
                              } else {
                                TrTorrent torrentInfo = controller.showTorrents[index];
                                return RepaintBoundary(child: _buildTrTorrentCard(torrentInfo, context));
                              }
                            });
                      }),
                    ),
                  ],
                ),
              );
      }),
      endDrawer: Drawer(
        child: controller.downloader.category.toLowerCase() == 'qb'
            ? ListView(
                padding: EdgeInsets.zero,
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
                            backgroundImage:
                                AssetImage('assets/images/${controller.downloader.category.toLowerCase()}.png'),
                          ),
                        ),
                        Text(
                            '${controller.downloader.protocol}://${controller.downloader.host}:${controller.downloader.port}'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: GetBuilder<TorrentController>(builder: (controller) {
                      return SfCartesianChart(
                        plotAreaBorderWidth: 0,
                        tooltipBehavior: tooltipBehavior,
                        primaryXAxis: const CategoryAxis(
                            isVisible: false,
                            majorGridLines: MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift),
                        primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(width: 0),
                            axisLabelFormatter: (AxisLabelRenderDetails details) {
                              return ChartAxisLabel(
                                FileSizeConvert.parseToFileSize(details.value),
                                const TextStyle(fontSize: 10, color: Colors.black38),
                              );
                            },
                            majorTickLines: const MajorTickLines(size: 0)),
                        series: [
                          AreaSeries<TransferInfo, int>(
                            animationDuration: 0,
                            dataSource: controller.statusList.value.cast<TransferInfo>(),
                            enableTooltip: true,
                            xValueMapper: (TransferInfo sales, index) => index,
                            yValueMapper: (TransferInfo sales, _) => sales.dlInfoSpeed,
                            color: Colors.red.withOpacity(0.5),
                            name: '下载速度',
                            borderColor: Colors.black38,
                            borderWidth: 1,
                          ),
                          AreaSeries<TransferInfo, int>(
                            animationDuration: 0,
                            dataSource: controller.statusList.value.cast<TransferInfo>(),
                            enableTooltip: true,
                            xValueMapper: (TransferInfo sales, index) => index,
                            yValueMapper: (TransferInfo sales, _) => sales.upInfoSpeed,
                            color: Colors.blue.withOpacity(0.9),
                            name: '上传速度',
                            borderColor: Colors.black38,
                            borderWidth: 1,
                            borderDrawMode: BorderDrawMode.all,
                          ),
                        ],
                      );
                    }),
                  ),
                  // const ListTile(
                  //   title: Text('筛选'),
                  //   onTap: null,
                  // ),
                  // SizedBox(
                  //   height: 200,
                  //   child: ListView.builder(
                  //       itemCount: controller.filters.length,
                  //       itemBuilder: (context, index) {
                  //         Map state = controller.filters[index];
                  //         return Obx(() {
                  //           return ListTile(
                  //             dense: true,
                  //             title: Text(
                  //               '${state['name']}${controller.torrentFilter.value == state['value'] ? "(${controller.torrents.length})" : ""}',
                  //               style: const TextStyle(
                  //                 fontSize: 12,
                  //               ),
                  //             ),
                  //             style: ListTileStyle.list,
                  //             selected: controller.torrentFilter.value ==
                  //                 state['value'],
                  //             selectedColor: Colors.purple,
                  //             onTap: () {
                  //               // controller.category.value = 'all_torrents';
                  //               controller.torrentState.value = null;
                  //               LoggerHelper.Logger.instance.d(state['value']);
                  //               controller.torrentFilter.value = state['value'];
                  //               controller.filterTorrents();
                  //             },
                  //           );
                  //         });
                  //       }),
                  // ),
                  const ListTile(
                    title: Text('状态'),
                    onTap: null,
                  ),
                  SizedBox(
                      height: 220,
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ListView.builder(
                            itemCount: controller.status.length,
                            itemBuilder: (context, index) {
                              Map state = controller.status[index];
                              return Obx(() {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${state['name']}(${controller.torrents.where((torrent) => torrent.state == state['value']).toList().length})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: ListTileStyle.list,
                                  selected: controller.torrentState.value == state['value'],
                                  selectedColor: Colors.purple,
                                  onTap: () {
                                    LoggerHelper.Logger.instance.d(state['value']);
                                    controller.torrentState.value = state['value'];
                                    controller.filterTorrents();
                                  },
                                );
                              });
                            }),
                      )),
                  const ListTile(
                    title: Text('分类'),
                    onTap: null,
                  ),
                  SizedBox(
                    height: 220,
                    child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: Obx(() {
                        return ListView.builder(
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              Map category = controller.categories[index];
                              int count = 0;
                              if (category['value'] == 'all_torrents') {
                                count = controller.torrents.length;
                              } else {
                                count = controller.torrents
                                    .where((torrent) => torrent.category == category['value'])
                                    .toList()
                                    .length;
                              }

                              return Obx(() {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${category['name']}($count)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: controller.category.value == category['value'],
                                  selectedColor: Colors.purple,
                                  onTap: () {
                                    controller.torrentFilter.value = TorrentFilter.all;
                                    controller.category.value = category['value'];
                                    controller.filterTorrents();
                                  },
                                );
                              });
                            });
                      }),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
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
                            backgroundImage:
                                AssetImage('assets/images/${controller.downloader.category.toLowerCase()}.png'),
                          ),
                        ),
                        Text(
                            '${controller.downloader.protocol}://${controller.downloader.host}:${controller.downloader.port}'),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: SfCartesianChart(
                      plotAreaBorderWidth: 0,
                      tooltipBehavior: tooltipBehavior,
                      primaryXAxis: const CategoryAxis(
                          isVisible: false,
                          majorGridLines: MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.none),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              FileSizeConvert.parseToFileSize(details.value),
                              const TextStyle(fontSize: 10, color: Colors.black38),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: <AreaSeries<TransmissionStats, int>>[
                        AreaSeries<TransmissionStats, int>(
                          animationDuration: 0,
                          dataSource: controller.statusList.value.cast<TransmissionStats>(),
                          xValueMapper: (TransmissionStats sales, index) => index,
                          yValueMapper: (TransmissionStats sales, _) => sales.uploadSpeed,
                          name: '上传速度',
                          borderColor: Colors.black38,
                          borderWidth: 1,
                        ),
                        AreaSeries<TransmissionStats, int>(
                          animationDuration: 0,
                          dataSource: controller.statusList.value.cast<TransmissionStats>(),
                          xValueMapper: (TransmissionStats sales, index) => index,
                          yValueMapper: (TransmissionStats sales, _) => sales.downloadSpeed,
                          enableTooltip: true,
                          name: '下载速度',
                          borderColor: Colors.black38,
                          borderWidth: 1,
                        ),
                      ],
                    ),
                  ),
                  const ListTile(
                    dense: true,
                    title: Text('状态'),
                    onTap: null,
                  ),
                  SizedBox(
                      height: 200,
                      child: MediaQuery.removePadding(
                        removeTop: true,
                        context: context,
                        child: ListView.builder(
                            itemCount: controller.trStatus.length,
                            itemBuilder: (context, index) {
                              final Map state = controller.trStatus[index];
                              return Obx(() {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${state['name']}(${state['value'] == null ? controller.torrents.length : controller.torrents.where((torrent) => torrent.status == state['value']).toList().length})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: ListTileStyle.list,
                                  selected: controller.trTorrentState.value == state['value'],
                                  selectedColor: Colors.purple,
                                  onTap: () {
                                    LoggerHelper.Logger.instance.d(state['value']);
                                    controller.trTorrentState.value = state['value'];
                                    controller.filterTorrents();
                                  },
                                );
                              });
                            }),
                      )),
                  const ListTile(
                    dense: true,
                    title: Text('保存路径'),
                    onTap: null,
                  ),
                  SizedBox(
                    height: 200,
                    child: MediaQuery.removePadding(
                      removeTop: true,
                      context: context,
                      child: Obx(() {
                        return ListView.builder(
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              Map category = controller.categories[index];
                              int count = 0;
                              if (category['value'] == 'all_torrents') {
                                count = controller.torrents.length;
                              } else {
                                count = controller.torrents
                                    .where((torrent) =>
                                        torrent.downloadDir.replaceAll(RegExp(r'\/$'), '') == category['value'])
                                    .toList()
                                    .length;
                              }

                              return Obx(() {
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${category['name']}($count)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  selected: controller.category.value == category['value'],
                                  selectedColor: Colors.purple,
                                  onTap: () {
                                    controller.torrentFilter.value = TorrentFilter.all;
                                    controller.category.value = category['value'];
                                    controller.filterTorrents();
                                  },
                                );
                              });
                            });
                      }),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            var isTimerActive = controller.isTimerActive.value;
            return ShadIconButton(
              icon: isTimerActive ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
              onPressed: () {
                // controller.cancelPeriodicTimer();
                isTimerActive ? controller.cancelPeriodicTimer() : controller.startPeriodicTimer();
                LoggerHelper.Logger.instance.d(controller.periodicTimer?.isActive);
                LoggerHelper.Logger.instance.d(isTimerActive);
                controller.update();
              },
            );
          }),
          ShadIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              Get.bottomSheet(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                enableDrag: true,
                CustomCard(
                  height: 400,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '添加种子',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        child: DownloadForm(
                          categories: controller.categoryList,
                          downloader: controller.downloader,
                          info: null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 72)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildDownloaderInfo() {
    if (controller.downloader.status.isEmpty) {
      return Center(child: const CircularProgressIndicator());
    }
    if (controller.downloader.category.toLowerCase() == 'qb') {
      TransferInfo res = controller.downloader.status.last;
      return Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        const Icon(
                          Icons.upload_outlined,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${FileSizeConvert.parseToFileSize(res.upInfoSpeed!)}/S',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.download_outlined,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${FileSizeConvert.parseToFileSize(res.dlInfoSpeed!)}/S',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        ),
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
                          Icons.cloud_upload_rounded,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          FileSizeConvert.parseToFileSize(res.upInfoData),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_download_rounded,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          FileSizeConvert.parseToFileSize(res.dlInfoData),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '上传限速：${FileSizeConvert.parseToFileSize(res.upRateLimit)}/S',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '下载限速：${FileSizeConvert.parseToFileSize(res.dlRateLimit)}/S',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      });
    } else {
      TransmissionStats res = controller.downloader.status.last;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.upload_outlined,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${FileSizeConvert.parseToFileSize(res.uploadSpeed)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.download_outlined,
                        color: Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${FileSizeConvert.parseToFileSize(res.downloadSpeed, 0)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        FileSizeConvert.parseToFileSize(res.currentStats.uploadedBytes),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_download_rounded,
                        color: Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        FileSizeConvert.parseToFileSize(res.currentStats.downloadedBytes),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildQbTorrentCard(TorrentInfo torrentInfo, context) {
    bool paused = torrentInfo.state.toString().contains('pause');
    bool deleteFile = false;
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.all(2.5),
      child: Slidable(
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
                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                  middleText: '确定要删除种子吗？',
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatefulBuilder(builder: (context, setInnerState) {
                        return ShadCheckbox(
                          size: 18,
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
                            command: 'delete', hashes: [torrentInfo.hash!], deleteFiles: deleteFile);
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
                await controller.controlTorrents(command: paused ? 'resume' : 'pause', hashes: [torrentInfo.hash!]);
              },
              flex: 2,
              backgroundColor: paused ? const Color(0xFF0392CF) : Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              icon: paused ? Icons.play_arrow : Icons.pause,
              label: paused ? '开始' : '暂停',
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
                    command: 'AutoManagement', hashes: [torrentInfo.hash!], enable: !torrentInfo.autoTmm!);
              },
              flex: 2,
              backgroundColor: torrentInfo.autoTmm! ? Colors.lightBlue : Colors.deepOrangeAccent,
              foregroundColor: Colors.white,
              icon: torrentInfo.autoTmm! ? Icons.auto_awesome : Icons.man,
              label: torrentInfo.autoTmm! ? '自动' : '手动',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            Get.bottomSheet(
              CustomCard(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: ListView(
                  children: [
                    Tooltip(
                      message: torrentInfo.name!,
                      child: Text(
                        torrentInfo.name!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                    Text(torrentInfo.state.toString().contains('pause').toString()),
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
                      '已完成: ${FileSizeConvert.parseToFileSize(torrentInfo.completed)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      '完成时间: ${formatTimestampToDateTime(torrentInfo.completionOn!)}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    if (torrentInfo.amountLeft! > 0)
                      Text(
                        '剩余大小: ${FileSizeConvert.parseToFileSize(torrentInfo.amountLeft)}',
                        style: const TextStyle(fontSize: 10),
                      ),

                    SizedBox(
                      height: 8,
                      // width: 100,
                      child: ShadProgress(
                        value: torrentInfo.progress!,
                        color: ShadTheme.of(context).colorScheme.background,
                        backgroundColor: ShadTheme.of(context).colorScheme.primary,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShadButton(
                          onPressed: () async {
                            Get.defaultDialog(
                                title: '',
                                middleText: '重新校验种子？',
                                onConfirm: () async {
                                  await controller.controlTorrents(command: 'recheck', hashes: [torrentInfo.hash!]);
                                },
                                cancel: const Text('取消'),
                                confirm: const Text('确定'));
                          },
                          leading: const Icon(Icons.auto_mode, size: 10),
                          child: Text('重新校验'),
                        ),
                        ShadButton(
                          onPressed: () async {
                            await controller.controlTorrents(command: 'reannounce', hashes: [torrentInfo.hash!]);
                          },
                          leading: const Icon(Icons.campaign, size: 10),
                          child: Text('强制汇报'),
                        ),
                        ShadButton(
                          onPressed: () async {
                            Clipboard.setData(ClipboardData(text: torrentInfo.hash!));
                            Get.snackbar('复制种子HASH', '种子HASH复制成功！', colorText: Theme.of(context).colorScheme.primary);
                          },
                          leading: const Icon(Icons.copy, size: 10),
                          child: Text('复制哈希'),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShadButton(
                          child: Text('自动TMM: ${torrentInfo.autoTmm! ? "✔" : "✖"}'),
                          onPressed: () async {
                            await controller.controlTorrents(
                                command: 'AutoManagement', hashes: [torrentInfo.hash!], enable: !torrentInfo.autoTmm!);
                          },
                        ),
                        ShadButton(
                          child: Text('超级做种: ${torrentInfo.superSeeding! ? "✔" : "✖"}'),
                          onPressed: () async {
                            await controller.controlTorrents(
                                command: 'SuperSeeding',
                                hashes: [torrentInfo.hash!],
                                enable: !torrentInfo.superSeeding!);
                          },
                        ),
                        ShadButton(
                          child: Text('强制开始: ${torrentInfo.forceStart! ? "✔" : "✖"}'),
                          onPressed: () async {
                            await controller.controlTorrents(
                                command: 'ForceStart', hashes: [torrentInfo.hash!], enable: !torrentInfo.forceStart!);
                          },
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 200,
                      child: GridView(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  torrentInfo.category!.isNotEmpty ? torrentInfo.category! : '未分类',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, color: Colors.white),
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
                                    (element) => element['value'] == torrentInfo.state!,
                                    orElse: () => {"name": "未知状态", "value": TorrentState.unknown},
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
                                  FileSizeConvert.parseToFileSize(torrentInfo.totalSize!),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  FileSizeConvert.parseToFileSize(torrentInfo.size!),
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
                                  '本次: ${FileSizeConvert.parseToFileSize(torrentInfo.uploadedSession)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  '共: ${FileSizeConvert.parseToFileSize(torrentInfo.uploaded)}',
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
                                  '速度: ${FileSizeConvert.parseToFileSize(torrentInfo.upSpeed)}/S',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  '限速: ${FileSizeConvert.parseToFileSize(torrentInfo.upLimit)}/S',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('已下载'),
                                Text(
                                  '已下载: ${FileSizeConvert.parseToFileSize(torrentInfo.downloaded)}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                                Text(
                                  '本次已下载: ${FileSizeConvert.parseToFileSize(torrentInfo.downloadedSession)}',
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
                ),
              ),
              backgroundColor: Colors.grey,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              isScrollControlled: true,
              enableDrag: true,
            );
          },
          // onLongPress: () {
          //   Get.snackbar('长按', '长按！',colorText: Theme.of(context).colorScheme.primary);
          // },
          // onDoubleTap: () {
          //   Get.snackbar('双击', '双击！',colorText: Theme.of(context).colorScheme.primary);
          // },
          child: Column(
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
                        basic_utils.DomainUtils.getDomainFromUrl(Uri.parse(torrentInfo.tracker!).host).toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
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
                          FileSizeConvert.parseToFileSize(torrentInfo.size),
                          style: const TextStyle(fontSize: 10, color: Colors.black38),
                        ),
                        SizedBox(
                          height: 12,
                          child: ShadButton(
                            child: controller.status.firstWhere(
                              (element) => element['value'] == torrentInfo.state!,
                              orElse: () => {"name": "未知状态", "value": TorrentState.unknown},
                            )['name'],
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
                        style: const TextStyle(fontSize: 11, color: Colors.black38),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  Text(
                    torrentInfo.category!.isNotEmpty ? torrentInfo.category! : '未分类',
                    style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                          const Icon(Icons.upload, size: 12, color: Colors.black38),
                          Text(FileSizeConvert.parseToFileSize(torrentInfo.upSpeed),
                              style: const TextStyle(fontSize: 10, color: Colors.black38))
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.cloud_upload, size: 12, color: Colors.black38),
                          Text(FileSizeConvert.parseToFileSize(torrentInfo.uploaded),
                              style: const TextStyle(fontSize: 10, color: Colors.black38))
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.download, size: 12, color: Colors.black38),
                          Text(FileSizeConvert.parseToFileSize(torrentInfo.dlSpeed),
                              style: const TextStyle(fontSize: 10, color: Colors.black38))
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.cloud_download, size: 12, color: Colors.black38),
                          Text(FileSizeConvert.parseToFileSize(torrentInfo.downloaded),
                              style: const TextStyle(fontSize: 10, color: Colors.black38))
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
                            text: formatDuration(torrentInfo.timeActive!).toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                                .format(DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedOn! * 1000))
                                .toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
                            maxLines: 1,
                            ellipsis: '...',
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 8,
                // width: 100,
                child: ShadProgress(
                  value: torrentInfo.progress!,
                  color: ShadTheme.of(context).colorScheme.background,
                  backgroundColor: ShadTheme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrTorrentCard(TrTorrent torrentInfo, context) {
    bool deleteFile = false;
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
                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                  middleText: '确定要删除种子吗？',
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StatefulBuilder(builder: (context, setInnerState) {
                        return ShadCheckbox(
                          size: 18,
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
                            command: 'delete', hashes: [torrentInfo.hashString], deleteFiles: deleteFile);
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
                            command: torrentInfo.status == 0 ? 'resume' : 'pause', hashes: [torrentInfo.hashString]);
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
                        await controller.controlTorrents(command: 'reannounce', hashes: [torrentInfo.hashString]);
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
        child: GestureDetector(
            onTap: () {
              Get.snackbar('单击', '单击！', colorText: Theme.of(context).colorScheme.primary);
            },
            // onLongPress: () {
            //   Get.snackbar('长按', '长按！',colorText: Theme.of(context).colorScheme.primary);
            // },
            // onDoubleTap: () {
            //   Get.snackbar('双击', '双击！',colorText: Theme.of(context).colorScheme.primary);
            // },
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
                          basic_utils.DomainUtils.getDomainFromUrl(torrentInfo.trackerStats.first.announce)!.toString(),
                          style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                            style: const TextStyle(fontSize: 10, color: Colors.black38),
                          ),
                          SizedBox(
                            height: 12,
                            child: ShadButton(
                              child: controller.trStatus.firstWhere(
                                (element) => element['value'] == torrentInfo.status,
                                orElse: () => {"name": "未知状态", "value": TorrentState.unknown},
                              )['name'],
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
                        message: torrentInfo.name,
                        child: Text(
                          torrentInfo.name,
                          style: const TextStyle(fontSize: 11, color: Colors.black38, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    Text(
                      torrentInfo.downloadDir.isNotEmpty ? torrentInfo.downloadDir : '未分类',
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                            const Icon(Icons.upload, size: 12, color: Colors.black38),
                            Text(FileSizeConvert.parseToFileSize(torrentInfo.rateUpload),
                                style: const TextStyle(fontSize: 10, color: Colors.black38))
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cloud_upload, size: 12, color: Colors.black38),
                            Text(FileSizeConvert.parseToFileSize(torrentInfo.uploadedEver),
                                style: const TextStyle(fontSize: 10, color: Colors.black38))
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.download, size: 12, color: Colors.black38),
                            Text(FileSizeConvert.parseToFileSize(torrentInfo.rateDownload),
                                style: const TextStyle(fontSize: 10, color: Colors.black38))
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.cloud_download, size: 12, color: Colors.black38),
                            Text(FileSizeConvert.parseToFileSize(torrentInfo.downloadedEver),
                                style: const TextStyle(fontSize: 10, color: Colors.black38))
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
                              text: formatDuration(torrentInfo.activityDate).toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.black38),
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
                                  .format(DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedDate * 1000))
                                  .toString(),
                              style: const TextStyle(fontSize: 10, color: Colors.black38),
                              maxLines: 1,
                              ellipsis: '...',
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                  // width: 100,
                  child: ShadProgress(
                    value: torrentInfo.percentDone.toDouble(),
                    color: ShadTheme.of(context).colorScheme.background,
                    backgroundColor: ShadTheme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
