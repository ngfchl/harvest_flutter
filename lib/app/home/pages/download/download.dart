import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../../utils/storage.dart';
import '../../../routes/app_pages.dart';
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
                    initialData: controller.dataList,
                    builder: (context, snapshot) {
                      controller.isLoaded = snapshot.hasData;
                      return EasyRefresh(
                        controller: EasyRefreshController(),
                        onRefresh: () async {
                          controller.getDownloaderListFromServer();
                        },
                        child: controller.isLoaded
                            ? ListView.builder(
                                itemCount: controller.dataList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Downloader downloader =
                                      controller.dataList[index];
                                  return buildDownloaderCard(downloader);
                                })
                            : Center(
                                child: ListView(
                                children: const [Expanded(child: GFLoader())],
                              )),
                      );
                    });
              }),
            ),
            if (!identical(0, 0.0) && Platform.isIOS)
              const SizedBox(height: 10),
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
            IconButton(
              icon: Icon(
                controller.isTimerActive ? Icons.pause : Icons.play_arrow,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => controller.toggleRealTimeState(),
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
                                    controller.cancelPeriodicTimer();
                                  } else {
                                    controller.startPeriodicTimer();
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
                                        if (controller.duration.toInt() > 3) {
                                          controller.duration--;
                                          SPUtil.setDouble(
                                              'duration', controller.duration);
                                          controller.update();
                                        }
                                      },
                                    ),
                                    Expanded(
                                      child: Slider(
                                          min: 3,
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
      return const GFLoader();
    }
    // LoggerHelper.Logger.instance.w(downloader.status.length);
    double chartHeight = 80;
    var tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      decimalPlaces: 1,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
          int seriesIndex) {
        // Logger.instance.w(data);
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
                      if (res.speedLimitSettings?.speedLimitUpEnabled == true)
                        Text(
                          '上传限速：${filesize(res.speedLimitSettings!.speedLimitUp * 1024)}/s',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (res.speedLimitSettings?.speedLimitDownEnabled == true)
                        Text(
                          '下载限速：${filesize(res.speedLimitSettings!.speedLimitDown * 1024)}/s',
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
    if (downloader.isActive) {
      controller.testConnect(downloader).then((res) {
        connectState.value = res.data;
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
          padding: const EdgeInsets.only(bottom: 16),
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
                  controller.cancelPeriodicTimer();
                  if (downloader.category == 'Qb') {
                    if (identical(0, 0.0)) {
                      Uri uri = Uri.parse(pathDownloader);
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.toNamed(Routes.QB, arguments: downloader);
                    }
                  }
                  if (downloader.category == 'Tr') {
                    Get.toNamed(Routes.TR, arguments: downloader);
                    // Get.toNamed(Routes.TORRENT, arguments: downloader);
                  }
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
                      connectState.value = res.data;
                      Get.snackbar(
                        '下载器连接测试',
                        res.msg!,
                        colorText: res.code == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      );
                    });
                  },
                ),
              ),
              GetBuilder<DownloadController>(builder: (controller) {
                return controller.realTimeState
                    ? _buildLiveLineChart(downloader, chartSeriesController)
                    : const SizedBox.shrink();
              })
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
      // LoggerHelper.Logger.instance.w(res.runtimeType);
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
    final nameController = TextEditingController(text: downloader?.name ?? '');
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
                              child: Obx(() {
                                return SwitchTile(
                                  title: brush.value ? '刷流' : '辅种',
                                  value: brush.value,
                                  onChanged: (value) {
                                    brush.value = value;
                                  },
                                );
                              }),
                            ),
                          ]);
                    }),
                  ],
                ),
              ),
            ),
            ButtonBar(
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
                    LoggerHelper.Logger.instance.i(downloader?.toJson());
                    CommonResponse response =
                        await controller.saveDownloaderToServer(downloader!);
                    if (response.code == 0) {
                      Navigator.of(context).pop();
                      Get.snackbar(
                        '保存成功！',
                        response.msg!,
                        snackPosition: SnackPosition.TOP,
                        colorText: Theme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 3),
                      );
                      await controller.getDownloaderListFromServer();
                      controller.update();
                    } else {
                      Get.snackbar(
                        '保存出错啦！',
                        response.msg!,
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
}
