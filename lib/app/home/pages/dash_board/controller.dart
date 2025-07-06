import 'package:get/get.dart';
import 'package:harvest/api/mysite.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/storage.dart';

import '../../../../models/authinfo.dart';
import '../../../../utils/logger_helper.dart';
import '../models/my_site.dart';
import '../my_site/controller.dart';

class DashBoardController extends GetxController {
  MySiteController mySiteController = Get.find();

  List<String> excludeUrlList = [
    'https://ssdforum.org/',
    'https://cnlang.org/',
  ];
  List<MetaDataItem> emailMap = [];
  List<MetaDataItem> usernameMap = [];
  List<MetaDataItem> statusList = [];
  List<MetaDataItem> stackChartDataList = [];
  List<MetaDataItem> seedDataList = [];
  List<MetaDataItem> uploadIncrementDataList = [];
  List<MetaDataItem> uploadMonthIncrementDataList = [];
  List<MetaDataItem> downloadIncrementDataList = [];
  int totalUploaded = 0;
  int totalPublished = 0;
  int totalDownloaded = 0;
  int todayUploadIncrement = 0;
  int todayDownloadIncrement = 0;
  int totalSeedVol = 0;
  int totalSeeding = 0;
  int totalLeeching = 0;
  String updatedAt = '';
  bool privateMode = false;
  bool isLoading = false;
  bool isCacheLoading = false;
  bool isStackedLoading = false;
  double cardHeight = 260;
  bool buildSiteInfoCard = true;
  bool buildAccountInfoCard = false;
  bool buildMonthPublishedBar = true;
  bool buildPublishedPieChart = true;
  bool buildSmartLabelPieChart = true;
  bool buildSeedVolumePieChart = true;
  bool buildMonthDownloadedBar = true;
  bool buildStackedBar = true;
  bool buildMonthStackedBar = true;
  bool buildSiteInfo = true;
  bool showTodayUploadedIncrement = true;
  bool showTodayDownloadedIncrement = true;
  MySite? earliestSite;
  int days = 7;
  int maxDays = 0;
  int siteCount = 0;
  AuthInfo? userinfo;
  String? baseUrl;

  @override
  void onInit() {
    userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo'));
    baseUrl = SPUtil.getLocalStorage('server');
    initData();
    super.onInit();
  }

  Future<void> initData() async {
    privateMode = SPUtil.getBool('privateMode', defaultValue: false)!;
    cardHeight = SPUtil.getDouble('buildCardHeight', defaultValue: 260)!;
    buildStackedBar = SPUtil.getBool('buildStackedBar', defaultValue: true)!;
    buildSeedVolumePieChart =
        SPUtil.getBool('buildSeedVolumePieChart', defaultValue: true)!;
    buildSmartLabelPieChart =
        SPUtil.getBool('buildSmartLabelPieChart', defaultValue: true)!;
    buildAccountInfoCard =
        SPUtil.getBool('buildAccountInfoCard', defaultValue: true)!;
    buildMonthPublishedBar =
        SPUtil.getBool('buildMonthPublishedBar', defaultValue: true)!;
    buildMonthDownloadedBar =
        SPUtil.getBool('buildMonthDownloadedBar', defaultValue: true)!;
    buildPublishedPieChart =
        SPUtil.getBool('buildPublishedPieChart', defaultValue: true)!;
    buildMonthStackedBar =
        SPUtil.getBool('buildMonthStackedBar', defaultValue: true)!;
    buildSiteInfo = SPUtil.getBool('buildSiteInfo', defaultValue: true)!;
    showTodayUploadedIncrement =
        SPUtil.getBool('showTodayUploadedIncrement', defaultValue: true)!;
    showTodayDownloadedIncrement =
        SPUtil.getBool('showTodayDownloadedIncrement', defaultValue: true)!;
    isCacheLoading = true;
    update();
    await loadCacheDashData();
    isCacheLoading = false;
    update();
    // 监听后台任务完成的消息
    Future.microtask(() async {
      Logger.instance.i('开始从数据库加载数据...');
      isLoading = true;
      update();
      // 模拟后台获取数据
      await initChartData();
      isLoading = false;
      Logger.instance.i('从数据库加载数据完成！');
      update(); // UI 更新
      mySiteController.loadCacheInfo();
      mySiteController.getWebSiteListFromServer();
      mySiteController.getSiteStatusFromServer();
      mySiteController.loadingFromServer = false;
    });
  }

  initChartData() async {
    // 记录开始时间
    DateTime startTime = DateTime.now();
    CommonResponse res = await getDashBoardDataApi(14);
    var endTime = DateTime.now();
    // 计算耗时
    var duration = endTime.difference(startTime);
    Logger.instance.d('网络加载首页数据耗时: ${duration.inMilliseconds} 毫秒');
    if (res.succeed) {
      try {
        // 清空数据
        Logger.instance.i('开始初始化页面数据...');
        totalUploaded = 0;
        totalPublished = 0;
        totalDownloaded = 0;
        totalSeedVol = 0;
        totalSeeding = 0;
        totalLeeching = 0;
        todayUploadIncrement = 0;
        todayDownloadIncrement = 0;
        updatedAt = '';
        emailMap.clear();
        usernameMap.clear();
        uploadIncrementDataList.clear();
        uploadMonthIncrementDataList.clear();
        downloadIncrementDataList.clear();
        Logger.instance.i('初始化页面数据完成,开始解析数据...');
        parseDashData(res.data);
        Logger.instance.i('缓存数据完成，缓存中...');
        SPUtil.setCache('$baseUrl - DASHBOARD_DATA', res.data, 3600 * 24);
        Logger.instance.i('缓存数据完成！');
      } catch (e, trace) {
        String message = '仪表数据解析失败啦～${e.toString()} ${trace.toString()}';
        Logger.instance.e(message);
        Get.snackbar('仪表数据解析失败啦～', message);
      }
    } else {
      Get.snackbar('仪表数据加载失败！～', res.msg);
    }
    endTime = DateTime.now();
    // 计算耗时
    duration = endTime.difference(startTime);
    Logger.instance.d('加载首页数据耗时: ${duration.inMilliseconds} 毫秒');
  }

  loadCacheDashData() async {
    String key = '$baseUrl - DASHBOARD_DATA';
    try {
      Map<String, dynamic>? data = await SPUtil.getCache(key);
      Logger.instance.i('开始从本地缓存加载数据...${data.isNotEmpty}');
      if (data.isNotEmpty) {
        parseDashData(data);
        Logger.instance.i('开始从缓存加载数据完成...');
      } else {
        Logger.instance.i('无缓存数据，跳过...');
      }
    } catch (e, trace) {
      String msg = '从缓存加载数据失败啦～$e';
      await SPUtil.remove(key);
      Logger.instance.e(msg);
      Logger.instance.d(trace);
    }
  }

  /*///@title 解析首页dash 数据
  ///@description
  ///@updateTime
   */
  parseDashData(data) {
    emailMap = (data['emailCount'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
    usernameMap = (data['usernameCount'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
    updatedAt = data['updatedAt'] ?? '';
    totalUploaded = data['totalUploaded'] ?? 0;
    totalDownloaded = data['totalDownloaded'] ?? 0;
    totalPublished = data['totalPublished'] ?? 0;
    totalSeedVol = data['totalSeedVol'] ?? 0;
    totalSeeding = data['totalSeeding'] ?? 0;
    totalLeeching = data['totalLeeching'] ?? 0;
    siteCount = data['siteCount'] ?? 0;
    todayUploadIncrement = data['todayUploadIncrement'] ?? 0;
    todayDownloadIncrement = data['todayDownloadIncrement'] ?? 0;
    uploadIncrementDataList = (data['uploadIncrementDataList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();

    downloadIncrementDataList = (data['downloadIncrementDataList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
    uploadMonthIncrementDataList = (data['uploadMonthIncrementDataList']
            as List)
        .map((el) => MetaDataItem(
              name: el['name'] as String,
              value: (el['value'] as List<dynamic>)
                  .map((e) => TrafficDelta.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ))
        .toList();
    statusList = (data['statusList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
    earliestSite = MySite.fromJson(data['earliestSite']);
    stackChartDataList = (data['stackChartDataList'] as List<dynamic>)
        .map((el) => MetaDataItem(
              name: el['name'] as String,
              value: (el['value'] as List<dynamic>)
                  .map((e) => TrafficDelta.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ))
        .toList();
    seedDataList = (data['seedDataList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
