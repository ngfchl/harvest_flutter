import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/pages/download/qb_file_tree_view.dart';
import 'package:harvest/app/home/pages/download/qbittorrent.dart';
import 'package:harvest/app/home/pages/download/tr_tree_file_view.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart' as qb;
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/meta_item.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../../../utils/storage.dart';
import '../../../torrent/models/transmission_base_torrent.dart';
import '../agg_search/download_form.dart';
import '../models/transmission.dart';
import 'download_controller.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final controller = Get.put(DownloadController(true));

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: GetBuilder<DownloadController>(builder: (controller) {
                return StreamBuilder<List<Downloader>>(
                    stream: controller.downloadStream,
                    // initialData: controller.dataList,
                    builder: (context, snapshot) {
                      controller.isLoaded = snapshot.hasData;
                      return EasyRefresh(
                          controller: EasyRefreshController(),
                          onRefresh: () async {
                            controller.getDownloaderListFromServer();
                          },
                          child: Stack(
                            children: [
                              ListView.builder(
                                  itemCount: controller.dataList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Downloader downloader =
                                        controller.dataList[index];
                                    return buildDownloaderCard(downloader);
                                  }),
                              if (!controller.isLoaded)
                                const Center(child: CircularProgressIndicator())
                            ],
                          ));
                    });
              }),
            ),
            if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
            const SizedBox(height: 50),
          ],
        ),
        floatingActionButton: _buildBottomButtonBar(),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
      ),
    );
  }

  _buildBottomButtonBar() {
    return GetBuilder<DownloadController>(builder: (controller) {
      return CustomCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // IconButton(
            //   icon: Icon(
            //     controller.isTimerActive ? Icons.pause : Icons.play_arrow,
            //     size: 20,
            //     color: Theme.of(context).colorScheme.primary,
            //   ),
            //   onPressed: () => controller.toggleRealTimeState(),
            // ),
            IconButton(
              icon: Icon(
                controller.isLoading ? Icons.pause : Icons.play_arrow,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => controller.toggleFetchStatus(),
            ),
            IconButton(
                icon: Icon(
                  Icons.settings,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  Get.bottomSheet(
                    GetBuilder<DownloadController>(builder: (controller) {
                      return CustomCard(
                        padding: const EdgeInsets.all(12),
                        height: 200,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SwitchListTile(
                                dense: true,
                                title: Text(
                                  '状态刷新',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                value: controller.realTimeState,
                                onChanged: (bool value) async {
                                  controller.realTimeState = value;
                                  await SPUtil.setBool('realTimeState', value);
                                  if (value == false) {
                                    await controller.stopFetchStatus();
                                  } else {
                                    await controller.getDownloaderStatus();
                                  }
                                  controller.update();
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  children: [
                                    CustomTextTag(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        labelText:
                                            '刷新间隔：${controller.duration}秒'),
                                    InkWell(
                                      child: const Icon(Icons.remove),
                                      onTap: () {
                                        if (controller.duration.toInt() > 1) {
                                          controller.duration--;
                                          SPUtil.setDouble(
                                              'duration', controller.duration);
                                          controller.stopFetchStatus();
                                          controller.getDownloaderStatus();
                                          controller.update();
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Slider(
                                          min: 1,
                                          max: 15,
                                          divisions: 12,
                                          label: controller.duration.toString(),
                                          value: controller.duration.toDouble(),
                                          onChanged: (duration) {
                                            controller.duration = duration;
                                            SPUtil.setDouble('duration',
                                                controller.duration);
                                            controller.update();
                                          }),
                                    ),
                                    InkWell(
                                      child: const Icon(Icons.add),
                                      onTap: () {
                                        if (controller.duration.toInt() < 15) {
                                          controller.duration++;
                                          SPUtil.setDouble(
                                              'duration', controller.duration);
                                          controller.update();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  children: [
                                    CustomTextTag(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        labelText:
                                            '刷新时长：${controller.timerDuration}分'),
                                    InkWell(
                                      child: const Icon(Icons.remove),
                                      onTap: () {
                                        if (controller.timerDuration.toInt() >
                                            3) {
                                          controller.timerDuration--;
                                          SPUtil.setDouble('timerDuration',
                                              controller.timerDuration);
                                          controller.update();
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Slider(
                                          min: 3,
                                          max: 15,
                                          divisions: 12,
                                          label: controller.timerDuration
                                              .toString(),
                                          value: controller.timerDuration
                                              .toDouble(),
                                          onChanged: (duration) {
                                            controller.timerDuration = duration;
                                            SPUtil.setDouble(
                                                'timerDuration', duration);
                                            controller.update();
                                          }),
                                    ),
                                    InkWell(
                                      child: const Icon(Icons.add),
                                      onTap: () {
                                        if (controller.timerDuration.toInt() <
                                            15) {
                                          controller.timerDuration++;
                                          SPUtil.setDouble('timerDuration',
                                              controller.timerDuration);
                                          controller.update();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  );
                }),
            IconButton(
              icon: Icon(
                Icons.add,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                _showEditBottomSheet();
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLiveLineChart(
      Downloader downloader, ChartSeriesController? chartSeriesController) {
    if (!downloader.isActive) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dangerous,
            color: Colors.red,
          ),
          Text('下载器已禁用！'),
        ],
      );
    }
    if (downloader.status.isEmpty) {
      return GFLoader(
        type: GFLoaderType.square,
        loaderstrokeWidth: 2,
        loaderColorOne: Theme.of(context).colorScheme.primary,
        loaderColorTwo: Theme.of(context).colorScheme.primary,
        loaderColorThree: Theme.of(context).colorScheme.primary,
        size: 16,
      );
    }
    double chartHeight = 80;
    var tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      decimalPlaces: 1,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        return Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Text(
            '${series.name}: ${filesize(point.y)}',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        );
      },
    );
    if (downloader.category.toLowerCase() == 'qb') {
      List<qb.ServerState> dataSource =
          downloader.status.cast<qb.ServerState>();
      chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[dataSource.length - 1],
      );
      qb.ServerState res = downloader.status.last;

      return SizedBox(
        height: chartHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SfCartesianChart(
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
                              filesize(details.value),
                              const TextStyle(
                                fontSize: 10,
                              ),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: [
                        AreaSeries<qb.ServerState, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (qb.ServerState sales, index) => index,
                          yValueMapper: (qb.ServerState sales, _) =>
                              sales.dlInfoSpeed,
                          color: Colors.red.withOpacity(0.5),
                          name: '下载速度',
                          borderWidth: 1,
                        ),
                        AreaSeries<qb.ServerState, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (qb.ServerState sales, index) => index,
                          yValueMapper: (qb.ServerState sales, _) =>
                              sales.upInfoSpeed,
                          color: Colors.blue.withOpacity(0.9),
                          name: '上传速度',
                          borderWidth: 1,
                          borderDrawMode: BorderDrawMode.all,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '上传限速：${filesize(res.upRateLimit)}/s',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '下载限速：${filesize(res.dlRateLimit)}/s',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            getSpeedInfo(downloader),
          ],
        ),
      );
    } else {
      List<TransmissionStats> dataSource =
          downloader.status.cast<TransmissionStats>();
      TransmissionStats res = downloader.status.last;
      return SizedBox(
        height: chartHeight,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
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
                              filesize(details.value),
                              const TextStyle(fontSize: 10),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: <AreaSeries<TransmissionStats, int>>[
                        AreaSeries<TransmissionStats, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) =>
                              index,
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.uploadSpeed,
                          color: Colors.blue.withOpacity(0.9),
                          name: '上传速度',
                          borderWidth: 1,
                        ),
                        AreaSeries<TransmissionStats, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            // _chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) =>
                              index,
                          yValueMapper: (TransmissionStats sales, _) =>
                              sales.downloadSpeed,
                          color: Colors.red.withOpacity(0.9),
                          enableTooltip: true,
                          name: '下载速度',
                          borderWidth: 1,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '活动种子：${res.activeTorrentCount}',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const SizedBox(width: 8),
                      if (downloader.prefs.speedLimitUpEnabled == true)
                        Text(
                          '上传限速：${filesize(downloader.prefs.speedLimitUp * 1024)}/s',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (downloader.prefs.speedLimitDownEnabled == true)
                        Text(
                          '下载限速：${filesize(downloader.prefs.speedLimitDown * 1024)}/s',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            getSpeedInfo(downloader),
          ],
        ),
      );
    }
  }

  Widget buildDownloaderCard(Downloader downloader) {
    RxBool connectState = true.obs;
    bool isQb = downloader.category == 'Qb';
    if (downloader.isActive) {
      controller.testConnect(downloader).then((res) {
        connectState.value = res.succeed;
      });
    } else {
      connectState.value = false;
    }
    ChartSeriesController? chartSeriesController;
    var pathDownloader =
        '${downloader.protocol}://${downloader.host}:${downloader.port}';
    return CustomCard(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 2),
      child: Slidable(
        key: ValueKey('${downloader.id}_${downloader.name}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                CommonResponse res =
                    controller.reseedDownloader(downloader.id!);
                if (res.code == 0) {
                  Get.snackbar('辅种通知', res.msg.toString(),
                      colorText: Theme.of(context).colorScheme.primary);
                } else {
                  Get.snackbar('辅种通知', res.msg.toString(),
                      colorText: Theme.of(context).colorScheme.error);
                }
              },
              backgroundColor: const Color(0xFF0A9D96),
              foregroundColor: Colors.white,
              icon: Icons.copy_sharp,
              label: '辅种',
            ),
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                _showEditBottomSheet(downloader: downloader);
              },
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              // icon: Icons.edit,
              label: '编辑',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                Get.defaultDialog(
                  title: '确认',
                  radius: 5,
                  titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.deepPurple),
                  middleText: '确定要删除任务吗？',
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
                        CommonResponse res =
                            await controller.removeDownloader(downloader);
                        if (res.code == 0) {
                          Get.snackbar('删除通知', res.msg.toString(),
                              colorText: Theme.of(context).colorScheme.primary);
                        } else {
                          Get.snackbar('删除通知', res.msg.toString(),
                              colorText: Theme.of(context).colorScheme.error);
                        }
                      },
                      child: const Text('确认'),
                    ),
                  ],
                );
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              // icon: Icons.delete,
              label: '删除',
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Column(
            children: [
              GFListTile(
                padding: const EdgeInsets.all(0),
                avatar: GFAvatar(
                  // shape: GFAvatarShape.square,
                  backgroundImage: AssetImage(
                      'assets/images/${downloader.category.toLowerCase()}.png'),
                  size: 18,
                ),
                title: Text(
                  downloader.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary),
                ),
                subTitle: Text(
                  pathDownloader,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () async {
                  _showTorrents(downloader);
                  // controller.cancelPeriodicTimer();
                  // if (downloader.category == 'Qb') {
                  //   if (kIsWeb) {
                  //     Uri uri = Uri.parse(pathDownloader);
                  //     await launchUrl(uri,
                  //         mode: LaunchMode.externalApplication);
                  //   } else {
                  //     Get.toNamed(Routes.QB, arguments: downloader);
                  //   }
                  // }
                  // if (downloader.category == 'Tr') {
                  //   Get.toNamed(Routes.TR, arguments: downloader);
                  //   // Get.toNamed(Routes.TORRENT, arguments: downloader);
                  // }
                },
                onLongPress: () async {
                  _showEditBottomSheet(downloader: downloader);
                },
                icon: GFIconButton(
                  icon: connectState.value
                      ? const Icon(
                          Icons.bolt,
                          color: Colors.green,
                          size: 24,
                        )
                      : const Icon(
                          Icons.offline_bolt_outlined,
                          color: Colors.red,
                          size: 24,
                        ),
                  type: GFButtonType.transparent,
                  onPressed: () {
                    controller.testConnect(downloader).then((res) {
                      connectState.value = res.succeed;
                      Get.snackbar(
                        '下载器连接测试',
                        res.msg,
                        colorText: res.code == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      );
                    });
                  },
                ),
              ),
              GetBuilder<DownloadController>(builder: (controller) {
                return controller.isLoading
                    ? _buildLiveLineChart(downloader, chartSeriesController)
                    : const SizedBox.shrink();
              }),
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          _showTorrents(downloader);
                        },
                        icon: Icon(
                          Icons.list_alt_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    IconButton(
                        onPressed: () => isQb
                            ? _showQbPrefs(downloader, context)
                            : _showTrPrefs(downloader, context),
                        icon: Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    (downloader.status.isNotEmpty &&
                            (isQb
                                ? downloader.status.last?.useAltSpeedLimits ==
                                    true
                                : downloader.prefs.altSpeedEnabled == true))
                        ? IconButton(
                            onPressed: () =>
                                controller.toggleSpeedLimit(downloader, false),
                            icon: Icon(
                              Icons.nordic_walking_sharp,
                              size: 18,
                              color: Theme.of(context).colorScheme.error,
                            ))
                        : IconButton(
                            onPressed: () =>
                                controller.toggleSpeedLimit(downloader, true),
                            icon: Icon(
                              Icons.electric_bolt_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.speed_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getSpeedInfo(Downloader downloader) {
    if (downloader.status.isEmpty) {
      return const GFLoader();
    }
    if (downloader.category == 'Qb') {
      qb.ServerState res = downloader.status.last;

      return Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
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
                      '${filesize(res.upInfoSpeed!)}/S',
                      style: const TextStyle(
                        fontSize: 10,
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
                      '${filesize(res.dlInfoSpeed!)}/S',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_upload_rounded,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      filesize(res.upInfoData),
                      style: const TextStyle(
                        fontSize: 10,
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
                      filesize(res.dlInfoData),
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],
            ),
          ),
        ],
      );
    } else {
      TransmissionStats res = downloader.status.last;
      return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
                  '${filesize(res.uploadSpeed)}/S',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.download_outlined,
                  color: Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${filesize(res.downloadSpeed, 0)}/S',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.cloud_upload_rounded,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  filesize(res.currentStats.uploadedBytes),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
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
                  filesize(res.currentStats.downloadedBytes),
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.pause,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${res.pausedTorrentCount}',
                  style: const TextStyle(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void _showEditBottomSheet({Downloader? downloader}) async {
    final nameController =
        TextEditingController(text: downloader?.name ?? 'QBittorrent');
    final categoryController =
        TextEditingController(text: downloader?.category ?? 'Qb');
    final usernameController =
        TextEditingController(text: downloader?.username ?? '');
    final passwordController =
        TextEditingController(text: downloader?.password ?? '');
    final protocolController =
        TextEditingController(text: downloader?.protocol ?? 'http');

    final hostController = TextEditingController(text: downloader?.host ?? '');
    final portController =
        TextEditingController(text: downloader?.port.toString() ?? '');

    final torrentPathController =
        TextEditingController(text: downloader?.torrentPath ?? '');

    RxBool isActive = downloader != null ? downloader.isActive.obs : true.obs;
    RxBool brush = downloader != null ? downloader.brush.obs : false.obs;
    final response = await controller.getTorrentsPathList();
    if (response.code == 0) {
      controller.pathList = [
        for (final item in response.data)
          if (item['path'] is String) item['path'].toString()
      ];
      controller.update();
    } else {
      Get.snackbar(
        '获取种子文件夹出错啦！',
        response.msg!,
        snackPosition: SnackPosition.TOP,
        colorText: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      );
    }
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      CustomCard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GFTypography(
                text: downloader != null ? '编辑下载器：${downloader.name}' : '添加下载器',
                icon: const Icon(Icons.add),
                dividerWidth: 128,
                textColor: Theme.of(context).colorScheme.onSurface,
                dividerColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomPickerField(
                      controller: categoryController,
                      labelText: '选择分类',
                      data: const ["Qb", "Tr"],
                    ),
                    CustomPickerField(
                      controller: protocolController,
                      labelText: '选择协议',
                      data: const ["http", "https"],
                    ),
                    CustomTextField(
                      controller: nameController,
                      labelText: '名称',
                    ),
                    CustomTextField(
                      controller: usernameController,
                      labelText: '账户',
                    ),
                    CustomTextField(
                      controller: passwordController,
                      labelText: '密码',
                    ),
                    CustomTextField(
                      controller: hostController,
                      labelText: 'HOST',
                    ),
                    CustomTextField(
                      controller: portController,
                      labelText: '端口',
                    ),
                    CustomPickerField(
                      controller: torrentPathController,
                      labelText: '选择路径',
                      data: controller.pathList,
                    ),
                    const SizedBox(height: 5),
                    Obx(() {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SwitchTile(
                                title: '可用',
                                value: isActive.value,
                                onChanged: (value) {
                                  isActive.value = value;
                                },
                              ),
                            ),
                            Expanded(
                                child: SwitchTile(
                              title: '刷流',
                              value: brush.value,
                              onChanged: (value) {
                                brush.value = value;
                              },
                            )),
                          ]);
                    }),
                  ],
                ),
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        Theme.of(context).colorScheme.primary),
                  ),
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    if (downloader != null) {
                      // 如果 downloader 不为空，表示是修改操作
                      downloader?.name = nameController.text;
                      downloader?.category = categoryController.text;
                      downloader?.username = usernameController.text;
                      downloader?.password = passwordController.text;
                      downloader?.protocol = protocolController.text;
                      downloader?.host = hostController.text;
                      downloader?.port = int.parse(portController.text);
                      downloader?.torrentPath = torrentPathController.text;
                      downloader?.isActive = isActive.value;
                      downloader?.brush = brush.value;
                    } else {
                      // 如果 downloader 为空，表示是添加操作
                      downloader = Downloader(
                        id: 0,
                        name: nameController.text,
                        category: categoryController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                        protocol: protocolController.text,
                        host: hostController.text,
                        port: int.parse(portController.text),
                        torrentPath: torrentPathController.text,
                        isActive: isActive.value,
                        brush: brush.value,
                        status: [],
                      );
                    }
                    logger_helper.Logger.instance.i(downloader?.toJson());
                    CommonResponse response =
                        await controller.saveDownloaderToServer(downloader!);
                    if (response.code == 0) {
                      Navigator.of(context).pop();
                      Get.snackbar(
                        '保存成功！',
                        response.msg,
                        snackPosition: SnackPosition.TOP,
                        colorText: Theme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 3),
                      );
                      await controller.getDownloaderListFromServer();
                      controller.update();
                    } else {
                      Get.snackbar(
                        '保存出错啦！',
                        response.msg,
                        snackPosition: SnackPosition.TOP,
                        colorText: Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 当应用程序重新打开时，重新加载数据
      controller.getDownloaderListFromServer();
    }
  }

  void _showTorrents(Downloader downloader) async {
    try {
      controller.getDownloaderTorrents(downloader);
      bool isQb = downloader.category == 'Qb';

      Get.bottomSheet(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // 圆角半径
          ),
          isScrollControlled: true,
          GetBuilder<DownloadController>(builder: (controller) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.92,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Row(
                  children: [
                    Text(
                        '${downloader.name} (${controller.torrents.isNotEmpty ? controller.torrents.length : 'loading'})'),
                    // if (controller.torrents.isEmpty)
                    //   const SizedBox(
                    //     height: 24,
                    //     width: 24,
                    //     child: Center(
                    //       child: CircularProgressIndicator(),
                    //     ),
                    //   )
                  ],
                ),
                actions: [
                  if (controller.serverStatus.isNotEmpty)
                    Text(
                      filesize(controller.serverStatus.last.freeSpaceOnDisk),
                      style: const TextStyle(color: Colors.red),
                    ),
                  IconButton(
                      onPressed: () async {
                        await controller.stopFetchTorrents();
                        Get.back();
                      },
                      icon: const Icon(Icons.exit_to_app_outlined)),
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
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              onTap: () async {
                                CommonResponse res =
                                    await controller.removeErrorTracker();
                                Get.snackbar('清理红种', res.msg,
                                    colorText: res.code == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error);
                                controller.update();
                              },
                            ),
                            // PopupMenuItem<String>(
                            //   child: Center(
                            //     child: Text(
                            //       '切换限速',
                            //       style: TextStyle(
                            //         color:
                            //             Theme.of(context).colorScheme.primary,
                            //       ),
                            //     ),
                            //   ),
                            //   onTap: () async {
                            //     await controller.toggleSpeedLimit();
                            //   },
                            // ),
                            PopupMenuItem<String>(
                              child: Center(
                                  child: Text(
                                '替换Tracker',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
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
                                    borderRadius:
                                        BorderRadius.circular(5.0), // 圆角半径
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
                                                    borderRadius:
                                                        BorderRadius.circular(
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
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    8.0), // 圆角半径
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      CommonResponse res =
                                                          await controller
                                                              .replaceTrackers(
                                                                  site:
                                                                      keyController
                                                                          .text,
                                                                  newTracker:
                                                                      valueController
                                                                          .text);

                                                      if (res.code == 0) {
                                                        Get.back(result: true);
                                                      }
                                                      Get.snackbar(
                                                          'Tracker替换ing',
                                                          res.msg,
                                                          colorText: res.code ==
                                                                  0
                                                              ? Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error);
                                                    },
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
                            PopupMenuItem<String>(
                              child: Center(
                                child: Text(
                                  '添加种子',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                              onTap: () async {
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
                                          textColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          dividerColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      Expanded(
                                        child: DownloadForm(
                                          categories: controller
                                              .qBCategoryMap.values
                                              .fold({}, (map, element) {
                                            map[element!.name!] =
                                                element.savePath ?? '';
                                            return map;
                                          }),
                                          downloader: downloader,
                                          info: null,
                                        ),
                                      ),
                                    ]),
                                  ),
                                );
                              },
                            ),
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
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.add,
                          size: 18,
                        ),
                      )),
                ],
              ),
              drawer: GetBuilder<DownloadController>(builder: (controller) {
                return isQb
                    ? _buildQbDrawer(downloader, context)
                    : _buildTrDrawer(downloader, context);
              }),
              drawerEdgeDragWidth: 100,
              body: CustomCard(
                  child: Column(
                children: [
                  Expanded(
                    child: controller.isTorrentsLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : controller.showTorrents.isEmpty
                            ? Center(
                                child: Text(
                                '暂无数据',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ))
                            : ListView.builder(
                                itemCount: controller.showTorrents.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (isQb) {
                                    QbittorrentTorrentInfo torrent =
                                        controller.showTorrents[index];
                                    return _showQbTorrent(
                                        downloader, torrent, context);
                                  } else {
                                    TrTorrent torrent =
                                        controller.showTorrents[index];
                                    return _showTrTorrent(
                                        downloader, torrent, context);
                                  }
                                }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child:
                        GetBuilder<DownloadController>(builder: (controller) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: TextField(
                                controller: controller.searchController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: '请输入搜索关键字',
                                  hintStyle: const TextStyle(fontSize: 13),
                                  // contentPadding: const EdgeInsets.symmetric(
                                  //     vertical: 5, horizontal: 5),
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
                                        child: Text(
                                            '计数：${controller.showTorrents.length}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange)),
                                      ),
                                    ],
                                  ),
                                ),
                                onChanged: (value) =>
                                    controller.filterTorrents(isQb),
                              ),
                            ),
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
                                                controller.searchController.text
                                                        .length -
                                                    1);
                                    controller.searchKey =
                                        controller.searchController.text;
                                    controller.filterTorrents(isQb);
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
                ],
              )),
            ),
          ),
        );
      })).whenComplete(() => controller.stopFetchTorrents());
    } catch (e, trace) {
      var message = '查看种子列表失败！$e';
      logger_helper.Logger.instance.e(message);
      logger_helper.Logger.instance.e(trace);
      Get.snackbar(
        '出错啦！',
        message,
        colorText: Theme.of(context).colorScheme.primary,
      );
      await controller.stopFetchTorrents();
    }
  }

  _showQbTorrent(
      Downloader downloader, QbittorrentTorrentInfo torrentInfo, context) {
    RxBool paused = torrentInfo.state.toString().contains('pause').obs;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: const EdgeInsets.all(2.5),
      child: GetBuilder<DownloadController>(builder: (controller) {
        return Slidable(
          key: ValueKey(torrentInfo.infohashV1),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  // _removeTorrent(controller, torrentInfo);
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
                    hashes: [torrentInfo.infohashV1],
                    downloader: downloader,
                  );
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
                            hashes: [torrentInfo.infohashV1],
                            downloader: downloader,
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
                    downloader: downloader,
                    command: 'AutoManagement',
                    hashes: [torrentInfo.infohashV1],
                    enable: !torrentInfo.autoTmm,
                  );
                },
                flex: 2,
                backgroundColor: torrentInfo.autoTmm
                    ? Colors.lightBlue
                    : Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                icon: torrentInfo.autoTmm ? Icons.auto_awesome : Icons.man,
                label: torrentInfo.autoTmm ? '自动' : '手动',
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              _openQbTorrentInfoDetail(downloader, torrentInfo, context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      torrentInfo.tracker.isNotEmpty
                          ? CustomTextTag(
                              labelText: controller.trackers.entries
                                      .firstWhereOrNull((entry) => entry.value
                                          .contains(torrentInfo.infohashV1))
                                      ?.key ??
                                  Uri.parse(torrentInfo.tracker).host,
                              icon: const Icon(Icons.file_upload_outlined,
                                  size: 10, color: Colors.white),
                            )
                          : CustomTextTag(
                              labelText: controller.trackers.entries
                                      .firstWhereOrNull((entry) => entry.value
                                          .contains(torrentInfo.infohashV1))
                                      ?.key ??
                                  (Uri.parse(torrentInfo.magnetUri)
                                              .queryParametersAll["tr"]
                                              ?.first !=
                                          null
                                      ? Uri.parse(
                                              Uri.parse(torrentInfo.magnetUri)
                                                  .queryParametersAll["tr"]!
                                                  .first)
                                          .host
                                      : "未知"),
                              icon: const Icon(Icons.link_off,
                                  size: 10, color: Colors.white),
                              backgroundColor: Colors.red,
                            ),
                      Text(
                        controller.qBitStatus
                            .firstWhere(
                                (element) => element.value == torrentInfo.state,
                                orElse: () => MetaDataItem(
                                    name: "未知状态",
                                    value: qb.TorrentState.unknown))
                            .name,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        filesize(torrentInfo.size),
                        style: const TextStyle(
                          fontSize: 10,
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
                          message: torrentInfo.name,
                          child: Text(
                            torrentInfo.name,
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Text(
                        torrentInfo.category.isNotEmpty
                            ? torrentInfo.category
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
                      SizedBox(
                        width: 80,
                        child: Column(
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
                      ),
                      SizedBox(
                        width: 70,
                        child: Column(
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
                                  text: formatDuration(torrentInfo.timeActive)
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
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              torrentInfo.addedOn * 1000))
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
                      ),
                    ],
                  ),
                  GFProgressBar(
                      margin: EdgeInsets.zero,
                      percentage: torrentInfo.progress,
                      progressHeadType: GFProgressHeadType.square,
                      trailing: Text(
                        '${(torrentInfo.progress * 100).toStringAsFixed(2)}%',
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

  Widget _buildQbDrawer(Downloader downloader, context) {
    return GetBuilder<DownloadController>(builder: (controller) {
      qb.ServerState state = controller.serverStatus.first;
      TextEditingController searchKeyController = TextEditingController();
      return GFDrawer(
        child: Column(
          children: <Widget>[
            // GFDrawerHeader(
            //   centerAlign: true,
            // currentAccountPicture: GFAvatar(
            //   radius: 80.0,
            //   backgroundImage: AssetImage(
            //       'assets/images/${downloader.category.toLowerCase()}.png'),
            // ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       Text(
            //           '${downloader.protocol}://${downloader.host}:${downloader.port}'),
            //     ],
            //   ),
            // ),
            SizedBox(
              height: 80,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/${downloader.category.toLowerCase()}.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                        '${downloader.protocol}://${downloader.host}:${downloader.port}'),
                  ],
                ),
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
                    // Logger.instance.d(data);
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
                  AreaSeries<qb.ServerState, int>(
                    animationDuration: 0,
                    dataSource: controller.serverStatus as List<qb.ServerState>,
                    enableTooltip: true,
                    xValueMapper: (qb.ServerState sales, index) => index,
                    yValueMapper: (qb.ServerState sales, _) =>
                        sales.dlInfoSpeed,
                    color: Colors.red.withOpacity(0.5),
                    name: '下载速度',
                    borderWidth: 1,
                  ),
                  AreaSeries<qb.ServerState, int>(
                    animationDuration: 0,
                    dataSource: controller.serverStatus as List<qb.ServerState>,
                    enableTooltip: true,
                    xValueMapper: (qb.ServerState sales, index) => index,
                    yValueMapper: (qb.ServerState sales, _) =>
                        sales.upInfoSpeed,
                    color: Colors.blue.withOpacity(0.9),
                    name: '上传速度',
                    borderWidth: 1,
                    borderDrawMode: BorderDrawMode.all,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  GFAccordion(
                    titleChild: GFTypography(
                      text: '种子排序',
                      type: GFTypographyType.typo6,
                      icon: const Icon(
                        Icons.sort_by_alpha,
                        size: 18,
                      ),
                      dividerWidth: 108,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      dividerColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 200,
                      child:
                          GetBuilder<DownloadController>(builder: (controller) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.qbSortOptions.length,
                            itemBuilder: (context, index) {
                              MetaDataItem item =
                                  controller.qbSortOptions[index];
                              bool isSelected =
                                  controller.sortKey == item.value;
                              return ListTile(
                                dense: true,
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
                                      '${downloader.host}:${downloader.port}-sortKey',
                                      controller.sortKey.toString());
                                  controller.update();
                                },
                              );
                            });
                      }),
                    ),
                  ),
                  GFAccordion(
                    titleChild: GFTypography(
                      text: '种子分类',
                      type: GFTypographyType.typo6,
                      icon: const Icon(
                        Icons.category,
                        size: 18,
                      ),
                      dividerWidth: 108,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      dividerColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 200,
                      child:
                          GetBuilder<DownloadController>(builder: (controller) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.qBCategoryMap.length,
                            itemBuilder: (context, index) {
                              String c =
                                  controller.qBCategoryMap.keys.toList()[index];
                              qb.Category? category = controller
                                  .qBCategoryMap.values
                                  .toList()[index];
                              int count = 0;
                              if (category?.savePath == null) {
                                count = controller.torrents.length;
                              } else {
                                count = controller.torrents
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
                                dense: true,
                                title: Text(
                                  '$c($count)',
                                ),
                                selected: selected,
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                onTap: () {
                                  Get.back();
                                  controller.torrentFilter =
                                      qb.TorrentFilter.all;
                                  controller.category =
                                      category?.savePath != null
                                          ? category?.name!
                                          : null;
                                  controller.filterQbTorrents();
                                },
                              );
                            });
                      }),
                    ),
                  ),
                  GFAccordion(
                    titleChild: GFTypography(
                      text: '种子状态',
                      type: GFTypographyType.typo6,
                      icon: const Icon(
                        Icons.info,
                        size: 18,
                      ),
                      dividerWidth: 108,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      dividerColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 200,
                      child:
                          GetBuilder<DownloadController>(builder: (controller) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              dense: true,
                              title: Text(
                                '活动中(${controller.torrents.where((torrent) => [
                                      qb.TorrentState.downloading,
                                      qb.TorrentState.uploading,
                                      // TorrentState.checkingUP,
                                      qb.TorrentState.forcedUP,
                                      qb.TorrentState.moving,
                                      // TorrentState.checkingDL,
                                    ].contains(torrent.state)).toList().length})',
                              ),
                              style: ListTileStyle.list,
                              selected: controller.torrentFilter ==
                                  qb.TorrentFilter.active,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              onTap: () {
                                Get.back();
                                controller.torrentState = null;
                                controller.torrentFilter =
                                    qb.TorrentFilter.active;
                                controller.update();
                              },
                            ),
                            ...controller.qBitStatus.map((state) {
                              final torrentsMatchingState = controller.torrents
                                  .where((torrent) => state.value != null
                                      ? torrent.state == state.value
                                      : true)
                                  .toList();
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${state.name}(${torrentsMatchingState.length})',
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
                                      qb.TorrentFilter.all;
                                  controller.update();
                                },
                              );
                            }),
                          ],
                        );
                      }),
                    ),
                  ),
                  GFAccordion(
                    titleChild: GFTypography(
                      text: '站点筛选',
                      type: GFTypographyType.typo6,
                      icon: const Icon(
                        Icons.language,
                        size: 18,
                      ),
                      dividerWidth: 108,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      dividerColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    titlePadding: EdgeInsets.zero,
                    contentChild: SizedBox(
                      height: 300,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: searchKeyController,
                            labelText: '筛选',
                            onChanged: (String value) {
                              // searchKey.text = value;
                              controller.update();
                            },
                          ),
                          Expanded(
                            child: GetBuilder<DownloadController>(
                                builder: (controller) {
                              List<String> keys = controller.trackers.keys
                                  .where((element) => element
                                      .toLowerCase()
                                      .contains(searchKeyController.text
                                          .toLowerCase()))
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
                                      hashList = controller.torrents
                                          .where((element) =>
                                              element.tracker?.isEmpty == true)
                                          .map((e) => e.hash.toString())
                                          .toList();
                                    } else {
                                      hashList = controller.trackers[key];
                                    }
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        '${key.trim()}(${key == ' All' ? controller.torrents.length : hashList?.length})',
                                      ),
                                      style: ListTileStyle.list,
                                      selected:
                                          controller.selectedTracker == key,
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      onTap: () {
                                        Get.back();
                                        // controller.torrentState = null;
                                        controller.torrentFilter =
                                            qb.TorrentFilter.all;
                                        controller.selectedTracker = key;
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
                ],
              ),
            ),
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.all(0),
              // title: Center(
              //     child: Text(
              //   '上传下载数据',
              //   style: TextStyle(
              //       color: Theme.of(context).colorScheme.primary),
              // )),
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
                          '${filesize(state.alltimeUl)}[${filesize(state.upInfoData)}]'),
                  CustomTextTag(
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.red,
                        size: 14,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: Colors.red,
                      labelText:
                          '${filesize(state.alltimeDl)}[${filesize(state.dlInfoData)}]'),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  _showTrTorrent(Downloader downloader, TrTorrent torrentInfo, context) {
    return GetBuilder<DownloadController>(builder: (controller) {
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
                              downloader: downloader,
                              command: 'delete',
                              deleteFiles: deleteFiles.value,
                              hashes: [torrentInfo.hashString]);
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
                              downloader: downloader,
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
                            downloader: downloader,
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
                              downloader: downloader,
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
                _openTrTorrentInfoDetail(downloader, torrentInfo, context);
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
                        torrentInfo.error <= 0
                            ? CustomTextTag(
                                labelText: controller
                                        .trackerToWebSiteMap[controller
                                            .trackerToWebSiteMap.keys
                                            .firstWhereOrNull(
                                                (String element) =>
                                                    element.contains(Uri.parse(
                                                            torrentInfo
                                                                .trackerStats
                                                                .first!
                                                                .announce)
                                                        .host))]
                                        ?.name ??
                                    Uri.parse(torrentInfo
                                            .trackerStats.first!.announce)
                                        .host,
                                icon: const Icon(Icons.file_upload_outlined,
                                    size: 10, color: Colors.white),
                              )
                            : CustomTextTag(
                                labelText: Uri.parse(torrentInfo.magnetLink)
                                            .queryParametersAll["tr"]
                                            ?.first !=
                                        null
                                    ? Uri.parse(
                                            Uri.parse(torrentInfo.magnetLink)
                                                .queryParametersAll["tr"]!
                                                .first)
                                        .host
                                    : "未知",
                                icon: const Icon(Icons.link_off,
                                    size: 10, color: Colors.white),
                                backgroundColor: Colors.red,
                              ),
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
                          width: 235,
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
                        SizedBox(
                          width: 80,
                          child: Column(
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
                        ),
                        SizedBox(
                          width: 70,
                          child: Column(
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  EllipsisText(
                                    text:
                                        formatDuration(torrentInfo.activityDate)
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

  _buildTrDrawer(downloader, context) {}

  _showQbPrefs(Downloader downloader, context) async {
    const List<Tab> tabs = [
      Tab(text: '下载'),
      Tab(text: '连接'),
      Tab(text: '速度'),
      Tab(text: 'Bittorrent'),
      Tab(text: 'RSS'),
      Tab(text: 'WEBUI'),
      Tab(text: '高级'),
    ];
    var response = await controller.getPrefs(downloader);
    if (!response.succeed) {
      Get.snackbar('出错啦！', '获取下载器设置失败',
          colorText: Theme.of(context).colorScheme.error);
      return;
    }
    controller.currentPrefs = QbittorrentPreferences.fromJson(response.data);
    controller.update();
    // QbittorrentPreferences prefs = downloader.prefs;
    RxBool autoTmmEnabled = RxBool(controller.currentPrefs.autoTmmEnabled);
    RxBool addTrackersEnabled =
        RxBool(controller.currentPrefs.addTrackersEnabled);
    RxBool alternativeWebuiEnabled =
        RxBool(controller.currentPrefs.alternativeWebuiEnabled);
    RxBool anonymousMode = RxBool(controller.currentPrefs.anonymousMode);
    RxBool bypassAuthSubnetWhitelistEnabled =
        RxBool(controller.currentPrefs.bypassAuthSubnetWhitelistEnabled);
    RxBool bypassLocalAuth = RxBool(controller.currentPrefs.bypassLocalAuth);
    RxBool categoryChangedTmmEnabled =
        RxBool(controller.currentPrefs.categoryChangedTmmEnabled);
    RxBool dht = RxBool(controller.currentPrefs.dht);
    RxBool dontCountSlowTorrents =
        RxBool(controller.currentPrefs.dontCountSlowTorrents);
    RxBool dyndnsEnabled = RxBool(controller.currentPrefs.dyndnsEnabled);
    RxBool embeddedTrackerPortForwarding =
        RxBool(controller.currentPrefs.embeddedTrackerPortForwarding);
    RxBool enableCoalesceReadWrite =
        RxBool(controller.currentPrefs.enableCoalesceReadWrite);
    RxBool enableEmbeddedTracker =
        RxBool(controller.currentPrefs.enableEmbeddedTracker);
    RxBool enableMultiConnectionsFromSameIp =
        RxBool(controller.currentPrefs.enableMultiConnectionsFromSameIp);
    RxBool enablePieceExtentAffinity =
        RxBool(controller.currentPrefs.enablePieceExtentAffinity);
    RxBool enableUploadSuggestions =
        RxBool(controller.currentPrefs.enableUploadSuggestions);
    RxBool excludedFileNamesEnabled =
        RxBool(controller.currentPrefs.excludedFileNamesEnabled);
    RxBool idnSupportEnabled =
        RxBool(controller.currentPrefs.idnSupportEnabled);
    RxBool incompleteFilesExt =
        RxBool(controller.currentPrefs.incompleteFilesExt);
    RxBool ipFilterEnabled = RxBool(controller.currentPrefs.ipFilterEnabled);
    RxBool ipFilterTrackers = RxBool(controller.currentPrefs.ipFilterTrackers);
    RxBool limitLanPeers = RxBool(controller.currentPrefs.limitLanPeers);
    RxBool limitTcpOverhead = RxBool(controller.currentPrefs.limitTcpOverhead);
    RxBool limitUtpRate = RxBool(controller.currentPrefs.limitUtpRate);
    RxInt autoDeleteMode = RxInt(controller.currentPrefs.autoDeleteMode);
    RxInt uploadChokingAlgorithm =
        RxInt(controller.currentPrefs.uploadChokingAlgorithm);
    RxInt uploadSlotsBehavior =
        RxInt(controller.currentPrefs.uploadSlotsBehavior);
    RxInt encryption = RxInt(controller.currentPrefs.encryption);
    RxInt utpTcpMixedMode = RxInt(controller.currentPrefs.utpTcpMixedMode);
    RxBool lsd = RxBool(controller.currentPrefs.lsd);
    // RxBool mailNotificationAuthEnabled =
    //     RxBool(controller.currentPrefs.mailNotificationAuthEnabled);
    // RxBool mailNotificationEnabled =
    //     RxBool(controller.currentPrefs.mailNotificationEnabled);
    // RxBool mailNotificationSslEnabled =
    //     RxBool(controller.currentPrefs.mailNotificationSslEnabled);
    RxBool maxRatioEnabled = RxBool(controller.currentPrefs.maxRatioEnabled);
    RxBool maxSeedingTimeEnabled =
        RxBool(controller.currentPrefs.maxSeedingTimeEnabled);
    RxBool performanceWarning =
        RxBool(controller.currentPrefs.performanceWarning);
    RxBool pex = RxBool(controller.currentPrefs.pex);
    RxBool preallocateAll = RxBool(controller.currentPrefs.preallocateAll);
    RxBool proxyAuthEnabled = RxBool(controller.currentPrefs.proxyAuthEnabled);
    RxBool proxyHostnameLookup =
        RxBool(controller.currentPrefs.proxyHostnameLookup);
    RxBool proxyPeerConnections =
        RxBool(controller.currentPrefs.proxyPeerConnections);
    RxBool proxyTorrentsOnly =
        RxBool(controller.currentPrefs.proxyTorrentsOnly);
    RxBool queueingEnabled = RxBool(controller.currentPrefs.queueingEnabled);
    RxBool randomPort = RxBool(controller.currentPrefs.randomPort);
    RxBool reannounceWhenAddressChanged =
        RxBool(controller.currentPrefs.reannounceWhenAddressChanged);
    RxBool recheckCompletedTorrents =
        RxBool(controller.currentPrefs.recheckCompletedTorrents);
    RxBool resolvePeerCountries =
        RxBool(controller.currentPrefs.resolvePeerCountries);
    RxBool rssAutoDownloadingEnabled =
        RxBool(controller.currentPrefs.rssAutoDownloadingEnabled);
    RxBool rssDownloadRepackProperEpisodes =
        RxBool(controller.currentPrefs.rssDownloadRepackProperEpisodes);
    RxBool rssProcessingEnabled =
        RxBool(controller.currentPrefs.rssProcessingEnabled);
    RxBool savePathChangedTmmEnabled =
        RxBool(controller.currentPrefs.savePathChangedTmmEnabled);
    RxBool schedulerEnabled = RxBool(controller.currentPrefs.schedulerEnabled);
    RxBool ssrfMitigation = RxBool(controller.currentPrefs.ssrfMitigation);
    RxBool startPausedEnabled =
        RxBool(controller.currentPrefs.startPausedEnabled);
    RxBool tempPathEnabled = RxBool(controller.currentPrefs.tempPathEnabled);
    RxBool torrentChangedTmmEnabled =
        RxBool(controller.currentPrefs.torrentChangedTmmEnabled);
    RxBool upnp = RxBool(controller.currentPrefs.upnp);
    RxBool useCategoryPathsInManualMode =
        RxBool(controller.currentPrefs.useCategoryPathsInManualMode);
    RxBool useHttps = RxBool(controller.currentPrefs.useHttps);
    RxBool validateHttpsTrackerCertificate =
        RxBool(controller.currentPrefs.validateHttpsTrackerCertificate);
    RxBool webUiClickjackingProtectionEnabled =
        RxBool(controller.currentPrefs.webUiClickjackingProtectionEnabled);
    RxBool webUiCsrfProtectionEnabled =
        RxBool(controller.currentPrefs.webUiCsrfProtectionEnabled);
    RxBool webUiHostHeaderValidationEnabled =
        RxBool(controller.currentPrefs.webUiHostHeaderValidationEnabled);
    RxBool webUiReverseProxyEnabled =
        RxBool(controller.currentPrefs.webUiReverseProxyEnabled);
    RxBool webUiSecureCookieEnabled =
        RxBool(controller.currentPrefs.webUiSecureCookieEnabled);
    RxBool webUiUpnp = RxBool(controller.currentPrefs.webUiUpnp);
    RxBool webUiUseCustomHttpHeadersEnabled =
        RxBool(controller.currentPrefs.webUiUseCustomHttpHeadersEnabled);

    TextEditingController bypassAuthSubnetWhitelistController =
        TextEditingController(
            text: controller.currentPrefs.bypassAuthSubnetWhitelist);
    TextEditingController addTrackersController =
        TextEditingController(text: controller.currentPrefs.addTrackers);
    TextEditingController alternativeWebuiPathController =
        TextEditingController(
            text: controller.currentPrefs.alternativeWebuiPath);
    TextEditingController announceIpController =
        TextEditingController(text: controller.currentPrefs.announceIp);
    TextEditingController autorunProgramController =
        TextEditingController(text: controller.currentPrefs.autorunProgram);
    TextEditingController bannedIPsController =
        TextEditingController(text: controller.currentPrefs.bannedIps);
    RxString currentInterfaceAddress =
        RxString(controller.currentPrefs.currentInterfaceAddress);
    RxString currentNetworkInterface =
        RxString(controller.currentPrefs.currentNetworkInterface);
    TextEditingController dyndnsDomainController =
        TextEditingController(text: controller.currentPrefs.dyndnsDomain);
    TextEditingController dyndnsPasswordController =
        TextEditingController(text: controller.currentPrefs.dyndnsPassword);
    TextEditingController dyndnsUsernameController =
        TextEditingController(text: controller.currentPrefs.dyndnsUsername);
    TextEditingController exportDirController =
        TextEditingController(text: controller.currentPrefs.exportDir);
    RxBool exportDirFinEnable =
        RxBool(controller.currentPrefs.exportDirFin.isNotEmpty);
    RxBool exportDirEnable =
        RxBool(controller.currentPrefs.exportDir.isNotEmpty);
    TextEditingController exportDirFinController =
        TextEditingController(text: controller.currentPrefs.exportDirFin);
    TextEditingController ipFilterPathController =
        TextEditingController(text: controller.currentPrefs.ipFilterPath);
    // TextEditingController mailNotificationEmailController =
    //     TextEditingController(
    //         text: controller.currentPrefs.mailNotificationEmail);
    // TextEditingController mailNotificationPasswordController =
    //     TextEditingController(
    //         text: controller.currentPrefs.mailNotificationPassword);
    // TextEditingController mailNotificationSenderController =
    //     TextEditingController(
    //         text: controller.currentPrefs.mailNotificationSender);
    // TextEditingController mailNotificationSmtpController =
    //     TextEditingController(
    //         text: controller.currentPrefs.mailNotificationSmtp);
    // TextEditingController mailNotificationUsernameController =
    //     TextEditingController(
    //         text: controller.currentPrefs.mailNotificationUsername);
    TextEditingController proxyIpController =
        TextEditingController(text: controller.currentPrefs.proxyIp);
    TextEditingController proxyPasswordController =
        TextEditingController(text: controller.currentPrefs.proxyPassword);
    TextEditingController proxyUsernameController =
        TextEditingController(text: controller.currentPrefs.proxyUsername);
    TextEditingController rssSmartEpisodeFiltersController =
        TextEditingController(
            text: controller.currentPrefs.rssSmartEpisodeFilters);
    TextEditingController savePathController =
        TextEditingController(text: controller.currentPrefs.savePath);
    TextEditingController tempPathController =
        TextEditingController(text: controller.currentPrefs.tempPath);
    TextEditingController torrentContentLayoutController =
        TextEditingController(
            text: controller.currentPrefs.torrentContentLayout);
    RxString torrentStopCondition =
        RxString(controller.currentPrefs.torrentStopCondition);
    RxString resumeDataStorageType =
        RxString(controller.currentPrefs.resumeDataStorageType);
    RxInt proxyType = RxInt(controller.currentPrefs.proxyType);

    TextEditingController webUiAddressController =
        TextEditingController(text: controller.currentPrefs.webUiAddress);
    TextEditingController webUiCustomHttpHeadersController =
        TextEditingController(
            text: controller.currentPrefs.webUiCustomHttpHeaders);
    TextEditingController webUiDomainListController =
        TextEditingController(text: controller.currentPrefs.webUiDomainList);
    TextEditingController webUiHttpsCertPathController =
        TextEditingController(text: controller.currentPrefs.webUiHttpsCertPath);
    TextEditingController webUiHttpsKeyPathController =
        TextEditingController(text: controller.currentPrefs.webUiHttpsKeyPath);
    TextEditingController webUiReverseProxiesListController =
        TextEditingController(
            text: controller.currentPrefs.webUiReverseProxiesList);
    TextEditingController webUiUsernameController =
        TextEditingController(text: controller.currentPrefs.webUiUsername);
    // TextEditingController webUiPasswordController =
    //     TextEditingController(text: '');
    TextEditingController listenPortController = TextEditingController(
        text: controller.currentPrefs.listenPort.toString());
    RxInt bittorrentProtocol =
        RxInt(controller.currentPrefs.bittorrentProtocol);
    RxInt dyndnsService = RxInt(controller.currentPrefs.dyndnsService);
    TextEditingController proxyPortController = TextEditingController(
        text: controller.currentPrefs.proxyPort.toString());
    TextEditingController altDlLimitController = TextEditingController(
        text: (controller.currentPrefs.altDlLimit / 1024).toInt().toString());
    TextEditingController altUpLimitController = TextEditingController(
        text: (controller.currentPrefs.altUpLimit / 1024).toInt().toString());
    TextEditingController asyncIoThreadsController = TextEditingController(
        text: controller.currentPrefs.asyncIoThreads.toString());
    TextEditingController checkingMemoryUseController = TextEditingController(
        text: controller.currentPrefs.checkingMemoryUse.toString());
    TextEditingController connectionSpeedController = TextEditingController(
        text: controller.currentPrefs.connectionSpeed.toString());
    TextEditingController diskCacheController = TextEditingController(
        text: controller.currentPrefs.diskCache.toString());
    TextEditingController diskCacheTtlController = TextEditingController(
        text: controller.currentPrefs.diskCacheTtl.toString());
    RxInt diskIoReadMode = RxInt(controller.currentPrefs.diskIoReadMode);
    RxInt diskIoType = RxInt(controller.currentPrefs.diskIoType);
    RxInt diskIoWriteMode = RxInt(controller.currentPrefs.diskIoWriteMode);
    TextEditingController diskQueueSizeController = TextEditingController(
        text:
            (controller.currentPrefs.diskQueueSize / 1024).toInt().toString());
    TextEditingController embeddedTrackerPortController = TextEditingController(
        text: controller.currentPrefs.embeddedTrackerPort.toString());
    TextEditingController filePoolSizeController = TextEditingController(
        text: controller.currentPrefs.filePoolSize.toString());
    TextEditingController hashingThreadsController = TextEditingController(
        text: controller.currentPrefs.hashingThreads.toString());
    TextEditingController maxActiveCheckingTorrentsController =
        TextEditingController(
            text: controller.currentPrefs.maxActiveCheckingTorrents.toString());
    TextEditingController maxActiveDownloadsController = TextEditingController(
        text: controller.currentPrefs.maxActiveDownloads.toString());
    TextEditingController maxActiveTorrentsController = TextEditingController(
        text: controller.currentPrefs.maxActiveTorrents.toString());
    TextEditingController maxActiveUploadsController = TextEditingController(
        text: controller.currentPrefs.maxActiveUploads.toString());
    TextEditingController maxConcurrentHttpAnnouncesController =
        TextEditingController(
            text:
                controller.currentPrefs.maxConcurrentHttpAnnounces.toString());
    TextEditingController maxConnecController = TextEditingController(
        text: controller.currentPrefs.maxConnec.toString());
    RxBool maxConnecEnabled = RxBool(controller.currentPrefs.maxConnec > 0);
    RxString locale = RxString(controller.currentPrefs.locale);
    RxBool maxConnecPerTorrentEnabled =
        RxBool(controller.currentPrefs.maxConnecPerTorrent > 0);

    TextEditingController maxConnecPerTorrentController = TextEditingController(
        text: controller.currentPrefs.maxConnecPerTorrent.toString());
    TextEditingController maxRatioController = TextEditingController(
        text: controller.currentPrefs.maxRatio.toString());
    RxInt maxRatioAct = RxInt(controller.currentPrefs.maxRatioAct);
    TextEditingController maxSeedingTimeController = TextEditingController(
        text: controller.currentPrefs.maxSeedingTime.toString());
    TextEditingController maxUploadsController = TextEditingController(
        text: controller.currentPrefs.maxUploads.toString());
    RxBool maxUploadsEnabled = RxBool(controller.currentPrefs.maxUploads > 0);
    RxBool announceToAllTrackers =
        RxBool(controller.currentPrefs.announceToAllTrackers);
    RxBool announceToAllTiers =
        RxBool(controller.currentPrefs.announceToAllTiers);

    RxBool blockPeersOnPrivilegedPorts =
        RxBool(controller.currentPrefs.blockPeersOnPrivilegedPorts);
    RxBool maxUploadsPerTorrentEnabled =
        RxBool(controller.currentPrefs.maxUploadsPerTorrent > 0);
    TextEditingController maxUploadsPerTorrentController =
        TextEditingController(
            text: controller.currentPrefs.maxUploadsPerTorrent.toString());
    TextEditingController memoryWorkingSetLimitController =
        TextEditingController(
            text: controller.currentPrefs.memoryWorkingSetLimit.toString());
    TextEditingController outgoingPortsMaxController = TextEditingController(
        text: controller.currentPrefs.outgoingPortsMax.toString());
    TextEditingController outgoingPortsMinController = TextEditingController(
        text: controller.currentPrefs.outgoingPortsMin.toString());
    TextEditingController peerTosController =
        TextEditingController(text: controller.currentPrefs.peerTos.toString());
    TextEditingController peerTurnoverController = TextEditingController(
        text: controller.currentPrefs.peerTurnover.toString());
    TextEditingController peerTurnoverCutoffController = TextEditingController(
        text: controller.currentPrefs.peerTurnoverCutoff.toString());
    TextEditingController peerTurnoverIntervalController =
        TextEditingController(
            text: controller.currentPrefs.peerTurnoverInterval.toString());
    TextEditingController refreshIntervalController = TextEditingController(
        text: controller.currentPrefs.refreshInterval.toString());
    TextEditingController requestQueueSizeController = TextEditingController(
        text: controller.currentPrefs.requestQueueSize.toString());
    TextEditingController rssMaxArticlesPerFeedController =
        TextEditingController(
            text: controller.currentPrefs.rssMaxArticlesPerFeed.toString());
    TextEditingController rssRefreshIntervalController = TextEditingController(
        text: controller.currentPrefs.rssRefreshInterval.toString());
    TextEditingController saveResumeDataIntervalController =
        TextEditingController(
            text: controller.currentPrefs.saveResumeDataInterval.toString());
    TextEditingController scheduleFromHourController = TextEditingController(
        text: controller.currentPrefs.scheduleFromHour.toString());
    TextEditingController scheduleFromMinController = TextEditingController(
        text: controller.currentPrefs.scheduleFromMin.toString());
    TextEditingController scheduleToHourController = TextEditingController(
        text: controller.currentPrefs.scheduleToHour.toString());
    TextEditingController scheduleToMinController = TextEditingController(
        text: controller.currentPrefs.scheduleToMin.toString());
    RxInt schedulerDays = RxInt(controller.currentPrefs.schedulerDays);
    TextEditingController sendBufferLowWatermarkController =
        TextEditingController(
            text: controller.currentPrefs.sendBufferLowWatermark.toString());
    TextEditingController sendBufferWatermarkController = TextEditingController(
        text: controller.currentPrefs.sendBufferWatermark.toString());
    TextEditingController sendBufferWatermarkFactorController =
        TextEditingController(
            text: controller.currentPrefs.sendBufferWatermarkFactor.toString());
    TextEditingController slowTorrentDlRateThresholdController =
        TextEditingController(
            text:
                controller.currentPrefs.slowTorrentDlRateThreshold.toString());
    TextEditingController slowTorrentInactiveTimerController =
        TextEditingController(
            text: controller.currentPrefs.slowTorrentInactiveTimer.toString());
    TextEditingController slowTorrentUlRateThresholdController =
        TextEditingController(
            text:
                controller.currentPrefs.slowTorrentUlRateThreshold.toString());
    TextEditingController socketBacklogSizeController = TextEditingController(
        text: controller.currentPrefs.socketBacklogSize.toString());
    TextEditingController stopTrackerTimeoutController = TextEditingController(
        text: controller.currentPrefs.stopTrackerTimeout.toString());
    TextEditingController upLimitController = TextEditingController(
        text: (controller.currentPrefs.upLimit / 1024).toInt().toString());
    TextEditingController dlLimitController = TextEditingController(
        text: (controller.currentPrefs.dlLimit / 1024).toInt().toString());
    TextEditingController upnpLeaseDurationController = TextEditingController(
        text: controller.currentPrefs.upnpLeaseDuration.toString());
    TextEditingController webUiBanDurationController = TextEditingController(
        text: controller.currentPrefs.webUiBanDuration.toString());
    TextEditingController webUiMaxAuthFailCountController =
        TextEditingController(
            text: controller.currentPrefs.webUiMaxAuthFailCount.toString());
    TextEditingController webUiPortController = TextEditingController(
        text: controller.currentPrefs.webUiPort.toString());
    TextEditingController webUiSessionTimeoutController = TextEditingController(
        text: controller.currentPrefs.webUiSessionTimeout.toString());
    logger_helper.Logger.instance.d(controller.currentPrefs.locale);
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
        child: GetBuilder<DownloadController>(builder: (controller) {
          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('配置选项'),
                bottom: const TabBar(tabs: tabs, isScrollable: true),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () async {
                  QbittorrentPreferences prefs =
                      controller.currentPrefs.copyWith(
                    addTrackers: addTrackersController.text,
                    addTrackersEnabled: addTrackersEnabled.value,
                    altDlLimit: int.parse(altDlLimitController.text) * 1024,
                    altUpLimit: int.parse(altUpLimitController.text) * 1024,
                    alternativeWebuiEnabled: alternativeWebuiEnabled.value,
                    alternativeWebuiPath: alternativeWebuiPathController.text,
                    announceIp: announceIpController.text,
                    announceToAllTiers: announceToAllTiers.value,
                    announceToAllTrackers: announceToAllTrackers.value,
                    anonymousMode: anonymousMode.value,
                    asyncIoThreads: int.parse(asyncIoThreadsController.text),
                    autoDeleteMode: autoDeleteMode.value,
                    autoTmmEnabled: autoTmmEnabled.value,
                    autorunProgram: autorunProgramController.text,
                    bannedIps: bannedIPsController.text,
                    bittorrentProtocol: bittorrentProtocol.value,
                    blockPeersOnPrivilegedPorts:
                        blockPeersOnPrivilegedPorts.value,
                    bypassAuthSubnetWhitelist:
                        bypassAuthSubnetWhitelistController.text,
                    bypassAuthSubnetWhitelistEnabled:
                        bypassAuthSubnetWhitelistEnabled.value,
                    bypassLocalAuth: bypassLocalAuth.value,
                    categoryChangedTmmEnabled: categoryChangedTmmEnabled.value,
                    checkingMemoryUse:
                        int.parse(checkingMemoryUseController.text),
                    connectionSpeed: int.parse(connectionSpeedController.text),
                    currentInterfaceAddress: currentInterfaceAddress.value,
                    currentNetworkInterface: currentNetworkInterface.value,
                    dht: dht.value,
                    diskCache: int.parse(diskCacheController.text),
                    diskCacheTtl: int.parse(diskCacheTtlController.text),
                    diskIoReadMode: diskIoReadMode.value,
                    diskIoType: diskIoType.value,
                    diskIoWriteMode: diskIoWriteMode.value,
                    diskQueueSize:
                        int.parse(diskQueueSizeController.text) * 1024,
                    dlLimit: int.parse(dlLimitController.text) * 1024,
                    dontCountSlowTorrents: dontCountSlowTorrents.value,
                    dyndnsDomain: dyndnsDomainController.text,
                    dyndnsEnabled: dyndnsEnabled.value,
                    dyndnsPassword: dyndnsPasswordController.text,
                    dyndnsService: dyndnsService.value,
                    dyndnsUsername: dyndnsUsernameController.text,
                    embeddedTrackerPort:
                        int.parse(embeddedTrackerPortController.text),
                    embeddedTrackerPortForwarding:
                        embeddedTrackerPortForwarding.value,
                    enableCoalesceReadWrite: enableCoalesceReadWrite.value,
                    enableEmbeddedTracker: enableEmbeddedTracker.value,
                    enableMultiConnectionsFromSameIp:
                        enableMultiConnectionsFromSameIp.value,
                    enablePieceExtentAffinity: enablePieceExtentAffinity.value,
                    enableUploadSuggestions: enableUploadSuggestions.value,
                    encryption: encryption.value,
                    excludedFileNamesEnabled: excludedFileNamesEnabled.value,
                    exportDir: exportDirController.text,
                    exportDirFin: exportDirFinController.text,
                    filePoolSize: int.parse(filePoolSizeController.text),
                    hashingThreads: int.parse(hashingThreadsController.text),
                    idnSupportEnabled: idnSupportEnabled.value,
                    incompleteFilesExt: incompleteFilesExt.value,
                    ipFilterEnabled: ipFilterEnabled.value,
                    ipFilterPath: ipFilterPathController.text,
                    ipFilterTrackers: ipFilterTrackers.value,
                    limitLanPeers: limitLanPeers.value,
                    limitTcpOverhead: limitTcpOverhead.value,
                    limitUtpRate: limitUtpRate.value,
                    listenPort: int.parse(listenPortController.text),
                    locale: locale.value,
                    lsd: lsd.value,
                    maxActiveCheckingTorrents:
                        int.parse(maxActiveCheckingTorrentsController.text),
                    maxActiveDownloads:
                        int.parse(maxActiveDownloadsController.text),
                    maxActiveTorrents:
                        int.parse(maxActiveTorrentsController.text),
                    maxActiveUploads:
                        int.parse(maxActiveUploadsController.text),
                    maxConnec: int.parse(maxConnecController.text),
                    maxConnecPerTorrent:
                        int.parse(maxConnecPerTorrentController.text),
                    maxConcurrentHttpAnnounces:
                        int.parse(maxConcurrentHttpAnnouncesController.text),
                    maxRatio: double.parse(maxRatioController.text),
                    maxRatioAct: maxRatioAct.value,
                    maxRatioEnabled: maxRatioEnabled.value,
                    maxSeedingTime: int.parse(maxSeedingTimeController.text),
                    maxSeedingTimeEnabled: maxSeedingTimeEnabled.value,
                    maxUploads: int.parse(maxUploadsController.text),
                    maxUploadsPerTorrent:
                        int.parse(maxUploadsPerTorrentController.text),
                    memoryWorkingSetLimit:
                        int.parse(memoryWorkingSetLimitController.text),
                    outgoingPortsMax:
                        int.parse(outgoingPortsMaxController.text),
                    outgoingPortsMin:
                        int.parse(outgoingPortsMinController.text),
                    peerTos: int.parse(peerTosController.text),
                    peerTurnover: int.parse(peerTurnoverController.text),
                    peerTurnoverCutoff:
                        int.parse(peerTurnoverCutoffController.text),
                    peerTurnoverInterval:
                        int.parse(peerTurnoverIntervalController.text),
                    performanceWarning: performanceWarning.value,
                    pex: pex.value,
                    preallocateAll: preallocateAll.value,
                    proxyAuthEnabled: proxyAuthEnabled.value,
                    proxyHostnameLookup: proxyHostnameLookup.value,
                    proxyIp: proxyIpController.text,
                    proxyPassword: proxyPasswordController.text,
                    proxyPeerConnections: proxyPeerConnections.value,
                    proxyPort: int.parse(proxyPortController.text),
                    proxyTorrentsOnly: proxyTorrentsOnly.value,
                    proxyType: proxyType.value,
                    proxyUsername: proxyUsernameController.text,
                    queueingEnabled: queueingEnabled.value,
                    randomPort: randomPort.value,
                    reannounceWhenAddressChanged:
                        reannounceWhenAddressChanged.value,
                    recheckCompletedTorrents: recheckCompletedTorrents.value,
                    refreshInterval: int.parse(refreshIntervalController.text),
                    requestQueueSize:
                        int.parse(requestQueueSizeController.text),
                    resolvePeerCountries: resolvePeerCountries.value,
                    resumeDataStorageType: resumeDataStorageType.value,
                    rssAutoDownloadingEnabled: rssAutoDownloadingEnabled.value,
                    rssDownloadRepackProperEpisodes:
                        rssDownloadRepackProperEpisodes.value,
                    rssMaxArticlesPerFeed:
                        int.parse(rssMaxArticlesPerFeedController.text),
                    rssProcessingEnabled: rssProcessingEnabled.value,
                    rssRefreshInterval:
                        int.parse(rssRefreshIntervalController.text),
                    rssSmartEpisodeFilters:
                        rssSmartEpisodeFiltersController.text,
                    savePath: savePathController.text,
                    savePathChangedTmmEnabled: savePathChangedTmmEnabled.value,
                    saveResumeDataInterval:
                        int.parse(saveResumeDataIntervalController.text),
                    scheduleFromHour:
                        int.parse(scheduleFromHourController.text),
                    scheduleFromMin: int.parse(scheduleFromMinController.text),
                    scheduleToHour: int.parse(scheduleToHourController.text),
                    scheduleToMin: int.parse(scheduleToMinController.text),
                    schedulerDays: schedulerDays.value,
                    schedulerEnabled: schedulerEnabled.value,
                    sendBufferLowWatermark:
                        int.parse(sendBufferLowWatermarkController.text),
                    sendBufferWatermark:
                        int.parse(sendBufferWatermarkController.text),
                    sendBufferWatermarkFactor:
                        int.parse(sendBufferWatermarkFactorController.text),
                    slowTorrentDlRateThreshold:
                        int.parse(slowTorrentDlRateThresholdController.text),
                    slowTorrentInactiveTimer:
                        int.parse(slowTorrentInactiveTimerController.text),
                    slowTorrentUlRateThreshold:
                        int.parse(slowTorrentUlRateThresholdController.text),
                    socketBacklogSize:
                        int.parse(socketBacklogSizeController.text),
                    ssrfMitigation: ssrfMitigation.value,
                    startPausedEnabled: startPausedEnabled.value,
                    stopTrackerTimeout:
                        int.parse(stopTrackerTimeoutController.text),
                    tempPath: tempPathController.text,
                    tempPathEnabled: tempPathEnabled.value,
                    torrentChangedTmmEnabled: torrentChangedTmmEnabled.value,
                    torrentContentLayout: torrentContentLayoutController.text,
                    torrentStopCondition: torrentStopCondition.value,
                    upLimit: int.parse(upLimitController.text) * 1024,
                    uploadChokingAlgorithm: uploadChokingAlgorithm.value,
                    uploadSlotsBehavior: uploadSlotsBehavior.value,
                    upnp: upnp.value,
                    useCategoryPathsInManualMode:
                        useCategoryPathsInManualMode.value,
                    useHttps: useHttps.value,
                    utpTcpMixedMode: utpTcpMixedMode.value,
                    validateHttpsTrackerCertificate:
                        validateHttpsTrackerCertificate.value,
                    webUiAddress: webUiAddressController.text,
                    webUiBanDuration:
                        int.parse(webUiBanDurationController.text),
                    webUiClickjackingProtectionEnabled:
                        webUiClickjackingProtectionEnabled.value,
                    webUiCsrfProtectionEnabled:
                        webUiCsrfProtectionEnabled.value,
                    webUiCustomHttpHeaders:
                        webUiCustomHttpHeadersController.text,
                    webUiDomainList: webUiDomainListController.text,
                    webUiHostHeaderValidationEnabled:
                        webUiHostHeaderValidationEnabled.value,
                    webUiHttpsCertPath: webUiHttpsCertPathController.text,
                    webUiHttpsKeyPath: webUiHttpsKeyPathController.text,
                    webUiMaxAuthFailCount:
                        int.parse(webUiMaxAuthFailCountController.text),
                    webUiPort: int.parse(webUiPortController.text),
                    webUiReverseProxiesList:
                        webUiReverseProxiesListController.text,
                    webUiReverseProxyEnabled: webUiReverseProxyEnabled.value,
                    webUiSecureCookieEnabled: webUiSecureCookieEnabled.value,
                    webUiSessionTimeout:
                        int.parse(webUiSessionTimeoutController.text),
                    webUiUpnp: webUiUpnp.value,
                    webUiUseCustomHttpHeadersEnabled:
                        webUiUseCustomHttpHeadersEnabled.value,
                    webUiUsername: webUiUsernameController.text,
                  );

                  CommonResponse response =
                      await controller.setPrefs(downloader, prefs);
                  if (!response.succeed) {
                    Get.snackbar('修改配置失败', response.msg);
                  } else {
                    controller.getDownloaderListFromServer();
                  }
                  Get.back();
                },
                label: const Text('保存'),
              ),
              body: TabBarView(children: [
                ListView(
                  children: [
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('添加种子时'),
                                  DropdownButton(
                                      isDense: true,
                                      value:
                                          torrentContentLayoutController.text,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Original',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '原始')),
                                        DropdownMenuItem(
                                            value: 'Subfolder',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '子文件夹')),
                                        DropdownMenuItem(
                                            value: 'NoSubfolder',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '不创建子文件夹')),
                                      ],
                                      onChanged: (value) {}),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: startPausedEnabled.value,
                              onChanged: (value) {
                                startPausedEnabled.value = value == true;
                              },
                              title: const Text('不要开始自动下载'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('种子停止条件'),
                                  DropdownButton<String>(
                                      value: torrentStopCondition.value,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'None',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '无'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'MetadataReceived',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '已收到元数据'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'FilesChecked',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '选种的文件'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        torrentStopCondition.value =
                                            value ?? 'None';
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: autoDeleteMode.value == 1,
                              onChanged: (value) {
                                autoDeleteMode.value = value == true ? 1 : 0;
                              },
                              title: const Text('完成后删除.torrent文件'),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              value: preallocateAll.value,
                              onChanged: (value) {
                                preallocateAll.value = value == true;
                              },
                              title: const Text('为所有文件预分配磁盘空间'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: incompleteFilesExt.value,
                              onChanged: (value) {
                                incompleteFilesExt.value = value == true;
                              },
                              title: const Text('为不完整的文件添加扩展名 .!qB'),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                          child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: autoTmmEnabled.value,
                            onChanged: (value) {
                              autoTmmEnabled.value = value == true;
                            },
                            title: const Text('Torrent 自动管理模式'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('当 Torrent 分类修改时'),
                                DropdownButton(
                                    isDense: true,
                                    value: categoryChangedTmmEnabled.value,
                                    items: const [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '重新定位')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '切换手动')),
                                    ],
                                    onChanged: (value) {
                                      savePathChangedTmmEnabled.value =
                                          value == true;
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('当默认保存路径修改时'),
                                DropdownButton(
                                    isDense: true,
                                    value: savePathChangedTmmEnabled.value,
                                    items: const [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '重新定位受影响的种子')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '切换受影响的种子为手动')),
                                    ],
                                    onChanged: (value) {
                                      savePathChangedTmmEnabled.value =
                                          value == true;
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('当分类保存路径修改时'),
                                DropdownButton(
                                    isDense: true,
                                    value: torrentChangedTmmEnabled.value,
                                    items: const [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '重新定位受影响的种子')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '切换受影响的种子为手动')),
                                    ],
                                    onChanged: (value) {
                                      torrentChangedTmmEnabled.value == true;
                                    }),
                              ],
                            ),
                          ),
                          CustomTextField(
                            controller: savePathController,
                            labelText: '默认保存路径',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: tempPathEnabled.value,
                            onChanged: (value) {
                              tempPathEnabled.value = value == true;
                            },
                            title: const Text('保存未完成的 torrent 到'),
                          ),
                          if (tempPathEnabled.value)
                            CustomTextField(
                              controller: tempPathController,
                              labelText: '保存未完成的 torrent 到',
                            ),
                          CheckboxListTile(
                            dense: true,
                            value: exportDirEnable.value,
                            onChanged: (value) {
                              exportDirEnable.value = value == true;
                            },
                            title: const Text('复制 .torrent 文件到：'),
                          ),
                          if (exportDirEnable.value)
                            CustomTextField(
                              controller: exportDirController,
                              labelText: '复制 .torrent 文件到：',
                            ),
                          CheckboxListTile(
                            dense: true,
                            value: exportDirFinEnable.value,
                            onChanged: (value) {
                              exportDirFinEnable.value = value == true;
                            },
                            title: const Text('复制下载完成的 .torrent 文件到'),
                          ),
                          if (exportDirFinEnable.value)
                            CustomTextField(
                              controller: exportDirFinController,
                              labelText: '复制下载完成的 .torrent 文件到',
                            ),
                        ],
                      ));
                    }),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('下载连接协议'),
                          DropdownButton(
                              isDense: true,
                              value: bittorrentProtocol.value,
                              items: const [
                                DropdownMenuItem(
                                    value: 0,
                                    child: Text(
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                        'TCP和UTP')),
                                DropdownMenuItem(
                                    value: 1,
                                    child: Text(
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                        'TCP')),
                                DropdownMenuItem(
                                    value: 2,
                                    child: Text(
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                        'UTP')),
                              ],
                              onChanged: (value) {
                                bittorrentProtocol.value = value!;
                              }),
                        ],
                      ),
                    ),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomPortField(
                                        readOnly: randomPort.value,
                                        controller: listenPortController,
                                        labelText: '用于传入连接的端口'),
                                  ),
                                  GFButton(
                                      // size: GFSize.SMALL,
                                      shape: GFButtonShape.square,
                                      onPressed: () {
                                        listenPortController.text =
                                            (10000 + Random().nextInt(55535))
                                                .toString();
                                      },
                                      child: const Text('随机'))
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: upnp.value,
                              onChanged: (value) {
                                upnp.value = value == true;
                              },
                              title:
                                  const Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: randomPort.value,
                              onChanged: (value) {
                                randomPort.value = value == true;
                              },
                              title: const Text('使用随机端口'),
                            ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              value: maxConnecEnabled.value,
                              onChanged: (value) {
                                maxConnecEnabled.value = value == true;
                              },
                              title: const Text(
                                '全局最大连接数',
                              ),
                            ),
                            if (maxConnecEnabled.value)
                              CustomNumberField(
                                readOnly: maxConnecEnabled.value,
                                controller: maxConnecController,
                                labelText: '全局最大连接数',
                              ),
                            CheckboxListTile(
                              dense: true,
                              value: maxConnecPerTorrentEnabled.value,
                              onChanged: (value) {
                                maxConnecPerTorrentEnabled.value =
                                    value == true;
                              },
                              title: const Text('每 torrent 最大连接数'),
                            ),
                            if (maxConnecPerTorrentEnabled.value)
                              CustomTextField(
                                  readOnly: maxConnecPerTorrentEnabled.value,
                                  controller: TextEditingController(
                                    text: controller
                                        .currentPrefs.maxConnecPerTorrent
                                        .toString(),
                                  ),
                                  labelText: '每 torrent 最大连接数'),
                            CheckboxListTile(
                              dense: true,
                              value: maxUploadsEnabled.value,
                              onChanged: (value) {
                                maxUploadsEnabled.value = value == true;
                              },
                              title: const Text('全局上传窗口数上限'),
                            ),
                            if (maxUploadsEnabled.value)
                              CustomTextField(
                                  controller: maxUploadsController,
                                  labelText: '全局上传窗口数上限'),
                            CheckboxListTile(
                              dense: true,
                              value: maxUploadsPerTorrentEnabled.value,
                              onChanged: (value) {
                                maxUploadsPerTorrentEnabled.value =
                                    value == true;
                              },
                              title: const Text('每个 torrent 上传窗口数上限'),
                            ),
                            if (maxUploadsPerTorrentEnabled.value)
                              CustomTextField(
                                  controller: maxUploadsPerTorrentController,
                                  labelText: '每个 torrent 上传窗口数上限'),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('代理类型'),
                                DropdownButton(
                                    isDense: true,
                                    value: proxyType.value,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 0,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              'None')),
                                      // DropdownMenuItem(
                                      //     value: 1,
                                      //     child: Text(
                                      //         style: TextStyle(
                                      //           fontSize: 14,
                                      //         ),
                                      //         'SOCKS4')),
                                      DropdownMenuItem(
                                          value: 2,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              'SOCKS5')),
                                      DropdownMenuItem(
                                          value: 3,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              'HTTP')),
                                    ],
                                    onChanged: (value) {
                                      proxyType.value = value!;
                                    }),
                              ],
                            ),
                            if (proxyType.value != 0)
                              Column(
                                children: [
                                  CustomTextField(
                                    controller: proxyIpController,
                                    labelText: '主机',
                                  ),
                                  CustomPortField(
                                    controller: proxyPortController,
                                    labelText: '端口',
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyPeerConnections.value,
                                    onChanged: (value) {
                                      proxyPeerConnections.value =
                                          value == true;
                                    },
                                    title: const Text('使用代理服务器进行用户连接'),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyTorrentsOnly.value,
                                    onChanged: (value) {
                                      proxyTorrentsOnly.value = value == true;
                                    },
                                    title: const Text(
                                        'Use proxy only for torrents'),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyHostnameLookup.value,
                                    onChanged: (value) {
                                      proxyHostnameLookup.value = value == true;
                                    },
                                    title: const Text('使用代理进行主机名查询'),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyAuthEnabled.value,
                                    onChanged: (value) {
                                      proxyAuthEnabled.value = value == true;
                                    },
                                    title: const Text('验证'),
                                  ),
                                  if (proxyAuthEnabled.value)
                                    Column(
                                      children: [
                                        CustomTextField(
                                            controller: proxyUsernameController,
                                            labelText: '用户名'),
                                        CustomTextField(
                                            controller: proxyPasswordController,
                                            labelText: '密码'),
                                      ],
                                    ),
                                ],
                              )
                          ],
                        ),
                      );
                    }),
                    CustomCard(
                      child: Obx(() {
                        return Column(
                          children: [
                            const Text('IP 过滤'),
                            CheckboxListTile(
                              dense: true,
                              value: ipFilterEnabled.value,
                              onChanged: (value) {
                                ipFilterEnabled.value = value == true;
                              },
                              title: const Text('开启过滤规则'),
                            ),
                            if (ipFilterEnabled.value)
                              Column(
                                children: [
                                  CustomTextField(
                                    controller: ipFilterPathController,
                                    labelText: '过滤规则路径',
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: ipFilterTrackers.value,
                                    onChanged: (value) {
                                      ipFilterTrackers.value = value == true;
                                    },
                                    title: const Text('开启过滤规则'),
                                  ),
                                  CustomTextField(
                                    controller: bannedIPsController,
                                    maxLines: 5,
                                    labelText: '手动屏蔽 IP 地址',
                                  ),
                                ],
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          const Text('全局速度限制(0 为无限制)'),
                          CustomTextField(
                            controller: upLimitController,
                            labelText: '上传(KiB/s)',
                          ),
                          CustomTextField(
                            controller: dlLimitController,
                            labelText: '下载(KiB/s)',
                          ),
                        ],
                      ),
                    ),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            const Text('备用速度限制(0 为无限制)'),
                            CustomTextField(
                              controller: altUpLimitController,
                              labelText: '上传(KiB/s)',
                            ),
                            CustomTextField(
                              controller: altDlLimitController,
                              labelText: '下载(KiB/s)',
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: schedulerEnabled.value,
                              onChanged: (value) {
                                schedulerEnabled.value = value == true;
                              },
                              title: const Text('计划备用速度限制的启用时间'),
                            ),
                            if (schedulerEnabled.value)
                              Column(
                                children: [
                                  CustomTextField(
                                      controller: scheduleFromHourController,
                                      labelText: '自动启用备用带宽设置开始时间(小时)'),
                                  CustomTextField(
                                      controller: scheduleFromMinController,
                                      labelText: '自动启用备用带宽设置开始时间(分钟)'),
                                  CustomTextField(
                                      controller: scheduleToHourController,
                                      labelText: '自动启用备用带宽设置结束时间(小时)'),
                                  CustomTextField(
                                      controller: scheduleToMinController,
                                      labelText: '自动启用备用带宽设置结束时间(分钟)'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: DropdownButton(
                                          isDense: true,
                                          value: schedulerDays.value,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 0,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '每天')),
                                            DropdownMenuItem(
                                                value: 1,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '工作日')),
                                            DropdownMenuItem(
                                                value: 2,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周末')),
                                            DropdownMenuItem(
                                                value: 3,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周一')),
                                            DropdownMenuItem(
                                                value: 4,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周二')),
                                            DropdownMenuItem(
                                                value: 5,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周三')),
                                            DropdownMenuItem(
                                                value: 6,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周四')),
                                            DropdownMenuItem(
                                                value: 7,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周五')),
                                            DropdownMenuItem(
                                                value: 8,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周六')),
                                            DropdownMenuItem(
                                                value: 9,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    '周日')),
                                          ],
                                          onChanged: (value) {
                                            schedulerDays.value = value!;
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                          child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: limitUtpRate.value,
                            onChanged: (value) {
                              limitUtpRate.value = value == true;
                            },
                            title: const Text('对 µTP 协议进行速度限制'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: limitTcpOverhead.value,
                            onChanged: (value) {
                              limitTcpOverhead.value = value == true;
                            },
                            title: const Text('对传送总开销进行速度限制'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: limitLanPeers.value,
                            onChanged: (value) {
                              limitLanPeers.value = value == true;
                            },
                            title: const Text('对本地网络用户进行速度限制'),
                          ),
                        ],
                      ));
                    }),
                  ],
                ),
                ListView(
                  children: [
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              value: dht.value,
                              onChanged: (value) {
                                dht.value = value == true;
                              },
                              title: const Text('启用 DHT (去中心化网络) 以找到更多用户'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: pex.value,
                              onChanged: (value) {
                                pex.value = value == true;
                              },
                              title: const Text('启用用户交换 (PeX) 以找到更多用户'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: lsd.value,
                              onChanged: (value) {
                                lsd.value = value == true;
                              },
                              title: const Text('启用本地用户发现以找到更多用户'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('加密模式'),
                                  DropdownButton(
                                      isDense: true,
                                      value: encryption.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '允许加密')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '强制加密')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '禁用加密')),
                                      ],
                                      onChanged: (value) {
                                        encryption.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: anonymousMode.value,
                              onChanged: (value) {
                                anonymousMode.value = value == true;
                              },
                              title: const Text('启用匿名模式'),
                            ),
                          ],
                        ),
                      );
                    }),
                    CustomCard(
                      child: CustomTextField(
                        controller: maxActiveCheckingTorrentsController,
                        labelText: '最大活跃检查种子数',
                      ),
                    ),
                    Obx(() {
                      return CustomCard(
                          child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: queueingEnabled.value,
                            onChanged: (value) {
                              queueingEnabled.value = value == true;
                            },
                            title: const Text('Torrent 排队'),
                          ),
                          if (queueingEnabled.value)
                            Column(
                              children: [
                                CustomTextField(
                                  controller: maxActiveDownloadsController,
                                  labelText: '最大活动的下载数',
                                ),
                                CustomPortField(
                                  controller: maxActiveUploadsController,
                                  labelText: '最大活动的上传数',
                                ),
                                CustomTextField(
                                  controller: maxActiveTorrentsController,
                                  labelText: '最大活动的 torrent 数',
                                ),
                                CheckboxListTile(
                                  dense: true,
                                  value: dontCountSlowTorrents.value,
                                  onChanged: (value) {
                                    dontCountSlowTorrents.value = value == true;
                                  },
                                  title: const Text('慢速 torrent 不计入限制内'),
                                ),
                                if (dontCountSlowTorrents.value)
                                  Column(
                                    children: [
                                      CustomTextField(
                                        controller:
                                            slowTorrentDlRateThresholdController,
                                        labelText: '下载速度阈值',
                                      ),
                                      CustomTextField(
                                        controller:
                                            slowTorrentUlRateThresholdController,
                                        labelText: '上传速度阈值',
                                      ),
                                      CustomTextField(
                                        controller:
                                            slowTorrentInactiveTimerController,
                                        labelText: 'Torrent 非活动计时器',
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                        ],
                      ));
                    }),
                    Obx(() {
                      return CustomCard(
                          child: Column(
                        children: [
                          const Text('做种限制'),
                          CheckboxListTile(
                            dense: true,
                            value: maxRatioEnabled.value,
                            onChanged: (value) {
                              maxRatioEnabled.value = value == true;
                            },
                            title: const Text('当分享率达到'),
                          ),
                          if (maxRatioEnabled.value)
                            CustomNumberField(
                              controller: maxRatioController,
                              labelText: '当分享率达到',
                            ),
                          CheckboxListTile(
                            dense: true,
                            value: maxSeedingTimeEnabled.value,
                            onChanged: (value) {
                              maxSeedingTimeEnabled.value = value == true;
                            },
                            title: const Text('当做种时间达到'),
                          ),
                          if (maxSeedingTimeEnabled.value)
                            CustomNumberField(
                              controller: TextEditingController(
                                text: controller.currentPrefs.maxSeedingTime
                                    .toString(),
                              ),
                              labelText: '当做种时间达到',
                            ),
                          if (maxSeedingTimeEnabled.value ||
                              maxRatioEnabled.value)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('达到做种限制时的操作'),
                                    DropdownButton(
                                        isDense: true,
                                        value: maxRatioAct.value,
                                        items: const [
                                          DropdownMenuItem(
                                              value: 0,
                                              child: Text(
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  '暂停 torrent')),
                                          DropdownMenuItem(
                                              value: 1,
                                              child: Text(
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  '删除 torrent')),
                                          DropdownMenuItem(
                                              value: 2,
                                              child: Text(
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  '删除 torrent 及所属文件')),
                                          DropdownMenuItem(
                                              value: 3,
                                              child: Text(
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  '为 torrent 启用超级做种')),
                                        ],
                                        onChanged: (value) {}),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ));
                    }),
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            CheckboxListTile(
                              dense: true,
                              value: addTrackersEnabled.value,
                              onChanged: (value) {
                                addTrackersEnabled.value = value == true;
                              },
                              title: const Text('自动添加tracker到新的 torrent'),
                            ),
                            if (addTrackersEnabled.value)
                              CustomTextField(
                                controller: addTrackersController,
                                maxLines: 5,
                                labelText: '自动添加以下tracker到新的 torrent',
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
                ListView(
                  children: [
                    Obx(() {
                      return CustomCard(
                          child: Column(
                        children: [
                          const Text('RSS'),
                          CheckboxListTile(
                            dense: true,
                            value: rssProcessingEnabled.value,
                            onChanged: (value) {
                              rssProcessingEnabled.value = value == true;
                            },
                            title: const Text('启用获取 RSS 订阅'),
                          ),
                          if (rssProcessingEnabled.value)
                            Column(
                              children: [
                                CustomTextField(
                                  controller: rssRefreshIntervalController,
                                  labelText: 'RSS 订阅源更新间隔(分钟)',
                                ),
                                CustomTextField(
                                  controller: rssMaxArticlesPerFeedController,
                                  labelText: '每个订阅源文章数目最大值(个)',
                                ),
                              ],
                            ),
                        ],
                      ));
                    }),
                    Obx(() {
                      return CustomCard(
                          child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: rssAutoDownloadingEnabled.value,
                          onChanged: (value) {
                            rssAutoDownloadingEnabled.value = value == true;
                          },
                          title: const Text('启用 RSS Torrent 自动下载'),
                        ),
                      ]));
                    }),
                    CustomCard(
                      child: Obx(() {
                        return Column(
                          children: [
                            const Text('RSS 智能剧集过滤器'),
                            CheckboxListTile(
                              dense: true,
                              value: rssDownloadRepackProperEpisodes.value,
                              onChanged: (value) {
                                rssDownloadRepackProperEpisodes.value =
                                    value == true;
                              },
                              title: const Text('下载 REPACK/PROPER 版剧集'),
                            ),
                            if (rssDownloadRepackProperEpisodes.value)
                              CustomTextField(
                                controller: rssSmartEpisodeFiltersController,
                                maxLines: 5,
                                labelText: '过滤器',
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    if (locale.value == 'en')
                      CustomCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('用户界面语言'),
                              DropdownButton(
                                  isDense: true,
                                  value: locale.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'zh_CN', child: Text('简体中文')),
                                    DropdownMenuItem(
                                        value: 'en', child: Text('English')),
                                  ],
                                  onChanged: (value) {
                                    locale.value = value!;
                                  }),
                            ],
                          ),
                        ),
                      ),
                    CustomCard(
                      child: Obx(() {
                        return CheckboxListTile(
                          dense: true,
                          value: performanceWarning.value,
                          onChanged: (value) {
                            performanceWarning.value = value == true;
                          },
                          title: const Text('记录性能警报'),
                        );
                      }),
                    ),
                    CustomCard(child: Obx(() {
                      return Column(children: [
                        CustomTextField(
                          controller: webUiAddressController,
                          labelText: 'IP 地址',
                        ),
                        CustomTextField(
                          controller: webUiPortController,
                          labelText: '端口',
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: webUiUpnp.value,
                          onChanged: (value) {
                            webUiUpnp.value = value == true;
                          },
                          title: const Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: useHttps.value,
                          onChanged: (value) {
                            useHttps.value = value == true;
                          },
                          title: const Text('使用 HTTPS 而不是 HTTP'),
                        ),
                        if (useHttps.value)
                          Column(
                            children: [
                              CustomTextField(
                                controller: webUiHttpsCertPathController,
                                labelText: '证书',
                              ),
                              CustomTextField(
                                controller: webUiHttpsKeyPathController,
                                labelText: '密钥',
                              ),
                            ],
                          ),
                      ]);
                    })),
                    CustomCard(child: Obx(() {
                      return Column(children: [
                        CustomTextField(
                          controller: webUiUsernameController,
                          labelText: '用户名',
                        ),
                        // CustomTextField(
                        //   controller: webUiPasswordController,
                        //   labelText: '密码',
                        // ),
                        CheckboxListTile(
                          dense: true,
                          value: bypassLocalAuth.value,
                          onChanged: (value) {
                            bypassLocalAuth.value = value == true;
                          },
                          title: const Text('对本地主机上的客户端跳过身份验证'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: bypassAuthSubnetWhitelistEnabled.value,
                          onChanged: (value) {
                            bypassAuthSubnetWhitelistEnabled.value =
                                value == true;
                          },
                          title: const Text('对 IP 子网白名单中的客户端跳过身份验证'),
                        ),
                        if (bypassAuthSubnetWhitelistEnabled.value)
                          CustomTextField(
                            controller: bypassAuthSubnetWhitelistController,
                            maxLines: 5,
                            labelText: '对 IP 子网白名单中的客户端跳过身份验证',
                          ),
                        CustomTextField(
                          controller: webUiMaxAuthFailCountController,
                          labelText: '连续失败后禁止客户端(次)',
                        ),
                        CustomTextField(
                          controller: webUiBanDurationController,
                          labelText: '连续失败后禁止时长(秒)',
                        ),
                        CustomTextField(
                          controller: webUiSessionTimeoutController,
                          labelText: '会话超时时间(秒)',
                        ),
                      ]);
                    })),
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          CheckboxListTile(
                            dense: true,
                            value: alternativeWebuiEnabled.value,
                            onChanged: (value) {
                              alternativeWebuiEnabled.value = value == true;
                            },
                            title: const Text('使用备用 Web UI'),
                          ),
                          if (alternativeWebuiEnabled.value)
                            CustomTextField(
                              controller: alternativeWebuiPathController,
                              labelText: '备用 Web UI 路径',
                            ),
                        ]);
                      }),
                    ),
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          CheckboxListTile(
                            dense: true,
                            value: webUiClickjackingProtectionEnabled.value,
                            onChanged: (value) {
                              webUiClickjackingProtectionEnabled.value =
                                  value == true;
                            },
                            title: const Text('启用 “点击劫持” 保护'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiCsrfProtectionEnabled.value,
                            onChanged: (value) {
                              webUiCsrfProtectionEnabled.value = value == true;
                            },
                            title: const Text('启用跨站请求伪造 (CSRF) 保护'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiSecureCookieEnabled.value,
                            enabled: useHttps.value,
                            onChanged: (value) {
                              webUiSecureCookieEnabled.value = value == true;
                            },
                            title: const Text('启用 cookie 安全标志（需要 HTTPS）'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiHostHeaderValidationEnabled.value,
                            onChanged: (value) {
                              webUiHostHeaderValidationEnabled.value =
                                  value == true;
                            },
                            title: const Text('启用 Host header 属性验证'),
                          ),
                          if (webUiHostHeaderValidationEnabled.value)
                            CustomTextField(
                              controller: TextEditingController(
                                text: controller.currentPrefs.webUiDomainList,
                              ),
                              labelText: '服务器域名',
                            ),
                        ]);
                      }),
                    ),
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          CheckboxListTile(
                            dense: true,
                            value: webUiUseCustomHttpHeadersEnabled.value,
                            onChanged: (value) {
                              webUiUseCustomHttpHeadersEnabled.value =
                                  value == true;
                            },
                            title: const Text('添加自定义 HTTP 头字段'),
                          ),
                          if (webUiUseCustomHttpHeadersEnabled.value)
                            CustomTextField(
                              controller: webUiCustomHttpHeadersController,
                              maxLines: 5,
                              labelText: 'HTTP 头字段（每行一个）',
                            ),
                        ]);
                      }),
                    ),
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          CheckboxListTile(
                            dense: true,
                            value: webUiReverseProxyEnabled.value,
                            onChanged: (value) {
                              webUiReverseProxyEnabled.value = value == true;
                            },
                            title: const Text('启用反向代理支持'),
                          ),
                          if (webUiReverseProxyEnabled.value)
                            CustomTextField(
                              controller: webUiReverseProxiesListController,
                              labelText: '受信任的代理列表',
                            ),
                        ]);
                      }),
                    ),
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          CheckboxListTile(
                            dense: true,
                            value: dyndnsEnabled.value,
                            onChanged: (value) {
                              dyndnsEnabled.value = value == true;
                            },
                            title: const Text('更新我的动态域名'),
                          ),
                          if (dyndnsEnabled.value)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('域名提供商'),
                                      DropdownButton(
                                          isDense: true,
                                          value: dyndnsService.value,
                                          items: const [
                                            DropdownMenuItem(
                                                value: 0,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    'DynDNS')),
                                            DropdownMenuItem(
                                                value: 1,
                                                child: Text(
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                    'NO-IP')),
                                          ],
                                          onChanged: (value) {
                                            dyndnsService.value = value!;
                                          }),
                                    ],
                                  ),
                                ),
                                CustomTextField(
                                  controller: dyndnsDomainController,
                                  labelText: '域名',
                                ),
                                CustomTextField(
                                  controller: dyndnsUsernameController,
                                  labelText: '用户名',
                                ),
                                CustomTextField(
                                  controller: dyndnsPasswordController,
                                  labelText: '密码',
                                ),
                              ],
                            ),
                        ]);
                      }),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Obx(() {
                        return Column(children: [
                          const Text('qBittorrent 相关'),
                          if (resumeDataStorageType.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('恢复数据存储类型（需要重新启动）'),
                                  DropdownButton(
                                      isDense: true,
                                      value: resumeDataStorageType.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Legacy',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '快速恢复文件')),
                                        DropdownMenuItem(
                                            value: 'SQLite',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                'SQLite 数据库')),
                                      ],
                                      onChanged: (value) {
                                        resumeDataStorageType.value = value!;
                                      }),
                                ],
                              ),
                            ),
                          CustomTextField(
                            controller: memoryWorkingSetLimitController,
                            labelText: '物理内存使用上限（仅 libtorrent >= 2.0 时应用）（MiB）',
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 16.0, vertical: 8),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text('网络接口'),
                          //       DropdownButton(
                          //           isDense: true,
                          //           value: currentNetworkInterface.value,
                          //           items: const [
                          //             DropdownMenuItem(
                          //                 value: '',
                          //                 child: Text(
                          //                     style: TextStyle(
                          //                       fontSize: 14,
                          //                     ),
                          //                     '任意接口')),
                          //           ],
                          //           onChanged: (value) {
                          //             currentNetworkInterface.value = value!;
                          //           }),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 16.0, vertical: 8),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       const Text('绑定到的可选 IP 地址'),
                          //       DropdownButton(
                          //           isDense: true,
                          //           value: currentInterfaceAddress.value,
                          //           items: const [
                          //             DropdownMenuItem(
                          //                 value: '',
                          //                 child: Text(
                          //                     style: TextStyle(
                          //                       fontSize: 14,
                          //                     ),
                          //                     '所有地址')),
                          //           ],
                          //           onChanged: (value) {
                          //             currentInterfaceAddress.value = value!;
                          //           }),
                          //     ],
                          //   ),
                          // ),
                          CustomTextField(
                            controller: saveResumeDataIntervalController,
                            labelText: '保存恢复数据间隔（分钟）',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: recheckCompletedTorrents.value,
                            onChanged: (value) {
                              recheckCompletedTorrents.value = value == true;
                            },
                            title: const Text('完成后重新校验 Torrent'),
                          ),
                          CustomTextField(
                            controller: refreshIntervalController,
                            labelText: '刷新间隔（毫秒）',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: resolvePeerCountries.value,
                            onChanged: (value) {
                              resolvePeerCountries.value = value == true;
                            },
                            title: const Text('解析用户所在国家'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: reannounceWhenAddressChanged.value,
                            onChanged: (value) {
                              reannounceWhenAddressChanged.value =
                                  value == true;
                            },
                            title: const Text('当 IP 或端口更改时，重新通知所有 trackers'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: enableEmbeddedTracker.value,
                            onChanged: (value) {
                              enableEmbeddedTracker.value = value == true;
                            },
                            title: const Text('启用内置 Tracker'),
                          ),
                          CustomTextField(
                            controller: embeddedTrackerPortController,
                            labelText: '内置 tracker 端口',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: embeddedTrackerPortForwarding.value,
                            onChanged: (value) {
                              embeddedTrackerPortForwarding.value =
                                  value == true;
                            },
                            title: const Text('对嵌入的 tracker 启用端口转发'),
                          ),
                        ]);
                      }),
                    ),
                    CustomCard(
                      child: Obx(() {
                        return Column(
                          children: [
                            const Text('libtorrent 相关'),
                            CustomTextField(
                              controller: asyncIoThreadsController,
                              labelText: '异步 I/O 线程数',
                            ),
                            CustomTextField(
                              controller: hashingThreadsController,
                              labelText: '散列线程',
                            ),
                            CustomTextField(
                              controller: filePoolSizeController,
                              labelText: '文件池大小',
                            ),
                            CustomTextField(
                              controller: checkingMemoryUseController,
                              labelText: '校验时内存使用扩增量(MiB)',
                            ),
                            CustomTextField(
                              controller: diskCacheController,
                              labelText: '磁盘缓存(MiB)',
                            ),
                            CustomTextField(
                              controller: diskCacheTtlController,
                              labelText: '磁盘缓存过期时间间隔',
                            ),
                            CustomTextField(
                              controller: diskQueueSizeController,
                              labelText: '磁盘队列大小（KiB）',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('磁盘 IO 类型（需要重启）'),
                                  DropdownButton(
                                      isDense: true,
                                      value: diskIoType.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                ' 默认')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '内存映射文件')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '遵循 POSIX')),
                                      ],
                                      onChanged: (value) {
                                        diskIoType.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('磁盘 IO 读取模式'),
                                  DropdownButton(
                                      isDense: true,
                                      value: diskIoReadMode.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '禁用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '启用操作系统缓存')),
                                      ],
                                      onChanged: (value) {
                                        diskIoReadMode.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('磁盘 IO 写入模式'),
                                  DropdownButton(
                                      isDense: true,
                                      value: diskIoWriteMode.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '禁用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '启用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '连续写入')),
                                      ],
                                      onChanged: (value) {
                                        diskIoWriteMode.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enableCoalesceReadWrite.value,
                              onChanged: (value) {
                                enableCoalesceReadWrite.value = value!;
                              },
                              title: const Text('合并读写'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enablePieceExtentAffinity.value,
                              onChanged: (value) {
                                enablePieceExtentAffinity.value = value == true;
                              },
                              title: const Text('启用相连文件块下载模式'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enableUploadSuggestions.value,
                              onChanged: (value) {
                                enableUploadSuggestions.value = value!;
                              },
                              title: const Text('发送分块上传建议'),
                            ),
                            CustomTextField(
                              controller: sendBufferWatermarkController,
                              labelText: '发送缓冲区上限（KiB）',
                            ),
                            CustomTextField(
                              controller: sendBufferLowWatermarkController,
                              labelText: '发送缓冲区下限（KiB）',
                            ),
                            CustomTextField(
                              controller: sendBufferWatermarkFactorController,
                              labelText: '发送缓冲区增长系数（%）',
                            ),
                            CustomTextField(
                              controller: connectionSpeedController,
                              labelText: '每秒传出连接数： (?)	',
                            ),
                            CustomTextField(
                              controller: socketBacklogSizeController,
                              labelText: 'Socket backlog 大小',
                            ),
                            CustomTextField(
                              controller: outgoingPortsMinController,
                              labelText: '传出端口 (下限) [0: 禁用]',
                            ),
                            CustomTextField(
                              controller: outgoingPortsMaxController,
                              labelText: '传出端口 (上限) [0: 禁用]',
                            ),
                            CustomTextField(
                              controller: upnpLeaseDurationController,
                              labelText: 'UPnP 租期 [0：永久]',
                            ),
                            CustomTextField(
                              controller: peerTosController,
                              labelText: '与 peers 连接的服务类型（ToS）',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('μTP-TCP 混合模式策略'),
                                  DropdownButton(
                                      isDense: true,
                                      value: utpTcpMixedMode.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '优先使用TCP')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '按用户比重')),
                                      ],
                                      onChanged: (value) {
                                        utpTcpMixedMode.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: idnSupportEnabled.value,
                              onChanged: (value) {
                                idnSupportEnabled.value = value!;
                              },
                              title: const Text('支持国际化域名（IDN）'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enableMultiConnectionsFromSameIp.value,
                              onChanged: (value) {
                                enableMultiConnectionsFromSameIp.value =
                                    value == true;
                              },
                              title: const Text('允许来自同一 IP 地址的多个连接'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: validateHttpsTrackerCertificate.value,
                              onChanged: (value) {
                                validateHttpsTrackerCertificate.value =
                                    value == true;
                              },
                              title: const Text('验证 HTTPS tracker 证书'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: ssrfMitigation.value,
                              onChanged: (value) {
                                ssrfMitigation.value = value == true;
                              },
                              title: const Text('服务器端请求伪造（SSRF）攻击缓解'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: blockPeersOnPrivilegedPorts.value,
                              onChanged: (value) {
                                blockPeersOnPrivilegedPorts.value =
                                    value == true;
                              },
                              title: const Text('禁止连接到特权端口上的 Peer'),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('上传窗口策略'),
                                  DropdownButton(
                                      isDense: true,
                                      value: uploadSlotsBehavior.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                ' 固定窗口数')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '基于上传速度')),
                                      ],
                                      onChanged: (value) {
                                        uploadSlotsBehavior.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('上传连接策略'),
                                  DropdownButton(
                                      isDense: true,
                                      value: uploadChokingAlgorithm.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '轮流上传')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '最快上传')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                ' 反吸血')),
                                      ],
                                      onChanged: (value) {
                                        uploadChokingAlgorithm.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: announceToAllTrackers.value,
                              onChanged: (value) {
                                announceToAllTrackers.value = value == true;
                              },
                              title: const Text('总是向同级的所有 Tracker 汇报'),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: announceToAllTiers.value,
                              onChanged: (value) {
                                announceToAllTiers.value = value == true;
                              },
                              title: const Text('总是向所有等级的 Tracker 汇报'),
                            ),
                            CustomTextField(
                              controller: announceIpController,
                              labelText: 'IP 地址已报告给 Trackers (需要重启)',
                            ),
                            CustomTextField(
                              controller: maxConcurrentHttpAnnouncesController,
                              labelText: '最大并行 HTTP 发布',
                            ),
                            CustomTextField(
                              controller: stopTrackerTimeoutController,
                              labelText: '停止 tracker 超时',
                            ),
                            CustomTextField(
                              controller: peerTurnoverController,
                              labelText: 'Peer 进出断开百分比',
                            ),
                            CustomTextField(
                              controller: peerTurnoverCutoffController,
                              labelText: 'Peer 进出阈值百分比',
                            ),
                            CustomTextField(
                              controller: peerTurnoverIntervalController,
                              labelText: 'Peer 进出断开间隔',
                            ),
                            CustomTextField(
                              controller: requestQueueSizeController,
                              labelText: '单一 peer 的最大未完成请求',
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }

  _showTrPrefs(Downloader downloader, context) async {
    const List<Tab> tabs = [
      Tab(text: '下载设置'),
      Tab(text: '网络设置'),
      Tab(text: '带宽设置'),
      Tab(text: '队列设置'),
    ];
    var response = await controller.getPrefs(downloader);
    if (!response.succeed) {
      Get.snackbar('出错啦！', '获取下载器设置失败',
          colorText: Theme.of(context).colorScheme.error);
      return;
    }
    controller.currentPrefs = TransmissionConfig.fromJson(response.data);
    controller.update();
    // 限速开关
    RxBool altSpeedEnabled = RxBool(controller.currentPrefs.altSpeedEnabled);
    // 自动按时间限速开关
    RxBool altSpeedTimeEnabled =
        RxBool(controller.currentPrefs.altSpeedTimeEnabled);
    // 黑名单开关
    RxBool blocklistEnabled = RxBool(controller.currentPrefs.blocklistEnabled);
    // RxBool startAddedTorrents =
    //     RxBool(controller.currentPrefs.startAddedTorrents);
    // 分布式 HASH 表
    RxBool dhtEnabled = RxBool(controller.currentPrefs.dhtEnabled);
    // 下载队列开关
    RxBool downloadQueueEnabled =
        RxBool(controller.currentPrefs.downloadQueueEnabled);
    // 种子超时无流量移出队列开关
    RxBool idleSeedingLimitEnabled =
        RxBool(controller.currentPrefs.idleSeedingLimitEnabled);
    // 临时目录开关
    RxBool incompleteDirEnabled =
        RxBool(controller.currentPrefs.incompleteDirEnabled);
    // 允许本地对等点发现
    RxBool lpdEnabled = RxBool(controller.currentPrefs.lpdEnabled);
    // 端口转发开关
    RxBool portForwardingEnabled =
        RxBool(controller.currentPrefs.portForwardingEnabled);
    // PEX开关
    RxBool pexEnabled = RxBool(controller.currentPrefs.pexEnabled);
    RxBool peerPortRandomOnStart =
        RxBool(controller.currentPrefs.peerPortRandomOnStart);
    // 队列等待开关
    RxBool queueStalledEnabled =
        RxBool(controller.currentPrefs.queueStalledEnabled);
    // 种子做种队列开关
    RxBool seedQueueEnabled = RxBool(controller.currentPrefs.seedQueueEnabled);
    // 未完成种子添加 part
    RxBool renamePartialFiles =
        RxBool(controller.currentPrefs.renamePartialFiles);
    // 种子上传限速开关
    RxBool speedLimitUpEnabled =
        RxBool(controller.currentPrefs.speedLimitUpEnabled);
    RxBool seedRatioLimited = RxBool(controller.currentPrefs.seedRatioLimited);
    // 种子下载限速开关
    RxBool speedLimitDownEnabled =
        RxBool(controller.currentPrefs.speedLimitDownEnabled);
    // 脚本种子添加开关
    // RxBool scriptTorrentAddedEnabled = RxBool(prefs.scriptTorrentAddedEnabled);
    // 脚本种子完成开关
    // RxBool scriptTorrentDoneSeedingEnabled =
    //     RxBool(prefs.scriptTorrentDoneSeedingEnabled);
    // TCP开关
    // RxBool tcpEnabled = RxBool(prefs.tcpEnabled);
    // UTP开关
    // RxBool utpEnabled = RxBool(prefs.utpEnabled);

    // int fields
    TextEditingController seedRatioLimitController = TextEditingController(
        text: controller.currentPrefs.seedRatioLimit.toString());
    TextEditingController altSpeedDownController = TextEditingController(
        text: controller.currentPrefs.altSpeedDown.toString());
    TextEditingController altSpeedTimeBeginController = TextEditingController(
        text: controller.currentPrefs.altSpeedTimeBegin.toString());
    RxInt altSpeedTimeDay = RxInt(controller.currentPrefs.altSpeedTimeDay);
    TextEditingController altSpeedTimeEndController = TextEditingController(
        text: controller.currentPrefs.altSpeedTimeEnd.toString());
    TextEditingController altSpeedUpController = TextEditingController(
        text: controller.currentPrefs.altSpeedUp.toString());
    RxInt blocklistSize = RxInt(controller.currentPrefs.blocklistSize);
    TextEditingController cacheSizeMbController = TextEditingController(
        text: controller.currentPrefs.cacheSizeMb.toString());
    // TextEditingController downloadDirFreeSpaceController =
    //     TextEditingController(
    //         text: controller.currentPrefs.downloadDirFreeSpace.toString());
    TextEditingController downloadQueueSizeController = TextEditingController(
        text: controller.currentPrefs.downloadQueueSize.toString());
    TextEditingController idleSeedingLimitController = TextEditingController(
        text: controller.currentPrefs.idleSeedingLimit.toString());
    TextEditingController peerLimitGlobalController = TextEditingController(
        text: controller.currentPrefs.peerLimitGlobal.toString());
    TextEditingController peerLimitPerTorrentController = TextEditingController(
        text: controller.currentPrefs.peerLimitPerTorrent.toString());
    TextEditingController peerPortController = TextEditingController(
        text: controller.currentPrefs.peerPort.toString());
    TextEditingController queueStalledMinutesController = TextEditingController(
        text: controller.currentPrefs.queueStalledMinutes.toString());
    // TextEditingController rpcVersionController = TextEditingController(
    //     text: controller.currentPrefs.rpcVersion.toString());
    // TextEditingController rpcVersionMinimumController = TextEditingController(
    //     text: controller.currentPrefs.rpcVersionMinimum.toString());
    TextEditingController seedQueueSizeController = TextEditingController(
        text: controller.currentPrefs.seedQueueSize.toString());
    TextEditingController speedLimitDownController = TextEditingController(
        text: controller.currentPrefs.speedLimitDown.toString());
    TextEditingController speedLimitUpController = TextEditingController(
        text: controller.currentPrefs.speedLimitUp.toString());

// String fields
    TextEditingController blocklistUrlController =
        TextEditingController(text: controller.currentPrefs.blocklistUrl);
    TextEditingController configDirController =
        TextEditingController(text: controller.currentPrefs.configDir);
    TextEditingController defaultTrackersController =
        TextEditingController(text: controller.currentPrefs.defaultTrackers);
    TextEditingController downloadDirController =
        TextEditingController(text: controller.currentPrefs.downloadDir);
    RxString encryption = RxString(controller.currentPrefs.encryption);
    TextEditingController incompleteDirController =
        TextEditingController(text: controller.currentPrefs.incompleteDir);
    // TextEditingController rpcVersionSemverController =
    //     TextEditingController(text: controller.currentPrefs.rpcVersionSemver);
    // TextEditingController scriptTorrentAddedFilenameController =
    //     TextEditingController(
    //         text: controller.currentPrefs.scriptTorrentAddedFilename);
    // TextEditingController scriptTorrentDoneFilenameController =
    //     TextEditingController(
    //         text: controller.currentPrefs.scriptTorrentDoneFilename);
    // TextEditingController scriptTorrentDoneSeedingFilenameController =
    //     TextEditingController(
    //         text: controller.currentPrefs.scriptTorrentDoneSeedingFilename);
    // TextEditingController sessionIdController =
    //     TextEditingController(text: controller.currentPrefs.sessionId);
    // TextEditingController versionController =
    //     TextEditingController(text: controller.currentPrefs.version);

    RxList<MetaDataItem> daysOfWeek = RxList([
      '星期天',
      '星期一',
      '星期二',
      '星期三',
      '星期四',
      '星期五',
      '星期六'
    ]
        .asMap()
        .entries
        .map((item) => MetaDataItem(name: item.value, value: pow(2, item.key)))
        .toList());
    RxList<int> daysOfWeekMask = RxList(
        TransmissionUtils.getEnabledDaysFromAltSpeedTimeDay(
            altSpeedTimeDay.value));
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
        child: GetBuilder<DownloadController>(builder: (controller) {
          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('配置选项'),
                bottom: const TabBar(tabs: tabs),
              ),
              body: TabBarView(children: [
                ListView(
                  children: [
                    Obx(() {
                      return Column(
                        children: [
                          CustomTextField(
                              controller: downloadDirController,
                              labelText: '默认保存目录'),
                          CheckboxListTile(
                            value: renamePartialFiles.value,
                            onChanged: (value) {
                              renamePartialFiles.value = value == true;
                            },
                            title: const Text('在未完成的文件名后加上 “.part” 后缀'),
                          ),
                          CheckboxListTile(
                            value: incompleteDirEnabled.value,
                            onChanged: (value) {
                              incompleteDirEnabled.value = value == true;
                            },
                            title: const Text('启用临时目录'),
                          ),
                          if (incompleteDirEnabled.value)
                            CustomTextField(
                              controller: incompleteDirController,
                              labelText: '临时目录',
                            ),
                          CheckboxListTile(
                            value: seedRatioLimited.value,
                            onChanged: (value) {
                              seedRatioLimited.value = value == true;
                            },
                            title: const Text('默认分享率上限'),
                          ),
                          if (seedRatioLimited.value)
                            CustomTextField(
                                controller: seedRatioLimitController,
                                labelText: '默认分享率上限'),
                          CheckboxListTile(
                            value: idleSeedingLimitEnabled.value,
                            onChanged: (value) {
                              idleSeedingLimitEnabled.value = value == true;
                            },
                            title: const Text('默认停止无流量种子'),
                          ),
                          if (idleSeedingLimitEnabled.value)
                            CustomTextField(
                                controller: idleSeedingLimitController,
                                labelText: '默认停止无流量种子持续时间(分钟)'),
                          CustomTextField(
                              controller: cacheSizeMbController,
                              labelText: '磁盘缓存大小（MB）'),
                        ],
                      );
                    }),
                  ],
                ),
                ListView(
                  children: [
                    Obx(() {
                      return Column(
                        children: [
                          CustomPortField(
                              controller: peerPortController,
                              labelText: '连接端口号'),
                          FullWidthButton(onPressed: () {}, text: '测试端口'),
                          CheckboxListTile(
                            value: peerPortRandomOnStart.value,
                            onChanged: (value) {
                              peerPortRandomOnStart.value = value == true;
                            },
                            title: const Text('启用随机端口'),
                          ),
                          CheckboxListTile(
                            value: portForwardingEnabled.value,
                            onChanged: (value) {
                              portForwardingEnabled.value = value == true;
                            },
                            title: const Text('启用端口转发 (UPnP)'),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('加密'),
                                DropdownButton(
                                    isDense: true,
                                    value: encryption.value,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'tolerated',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '允许加密')),
                                      DropdownMenuItem(
                                          value: 'preferred',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '优先加密')),
                                      DropdownMenuItem(
                                          value: 'required',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              ' 强制加密')),
                                    ],
                                    onChanged: (value) {
                                      encryption.value = value!;
                                    }),
                              ],
                            ),
                          ),
                          CustomTextField(
                              controller: peerLimitGlobalController,
                              labelText: '全局最大链接数'),
                          CustomTextField(
                              controller: peerLimitPerTorrentController,
                              labelText: '单种最大链接数'),
                          CheckboxListTile(
                            value: pexEnabled.value,
                            onChanged: (value) {
                              pexEnabled.value = value == true;
                            },
                            title: const Text('启用本地用户交换'),
                          ),
                          CheckboxListTile(
                            value: lpdEnabled.value,
                            onChanged: (value) {
                              lpdEnabled.value = value == true;
                            },
                            title: const Text('对等交换'),
                          ),
                          CheckboxListTile(
                            value: dhtEnabled.value,
                            onChanged: (value) {
                              dhtEnabled.value = value == true;
                            },
                            title: const Text('启用分布式哈希表 (DHT)'),
                          ),
                          CheckboxListTile(
                            value: blocklistEnabled.value,
                            onChanged: (value) {
                              blocklistEnabled.value = value == true;
                            },
                            title: const Text('启用黑名单列表:'),
                          ),
                          if (blocklistEnabled.value)
                            Column(
                              children: [
                                CustomTextField(
                                    controller: blocklistUrlController,
                                    labelText: '黑名单列表'),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Text(
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                        '更新黑名单【$blocklistSize】')),
                              ],
                            ),
                        ],
                      );
                    })
                  ],
                ),
                Obx(() {
                  return ListView(
                    children: [
                      CheckboxListTile(
                        value: speedLimitDownEnabled.value,
                        onChanged: (value) {
                          speedLimitDownEnabled.value = value == true;
                        },
                        title: const Text('最大下载速度 (KB/s):'),
                      ),
                      if (speedLimitDownEnabled.value)
                        Column(
                          children: [
                            CustomNumberField(
                                controller: speedLimitDownController,
                                labelText: '正常最大下载速度(KB/s)'),
                            CustomNumberField(
                                controller: altSpeedDownController,
                                labelText: '备用最大下载速度(KB/s)'),
                          ],
                        ),
                      CheckboxListTile(
                        value: speedLimitUpEnabled.value,
                        onChanged: (value) {
                          speedLimitUpEnabled.value = value == true;
                        },
                        title: const Text('最大上传速度 (KB/s):'),
                      ),
                      if (speedLimitUpEnabled.value)
                        Column(
                          children: [
                            CustomNumberField(
                                controller: speedLimitUpController,
                                labelText: '正常最大上传速度(KB/s)'),
                            CustomNumberField(
                                controller: altSpeedUpController,
                                labelText: '备用最大上传速度(KB/s)'),
                          ],
                        ),
                      CheckboxListTile(
                        value: altSpeedEnabled.value,
                        onChanged: (value) {
                          altSpeedEnabled.value = value == true;
                        },
                        title: const Text('启用备用带宽'),
                      ),
                      CheckboxListTile(
                        value: altSpeedTimeEnabled.value,
                        onChanged: (value) {
                          altSpeedTimeEnabled.value = value == true;
                        },
                        title: const Text('自动启用备用带宽设置 (时间段内)'),
                      ),
                      if (altSpeedTimeEnabled.value)
                        Obx(() {
                          return Column(
                            children: [
                              CustomTextField(
                                  controller: altSpeedTimeBeginController,
                                  labelText: '自动启用备用带宽设置开始时间'),
                              CustomTextField(
                                  controller: altSpeedTimeEndController,
                                  labelText: '自动启用备用带宽设置结束时间'),
                              Text('${altSpeedTimeDay.value}'),
                              Obx(() {
                                return Wrap(
                                  children: [
                                    ...daysOfWeek.map(
                                      (item) => CheckboxListTile(
                                        value:
                                            daysOfWeekMask.contains(item.value),
                                        onChanged: (value) {
                                          logger_helper.Logger.instance
                                              .d(value);
                                          if (value == true) {
                                            altSpeedTimeDay.value =
                                                (altSpeedTimeDay.value +
                                                        item.value)
                                                    .toInt();
                                          } else {
                                            altSpeedTimeDay.value =
                                                (altSpeedTimeDay.value -
                                                        item.value)
                                                    .toInt();
                                          }
                                          daysOfWeekMask.value = TransmissionUtils
                                              .getEnabledDaysFromAltSpeedTimeDay(
                                                  altSpeedTimeDay.value);
                                          logger_helper.Logger.instance
                                              .d(daysOfWeekMask);
                                        },
                                        title: Text(item.name),
                                      ),
                                    )
                                  ],
                                );
                              }),
                            ],
                          );
                        })
                    ],
                  );
                }),
                Obx(() {
                  return ListView(children: [
                    CheckboxListTile(
                      value: downloadQueueEnabled.value,
                      onChanged: (value) {
                        downloadQueueEnabled.value = value == true;
                      },
                      title: const Text('启用下载队列，最大同时下载数'),
                    ),
                    if (downloadQueueEnabled.value)
                      CustomTextField(
                          controller: downloadQueueSizeController,
                          labelText: '启用下载队列，最大同时下载数'),
                    CheckboxListTile(
                      value: seedQueueEnabled.value,
                      onChanged: (value) {
                        seedQueueEnabled.value = value == true;
                      },
                      title: const Text('启用上传队列，最大同时上传数'),
                    ),
                    if (seedQueueEnabled.value)
                      CustomTextField(
                          controller: seedQueueSizeController,
                          labelText: '启用上传队列，最大同时上传数'),
                    CheckboxListTile(
                      value: queueStalledEnabled.value,
                      onChanged: (value) {
                        queueStalledEnabled.value = value == true;
                      },
                      title: const Text('种子超过该时间无流量，移出队列'),
                    ),
                    if (queueStalledEnabled.value)
                      CustomTextField(
                          controller: queueStalledMinutesController,
                          labelText: '种子超过该时间无流量，移出队列(分钟)'),
                  ]);
                }),
              ]),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  TransmissionConfig prefs = controller.currentPrefs.copyWith(
                    altSpeedDown: int.parse(altSpeedDownController.text),
                    altSpeedEnabled: altSpeedEnabled.value,
                    altSpeedTimeBegin:
                        int.parse(altSpeedTimeBeginController.text),
                    altSpeedTimeDay: altSpeedTimeDay.value,
                    altSpeedTimeEnabled: altSpeedTimeEnabled.value,
                    altSpeedTimeEnd: int.parse(altSpeedTimeEndController.text),
                    altSpeedUp: int.parse(altSpeedUpController.text),
                    blocklistEnabled: blocklistEnabled.value,
                    blocklistUrl: blocklistUrlController.text,
                    cacheSizeMb: int.parse(cacheSizeMbController.text),
                    configDir: configDirController.text,
                    defaultTrackers: defaultTrackersController.text,
                    dhtEnabled: dhtEnabled.value,
                    downloadDir: downloadDirController.text,
                    downloadQueueEnabled: downloadQueueEnabled.value,
                    downloadQueueSize:
                        int.parse(downloadQueueSizeController.text),
                    encryption: encryption.value,
                    idleSeedingLimit:
                        int.parse(idleSeedingLimitController.text),
                    idleSeedingLimitEnabled: idleSeedingLimitEnabled.value,
                    incompleteDir: incompleteDirController.text,
                    incompleteDirEnabled: incompleteDirEnabled.value,
                    lpdEnabled: lpdEnabled.value,
                    peerLimitGlobal: int.parse(peerLimitGlobalController.text),
                    peerLimitPerTorrent:
                        int.parse(peerLimitPerTorrentController.text),
                    peerPort: int.parse(peerPortController.text),
                    peerPortRandomOnStart: peerPortRandomOnStart.value,
                    pexEnabled: pexEnabled.value,
                    portForwardingEnabled: portForwardingEnabled.value,
                    queueStalledEnabled: queueStalledEnabled.value,
                    queueStalledMinutes:
                        int.parse(queueStalledMinutesController.text),
                    renamePartialFiles: renamePartialFiles.value,
                    // scriptTorrentAddedEnabled: scriptTorrentAddedEnabled.value,
                    // scriptTorrentAddedFilename:
                    //     scriptTorrentAddedFilenameController.text,
                    // scriptTorrentDoneEnabled: scriptTorrentDoneEnabled.value,
                    // scriptTorrentDoneFilename:
                    //     scriptTorrentDoneFilenameController.text,
                    // scriptTorrentDoneSeedingEnabled:
                    //     scriptTorrentDoneSeedingEnabled.value,
                    // scriptTorrentDoneSeedingFilename:
                    //     scriptTorrentDoneSeedingFilenameController.text,
                    seedQueueEnabled: seedQueueEnabled.value,
                    seedQueueSize: int.parse(seedQueueSizeController.text),
                    seedRatioLimit: double.parse(seedRatioLimitController.text),
                    seedRatioLimited: seedRatioLimited.value,
                    speedLimitDown: int.parse(speedLimitDownController.text),
                    speedLimitDownEnabled: speedLimitDownEnabled.value,
                    speedLimitUp: int.parse(speedLimitUpController.text),
                    speedLimitUpEnabled: speedLimitUpEnabled.value,
                    // startAddedTorrents: startAddedTorrents.value,
                    // tcpEnabled: tcpEnabled.value,
                    // trashOriginalTorrentFiles: trashOriginalTorrentFiles.value,
                  );
                  CommonResponse response =
                      await controller.setPrefs(downloader, prefs);
                  if (!response.succeed) {
                    Get.snackbar('修改配置失败', response.msg);
                  } else {
                    controller.getDownloaderListFromServer();
                  }
                  Get.back();
                },
                child: const Icon(Icons.save_outlined),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openQbTorrentInfoDetail(Downloader downloader,
      QbittorrentTorrentInfo torrentInfo, context) async {
    if (torrentInfo.infohashV1 == null) {
      Get.snackbar('错误', '无法获取torrent信息: ${torrentInfo.infohashV1}',
          colorText: Theme.of(context).colorScheme.error);
      return;
    }
    logger_helper.Logger.instance.d(torrentInfo.infohashV1);
    CommonResponse response = await controller.getDownloaderTorrentDetailInfo(
        downloader, torrentInfo.infohashV1);
    // TorrentProperties properties =
    //     TorrentProperties.fromJson(response.data['properties']);
    List<qb.TorrentContents> contents = response.data['files']
        .map<qb.TorrentContents>((item) => qb.TorrentContents.fromJson(item))
        .toList();
    List<qb.Tracker> trackers = response.data['trackers']
        .map<qb.Tracker>((item) => qb.Tracker.fromJson(item))
        .toList();
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
        child: GetBuilder<DownloadController>(builder: (controller) {
          trackers = trackers
              .where((element) => element.url!.startsWith('http'))
              .toList();
          var repeatTorrents = controller.torrents
              .where(
                  (element) => element.contentPath == torrentInfo.contentPath)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller.trackers.entries
                        .firstWhere((entry) => entry.value.contains(e.hash))
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
                      _openQbTorrentInfoDetail(downloader, e.value, context);
                    },
                    onDeleted: () {
                      // _removeTorrent(controller, e.value);
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
                                percentage: torrentInfo.progress,
                                lineHeight: 12,
                                progressHeadType: GFProgressHeadType.square,
                                progressBarColor: GFColors.SUCCESS,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      '${torrentInfo.progress * 100}%',
                                      style: const TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: torrentInfo.state
                                          .toString()
                                          .contains('pause') ||
                                      torrentInfo.tracker.isEmpty == true
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
                                torrentInfo.category.isNotEmpty
                                    ? torrentInfo.category
                                    : '未分类',
                                style: const TextStyle(fontSize: 12),
                              ),
                              subtitle: Tooltip(
                                message: torrentInfo.contentPath,
                                child: Text(
                                  torrentInfo.contentPath,
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
                                    children: controller.qBCategoryMap.values
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
                                            // await controller.controlTorrents(
                                            //     command: 'recheck',
                                            //     hashes: [torrentInfo.hash!]);
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
                                    // await controller.controlTorrents(
                                    //     command: 'reannounce',
                                    //     hashes: [torrentInfo.hash!]);
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
                                        text: torrentInfo.infohashV1));
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
                                  color: torrentInfo.autoTmm
                                      ? GFColors.SUCCESS
                                      : GFColors.DANGER,
                                  onPressed: () async {
                                    Get.back();
                                    // await controller.controlTorrents(
                                    //     command: 'AutoManagement',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.autoTmm!);
                                    controller.update();
                                  },
                                  icon: torrentInfo.autoTmm
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
                                  color: torrentInfo.superSeeding
                                      ? GFColors.SUCCESS
                                      : GFColors.DANGER,
                                  onPressed: () async {
                                    Get.back();
                                    // await controller.controlTorrents(
                                    //     command: 'SuperSeeding',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.superSeeding!);
                                  },
                                  icon: torrentInfo.superSeeding
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
                                  color: torrentInfo.forceStart
                                      ? GFColors.SUCCESS
                                      : GFColors.DANGER,
                                  onPressed: () async {
                                    Get.back();
                                    // await controller.controlTorrents(
                                    //     command: 'ForceStart',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.forceStart!);
                                  },
                                  icon: torrentInfo.forceStart
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
                                        formatDuration(torrentInfo.seedingTime),
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
                                        controller.qBitStatus
                                            .firstWhere(
                                              (element) =>
                                                  element.value ==
                                                  torrentInfo.state,
                                              orElse: () => MetaDataItem(
                                                name: "未知状态",
                                                value: qb.TorrentState.unknown,
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
                                        filesize(torrentInfo.size),
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
                                  ...trackers.map((qb.Tracker e) => Padding(
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
                                                            qb.TrackerStatus
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
                  QBittorrentTreeView(contents),
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

  void _openTrTorrentInfoDetail(
      Downloader downloader, TrTorrent torrentInfo, context) async {
    logger_helper.Logger.instance.i(torrentInfo.files);

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
        child: GetBuilder<DownloadController>(builder: (controller) {
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
                        _openTrTorrentInfoDetail(downloader, e.value, context);
                      },
                      onDeleted: () {
                        // _removeTorrent(e.value);
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
                                            // Get.back(result: true);
                                            // await controller.controlTorrents(
                                            //     command: 'recheck',
                                            //     hashes: [
                                            //       torrentInfo.hashString
                                            //     ]);
                                            // Get.back();
                                            // controller.update();
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
                                    // await controller.controlTorrents(
                                    //     command: 'reannounce',
                                    //     hashes: [torrentInfo.hashString]);
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
                                //                 value: qb.TorrentState.unknown,
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
                  TransmissionTreeView(torrentInfo.files),
                  ListView(
                    children: [
                      Center(
                          child: Text(
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              'Tracker数量：${repeatTorrents.length}')),
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
