import 'package:get/get.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/utils/storage.dart';
import 'package:intl/intl.dart';

import '../../../../models/authinfo.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../../utils/logger_helper.dart';
import '../models/my_site.dart';
import '../my_site/controller.dart';

class DashBoardController extends GetxController {
  MySiteController mySiteController = Get.find();

  List<String> excludeUrlList = [
    'https://ssdforum.org/',
    'https://cnlang.org/',
  ];
  List<MySite> statusList = [];
  List<Map<String, dynamic>> pieDataList = [
    // {
    //   'genre': '站点',
    //   'sold': 10240000,
    // }
  ];
  List<Map> stackChartDataList = [];
  List<MetaDataItem> seedDataList = [];
  List<Map> uploadIncrementDataList = [];
  List<MetaDataItem> uploadMonthIncrementDataList = [];
  List<Map> downloadIncrementDataList = [];
  int totalUploaded = 0;
  int totalDownloaded = 0;
  int todayUploadIncrement = 0;
  int todayDownloadIncrement = 0;
  int totalSeedVol = 0;
  int totalSeeding = 0;
  int totalLeeching = 0;
  bool privateMode = false;
  bool isLoading = false;
  bool buildSiteInfoCard = true;
  bool buildSmartLabelPieChart = true;
  bool buildSeedVolumePieChart = true;
  bool buildStackedBar = true;
  bool buildMonthStackedBar = true;
  bool buildSiteInfo = true;
  bool showTodayUploadedIncrement = true;
  bool showTodayDownloadedIncrement = true;
  int days = 7;
  int maxDays = 0;
  int initCount = 0;
  AuthInfo? userinfo;

  @override
  void onInit() {
    userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo'));
    initData();
    super.onInit();
  }

  Future<void> initData() async {
    isLoading = true;
    update();
    mySiteController.initFlag = true;
    await initChartData();

    isLoading = false;
    update();
    // 监听后台任务完成的消息
    Future.microtask(() async {
      Logger.instance.i('开始从数据库加载数据...');
      // 模拟后台获取数据
      await mySiteController.getWebSiteListFromServer();
      await mySiteController.getSiteStatusFromServer();
      mySiteController.loadingFromServer = false;
      await initChartData();
      Logger.instance.i('从数据库加载数据完成！');
      update(); // UI 更新
    });
  }

  Future<void> initChartData() async {
    totalUploaded = 0;
    totalDownloaded = 0;
    totalSeedVol = 0;
    totalSeeding = 0;
    totalLeeching = 0;
    todayUploadIncrement = 0;
    todayDownloadIncrement = 0;
    uploadIncrementDataList.clear();
    uploadMonthIncrementDataList.clear();
    downloadIncrementDataList.clear();
    privateMode = SPUtil.getBool('DashBoardPrivateMode', defaultValue: false)!;
    List<String> dateList = generateDateList(days);
    String todayStr = getTodayString();
    String yesterdayStr = getYesterdayString();
    List<String> monthList = getLastDaysOfPastYear();
    monthList.add(todayStr);
    if (mySiteController.mySiteList.isEmpty) {
      await mySiteController.loadCacheInfo();
      update();
      mySiteController.initFlag = false;
    }
    statusList = mySiteController.mySiteList;
    statusList.sort((MySite a, MySite b) {
      final StatusInfo? statusA = a.latestStatusInfo;
      final StatusInfo? statusB = b.latestStatusInfo;

      // 使用 null-aware 操作符和三元表达式进行比较和排序
      return (statusB?.uploaded ?? 0).compareTo(statusA?.uploaded ?? 0);
    });
    stackChartDataList.clear();
    seedDataList.clear();

    for (final MySite mySite
        in statusList.where((item) => !excludeUrlList.contains(item.mirror))) {
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
        Map<String, dynamic> monthStatusInfoMap = Map.fromEntries(mySite
            .statusInfo.entries
            .where((entry) => monthList.contains(entry.key)));
        Logger.instance.d("${mySite.nickname}: $monthStatusInfoMap");
        stackChartDataList
            .add({'site': mySite.nickname, 'data': statusInfoList});
        uploadMonthIncrementDataList.add(
            MetaDataItem(name: mySite.nickname, value: monthStatusInfoMap));
        if (mySite.available == true && mySite.statusInfo.length > 1) {
          int increment = mySite.statusInfo[todayStr] != null &&
                  mySite.statusInfo[yesterdayStr] != null
              ? mySite.statusInfo[todayStr]!.uploaded -
                  mySite.statusInfo[yesterdayStr]!.uploaded
              : 0;
          int downloaded = mySite.statusInfo[todayStr] != null &&
                  mySite.statusInfo[yesterdayStr] != null
              ? mySite.statusInfo[todayStr]!.downloaded -
                  mySite.statusInfo[yesterdayStr]!.downloaded
              : 0;
          if (increment > 0) {
            todayUploadIncrement += increment;
            uploadIncrementDataList
                .add({'site': mySite.nickname, 'data': increment});
          }
          if (downloaded > 0) {
            todayDownloadIncrement += downloaded;
            downloadIncrementDataList
                .add({'site': mySite.nickname, 'data': downloaded});
          }
        }
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
        seedDataList.add(MetaDataItem(
            name: mySite.nickname, value: currentStatus.seedVolume));
      }
      // 若当前站点无状态信息，添加默认的饼图数据
      else {
        pieDataList.add({'genre': mySite.nickname, 'sold': 0});
      }
    }
    Logger.instance.d('上传增量列表：$uploadIncrementDataList');
    Logger.instance.d('下载增量列表：$downloadIncrementDataList');
    uploadIncrementDataList
        .sort((Map a, Map b) => b["data"].compareTo(a["data"]));

    downloadIncrementDataList
        .sort((Map a, Map b) => b["data"].compareTo(a["data"]));
    seedDataList.sort((a, b) => b.value.compareTo(a.value));
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
