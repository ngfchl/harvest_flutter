import 'dart:io';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/app/home/controller/home_controller.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../common/card_view.dart';
import '../../../../common/hex_color.dart';
import '../../../../common/meta_item.dart';
import '../../../../common/utils.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import '../../controller/common_api.dart';
import 'controller.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final controller = Get.put(DashBoardController());
  AnimationController? animationController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _updateShowInfoChildren();
    super.build(context);
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          body: GetBuilder<DashBoardController>(builder: (controller) {
            return _showAllInfo();
          }),
          floatingActionButton: controller.userinfo?.isStaff == true
              ? _buildBottomButtonBar()
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
        ),
      );
    });
  }

  Widget _showTodayUploadedIncrement() {
    // controller.todayIncrement = 0;
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
        height: 260,
        child: SfCircularChart(
          title: ChartTitle(
            text:
                '今日上传增量：${filesize(controller.todayUploadIncrement)}【${controller.uploadIncrementDataList.length}个站点】',
            textStyle: TextStyle(
                fontSize: 11, color: Theme.of(context).colorScheme.primary),
          ),
          legend: Legend(
            position: LegendPosition.left,
            // height: "20",
            isVisible: true,
            iconWidth: 8,
            iconHeight: 8,
            padding: 5,
            itemPadding: 5,
            // width: '64',
            isResponsive: true,
            textStyle: TextStyle(
              fontSize: 8,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          series: <DoughnutSeries<MetaDataItem, String>>[
            DoughnutSeries<MetaDataItem, String>(
              name: '今日上传数据汇总',
              dataSource: controller.uploadIncrementDataList,
              xValueMapper: (MetaDataItem data, _) => controller.privateMode
                  ? "${data.name.substring(0, 1)}**"
                  : data.name,
              yValueMapper: (MetaDataItem data, _) => data.value,
              dataLabelMapper: (MetaDataItem data, _) {
                return '${controller.privateMode ? "${data.name.substring(0, 1)}*" : data.name}: ${filesize(data.value)}';
              },
              legendIconType: LegendIconType.circle,
              enableTooltip: true,
              explode: true,
              explodeIndex: 0,
              explodeOffset: '10%',
              radius: '60%',
              // pointRenderMode: PointRenderMode.gradient,
              dataLabelSettings: DataLabelSettings(
                margin: EdgeInsets.zero,
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
                showZeroValue: false,
                connectorLineSettings: const ConnectorLineSettings(
                  type: ConnectorType.curve,
                  length: '20%',
                ),
                labelIntersectAction: LabelIntersectAction.shift,
              ),
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: false,
            activationMode: ActivationMode.singleTap,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${point.x}: ${filesize(point.y ?? 0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _showTodayDownloadedIncrement() {
    // controller.todayIncrement = 0;
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
        height: 260,
        child: SfCircularChart(
          title: ChartTitle(
            text:
                '今日下载增量：${filesize(controller.todayDownloadIncrement)}【${controller.downloadIncrementDataList.length}个站点】',
            textStyle: TextStyle(
                fontSize: 11, color: Theme.of(context).colorScheme.primary),
          ),
          legend: Legend(
            position: LegendPosition.left,
            // height: "20",
            isVisible: true,
            iconWidth: 8,
            iconHeight: 8,
            padding: 5,
            itemPadding: 5,
            // width: '64',
            isResponsive: true,
            textStyle: TextStyle(
              fontSize: 8,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          series: <DoughnutSeries<MetaDataItem, String>>[
            DoughnutSeries<MetaDataItem, String>(
              name: '今日下载数据汇总',
              dataSource: controller.downloadIncrementDataList,
              xValueMapper: (MetaDataItem data, _) => controller.privateMode
                  ? "${data.name.substring(0, 1)}**"
                  : data.name,
              yValueMapper: (MetaDataItem data, _) => data.value,
              dataLabelMapper: (MetaDataItem data, _) {
                return '${controller.privateMode ? "${data.name.substring(0, 1)}**" : data.name}: ${filesize(data.value)}';
              },
              legendIconType: LegendIconType.circle,
              enableTooltip: true,
              explode: true,
              explodeIndex: 0,
              explodeOffset: '10%',
              radius: '60%',
              pointRenderMode: PointRenderMode.gradient,
              dataLabelSettings: DataLabelSettings(
                margin: EdgeInsets.zero,
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  fontSize: 8,
                  color: Theme.of(context).colorScheme.primary,
                ),
                showZeroValue: false,
                connectorLineSettings: const ConnectorLineSettings(
                  type: ConnectorType.curve,
                  length: '10%',
                ),
                labelIntersectAction: LabelIntersectAction.shift,
              ),
            )
          ],
          // tooltipBehavior:
          //     TooltipBehavior(enable: true, format: 'point.x : ${filesize(point.y)}'),
        ),
      );
    });
  }

  Widget _showAllInfo() {
    Logger.instance.d('数据标记 1');
    Logger.instance.d(controller.earliestSite);
    return GetBuilder<DashBoardController>(builder: (controller) {
      return Column(
        children: [
          if (controller.isLoading)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(child: GFLoader(size: 8, loaderstrokeWidth: 2)),
                const SizedBox(width: 5),
                Text(
                  '当前为缓存数据，正在从服务器加载',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 5),
          Expanded(
            child: EasyRefresh(
              onRefresh: () async {
                // controller.mySiteController.initFlag = true;
                await controller.initChartData(controller.days);
              },
              child: GetBuilder<DashBoardController>(builder: (controller) {
                Logger.instance.d('数据标记 2');
                return controller.isLoading
                    ? GFLoader(
                        type: GFLoaderType.circle,
                        loaderColorOne: Theme.of(context).primaryColor,
                        loaderColorTwo: Theme.of(context).primaryColor,
                        loaderColorThree: Theme.of(context).primaryColor,
                        loaderIconOne: const Icon(Icons.ac_unit, size: 18),
                        loaderIconTwo:
                            const Icon(Icons.ac_unit_outlined, size: 24),
                        loaderIconThree:
                            const Icon(Icons.ac_unit_rounded, size: 18),
                      )
                    : InkWell(
                        onLongPress: () {
                          Get.defaultDialog(
                            title: '小部件',
                            radius: 5,
                            titleStyle: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900),
                            content: SizedBox(
                                height: 260,
                                width: 280,
                                child: GetBuilder<DashBoardController>(
                                    builder: (controller) {
                                  return ListView(
                                    children: [
                                      // CheckboxListTile(
                                      //     title: const Text("站点数据汇总"),
                                      //     value: controller
                                      //         .buildSiteInfoCard,
                                      //     onChanged: (bool? value) {
                                      //       controller.buildSiteInfoCard =
                                      //           value!;
                                      //       controller.update();
                                      //     }),

                                      CustomCheckboxListTile(
                                        title: '开启隐私模式',
                                        value: controller.privateMode,
                                        storageKey: 'privateMode',
                                        onUpdate: (bool newValue) {
                                          controller.privateMode = newValue;
                                          Logger.instance.d(
                                              "privateMode: ${controller.privateMode}");
                                          controller
                                              .initChartData(controller.days);
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '上传总量饼图',
                                        value:
                                            controller.buildSmartLabelPieChart,
                                        storageKey: 'buildSmartLabelPieChart',
                                        onUpdate: (bool newValue) {
                                          controller.buildSmartLabelPieChart =
                                              newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '做种总量饼图',
                                        value:
                                            controller.buildSeedVolumePieChart,
                                        storageKey: 'buildSeedVolumePieChart',
                                        onUpdate: (bool newValue) {
                                          controller.buildSeedVolumePieChart =
                                              newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '每日数据柱图',
                                        value: controller.buildStackedBar,
                                        storageKey: 'buildStackedBar',
                                        onUpdate: (bool newValue) {
                                          controller.buildStackedBar = newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '每月数据柱图',
                                        value: controller.buildMonthStackedBar,
                                        storageKey: 'buildMonthStackedBar',
                                        onUpdate: (bool newValue) {
                                          controller.buildMonthStackedBar =
                                              newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '站点数据柱图',
                                        value: controller.buildSiteInfo,
                                        storageKey: 'buildSiteInfo',
                                        onUpdate: (bool newValue) {
                                          controller.buildSiteInfo = newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '今日上传增量',
                                        value: controller
                                            .showTodayUploadedIncrement,
                                        storageKey:
                                            'showTodayUploadedIncrement',
                                        onUpdate: (bool newValue) {
                                          controller
                                                  .showTodayUploadedIncrement =
                                              newValue;
                                          controller.update();
                                        },
                                      ),
                                      CustomCheckboxListTile(
                                        title: '今日下载增量',
                                        value: controller
                                            .showTodayDownloadedIncrement,
                                        storageKey:
                                            'showTodayDownloadedIncrement',
                                        onUpdate: (bool newValue) {
                                          controller
                                                  .showTodayDownloadedIncrement =
                                              newValue;
                                          controller.update();
                                        },
                                      ),
                                    ],
                                  );
                                })),
                            // actions: [
                            //   ElevatedButton(
                            //     onPressed: () {
                            //       Get.back(result: false);
                            //     },
                            //     child: const Text('取消'),
                            //   ),
                            //   ElevatedButton(
                            //     onPressed: () async {
                            //       Get.back(result: true);
                            //       Navigator.of(context).pop();
                            //     },
                            //     child: const Text('确认'),
                            //   ),
                            // ],
                          );
                        },
                        child: SingleChildScrollView(
                          child: Obx(() {
                            return Wrap(
                                alignment: WrapAlignment.spaceAround,
                                direction: Axis.horizontal,
                                children: [
                                  if (controller.buildSiteInfoCard)
                                    _buildSiteInfoCard(),
                                  if (controller.buildSiteInfo)
                                    _buildSiteInfo(),
                                  if (controller.buildSmartLabelPieChart)
                                    _buildSmartLabelPieChart(),
                                  if (controller.buildSeedVolumePieChart)
                                    _buildSeedVolumePieChart(),
                                  if (controller.buildStackedBar)
                                    _buildStackedBar(),
                                  if (controller.buildMonthStackedBar)
                                    _buildMonthStackedBar(),
                                  if (controller.showTodayUploadedIncrement)
                                    _showTodayUploadedIncrement(),
                                  if (controller.showTodayDownloadedIncrement)
                                    _showTodayDownloadedIncrement(),
                                ]
                                    .map((item) => FractionallySizedBox(
                                          widthFactor:
                                              Get.find<HomeController>()
                                                      .isPortrait
                                                      .value
                                                  ? 1
                                                  : 0.5,
                                          child: item,
                                        ))
                                    .toList());
                          }),
                        ),
                      );
                // : Center(
                //     child: ElevatedButton.icon(
                //     onPressed: () async {
                //       await controller.initChartData(controller.days);
                //     },
                //     label: Text(
                //       '加载数据',
                //       style: TextStyle(
                //           fontSize: 12,
                //           color: Theme.of(context).primaryColor),
                //     ),
                //     icon: Icon(Icons.cloud_download,
                //         size: 12,
                //         color: Theme.of(context).primaryColor),
                //   ));
              }),
            ),
          ),
          if (!kIsWeb && Platform.isIOS) const SizedBox(height: 10),
          if (controller.userinfo?.isStaff == true) const SizedBox(height: 50),
        ],
      );
    });
  }

  _buildBottomButtonBar() {
    List<MetaDataItem> cacheList = [
      {"name": "豆瓣缓存数据", "value": "*douban*"},
      {"name": "RSS缓存数据", "value": "rss_data_list"},
      {"name": "单下载器缓存", "value": "repeat_info_hash_cache:*-*"},
      {"name": "站点删种缓存", "value": "repeat_404_cache:*-*"},
      {"name": "辅种错误缓存", "value": "repeat_error_cache:*-*"},
      {"name": "辅种成功缓存", "value": "repeat_success_cache:*-*"},
      {"name": "辅种数据缓存", "value": "repeat_info_hash_cache"},
      {"name": "站点配置缓存", "value": "website_list"},
      {"name": "我的站点缓存", "value": "my_site_list"},
    ].map((e) => MetaDataItem.fromJson(e)).toList();
    return CustomCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          // crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 15,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await controller.initData();
              },
              icon: Icon(
                Icons.cloud_download,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 5)),
                side: WidgetStateProperty.all(BorderSide.none),
              ),
              label: Text(
                '重新加载',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await getAllStatusButton();
              },
              icon: Icon(
                Icons.refresh,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 5)),
                side: WidgetStateProperty.all(BorderSide.none),
              ),
              label: Text(
                '更新数据',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 12),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await signAllSiteButton();
              },
              icon: Icon(
                Icons.credit_score,
                size: 12,
                color: Theme.of(context).colorScheme.primary,
              ),
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                ),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 5)),
                side: WidgetStateProperty.all(BorderSide.none),
              ),
              label: Text(
                '全员签到',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 12),
              ),
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
                    ...cacheList.map((item) => PopupMenuItem<String>(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          onTap: () async {
                            await clearMyCacheButton(item.value);
                            // await controller.mySiteController.initData();
                          },
                        )),
                  ],
                ),
              ),
              child: ElevatedButton.icon(
                icon: Icon(
                  Icons.cleaning_services_rounded,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: null,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                  ),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 5)),
                  side: WidgetStateProperty.all(BorderSide.none),
                ),
                label: Text(
                  '清理缓存',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteInfoCard() {
    return GetBuilder<DashBoardController>(builder: (controller) {
      // MySite earliestSite = controller.mySiteController.mySiteList
      //     .where((item) =>
      //         !controller.excludeUrlList.contains(item.mirror) &&
      //         DateTime.parse(item.timeJoin) != DateTime(2024, 2, 1))
      //     .reduce((value, element) =>
      //         value.timeJoin.compareTo(element.timeJoin) < 0 ? value : element);
      MySite earliestSite = controller.earliestSite!;
      RxBool showYear = true.obs;
      return CustomCard(
        height: 260,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topRight: Radius.circular(68.0),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 4),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                height: 48,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: HexColor('#87A0E5').withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 2),
                                      child: Text(
                                        '上传量',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                          letterSpacing: -0.1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: Icon(
                                            Icons.upload,
                                            size: 15,
                                            color: Colors.lightGreen,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: Text(
                                            filesize(controller.totalUploaded),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, bottom: 3),
                                          child: Text(
                                            '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              letterSpacing: -0.2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Container(
                                height: 48,
                                width: 2,
                                decoration: BoxDecoration(
                                  color: HexColor('#F56E98').withOpacity(0.5),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 2),
                                      child: Text(
                                        '下载量',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11,
                                          letterSpacing: -0.1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 15,
                                          height: 15,
                                          child: Icon(
                                            Icons.download,
                                            size: 15,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4),
                                          child: Text(
                                            filesize(
                                                controller.totalDownloaded),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, bottom: 3),
                                          child: Text(
                                            '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              letterSpacing: -0.2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          showYear.value = !showYear.value;
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0),
                                  ),
                                  border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ),
                                ),
                                child: Obx(() {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      showYear.value
                                          ? Text(
                                              calcWeeksDays(
                                                  earliestSite.timeJoin),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 11,
                                                letterSpacing: 0.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.8),
                                              ),
                                            )
                                          : Text(
                                              calculateTimeElapsed(
                                                      earliestSite.timeJoin)
                                                  .replaceAll('前', ''),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 11,
                                                letterSpacing: 0.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                      Text(
                                        '🔥P龄',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CustomPaint(
                                painter: CurvePainter(colors: [
                                  HexColor("#8A98E8"),
                                  HexColor("#8A98E8")
                                ], angle: 140 + (360 - 140) * 1.0),
                                child: const SizedBox(
                                  width: 108,
                                  height: 108,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '站点数',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            letterSpacing: -0.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            height: 4,
                            width: 50,
                            decoration: BoxDecoration(
                              color: HexColor('#87D0E5').withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 60 / 1.2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      HexColor('#87D0E5'),
                                      HexColor('#87D0E5').withOpacity(0.5),
                                    ]),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${controller.siteCount}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '做种量',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            letterSpacing: -0.2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            height: 4,
                            width: 50,
                            decoration: BoxDecoration(
                              color: HexColor('#89A0E5').withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 60 / 1.2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      HexColor('#89A0E5'),
                                      HexColor('#89A0E5').withOpacity(0.5),
                                    ]),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(4.0)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            filesize(controller.totalSeedVol, 2),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -1,
                              wordSpacing: -1,
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '做种中',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                letterSpacing: -0.2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: HexColor('#F56E98').withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: ((60 / 2) *
                                          animationController!.value),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          HexColor('#F56E98').withOpacity(0.1),
                                          HexColor('#F56E98'),
                                        ]),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${controller.totalSeeding}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '吸血中',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                letterSpacing: -0.2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 0, top: 4),
                              child: Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: HexColor('#F1B440').withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: ((60 / 2.5) *
                                          animationController!.value),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          HexColor('#F1B440').withOpacity(0.1),
                                          HexColor('#F1B440'),
                                        ]),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${controller.totalLeeching}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildSiteInfo() {
    int maxUploaded = controller.statusList
        .map((item) => item.value['uploaded'])
        .reduce((a, b) => a > b ? a : b);

    int maxDownloaded = controller.statusList
        .map((item) => item.value['downloaded'])
        .reduce((a, b) => a > b ? a : b);

    var uploadColor = RandomColor().randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.green, ColorHue.blue]),
        colorBrightness: ColorBrightness.dark);
    var downloadColor = RandomColor().randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.red, ColorHue.orange]),
        colorBrightness: ColorBrightness.dark,
        colorSaturation: ColorSaturation.highSaturation);
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
        height: 260,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text('站点数据',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                )),
            const SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                  itemCount: controller.statusList.length,
                  itemBuilder: (context, index) {
                    MetaDataItem data = controller.statusList[index];
                    StatusInfo? status = StatusInfo.fromJson(data.value);

                    return Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        filesize(status?.uploaded ?? 0),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 18,
                                        // width: 100,
                                        child: SfLinearGauge(
                                          showTicks: false,
                                          showLabels: false,
                                          animateAxis: true,
                                          isAxisInversed: true,
                                          axisTrackStyle:
                                              const LinearAxisTrackStyle(
                                                  thickness: 16,
                                                  edgeStyle:
                                                      LinearEdgeStyle.bothFlat,
                                                  borderWidth: 2,
                                                  borderColor:
                                                      Color(0xff898989),
                                                  color: Colors.transparent),
                                          barPointers: <LinearBarPointer>[
                                            LinearBarPointer(
                                              value: (status.uploaded ?? 0) /
                                                  maxUploaded *
                                                  100,
                                              thickness: 16,
                                              edgeStyle:
                                                  LinearEdgeStyle.bothFlat,
                                              color: uploadColor,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: 70,
                                  child: Center(
                                      child: EllipsisText(
                                    text: controller.privateMode
                                        ? "${data.name.substring(0, 1)}**"
                                        : data.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    ellipsis: '...',
                                    maxLines: 1,
                                  ))),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                          height: 18,
                                          // width: 100,
                                          child: SfLinearGauge(
                                            showTicks: false,
                                            showLabels: false,
                                            animateAxis: true,
                                            axisTrackStyle:
                                                const LinearAxisTrackStyle(
                                              thickness: 16,
                                              edgeStyle:
                                                  LinearEdgeStyle.bothFlat,
                                              borderWidth: 2,
                                              borderColor: Color(0xff898989),
                                              color: Colors.transparent,
                                            ),
                                            barPointers: <LinearBarPointer>[
                                              LinearBarPointer(
                                                  value:
                                                      (status.downloaded ?? 0) /
                                                          maxDownloaded *
                                                          100,
                                                  thickness: 16,
                                                  edgeStyle:
                                                      LinearEdgeStyle.bothFlat,
                                                  color: downloadColor),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    SizedBox(
                                        width: 60,
                                        child: Text(
                                          filesize(status?.downloaded ?? 0),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSmartLabelPieChart() {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
        height: 260,
        padding: const EdgeInsets.only(left: 10),
        child: SfCircularChart(
          title: ChartTitle(
              text: '上传数据',
              textStyle: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
              )),
          centerX: '47%',
          centerY: '45%',
          margin: const EdgeInsets.all(10),
          legend: Legend(
              position: LegendPosition.left,
              // height: "20",
              isVisible: true,
              iconWidth: 8,
              padding: 5,
              itemPadding: 5,
              // width: '64',
              isResponsive: true,
              textStyle: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.primary,
              )),
          series: _getSmartLabelPieSeries(),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: false,
            activationMode: ActivationMode.singleTap,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${data.name}: ${filesize(data.value.uploaded ?? 0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          enableMultiSelection: true,
        ),
      );
    });
  }

  Widget _buildSeedVolumePieChart() {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
        height: 260,
        padding: const EdgeInsets.only(left: 10),
        child: SfCircularChart(
          title: ChartTitle(
              text: '做种总量：${filesize(controller.totalSeedVol)}',
              textStyle: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
              )),
          centerX: '47%',
          centerY: '45%',
          margin: const EdgeInsets.all(10),
          legend: Legend(
              position: LegendPosition.left,
              // height: "20",
              isVisible: true,
              iconWidth: 8,
              padding: 5,
              itemPadding: 5,
              // width: '64',
              isResponsive: true,
              textStyle: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.primary,
              )),
          series: _getSeedVolumePieSeries(),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            header: '',
            canShowMarker: false,
            activationMode: ActivationMode.singleTap,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              return Container(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${data.name}: ${filesize(data.value ?? 0)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          enableMultiSelection: true,
        ),
      );
    });
  }

  List<PieSeries<MetaDataItem, String>> _getSmartLabelPieSeries() {
    return <PieSeries<MetaDataItem, String>>[
      PieSeries<MetaDataItem, String>(
        name: '站点上传数据汇总',
        dataSource: controller.statusList
            .map((item) => MetaDataItem(
                name: item.name, value: StatusInfo.fromJson(item.value)))
            .toList(),
        xValueMapper: (MetaDataItem data, _) => controller.privateMode
            ? "${data.name.substring(0, 1)}**"
            : data.name,
        yValueMapper: (MetaDataItem data, _) => data.value.uploaded ?? 0,
        dataLabelMapper: (MetaDataItem data, _) =>
            '${controller.privateMode ? "${data.name.substring(0, 1)}**" : data.name}: ${filesize(data.value.uploaded ?? 0)}',
        enableTooltip: true,
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        radius: '65%',
        // pointRenderMode: PointRenderMode.gradient,
        dataLabelSettings: DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            fontSize: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
          showZeroValue: false,
          connectorLineSettings: const ConnectorLineSettings(
            type: ConnectorType.curve,
            length: '20%',
          ),
          labelIntersectAction: LabelIntersectAction.shift,
        ),
      )
    ];
  }

  List<PieSeries<MetaDataItem, String>> _getSeedVolumePieSeries() {
    return <PieSeries<MetaDataItem, String>>[
      PieSeries<MetaDataItem, String>(
        name: '站点做种数据汇总',
        dataSource: controller.seedDataList,
        xValueMapper: (MetaDataItem data, _) => controller.privateMode
            ? "${data.name.substring(0, 1)}**"
            : data.name,
        yValueMapper: (MetaDataItem data, _) => data.value ?? 0,
        dataLabelMapper: (MetaDataItem data, _) =>
            '${controller.privateMode ? "${data.name.substring(0, 1)}**" : data.name}: ${filesize(data.value ?? 0)}',
        enableTooltip: true,
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        radius: '65%',
        // pointRenderMode: PointRenderMode.gradient,
        dataLabelSettings: DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            fontSize: 8,
            color: Theme.of(context).colorScheme.primary,
          ),
          showZeroValue: false,
          connectorLineSettings: const ConnectorLineSettings(
            type: ConnectorType.curve,
            length: '20%',
          ),
          labelIntersectAction: LabelIntersectAction.shift,
        ),
      )
    ];
  }

  Widget _buildStackedBar() {
    try {
      return GetBuilder<DashBoardController>(builder: (controller) {
        return CustomCard(
          height: 260,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                    title: ChartTitle(
                        text: '每日上传增量',
                        textStyle: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary)),
                    isTransposed: true,
                    margin: const EdgeInsets.all(15),
                    legend: Legend(
                        isVisible: false,
                        iconWidth: 8,
                        iconHeight: 8,
                        padding: 5,
                        itemPadding: 5,
                        textStyle: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    enableSideBySideSeriesPlacement: false,
                    plotAreaBorderWidth: 0,
                    enableAxisAnimation: true,
                    selectionType: SelectionType.point,
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enableDoubleTapZooming: true,
                      zoomMode: ZoomMode.x,
                      enablePanning: true,
                      enableMouseWheelZooming: true,
                      enableSelectionZooming: true,
                      maximumZoomLevel: 0.3,
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      canShowMarker: true,
                      duration: 0,
                      activationMode: ActivationMode.singleTap,
                      tooltipPosition: TooltipPosition.auto,
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  point.x,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '${series.name}: ${filesize(point.y)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(
                          details.text,
                          TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(
                          filesize(details.value.toInt()),
                          TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    series: List.generate(controller.stackChartDataList.length,
                        (index) {
                      MetaDataItem siteData =
                          controller.stackChartDataList[index];
                      return StackedBarSeries<StatusInfo?, String>(
                        name: controller.privateMode
                            ? "${siteData.name.toString().substring(0, 1)}**"
                            : siteData.name,
                        // width: 0.5,
                        borderRadius: BorderRadius.circular(1),
                        legendIconType: LegendIconType.circle,
                        dataSource: siteData.value,
                        // isVisibleInLegend: true,
                        xValueMapper: (StatusInfo? status, loop) => loop > 0
                            ? formatCreatedTimeToDateString(status!)
                            : null,
                        yValueMapper: (StatusInfo? status, loop) {
                          if (loop > 0 && loop < siteData.value.length) {
                            num increase = status!.uploaded -
                                siteData.value[loop - 1]!.uploaded;
                            return increase > 0 ? increase : 0;
                          }
                          return null;
                        },
                        // pointColorMapper: (StatusInfo status, _) =>
                        //     RandomColor().randomColor(),
                        emptyPointSettings: const EmptyPointSettings(
                          mode: EmptyPointMode.drop,
                        ),
                        dataLabelMapper: (StatusInfo? status, _) =>
                            controller.privateMode
                                ? siteData.name.toString().substring(0, 1)
                                : siteData.name,
                        // color: RandomColor().randomColor(),
                        // enableTooltip: true,
                      );
                    }).toList()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    CustomTextTag(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        labelText: '最近${controller.days}天'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                          children: [
                            InkWell(
                              child: const Icon(Icons.remove),
                              onTap: () async {
                                if (controller.days > 1) {
                                  controller.days--;
                                  await controller
                                      .initChartData(controller.days);
                                  controller.update();
                                }
                              },
                            ),
                            Expanded(
                              child: Slider(
                                  min: 1,
                                  max: 14,
                                  divisions: 14,
                                  label: controller.days.toString(),
                                  value: controller.days.toDouble(),
                                  onChanged: (value) async {
                                    controller.days = value.toInt();
                                    await controller
                                        .initChartData(controller.days);

                                    controller.update();
                                  }),
                            ),
                            InkWell(
                              child: const Icon(Icons.add),
                              onTap: () {
                                if (controller.days < 14) {
                                  controller.days++;
                                  controller.initChartData(controller.days);
                                  controller.update();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      return const SizedBox.shrink();
    }
  }

  Widget _buildMonthStackedBar() {
    try {
      return GetBuilder<DashBoardController>(builder: (controller) {
        return CustomCard(
          height: 260,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                    title: ChartTitle(
                        text: '月度上传增量',
                        textStyle: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.primary)),
                    isTransposed: true,
                    margin: const EdgeInsets.all(15),
                    legend: Legend(
                        isVisible: false,
                        iconWidth: 8,
                        iconHeight: 8,
                        padding: 5,
                        itemPadding: 5,
                        textStyle: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    enableSideBySideSeriesPlacement: false,
                    plotAreaBorderWidth: 0,
                    enableAxisAnimation: true,
                    selectionType: SelectionType.point,
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enableDoubleTapZooming: true,
                      zoomMode: ZoomMode.x,
                      enablePanning: true,
                      enableMouseWheelZooming: true,
                      enableSelectionZooming: true,
                      maximumZoomLevel: 0.3,
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      canShowMarker: true,
                      duration: 0,
                      activationMode: ActivationMode.singleTap,
                      tooltipPosition: TooltipPosition.auto,
                      builder: (dynamic data, dynamic point, dynamic series,
                          int pointIndex, int seriesIndex) {
                        // Logger.instance.d(data);
                        return Container(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  point.x,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.8),
                                  ),
                                ),
                                Text(
                                  '${series.name}: ${filesize(point.y)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(
                          details.text,
                          TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    primaryYAxis: NumericAxis(
                      axisLine: const AxisLine(width: 0),
                      axisLabelFormatter: (AxisLabelRenderDetails details) {
                        return ChartAxisLabel(
                          filesize(details.value.toInt()),
                          TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                      majorTickLines: const MajorTickLines(size: 0),
                    ),
                    series: List.generate(
                        controller.uploadMonthIncrementDataList.length,
                        (index) {
                      MetaDataItem siteData =
                          controller.uploadMonthIncrementDataList[index];
                      List<StatusInfo?> dataSource =
                          siteData.value.whereType<StatusInfo?>().toList();
                      return StackedBarSeries<StatusInfo?, String>(
                        name: controller.privateMode
                            ? "${siteData.name.toString().substring(0, 1)}**"
                            : siteData.name,
                        // width: 0.5,
                        borderRadius: BorderRadius.circular(1),
                        legendIconType: LegendIconType.circle,
                        dataSource: dataSource,
                        // isVisibleInLegend: true,
                        xValueMapper: (StatusInfo? status, loop) => loop > 0
                            ? formatCreatedTimeToMonthString(status!)
                            : null,
                        yValueMapper: (StatusInfo? status, loop) {
                          if (loop > 0 && loop < dataSource.length) {
                            num increase = status!.uploaded -
                                dataSource[loop - 1]!.uploaded;
                            return increase > 0 ? increase : 0;
                          }
                          return null;
                        },
                        // pointColorMapper: (StatusInfo status, _) =>
                        //     RandomColor().randomColor(),
                        emptyPointSettings: const EmptyPointSettings(
                          mode: EmptyPointMode.drop,
                        ),
                        dataLabelMapper: (StatusInfo? status, _) => controller
                                .privateMode
                            ? "${siteData.name.toString().substring(0, 1)}**"
                            : siteData.name,
                        // color: RandomColor().randomColor(),
                        // enableTooltip: true,
                      );
                    }).toList()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    CustomTextTag(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        labelText: '最近12月'),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                          children: [
                            // InkWell(
                            //   child: const Icon(Icons.remove),
                            //   onTap: () async {
                            //     if (controller.days > 1) {
                            //       controller.days--;
                            //       await controller.initChartData();
                            //       controller.update();
                            //     }
                            //   },
                            // ),
                            Expanded(
                              child: Slider(
                                  min: 1,
                                  max: 12,
                                  divisions: 12,
                                  // label: controller.days.toString(),
                                  value: 12,
                                  onChanged: (value) async {
                                    // controller.days = value.toInt();
                                    // await controller.initChartData();
                                    //
                                    // controller.update();
                                  }),
                            ),
                            // InkWell(
                            //   child: const Icon(Icons.add),
                            //   onTap: () {
                            //     if (controller.days < 14) {
                            //       controller.days++;
                            //       controller.initChartData();
                            //       controller.update();
                            //     }
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    Get.delete<DashBoardController>();
    super.dispose();
  }
}

class CustomCheckboxListTile extends StatelessWidget {
  final String title;
  final bool value;
  final String storageKey;
  final void Function(bool) onUpdate;

  const CustomCheckboxListTile({
    super.key,
    required this.title,
    required this.value,
    required this.storageKey,
    this.onUpdate = _defaultOnUpdate,
  });

  static void _defaultOnUpdate(bool newValue) {}

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
      ),
      value: value,
      onChanged: (bool? newValue) {
        if (newValue == null) return;
        onUpdate(newValue);
        SPUtil.setBool(storageKey, newValue);
      },
    );
  }
}
