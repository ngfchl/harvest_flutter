import 'dart:math';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/download/qb_file_tree_view.dart';
import 'package:harvest/app/home/pages/download/tr_tree_file_view.dart';
import 'package:harvest/app/home/pages/models/qbittorrent.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart' as qb;
import 'package:random_color/random_color.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/meta_item.dart';
import '../../../../common/utils.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../../../utils/storage.dart';
import '../../../../utils/string_utils.dart';
import '../../../routes/app_pages.dart';
import '../models/download.dart';
import '../models/transmission.dart';
import '../models/transmission_base_torrent.dart';
import 'download_controller.dart';
import 'download_form.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final controller = Get.put(DownloadController(true));

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GetBuilder<DownloadController>(builder: (controller) {
          return StreamBuilder<List<Downloader>>(
              stream: controller.downloadStream,
              // initialData: controller.dataList,
              builder: (context, snapshot) {
                // controller.isLoaded = snapshot.hasData;
                return EasyRefresh(
                    header: ClassicHeader(
                      dragText: '下拉刷新...',
                      readyText: '松开刷新',
                      processingText: '正在刷新...',
                      processedText: '刷新完成',
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: shadColorScheme.foreground,
                        fontWeight: FontWeight.bold,
                      ),
                      messageStyle: TextStyle(
                        fontSize: 12,
                        color: shadColorScheme.foreground,
                      ),
                    ),
                    controller: EasyRefreshController(),
                    onRefresh: () => controller.getDownloaderListFromServer(withStatus: true),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              direction: Axis.horizontal,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              runAlignment: WrapAlignment.start,
                              children: controller.dataList
                                  .map((downloader) => FractionallySizedBox(
                                        widthFactor: getWidthFactor(context),
                                        child: buildDownloaderCard(downloader),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                        if (controller.loading)
                          const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ));
              });
        }),
        floatingActionButton: _buildBottomButtonBar(),
      ),
    );
  }

  Widget _buildBottomButtonBar() {
    return GetBuilder<DownloadController>(builder: (controller) {
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // IconButton(
          //   icon: Icon(
          //     controller.isTimerActive ? Icons.pause : Icons.play_arrow,
          //     size: 20,
          //     color: ShadTheme.of(context).colorScheme.foreground,
          //   ),
          //   onPressed: () => controller.toggleRealTimeState(),
          // ),
          ShadIconButton.ghost(
            icon: Icon(
              controller.isLoading ? Icons.pause_outlined : Icons.play_arrow_outlined,
              size: 24,
            ),
            onPressed: () => controller.toggleFetchStatus(),
          ),
          ShadIconButton.ghost(
              icon: Icon(
                Icons.settings_outlined,
                size: 24,
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
                            ListTile(
                              dense: true,
                              title: Text(
                                '状态刷新',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: shadColorScheme.foreground,
                                ),
                              ),
                              trailing: ShadSwitch(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  CustomTextTag(
                                      backgroundColor: Colors.transparent, labelText: '刷新间隔：${controller.duration}秒'),
                                  InkWell(
                                    child: Icon(
                                      Icons.remove,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.duration.toInt() > 1) {
                                        controller.duration--;
                                        SPUtil.setDouble('duration', controller.duration);
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
                                        divisions: 14,
                                        label: controller.duration.toString(),
                                        value: controller.duration.toDouble(),
                                        activeColor: shadColorScheme.primary,
                                        onChanged: (duration) {
                                          controller.duration = duration;
                                          SPUtil.setDouble('duration', controller.duration);
                                          controller.update();
                                        }),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.duration.toInt() < 15) {
                                        controller.duration++;
                                        SPUtil.setDouble('duration', controller.duration);
                                        controller.update();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  CustomTextTag(
                                      backgroundColor: Colors.transparent,
                                      labelText: '分页大小：${controller.pageSize * 10}个'),
                                  InkWell(
                                    child: Icon(
                                      Icons.remove,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.pageSize.toInt() > 10) {
                                        controller.pageSize -= 10;
                                        SPUtil.setInt('pageSize', controller.pageSize);
                                        controller.update();
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                        min: 1,
                                        max: 20,
                                        divisions: 19,
                                        label: controller.pageSize.toString(),
                                        value: controller.pageSize / 10,
                                        activeColor: shadColorScheme.primary,
                                        onChanged: (pageSize) {
                                          controller.pageSize = (pageSize * 10).toInt();
                                          SPUtil.setInt('pageSize', controller.pageSize);
                                          controller.update();
                                        }),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.pageSize.toInt() < 200) {
                                        controller.pageSize += 10;
                                        SPUtil.setInt('pageSize', controller.pageSize);
                                        controller.update();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                children: [
                                  CustomTextTag(
                                      backgroundColor: Colors.transparent,
                                      labelText: '刷新时长：${controller.timerDuration}分'),
                                  InkWell(
                                    child: Icon(
                                      Icons.remove,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.timerDuration.toInt() > 3) {
                                        controller.timerDuration--;
                                        SPUtil.setDouble('timerDuration', controller.timerDuration);
                                        controller.update();
                                      }
                                    },
                                  ),
                                  Expanded(
                                    child: Slider(
                                        min: 3,
                                        max: 15,
                                        divisions: 12,
                                        label: controller.timerDuration.toString(),
                                        value: controller.timerDuration.toDouble(),
                                        activeColor: shadColorScheme.primary,
                                        onChanged: (duration) {
                                          controller.timerDuration = duration;
                                          SPUtil.setDouble('timerDuration', duration);
                                          controller.update();
                                        }),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.add,
                                      color: shadColorScheme.foreground,
                                    ),
                                    onTap: () {
                                      if (controller.timerDuration.toInt() < 15) {
                                        controller.timerDuration++;
                                        SPUtil.setDouble('timerDuration', controller.timerDuration);
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
          ShadIconButton.ghost(
            icon: Icon(
              Icons.add_outlined,
              size: 24,
            ),
            onPressed: () async {
              _showEditBottomSheet();
            },
          ),
        ],
      );
    });
  }

  Widget _buildLiveLineChart(Downloader downloader, ChartSeriesController? chartSeriesController) {
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
      return Center(child: const CircularProgressIndicator());
    }
    double chartHeight = 80;
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    var tooltipBehavior = TooltipBehavior(
      enable: true,
      shared: true,
      decimalPlaces: 1,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        return Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            color: shadColorScheme.background,
          ),
          child: Text(
            '${series.name}: ${FileSizeConvert.parseToFileSize(point.y)}',
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        );
      },
    );
    if (downloader.category.toLowerCase() == 'qb') {
      List<qb.ServerState> dataSource = downloader.status.cast<qb.ServerState>();
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
                      primaryXAxis: CategoryAxis(
                          isVisible: false,
                          labelStyle: TextStyle(color: shadColorScheme.foreground),
                          majorGridLines: MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          labelStyle: TextStyle(color: shadColorScheme.foreground),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              FileSizeConvert.parseToFileSize(details.value),
                              const TextStyle(
                                fontSize: 10,
                              ),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: [
                        AreaSeries<qb.ServerState, int>(
                          onRendererCreated: (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (qb.ServerState sales, index) => index,
                          yValueMapper: (qb.ServerState sales, _) => sales.dlInfoSpeed,
                          color: Colors.red.withOpacity(0.5),
                          name: '下载速度',
                          borderWidth: 1,
                        ),
                        AreaSeries<qb.ServerState, int>(
                          onRendererCreated: (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          enableTooltip: true,
                          xValueMapper: (qb.ServerState sales, index) => index,
                          yValueMapper: (qb.ServerState sales, _) => sales.upInfoSpeed,
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
                        '上传限速：${FileSizeConvert.parseToFileSize(res.upRateLimit)}/s',
                        style: TextStyle(
                          fontSize: 10,
                          color: shadColorScheme.foreground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '下载限速：${FileSizeConvert.parseToFileSize(res.dlRateLimit)}/s',
                        style: TextStyle(
                          fontSize: 10,
                          color: shadColorScheme.foreground,
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
      List<TransmissionStats> dataSource = downloader.status.cast<TransmissionStats>();
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
                      primaryXAxis: CategoryAxis(
                          isVisible: false,
                          labelStyle: TextStyle(color: shadColorScheme.foreground),
                          majorGridLines: MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.none),
                      primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(width: 0),
                          labelStyle: TextStyle(color: shadColorScheme.foreground),
                          axisLabelFormatter: (AxisLabelRenderDetails details) {
                            return ChartAxisLabel(
                              FileSizeConvert.parseToFileSize(details.value),
                              const TextStyle(fontSize: 10),
                            );
                          },
                          majorTickLines: const MajorTickLines(size: 0)),
                      series: <AreaSeries<TransmissionStats, int>>[
                        AreaSeries<TransmissionStats, int>(
                          onRendererCreated: (ChartSeriesController controller) {
                            chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) => index,
                          yValueMapper: (TransmissionStats sales, _) => sales.uploadSpeed,
                          color: Colors.blue.withOpacity(0.9),
                          name: '上传速度',
                          borderWidth: 1,
                        ),
                        AreaSeries<TransmissionStats, int>(
                          onRendererCreated: (ChartSeriesController controller) {
                            // _chartSeriesController = controller;
                          },
                          animationDuration: 0,
                          dataSource: dataSource,
                          xValueMapper: (TransmissionStats sales, index) => index,
                          yValueMapper: (TransmissionStats sales, _) => sales.downloadSpeed,
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
                        style: TextStyle(
                          fontSize: 10,
                          color: shadColorScheme.foreground,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const SizedBox(width: 8),
                      if (downloader.prefs.speedLimitUpEnabled == true)
                        Text(
                          '上传限速：${FileSizeConvert.parseToFileSize(downloader.prefs.speedLimitUp * 1024)}/s',
                          style: TextStyle(
                            fontSize: 10,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (downloader.prefs.speedLimitDownEnabled == true)
                        Text(
                          '下载限速：${FileSizeConvert.parseToFileSize(downloader.prefs.speedLimitDown * 1024)}/s',
                          style: TextStyle(
                            fontSize: 10,
                            color: shadColorScheme.foreground,
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
    bool isQb = downloader.category == 'Qb';

    ChartSeriesController? chartSeriesController;
    var pathDownloader = '${downloader.protocol}://${downloader.host}:${downloader.port}';
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    return CustomCard(
      child: Slidable(
        key: ValueKey('${downloader.id}_${downloader.name}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
              onPressed: (context) async {
                CommonResponse res = await controller.reseedDownloader(downloader.id!);
                if (res.code == 0) {
                  Get.snackbar('辅种通知', res.msg.toString(), colorText: shadColorScheme.foreground);
                } else {
                  Get.snackbar('辅种通知', res.msg.toString(), colorText: shadColorScheme.destructive);
                }
              },
              backgroundColor: const Color(0xFF0A9D96),
              foregroundColor: Colors.white,
              icon: Icons.copy_sharp,
              label: '辅种',
            ),
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
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
                  titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                  middleText: '确定要删除任务吗？',
                  actions: [
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () {
                        Get.back(result: false);
                      },
                      child: const Text('取消'),
                    ),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      onPressed: () async {
                        Get.back(result: true);
                        CommonResponse res = await controller.removeDownloader(downloader);
                        if (res.code == 0) {
                          Get.snackbar('删除通知', res.msg.toString(), colorText: shadColorScheme.foreground);
                        } else {
                          Get.snackbar('删除通知', res.msg.toString(), colorText: shadColorScheme.destructive);
                        }
                        await controller.getDownloaderListFromServer(withStatus: true);
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
              ListTile(
                onTap: () async {
                  // _showTorrents(downloader);
                  controller.cancelPeriodicTimer();
                  if (kIsWeb) {
                    Uri uri = Uri.parse(pathDownloader);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                  if (downloader.category == 'Qb') {
                    Get.toNamed(Routes.QB, arguments: downloader);
                  }
                  if (downloader.category == 'Tr') {
                    Get.toNamed(Routes.TR, arguments: downloader);
                    // Get.toNamed(Routes.TORRENT, arguments: downloader);
                  }
                },
                onLongPress: () async {
                  _showEditBottomSheet(downloader: downloader);
                },
                leading: ShadAvatar(
                  'assets/images/${downloader.category.toLowerCase()}.png',
                  size: Size(28, 28.0),
                ),
                title: Text(
                  downloader.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: shadColorScheme.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  pathDownloader,
                  style: TextStyle(
                    fontSize: 11,
                    color: shadColorScheme.foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: downloader.status.isNotEmpty
                    ? ShadBadge(
                        shape: RoundedRectangleBorder(
                          // 0.27+ 官方形状
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(downloader.prefs.version),
                      )
                    : ShadIconButton.ghost(
                        onPressed: () async {
                          CommonResponse res = await controller.testConnect(downloader);
                          if (!res.succeed) {
                            Get.snackbar(
                              '下载器连接失败',
                              '下载器 ${res.msg}',
                              colorText: shadColorScheme.destructive,
                            );
                          } else {
                            await controller.getDownloaderListFromServer(withStatus: true);
                          }
                        },
                        icon: Icon(
                          Icons.offline_bolt_outlined,
                          color: shadColorScheme.destructive,
                          size: 12,
                        ),
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
                    ShadIconButton.ghost(
                        onPressed: () {
                          _showTorrents(downloader);
                        },
                        icon: Icon(
                          Icons.list_alt_outlined,
                          size: 18,
                          color: shadColorScheme.foreground,
                        )),
                    ShadIconButton.ghost(
                        onPressed: () => isQb ? _showQbPrefs(downloader, context) : _showTrPrefs(downloader, context),
                        icon: Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: shadColorScheme.foreground,
                        )),
                    (downloader.status.isNotEmpty &&
                            (isQb
                                ? downloader.status.last?.useAltSpeedLimits == true
                                : downloader.prefs.altSpeedEnabled == true))
                        ? ShadIconButton.ghost(
                            onPressed: () => controller.toggleSpeedLimit(downloader, false),
                            icon: Icon(
                              Icons.nordic_walking_sharp,
                              size: 18,
                              color: shadColorScheme.destructive,
                            ))
                        : ShadIconButton.ghost(
                            onPressed: () => controller.toggleSpeedLimit(downloader, true),
                            icon: Icon(
                              Icons.electric_bolt_outlined,
                              size: 18,
                              color: shadColorScheme.foreground,
                            )),
                    // ShadIconButton.ghost(
                    //     onPressed: () {},
                    //     icon: Icon(
                    //       Icons.speed_outlined,
                    //       size: 18,
                    //       color: ShadTheme.of(context).colorScheme.foreground,
                    //     )),
                    ShadIconButton.ghost(
                        onPressed: () => _openAddTorrentDialog(controller, downloader),
                        icon: Icon(
                          Icons.add_outlined,
                          size: 18,
                          color: shadColorScheme.foreground,
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
      return Center(child: const CircularProgressIndicator());
    }
    var shadColorScheme = ShadTheme.of(context).colorScheme;
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
                      '${FileSizeConvert.parseToFileSize(res.upInfoSpeed!)}/S',
                      style: TextStyle(
                        fontSize: 10,
                        color: shadColorScheme.foreground,
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
                      style: TextStyle(
                        fontSize: 10,
                        color: shadColorScheme.foreground,
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
                      FileSizeConvert.parseToFileSize(res.upInfoData),
                      style: TextStyle(
                        fontSize: 10,
                        color: shadColorScheme.foreground,
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
                      style: TextStyle(
                        fontSize: 10,
                        color: shadColorScheme.foreground,
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
                  '${FileSizeConvert.parseToFileSize(res.uploadSpeed)}/S',
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground,
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
                  '${FileSizeConvert.parseToFileSize(res.downloadSpeed, 0)}/S',
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground,
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
                  FileSizeConvert.parseToFileSize(res.currentStats.uploadedBytes),
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground,
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
                  FileSizeConvert.parseToFileSize(res.currentStats.downloadedBytes),
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground,
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
                  style: TextStyle(
                    fontSize: 10,
                    color: shadColorScheme.foreground,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showEditBottomSheet({Downloader? downloader}) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final response = await controller.getTorrentsPathList();
    if (response.succeed) {
      controller.pathList = [
        for (final item in response.data)
          if (item['path'] is String) item['path'].toString()
      ];
      controller.update();
    } else {
      Get.snackbar(
        '获取种子文件夹出错啦！',
        response.msg,
        snackPosition: SnackPosition.TOP,
        colorText: shadColorScheme.destructive,
        duration: const Duration(seconds: 3),
      );
    }

    final nameController = TextEditingController(text: downloader?.name ?? 'QBittorrent');
    final categoryController = TextEditingController(text: downloader?.category ?? 'Qb');
    final usernameController = TextEditingController(text: downloader?.username ?? 'admin');
    final passwordController = TextEditingController(text: downloader?.password ?? 'admin');
    final protocolController = TextEditingController(text: downloader?.protocol ?? 'http');
    final sortIdController = TextEditingController(text: downloader?.sortId.toString() ?? '0');

    final hostController = TextEditingController(text: downloader?.host ?? '192.168.');
    final portController = TextEditingController(text: downloader?.port.toString() ?? '8999');

    final torrentPathController = TextEditingController(text: downloader?.torrentPath ?? '/downloaders');

    RxBool isActive = downloader != null ? downloader.isActive.obs : true.obs;
    RxBool brush = downloader != null ? downloader.brush.obs : false.obs;

    Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      GetBuilder<DownloadController>(builder: (controller) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  downloader != null ? '编辑下载器：${downloader?.name}' : '添加下载器',
                  style: ShadTheme.of(context).textTheme.h4,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          child: ShadSelect<String>(
                              decoration: ShadDecoration(
                                border: ShadBorder(
                                  merge: false,
                                  bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                              trailing: const Text('下载器分类'),
                              placeholder: const Text('下载器分类'),
                              initialValue: "Qb",
                              options: ["Qb", "Tr"].map((key) => ShadOption(value: key, child: Text(key))).toList(),
                              selectedOptionBuilder: (context, value) {
                                return Text(value);
                              },
                              onChanged: (String? value) {
                                categoryController.text = value!;
                                nameController.text = value == 'Qb' ? 'QBittorrent' : 'Transmission';
                              }),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          child: ShadSelect<String>(
                              decoration: ShadDecoration(
                                border: ShadBorder(
                                  merge: false,
                                  bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                              trailing: const Text('选择协议'),
                              placeholder: const Text('选择协议'),
                              initialValue: "http",
                              options:
                                  ["http", "https"].map((key) => ShadOption(value: key, child: Text(key))).toList(),
                              selectedOptionBuilder: (context, value) {
                                return Text(value);
                              },
                              onChanged: (String? value) {
                                protocolController.text = value!;
                              }),
                        ),
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
                      CustomTextField(
                        controller: sortIdController,
                        labelText: '排序',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: double.infinity),
                          child: ShadSelect<String>(
                              placeholder: Text('种子路径', style: TextStyle(color: shadColorScheme.foreground)),
                              trailing: Text('种子路径', style: TextStyle(color: shadColorScheme.foreground)),
                              initialValue: torrentPathController.text,
                              decoration: ShadDecoration(
                                border: ShadBorder(
                                  merge: false,
                                  bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                              options:
                                  controller.pathList.map((key) => ShadOption(value: key, child: Text(key))).toList(),
                              selectedOptionBuilder: (context, value) {
                                return Text(value);
                              },
                              onChanged: (String? value) {
                                torrentPathController.text = value!;
                              }),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Obx(() {
                        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                            title: '辅种开关',
                            value: !brush.value,
                            onChanged: (value) {
                              brush.value = !value;
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
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '取消',
                    ),
                  ),
                  ShadButton(
                    size: ShadButtonSize.sm,
                    child: const Text(
                      '保存',
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
                        downloader?.port = int.tryParse(portController.text) ?? 8999;
                        downloader?.sortId = int.tryParse(sortIdController.text) ?? 0;
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
                          sortId: int.tryParse(sortIdController.text) ?? 0,
                          host: hostController.text,
                          port: int.tryParse(portController.text) ?? 8999,
                          torrentPath: torrentPathController.text,
                          isActive: isActive.value,
                          brush: brush.value,
                          status: [],
                        );
                      }
                      logger_helper.Logger.instance.i(downloader?.toJson());
                      CommonResponse response = await controller.saveDownloaderToServer(downloader!);
                      if (response.code == 0) {
                        Navigator.of(context).pop();
                        Get.snackbar(
                          '保存成功！',
                          response.msg,
                          snackPosition: SnackPosition.TOP,
                          colorText: shadColorScheme.foreground,
                          duration: const Duration(seconds: 3),
                        );
                        await controller.getDownloaderListFromServer();
                        controller.update();
                        await controller.getDownloaderListFromServer(withStatus: true);
                        controller.update();
                      } else {
                        Get.snackbar(
                          '保存出错啦！',
                          response.msg,
                          snackPosition: SnackPosition.TOP,
                          colorText: shadColorScheme.destructive,
                          duration: const Duration(seconds: 3),
                        );
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        );
      }),
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

  Widget _buildFunctionBar(Downloader downloader) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    bool isQb = downloader.category == 'Qb';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                controller.sortReversed = !controller.sortReversed;
                isQb ? controller.sortQbTorrents() : controller.sortTrTorrents();
                logger_helper.Logger.instance.d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    controller.sortReversed
                        ? Icon(
                            Icons.sim_card_download_sharp,
                            size: 13,
                            color: shadColorScheme.foreground,
                          )
                        : Icon(
                            Icons.upload_file_sharp,
                            size: 13,
                            color: shadColorScheme.foreground,
                          ),
                    SizedBox(width: 3),
                    controller.sortReversed
                        ? Text(
                            '正序',
                            style: TextStyle(
                              fontSize: 12,
                              color: shadColorScheme.foreground,
                            ),
                          )
                        : Text(
                            '倒序',
                            style: TextStyle(
                              fontSize: 12,
                              color: shadColorScheme.foreground,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            GetBuilder<DownloadController>(builder: (controller) {
              return CustomPopup(
                showArrow: false,
                backgroundColor: shadColorScheme.background,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: isQb
                          ? controller.qbSortOptions
                              .map((item) => PopupMenuItem<String>(
                                    height: 32,
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        color: shadColorScheme.foreground,
                                      ),
                                    ),
                                    onTap: () async {
                                      logger_helper.Logger.instance
                                          .d('当前排序规则：${controller.sortKey},正序：${controller.sortReversed}！');
                                      controller.sortKey = item.value;
                                      SPUtil.setLocalStorage('${downloader.host}:${downloader.port}-sortKey',
                                          controller.sortKey.toString());
                                      controller.sortQbTorrents();
                                    },
                                  ))
                              .toList()
                          : controller.trSortOptions
                              .map((item) => PopupMenuItem(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        color: shadColorScheme.foreground,
                                      ),
                                    ),
                                    onTap: () {
                                      controller.sortKey = item.value;
                                      SPUtil.setLocalStorage('${downloader.host}:${downloader.port}-sortKey',
                                          controller.sortKey.toString());
                                      controller.sortTrTorrents();
                                    },
                                  ))
                              .toList(),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: CustomTextTag(
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.sort_by_alpha_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText:
                        '【${controller.qbSortOptions.firstWhereOrNull((item) => item.value == controller.sortKey)?.name ?? "无"}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                ),
              );
            }),
            GetBuilder<DownloadController>(builder: (controller) {
              return CustomPopup(
                showArrow: false,
                backgroundColor: shadColorScheme.background,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuItem<String>(
                          height: 32,
                          child: Text(
                            '全部[${controller.torrents.length}]',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                            ),
                          ),
                          onTap: () async {
                            Get.back();
                            controller.selectedTag = '全部';
                            isQb ? controller.filterQbTorrents() : controller.filterTrTorrents();
                          },
                        ),
                        ...controller.tags.map((item) => PopupMenuItem<String>(
                              height: 32,
                              child: Text(
                                '$item[${controller.torrents.where((element) => isQb ? element.tags.contains(item) : element.labels.contains(item)).length}]',
                                style: TextStyle(
                                  color: shadColorScheme.foreground,
                                ),
                              ),
                              onTap: () async {
                                controller.selectedTag = item;
                                isQb ? controller.filterQbTorrents() : controller.filterTrTorrents();
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: CustomTextTag(
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.tag,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText: '【${controller.selectedTag}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                ),
              );
            }),
            GetBuilder<DownloadController>(builder: (controller) {
              return CustomPopup(
                showArrow: false,
                backgroundColor: shadColorScheme.background,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuItem<String>(
                          height: 32,
                          child: Text(
                            '全部[${controller.torrents.length}]',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                            ),
                          ),
                          onTap: () async {
                            controller.selectedTracker = '全部';
                            controller.filterTorrents(isQb);
                          },
                        ),
                        PopupMenuItem<String>(
                          height: 32,
                          child: Text(
                            '红种[${controller.torrents.where((element) => isQb ? element.tracker?.isEmpty == true : element.errorString.isNotEmpty).toList().length}]',
                            style: TextStyle(
                              color: shadColorScheme.foreground,
                            ),
                          ),
                          onTap: () async {
                            controller.selectedTracker = '红种';
                            controller.filterTorrents(isQb);
                          },
                        ),
                        ...controller.showTrackers.map((item) => PopupMenuItem<String>(
                              height: 32,
                              child: Text(
                                '$item[${controller.trackers[item]?.length ?? 0}]',
                                style: TextStyle(
                                  color: shadColorScheme.foreground,
                                ),
                              ),
                              onTap: () async {
                                controller.selectedTracker = item;
                                controller.filterTorrents(isQb);
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: CustomTextTag(
                    backgroundColor: Colors.transparent,
                    icon: Icon(
                      Icons.language_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    labelText: '【${controller.selectedTracker}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                ),
              );
            }),
            GetBuilder<DownloadController>(builder: (controller) {
              return CustomPopup(
                showArrow: false,
                backgroundColor: shadColorScheme.background,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...controller.categoryMap.values.map((item) => ListTile(
                              dense: true,
                              title: Text(
                                "${item?.name ?? '未分类'}[${item?.name == '全部' ? controller.torrents.length : controller.torrents.where((torrent) => isQb ? torrent.category == (item?.name != '未分类' ? item?.name : '') : torrent.downloadDir == item?.savePath).toList().length}]",
                              ),
                              style: ListTileStyle.list,
                              titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                              selected: controller.selectedCategory == (item?.savePath != null ? item?.name! : null),
                              selectedColor: shadColorScheme.destructive,
                              selectedTileColor: Colors.amber,
                              onTap: () {
                                controller.selectedCategory = item?.savePath != null ? item?.name! : null;
                                controller.filterTrTorrents();
                              },
                            )),
                      ],
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: CustomTextTag(
                    mainAxisAlignment: MainAxisAlignment.center,
                    icon: Icon(
                      Icons.category_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    backgroundColor: Colors.transparent,
                    labelColor: shadColorScheme.foreground,
                    labelText:
                        '【${controller.categoryMap.keys.firstWhereOrNull((item) => item == controller.selectedCategory) ?? "全部"}】',
                  ),
                ),
              );
            }),
            GetBuilder<DownloadController>(builder: (controller) {
              return CustomPopup(
                showArrow: false,
                backgroundColor: shadColorScheme.background,
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: isQb
                          ? controller.qBitStatus.map((state) {
                              var torrentsMatchingState = [];
                              if (state.value == 'all') {
                                torrentsMatchingState = controller.torrents;
                              } else if (state.value == 'active') {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) =>
                                        [
                                          "downloading",
                                          "uploading",
                                          "checkingUP",
                                          "forcedUP",
                                          "moving",
                                          "checkingDL",
                                        ].contains(torrent.state) ||
                                        (torrent.upSpeed + torrent.dlSpeed) > 0)
                                    .toList();
                              } else {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) => state.value != null ? torrent.state == state.value : true)
                                    .toList();
                              }
                              return PopupMenuItem(
                                child: Text(
                                  '${state.name}(${torrentsMatchingState.length})',
                                  style: TextStyle(color: shadColorScheme.foreground),
                                ),
                                onTap: () {
                                  // Get.back();
                                  logger_helper.Logger.instance.d("状态筛选...${state.name}");
                                  controller.torrentState = state.value;
                                  controller.filterQbTorrents();
                                },
                              );
                            }).toList()
                          : controller.trStatus.map((state) {
                              var torrentsMatchingState = [];
                              if (state.value == 100) {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) =>
                                        [
                                          2,
                                          4,
                                        ].contains(torrent.status) ||
                                        torrent.rateUpload > 0)
                                    .toList();
                              } else {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) => state.value != null ? torrent.status == state.value : true)
                                    .toList();
                              }
                              return PopupMenuItem(
                                child: Text(
                                  '${state.name}(${torrentsMatchingState.length})',
                                  style: TextStyle(color: shadColorScheme.foreground),
                                ),
                                onTap: () {
                                  // Get.back();
                                  logger_helper.Logger.instance.d("状态筛选...${state.name}");
                                  controller.trTorrentState = state.value;
                                  controller.filterTrTorrents();
                                },
                              );
                            }).toList(),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                  child: CustomTextTag(
                    mainAxisAlignment: MainAxisAlignment.center,
                    icon: Icon(
                      Icons.info_outlined,
                      size: 13,
                      color: shadColorScheme.foreground,
                    ),
                    backgroundColor: Colors.transparent,
                    labelText:
                        '【${controller.qBitStatus.firstWhereOrNull((item) => item.value == controller.torrentState)?.name ?? "全部"}】',
                    labelColor: shadColorScheme.foreground,
                  ),
                ),
              );
            }),
            if (!isQb)
              GetBuilder<DownloadController>(builder: (controller) {
                return CustomPopup(
                  showArrow: false,
                  contentDecoration: BoxDecoration(
                    color: shadColorScheme.background,
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...controller.errors.map((error) {
                            int count = 0;
                            if (error == '全部') {
                              count = controller.torrents.where((item) => item.error > 0).length;
                            } else {
                              count = controller.torrents
                                  .where((torrent) => torrent.errorString.contains(error))
                                  .toList()
                                  .length;
                            }
                            bool selected = controller.selectedError == error;
                            return ListTile(
                              dense: true,
                              title: Text(
                                '$error($count)',
                              ),
                              titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                              selected: selected,
                              selectedColor: shadColorScheme.destructive,
                              onTap: () {
                                Get.back();
                                controller.selectedError = error;
                                controller.filterTrTorrents();
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                    child: CustomTextTag(
                      mainAxisAlignment: MainAxisAlignment.center,
                      icon: Icon(
                        Icons.warning_amber_outlined,
                        size: 13,
                        color: shadColorScheme.foreground,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: shadColorScheme.foreground,
                      labelText:
                          '【${controller.qBitStatus.firstWhereOrNull((item) => item.value == controller.torrentState) ?? "全部"}】',
                    ),
                  ),
                );
              }),
          ]),
    );
  }

  void _showTorrents(Downloader downloader) async {
    controller.initData();
    controller.isTorrentsLoading = true;
    controller.update();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    try {
      var res = await controller.testConnect(downloader);
      if (!res.succeed) {
        Get.snackbar(
          '提示',
          '下载器连接失败啦，请检查配置信息！',
          snackPosition: SnackPosition.TOP,
          colorText: shadColorScheme.destructive,
        );
        return;
      }
      controller.getDownloaderTorrents(downloader);
      bool isQb = downloader.category == 'Qb';
      if (controller.serverStatus.isEmpty) {
        controller.getDownloaderListFromServer(withStatus: true);
      }

      Future.delayed(Duration(milliseconds: 50), () {
        logger_helper.Logger.instance.i('开始加载种子数据 1');
        // controller.localPaginationController.bindSource(controller.showTorrents.obs, reset: true);
        // controller.isTorrentsLoading = false;
        // controller.update();
        Get.bottomSheet(
          backgroundColor: shadColorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // 圆角半径
          ),
          isScrollControlled: true,
          GetBuilder<DownloadController>(
              id: "${downloader.host} - ${downloader.port} - torrentList",
              builder: (controller) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.92,
                  width: MediaQuery.of(context).size.width,
                  child: GetBuilder<DownloadController>(builder: (controller) {
                    return SafeArea(
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        resizeToAvoidBottomInset: false,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          toolbarHeight: 40,
                          title: Text(
                            '${downloader.name} (${controller.torrents.isNotEmpty ? controller.torrents.length : 'loading'})',
                          ),
                          titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                          toolbarTextStyle: TextStyle(color: shadColorScheme.foreground),
                          actions: [
                            if (controller.serverStatus.isNotEmpty) ...[
                              SizedBox(
                                width: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...(isQb
                                        ? [
                                            CustomTextTag(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_up_outlined,
                                                  color: shadColorScheme.primary,
                                                  size: 14,
                                                ),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                backgroundColor: Colors.transparent,
                                                labelColor: shadColorScheme.primary,
                                                labelText:
                                                    "${FileSizeConvert.parseToFileSize(controller.serverStatus.last.upInfoSpeed)}/s[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.upRateLimit)}]"),
                                            CustomTextTag(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down_outlined,
                                                  color: shadColorScheme.destructive,
                                                  size: 14,
                                                ),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                backgroundColor: Colors.transparent,
                                                labelColor: shadColorScheme.destructive,
                                                labelText:
                                                    "${FileSizeConvert.parseToFileSize(controller.serverStatus.last.dlInfoSpeed)}/s[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.dlRateLimit)}]"),
                                          ]
                                        : [
                                            CustomTextTag(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_up_outlined,
                                                  color: shadColorScheme.primary,
                                                  size: 14,
                                                ),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                backgroundColor: Colors.transparent,
                                                labelColor: shadColorScheme.primary,
                                                labelText:
                                                    "${FileSizeConvert.parseToFileSize(controller.serverStatus.last.uploadSpeed)}/s[${FileSizeConvert.parseToFileSize(downloader.prefs.speedLimitUp * 1024)}]"),
                                            CustomTextTag(
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down_outlined,
                                                  color: shadColorScheme.destructive,
                                                  size: 14,
                                                ),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                backgroundColor: Colors.transparent,
                                                labelColor: shadColorScheme.destructive,
                                                labelText:
                                                    "${FileSizeConvert.parseToFileSize(controller.serverStatus.last.downloadSpeed)}/s[${FileSizeConvert.parseToFileSize(downloader.prefs.speedLimitDown * 1024)}]"),
                                          ]),
                                  ],
                                ),
                              ),
                            ],
                            CustomPopup(
                                showArrow: false,
                                backgroundColor: shadColorScheme.background,
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
                                              color: shadColorScheme.foreground,
                                            ),
                                          ),
                                        ),
                                        onTap: () =>
                                            isQb ? removeQbErrorTracker(downloader) : removeTrErrorTracker(downloader),
                                      ),
                                      PopupMenuItem<String>(
                                        child: Center(
                                          child: Text(
                                            '重置排序',
                                            style: TextStyle(
                                              color: shadColorScheme.foreground,
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          controller.resetSortKey(downloader);
                                          isQb ? controller.sortQbTorrents() : controller.sortTrTorrents();
                                        },
                                      ),
                                      PopupMenuItem<String>(
                                        child: Center(
                                          child: Text(
                                            '清除筛选',
                                            style: TextStyle(
                                              color: shadColorScheme.foreground,
                                            ),
                                          ),
                                        ),
                                        onTap: () async {
                                          controller.clearFilterOption();
                                          controller.filterTorrents(isQb);
                                        },
                                      ),
                                      PopupMenuItem<String>(
                                        child: Center(
                                            child: Text(
                                          '替换Tracker',
                                          style: TextStyle(color: shadColorScheme.foreground),
                                        )),
                                        onTap: () => replaceTrackers(downloader: downloader),
                                      ),
                                      PopupMenuItem<String>(
                                        child: Center(
                                          child: Text(
                                            '关闭页面',
                                          ),
                                        ),
                                        onTap: () async {
                                          await controller.stopFetchTorrents();
                                          Get.back();
                                        },
                                      ),
                                      PopupMenuItem<String>(
                                        child: Center(
                                          child: Text(
                                            '添加种子',
                                          ),
                                        ),
                                        onTap: () => _openAddTorrentDialog(controller, downloader),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                                  child: Icon(
                                    Icons.add,
                                    size: 24,
                                  ),
                                )),
                          ],
                        ),
                        body: Column(
                          children: [
                            GetBuilder<DownloadController>(builder: (controller) {
                              return _buildFunctionBar(downloader);
                            }),
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
                                            color: shadColorScheme.foreground,
                                          ),
                                        ))
                                      : ListView.builder(
                                          controller: controller.scrollController,
                                          itemCount: controller.showTorrents.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            dynamic torrent = controller.showTorrents[index];
                                            if (!isQb && torrent is QbittorrentTorrentInfo) {
                                              return SizedBox.shrink();
                                            }
                                            return ShowTorrentWidget(
                                                downloader: downloader, torrentInfo: torrent, controller: controller);
                                          }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: GetBuilder<DownloadController>(builder: (controller) {
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
                                                  child: Text('计数：${controller.showTorrents.length}',
                                                      style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onChanged: (value) {
                                            controller.filterTorrents(isQb);
                                            logger_helper.Logger.instance
                                                .i('开始加载种子数据 3：${controller.showTorrents.length}');
                                            // controller.localPaginationController
                                            //     .bindSource(controller.showTorrents.obs, reset: true);
                                          },
                                        ),
                                      ),
                                    ),
                                    if (controller.searchKey.isNotEmpty)
                                      ShadIconButton.ghost(
                                          onPressed: () {
                                            if (controller.searchController.text.isNotEmpty) {
                                              controller.searchController.text = controller.searchController.text
                                                  .substring(0, controller.searchController.text.length - 1);
                                              controller.searchKey = controller.searchController.text;
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
                            if (controller.serverStatus.isNotEmpty)
                              isQb
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        CustomTextTag(
                                            icon: Icon(
                                              Icons.sd_storage,
                                              color: shadColorScheme.primary,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: shadColorScheme.primary,
                                            labelText: FileSizeConvert.parseToFileSize(
                                                controller.serverStatus.last.freeSpaceOnDisk)),
                                        CustomTextTag(
                                            icon: Icon(
                                              Icons.upload_outlined,
                                              color: shadColorScheme.primary,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: shadColorScheme.primary,
                                            labelText:
                                                '${FileSizeConvert.parseToFileSize(controller.serverStatus.last.alltimeUl)}[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.upInfoData)}]'),
                                        CustomTextTag(
                                            icon: Icon(
                                              Icons.download_outlined,
                                              color: shadColorScheme.destructive,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: shadColorScheme.destructive,
                                            labelText:
                                                '${FileSizeConvert.parseToFileSize(controller.serverStatus.last.alltimeDl)}[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.dlInfoData)}]'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        CustomTextTag(
                                            icon: const Icon(
                                              Icons.upload_outlined,
                                              color: Colors.green,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: Colors.red,
                                            labelText:
                                                FileSizeConvert.parseToFileSize(downloader.prefs.downloadDirFreeSpace)),
                                        CustomTextTag(
                                            icon: const Icon(
                                              Icons.upload_outlined,
                                              color: Colors.green,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: Colors.green,
                                            labelText:
                                                '${FileSizeConvert.parseToFileSize(controller.serverStatus.last.uploadSpeed)}[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.currentStats.uploadedBytes)}]'),
                                        CustomTextTag(
                                            icon: const Icon(
                                              Icons.download_outlined,
                                              color: Colors.red,
                                              size: 14,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            labelColor: Colors.red,
                                            labelText:
                                                '${FileSizeConvert.parseToFileSize(controller.serverStatus.last.downloadSpeed)}[${FileSizeConvert.parseToFileSize(controller.serverStatus.last.currentStats.downloadedBytes)}]'),
                                      ],
                                    )
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }),
        ).whenComplete(() => controller.stopFetchTorrents());
      });
    } catch (e, trace) {
      var message = '查看种子列表失败！$e';
      logger_helper.Logger.instance.e(message);
      logger_helper.Logger.instance.e(trace);
      Get.snackbar(
        '出错啦！',
        message,
        colorText: shadColorScheme.foreground,
      );
      await controller.stopFetchTorrents();
    }
  }

  void _openAddTorrentDialog(DownloadController controller, Downloader downloader) async {
    try {
      if (controller.addTorrentLoading == true) {
        return;
      }
      controller.addTorrentLoading = true;
      await controller.getDownloaderCategoryList(downloader);
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      Get.bottomSheet(
        backgroundColor: shadColorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        enableDrag: true,
        SizedBox(
          height: 400,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '添加种子',
                style: ShadTheme.of(context).textTheme.h4,
              ),
            ),
            Expanded(
              child: DownloadForm(
                categories: controller.categoryMap.values.fold({}, (map, element) {
                  map[element!.name!] = element;
                  return map;
                }),
                downloader: downloader,
                info: null,
              ),
            ),
          ]),
        ),
      ).whenComplete(() {
        controller.addTorrentLoading = false;
      });
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.e(trace);
      Get.snackbar('出错啦！', e.toString());
    } finally {
      controller.addTorrentLoading = false;
    }
  }

  void replaceTrackers({
    required Downloader downloader,
  }) {
    TextEditingController keyController = TextEditingController(text: '');
    TextEditingController valueController = TextEditingController(text: '');
    List<String> sites = controller.trackers.keys.where((e) => e != '全部' && e != ' 红种').toList();
    sites.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    Get.bottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0), // 圆角半径
      ),
      SizedBox(
        height: 240,
        // width: 240,
        child: Scaffold(
          backgroundColor: shadColorScheme.background,
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
                          bottom: ShadBorderSide(color: shadColorScheme.foreground.withOpacity(0.2), width: 1),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                      options: sites.map((key) => ShadOption(value: key, child: Text(key))).toList(),
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
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      Get.back(result: false);
                    },
                    child: const Text('取消'),
                  ),
                  Stack(
                    children: [
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          List<String> torrentHashes = controller.trackers[keyController.text] ?? [];
                          logger_helper.Logger.instance.d(torrentHashes);
                          if (torrentHashes.isEmpty) {
                            Get.snackbar('Tracker替换ing', '本下载器没有 ${keyController.text} 站点的种子！',
                                colorText: shadColorScheme.destructive);
                            return;
                          }
                          Get.defaultDialog(
                            title: '确认',
                            radius: 5,
                            titleStyle:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                            middleText: '站点 ${keyController.text} 共检测到${torrentHashes.length}条种子，确定要替换 Tracker 地址吗？',
                            actions: [
                              ShadButton.destructive(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back(result: false);
                                },
                                child: const Text('取消'),
                              ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () async {
                                  Get.back(result: true);
                                  CommonResponse res = await controller.replaceTrackers(
                                    downloader: downloader,
                                    torrentHashes: torrentHashes,
                                    newTracker: valueController.text,
                                  );
                                  if (res.succeed) {
                                    Get.back();
                                  }
                                  Get.snackbar('Tracker通知', res.msg,
                                      colorText: res.succeed ? shadColorScheme.primary : shadColorScheme.destructive);
                                  controller.update();
                                },
                                child: const Text('确认'),
                              ),
                            ],
                          );
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
  }

  Widget _buildTrDrawer(downloader, context) {
    List<TransmissionStats> serverStatus = controller.serverStatus.whereType<TransmissionStats>().toList();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    TransmissionStats state = serverStatus.last;
    // TextEditingController searchKeyController = TextEditingController();
    return Drawer(
        child: Column(
      children: <Widget>[
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
                Text('${downloader.protocol}://${downloader.host}:${downloader.port}'),
              ],
            ),
          ),
        ),
        // SizedBox(
        //   height: 80,
        //   child: SfCartesianChart(
        //     plotAreaBorderWidth: 0,
        //     tooltipBehavior: TooltipBehavior(
        //       enable: true,
        //       shared: true,
        //       decimalPlaces: 1,
        //       builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        //         // Logger.instance.d(data);
        //         return Container(
        //           padding: const EdgeInsets.all(8),
        //           decoration: BoxDecoration(
        //             color: shadColorScheme.background,
        //             border: Border.all(width: 1),
        //           ),
        //           child: Text(
        //             '${series.name}: ${FileSizeConvert.parseToFileSize(point.y)}',
        //             style: const TextStyle(fontSize: 12),
        //           ),
        //         );
        //       },
        //     ),
        //     primaryXAxis: const CategoryAxis(
        //         isVisible: false,
        //         majorGridLines: MajorGridLines(width: 0),
        //         edgeLabelPlacement: EdgeLabelPlacement.shift),
        //     primaryYAxis: NumericAxis(
        //         axisLine: const AxisLine(width: 0),
        //         axisLabelFormatter: (AxisLabelRenderDetails details) {
        //           return ChartAxisLabel(
        //             FileSizeConvert.parseToFileSize(details.value),
        //             const TextStyle(
        //               fontSize: 10,
        //             ),
        //           );
        //         },
        //         majorTickLines: const MajorTickLines(size: 0)),
        //     series: [
        //       AreaSeries<TransmissionStats, int>(
        //         animationDuration: 0,
        //         dataSource: serverStatus,
        //         enableTooltip: true,
        //         xValueMapper: (TransmissionStats sales, index) => index,
        //         yValueMapper: (TransmissionStats sales, _) => sales.downloadSpeed,
        //         color: Colors.red.withOpacity(0.5),
        //         name: '下载速度',
        //         borderWidth: 1,
        //       ),
        //       AreaSeries<TransmissionStats, int>(
        //         animationDuration: 0,
        //         dataSource: serverStatus,
        //         enableTooltip: true,
        //         xValueMapper: (TransmissionStats sales, index) => index,
        //         yValueMapper: (TransmissionStats sales, _) => sales.uploadSpeed,
        //         color: Colors.blue.withOpacity(0.9),
        //         name: '上传速度',
        //         borderWidth: 1,
        //         borderDrawMode: BorderDrawMode.all,
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
            child: SingleChildScrollView(
          child: ShadAccordion<String>(
            initialValue: "种子状态",
            children: [
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                value: "种子排序",
                title: Text(
                  '种子排序【${controller.trSortOptions.firstWhereOrNull((item) => item.value == controller.sortKey)?.name ?? "无"}】',
                ),
                child: GetBuilder<DownloadController>(builder: (controller) {
                  return Column(children: [
                    ...controller.trSortOptions.map((item) => ListTile(
                          dense: true,
                          title: Text(
                            item.name,
                          ),
                          style: ListTileStyle.list,
                          titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                          selected: controller.sortKey == item.value,
                          selectedColor: shadColorScheme.destructive,
                          selectedTileColor: Colors.amber,
                          onTap: () {
                            Get.back();
                            controller.sortReversed =
                                controller.sortKey == item.value ? !controller.sortReversed : false;
                            controller.sortKey = item.value;
                            SPUtil.setLocalStorage(
                                '${downloader.host}:${downloader.port}-sortKey', controller.sortKey.toString());
                            controller.sortTrTorrents();
                          },
                        ))
                  ]);
                }),
              ),
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                title: Text(
                  '种子分类【${controller.categoryMap.keys.firstWhereOrNull((item) => item == controller.selectedCategory) ?? "无"}】',
                ),
                value: "种子分类",
                child: SizedBox(
                  height: 200,
                  child: GetBuilder<DownloadController>(builder: (controller) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.categoryMap.length,
                        itemBuilder: (context, index) {
                          String c = controller.categoryMap.keys.toList()[index];
                          qb.Category? category = controller.categoryMap.values.toList()[index];
                          int count = 0;
                          if (category?.savePath == null) {
                            count = controller.torrents.length;
                          } else {
                            count = controller.torrents
                                .where((torrent) => torrent.downloadDir == category?.savePath)
                                .toList()
                                .length;
                          }
                          bool selected =
                              controller.selectedCategory == (category?.savePath != null ? category?.name! : null);

                          return ListTile(
                            dense: true,
                            title: Text(
                              '$c($count)',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            selected: selected,
                            selectedColor: shadColorScheme.destructive,
                            onTap: () {
                              Get.back();
                              controller.selectedCategory = category?.savePath != null ? category?.name! : null;
                              controller.filterTrTorrents();
                            },
                          );
                        });
                  }),
                ),
              ),
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                value: "种子标签",
                title: Text(
                  '种子标签【${controller.tags.firstWhereOrNull((item) => item == controller.selectedTag) ?? "无"}】',
                ),
                child: SizedBox(
                  height: 200,
                  child: GetBuilder<DownloadController>(builder: (controller) {
                    return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.tags.length,
                        itemBuilder: (context, index) {
                          String tag = controller.tags[index];
                          int count = 0;
                          if (tag == '全部') {
                            count = controller.torrents.length;
                          } else {
                            count =
                                controller.torrents.where((torrent) => torrent.labels.contains(tag)).toList().length;
                          }
                          bool selected = controller.selectedTag == tag;
                          return ListTile(
                            dense: true,
                            title: Text(
                              '$tag($count)',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            selected: selected,
                            selectedColor: shadColorScheme.destructive,
                            onTap: () {
                              Get.back();
                              controller.selectedTag = tag;
                              controller.filterTrTorrents();
                            },
                          );
                        });
                  }),
                ),
              ),
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                value: "种子状态",
                title: Text(
                  '种子状态【${controller.trStatus.firstWhereOrNull((item) => item.value == controller.trTorrentState) ?? "无"}】',
                ),
                child: SizedBox(
                  height: 200,
                  child: GetBuilder<DownloadController>(builder: (controller) {
                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...controller.trStatus.map((state) {
                          var torrentsMatchingState = [];
                          if (state.value == 100) {
                            torrentsMatchingState = controller.torrents
                                .where((torrent) =>
                                    [
                                      2,
                                      4,
                                    ].contains(torrent.status) ||
                                    torrent.rateUpload > 0)
                                .toList();
                          } else {
                            torrentsMatchingState = controller.torrents
                                .where((torrent) => state.value != null ? torrent.status == state.value : true)
                                .toList();
                          }
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${state.name}(${torrentsMatchingState.length})',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            style: ListTileStyle.list,
                            selected: controller.trTorrentState == state.value,
                            selectedColor: shadColorScheme.destructive,
                            onTap: () {
                              Get.back();
                              controller.filterTrTorrents();
                            },
                          );
                        }),
                      ],
                    );
                  }),
                ),
              ),
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                value: "站点筛选",
                title: Text(
                  '站点筛选【${controller.selectedTracker}】',
                ),
                child: SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: controller.showTrackersKeyController,
                        labelText: '筛选',
                        onChanged: (String value) => controller.filterTorrents(false),
                      ),
                      Expanded(
                        child: GetBuilder<DownloadController>(builder: (controller) {
                          return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.showTrackers.length,
                              itemBuilder: (context, index) {
                                String? key = controller.showTrackers[index];
                                List<String>? hashList;
                                if (key == ' 红种') {
                                  hashList = controller.torrents
                                      .where((element) => element.tracker?.isEmpty == true)
                                      .map((e) => e.hash.toString())
                                      .toList();
                                } else {
                                  hashList = controller.trackers[key];
                                }
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${key.trim()}(${key == '全部' ? controller.torrents.length : hashList?.length})',
                                  ),
                                  titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                  style: ListTileStyle.list,
                                  selected: controller.selectedTracker == key,
                                  selectedColor: shadColorScheme.destructive,
                                  onTap: () {
                                    Get.back();
                                    // controller.torrentState = null;
                                    controller.torrentState = "站点筛选";
                                    controller.selectedTracker = key;
                                    controller.filterTrTorrents();
                                  },
                                );
                              });
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              ShadAccordionItem<String>(
                underlineTitleOnHover: true,
                padding: EdgeInsets.only(left: 16),
                value: "错误信息",
                title: Text(
                  '错误信息【${controller.selectedError}】',
                ),
                child: SizedBox(
                  height: 200,
                  child: GetBuilder<DownloadController>(builder: (controller) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.errors.length,
                        itemBuilder: (context, index) {
                          String error = controller.errors[index];
                          int count = 0;
                          if (error == '全部') {
                            count = controller.torrents.where((item) => item.error > 0).length;
                          } else {
                            count = controller.torrents
                                .where((torrent) => torrent.errorString.contains(error))
                                .toList()
                                .length;
                          }
                          bool selected = controller.selectedError == error;
                          return ListTile(
                            dense: true,
                            title: Text(
                              '$error($count)',
                            ),
                            titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                            selected: selected,
                            selectedColor: shadColorScheme.destructive,
                            onTap: () {
                              Get.back();
                              controller.selectedError = error;
                              controller.filterTrTorrents();
                            },
                          );
                        });
                  }),
                ),
              ),
            ],
          ),
        )),
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.all(0),
          titleTextStyle: TextStyle(color: shadColorScheme.foreground),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CustomTextTag(
                  icon: const Icon(
                    Icons.upload_outlined,
                    color: Colors.green,
                    size: 14,
                  ),
                  backgroundColor: Colors.transparent,
                  labelColor: Colors.red,
                  labelText: FileSizeConvert.parseToFileSize(downloader.prefs.downloadDirFreeSpace)),
              CustomTextTag(
                  icon: const Icon(
                    Icons.upload_outlined,
                    color: Colors.green,
                    size: 14,
                  ),
                  backgroundColor: Colors.transparent,
                  labelColor: Colors.green,
                  labelText:
                      '${FileSizeConvert.parseToFileSize(state.uploadSpeed)}[${FileSizeConvert.parseToFileSize(state.currentStats.uploadedBytes)}]'),
              CustomTextTag(
                  icon: const Icon(
                    Icons.download_outlined,
                    color: Colors.red,
                    size: 14,
                  ),
                  backgroundColor: Colors.transparent,
                  labelColor: Colors.red,
                  labelText:
                      '${FileSizeConvert.parseToFileSize(state.downloadSpeed)}[${FileSizeConvert.parseToFileSize(state.currentStats.downloadedBytes)}]'),
            ],
          ),
        )
      ],
    ));
  }

  Widget _buildQbDrawer(Downloader downloader, context) {
    return GetBuilder<DownloadController>(builder: (controller) {
      List<qb.ServerState> serverStatus = controller.serverStatus.whereType<qb.ServerState>().toList();
      controller.sortKey = SPUtil.getLocalStorage('${downloader.host}:${downloader.port}-sortKey') ?? 'name';
      qb.ServerState state = serverStatus.first;
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      // TextEditingController searchKeyController = TextEditingController();
      return Drawer(
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
                    Text('${downloader.protocol}://${downloader.host}:${downloader.port}'),
                  ],
                ),
              ),
            ),
            // SizedBox(
            //   height: 80,
            //   child: SfCartesianChart(
            //     plotAreaBorderWidth: 0,
            //     tooltipBehavior: TooltipBehavior(
            //       enable: true,
            //       shared: true,
            //       decimalPlaces: 1,
            //       builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
            //         // Logger.instance.d(data);
            //         return Container(
            //           padding: const EdgeInsets.all(8),
            //           decoration: BoxDecoration(
            //             color: shadColorScheme.background,
            //             border: Border.all(width: 1),
            //           ),
            //           child: Text(
            //             '${series.name}: ${FileSizeConvert.parseToFileSize(point.y)}',
            //             style: const TextStyle(fontSize: 12),
            //           ),
            //         );
            //       },
            //     ),
            //     primaryXAxis: const CategoryAxis(
            //         isVisible: false,
            //         majorGridLines: MajorGridLines(width: 0),
            //         edgeLabelPlacement: EdgeLabelPlacement.shift),
            //     primaryYAxis: NumericAxis(
            //         axisLine: const AxisLine(width: 0),
            //         axisLabelFormatter: (AxisLabelRenderDetails details) {
            //           return ChartAxisLabel(
            //             FileSizeConvert.parseToFileSize(details.value),
            //             const TextStyle(
            //               fontSize: 10,
            //             ),
            //           );
            //         },
            //         majorTickLines: const MajorTickLines(size: 0)),
            //     series: [
            //       AreaSeries<qb.ServerState, int>(
            //         animationDuration: 0,
            //         dataSource: serverStatus,
            //         enableTooltip: true,
            //         xValueMapper: (qb.ServerState sales, index) => index,
            //         yValueMapper: (qb.ServerState sales, _) => sales.dlInfoSpeed,
            //         color: Colors.red.withOpacity(0.5),
            //         name: '下载速度',
            //         borderWidth: 1,
            //       ),
            //       AreaSeries<qb.ServerState, int>(
            //         animationDuration: 0,
            //         dataSource: serverStatus,
            //         enableTooltip: true,
            //         xValueMapper: (qb.ServerState sales, index) => index,
            //         yValueMapper: (qb.ServerState sales, _) => sales.upInfoSpeed,
            //         color: Colors.blue.withOpacity(0.9),
            //         name: '上传速度',
            //         borderWidth: 1,
            //         borderDrawMode: BorderDrawMode.all,
            //       ),
            //     ],
            //   ),
            // ),
            Expanded(
              child: SingleChildScrollView(
                child: ShadAccordion<String>(
                  maintainState: true,
                  children: [
                    ShadAccordionItem<String>(
                      underlineTitleOnHover: false,
                      padding: EdgeInsets.only(left: 16),
                      value: '种子排序',
                      title: Text(
                        '种子排序【${controller.qbSortOptions.firstWhereOrNull((item) => item.value == controller.sortKey)?.name ?? "无"}】',
                      ),
                      child: GetBuilder<DownloadController>(builder: (controller) {
                        return Column(
                          children: [
                            ...controller.qbSortOptions.map((item) => CheckboxListTile(
                                  dense: true,
                                  title: Text(item.name),
                                  selected: controller.sortKey == item.value,
                                  onChanged: (bool? value) {
                                    Get.back();
                                    controller.sortReversed =
                                        controller.sortKey == item.value ? !controller.sortReversed : false;
                                    controller.sortKey = item.value;
                                    SPUtil.setLocalStorage(
                                        '${downloader.host}:${downloader.port}-sortKey', controller.sortKey.toString());
                                    controller.sortQbTorrents();
                                  },
                                  value: controller.sortKey == item.value,
                                ))
                          ],
                        );
                      }),
                    ),
                    ShadAccordionItem<String>(
                      underlineTitleOnHover: true,
                      padding: EdgeInsets.only(left: 16),
                      value: '种子分类',
                      title: Text(
                        '种子分类【${controller.categoryMap.keys.firstWhereOrNull((item) => item == controller.selectedCategory) ?? "无"}】',
                      ),
                      child: GetBuilder<DownloadController>(builder: (controller) {
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.categoryMap.length,
                            itemBuilder: (context, index) {
                              String c = controller.categoryMap.keys.toList()[index];
                              qb.Category? category = controller.categoryMap.values.toList()[index];
                              int count = 0;
                              if (category?.savePath == null) {
                                count = controller.torrents.length;
                              } else {
                                count = controller.torrents
                                    .where((torrent) =>
                                        torrent.category == (category?.name != '未分类' ? category?.name : ''))
                                    .toList()
                                    .length;
                              }
                              bool selected =
                                  controller.selectedCategory == (category?.savePath != null ? category?.name! : null);
                              return ListTile(
                                dense: true,
                                title: Text('$c($count)'),
                                titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                selected: selected,
                                selectedColor: shadColorScheme.destructive,
                                onTap: () {
                                  Get.back();
                                  controller.torrentFilter = 0;
                                  controller.selectedCategory = category?.savePath != null ? category?.name! : null;
                                  controller.filterQbTorrents();
                                },
                              );
                            });
                      }),
                    ),
                    ShadAccordionItem<String>(
                      underlineTitleOnHover: true,
                      padding: EdgeInsets.only(left: 16),
                      value: '种子标签',
                      title: Text(
                        '种子标签【${controller.tags.firstWhereOrNull((item) => item == controller.selectedTag) ?? "无"}】',
                      ),
                      child: GetBuilder<DownloadController>(builder: (controller) {
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.tags.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              String tag = controller.tags[index];
                              int count = 0;
                              if (tag == '全部') {
                                count = controller.torrents.length;
                              } else {
                                count =
                                    controller.torrents.where((torrent) => torrent.tags.contains(tag)).toList().length;
                              }
                              bool selected = controller.selectedTag == tag;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '$tag($count)',
                                ),
                                titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                selected: selected,
                                selectedColor: shadColorScheme.destructive,
                                onTap: () {
                                  controller.selectedTag = tag;
                                  controller.filterQbTorrents();
                                },
                              );
                            });
                      }),
                    ),
                    ShadAccordionItem<String>(
                      underlineTitleOnHover: true,
                      padding: EdgeInsets.only(left: 16),
                      value: '种子状态',
                      title: Text(
                        '种子状态【${controller.qBitStatus.firstWhereOrNull((item) => item.value == controller.torrentState) ?? "无"}】',
                      ),
                      child: GetBuilder<DownloadController>(builder: (controller) {
                        return ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            ...controller.qBitStatus.map((state) {
                              var torrentsMatchingState = [];
                              if (state.value == 'active') {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) =>
                                        [
                                          "downloading",
                                          "uploading",
                                          "checkingUP",
                                          "forcedUP",
                                          "moving",
                                          "checkingDL",
                                        ].contains(torrent.state) ||
                                        (torrent.upSpeed + torrent.dlSpeed) > 0)
                                    .toList();
                              } else {
                                torrentsMatchingState = controller.torrents
                                    .where((torrent) => state.value != null ? torrent.state == state.value : true)
                                    .toList();
                              }
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${state.name}(${torrentsMatchingState.length})',
                                ),
                                titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                style: ListTileStyle.list,
                                selected: controller.torrentState == state.value,
                                selectedColor: shadColorScheme.destructive,
                                onTap: () {
                                  Get.back();
                                  controller.torrentState = state.value;
                                  controller.filterQbTorrents();
                                },
                              );
                            }),
                          ],
                        );
                      }),
                    ),
                    ShadAccordionItem<String>(
                      underlineTitleOnHover: true,
                      padding: EdgeInsets.only(left: 16),
                      value: '站点筛选',
                      title: Text(
                        '站点筛选【${controller.selectedTracker}】',
                      ),
                      child: SizedBox(
                        height: 300,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: controller.showTrackersKeyController,
                              labelText: '筛选',
                              onChanged: (String value) => controller.filterTorrents(false),
                            ),
                            ListTile(
                              dense: true,
                              title: Text('全部'),
                              titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                              style: ListTileStyle.list,
                              selected: controller.selectedTracker == '全部',
                              selectedColor: shadColorScheme.destructive,
                              onTap: () {
                                Get.back();
                                controller.selectedTracker = '全部';
                                controller.filterQbTorrents();
                              },
                            ),
                            Expanded(
                              child: GetBuilder<DownloadController>(builder: (controller) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: controller.showTrackers.length,
                                    itemBuilder: (context, index) {
                                      String? key = controller.showTrackers[index];
                                      List<String>? hashList;
                                      if (key == ' 红种') {
                                        hashList = controller.torrents
                                            .where((element) => element.tracker?.isEmpty == true)
                                            .map((e) => e.hash.toString())
                                            .toList();
                                      } else {
                                        hashList = controller.trackers[key];
                                      }
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          '${key.trim()}(${key == '全部' ? controller.torrents.length : hashList?.length})',
                                        ),
                                        titleTextStyle: TextStyle(color: shadColorScheme.foreground),
                                        style: ListTileStyle.list,
                                        selected: controller.selectedTracker == key,
                                        selectedColor: shadColorScheme.destructive,
                                        onTap: () {
                                          Get.back();
                                          controller.selectedTracker = key;
                                          controller.filterQbTorrents();
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
            ),

            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.all(0),
              titleTextStyle: TextStyle(color: shadColorScheme.foreground),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomTextTag(
                      icon: const Icon(
                        Icons.sd_storage,
                        color: Colors.green,
                        size: 14,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: Colors.green,
                      labelText: FileSizeConvert.parseToFileSize(state.freeSpaceOnDisk)),
                  CustomTextTag(
                      icon: const Icon(
                        Icons.upload_outlined,
                        color: Colors.green,
                        size: 14,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: Colors.green,
                      labelText:
                          '${FileSizeConvert.parseToFileSize(state.alltimeUl)}[${FileSizeConvert.parseToFileSize(state.upInfoData)}]'),
                  CustomTextTag(
                      icon: const Icon(
                        Icons.download_outlined,
                        color: Colors.red,
                        size: 14,
                      ),
                      backgroundColor: Colors.transparent,
                      labelColor: Colors.red,
                      labelText:
                          '${FileSizeConvert.parseToFileSize(state.alltimeDl)}[${FileSizeConvert.parseToFileSize(state.dlInfoData)}]'),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Future<void> _showQbPrefs(Downloader downloader, context) async {
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
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (!response.succeed) {
      Get.snackbar('出错啦！', '获取下载器设置失败', colorText: shadColorScheme.destructive);
      return;
    }
    controller.currentPrefs = QbittorrentPreferences.fromJson(response.data);
    controller.update();
    logger_helper.Logger.instance.d(controller.currentPrefs.torrentContentLayout);
    // QbittorrentPreferences prefs = downloader.prefs;
    RxBool autoTmmEnabled = RxBool(controller.currentPrefs.autoTmmEnabled);
    RxBool addTrackersEnabled = RxBool(controller.currentPrefs.addTrackersEnabled);
    RxBool alternativeWebuiEnabled = RxBool(controller.currentPrefs.alternativeWebuiEnabled);
    RxBool anonymousMode = RxBool(controller.currentPrefs.anonymousMode);
    RxBool bypassAuthSubnetWhitelistEnabled = RxBool(controller.currentPrefs.bypassAuthSubnetWhitelistEnabled);
    RxBool bypassLocalAuth = RxBool(controller.currentPrefs.bypassLocalAuth);
    RxBool categoryChangedTmmEnabled = RxBool(controller.currentPrefs.categoryChangedTmmEnabled);
    RxBool dht = RxBool(controller.currentPrefs.dht);
    RxBool dontCountSlowTorrents = RxBool(controller.currentPrefs.dontCountSlowTorrents);
    RxBool dyndnsEnabled = RxBool(controller.currentPrefs.dyndnsEnabled);
    RxBool embeddedTrackerPortForwarding = RxBool(controller.currentPrefs.embeddedTrackerPortForwarding);
    RxBool enableCoalesceReadWrite = RxBool(controller.currentPrefs.enableCoalesceReadWrite);
    RxBool enableEmbeddedTracker = RxBool(controller.currentPrefs.enableEmbeddedTracker);
    RxBool enableMultiConnectionsFromSameIp = RxBool(controller.currentPrefs.enableMultiConnectionsFromSameIp);
    RxBool enablePieceExtentAffinity = RxBool(controller.currentPrefs.enablePieceExtentAffinity);
    RxBool enableUploadSuggestions = RxBool(controller.currentPrefs.enableUploadSuggestions);
    RxBool excludedFileNamesEnabled = RxBool(controller.currentPrefs.excludedFileNamesEnabled);
    RxBool idnSupportEnabled = RxBool(controller.currentPrefs.idnSupportEnabled);
    RxBool incompleteFilesExt = RxBool(controller.currentPrefs.incompleteFilesExt);
    RxBool ipFilterEnabled = RxBool(controller.currentPrefs.ipFilterEnabled);
    RxBool ipFilterTrackers = RxBool(controller.currentPrefs.ipFilterTrackers);
    RxBool limitLanPeers = RxBool(controller.currentPrefs.limitLanPeers);
    RxBool limitTcpOverhead = RxBool(controller.currentPrefs.limitTcpOverhead);
    RxBool limitUtpRate = RxBool(controller.currentPrefs.limitUtpRate);
    RxInt autoDeleteMode = RxInt(controller.currentPrefs.autoDeleteMode);
    RxInt uploadChokingAlgorithm = RxInt(controller.currentPrefs.uploadChokingAlgorithm);
    RxInt uploadSlotsBehavior = RxInt(controller.currentPrefs.uploadSlotsBehavior);
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
    RxBool maxSeedingTimeEnabled = RxBool(controller.currentPrefs.maxSeedingTimeEnabled);
    RxBool performanceWarning = RxBool(controller.currentPrefs.performanceWarning);
    RxBool pex = RxBool(controller.currentPrefs.pex);
    RxBool preallocateAll = RxBool(controller.currentPrefs.preallocateAll);
    RxBool proxyAuthEnabled = RxBool(controller.currentPrefs.proxyAuthEnabled);
    RxBool proxyHostnameLookup = RxBool(controller.currentPrefs.proxyHostnameLookup);
    RxBool proxyPeerConnections = RxBool(controller.currentPrefs.proxyPeerConnections);
    RxBool proxyTorrentsOnly = RxBool(controller.currentPrefs.proxyTorrentsOnly);
    RxBool queueingEnabled = RxBool(controller.currentPrefs.queueingEnabled);
    RxBool randomPort = RxBool(controller.currentPrefs.randomPort);
    RxBool reannounceWhenAddressChanged = RxBool(controller.currentPrefs.reannounceWhenAddressChanged);
    RxBool recheckCompletedTorrents = RxBool(controller.currentPrefs.recheckCompletedTorrents);
    RxBool resolvePeerCountries = RxBool(controller.currentPrefs.resolvePeerCountries);
    RxBool rssAutoDownloadingEnabled = RxBool(controller.currentPrefs.rssAutoDownloadingEnabled);
    RxBool rssDownloadRepackProperEpisodes = RxBool(controller.currentPrefs.rssDownloadRepackProperEpisodes);
    RxBool rssProcessingEnabled = RxBool(controller.currentPrefs.rssProcessingEnabled);
    RxBool savePathChangedTmmEnabled = RxBool(controller.currentPrefs.savePathChangedTmmEnabled);
    RxBool schedulerEnabled = RxBool(controller.currentPrefs.schedulerEnabled);
    RxBool ssrfMitigation = RxBool(controller.currentPrefs.ssrfMitigation);
    RxBool startPausedEnabled = RxBool(controller.currentPrefs.startPausedEnabled);
    RxBool tempPathEnabled = RxBool(controller.currentPrefs.tempPathEnabled);
    RxBool torrentChangedTmmEnabled = RxBool(controller.currentPrefs.torrentChangedTmmEnabled);
    RxBool upnp = RxBool(controller.currentPrefs.upnp);
    RxBool useCategoryPathsInManualMode = RxBool(controller.currentPrefs.useCategoryPathsInManualMode);
    RxBool useHttps = RxBool(controller.currentPrefs.useHttps);
    RxBool validateHttpsTrackerCertificate = RxBool(controller.currentPrefs.validateHttpsTrackerCertificate);
    RxBool webUiClickjackingProtectionEnabled = RxBool(controller.currentPrefs.webUiClickjackingProtectionEnabled);
    RxBool webUiCsrfProtectionEnabled = RxBool(controller.currentPrefs.webUiCsrfProtectionEnabled);
    RxBool webUiHostHeaderValidationEnabled = RxBool(controller.currentPrefs.webUiHostHeaderValidationEnabled);
    RxBool webUiReverseProxyEnabled = RxBool(controller.currentPrefs.webUiReverseProxyEnabled);
    RxBool webUiSecureCookieEnabled = RxBool(controller.currentPrefs.webUiSecureCookieEnabled);
    RxBool webUiUpnp = RxBool(controller.currentPrefs.webUiUpnp);
    RxBool webUiUseCustomHttpHeadersEnabled = RxBool(controller.currentPrefs.webUiUseCustomHttpHeadersEnabled);

    TextEditingController bypassAuthSubnetWhitelistController =
        TextEditingController(text: controller.currentPrefs.bypassAuthSubnetWhitelist);
    TextEditingController addTrackersController = TextEditingController(text: controller.currentPrefs.addTrackers);
    TextEditingController alternativeWebuiPathController =
        TextEditingController(text: controller.currentPrefs.alternativeWebuiPath);
    TextEditingController announceIpController = TextEditingController(text: controller.currentPrefs.announceIp);
    TextEditingController autorunProgramController =
        TextEditingController(text: controller.currentPrefs.autorunProgram);
    TextEditingController bannedIPsController = TextEditingController(text: controller.currentPrefs.bannedIps);
    RxString currentInterfaceAddress = RxString(controller.currentPrefs.currentInterfaceAddress);
    RxString currentNetworkInterface = RxString(controller.currentPrefs.currentNetworkInterface);
    TextEditingController dyndnsDomainController = TextEditingController(text: controller.currentPrefs.dyndnsDomain);
    TextEditingController dyndnsPasswordController =
        TextEditingController(text: controller.currentPrefs.dyndnsPassword);
    TextEditingController dyndnsUsernameController =
        TextEditingController(text: controller.currentPrefs.dyndnsUsername);
    TextEditingController exportDirController = TextEditingController(text: controller.currentPrefs.exportDir);
    RxBool exportDirFinEnable = RxBool(controller.currentPrefs.exportDirFin.isNotEmpty);
    RxBool exportDirEnable = RxBool(controller.currentPrefs.exportDir.isNotEmpty);
    TextEditingController exportDirFinController = TextEditingController(text: controller.currentPrefs.exportDirFin);
    TextEditingController ipFilterPathController = TextEditingController(text: controller.currentPrefs.ipFilterPath);
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
    TextEditingController proxyIpController = TextEditingController(text: controller.currentPrefs.proxyIp);
    TextEditingController proxyPasswordController = TextEditingController(text: controller.currentPrefs.proxyPassword);
    TextEditingController proxyUsernameController = TextEditingController(text: controller.currentPrefs.proxyUsername);
    TextEditingController rssSmartEpisodeFiltersController =
        TextEditingController(text: controller.currentPrefs.rssSmartEpisodeFilters);
    TextEditingController savePathController = TextEditingController(text: controller.currentPrefs.savePath);
    TextEditingController tempPathController = TextEditingController(text: controller.currentPrefs.tempPath);
    TextEditingController torrentContentLayoutController =
        TextEditingController(text: controller.currentPrefs.torrentContentLayout);
    RxString torrentStopCondition = RxString(controller.currentPrefs.torrentStopCondition);
    RxString resumeDataStorageType = RxString(controller.currentPrefs.resumeDataStorageType);
    Rx proxyType = Rx(controller.currentPrefs.proxyType);

    TextEditingController webUiAddressController = TextEditingController(text: controller.currentPrefs.webUiAddress);
    TextEditingController webUiCustomHttpHeadersController =
        TextEditingController(text: controller.currentPrefs.webUiCustomHttpHeaders);
    TextEditingController webUiDomainListController =
        TextEditingController(text: controller.currentPrefs.webUiDomainList);
    TextEditingController webUiHttpsCertPathController =
        TextEditingController(text: controller.currentPrefs.webUiHttpsCertPath);
    TextEditingController webUiHttpsKeyPathController =
        TextEditingController(text: controller.currentPrefs.webUiHttpsKeyPath);
    TextEditingController webUiReverseProxiesListController =
        TextEditingController(text: controller.currentPrefs.webUiReverseProxiesList);
    TextEditingController webUiUsernameController = TextEditingController(text: controller.currentPrefs.webUiUsername);
    // TextEditingController webUiPasswordController =
    //     TextEditingController(text: '');
    TextEditingController listenPortController =
        TextEditingController(text: controller.currentPrefs.listenPort.toString());
    RxInt bittorrentProtocol = RxInt(controller.currentPrefs.bittorrentProtocol);
    RxInt dyndnsService = RxInt(controller.currentPrefs.dyndnsService);
    TextEditingController proxyPortController =
        TextEditingController(text: controller.currentPrefs.proxyPort.toString());
    TextEditingController altDlLimitController =
        TextEditingController(text: (controller.currentPrefs.altDlLimit / 1024).toInt().toString());
    TextEditingController altUpLimitController =
        TextEditingController(text: (controller.currentPrefs.altUpLimit / 1024).toInt().toString());
    TextEditingController asyncIoThreadsController =
        TextEditingController(text: controller.currentPrefs.asyncIoThreads.toString());
    TextEditingController checkingMemoryUseController =
        TextEditingController(text: controller.currentPrefs.checkingMemoryUse.toString());
    TextEditingController connectionSpeedController =
        TextEditingController(text: controller.currentPrefs.connectionSpeed.toString());
    TextEditingController diskCacheController =
        TextEditingController(text: controller.currentPrefs.diskCache.toString());
    TextEditingController diskCacheTtlController =
        TextEditingController(text: controller.currentPrefs.diskCacheTtl.toString());
    RxInt diskIoReadMode = RxInt(controller.currentPrefs.diskIoReadMode);
    RxInt diskIoType = RxInt(controller.currentPrefs.diskIoType);
    RxInt diskIoWriteMode = RxInt(controller.currentPrefs.diskIoWriteMode);
    TextEditingController diskQueueSizeController =
        TextEditingController(text: (controller.currentPrefs.diskQueueSize / 1024).toInt().toString());
    TextEditingController embeddedTrackerPortController =
        TextEditingController(text: controller.currentPrefs.embeddedTrackerPort.toString());
    TextEditingController filePoolSizeController =
        TextEditingController(text: controller.currentPrefs.filePoolSize.toString());
    TextEditingController hashingThreadsController =
        TextEditingController(text: controller.currentPrefs.hashingThreads.toString());
    TextEditingController maxActiveCheckingTorrentsController =
        TextEditingController(text: controller.currentPrefs.maxActiveCheckingTorrents.toString());
    TextEditingController maxActiveDownloadsController =
        TextEditingController(text: controller.currentPrefs.maxActiveDownloads.toString());
    TextEditingController maxActiveTorrentsController =
        TextEditingController(text: controller.currentPrefs.maxActiveTorrents.toString());
    TextEditingController maxActiveUploadsController =
        TextEditingController(text: controller.currentPrefs.maxActiveUploads.toString());
    TextEditingController maxConcurrentHttpAnnouncesController =
        TextEditingController(text: controller.currentPrefs.maxConcurrentHttpAnnounces.toString());
    TextEditingController maxConnecController =
        TextEditingController(text: controller.currentPrefs.maxConnec.toString());
    RxBool maxConnecEnabled = RxBool(controller.currentPrefs.maxConnec > 0);
    RxString locale = RxString(controller.currentPrefs.locale);
    RxBool maxConnecPerTorrentEnabled = RxBool(controller.currentPrefs.maxConnecPerTorrent > 0);

    TextEditingController maxConnecPerTorrentController =
        TextEditingController(text: controller.currentPrefs.maxConnecPerTorrent.toString());
    TextEditingController maxRatioController = TextEditingController(text: controller.currentPrefs.maxRatio.toString());
    RxInt maxRatioAct = RxInt(controller.currentPrefs.maxRatioAct);
    TextEditingController maxSeedingTimeController =
        TextEditingController(text: controller.currentPrefs.maxSeedingTime.toString());
    TextEditingController maxUploadsController =
        TextEditingController(text: controller.currentPrefs.maxUploads.toString());
    RxBool maxUploadsEnabled = RxBool(controller.currentPrefs.maxUploads > 0);
    RxBool announceToAllTrackers = RxBool(controller.currentPrefs.announceToAllTrackers);
    RxBool announceToAllTiers = RxBool(controller.currentPrefs.announceToAllTiers);

    RxBool blockPeersOnPrivilegedPorts = RxBool(controller.currentPrefs.blockPeersOnPrivilegedPorts);
    RxBool maxUploadsPerTorrentEnabled = RxBool(controller.currentPrefs.maxUploadsPerTorrent > 0);
    TextEditingController maxUploadsPerTorrentController =
        TextEditingController(text: controller.currentPrefs.maxUploadsPerTorrent.toString());
    TextEditingController memoryWorkingSetLimitController =
        TextEditingController(text: controller.currentPrefs.memoryWorkingSetLimit.toString());
    TextEditingController outgoingPortsMaxController =
        TextEditingController(text: controller.currentPrefs.outgoingPortsMax.toString());
    TextEditingController outgoingPortsMinController =
        TextEditingController(text: controller.currentPrefs.outgoingPortsMin.toString());
    TextEditingController peerTosController = TextEditingController(text: controller.currentPrefs.peerTos.toString());
    TextEditingController peerTurnoverController =
        TextEditingController(text: controller.currentPrefs.peerTurnover.toString());
    TextEditingController peerTurnoverCutoffController =
        TextEditingController(text: controller.currentPrefs.peerTurnoverCutoff.toString());
    TextEditingController peerTurnoverIntervalController =
        TextEditingController(text: controller.currentPrefs.peerTurnoverInterval.toString());
    TextEditingController refreshIntervalController =
        TextEditingController(text: controller.currentPrefs.refreshInterval.toString());
    TextEditingController requestQueueSizeController =
        TextEditingController(text: controller.currentPrefs.requestQueueSize.toString());
    TextEditingController rssMaxArticlesPerFeedController =
        TextEditingController(text: controller.currentPrefs.rssMaxArticlesPerFeed.toString());
    TextEditingController rssRefreshIntervalController =
        TextEditingController(text: controller.currentPrefs.rssRefreshInterval.toString());
    TextEditingController saveResumeDataIntervalController =
        TextEditingController(text: controller.currentPrefs.saveResumeDataInterval.toString());
    TextEditingController scheduleFromHourController =
        TextEditingController(text: controller.currentPrefs.scheduleFromHour.toString());
    TextEditingController scheduleFromMinController =
        TextEditingController(text: controller.currentPrefs.scheduleFromMin.toString());
    TextEditingController scheduleToHourController =
        TextEditingController(text: controller.currentPrefs.scheduleToHour.toString());
    TextEditingController scheduleToMinController =
        TextEditingController(text: controller.currentPrefs.scheduleToMin.toString());
    RxInt schedulerDays = RxInt(controller.currentPrefs.schedulerDays);
    TextEditingController sendBufferLowWatermarkController =
        TextEditingController(text: controller.currentPrefs.sendBufferLowWatermark.toString());
    TextEditingController sendBufferWatermarkController =
        TextEditingController(text: controller.currentPrefs.sendBufferWatermark.toString());
    TextEditingController sendBufferWatermarkFactorController =
        TextEditingController(text: controller.currentPrefs.sendBufferWatermarkFactor.toString());
    TextEditingController slowTorrentDlRateThresholdController =
        TextEditingController(text: controller.currentPrefs.slowTorrentDlRateThreshold.toString());
    TextEditingController slowTorrentInactiveTimerController =
        TextEditingController(text: controller.currentPrefs.slowTorrentInactiveTimer.toString());
    TextEditingController slowTorrentUlRateThresholdController =
        TextEditingController(text: controller.currentPrefs.slowTorrentUlRateThreshold.toString());
    TextEditingController socketBacklogSizeController =
        TextEditingController(text: controller.currentPrefs.socketBacklogSize.toString());
    TextEditingController stopTrackerTimeoutController =
        TextEditingController(text: controller.currentPrefs.stopTrackerTimeout.toString());
    TextEditingController upLimitController =
        TextEditingController(text: (controller.currentPrefs.upLimit / 1024).toInt().toString());
    TextEditingController dlLimitController =
        TextEditingController(text: (controller.currentPrefs.dlLimit / 1024).toInt().toString());
    TextEditingController upnpLeaseDurationController =
        TextEditingController(text: controller.currentPrefs.upnpLeaseDuration.toString());
    TextEditingController webUiBanDurationController =
        TextEditingController(text: controller.currentPrefs.webUiBanDuration.toString());
    TextEditingController webUiMaxAuthFailCountController =
        TextEditingController(text: controller.currentPrefs.webUiMaxAuthFailCount.toString());
    TextEditingController webUiPortController =
        TextEditingController(text: controller.currentPrefs.webUiPort.toString());
    TextEditingController webUiSessionTimeoutController =
        TextEditingController(text: controller.currentPrefs.webUiSessionTimeout.toString());
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
      GetBuilder<DownloadController>(builder: (controller) {
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            backgroundColor: shadColorScheme.background,
            appBar: AppBar(
              backgroundColor: shadColorScheme.background,
              title: Text(
                '配置选项[${downloader.prefs.webApiVersion.toString()}]',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              toolbarHeight: 40,
              bottom: const TabBar(tabs: tabs, isScrollable: true),
            ),
            body: CustomCard(
              padding: const EdgeInsets.all(8.0),
              child: TabBarView(children: [
                ListView(
                  children: [
                    Obx(() {
                      return CustomCard(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '添加种子时',
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  ),
                                  DropdownButton(
                                      isDense: true,
                                      dropdownColor: shadColorScheme.background,
                                      value: torrentContentLayoutController.text,
                                      items: [
                                        DropdownMenuItem(
                                            value: 'Original',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '原始')),
                                        DropdownMenuItem(
                                            value: 'Subfolder',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '子文件夹')),
                                        DropdownMenuItem(
                                            value: 'NoSubfolder',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '不创建子文件夹')),
                                      ],
                                      onChanged: (value) {
                                        torrentContentLayoutController.text = value!;
                                      }),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: startPausedEnabled.value,
                              onChanged: (value) {
                                startPausedEnabled.value = value == true;
                              },
                              title: Text(
                                '不要开始自动下载',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('种子停止条件', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      value: torrentStopCondition.value,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'None',
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground), '无'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'MetadataReceived',
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '已收到元数据'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'FilesChecked',
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '选种的文件'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        torrentStopCondition.value = value ?? 'None';
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
                              title: Text(
                                '完成后删除.torrent文件',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
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
                              title: Text('为所有文件预分配磁盘空间', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: incompleteFilesExt.value,
                              onChanged: (value) {
                                incompleteFilesExt.value = value == true;
                              },
                              title: Text('为不完整的文件添加扩展名 .!qB', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('Torrent 自动管理模式', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('当分类修改时', style: TextStyle(color: shadColorScheme.foreground)),
                                DropdownButton(
                                    isDense: true,
                                    dropdownColor: shadColorScheme.background,
                                    value: categoryChangedTmmEnabled.value,
                                    items: [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '重新定位')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '切换手动')),
                                    ],
                                    onChanged: (value) {
                                      savePathChangedTmmEnabled.value = value == true;
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('当默认保存路径修改', style: TextStyle(color: shadColorScheme.foreground)),
                                DropdownButton(
                                    dropdownColor: shadColorScheme.background,
                                    isDense: true,
                                    value: savePathChangedTmmEnabled.value,
                                    items: [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '重新定位')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '切换手动')),
                                    ],
                                    onChanged: (value) {
                                      savePathChangedTmmEnabled.value = value == true;
                                    }),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('当分类保存路径修改', style: TextStyle(color: shadColorScheme.foreground)),
                                DropdownButton(
                                    dropdownColor: shadColorScheme.background,
                                    isDense: true,
                                    value: torrentChangedTmmEnabled.value,
                                    items: [
                                      DropdownMenuItem(
                                          value: true,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '重新定位')),
                                      DropdownMenuItem(
                                          value: false,
                                          child: Text(
                                              style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                              '切换手动')),
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
                            title: Text('保存未完成的 torrent 到', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('复制 .torrent 文件到：', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('复制下载完成的 .torrent 文件到', style: TextStyle(color: shadColorScheme.foreground)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('下载连接协议', style: TextStyle(color: shadColorScheme.foreground)),
                          DropdownButton(
                              dropdownColor: shadColorScheme.background,
                              isDense: true,
                              value: bittorrentProtocol.value,
                              items: [
                                DropdownMenuItem(
                                    value: 0,
                                    child: Text(
                                        style: TextStyle(fontSize: 14, color: shadColorScheme.foreground), 'TCP和UTP')),
                                DropdownMenuItem(
                                    value: 1,
                                    child:
                                        Text(style: TextStyle(fontSize: 14, color: shadColorScheme.foreground), 'TCP')),
                                DropdownMenuItem(
                                    value: 2,
                                    child:
                                        Text(style: TextStyle(fontSize: 14, color: shadColorScheme.foreground), 'UTP')),
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
                                  ShadButton.outline(
                                      size: ShadButtonSize.sm,
                                      onPressed: () {
                                        listenPortController.text = (10000 + Random().nextInt(55535)).toString();
                                      },
                                      child: Text('随机', style: TextStyle(color: shadColorScheme.foreground)))
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: upnp.value,
                              onChanged: (value) {
                                upnp.value = value == true;
                              },
                              title: Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口',
                                  style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: randomPort.value,
                              onChanged: (value) {
                                randomPort.value = value == true;
                              },
                              title: Text('使用随机端口', style: TextStyle(color: shadColorScheme.foreground)),
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
                              title: Text(
                                '全局最大连接数',
                                style: TextStyle(color: shadColorScheme.foreground),
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
                                maxConnecPerTorrentEnabled.value = value == true;
                              },
                              title: Text('每 torrent 最大连接数', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            if (maxConnecPerTorrentEnabled.value)
                              CustomTextField(
                                  readOnly: maxConnecPerTorrentEnabled.value,
                                  controller: TextEditingController(
                                    text: controller.currentPrefs.maxConnecPerTorrent.toString(),
                                  ),
                                  labelText: '每 torrent 最大连接数'),
                            CheckboxListTile(
                              dense: true,
                              value: maxUploadsEnabled.value,
                              onChanged: (value) {
                                maxUploadsEnabled.value = value == true;
                              },
                              title: Text('全局上传窗口数上限', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            if (maxUploadsEnabled.value)
                              CustomTextField(controller: maxUploadsController, labelText: '全局上传窗口数上限'),
                            CheckboxListTile(
                              dense: true,
                              value: maxUploadsPerTorrentEnabled.value,
                              onChanged: (value) {
                                maxUploadsPerTorrentEnabled.value = value == true;
                              },
                              title: Text('每个 torrent 上传窗口数上限', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            if (maxUploadsPerTorrentEnabled.value)
                              CustomTextField(
                                  controller: maxUploadsPerTorrentController, labelText: '每个 torrent 上传窗口数上限'),
                          ],
                        ),
                      );
                    }),
                    Obx(() {
                      return CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('代理类型', style: TextStyle(color: shadColorScheme.foreground)),
                                DropdownButton(
                                    dropdownColor: shadColorScheme.background,
                                    isDense: true,
                                    value: proxyType.value,
                                    items: [
                                      if (downloader.prefs.version.compareTo('2.5.1') > 0) ...[
                                        DropdownMenuItem(
                                            value: 'None',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '(无)')),
                                        DropdownMenuItem(
                                            value: 'SOCKS4',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'SOCKS4')),
                                        DropdownMenuItem(
                                            value: 'SOCKS5',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'SOCKS5')),
                                        DropdownMenuItem(
                                            value: 'HTTP',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'HTTP')),
                                      ],
                                      if (downloader.prefs.version.compareTo('2.5.1') < 0) ...[
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '(无)')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'SOCKS4')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'SOCKS5')),
                                        DropdownMenuItem(
                                            value: 3,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                'HTTP')),
                                      ],
                                    ],
                                    onChanged: (value) {
                                      proxyType.value = value!;
                                    }),
                              ],
                            ),
                            if (proxyType.value != 'None')
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
                                      proxyPeerConnections.value = value == true;
                                    },
                                    title: Text('使用代理服务器进行用户连接', style: TextStyle(color: shadColorScheme.foreground)),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyTorrentsOnly.value,
                                    onChanged: (value) {
                                      proxyTorrentsOnly.value = value == true;
                                    },
                                    title: Text('Use proxy only for torrents',
                                        style: TextStyle(color: shadColorScheme.foreground)),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyHostnameLookup.value,
                                    onChanged: (value) {
                                      proxyHostnameLookup.value = value == true;
                                    },
                                    title: Text('使用代理进行主机名查询', style: TextStyle(color: shadColorScheme.foreground)),
                                  ),
                                  CheckboxListTile(
                                    dense: true,
                                    value: proxyAuthEnabled.value,
                                    onChanged: (value) {
                                      proxyAuthEnabled.value = value == true;
                                    },
                                    title: Text('验证', style: TextStyle(color: shadColorScheme.foreground)),
                                  ),
                                  if (proxyAuthEnabled.value)
                                    Column(
                                      children: [
                                        CustomTextField(controller: proxyUsernameController, labelText: '用户名'),
                                        CustomTextField(controller: proxyPasswordController, labelText: '密码'),
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
                            Text('IP 过滤', style: TextStyle(color: shadColorScheme.foreground)),
                            CheckboxListTile(
                              dense: true,
                              value: ipFilterEnabled.value,
                              onChanged: (value) {
                                ipFilterEnabled.value = value == true;
                              },
                              title: Text('开启过滤规则', style: TextStyle(color: shadColorScheme.foreground)),
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
                                    title: Text('开启过滤规则', style: TextStyle(color: shadColorScheme.foreground)),
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
                          Text('全局速度限制(0 为无限制)', style: TextStyle(color: shadColorScheme.foreground)),
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
                            Text('备用速度限制(0 为无限制)', style: TextStyle(color: shadColorScheme.foreground)),
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
                              title: Text('计划备用速度限制的启用时间', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            if (schedulerEnabled.value)
                              Column(
                                children: [
                                  CustomTextField(
                                      controller: scheduleFromHourController, labelText: '自动启用备用带宽设置开始时间(小时)'),
                                  CustomTextField(
                                      controller: scheduleFromMinController, labelText: '自动启用备用带宽设置开始时间(分钟)'),
                                  CustomTextField(
                                      controller: scheduleToHourController, labelText: '自动启用备用带宽设置结束时间(小时)'),
                                  CustomTextField(controller: scheduleToMinController, labelText: '自动启用备用带宽设置结束时间(分钟)'),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: DropdownButton(
                                          dropdownColor: shadColorScheme.background,
                                          isDense: true,
                                          value: schedulerDays.value,
                                          items: [
                                            DropdownMenuItem(
                                                value: 0,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '每天')),
                                            DropdownMenuItem(
                                                value: 1,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '工作日')),
                                            DropdownMenuItem(
                                                value: 2,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周末')),
                                            DropdownMenuItem(
                                                value: 3,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周一')),
                                            DropdownMenuItem(
                                                value: 4,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周二')),
                                            DropdownMenuItem(
                                                value: 5,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周三')),
                                            DropdownMenuItem(
                                                value: 6,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周四')),
                                            DropdownMenuItem(
                                                value: 7,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周五')),
                                            DropdownMenuItem(
                                                value: 8,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    '周六')),
                                            DropdownMenuItem(
                                                value: 9,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                            title: Text('对 µTP 协议进行速度限制', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: limitTcpOverhead.value,
                            onChanged: (value) {
                              limitTcpOverhead.value = value == true;
                            },
                            title: Text('对传送总开销进行速度限制', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: limitLanPeers.value,
                            onChanged: (value) {
                              limitLanPeers.value = value == true;
                            },
                            title: Text('对本地网络用户进行速度限制', style: TextStyle(color: shadColorScheme.foreground)),
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
                              title:
                                  Text('启用 DHT (去中心化网络) 以找到更多用户', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: pex.value,
                              onChanged: (value) {
                                pex.value = value == true;
                              },
                              title: Text('启用用户交换 (PeX) 以找到更多用户', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: lsd.value,
                              onChanged: (value) {
                                lsd.value = value == true;
                              },
                              title: Text('启用本地用户发现以找到更多用户', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('加密模式', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: encryption.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '允许加密')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '强制加密')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                              title: Text('启用匿名模式', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('Torrent 排队', style: TextStyle(color: shadColorScheme.foreground)),
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
                                  title: Text('慢速 torrent 不计入限制内', style: TextStyle(color: shadColorScheme.foreground)),
                                ),
                                if (dontCountSlowTorrents.value)
                                  Column(
                                    children: [
                                      CustomTextField(
                                        controller: slowTorrentDlRateThresholdController,
                                        labelText: '下载速度阈值',
                                      ),
                                      CustomTextField(
                                        controller: slowTorrentUlRateThresholdController,
                                        labelText: '上传速度阈值',
                                      ),
                                      CustomTextField(
                                        controller: slowTorrentInactiveTimerController,
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
                          Text('做种限制', style: TextStyle(color: shadColorScheme.foreground)),
                          CheckboxListTile(
                            dense: true,
                            value: maxRatioEnabled.value,
                            onChanged: (value) {
                              maxRatioEnabled.value = value == true;
                            },
                            title: Text('当分享率达到', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('当做种时间达到', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          if (maxSeedingTimeEnabled.value)
                            CustomNumberField(
                              controller: TextEditingController(
                                text: controller.currentPrefs.maxSeedingTime.toString(),
                              ),
                              labelText: '当做种时间达到',
                            ),
                          if (maxSeedingTimeEnabled.value || maxRatioEnabled.value)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('达到做种限制时的操作', style: TextStyle(color: shadColorScheme.foreground)),
                                    DropdownButton(
                                        dropdownColor: shadColorScheme.background,
                                        isDense: true,
                                        value: maxRatioAct.value,
                                        items: [
                                          DropdownMenuItem(
                                              value: 0,
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '暂停 torrent')),
                                          DropdownMenuItem(
                                              value: 1,
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '删除 torrent')),
                                          DropdownMenuItem(
                                              value: 2,
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '删除 torrent 及所属文件')),
                                          DropdownMenuItem(
                                              value: 3,
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                              title:
                                  Text('自动添加tracker到新的 torrent', style: TextStyle(color: shadColorScheme.foreground)),
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
                          Text('RSS', style: TextStyle(color: shadColorScheme.foreground)),
                          CheckboxListTile(
                            dense: true,
                            value: rssProcessingEnabled.value,
                            onChanged: (value) {
                              rssProcessingEnabled.value = value == true;
                            },
                            title: Text('启用获取 RSS 订阅', style: TextStyle(color: shadColorScheme.foreground)),
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
                          title: Text('启用 RSS Torrent 自动下载', style: TextStyle(color: shadColorScheme.foreground)),
                        ),
                      ]));
                    }),
                    CustomCard(
                      child: Obx(() {
                        return Column(
                          children: [
                            Text('RSS 智能剧集过滤器', style: TextStyle(color: shadColorScheme.foreground)),
                            CheckboxListTile(
                              dense: true,
                              value: rssDownloadRepackProperEpisodes.value,
                              onChanged: (value) {
                                rssDownloadRepackProperEpisodes.value = value == true;
                              },
                              title: Text('下载 REPACK/PROPER 版剧集', style: TextStyle(color: shadColorScheme.foreground)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('用户界面语言', style: TextStyle(color: shadColorScheme.foreground)),
                              DropdownButton(
                                  dropdownColor: shadColorScheme.background,
                                  isDense: true,
                                  value: locale.value,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'zh_CN',
                                        child: Text('简体中文', style: TextStyle(color: shadColorScheme.foreground))),
                                    DropdownMenuItem(
                                        value: 'en',
                                        child: Text('English', style: TextStyle(color: shadColorScheme.foreground))),
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
                          title: Text('记录性能警报', style: TextStyle(color: shadColorScheme.foreground)),
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
                          title: Text('使用我的路由器的 UPnP / NAT-PMP 功能来转发端口',
                              style: TextStyle(color: shadColorScheme.foreground)),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: useHttps.value,
                          onChanged: (value) {
                            useHttps.value = value == true;
                          },
                          title: Text('使用 HTTPS 而不是 HTTP', style: TextStyle(color: shadColorScheme.foreground)),
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
                          title: Text('对本地主机上的客户端跳过身份验证', style: TextStyle(color: shadColorScheme.foreground)),
                        ),
                        CheckboxListTile(
                          dense: true,
                          value: bypassAuthSubnetWhitelistEnabled.value,
                          onChanged: (value) {
                            bypassAuthSubnetWhitelistEnabled.value = value == true;
                          },
                          title: Text('对 IP 子网白名单中的客户端跳过身份验证', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('使用备用 Web UI', style: TextStyle(color: shadColorScheme.foreground)),
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
                              webUiClickjackingProtectionEnabled.value = value == true;
                            },
                            title: Text('启用 “点击劫持” 保护', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiCsrfProtectionEnabled.value,
                            onChanged: (value) {
                              webUiCsrfProtectionEnabled.value = value == true;
                            },
                            title: Text('启用跨站请求伪造 (CSRF) 保护', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiSecureCookieEnabled.value,
                            enabled: useHttps.value,
                            onChanged: (value) {
                              webUiSecureCookieEnabled.value = value == true;
                            },
                            title:
                                Text('启用 cookie 安全标志（需要 HTTPS）', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: webUiHostHeaderValidationEnabled.value,
                            onChanged: (value) {
                              webUiHostHeaderValidationEnabled.value = value == true;
                            },
                            title: Text('启用 Host header 属性验证', style: TextStyle(color: shadColorScheme.foreground)),
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
                              webUiUseCustomHttpHeadersEnabled.value = value == true;
                            },
                            title: Text('添加自定义 HTTP 头字段', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('启用反向代理支持', style: TextStyle(color: shadColorScheme.foreground)),
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
                            title: Text('更新我的动态域名', style: TextStyle(color: shadColorScheme.foreground)),
                          ),
                          if (dyndnsEnabled.value)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('域名提供商', style: TextStyle(color: shadColorScheme.foreground)),
                                      DropdownButton(
                                          dropdownColor: shadColorScheme.background,
                                          isDense: true,
                                          value: dyndnsService.value,
                                          items: [
                                            DropdownMenuItem(
                                                value: 0,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                    'DynDNS')),
                                            DropdownMenuItem(
                                                value: 1,
                                                child: Text(
                                                    style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                          Text(
                            'qBittorrent 相关',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ),
                          if (resumeDataStorageType.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('恢复数据存储(需重启)', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: resumeDataStorageType.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 'Legacy',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '快速恢复文件')),
                                        DropdownMenuItem(
                                            value: 'SQLite',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                          //        DropdownButton(dropdownColor: shadColorScheme.background,
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
                          //        DropdownButton(dropdownColor: shadColorScheme.background,
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
                            title: Text(
                              '完成后重新校验 Torrent',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
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
                              reannounceWhenAddressChanged.value = value == true;
                            },
                            title: Text(
                              '当 IP 或端口更改时，重新通知所有 trackers',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                          ),
                          CheckboxListTile(
                            dense: true,
                            value: enableEmbeddedTracker.value,
                            onChanged: (value) {
                              enableEmbeddedTracker.value = value == true;
                            },
                            title: Text(
                              '启用内置 Tracker',
                              style: TextStyle(color: shadColorScheme.foreground),
                            ),
                          ),
                          if (enableEmbeddedTracker.value == true)
                            Column(
                              children: [
                                CustomTextField(
                                  controller: embeddedTrackerPortController,
                                  labelText: '内置 tracker 端口',
                                ),
                                CheckboxListTile(
                                  dense: true,
                                  value: embeddedTrackerPortForwarding.value,
                                  onChanged: (value) {
                                    embeddedTrackerPortForwarding.value = value == true;
                                  },
                                  title: Text(
                                    '对嵌入的 tracker 启用端口转发',
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  ),
                                ),
                              ],
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '磁盘 IO 类型（需要重启）',
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  ),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: diskIoType.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                ' 默认')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '内存映射文件')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '遵循 POSIX')),
                                      ],
                                      onChanged: (value) {
                                        diskIoType.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '磁盘 IO 读取模式',
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  ),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: diskIoReadMode.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '禁用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '启用操作系统缓存')),
                                      ],
                                      onChanged: (value) {
                                        diskIoReadMode.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('磁盘 IO 写入模式', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: diskIoWriteMode.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '禁用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '启用操作系统缓存')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                              title: Text('合并读写', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enablePieceExtentAffinity.value,
                              onChanged: (value) {
                                enablePieceExtentAffinity.value = value == true;
                              },
                              title: Text('启用相连文件块下载模式', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enableUploadSuggestions.value,
                              onChanged: (value) {
                                enableUploadSuggestions.value = value!;
                              },
                              title: Text('发送分块上传建议', style: TextStyle(color: shadColorScheme.foreground)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('μTP-TCP 混合模式策略', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: utpTcpMixedMode.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '优先使用TCP')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                              title: Text('支持国际化域名（IDN）', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: enableMultiConnectionsFromSameIp.value,
                              onChanged: (value) {
                                enableMultiConnectionsFromSameIp.value = value == true;
                              },
                              title: Text('允许来自同一 IP 地址的多个连接', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: validateHttpsTrackerCertificate.value,
                              onChanged: (value) {
                                validateHttpsTrackerCertificate.value = value == true;
                              },
                              title: Text('验证 HTTPS tracker 证书', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: ssrfMitigation.value,
                              onChanged: (value) {
                                ssrfMitigation.value = value == true;
                              },
                              title: Text('服务器端请求伪造（SSRF）攻击缓解', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: blockPeersOnPrivilegedPorts.value,
                              onChanged: (value) {
                                blockPeersOnPrivilegedPorts.value = value == true;
                              },
                              title: Text('禁止连接到特权端口上的 Peer', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('上传窗口策略', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: uploadSlotsBehavior.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                ' 固定窗口数')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '基于上传速度')),
                                      ],
                                      onChanged: (value) {
                                        uploadSlotsBehavior.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('上传连接策略', style: TextStyle(color: shadColorScheme.foreground)),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: uploadChokingAlgorithm.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 0,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '轮流上传')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '最快上传')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
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
                              title: Text('总是向同级的所有 Tracker 汇报', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              dense: true,
                              value: announceToAllTiers.value,
                              onChanged: (value) {
                                announceToAllTiers.value = value == true;
                              },
                              title: Text('总是向所有等级的 Tracker 汇报', style: TextStyle(color: shadColorScheme.foreground)),
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
            floatingActionButton: ShadIconButton.ghost(
              onPressed: () async {
                QbittorrentPreferences prefs = controller.currentPrefs.copyWith(
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
                  blockPeersOnPrivilegedPorts: blockPeersOnPrivilegedPorts.value,
                  bypassAuthSubnetWhitelist: bypassAuthSubnetWhitelistController.text,
                  bypassAuthSubnetWhitelistEnabled: bypassAuthSubnetWhitelistEnabled.value,
                  bypassLocalAuth: bypassLocalAuth.value,
                  categoryChangedTmmEnabled: categoryChangedTmmEnabled.value,
                  checkingMemoryUse: int.parse(checkingMemoryUseController.text),
                  connectionSpeed: int.parse(connectionSpeedController.text),
                  currentInterfaceAddress: currentInterfaceAddress.value,
                  currentNetworkInterface: currentNetworkInterface.value,
                  dht: dht.value,
                  diskCache: int.parse(diskCacheController.text),
                  diskCacheTtl: int.parse(diskCacheTtlController.text),
                  diskIoReadMode: diskIoReadMode.value,
                  diskIoType: diskIoType.value,
                  diskIoWriteMode: diskIoWriteMode.value,
                  diskQueueSize: int.parse(diskQueueSizeController.text) * 1024,
                  dlLimit: int.parse(dlLimitController.text) * 1024,
                  dontCountSlowTorrents: dontCountSlowTorrents.value,
                  dyndnsDomain: dyndnsDomainController.text,
                  dyndnsEnabled: dyndnsEnabled.value,
                  dyndnsPassword: dyndnsPasswordController.text,
                  dyndnsService: dyndnsService.value,
                  dyndnsUsername: dyndnsUsernameController.text,
                  embeddedTrackerPort: int.parse(embeddedTrackerPortController.text),
                  embeddedTrackerPortForwarding: embeddedTrackerPortForwarding.value,
                  enableCoalesceReadWrite: enableCoalesceReadWrite.value,
                  enableEmbeddedTracker: enableEmbeddedTracker.value,
                  enableMultiConnectionsFromSameIp: enableMultiConnectionsFromSameIp.value,
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
                  maxActiveCheckingTorrents: int.parse(maxActiveCheckingTorrentsController.text),
                  maxActiveDownloads: int.parse(maxActiveDownloadsController.text),
                  maxActiveTorrents: int.parse(maxActiveTorrentsController.text),
                  maxActiveUploads: int.parse(maxActiveUploadsController.text),
                  maxConnec: int.parse(maxConnecController.text),
                  maxConnecPerTorrent: int.parse(maxConnecPerTorrentController.text),
                  maxConcurrentHttpAnnounces: int.parse(maxConcurrentHttpAnnouncesController.text),
                  maxRatio: double.parse(maxRatioController.text),
                  maxRatioAct: maxRatioAct.value,
                  maxRatioEnabled: maxRatioEnabled.value,
                  maxSeedingTime: int.parse(maxSeedingTimeController.text),
                  maxSeedingTimeEnabled: maxSeedingTimeEnabled.value,
                  maxUploads: int.parse(maxUploadsController.text),
                  maxUploadsPerTorrent: int.parse(maxUploadsPerTorrentController.text),
                  memoryWorkingSetLimit: int.parse(memoryWorkingSetLimitController.text),
                  outgoingPortsMax: int.parse(outgoingPortsMaxController.text),
                  outgoingPortsMin: int.parse(outgoingPortsMinController.text),
                  peerTos: int.parse(peerTosController.text),
                  peerTurnover: int.parse(peerTurnoverController.text),
                  peerTurnoverCutoff: int.parse(peerTurnoverCutoffController.text),
                  peerTurnoverInterval: int.parse(peerTurnoverIntervalController.text),
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
                  reannounceWhenAddressChanged: reannounceWhenAddressChanged.value,
                  recheckCompletedTorrents: recheckCompletedTorrents.value,
                  refreshInterval: int.parse(refreshIntervalController.text),
                  requestQueueSize: int.parse(requestQueueSizeController.text),
                  resolvePeerCountries: resolvePeerCountries.value,
                  resumeDataStorageType: resumeDataStorageType.value,
                  rssAutoDownloadingEnabled: rssAutoDownloadingEnabled.value,
                  rssDownloadRepackProperEpisodes: rssDownloadRepackProperEpisodes.value,
                  rssMaxArticlesPerFeed: int.parse(rssMaxArticlesPerFeedController.text),
                  rssProcessingEnabled: rssProcessingEnabled.value,
                  rssRefreshInterval: int.parse(rssRefreshIntervalController.text),
                  rssSmartEpisodeFilters: rssSmartEpisodeFiltersController.text,
                  savePath: savePathController.text,
                  savePathChangedTmmEnabled: savePathChangedTmmEnabled.value,
                  saveResumeDataInterval: int.parse(saveResumeDataIntervalController.text),
                  scheduleFromHour: int.parse(scheduleFromHourController.text),
                  scheduleFromMin: int.parse(scheduleFromMinController.text),
                  scheduleToHour: int.parse(scheduleToHourController.text),
                  scheduleToMin: int.parse(scheduleToMinController.text),
                  schedulerDays: schedulerDays.value,
                  schedulerEnabled: schedulerEnabled.value,
                  sendBufferLowWatermark: int.parse(sendBufferLowWatermarkController.text),
                  sendBufferWatermark: int.parse(sendBufferWatermarkController.text),
                  sendBufferWatermarkFactor: int.parse(sendBufferWatermarkFactorController.text),
                  slowTorrentDlRateThreshold: int.parse(slowTorrentDlRateThresholdController.text),
                  slowTorrentInactiveTimer: int.parse(slowTorrentInactiveTimerController.text),
                  slowTorrentUlRateThreshold: int.parse(slowTorrentUlRateThresholdController.text),
                  socketBacklogSize: int.parse(socketBacklogSizeController.text),
                  ssrfMitigation: ssrfMitigation.value,
                  startPausedEnabled: startPausedEnabled.value,
                  stopTrackerTimeout: int.parse(stopTrackerTimeoutController.text),
                  tempPath: tempPathController.text,
                  tempPathEnabled: tempPathEnabled.value,
                  torrentChangedTmmEnabled: torrentChangedTmmEnabled.value,
                  torrentContentLayout: torrentContentLayoutController.text,
                  torrentStopCondition: torrentStopCondition.value,
                  upLimit: int.parse(upLimitController.text) * 1024,
                  uploadChokingAlgorithm: uploadChokingAlgorithm.value,
                  uploadSlotsBehavior: uploadSlotsBehavior.value,
                  upnp: upnp.value,
                  useCategoryPathsInManualMode: useCategoryPathsInManualMode.value,
                  useHttps: useHttps.value,
                  utpTcpMixedMode: utpTcpMixedMode.value,
                  validateHttpsTrackerCertificate: validateHttpsTrackerCertificate.value,
                  webUiAddress: webUiAddressController.text,
                  webUiBanDuration: int.parse(webUiBanDurationController.text),
                  webUiClickjackingProtectionEnabled: webUiClickjackingProtectionEnabled.value,
                  webUiCsrfProtectionEnabled: webUiCsrfProtectionEnabled.value,
                  webUiCustomHttpHeaders: webUiCustomHttpHeadersController.text,
                  webUiDomainList: webUiDomainListController.text,
                  webUiHostHeaderValidationEnabled: webUiHostHeaderValidationEnabled.value,
                  webUiHttpsCertPath: webUiHttpsCertPathController.text,
                  webUiHttpsKeyPath: webUiHttpsKeyPathController.text,
                  webUiMaxAuthFailCount: int.parse(webUiMaxAuthFailCountController.text),
                  webUiPort: int.parse(webUiPortController.text),
                  webUiReverseProxiesList: webUiReverseProxiesListController.text,
                  webUiReverseProxyEnabled: webUiReverseProxyEnabled.value,
                  webUiSecureCookieEnabled: webUiSecureCookieEnabled.value,
                  webUiSessionTimeout: int.parse(webUiSessionTimeoutController.text),
                  webUiUpnp: webUiUpnp.value,
                  webUiUseCustomHttpHeadersEnabled: webUiUseCustomHttpHeadersEnabled.value,
                  webUiUsername: webUiUsernameController.text,
                );

                CommonResponse response = await controller.setPrefs(downloader, prefs);
                if (!response.succeed) {
                  Get.snackbar('修改配置失败', response.msg);
                } else {
                  controller.getDownloaderListFromServer();
                }
                Get.back();
              },
              icon: Icon(
                Icons.save_outlined,
                size: 24,
                color: shadColorScheme.primary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showTrPrefs(Downloader downloader, context) async {
    const List<Tab> tabs = [
      Tab(text: '下载设置'),
      Tab(text: '网络设置'),
      Tab(text: '带宽设置'),
      Tab(text: '队列设置'),
    ];
    var response = await controller.getPrefs(downloader);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (!response.succeed) {
      Get.snackbar('出错啦！', '获取下载器设置失败', colorText: shadColorScheme.destructive);
      return;
    }
    controller.currentPrefs = TransmissionConfig.fromJson(response.data);
    controller.update();
    // 限速开关
    RxBool altSpeedEnabled = RxBool(controller.currentPrefs.altSpeedEnabled);
    // 自动按时间限速开关
    RxBool altSpeedTimeEnabled = RxBool(controller.currentPrefs.altSpeedTimeEnabled);
    // 黑名单开关
    RxBool blocklistEnabled = RxBool(controller.currentPrefs.blocklistEnabled);
    // RxBool startAddedTorrents =
    //     RxBool(controller.currentPrefs.startAddedTorrents);
    // 分布式 HASH 表
    RxBool dhtEnabled = RxBool(controller.currentPrefs.dhtEnabled);
    // 下载队列开关
    RxBool downloadQueueEnabled = RxBool(controller.currentPrefs.downloadQueueEnabled);
    // 种子超时无流量移出队列开关
    RxBool idleSeedingLimitEnabled = RxBool(controller.currentPrefs.idleSeedingLimitEnabled);
    // 临时目录开关
    RxBool incompleteDirEnabled = RxBool(controller.currentPrefs.incompleteDirEnabled);
    // 允许本地对等点发现
    RxBool lpdEnabled = RxBool(controller.currentPrefs.lpdEnabled);
    // 端口转发开关
    RxBool portForwardingEnabled = RxBool(controller.currentPrefs.portForwardingEnabled);
    // PEX开关
    RxBool pexEnabled = RxBool(controller.currentPrefs.pexEnabled);
    RxBool peerPortRandomOnStart = RxBool(controller.currentPrefs.peerPortRandomOnStart);
    // 队列等待开关
    RxBool queueStalledEnabled = RxBool(controller.currentPrefs.queueStalledEnabled);
    // 种子做种队列开关
    RxBool seedQueueEnabled = RxBool(controller.currentPrefs.seedQueueEnabled);
    // 未完成种子添加 part
    RxBool renamePartialFiles = RxBool(controller.currentPrefs.renamePartialFiles);
    // 种子上传限速开关
    RxBool speedLimitUpEnabled = RxBool(controller.currentPrefs.speedLimitUpEnabled);
    RxBool seedRatioLimited = RxBool(controller.currentPrefs.seedRatioLimited);
    // 种子下载限速开关
    RxBool speedLimitDownEnabled = RxBool(controller.currentPrefs.speedLimitDownEnabled);
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
    TextEditingController seedRatioLimitController =
        TextEditingController(text: controller.currentPrefs.seedRatioLimit.toString());
    TextEditingController altSpeedDownController =
        TextEditingController(text: controller.currentPrefs.altSpeedDown.toString());
    TextEditingController altSpeedTimeBeginController =
        TextEditingController(text: controller.currentPrefs.altSpeedTimeBegin.toString());
    RxInt altSpeedTimeDay = RxInt(controller.currentPrefs.altSpeedTimeDay);
    TextEditingController altSpeedTimeEndController =
        TextEditingController(text: controller.currentPrefs.altSpeedTimeEnd.toString());
    TextEditingController altSpeedUpController =
        TextEditingController(text: controller.currentPrefs.altSpeedUp.toString());
    RxInt blocklistSize = RxInt(controller.currentPrefs.blocklistSize);
    TextEditingController cacheSizeMbController =
        TextEditingController(text: controller.currentPrefs.cacheSizeMb.toString());
    // TextEditingController downloadDirFreeSpaceController =
    //     TextEditingController(
    //         text: controller.currentPrefs.downloadDirFreeSpace.toString());
    TextEditingController downloadQueueSizeController =
        TextEditingController(text: controller.currentPrefs.downloadQueueSize.toString());
    TextEditingController idleSeedingLimitController =
        TextEditingController(text: controller.currentPrefs.idleSeedingLimit.toString());
    TextEditingController peerLimitGlobalController =
        TextEditingController(text: controller.currentPrefs.peerLimitGlobal.toString());
    TextEditingController peerLimitPerTorrentController =
        TextEditingController(text: controller.currentPrefs.peerLimitPerTorrent.toString());
    TextEditingController peerPortController = TextEditingController(text: controller.currentPrefs.peerPort.toString());
    TextEditingController queueStalledMinutesController =
        TextEditingController(text: controller.currentPrefs.queueStalledMinutes.toString());
    // TextEditingController rpcVersionController = TextEditingController(
    //     text: controller.currentPrefs.rpcVersion.toString());
    // TextEditingController rpcVersionMinimumController = TextEditingController(
    //     text: controller.currentPrefs.rpcVersionMinimum.toString());
    TextEditingController seedQueueSizeController =
        TextEditingController(text: controller.currentPrefs.seedQueueSize.toString());
    TextEditingController speedLimitDownController =
        TextEditingController(text: controller.currentPrefs.speedLimitDown.toString());
    TextEditingController speedLimitUpController =
        TextEditingController(text: controller.currentPrefs.speedLimitUp.toString());

// String fields
    TextEditingController blocklistUrlController = TextEditingController(text: controller.currentPrefs.blocklistUrl);
    TextEditingController configDirController = TextEditingController(text: controller.currentPrefs.configDir);
    TextEditingController defaultTrackersController =
        TextEditingController(text: controller.currentPrefs.defaultTrackers);
    TextEditingController downloadDirController = TextEditingController(text: controller.currentPrefs.downloadDir);
    RxString encryption = RxString(controller.currentPrefs.encryption);
    TextEditingController incompleteDirController = TextEditingController(text: controller.currentPrefs.incompleteDir);
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

    RxList<MetaDataItem> daysOfWeek = RxList(['星期天', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六']
        .asMap()
        .entries
        .map((item) => MetaDataItem(name: item.value, value: pow(2, item.key)))
        .toList());
    RxList<int> daysOfWeekMask = RxList(TransmissionUtils.getEnabledDaysFromAltSpeedTimeDay(altSpeedTimeDay.value));
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
              backgroundColor: shadColorScheme.background,
              appBar: AppBar(
                title: Text('配置选项', style: TextStyle(color: shadColorScheme.foreground)),
                backgroundColor: shadColorScheme.background,
                bottom: TabBar(
                  tabs: tabs,
                  isScrollable: true,
                  labelColor: shadColorScheme.foreground,
                  labelStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TabBarView(children: [
                  ListView(
                    children: [
                      Obx(() {
                        return Column(
                          children: [
                            CustomTextField(controller: downloadDirController, labelText: '默认保存目录'),
                            CheckboxListTile(
                              value: renamePartialFiles.value,
                              onChanged: (value) {
                                renamePartialFiles.value = value == true;
                              },
                              title:
                                  Text('在未完成的文件名后加上 “.part” 后缀', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            CheckboxListTile(
                              value: incompleteDirEnabled.value,
                              onChanged: (value) {
                                incompleteDirEnabled.value = value == true;
                              },
                              title: Text(
                                '启用临时目录',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
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
                              title: Text(
                                '默认分享率上限',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            if (seedRatioLimited.value)
                              CustomTextField(controller: seedRatioLimitController, labelText: '默认分享率上限'),
                            CheckboxListTile(
                              value: idleSeedingLimitEnabled.value,
                              onChanged: (value) {
                                idleSeedingLimitEnabled.value = value == true;
                              },
                              title: Text(
                                '默认停止无流量种子',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            if (idleSeedingLimitEnabled.value)
                              CustomTextField(controller: idleSeedingLimitController, labelText: '默认停止无流量种子持续时间(分钟)'),
                            CustomTextField(controller: cacheSizeMbController, labelText: '磁盘缓存大小（MB）'),
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
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Row(
                                children: [
                                  Expanded(child: CustomPortField(controller: peerPortController, labelText: '连接端口号')),
                                  ShadButton.outline(
                                    size: ShadButtonSize.sm,
                                    onPressed: null,
                                    child: Text(
                                      '测试端口',
                                      style: TextStyle(color: shadColorScheme.foreground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CheckboxListTile(
                              value: peerPortRandomOnStart.value,
                              onChanged: (value) {
                                peerPortRandomOnStart.value = value == true;
                              },
                              title: Text(
                                '启用随机端口',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            CheckboxListTile(
                              value: portForwardingEnabled.value,
                              onChanged: (value) {
                                portForwardingEnabled.value = value == true;
                              },
                              title: Text(
                                '启用端口转发 (UPnP)',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '加密',
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  ),
                                  DropdownButton(
                                      dropdownColor: shadColorScheme.background,
                                      isDense: true,
                                      value: encryption.value,
                                      items: [
                                        DropdownMenuItem(
                                            value: 'tolerated',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '允许加密')),
                                        DropdownMenuItem(
                                            value: 'preferred',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '优先加密')),
                                        DropdownMenuItem(
                                            value: 'required',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                ' 强制加密')),
                                      ],
                                      onChanged: (value) {
                                        encryption.value = value!;
                                      }),
                                ],
                              ),
                            ),
                            CustomTextField(controller: peerLimitGlobalController, labelText: '全局最大链接数'),
                            CustomTextField(controller: peerLimitPerTorrentController, labelText: '单种最大链接数'),
                            CheckboxListTile(
                              value: pexEnabled.value,
                              onChanged: (value) {
                                pexEnabled.value = value == true;
                              },
                              title: Text(
                                '启用本地用户交换',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            CheckboxListTile(
                              value: lpdEnabled.value,
                              onChanged: (value) {
                                lpdEnabled.value = value == true;
                              },
                              title: Text(
                                '对等交换',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            CheckboxListTile(
                              value: dhtEnabled.value,
                              onChanged: (value) {
                                dhtEnabled.value = value == true;
                              },
                              title: Text(
                                '启用分布式哈希表 (DHT)',
                                style: TextStyle(color: shadColorScheme.foreground),
                              ),
                            ),
                            CheckboxListTile(
                              value: blocklistEnabled.value,
                              onChanged: (value) {
                                blocklistEnabled.value = value == true;
                              },
                              title: Text('启用黑名单列表:', style: TextStyle(color: shadColorScheme.foreground)),
                            ),
                            if (blocklistEnabled.value)
                              Column(
                                children: [
                                  CustomTextField(controller: blocklistUrlController, labelText: '黑名单列表'),
                                  ShadButton(
                                    size: ShadButtonSize.sm,
                                    onPressed: null,
                                    child: Text(
                                        style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                        '更新黑名单【$blocklistSize】'),
                                  ),
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
                          title: Text(
                            '最大下载速度 (KB/s):',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ),
                        ),
                        if (speedLimitDownEnabled.value)
                          Column(
                            children: [
                              CustomNumberField(controller: speedLimitDownController, labelText: '正常最大下载速度(KB/s)'),
                              CustomNumberField(controller: altSpeedDownController, labelText: '备用最大下载速度(KB/s)'),
                            ],
                          ),
                        CheckboxListTile(
                          value: speedLimitUpEnabled.value,
                          onChanged: (value) {
                            speedLimitUpEnabled.value = value == true;
                          },
                          title: Text(
                            '最大上传速度 (KB/s):',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ),
                        ),
                        if (speedLimitUpEnabled.value)
                          Column(
                            children: [
                              CustomNumberField(controller: speedLimitUpController, labelText: '正常最大上传速度(KB/s)'),
                              CustomNumberField(controller: altSpeedUpController, labelText: '备用最大上传速度(KB/s)'),
                            ],
                          ),
                        CheckboxListTile(
                          value: altSpeedEnabled.value,
                          onChanged: (value) {
                            altSpeedEnabled.value = value == true;
                          },
                          title: Text(
                            '启用备用带宽',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ),
                        ),
                        CheckboxListTile(
                          value: altSpeedTimeEnabled.value,
                          onChanged: (value) {
                            altSpeedTimeEnabled.value = value == true;
                          },
                          title: Text(
                            '自动启用备用带宽设置 (时间段内)',
                            style: TextStyle(color: shadColorScheme.foreground),
                          ),
                        ),
                        if (altSpeedTimeEnabled.value)
                          Obx(() {
                            return Column(
                              children: [
                                CustomTextField(controller: altSpeedTimeBeginController, labelText: '自动启用备用带宽设置开始时间'),
                                CustomTextField(controller: altSpeedTimeEndController, labelText: '自动启用备用带宽设置结束时间'),
                                Text('${altSpeedTimeDay.value}'),
                                Obx(() {
                                  return Wrap(
                                    children: [
                                      ...daysOfWeek.map(
                                        (item) => CheckboxListTile(
                                          value: daysOfWeekMask.contains(item.value),
                                          onChanged: (value) {
                                            logger_helper.Logger.instance.d(value);
                                            if (value == true) {
                                              altSpeedTimeDay.value = (altSpeedTimeDay.value + item.value).toInt();
                                            } else {
                                              altSpeedTimeDay.value = (altSpeedTimeDay.value - item.value).toInt();
                                            }
                                            daysOfWeekMask.value = TransmissionUtils.getEnabledDaysFromAltSpeedTimeDay(
                                                altSpeedTimeDay.value);
                                            logger_helper.Logger.instance.d(daysOfWeekMask);
                                          },
                                          title: Text(
                                            item.name,
                                            style: TextStyle(color: shadColorScheme.foreground),
                                          ),
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
                        title: Text(
                          '启用下载队列，最大同时下载数',
                          style: TextStyle(color: shadColorScheme.foreground),
                        ),
                      ),
                      if (downloadQueueEnabled.value)
                        CustomTextField(controller: downloadQueueSizeController, labelText: '启用下载队列，最大同时下载数'),
                      CheckboxListTile(
                        value: seedQueueEnabled.value,
                        onChanged: (value) {
                          seedQueueEnabled.value = value == true;
                        },
                        title: Text(
                          '启用上传队列，最大同时上传数',
                          style: TextStyle(color: shadColorScheme.foreground),
                        ),
                      ),
                      if (seedQueueEnabled.value)
                        CustomTextField(controller: seedQueueSizeController, labelText: '启用上传队列，最大同时上传数'),
                      CheckboxListTile(
                        value: queueStalledEnabled.value,
                        onChanged: (value) {
                          queueStalledEnabled.value = value == true;
                        },
                        title: Text(
                          '种子超过该时间无流量，移出队列',
                          style: TextStyle(color: shadColorScheme.foreground),
                        ),
                      ),
                      if (queueStalledEnabled.value)
                        CustomTextField(controller: queueStalledMinutesController, labelText: '种子超过该时间无流量，移出队列(分钟)'),
                    ]);
                  }),
                ]),
              ),
              floatingActionButton: ShadIconButton(
                onPressed: () async {
                  TransmissionConfig prefs = controller.currentPrefs.copyWith(
                    altSpeedDown: int.parse(altSpeedDownController.text),
                    altSpeedEnabled: altSpeedEnabled.value,
                    altSpeedTimeBegin: int.parse(altSpeedTimeBeginController.text),
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
                    downloadQueueSize: int.parse(downloadQueueSizeController.text),
                    encryption: encryption.value,
                    idleSeedingLimit: int.parse(idleSeedingLimitController.text),
                    idleSeedingLimitEnabled: idleSeedingLimitEnabled.value,
                    incompleteDir: incompleteDirController.text,
                    incompleteDirEnabled: incompleteDirEnabled.value,
                    lpdEnabled: lpdEnabled.value,
                    peerLimitGlobal: int.parse(peerLimitGlobalController.text),
                    peerLimitPerTorrent: int.parse(peerLimitPerTorrentController.text),
                    peerPort: int.parse(peerPortController.text),
                    peerPortRandomOnStart: peerPortRandomOnStart.value,
                    pexEnabled: pexEnabled.value,
                    portForwardingEnabled: portForwardingEnabled.value,
                    queueStalledEnabled: queueStalledEnabled.value,
                    queueStalledMinutes: int.parse(queueStalledMinutesController.text),
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
                  CommonResponse response = await controller.setPrefs(downloader, prefs);
                  if (!response.succeed) {
                    Get.snackbar('修改配置失败', response.msg);
                  } else {
                    controller.getDownloaderListFromServer();
                  }
                  Get.back();
                },
                icon: Icon(
                  Icons.save_outlined,
                  size: 24,
                  color: shadColorScheme.primary,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  ///@title 移除红种
  ///@description 移除红种
  ///@updateTime
  Future<void> removeQbErrorTracker(Downloader downloader) async {
    try {
      List<String> toRemoveTorrentList = [];
      var groupedTorrents = groupBy(controller.torrents, (t) => t.contentPath);
      for (var group in groupedTorrents.values) {
        var hasTracker = group.any((t) => t.tracker?.isNotEmpty == true);
        if (!hasTracker) {
          group.sort((t1, t2) => t2.progress!.compareTo(t1.progress!));
          toRemoveTorrentList.addAll(group.skip(1).map((t) => t.hash!));
        } else {
          toRemoveTorrentList.addAll(group.where((element) => element.tracker!.isEmpty).map((t) => t.hash!));
        }
      }

      logger_helper.Logger.instance.i(toRemoveTorrentList);
      logger_helper.Logger.instance.i(toRemoveTorrentList.length);
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      if (toRemoveTorrentList.isEmpty) {
        Get.snackbar('清理红种', '没有需要清理的种子！', colorText: shadColorScheme.foreground);
        return;
      }

      Get.defaultDialog(
        title: '确认',
        radius: 5,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
        middleText: '共检测到${toRemoveTorrentList.length}条可删除红种，确定要删除种子吗？',
        actions: [
          ShadButton(
            size: ShadButtonSize.sm,
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('取消'),
          ),
          ShadButton(
            size: ShadButtonSize.sm,
            onPressed: () async {
              Get.back(result: true);
              CommonResponse res = await controller.controlQbTorrents(
                  downloader: downloader, command: 'delete', hashes: toRemoveTorrentList, enable: false);
              if (res.succeed) {
                controller.showTorrents.removeWhere((element) => toRemoveTorrentList.contains(element.hash));
                String msg = '清理出错种子成功，本次共清理${toRemoveTorrentList.length}个种子！';
                Get.snackbar('删除通知', msg, colorText: shadColorScheme.foreground);
                controller.update();
              }
            },
            child: const Text('确认'),
          ),
        ],
      );
    } catch (e) {
      logger_helper.Logger.instance.e('出错啦！${e.toString()}');
    }
  }

  Future removeTrErrorTracker(Downloader downloader) async {
    try {
      List<String> toRemoveTorrentList = [];
      var groupedTorrents = groupBy(controller.torrents, (t) => t.name);
      for (var group in groupedTorrents.values) {
        var hasTracker = group.any((t) => t.error != 2);
        if (!hasTracker) {
          group.sort((t1, t2) => t2.percentDone.compareTo(t1.percentDone));
          toRemoveTorrentList.addAll(group.skip(1).map((t) => t.hashString));
        } else {
          toRemoveTorrentList.addAll(group.where((element) => element.error == 2).map((t) => t.hashString));
        }
      }

      logger_helper.Logger.instance.i(toRemoveTorrentList);
      logger_helper.Logger.instance.i(toRemoveTorrentList.length);
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      if (toRemoveTorrentList.isEmpty) {
        Get.snackbar('清理红种', '没有需要清理的种子！', colorText: shadColorScheme.foreground);
        return;
      }
      Get.defaultDialog(
        title: '确认',
        radius: 5,
        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
        middleText: '共检测到${toRemoveTorrentList.length}条可删除红种，确定要删除种子吗？',
        actions: [
          ShadButton.destructive(
            size: ShadButtonSize.sm,
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text('取消'),
          ),
          ShadButton(
            size: ShadButtonSize.sm,
            onPressed: () async {
              Get.back(result: true);
              CommonResponse res = await controller.controlTrTorrents(
                  downloader: downloader, command: 'remove_torrent', ids: toRemoveTorrentList, enable: false);
              if (res.succeed) {
                controller.showTorrents.removeWhere((element) => toRemoveTorrentList.contains(element.hashString));
                String msg = '清理出错种子成功，本次共清理${toRemoveTorrentList.length}个种子！';
                Get.snackbar('删除通知', msg, colorText: shadColorScheme.foreground);
                controller.update();
              }
            },
            child: const Text('确认'),
          ),
        ],
      );
    } catch (e) {
      logger_helper.Logger.instance.e('出错啦！${e.toString()}');
      return CommonResponse.error(msg: '清理出错种子失败！${e.toString()}');
    }
  }
}

class ShowTorrentWidget extends StatelessWidget {
  final Downloader downloader;
  final dynamic torrentInfo;
  final DownloadController controller;

  const ShowTorrentWidget({
    super.key,
    required this.downloader,
    required this.torrentInfo,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return downloader.category == 'Qb'
        ? _showQbTorrent(downloader, torrentInfo, context)
        : _showTrTorrent(downloader, torrentInfo, context);
  }

  GetBuilder<DownloadController> _showQbTorrent(Downloader downloader, QbittorrentTorrentInfo torrentInfo, context) {
    RxBool paused = torrentInfo.state.toString().contains('pause').obs;
    RxBool autoTmm = torrentInfo.autoTmm.obs;

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<DownloadController>(
        id: '${downloader.host} - ${downloader.port} - ${torrentInfo.hash}',
        builder: (controller) {
          return CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: GetBuilder<DownloadController>(builder: (controller) {
              return Slidable(
                key: ValueKey(torrentInfo.infohashV1),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.5,
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
                            ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: const Text('取消'),
                            ),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                Get.back(result: true);
                                CommonResponse res = await controller.controlQbTorrents(
                                    downloader: downloader,
                                    command: 'delete',
                                    hashes: [torrentInfo.hash],
                                    enable: deleteFiles.value);
                                if (res.succeed) {
                                  controller.showTorrents.removeWhere((element) => element.hash == torrentInfo.hash);
                                  controller.update();
                                }
                              },
                              child: const Text('删除'),
                            )
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
                        await controller.controlQbTorrents(
                          command: paused.value ? 'resume' : 'pause',
                          hashes: [torrentInfo.infohashV1],
                          downloader: downloader,
                        );
                      },
                      flex: 2,
                      backgroundColor: paused.value ? const Color(0xFF0392CF) : Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      icon: paused.value ? Icons.play_arrow : Icons.pause,
                      label: paused.value ? '开始' : '暂停',
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
                        size: 18,
                        Icons.stop_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('停止'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        torrentInfo.forceStart ? Icons.double_arrow : Icons.play_arrow,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('强制启动'),
                      onPressed: () => controller.controlQbTorrents(
                          downloader: downloader,
                          command: 'set_force_start',
                          hashes: [torrentInfo.infohashV1],
                          enable: !torrentInfo.forceStart),
                    ),
                    // ShadContextMenuItem(
                    //   leading: Icon(
                    //     size: 18,
                    //     Icons.delete_outline,
                    //     color: shadColorScheme.foreground,
                    //   ),
                    //   child: Text('删除'),
                    //   onPressed: () {},
                    // ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.edit_location_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('更改保存位置'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.drive_file_rename_outline_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('重命名'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.drive_file_rename_outline,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('重命名文件'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.category_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      items: [
                        ...controller.categoryMap.values.map((value) => ShadContextMenuItem(
                              leading: Icon(
                                size: 18,
                                value?.name == torrentInfo.category ||
                                        (torrentInfo.category == '' && value?.name == '未分类')
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank_outlined,
                                color: shadColorScheme.foreground,
                              ),
                              onPressed: () => controller.controlQbTorrents(
                                downloader: downloader,
                                command: 'set_category',
                                hashes: [torrentInfo.hash],
                                category: value.name != '未分类' ? value.name! : '',
                              ),
                              child: Text(value!.name!),
                            )),
                      ],
                      child: Text('分类'),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.tag_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      items: [
                        ...controller.tags.where((item) => item != '全部').map((value) => ShadContextMenuItem(
                              leading: Icon(
                                size: 18,
                                torrentInfo.tags.contains(value)
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank_outlined,
                                color: shadColorScheme.foreground,
                              ),
                              onPressed: () => controller.controlQbTorrents(
                                downloader: downloader,
                                command: !torrentInfo.tags.contains(value) ? 'add_tags' : 'remove_tags',
                                hashes: [torrentInfo.hash],
                                tag: value,
                              ),
                              child: Text(value),
                            ))
                      ],
                      child: Text('标签'),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.copy_rounded,
                        color: shadColorScheme.foreground,
                      ),
                      items: [
                        ShadContextMenuItem(
                          leading: Icon(
                            size: 18,
                            Icons.copy_rounded,
                            color: shadColorScheme.foreground,
                          ),
                          child: Text('名称'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: torrentInfo.name));
                            Get.snackbar('复制种子名称', '种子名称复制成功！', colorText: shadColorScheme.foreground);
                          },
                        ),
                        ShadContextMenuItem(
                          leading: Icon(
                            size: 18,
                            Icons.copy_rounded,
                            color: shadColorScheme.foreground,
                          ),
                          child: Text('哈希'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: torrentInfo.infohashV1));
                            Get.snackbar('复制种子HASH', '种子HASH复制成功！', colorText: shadColorScheme.foreground);
                          },
                        ),
                        ShadContextMenuItem(
                          leading: Icon(
                            size: 18,
                            Icons.copy_rounded,
                            color: shadColorScheme.foreground,
                          ),
                          child: Text('磁力链接'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: torrentInfo.magnetUri));
                            Get.snackbar('复制种子磁力链接', '种子磁力链接复制成功！', colorText: shadColorScheme.foreground);
                          },
                        ),
                        // ShadContextMenuItem(
                        //   child: Text('Torrent ID'),
                        //   onPressed: () {},
                        // ),
                        ShadContextMenuItem(
                          leading: Icon(
                            size: 18,
                            Icons.copy_rounded,
                            color: shadColorScheme.foreground,
                          ),
                          child: Text('Tracker 地址'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: torrentInfo.tracker));
                            Get.snackbar('复制种子Tracker', '种子Tracker复制成功！', colorText: shadColorScheme.foreground);
                          },
                        ),
                        ShadContextMenuItem(
                          leading: Icon(
                            size: 18,
                            Icons.copy_rounded,
                            color: shadColorScheme.foreground,
                          ),
                          child: Text('注释'),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: torrentInfo.comment));
                            Get.snackbar('复制种子Tracker', '种子Tracker复制成功！', colorText: shadColorScheme.foreground);
                          },
                        ),
                      ],
                      child: Text('复制'),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        torrentInfo.autoTmm ? Icons.check_box_outlined : Icons.motion_photos_auto_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('自动管理'),
                      onPressed: () => controller.controlQbTorrents(
                          downloader: downloader,
                          command: 'set_auto_management',
                          hashes: [torrentInfo.infohashV1],
                          enable: !torrentInfo.autoTmm),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.upload_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('限制上传速度'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.mobile_screen_share,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('限制分享率'),
                      onPressed: () {},
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        torrentInfo.superSeeding
                            ? Icons.keyboard_double_arrow_up_outlined
                            : Icons.keyboard_arrow_up_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('超级做种'),
                      onPressed: () => controller.controlQbTorrents(
                          downloader: downloader,
                          command: 'set_super_seeding',
                          hashes: [torrentInfo.infohashV1],
                          enable: !torrentInfo.superSeeding),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.fact_check,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('重新校验'),
                      onPressed: () => Get.defaultDialog(
                        title: '',
                        middleText: '重新校验种子？',
                        actions: [
                          ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            onPressed: () {
                              Get.back(result: false);
                            },
                            child: const Text('取消'),
                          ),
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () async {
                              // 重新校验种子
                              Get.back(result: true);
                              await controller.controlQbTorrents(
                                  downloader: downloader, command: 'recheck', hashes: [torrentInfo.infohashV1]);
                            },
                            child: const Text('确认'),
                          ),
                        ],
                      ),
                    ),
                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.announcement_outlined,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('重新汇报'),
                      onPressed: () => controller.controlQbTorrents(
                          downloader: downloader, command: 'reannounce', hashes: [torrentInfo.infohashV1]),
                    ),

                    ShadContextMenuItem(
                      leading: Icon(
                        size: 18,
                        Icons.import_export,
                        color: shadColorScheme.foreground,
                      ),
                      child: Text('导出.torrent'),
                      onPressed: () {},
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (controller.showDetails) {
                              controller.showDetails = false;
                              // 只更新当前下载器窗口内容
                              controller.update(["${downloader.host} - ${downloader.port} - torrentList"]);
                              if (controller.selectedTorrent?.hash == torrentInfo.hash) {
                                controller.selectedTorrent = null;
                                controller.selectedTorrentTrackers.clear();
                                controller.selectedTorrentContents.clear();
                                controller.update(['${downloader.host} - ${downloader.port} - ${torrentInfo.hash}']);
                                return;
                              }
                            }

                            CommonResponse response = await controller.getDownloaderTorrentDetailInfo(
                                downloader, torrentInfo.infohashV1, true);
                            if (!response.succeed) {
                              Get.snackbar('获取种子详情失败', response.msg);
                              return;
                            }

                            controller.selectedTorrentContents = response.data['files']
                                .map<qb.TorrentContents>((item) => qb.TorrentContents.fromJson(item))
                                .toList();

                            controller.selectedTorrentTrackers = (response.data['trackers'] as List)
                                .map<qb.Tracker>((item) => qb.Tracker.fromJson(item as Map<String, dynamic>))
                                .toList();
                            controller.selectTab = 'torrentInfo';
                            controller.showDetails = true;
                            controller.update(
                                ['${downloader.host} - ${downloader.port} - ${controller.selectedTorrent.hash}']);
                          },
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
                                                  .firstWhereOrNull(
                                                      (entry) => entry.value.contains(torrentInfo.infohashV1))
                                                  ?.key ??
                                              Uri.parse(torrentInfo.tracker).host,
                                          icon: const Icon(Icons.file_upload_outlined, size: 10, color: Colors.white),
                                        )
                                      : CustomTextTag(
                                          labelText: controller.trackers.entries
                                                  .firstWhereOrNull(
                                                      (entry) => entry.value.contains(torrentInfo.infohashV1))
                                                  ?.key ??
                                              (Uri.parse(torrentInfo.magnetUri).queryParametersAll["tr"]?.first != null
                                                  ? Uri.parse(Uri.parse(torrentInfo.magnetUri)
                                                          .queryParametersAll["tr"]!
                                                          .first)
                                                      .host
                                                  : "未知"),
                                          icon: const Icon(Icons.link_off, size: 10, color: Colors.white),
                                          backgroundColor: Colors.red,
                                        ),
                                  Text(
                                    controller.qBitStatus
                                        .firstWhere((element) => element.value == torrentInfo.state,
                                            orElse: () => MetaDataItem(name: "未知状态", value: qb.TorrentState.unknown))
                                        .name,
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                                  ),
                                  Text(
                                    FileSizeConvert.parseToFileSize(torrentInfo.size),
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                        style: TextStyle(fontSize: 11, color: shadColorScheme.foreground),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    torrentInfo.category.isNotEmpty ? torrentInfo.category : '未分类',
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                            Text('${FileSizeConvert.parseToFileSize(torrentInfo.upSpeed)}/s',
                                                style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.cloud_upload,
                                              size: 12,
                                            ),
                                            Text(FileSizeConvert.parseToFileSize(torrentInfo.uploaded),
                                                style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                            Text('${FileSizeConvert.parseToFileSize(torrentInfo.dlSpeed)}/s',
                                                style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.cloud_download,
                                              size: 12,
                                            ),
                                            Text(FileSizeConvert.parseToFileSize(torrentInfo.downloaded),
                                                style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                              text: formatDuration(torrentInfo.timeActive).toString(),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                                      DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedOn * 1000))
                                                  .toString(),
                                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 6),
                                child: ShadProgress(value: torrentInfo.progress),
                              ),
                            ],
                          ),
                        ),
                        if (controller.selectedTorrent?.hash == torrentInfo.hash && controller.showDetails)
                          GetBuilder<DownloadController>(
                              // id: '${downloader.host} - ${downloader.port} - ${controller.selectedTorrent.hash} - details',
                              builder: (controller) {
                            List<qb.Tracker> trackers = controller.selectedTorrentTrackers
                                .where((qb.Tracker element) => element.url?.startsWith('http') ?? false)
                                .toList();
                            var repeatTorrents = controller.torrents
                                .where((element) => element.contentPath == controller.selectedTorrent.contentPath)
                                .map((e) => MetaDataItem.fromJson({
                                      "name": controller.trackers.entries
                                          .firstWhere((entry) => entry.value.contains(e.infohashV1))
                                          .key,
                                      "value": e,
                                    }))
                                .map((e) => InputChip(
                                      labelPadding: EdgeInsets.zero,
                                      backgroundColor: e.value.tracker.isNotEmpty
                                          ? shadColorScheme.primary
                                          : shadColorScheme.destructive,
                                      deleteIconColor: e.value.tracker.isNotEmpty
                                          ? shadColorScheme.primaryForeground
                                          : shadColorScheme.destructiveForeground,
                                      elevation: 1,
                                      deleteButtonTooltipMessage: '删除种子',
                                      label: SizedBox(
                                        width: 52,
                                        child: Center(
                                          child: Text(
                                            e.name,
                                            style: TextStyle(
                                              color: e.value.tracker.isNotEmpty
                                                  ? shadColorScheme.primaryForeground
                                                  : shadColorScheme.destructiveForeground,
                                            ),
                                          ),
                                        ),
                                      ),
                                      avatar: e.value.tracker.isNotEmpty
                                          ? Icon(Icons.link, color: shadColorScheme.primaryForeground)
                                          : Icon(Icons.link_off, color: shadColorScheme.destructiveForeground),
                                      // onPressed: () async {
                                      // },
                                      onDeleted: () async {
                                        RxBool deleteFiles = false.obs;
                                        Get.defaultDialog(
                                          title: '确认',
                                          radius: 10,
                                          titleStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          middleText: '您确定要执行这个操作吗？',
                                          backgroundColor: shadColorScheme.background,
                                          content: Obx(() {
                                            return ShadSwitch(
                                              value: deleteFiles.value,
                                              onChanged: (v) => deleteFiles.value = v,
                                              label: const Text('是否删除种子文件？'),
                                            );
                                          }),
                                          actions: [
                                            ShadButton.destructive(
                                              size: ShadButtonSize.sm,
                                              onPressed: () {
                                                Get.back(result: false);
                                              },
                                              child: const Text('取消'),
                                            ),
                                            ShadButton(
                                              size: ShadButtonSize.sm,
                                              onPressed: () async {
                                                Get.back(result: true);
                                                CommonResponse res = await controller.controlQbTorrents(
                                                    downloader: downloader,
                                                    command: 'delete',
                                                    hashes: [e.value.hash],
                                                    enable: false);
                                                if (res.succeed) {
                                                  controller.showTorrents
                                                      .removeWhere((element) => element.hash == e.value.hash);
                                                  controller.update();
                                                } else {
                                                  Get.snackbar('删除通知', res.msg);
                                                }
                                              },
                                              child: const Text('删除'),
                                            )
                                          ],
                                        );
                                      },
                                    ))
                                .toList();

                            return Container(
                              height: 360,
                              padding: const EdgeInsets.only(top: 12),
                              child: ShadTabs(
                                value: controller.selectTab,
                                padding: EdgeInsets.zero,
                                tabBarConstraints: const BoxConstraints(maxWidth: 600, maxHeight: 40),
                                contentConstraints: const BoxConstraints(maxWidth: 600, maxHeight: 300),
                                tabs: [
                                  ShadTab(
                                    value: 'torrentInfo',
                                    onPressed: () {
                                      controller.selectTab = 'torrentInfo';
                                    },
                                    content: ListView(
                                      children: [
                                        CustomCard(
                                          child: ListTile(
                                            dense: true,
                                            title: Tooltip(
                                              message: controller.selectedTorrent.contentPath,
                                              child: Text(
                                                controller.selectedTorrent.contentPath,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            leading: Text('资源路径'),
                                            trailing: Text(torrentInfo.category),
                                          ),
                                        ),
                                        CustomCard(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          child: Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            alignment: WrapAlignment.spaceAround,
                                            children: [
                                              ShadBadge(
                                                child: Text(
                                                  '已上传: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.uploaded)}',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                              ShadBadge(
                                                child: Text(
                                                  '上传速度: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.upSpeed)}/S',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                              ShadBadge(
                                                child: Text(
                                                  '上传限速: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.upLimit)}/S',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                              ShadBadge(
                                                child: Text(
                                                  '已下载: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.downloaded)}',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                              if (torrentInfo.progress < 1) ...[
                                                ShadBadge(
                                                  child: Text(
                                                    '下载速度: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.dlSpeed)}',
                                                    style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                  ),
                                                ),
                                                ShadBadge(
                                                  child: Text(
                                                    '下载限速: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.dlLimit)}',
                                                    style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                  ),
                                                ),
                                              ],
                                              ShadBadge(
                                                child: Text(
                                                  '分享率: ${controller.selectedTorrent.ratio.toStringAsFixed(2)}',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                              ShadBadge(
                                                child: Text(
                                                  '分享率限制: ${controller.selectedTorrent.ratioLimit}',
                                                  style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        CustomCard(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ...trackers.map((qb.Tracker e) => CustomCard(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Tooltip(
                                                                message: e.url.toString(),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Clipboard.setData(
                                                                        ClipboardData(text: e.url.toString()));
                                                                  },
                                                                  child: CustomTextTag(
                                                                    backgroundColor: shadColorScheme.foreground,
                                                                    labelColor: shadColorScheme.background,
                                                                    labelText:
                                                                        controller.mySiteController.webSiteList.values
                                                                                .firstWhereOrNull(
                                                                                  (element) => element.tracker.contains(
                                                                                      Uri.parse(e.url.toString()).host),
                                                                                )
                                                                                ?.name ??
                                                                            Uri.parse(e.url.toString()).host,
                                                                  ),
                                                                ),
                                                              ),
                                                              CustomTextTag(
                                                                  backgroundColor: Colors.transparent,
                                                                  labelColor: shadColorScheme.foreground,
                                                                  icon: const Icon(Icons.download_done,
                                                                      size: 10, color: Colors.white),
                                                                  labelText:
                                                                      '完成：${e.numDownloaded! > 0 ? e.numDownloaded.toString() : '0'}'),
                                                              CustomTextTag(
                                                                  backgroundColor: Colors.transparent,
                                                                  labelColor: shadColorScheme.foreground,
                                                                  icon: const Icon(Icons.download_outlined,
                                                                      size: 10, color: Colors.white),
                                                                  labelText: '下载：${e.numLeeches.toString()}'),
                                                              CustomTextTag(
                                                                  backgroundColor: Colors.transparent,
                                                                  labelColor: shadColorScheme.foreground,
                                                                  icon: const Icon(Icons.insert_link,
                                                                      size: 10, color: Colors.white),
                                                                  labelText: '连接：${e.numPeers.toString()}'),
                                                              CustomTextTag(
                                                                  backgroundColor: Colors.transparent,
                                                                  labelColor: shadColorScheme.foreground,
                                                                  icon: const Icon(Icons.cloud_upload_outlined,
                                                                      size: 10, color: Colors.white),
                                                                  labelText: '做种：${e.numSeeds.toString()}'),
                                                            ],
                                                          ),
                                                          if (e.msg != null && e.msg!.isNotEmpty) ...[
                                                            const SizedBox(height: 5),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                CustomTextTag(
                                                                    backgroundColor:
                                                                        e.status == qb.TrackerStatus.working
                                                                            ? Colors.transparent
                                                                            : shadColorScheme.destructiveForeground,
                                                                    labelColor: e.status == qb.TrackerStatus.working
                                                                        ? shadColorScheme.foreground
                                                                        : shadColorScheme.destructive,
                                                                    labelText: controller.qbTrackerStatus
                                                                            .firstWhereOrNull(
                                                                                (element) => element.value == e.status)
                                                                            ?.name ??
                                                                        '未知'),
                                                                CustomTextTag(
                                                                  backgroundColor: shadColorScheme.destructive,
                                                                  labelColor: shadColorScheme.destructiveForeground,
                                                                  icon: Icon(
                                                                    Icons.message_outlined,
                                                                    size: 10,
                                                                    color: shadColorScheme.background,
                                                                  ),
                                                                  labelText: e.msg.toString(),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    )),
                                              ],
                                            )),
                                      ],
                                    ),
                                    child: const Text('种子信息'),
                                  ),
                                  ShadTab(
                                      value: 'files',
                                      onPressed: () {
                                        controller.selectTab = 'files';
                                      },
                                      content: QBittorrentTreeView(controller.selectedTorrentContents),
                                      child: const Text('文件列表')),
                                  ShadTab(
                                    value: 'repeatInfo',
                                    onPressed: () {
                                      controller.selectTab = 'repeatInfo';
                                    },
                                    content: ListView(
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
                                    child: const Text('辅种信息'),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  Widget _showTrTorrent(Downloader downloader, TrTorrent torrentInfo, context) {
    return GetBuilder<DownloadController>(builder: (controller) {
      String tracker = Uri.parse(torrentInfo.magnetLink).queryParametersAll["tr"]?.first ??
          (torrentInfo.trackerStats.isNotEmpty ? torrentInfo.trackerStats.first.announce : '');
      String host = Uri.parse(tracker).host;
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      return CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          Get.back(result: true);
                          var res = await controller.controlTrTorrents(
                              downloader: downloader,
                              command: 'remove_torrent',
                              enable: deleteFiles.value,
                              ids: [torrentInfo.hashString]);
                          if (res.succeed) {
                            controller.showTorrents
                                .removeWhere((element) => element.hashString == torrentInfo.hashString);
                            controller.update();
                          }
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
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTrTorrents(
                              downloader: downloader,
                              command: torrentInfo.status == 0 ? 'start_torrent' : 'stop_torrent',
                              ids: [torrentInfo.hashString]);
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
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTrTorrents(
                            downloader: downloader,
                            command: 'verify_torrent',
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
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () async {
                          Get.back(result: true);
                          await controller.controlTrTorrents(
                              downloader: downloader, command: 'reannounce_torrent', ids: [torrentInfo.hashString]);
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
              //   Get.snackbar('长按', '长按！',colorText: ShadTheme.of(context).colorScheme.primary);
              // },
              // onDoubleTap: () {
              //   Get.snackbar('双击', '双击！',colorText: ShadTheme.of(context).colorScheme.primary);
              // },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        torrentInfo.error <= 0
                            ? CustomTextTag(
                                labelText: host.isEmpty ? '未知' : (controller.trackerToWebSiteMap[host]?.name ?? host),
                                icon: const Icon(Icons.file_upload_outlined, size: 10, color: Colors.white),
                              )
                            : CustomTextTag(
                                labelText: Uri.parse(torrentInfo.magnetLink).queryParametersAll["tr"]?.first != null
                                    ? Uri.parse(Uri.parse(torrentInfo.magnetLink).queryParametersAll["tr"]!.first).host
                                    : "未知",
                                icon: const Icon(Icons.link_off, size: 10, color: Colors.white),
                                backgroundColor: Colors.red,
                              ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                FileSizeConvert.parseToFileSize(torrentInfo.totalSize),
                                style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                              ),
                              SizedBox(
                                height: 12,
                                child: Text(
                                  '${controller.trStatus.firstWhere((element) => element.value == torrentInfo.status, orElse: () => MetaDataItem(name: "未知状态", value: null)).name}[${torrentInfo.status}]',
                                  style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                  fontSize: 11, color: shadColorScheme.foreground, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Text(
                          torrentInfo.downloadDir.isNotEmpty ? torrentInfo.downloadDir : '未分类',
                          style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                  Icon(Icons.upload, size: 12, color: shadColorScheme.foreground),
                                  Text('${FileSizeConvert.parseToFileSize(torrentInfo.rateUpload)}/s',
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cloud_upload, size: 12, color: shadColorScheme.foreground),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.uploadedEver as int?),
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                  Icon(Icons.download, size: 12, color: shadColorScheme.foreground),
                                  Text('${FileSizeConvert.parseToFileSize(torrentInfo.rateDownload)}/s',
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.cloud_download, size: 12, color: shadColorScheme.foreground),
                                  Text(FileSizeConvert.parseToFileSize(torrentInfo.downloadedEver),
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground))
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
                                    color: shadColorScheme.foreground,
                                  ),
                                  EllipsisText(
                                    text: formatDuration(torrentInfo.activityDate).toString(),
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                                    color: shadColorScheme.foreground,
                                  ),
                                  EllipsisText(
                                    text: DateFormat('yyyy-MM-dd HH:mm:ss')
                                        .format(DateTime.fromMillisecondsSinceEpoch(torrentInfo.addedDate * 1000))
                                        .toString(),
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 6),
                      child: ShadProgress(value: torrentInfo.percentDone.toDouble()),
                    ),
                    if (torrentInfo.error > 0)
                      EllipsisText(
                        text: '${torrentInfo.error} - ${torrentInfo.errorString}',
                        ellipsis: '...',
                        maxLines: 1,
                        style: TextStyle(
                          color: shadColorScheme.destructive,
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

  void _openTrTorrentInfoDetail(Downloader downloader, TrTorrent torrentInfo, context) async {
    CommonResponse response =
        await controller.getDownloaderTorrentDetailInfo(downloader, torrentInfo.hashString, false);
    if (!response.succeed) {
      Get.snackbar('获取种子详情失败', response.msg);
      return;
    }
    var shadColorScheme = ShadTheme.of(context).colorScheme;

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
              .where((element) =>
                  element.name == controller.selectedTorrent.name &&
                  element.hashString != controller.selectedTorrent.hashString)
              .map((e) => MetaDataItem.fromJson({
                    "name": controller.getTrMetaName(e.hashString),
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
                      deleteButtonTooltipMessage: '删除',
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
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: const Text('取消'),
                            ),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                Get.back(result: true);
                                var res = await controller.controlTrTorrents(
                                    downloader: downloader,
                                    command: 'remove_torrent',
                                    enable: deleteFiles.value,
                                    ids: [e.value.hashString]);
                                if (res.succeed) {
                                  controller.showTorrents
                                      .removeWhere((element) => element.hashString == e.value.hashString);
                                  controller.update();
                                }
                              },
                              child: const Text('确认'),
                            ),
                          ],
                        );
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
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
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
                                message: controller.selectedTorrent.name,
                                child: Text(
                                  controller.selectedTorrent.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              subtitle: ShadProgress(value: controller.selectedTorrent.percentDone.toDouble()),
                              trailing: controller.selectedTorrent.status.toString().contains('pause') ||
                                      controller.selectedTorrent.trackerStats.isEmpty == true
                                  ? const Icon(Icons.pause, color: Colors.red)
                                  : const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: Colors.green,
                                    ),
                            ),
                          ),
                          if (controller.selectedTorrent.error > 0)
                            Center(
                              child: Text(
                                controller.selectedTorrent.errorString,
                                style: TextStyle(fontSize: 8, color: shadColorScheme.destructive),
                              ),
                            ),
                          // CustomCard(
                          //   child: ListTile(
                          //     dense: true,
                          //     title: Text(
                          //       controller.selectedTorrent.downloadDir,
                          //       style: const TextStyle(fontSize: 12),
                          //     ),
                          //     subtitle: Tooltip(
                          //       message: controller.selectedTorrent.downloadDir,
                          //       child: Text(
                          //         controller.selectedTorrent.downloadDir!,
                          //         style: const TextStyle(
                          //             overflow: TextOverflow.ellipsis),
                          //       ),
                          //     ),
                          //     leading: const Icon(Icons.category_outlined),
                          //     trailing: CustomPopup(
                          //       showArrow: false,
                          //       backgroundColor:
                          //           ShadTheme.of(context).colorScheme.background,
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
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            child: Wrap(
                              spacing: 18,
                              alignment: WrapAlignment.spaceAround,
                              children: [
                                ShadButton.destructive(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: '',
                                      middleText: '重新校验种子？',
                                      actions: [
                                        ShadButton(
                                          size: ShadButtonSize.sm,
                                          onPressed: () {
                                            Get.back(result: false);
                                          },
                                          child: const Text('取消'),
                                        ),
                                        ShadButton(
                                          size: ShadButtonSize.sm,
                                          onPressed: () async {
                                            Get.back(result: true);
                                            await controller.controlTrTorrents(
                                                downloader: downloader,
                                                command: 'verify_torrent',
                                                ids: [controller.selectedTorrent.hashString]);
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
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    await controller.controlTrTorrents(
                                        downloader: downloader,
                                        command: 'reannounce_torrent',
                                        ids: [controller.selectedTorrent.hashString]);
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
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    Clipboard.setData(ClipboardData(text: controller.selectedTorrent.hashString));
                                    Get.snackbar('复制种子HASH', '种子HASH复制成功！', colorText: shadColorScheme.foreground);
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
                                        formatDuration(controller.selectedTorrent.doneDate),
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
                                //                   controller.selectedTorrent.state!,
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
                                        FileSizeConvert.parseToFileSize(controller.selectedTorrent.totalSize),
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
                                        FileSizeConvert.parseToFileSize(controller.selectedTorrent.uploadedEver),
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
                                        '${FileSizeConvert.parseToFileSize(controller.selectedTorrent.rateUpload)}/S',
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
                                      Text(
                                        '上传限速',
                                        style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                      ),
                                      Text(
                                        '${FileSizeConvert.parseToFileSize(controller.selectedTorrent.rateUpload)}/S',
                                        style: TextStyle(color: shadColorScheme.foreground, fontSize: 14),
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
                                        FileSizeConvert.parseToFileSize(controller.selectedTorrent.downloadedEver),
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
                                        controller.selectedTorrent.uploadRatio.toStringAsFixed(2),
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
                                //         '${controller.selectedTorrent.uploadRatio}',
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
                          //                               ShadTheme.of(context)
                          //                                   .colorScheme
                          //                                   .foreground,
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
                          //                               ShadTheme.of(context)
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
                          //                               ShadTheme.of(context)
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
                          //                               ShadTheme.of(context)
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
                          //                               ShadTheme.of(context)
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
                          //   labelText: '可用性: ${controller.selectedTorrent.availability}',
                          // ),

                          // CustomTextTag(
                          //labelText:
                          //   '文件路径: ${controller.selectedTorrent.contentPath}',
                          //
                          // ),

                          // CustomTextTag(
                          //   labelText: '下载路径: ${controller.selectedTorrent.downloadPath}',
                          // ),

                          // CustomTextTag(
                          //   labelText:
                          //       'FL Piece Prio: ${controller.selectedTorrent.fLPiecePrio}',
                          // ),

                          // CustomTextTag(
                          //labelText:
                          //   '磁力链接: ${controller.selectedTorrent.magnetUri}',
                          //
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     CustomTextTag(
                          //       labelText: '最大分享比率: ${controller.selectedTorrent.maxRatio}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText:
                          //           '最大做种时间: ${formatDuration(controller.selectedTorrent.maxSeedingTime!)}',
                          //     ),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     CustomTextTag(
                          //       labelText: '完成数量: ${controller.selectedTorrent.numComplete}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText:
                          //           '未完成数量: ${controller.selectedTorrent.numIncomplete}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText: '正在做种数量: ${controller.selectedTorrent.numLeechs}',
                          //     ),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     CustomTextTag(
                          //       labelText: '做种数量: ${controller.selectedTorrent.numSeeds}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText: '优先级: ${controller.selectedTorrent.priority}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText: '保存路径: ${controller.selectedTorrent.savePath}',
                          //     ),
                          //   ],
                          // ),

                          // CustomTextTag(
                          //   labelText: '做种时间限制: ${controller.selectedTorrent.seedingTimeLimit}',
                          // ),

                          // CustomTextTag(
                          //   labelText: 'Seq DL: ${controller.selectedTorrent.seqDl}',
                          // ),
                          // CustomTextTag(
                          //   labelText: 'HASH: ${controller.selectedTorrent.hashString}',
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     CustomTextTag(
                          //       labelText:
                          //           '添加时间: ${formatTimestampToDateTime(controller.selectedTorrent.addedOn!)}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText:
                          //           '最后完整可见：${calcDurationFromTimeStamp(controller.selectedTorrent.seenComplete!)}',
                          //     ),
                          //   ],
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     CustomTextTag(
                          //       labelText:
                          //           '耗时: ${formatDuration(controller.selectedTorrent.eta!)}',
                          //     ),
                          //     CustomTextTag(
                          //       labelText:
                          //           '最后活动时间: ${calcDurationFromTimeStamp(controller.selectedTorrent.lastActivity!)}',
                          //     ),
                          //   ],
                          // ),
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       CustomTextTag(
                          //         labelText:
                          //             '已完成: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.completed)}',
                          //       ),
                          //       CustomTextTag(
                          //         labelText:
                          //             '完成时间: ${calcDurationFromTimeStamp(controller.selectedTorrent.completionOn!)}',
                          //       ),
                          //     ],
                          //   ),
                          //   if (controller.selectedTorrent.amountLeft! > 0)
                          //     CustomTextTag(
                          //       labelText:
                          //           '剩余大小: ${FileSizeConvert.parseToFileSize(controller.selectedTorrent.amountLeft)}',
                          //     ),
                          // ]),
                          ...controller.selectedTorrent.labels.map((e) => CustomTextTag(
                                labelText: '标签: $e',
                              )),
                          // CustomTextTag(
                          //   labelText:
                          //       '活跃时间: ${formatDuration(controller.selectedTorrent.timeActive!)}',
                          // ),
                        ],
                      ),
                    ],
                  ),
                  TransmissionTreeView(controller.selectedTorrent.files),
                  ListView(
                    children: [
                      Center(
                          child: Text(
                              style: const TextStyle(
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
