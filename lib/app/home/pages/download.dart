import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/form_widgets.dart';
import '../../../common/glass_widget.dart';
import '../../../models/download.dart';
import '../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../utils/logger_helper.dart';
import '../../../utils/range_input.dart';
import '../../../utils/storage.dart';
import '../../routes/app_pages.dart';
import 'controller/download_controller.dart';
import 'models/transmission.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  RxBool isLoaded = false.obs;

  DownloadController controller = Get.put(DownloadController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<DownloadController>(builder: (controller) {
        return StreamBuilder<List<Downloader>>(
            stream: controller.downloadStream,
            builder: (context, snapshot) {
              isLoaded.value = snapshot.hasData;
              return isLoaded.value
                  ? GlassWidget(
                      child: EasyRefresh(
                        controller: EasyRefreshController(),
                        onRefresh: () async {
                          controller.getDownloaderListFromServer();
                          controller.startPeriodicTimer();
                        },
                        child: ListView.builder(
                            itemCount: controller.dataList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Downloader downloader =
                                  controller.dataList[index];
                              return buildDownloaderCard(downloader);
                            }),
                      ),
                    )
                  : const Center(child: GFLoader());
            });
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() {
            var isTimerActive = controller.isTimerActive.value;
            return GFIconButton(
              icon: isTimerActive
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
              // shape: GFIconButtonShape.standard,
              type: GFButtonType.transparent,
              color: GFColors.PRIMARY,
              onPressed: () {
                // controller.cancelPeriodicTimer();
                isTimerActive
                    ? controller.cancelPeriodicTimer()
                    : controller.startPeriodicTimer();
                LoggerHelper.Logger.instance
                    .w(controller.periodicTimer.isActive);
                LoggerHelper.Logger.instance.w(isTimerActive);
                // controller.update();
              },
            );
          }),
          GFIconButton(
              icon: const Icon(Icons.settings),
              shape: GFIconButtonShape.standard,
              type: GFButtonType.transparent,
              color: GFColors.PRIMARY,
              onPressed: () {
                // controller.getAllCategory();
                // GFToast.showToast(
                //   '设置',
                //   context,
                //   backgroundColor: GFColors.SECONDARY,
                //   toastBorderRadius: 5.0,
                // );
                TextEditingController durationTextEditingController =
                    TextEditingController(text: controller.duration.toString());
                TextEditingController timerDurationTextEditingController =
                    TextEditingController(
                        text: controller.timerDuration.toString());
                Get.bottomSheet(
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                return TextField(
                                  controller: durationTextEditingController,
                                  decoration: InputDecoration(
                                    labelText: '刷新时间',
                                    hintText: '3-10',
                                    labelStyle: const TextStyle(fontSize: 10),
                                    hintStyle: const TextStyle(fontSize: 10),
                                    prefixIcon:
                                        const Icon(Icons.timer_3, size: 15),
                                    errorText: controller.isDurationValid.value
                                        ? null
                                        : 'Invalid input',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d{0,2}(\.\d{0,2})?$')),
                                    RangeInputFormatter(min: 3, max: 10),
                                  ],
                                  onChanged: (value) {
                                    controller.validateInput(value);
                                  },
                                );
                              }),
                            ),
                            GFIconButton(
                                type: GFButtonType.transparent,
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  try {
                                    double duration = double.parse(
                                        durationTextEditingController.text);
                                    if (duration < 3 || duration > 10) {
                                      Get.snackbar('出错啦', '超出范围，请设置 3-10');
                                    } else {
                                      controller.duration.value = duration;
                                      SPUtil.setDouble('duration', duration);
                                      controller.cancelPeriodicTimer();
                                      controller.startPeriodicTimer();
                                      controller.update();
                                      Get.snackbar('OK 啦', '保存成功！');
                                    }
                                  } catch (e) {
                                    Get.snackbar('出错啦', '请输入数字');
                                  }
                                })
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() {
                                return TextField(
                                  controller:
                                      timerDurationTextEditingController,
                                  decoration: InputDecoration(
                                    labelText: '刷新时长',
                                    hintText: '3-10',
                                    labelStyle: const TextStyle(fontSize: 10),
                                    hintStyle: const TextStyle(fontSize: 10),
                                    prefixIcon:
                                        const Icon(Icons.timer_3, size: 15),
                                    errorText: controller.isDurationValid.value
                                        ? null
                                        : 'Invalid input',
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d{0,2}(\.\d{0,2})?$')),
                                    RangeInputFormatter(min: 1, max: 10),
                                  ],
                                  onChanged: (value) {
                                    controller.validateInput(value, min: 1);
                                  },
                                );
                              }),
                            ),
                            GFIconButton(
                                type: GFButtonType.transparent,
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  try {
                                    double duration = double.parse(
                                        timerDurationTextEditingController
                                            .text);
                                    if (duration < 1 || duration > 10) {
                                      Get.snackbar('出错啦', '超出范围，请设置 1-10');
                                    } else {
                                      controller.timerDuration.value = duration;
                                      SPUtil.setDouble(
                                          'timerDuration', duration);
                                      controller.fiveMinutesTimer.cancel();
                                      controller.timerToStop();
                                      controller.update();
                                      Get.snackbar('OK 啦', '保存成功！');
                                    }
                                  } catch (e) {
                                    Get.snackbar('出错啦', '请输入数字');
                                  }
                                })
                          ],
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.white54.withOpacity(0.9),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(2),
                    ),
                  ),
                );
              }),
          GFIconButton(
            icon: const Icon(Icons.add),
            shape: GFIconButtonShape.standard,
            type: GFButtonType.transparent,
            color: GFColors.PRIMARY,
            onPressed: () async {
              _showEditBottomSheet();
            },
          ),
          const SizedBox(height: 72)
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
          Text(
            '下载器已禁用！',
            style: TextStyle(color: Colors.grey),
          ),
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
                                  fontSize: 10, color: Colors.black38),
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
                          borderColor: Colors.black38,
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
                          borderColor: Colors.black38,
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
                        '上传限速：${filesize(res.upRateLimit)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '下载限速：${filesize(res.dlRateLimit)}/S',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
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
                              const TextStyle(
                                  fontSize: 10, color: Colors.black38),
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
                          name: '上传速度',
                          borderColor: Colors.black38,
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
                          enableTooltip: true,
                          name: '下载速度',
                          borderColor: Colors.black38,
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
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        '暂停种子：${res.pausedTorrentCount}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
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
    return GFCard(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      boxFit: BoxFit.cover,
      color: Colors.white54,
      title: GFListTile(
        padding: const EdgeInsets.all(0),
        avatar: GFAvatar(
          // shape: GFAvatarShape.square,
          backgroundImage: AssetImage(
              'assets/images/${downloader.category.toLowerCase()}.png'),
          size: 18,
        ),
        title: Text(
          downloader.name,
          style: const TextStyle(
            color: Colors.black38,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subTitle: Text(
          '${downloader.protocol}://${downloader.host}:${downloader.port}',
          style: const TextStyle(
            color: Colors.black38,
            fontSize: 11,
          ),
        ),
        onTap: () {
          controller.cancelPeriodicTimer();
          Get.toNamed(Routes.TORRENT, arguments: downloader);
        },
        onLongPress: () async {
          _showEditBottomSheet(downloader: downloader);
        },
        icon: Obx(() {
          return GFIconButton(
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
                  '',
                  messageText: EllipsisText(
                    text: res.msg!,
                    ellipsis: '...',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 12,
                      color: res.data ? Colors.white : Colors.red,
                    ),
                  ),
                  colorText: res.data ? Colors.white : Colors.red,
                );
              });
            },
          );
        }),
      ),
      content: GetBuilder<DownloadController>(builder: (controller) {
        return _buildLiveLineChart(downloader, chartSeriesController);
      }),
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
                      '${filesize(res.dlInfoSpeed!)}/S',
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
                      Icons.cloud_upload_rounded,
                      color: Colors.green,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      filesize(res.upInfoData),
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
                      filesize(res.dlInfoData),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black38,
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
                  '${filesize(res.downloadSpeed, 0)}/S',
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
                  Icons.cloud_upload_rounded,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  filesize(res.currentStats.uploadedBytes),
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
                  filesize(res.currentStats.downloadedBytes),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black38,
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
        TextEditingController(text: downloader?.torrentPath ?? '/downloaders/');

    RxBool isActive = downloader != null ? downloader.isActive.obs : true.obs;
    RxBool brush = downloader != null ? downloader.brush.obs : false.obs;
    await controller.getTorrentsPathList();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        color: Colors.blueGrey.shade300,
        width: 550,
        child: Column(
          children: [
            Text(
              downloader != null ? '编辑站点：${downloader.name}' : '添加站点',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  return Column(
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
                      Row(
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
                              ),
                            ),
                          ]),
                      ButtonBar(
                        alignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.error),
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
                              backgroundColor: MaterialStateProperty.all(
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
                                downloader?.port =
                                    int.parse(portController.text);
                                downloader?.torrentPath =
                                    torrentPathController.text;
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
                              Logger.instance.i(downloader?.toJson());
                              if (await controller
                                  .saveDownloaderToServer(downloader!)) {
                                Navigator.of(context).pop();
                                controller.getDownloaderListFromServer();
                                controller.update();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }),
              ),
            ),
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
