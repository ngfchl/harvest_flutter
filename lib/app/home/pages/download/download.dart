import 'dart:io';

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
import 'package:harvest/app/home/pages/download/tr_tree_file_view.dart';
import 'package:intl/intl.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
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
      List<TransferInfo> dataSource = downloader.status.cast<TransferInfo>();
      chartSeriesController?.updateDataSource(
        addedDataIndexes: <int>[dataSource.length - 1],
      );
      TransferInfo res = downloader.status.last;

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
                        AreaSeries<TransferInfo, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (TransferInfo sales, index) => index,
                          yValueMapper: (TransferInfo sales, _) =>
                              sales.dlInfoSpeed,
                          color: Colors.red.withOpacity(0.5),
                          name: '下载速度',
                          borderWidth: 1,
                        ),
                        AreaSeries<TransferInfo, int>(
                          onRendererCreated:
                              (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (TransferInfo sales, index) => index,
                          yValueMapper: (TransferInfo sales, _) =>
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
      TransferInfo res = downloader.status.last;

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
                  IconButton(
                      onPressed: () {}, icon: const Icon(Icons.speed_outlined)),
                  IconButton(
                      onPressed: () async {
                        await controller.stopFetchTorrents();
                        Get.back();
                      },
                      icon: const Icon(Icons.exit_to_app_outlined))
                ],
              ),
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
                                    TorrentInfo torrent =
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
                              height: 28,
                              child: TextField(
                                controller: controller.searchController,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: '请输入搜索关键字',
                                  hintStyle: const TextStyle(fontSize: 14),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 5),
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

  _showQbTorrent(Downloader downloader, TorrentInfo torrentInfo, context) {
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
                    hashes: [torrentInfo.hash!],
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
                            hashes: [torrentInfo.hash!],
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
                    hashes: [torrentInfo.hash!],
                    enable: !torrentInfo.autoTmm!,
                  );
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
                      torrentInfo.tracker!.isNotEmpty
                          ? CustomTextTag(
                              labelText: controller.trackers.entries
                                      .firstWhereOrNull((entry) => entry.value
                                          .contains(torrentInfo.hash))
                                      ?.key ??
                                  Uri.parse(torrentInfo.tracker!).host,
                              icon: const Icon(Icons.file_upload_outlined,
                                  size: 10, color: Colors.white),
                            )
                          : CustomTextTag(
                              labelText: controller.trackers.entries
                                      .firstWhereOrNull((entry) => entry.value
                                          .contains(torrentInfo.hash))
                                      ?.key ??
                                  (Uri.parse(torrentInfo.magnetUri!)
                                              .queryParametersAll["tr"]
                                              ?.first !=
                                          null
                                      ? Uri.parse(
                                              Uri.parse(torrentInfo.magnetUri!)
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
                                (element) =>
                                    element.value == torrentInfo.state!,
                                orElse: () => MetaDataItem(
                                    name: "未知状态", value: TorrentState.unknown))
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
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
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

  _showQbPrefs(Downloader downloader, context) {
    const List<Tab> tabs = [
      Tab(text: '下载'),
      Tab(text: '连接'),
      Tab(text: '速度'),
      Tab(text: 'Bittorrent'),
      Tab(text: 'RSS'),
      Tab(text: 'WEBUI'),
      Tab(text: '高级'),
    ];
    Preferences prefs = downloader.prefs;
    RxBool autoTmmEnabled = prefs.autoTmmEnabled!.obs;
    RxBool addTrackersEnabled = prefs.addTrackersEnabled!.obs;
    RxBool createSubfolderEnabled =
        prefs.createSubfolderEnabled?.obs ?? false.obs;
    RxBool startPausedEnabled = prefs.startPausedEnabled!.obs;
    RxBool torrentChangedTmmEnabled = prefs.torrentChangedTmmEnabled!.obs;
    RxBool savePathChangedTmmEnabled = prefs.savePathChangedTmmEnabled!.obs;
    RxBool categoryChangedTmmEnabled = prefs.categoryChangedTmmEnabled!.obs;
    RxBool tempPathEnabled = prefs.tempPathEnabled!.obs;
    RxBool mailNotificationEnabled = prefs.mailNotificationEnabled!.obs;
    RxBool mailNotificationSslEnabled = prefs.mailNotificationSslEnabled!.obs;
    RxBool mailNotificationAuthEnabled = prefs.mailNotificationAuthEnabled!.obs;
    RxBool autorunEnabled = prefs.autorunEnabled!.obs;
    RxBool queueingEnabled = prefs.queueingEnabled!.obs;
    RxBool maxRatioEnabled = prefs.maxRatioEnabled!.obs;
    RxBool schedulerEnabled = prefs.schedulerEnabled!.obs;
    RxBool proxyAuthEnabled = prefs.proxyAuthEnabled!.obs;
    RxBool ipFilterEnabled = prefs.ipFilterEnabled!.obs;
    RxBool webUiCsrfProtectionEnabled = prefs.webUiCsrfProtectionEnabled!.obs;
    RxBool webUiClickjackingProtectionEnabled =
        prefs.webUiClickjackingProtectionEnabled!.obs;
    RxBool webUiSecureCookieEnabled = prefs.webUiSecureCookieEnabled!.obs;
    RxBool webUiHostHeaderValidationEnabled =
        prefs.webUiHostHeaderValidationEnabled!.obs;
    RxBool bypassAuthSubnetWhitelistEnabled =
        prefs.bypassAuthSubnetWhitelistEnabled!.obs;
    RxBool alternativeWebUiEnabled = prefs.alternativeWebUiEnabled!.obs;
    RxBool dyndnsEnabled = prefs.dyndnsEnabled!.obs;
    RxBool rssProcessingEnabled = prefs.rssProcessingEnabled!.obs;
    RxBool rssAutoDownloadingEnabled = prefs.rssAutoDownloadingEnabled!.obs;
    RxBool maxSeedingTimeEnabled = prefs.maxSeedingTimeEnabled!.obs;

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
              body: TabBarView(children: [
                ListView(
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('添加种子时'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'subfloder', child: Text('子文件夹')),
                                  DropdownMenuItem(
                                      value: 'subfloder', child: Text('原始')),
                                  DropdownMenuItem(
                                      value: 'subfloder',
                                      child: Text('不创建子文件夹')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('不要开始自动下载'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('种子停止条件'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'subfloder', child: Text('无')),
                                  DropdownMenuItem(
                                      value: 'subfloder',
                                      child: Text('已收到元数据')),
                                  DropdownMenuItem(
                                      value: 'subfloder', child: Text('选种的文件')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('完成后删除.torrent文件'),
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('为所有文件预分配磁盘空间'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('为不完整的文件添加扩展名 .!qB'),
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                        child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('默认 Torrent 管理模式'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'subfloder', child: Text('手动')),
                                DropdownMenuItem(
                                    value: 'subfloder', child: Text('自动')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('当 Torrent 分类修改时'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'subfloder', child: Text('重新定位')),
                                DropdownMenuItem(
                                    value: 'subfloder', child: Text('切换手动')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('当默认保存路径修改时'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'subfloder',
                                    child: Text('重新定位受影响的种子')),
                                DropdownMenuItem(
                                    value: 'subfloder',
                                    child: Text('切换受影响的种子为手动')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('当分类保存路径修改时'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'subfloder',
                                    child: Text('重新定位受影响的种子')),
                                DropdownMenuItem(
                                    value: 'subfloder',
                                    child: Text('切换受影响的种子为手动')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        CustomTextField(
                            controller: TextEditingController(
                                text: prefs.savePath.toString()),
                            labelText: '默认保存目录'),
                        CheckboxListTile(
                          dense: true,
                          value: false,
                          onChanged: (value) {},
                          title: const Text('保存未完成的 torrent 到'),
                        ),
                        CustomTextField(
                            controller: TextEditingController(
                                text:
                                    '${prefs.savePath.toString()}/incomplete'),
                            labelText: '默认保存目录'),
                        CheckboxListTile(
                          dense: true,
                          value: false,
                          onChanged: (value) {},
                          title: const Text('保存未完成的 torrent 到'),
                        ),
                        CustomTextField(
                            controller: TextEditingController(
                                text:
                                    '${prefs.savePath.toString()}/incomplete'),
                            labelText: '默认保存目录'),
                        CheckboxListTile(
                          dense: true,
                          value: false,
                          onChanged: (value) {},
                          title: const Text('保存未完成的 torrent 到'),
                        ),
                        CustomTextField(
                            controller: TextEditingController(
                                text:
                                    '${prefs.savePath.toString()}/incomplete'),
                            labelText: '未完成目录'),
                        CheckboxListTile(
                          dense: true,
                          value: false,
                          onChanged: (value) {},
                          title: const Text('复制下载完成的 .torrent 文件到'),
                        ),
                        CustomTextField(
                            controller: TextEditingController(
                                text:
                                    '${prefs.savePath.toString()}/incomplete'),
                            labelText: '复制下载完成的 .torrent 文件到'),
                      ],
                    )),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('下载连接协议'),
                          DropdownButton(items: const [
                            DropdownMenuItem(
                                value: 'tcp utp', child: Text('TCP 和 UTP')),
                            DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                            DropdownMenuItem(value: 'utp', child: Text('UTP')),
                          ], onChanged: (value) {}),
                        ],
                      ),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                    controller: TextEditingController(
                                      text: '${prefs.embeddedTrackerPort}',
                                    ),
                                    labelText: '用于传入连接的端口'),
                              ),
                              ElevatedButton(
                                  onPressed: () {}, child: const Text('随机'))
                            ],
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title:
                                const Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.randomPort,
                            onChanged: (value) {},
                            title: const Text('使用随机端口'),
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('全局最大连接数'),
                          ),
                          CustomTextField(
                              controller: TextEditingController(
                                text: prefs.savePath.toString(),
                              ),
                              labelText: '全局最大连接数'),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('每 torrent 最大连接数'),
                          ),
                          CustomTextField(
                              controller: TextEditingController(
                                text: prefs.maxConnecPerTorrent.toString(),
                              ),
                              labelText: '每 torrent 最大连接数'),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('全局上传窗口数上限'),
                          ),
                          CustomTextField(
                              controller: TextEditingController(
                                text: prefs.maxConnec.toString(),
                              ),
                              labelText: '全局上传窗口数上限'),
                          CheckboxListTile(
                            dense: true,
                            value: false,
                            onChanged: (value) {},
                            title: const Text('每个 torrent 上传窗口数上限'),
                          ),
                          CustomTextField(
                              controller: TextEditingController(
                                text: prefs.savePath.toString(),
                              ),
                              labelText: '每个 torrent 上传窗口数上限'),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          const Text('全局速度限制'),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '${prefs.embeddedTrackerPort}',
                            ),
                            labelText: '上传',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '${prefs.embeddedTrackerPort}',
                            ),
                            labelText: '下载',
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          const Text('备用速度限制'),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '${prefs.embeddedTrackerPort}',
                            ),
                            labelText: '上传',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '${prefs.embeddedTrackerPort}',
                            ),
                            labelText: '下载',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('计划备用速度限制的启用时间'),
                          ),
                          CustomTextField(
                              controller: TextEditingController(
                                text: '',
                              ),
                              labelText: '自动启用备用带宽设置开始时间'),
                          CustomTextField(
                              controller: TextEditingController(
                                text: 'prefs.altSpeedTimeEnd.toString()',
                              ),
                              labelText: '自动启用备用带宽设置结束时间'),
                        ],
                      ),
                    ),
                    CustomCard(
                        child: Column(
                      children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('对 µTP 协议进行速度限制'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('对传送总开销进行速度限制'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('对本地网络用户进行速度限制'),
                        ),
                      ],
                    )),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('启用 DHT (去中心化网络) 以找到更多用户'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('启用用户交换 (PeX) 以找到更多用户'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('启用本地用户发现以找到更多用户'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('加密模式'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'tcp utp', child: Text('允许加密')),
                                  DropdownMenuItem(
                                      value: 'tcp', child: Text('强制加密')),
                                  DropdownMenuItem(
                                      value: 'utp', child: Text('禁用加密')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('启用匿名模式'),
                          ),
                        ],
                      ),
                    ),
                    CustomCard(
                      child: CustomTextField(
                        controller: TextEditingController(
                          text: 'prefs.altSpeedTimeEnd.toString()',
                        ),
                        labelText: '最大活跃检查种子数',
                      ),
                    ),
                    CustomCard(
                        child: Column(
                      children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('Torrent 排队'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: '最大活动的下载数',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: '最大活动的上传数',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: '最大活动的 torrent 数',
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('慢速 torrent 不计入限制内'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: '下载速度阈值',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: '上传速度阈值',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: 'prefs.altSpeedTimeEnd.toString()',
                          ),
                          labelText: 'Torrent 非活动计时器',
                        ),
                      ],
                    )),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                        child: Column(
                      children: [
                        const Text('RSS'),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用获取 RSS 订阅'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: 'RSS 订阅源更新间隔(分钟)',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '每个订阅源文章数目最大值(个)',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '最大活动的 torrent 数',
                        ),
                      ],
                    )),
                    CustomCard(
                        child: Column(children: [
                      CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('启用 RSS Torrent 自动下载'),
                      ),
                    ])),
                    CustomCard(
                      child: Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('下载 REPACK/PROPER 版剧集'),
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            maxLines: 5,
                            labelText: '过滤器',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('用户界面语言'),
                            DropdownButton(items: const [
                              DropdownMenuItem(
                                  value: 'zh_CN', child: Text(' 简体中文')),
                              DropdownMenuItem(
                                  value: 'en_US', child: Text('English')),
                            ], onChanged: (value) {}),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      child: CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('记录性能警报'),
                      ),
                    ),
                    CustomCard(
                        child: Column(children: [
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: 'IP 地址',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '端口',
                      ),
                      CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口'),
                      ),
                      CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('使用 HTTPS 而不是 HTTP'),
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '证书',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '密钥',
                      ),
                    ])),
                    CustomCard(
                        child: Column(children: [
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '用户名',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '密码',
                      ),
                      CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('对本地主机上的客户端跳过身份验证'),
                      ),
                      CheckboxListTile(
                        dense: true,
                        value: prefs.upnp,
                        onChanged: (value) {},
                        title: const Text('对 IP 子网白名单中的客户端跳过身份验证'),
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        maxLines: 5,
                        labelText: '对 IP 子网白名单中的客户端跳过身份验证',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '连续失败后禁止客户端(次)',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '连续失败后禁止时长(秒)',
                      ),
                      CustomTextField(
                        controller: TextEditingController(
                          text: '',
                        ),
                        labelText: '会话超时时间(秒)',
                      ),
                    ])),
                    CustomCard(
                      child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('使用备用 Web UI'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '备用 Web UI 路径',
                        ),
                      ]),
                    ),
                    CustomCard(
                      child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用 “点击劫持” 保护'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用跨站请求伪造 (CSRF) 保护'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用 cookie 安全标志（需要 HTTPS）'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用 Host header 属性验证'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '服务器域名',
                        ),
                      ]),
                    ),
                    CustomCard(
                      child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('添加自定义 HTTP 头字段'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          maxLines: 5,
                          labelText: 'HTTP 头字段（每行一个）',
                        ),
                      ]),
                    ),
                    CustomCard(
                      child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用反向代理支持'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '受信任的代理列表',
                        ),
                      ]),
                    ),
                    CustomCard(
                      child: Column(children: [
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('更新我的动态域名'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('域名提供商'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'zh_CN', child: Text('DynDNS')),
                                DropdownMenuItem(
                                    value: 'en_US', child: Text('NO-IP')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '域名',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '用户名',
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '密码',
                        ),
                      ]),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    CustomCard(
                      child: Column(children: [
                        const Text('qBittorrent 相关'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('恢复数据存储类型（需要重新启动）'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'zh_CN', child: Text('快速恢复文件')),
                                DropdownMenuItem(
                                    value: 'en_US', child: Text('SQLite 数据库')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '物理内存使用上限（仅 libtorrent >= 2.0 时应用）（MiB）',
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('网络接口'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'zh_CN', child: Text('快速恢复文件')),
                                DropdownMenuItem(
                                    value: 'en_US', child: Text('SQLite 数据库')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('绑定到的可选 IP 地址'),
                              DropdownButton(items: const [
                                DropdownMenuItem(
                                    value: 'zh_CN', child: Text('快速恢复文件')),
                                DropdownMenuItem(
                                    value: 'en_US', child: Text('SQLite 数据库')),
                              ], onChanged: (value) {}),
                            ],
                          ),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '保存恢复数据间隔（分钟）',
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('解析用户所在国家'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('当 IP 或端口更改时，重新通知所有 trackers'),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('启用内置 Tracker'),
                        ),
                        CustomTextField(
                          controller: TextEditingController(
                            text: '',
                          ),
                          labelText: '内置 tracker 端口',
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: prefs.upnp,
                          onChanged: (value) {},
                          title: const Text('对嵌入的 tracker 启用端口转发'),
                        ),
                      ]),
                    ),
                    CustomCard(
                      child: Column(
                        children: [
                          const Text('libtorrent 相关'),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '异步 I/O 线程数',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '散列线程（需要 libtorrent> = 2.0）',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '文件池大小',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '校验时内存使用扩增量(MiB)',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '磁盘缓存（需要 libtorrent < 2.0）(MiB)',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '磁盘缓存过期时间间隔（要求 libtorrent < 2.0）(秒)',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '磁盘队列大小（KiB）',
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('合并读写（需要 libtorrent<2.0）'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('启用相连文件块下载模式'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('发送分块上传建议'),
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '发送缓冲区上限（KiB）',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '发送缓冲区下限（KiB）',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '发送缓冲区增长系数（%）',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '每秒传出连接数： (?)	',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: 'Socket backlog 大小',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '传出端口 (下限) [0: 禁用]',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '传出端口 (上限) [0: 禁用]',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: 'UPnP 租期 [0：永久]',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '与 peers 连接的服务类型（ToS）',
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('μTP-TCP 混合模式策略'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'zh_CN', child: Text('DynDNS')),
                                  DropdownMenuItem(
                                      value: 'en_US', child: Text('NO-IP')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('支持国际化域名（IDN）'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('允许来自同一 IP 地址的多个连接'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('验证 HTTPS tracker 证书'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('服务器端请求伪造（SSRF）攻击缓解'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('禁止连接到特权端口上的 Peer'),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('上传窗口策略'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'zh_CN', child: Text('DynDNS')),
                                  DropdownMenuItem(
                                      value: 'en_US', child: Text('NO-IP')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('上传连接策略'),
                                DropdownButton(items: const [
                                  DropdownMenuItem(
                                      value: 'zh_CN', child: Text('DynDNS')),
                                  DropdownMenuItem(
                                      value: 'en_US', child: Text('NO-IP')),
                                ], onChanged: (value) {}),
                              ],
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('总是向同级的所有 Tracker 汇报'),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: prefs.upnp,
                            onChanged: (value) {},
                            title: const Text('总是向所有等级的 Tracker 汇报'),
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: 'IP 地址已报告给 Trackers (需要重启)',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '最大并行 HTTP 发布',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '停止 tracker 超时',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: 'Peer 进出阈值百分比',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: 'Peer 进出断开间隔',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '单一 peer 的最大未完成请求',
                          ),
                          CustomTextField(
                            controller: TextEditingController(
                              text: '',
                            ),
                            labelText: '与 peers 连接的服务类型（ToS）',
                          ),
                        ],
                      ),
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

  _showTrPrefs(Downloader downloader, context) {
    const List<Tab> tabs = [
      Tab(text: '下载设置'),
      Tab(text: '网络设置'),
      Tab(text: '带宽设置'),
      Tab(text: '队列设置'),
    ];
    TransmissionConfig prefs = downloader.prefs;
    // 限速开关
    RxBool altSpeedEnabled = RxBool(prefs.altSpeedEnabled);
    // 自动按时间限速开关
    RxBool altSpeedTimeEnabled = RxBool(prefs.altSpeedTimeEnabled);
    // 黑名单开关
    RxBool blocklistEnabled = RxBool(prefs.blocklistEnabled);
    // 分布式 HASH 表
    RxBool dhtEnabled = RxBool(prefs.dhtEnabled);
    // 下载队列开关
    RxBool downloadQueueEnabled = RxBool(prefs.downloadQueueEnabled);
    // 种子超时无流量移出队列开关
    RxBool idleSeedingLimitEnabled = RxBool(prefs.idleSeedingLimitEnabled);
    // 临时目录开关
    RxBool incompleteDirEnabled = RxBool(prefs.incompleteDirEnabled);
    // 允许本地对等点发现
    RxBool lpdEnabled = RxBool(prefs.lpdEnabled);
    // 端口转发开关
    RxBool portForwardingEnabled = RxBool(prefs.portForwardingEnabled);
    // PEX开关
    RxBool pexEnabled = RxBool(prefs.pexEnabled);
    RxBool peerPortRandomOnStart = RxBool(prefs.peerPortRandomOnStart);
    // 队列等待开关
    RxBool queueStalledEnabled = RxBool(prefs.queueStalledEnabled);
    // 种子做种队列开关
    RxBool seedQueueEnabled = RxBool(prefs.seedQueueEnabled);
    // 未完成种子添加 part
    RxBool renamePartialFiles = RxBool(prefs.renamePartialFiles);
    // 种子上传限速开关
    RxBool speedLimitUpEnabled = RxBool(prefs.speedLimitUpEnabled);
    RxBool seedRatioLimited = RxBool(prefs.seedRatioLimited);
    // 种子下载限速开关
    RxBool speedLimitDownEnabled = RxBool(prefs.speedLimitDownEnabled);
    // 脚本种子添加开关
    // RxBool scriptTorrentAddedEnabled = RxBool(prefs.scriptTorrentAddedEnabled);
    // 脚本种子完成开关
    // RxBool scriptTorrentDoneSeedingEnabled =
    //     RxBool(prefs.scriptTorrentDoneSeedingEnabled);
    // TCP开关
    // RxBool tcpEnabled = RxBool(prefs.tcpEnabled);
    // UTP开关
    // RxBool utpEnabled = RxBool(prefs.utpEnabled);
    List<MetaDataItem> daysOfWeek = [
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
        .map((item) => MetaDataItem(name: item.value, value: item.key))
        .toList();
    List<int> daysOfWeekMask =
        TransmissionUtils.getEnabledDaysFromAltSpeedTimeDay(
            prefs.altSpeedTimeDay);
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
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.downloadDir.toString()),
                        labelText: '默认保存目录'),
                    CheckboxListTile(
                      value: renamePartialFiles.value,
                      onChanged: (value) {
                        prefs.renamePartialFiles = value!;
                      },
                      title: const Text('在未完成的文件名后加上 “.part” 后缀'),
                    ),
                    CheckboxListTile(
                      value: incompleteDirEnabled.value,
                      onChanged: (value) {
                        prefs.incompleteDirEnabled = value!;
                      },
                      title: const Text('启用临时目录'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.incompleteDir.toString()),
                        labelText: '临时目录'),
                    CheckboxListTile(
                      value: seedRatioLimited.value,
                      onChanged: (value) {},
                      title: const Text('默认分享率上限'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.seedRatioLimit.toString()),
                        labelText: '默认分享率上限'),
                    CheckboxListTile(
                      value: idleSeedingLimitEnabled.value,
                      onChanged: (value) {},
                      title: const Text('默认停止无流量种子持续时间(分钟)'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.idleSeedingLimit.toString()),
                        labelText: '默认停止无流量种子持续时间(分钟)'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.cacheSizeMb.toString()),
                        labelText: '磁盘缓存大小（MB）'),
                  ],
                ),
                ListView(
                  children: [
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.peerPort.toString()),
                        labelText: '连接端口号'),
                    FullWidthButton(onPressed: () {}, text: '测试端口'),
                    CheckboxListTile(
                      value: peerPortRandomOnStart.value,
                      onChanged: (value) {
                        prefs.peerPortRandomOnStart = value!;
                      },
                      title: const Text('启用随机端口'),
                    ),
                    CheckboxListTile(
                      value: portForwardingEnabled.value,
                      onChanged: (value) {
                        prefs.portForwardingEnabled = value!;
                      },
                      title: const Text('启用端口转发 (UPnP)'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.encryption.toString()),
                        labelText: '加密'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.peerLimitGlobal.toString()),
                        labelText: '全局最大链接数'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.peerLimitPerTorrent.toString()),
                        labelText: '单种最大链接数'),
                    CheckboxListTile(
                      value: pexEnabled.value,
                      onChanged: (value) {},
                      title: const Text('启用本地用户交换'),
                    ),
                    CheckboxListTile(
                      value: lpdEnabled.value,
                      onChanged: (value) {},
                      title: const Text('对等交换'),
                    ),
                    CheckboxListTile(
                      value: dhtEnabled.value,
                      onChanged: (value) {},
                      title: const Text('启用分布式哈希表 (DHT)'),
                    ),
                    CheckboxListTile(
                      value: blocklistEnabled.value,
                      onChanged: (value) {},
                      title: const Text('启用黑名单列表:'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.blocklistUrl.toString()),
                        labelText: '黑名单列表'),
                    ElevatedButton(
                        onPressed: () {},
                        child: Text('更新黑名单【${prefs.blocklistSize}】'))
                  ],
                ),
                ListView(
                  children: [
                    CheckboxListTile(
                      value: speedLimitDownEnabled.value,
                      onChanged: (value) {},
                      title: const Text('最大下载速度 (KB/s):'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.speedLimitDown.toString()),
                        labelText: '正常最大下载速度(KB/s)'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.altSpeedDown.toString()),
                        labelText: '备用最大下载速度(KB/s)'),
                    CheckboxListTile(
                      value: speedLimitUpEnabled.value,
                      onChanged: (value) {},
                      title: const Text('最大上传速度 (KB/s):'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.speedLimitUp.toString()),
                        labelText: '正常最大上传速度(KB/s)'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.altSpeedUp.toString()),
                        labelText: '备用最大上传速度(KB/s)'),
                    CheckboxListTile(
                      value: altSpeedEnabled.value,
                      onChanged: (value) {},
                      title: const Text('启用备用带宽'),
                    ),
                    CheckboxListTile(
                      value: altSpeedTimeEnabled.value,
                      onChanged: (value) {},
                      title: const Text('自动启用备用带宽设置 (时间段内)'),
                    ),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.altSpeedTimeBegin.toString()),
                        labelText: '自动启用备用带宽设置开始时间'),
                    CustomTextField(
                        controller: TextEditingController(
                            text: prefs.altSpeedTimeEnd.toString()),
                        labelText: '自动启用备用带宽设置结束时间'),
                    Text('${prefs.altSpeedTimeDay}'),
                    Wrap(
                      children: [
                        ...daysOfWeek.map(
                          (item) => CheckboxListTile(
                            value: daysOfWeekMask.contains(item.value),
                            onChanged: (value) {
                              logger_helper.Logger.instance.d(value);
                              if (value == true) {
                                prefs.altSpeedTimeDay += int.parse(item.value);
                              } else {
                                prefs.altSpeedTimeDay -= int.parse(item.value);
                              }
                            },
                            title: Text(item.name),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                ListView(children: [
                  CheckboxListTile(
                    value: downloadQueueEnabled.value,
                    onChanged: (value) {},
                    title: const Text('启用下载队列，最大同时下载数'),
                  ),
                  CustomTextField(
                      controller: TextEditingController(
                          text: prefs.downloadQueueSize.toString()),
                      labelText: '启用下载队列，最大同时下载数'),
                  CheckboxListTile(
                    value: seedQueueEnabled.value,
                    onChanged: (value) {},
                    title: const Text('启用上传队列，最大同时上传数'),
                  ),
                  CustomTextField(
                      controller: TextEditingController(
                          text: prefs.seedQueueSize.toString()),
                      labelText: '启用上传队列，最大同时上传数'),
                  CheckboxListTile(
                    value: queueStalledEnabled.value,
                    onChanged: (value) {},
                    title: const Text('种子超过该时间无流量，移出队列'),
                  ),
                  CustomTextField(
                      controller: TextEditingController(
                          text: prefs.queueStalledMinutes.toString()),
                      labelText: '种子超过该时间无流量，移出队列(分钟)'),
                ]),
              ]),
            ),
          );
        }),
      ),
    );
  }

  void _openQbTorrentInfoDetail(
      Downloader downloader, TorrentInfo torrentInfo, context) async {
    if (torrentInfo.hash == null) {
      Get.snackbar('错误', '无法获取torrent信息: ${torrentInfo.hash}',
          colorText: Theme.of(context).colorScheme.error);
      return;
    }
    logger_helper.Logger.instance.d(torrentInfo.hash);
    CommonResponse response = await controller.getDownloaderTorrentDetailInfo(
        downloader, torrentInfo.hash!);
    // TorrentProperties properties =
    //     TorrentProperties.fromJson(response.data['properties']);
    List<TorrentContents> contents = response.data['files']
        .map<TorrentContents>((item) => TorrentContents.fromJson(item))
        .toList();
    List<Tracker> trackers = response.data['trackers']
        .map<Tracker>((item) => Tracker.fromJson(item))
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
                                    // await controller.controlTorrents(
                                    //     command: 'AutoManagement',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.autoTmm!);
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
                                    // await controller.controlTorrents(
                                    //     command: 'SuperSeeding',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.superSeeding!);
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
                                    // await controller.controlTorrents(
                                    //     command: 'ForceStart',
                                    //     hashes: [torrentInfo.hash!],
                                    //     enable: !torrentInfo.forceStart!);
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
                                        controller.qBitStatus
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
}
