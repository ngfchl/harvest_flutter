import 'package:easy_refresh/easy_refresh.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:proper_filesize/proper_filesize.dart';
import 'package:random_color/random_color.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../../../../common/card_view.dart';
import '../../../../common/glass_widget.dart';
import '../../../../common/hex_color.dart';
import '../../../../common/utils.dart';
import '../../../../theme/fitness_app_theme.dart';
import '../../../../utils/logger_helper.dart';
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
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GetBuilder<DashBoardController>(builder: (controller) {
        return GlassWidget(
          child: Column(
            children: [
              Expanded(
                child: EasyRefresh(
                  onRefresh: controller.initChartData,
                  child: controller.statusList.isNotEmpty
                      ? ListView(
                          children: [
                            _buildSiteInfoCard(),
                            if (controller.stackChartDataList.isNotEmpty)
                              CustomCard(child: _buildStackedBar()),
                            if (controller.statusList.isNotEmpty)
                              CustomCard(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  child: _buildSiteInfo()),
                            if (controller.statusList.isNotEmpty)
                              CustomCard(child: _buildSmartLabelPieChart()),
                            const SizedBox(height: 40),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSiteInfoCard() {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return CustomCard(
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
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.1,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Icon(Icons.upload),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, bottom: 3),
                                          child: Text(
                                            filesize(controller.totalUploaded),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: FitnessAppTheme.darkerText,
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
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              letterSpacing: -0.2,
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.5),
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
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
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          letterSpacing: -0.1,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        const SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Icon(Icons.download),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, bottom: 3),
                                          child: Text(
                                            filesize(
                                                controller.totalDownloaded),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: FitnessAppTheme.darkerText,
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
                                              fontFamily:
                                                  FitnessAppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              letterSpacing: -0.2,
                                              color: FitnessAppTheme.grey
                                                  .withOpacity(0.5),
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: FitnessAppTheme.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(100.0),
                                ),
                                border: Border.all(
                                    width: 4,
                                    color: FitnessAppTheme.nearlyDarkBlue
                                        .withOpacity(0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${controller.statusList.length}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 24,
                                      letterSpacing: 0.0,
                                      color: FitnessAppTheme.nearlyDarkBlue,
                                    ),
                                  ),
                                  Text(
                                    '站点数',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.0,
                                      color:
                                          FitnessAppTheme.grey.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: CustomPaint(
                              painter: CurvePainter(colors: [
                                FitnessAppTheme.nearlyDarkBlue,
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
                  color: FitnessAppTheme.background,
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
                        const Text(
                          '做种量',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: FitnessAppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            letterSpacing: -0.2,
                            color: FitnessAppTheme.darkText,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            height: 4,
                            width: 70,
                            decoration: BoxDecoration(
                              color: HexColor('#87A0E5').withOpacity(0.2),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 70 / 1.2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      HexColor('#87A0E5'),
                                      HexColor('#87A0E5').withOpacity(0.5),
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
                            filesize(controller.totalSeedVol),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: FitnessAppTheme.fontName,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: FitnessAppTheme.grey.withOpacity(0.5),
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
                            const Text(
                              '做种中',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                letterSpacing: -0.2,
                                color: FitnessAppTheme.darkText,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                height: 4,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: HexColor('#F56E98').withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: ((70 / 2) *
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
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: FitnessAppTheme.grey.withOpacity(0.5),
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
                            const Text(
                              '吸血中',
                              style: TextStyle(
                                fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                letterSpacing: -0.2,
                                color: FitnessAppTheme.darkText,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 0, top: 4),
                              child: Container(
                                height: 4,
                                width: 70,
                                decoration: BoxDecoration(
                                  color: HexColor('#F1B440').withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0)),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: ((70 / 2.5) *
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
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: FitnessAppTheme.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
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
        .map((MySite mySite) => mySite.latestStatusInfo?.uploaded ?? 0)
        .reduce((a, b) => a > b ? a : b);

    int maxDownloaded = controller.statusList
        .map((MySite mySite) => mySite.latestStatusInfo?.downloaded ?? 0)
        .reduce((a, b) => a > b ? a : b);

    var uploadColor = RandomColor().randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.green, ColorHue.blue]),
        colorBrightness: ColorBrightness.dark);
    var downloadColor = RandomColor().randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.red, ColorHue.orange]),
        colorBrightness: ColorBrightness.dark,
        colorSaturation: ColorSaturation.highSaturation);
    return SizedBox(
      height: 200,
      // padding: const EdgeInsets.only(top: 5),
      child: Column(
        children: [
          const Text('站点数据',
              style: TextStyle(fontSize: 12, color: Colors.black38)),
          const SizedBox(height: 5),
          Expanded(
            child: ListView.builder(
                itemCount: controller.statusList.length,
                itemBuilder: (context, index) {
                  MySite mySite = controller.statusList[index];
                  StatusInfo? status = mySite.latestStatusInfo;

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
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black38,
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
                                                borderColor: Color(0xff898989),
                                                color: Colors.transparent),
                                        barPointers: <LinearBarPointer>[
                                          LinearBarPointer(
                                            value: (status?.uploaded ?? 0) /
                                                maxUploaded *
                                                100,
                                            thickness: 16,
                                            edgeStyle: LinearEdgeStyle.bothFlat,
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
                                  text: mySite.nickname,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black38),
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
                                            edgeStyle: LinearEdgeStyle.bothFlat,
                                            borderWidth: 2,
                                            borderColor: Color(0xff898989),
                                            color: Colors.transparent,
                                          ),
                                          barPointers: <LinearBarPointer>[
                                            LinearBarPointer(
                                                value:
                                                    (status?.downloaded ?? 0) /
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
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black38),
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
  }

  Widget _buildSmartLabelPieChart() {
    return Container(
      height: 240,
      padding: const EdgeInsets.only(left: 10),
      child: SfCircularChart(
        title: const ChartTitle(
            text: '上传数据',
            textStyle: TextStyle(
              fontSize: 11,
              color: Colors.black38,
            )),
        centerX: '47%',
        centerY: '45%',
        margin: const EdgeInsets.all(10),
        legend: const Legend(
            position: LegendPosition.left,
            // height: "20",
            isVisible: true,
            iconWidth: 8,
            padding: 5,
            itemPadding: 5,
            // width: '64',
            isResponsive: true,
            // offset: Offset(20, 0),
            // legendItemBuilder:
            //     (String name, dynamic series, dynamic point, int index) {
            //   Logger.instance.w(name);
            //   Logger.instance.w(series.series.dataSource);
            //   Logger.instance.w(point.y);
            //   // Logger.instance.w(index);
            //   StatusInfo status = series.series.dataSource[index];
            //   return Container(
            //     height: 15,
            //     width: 50,
            //     padding: EdgeInsets.zero,
            //     child: Row(
            //       children: [
            //         // const Icon(
            //         //   Icons.ac_unit_outlined,
            //         //   size: 12,
            //         //   color: Colors.black38,
            //         // ),
            //         GFImageOverlay(
            //           height: 10,
            //           width: 10,
            //           image:
            //               NetworkImage('${status.siteUrl}${status.siteLogo}'),
            //         ),
            //         EllipsisText(
            //           text: name,
            //           maxWidth: 38,
            //           style: const TextStyle(
            //             fontSize: 8,
            //             color: Colors.black38,
            //           ),
            //           isShowMore: false,
            //           ellipsis: '..',
            //           maxLines: 1,
            //         ),
            //       ],
            //     ),
            //   );
            // },
            textStyle: TextStyle(
              fontSize: 8,
              color: Colors.black38,
            )),
        series: _getSmartLabelPieSeries(),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: '',
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            return Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.teal.shade300,
                border: Border.all(width: 2, color: Colors.teal.shade400),
              ),
              child: Text(
                '${data.nickname}: ${filesize(data.latestStatusInfo?.uploaded ?? 0)}',
                style: const TextStyle(fontSize: 14, color: Colors.black38),
              ),
            );
          },
        ),
        enableMultiSelection: true,
      ),
    );
  }

  List<PieSeries<MySite, String>> _getSmartLabelPieSeries() {
    return <PieSeries<MySite, String>>[
      PieSeries<MySite, String>(
        name: '站点上传数据汇总',
        dataSource: controller.statusList,
        xValueMapper: (MySite data, _) => data.nickname,
        yValueMapper: (MySite data, _) => data.latestStatusInfo?.uploaded,
        dataLabelMapper: (MySite data, _) =>
            '${data.nickname}: ${filesize(data.latestStatusInfo?.uploaded ?? 0)}',
        enableTooltip: true,
        explode: true,
        explodeIndex: 0,
        explodeOffset: '10%',
        radius: '65%',
        // pointRenderMode: PointRenderMode.gradient,
        dataLabelSettings: const DataLabelSettings(
          margin: EdgeInsets.zero,
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
          textStyle: TextStyle(
            fontSize: 8,
            color: Colors.black38,
          ),
          showZeroValue: false,
          connectorLineSettings: ConnectorLineSettings(
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
      return SizedBox(
        height: 220,
        child: SfCartesianChart(
            title: const ChartTitle(
                text: '每日数据',
                textStyle: TextStyle(
                  fontSize: 11,
                  color: Colors.black38,
                )),
            isTransposed: true,
            margin: const EdgeInsets.all(15),
            legend: const Legend(
                isVisible: false,
                iconWidth: 8,
                iconHeight: 8,
                padding: 5,
                itemPadding: 5,
                textStyle: TextStyle(
                  fontSize: 8,
                  color: Colors.black38,
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
                return Card(
                  color: Colors.white,
                  child: SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(point.x),
                          Text(
                            '${series.name}: ${ProperFilesize.generateHumanReadableFilesize(point.y)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
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
                  const TextStyle(fontSize: 10, color: Colors.black38),
                );
              },
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              axisLabelFormatter: (AxisLabelRenderDetails details) {
                return ChartAxisLabel(
                  filesize(details.value.toInt()),
                  const TextStyle(fontSize: 10, color: Colors.black38),
                );
              },
              majorTickLines: const MajorTickLines(size: 0),
            ),
            series:
                List.generate(controller.stackChartDataList.length, (index) {
              Map siteData = controller.stackChartDataList[index];
              List<StatusInfo> dataSource = siteData['data'].length >= 15
                  ? siteData['data'].sublist(siteData['data'].length - 15)
                  : siteData['data'];
              return StackedBarSeries<StatusInfo, String>(
                name: siteData['site'],
                // width: 0.5,
                borderRadius: BorderRadius.circular(1),
                legendIconType: LegendIconType.circle,
                dataSource: dataSource,
                // isVisibleInLegend: true,
                xValueMapper: (StatusInfo status, loop) =>
                    loop > 0 ? formatCreatedTimeToDateString(status) : null,
                yValueMapper: (StatusInfo status, loop) {
                  if (loop > 0 && loop < dataSource.length) {
                    num increase =
                        status.uploaded - dataSource[loop - 1].uploaded;
                    return increase > 0 ? increase : 0;
                  }
                  return null;
                },
                // pointColorMapper: (StatusInfo status, _) =>
                //     RandomColor().randomColor(),
                emptyPointSettings: const EmptyPointSettings(
                  mode: EmptyPointMode.drop,
                ),
                dataLabelMapper: (StatusInfo status, _) => siteData['site'],
                // color: RandomColor().randomColor(),
                // enableTooltip: true,
              );
            }).toList()),
      );
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
