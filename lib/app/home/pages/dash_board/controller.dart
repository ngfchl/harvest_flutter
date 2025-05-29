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
  List<MetaDataItem> statusList = [];
  List<MetaDataItem> stackChartDataList = [];
  List<MetaDataItem> seedDataList = [];
  List<MetaDataItem> uploadIncrementDataList = [];
  List<MetaDataItem> uploadMonthIncrementDataList = [];
  List<MetaDataItem> downloadIncrementDataList = [];
  int totalUploaded = 0;
  int totalDownloaded = 0;
  int todayUploadIncrement = 0;
  int todayDownloadIncrement = 0;
  int totalSeedVol = 0;
  int totalSeeding = 0;
  int totalLeeching = 0;
  bool privateMode = false;
  bool isLoading = false;
  bool isCacheLoading = false;
  bool isStackedLoading = false;
  bool buildSiteInfoCard = true;
  bool buildSmartLabelPieChart = true;
  bool buildSeedVolumePieChart = true;
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

  @override
  void onInit() {
    userinfo = AuthInfo.fromJson(SPUtil.getLocalStorage('userinfo'));
    initData();
    super.onInit();
  }

  Future<void> initData() async {
    privateMode = SPUtil.getBool('privateMode', defaultValue: false)!;
    buildStackedBar = SPUtil.getBool('buildStackedBar', defaultValue: true)!;
    buildSeedVolumePieChart =
        SPUtil.getBool('buildSeedVolumePieChart', defaultValue: true)!;
    buildSmartLabelPieChart =
        SPUtil.getBool('buildSmartLabelPieChart', defaultValue: true)!;
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
    });
  }

  initChartData() async {
    mySiteController.loadCacheInfo();
    mySiteController.getWebSiteListFromServer();
    mySiteController.getSiteStatusFromServer();
    mySiteController.loadingFromServer = false;
    CommonResponse res = await getDashBoardDataApi(14);
    if (res.succeed) {
      try {
        // 清空数据
        Logger.instance.i('开始初始化页面数据...');
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
        Logger.instance.i('初始化页面数据完成,开始解析数据...');
        parseDashData(res.data);
        Logger.instance.i('缓存数据完成，缓存中...');
        SPUtil.setCache('$baseUrl - DASHBOARD_DATA', res.data, 3600 * 24);
        Logger.instance.i('缓存数据完成！');
      } catch (e) {
        String message = '仪表数据解析失败啦～${e.toString()}';
        Logger.instance.e(message);
        Get.snackbar('仪表数据解析失败啦～', message);
      }
    } else {
      Get.snackbar('仪表数据加载失败！～', res.msg);
    }
  }

  loadCacheDashData() async {
    String key = '$baseUrl - DASHBOARD_DATA';
    Map<String, dynamic>? data = await SPUtil.getCache(key);
    Logger.instance.i('开始从本地缓存加载数据...${data.isNotEmpty}');
    if (data.isNotEmpty) {
      parseDashData(data);
      Logger.instance.i('开始从缓存加载数据完成...');
    } else {
      Logger.instance.i('无缓存数据，跳过...');
    }
  }

  /*///@title 解析首页dash 数据
  ///@description
  ///@updateTime
   */
  parseDashData(data) {
    totalUploaded = data['totalUploaded'];
    totalDownloaded = data['totalDownloaded'];
    totalSeedVol = data['totalSeedVol'];
    totalSeeding = data['totalSeeding'];
    totalLeeching = data['totalLeeching'];
    siteCount = data['siteCount'] ?? 0;
    todayUploadIncrement = data['todayUploadIncrement'];
    todayDownloadIncrement = data['todayDownloadIncrement'];
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
    Logger.instance
        .i('stackChartDataList: ${stackChartDataList[1].value?.length}.');
    seedDataList = (data['seedDataList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
    update();
  }
}
