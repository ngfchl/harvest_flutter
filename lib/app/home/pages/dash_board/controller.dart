import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/my_site.dart';
import '../my_site/controller.dart';

class DashBoardController extends GetxController {
  MySiteController mySiteController = Get.find();

  List<MySite> statusList = [];
  List<Map<String, dynamic>> pieDataList = [
    // {
    //   'genre': '站点',
    //   'sold': 10240000,
    // }
  ];
  List<Map> stackChartDataList = [];
  int totalUploaded = 0;
  int totalDownloaded = 0;
  int totalSeedVol = 0;
  int totalSeeding = 0;
  int totalLeeching = 0;
  bool isLoading = false;
  int days = 7;
  int maxDays = 0;

  @override
  void onInit() {
    initData();

    super.onInit();
  }

  Future<void> initData() async {
    isLoading = true;
    update();
    await initChartData();
    isLoading = false;
    update();
  }

  Future<void> initChartData() async {
    totalUploaded = 0;
    totalDownloaded = 0;
    totalSeedVol = 0;
    totalSeeding = 0;
    totalLeeching = 0;
    List<String> dateList = generateDateList(days);
    if (statusList.isEmpty) {
      await mySiteController.initData();
      statusList = mySiteController.mySiteList;
    }
    statusList.sort((MySite a, MySite b) {
      final StatusInfo? statusA = a.latestStatusInfo;
      final StatusInfo? statusB = b.latestStatusInfo;

      // 使用 null-aware 操作符和三元表达式进行比较和排序
      return (statusB?.uploaded ?? 0).compareTo(statusA?.uploaded ?? 0);
    });
    stackChartDataList.clear();
    pieDataList.clear();

    for (final MySite mySite in statusList) {
      final StatusInfo? currentStatus = mySite.latestStatusInfo;
      maxDays = mySite.statusInfo.length > maxDays
          ? mySite.statusInfo.length
          : maxDays;
      // 添加堆叠图表数据
      if (mySite.statusInfo.isNotEmpty) {
        dateList.sort((String a, String b) => a.compareTo(b));
        List<StatusInfo?> statusInfoList = dateList
            .map((e) => mySite.statusInfo[e])
            .where((element) => element != null)
            .toList();

        stackChartDataList
            .add({'site': mySite.nickname, 'data': statusInfoList});
      }
      // 处理存在状态信息的情况
      if (currentStatus != null) {
        // 添加饼图数据
        pieDataList
            .add({'genre': mySite.nickname, 'sold': currentStatus.uploaded});

        // 累加统计值
        totalUploaded += currentStatus.uploaded;
        totalDownloaded += currentStatus.downloaded;
        totalSeedVol += currentStatus.seedVolume;
        totalSeeding += currentStatus.seed;
        totalLeeching += currentStatus.leech;
      }
      // 若当前站点无状态信息，添加默认的饼图数据
      else {
        pieDataList.add({'genre': mySite.nickname, 'sold': 0});
      }
    }
    isLoading = false;
    update();
  }

  List<String> generateDateList(days) {
    // 当前日期
    DateTime currentDate = DateTime.now();

    // 直接生成最近15天的日期列表
    List<String> recentDates = List.generate(
        days + 1,
        (i) => DateFormat('yyyy-MM-dd')
            .format(currentDate.subtract(Duration(days: i))));

    return recentDates;
  }
}
