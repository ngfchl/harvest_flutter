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
  List<Map<String, dynamic>> pieDataList = [];
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
    isLoading = true;
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
    update();
    mySiteController.initFlag = true;
    await loadCacheDashData();

    isLoading = false;
    update();
    // 监听后台任务完成的消息
    Future.microtask(() async {
      Logger.instance.i('开始从数据库加载数据...');
      // 模拟后台获取数据
      await mySiteController.getWebSiteListFromServer();
      await mySiteController.getSiteStatusFromServer();
      mySiteController.loadingFromServer = false;
      await initChartData(days);
      Logger.instance.i('从数据库加载数据完成！');
      update(); // UI 更新
    });
  }

  initChartData(days) async {
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

    CommonResponse res = await getDashBoardDataApi(days);
    if (res.succeed) {
      try {
        SPUtil.setCache('$baseUrl - DASHBOARD_DATA', res.data, 3600 * 8);
        parseDashData(res.data);
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
    }

    mySiteController.initFlag = false;
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
                  .map((e) => StatusInfo.fromJson(e as Map<String, dynamic>))
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
                  .map((e) => StatusInfo.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ))
        .toList();
    pieDataList = (data['pieDataList'] as List)
        .map((item) => item as Map<String, dynamic>)
        .toList();
    seedDataList = (data['seedDataList'] as List)
        .map((item) => MetaDataItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
