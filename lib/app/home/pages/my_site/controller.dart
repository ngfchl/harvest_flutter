import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../api/mysite.dart';
import '../../../../utils/date_time_utils.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';

class MySiteController extends GetxController {
  final searchController = TextEditingController();
  String searchKey = '';
  String filterKey = 'available';
  List<MySite> mySiteList = <MySite>[];
  List<MySite> showStatusList = <MySite>[];
  bool loading = false;
  bool siteCardView = false;
  bool initFlag = false;
  bool loadingFromServer = false;
  bool openByInnerExplorer = true;
  String sortKey = 'statusMail';
  late String baseUrl;
  bool sortReversed = false;
  bool searching = false;
  Map<String, WebSite> webSiteList = {};
  String selectTag = '全部';
  List<String> tagList = [];

  List<MetaDataItem> siteSortOptions = [
    // {'name': '站点ID', 'value': 'mySiteId'},
    {'name': '排序ID', 'value': 'mySiteSortId'},
    {'name': '站点名称', 'value': 'siteName'},
    {'name': '站点昵称', 'value': 'mySiteNickname'},
    {'name': '注册时间', 'value': 'mySiteJoined'},
    {'name': '更新时间', 'value': 'updatedAt'},
    {'name': '最后访问', 'value': 'latestActive'},
    // {'name': '站点链接', 'value': 'siteUrl'},
    {'name': '做种体积', 'value': 'statusSeedVolume'},
    {'name': '站点魔力', 'value': 'statusMyBonus'},
    {'name': '站点积分', 'value': 'statusMyScore'},
    {'name': '上传量', 'value': 'statusUploaded'},
    {'name': '下载量', 'value': 'statusDownloaded'},
    {'name': '上传增量', 'value': 'statusUploadedDelta'},
    {'name': '下载增量', 'value': 'statusDownloadedDelta'},
    {'name': '发种量', 'value': 'statusPublished'},
    {'name': '时魔', 'value': 'statusBonusHour'},
    {'name': '邀请', 'value': 'statusInvitation'},
    {'name': '正在下载', 'value': 'statusLeech'},
    {'name': '正在做种', 'value': 'statusSeed'},
    {'name': '分享率', 'value': 'statusRatio'},
  ].map((item) => MetaDataItem.fromJson(item)).toList();

  List<MetaDataItem> filterOptions = [
    {'name': '清除筛选', 'value': ''},
    {'name': '站点存活', 'value': 'available'},
    {'name': '站点死亡', 'value': 'unavailable'},
    {'name': '未签到', 'value': 'signIn'},
    {'name': '有新邮件', 'value': 'mail'},
    {'name': '有新公告', 'value': 'notice'},
    {'name': '无今日数据', 'value': 'status'},
    {'name': '上传增量', 'value': 'statusUploadedDelta'},
    {'name': '下载增量', 'value': 'statusDownloadedDelta'},
    {'name': '无代理', 'value': 'proxy'},
    {'name': '无 UID', 'value': 'userId'},
    {'name': '无用户名称', 'value': 'username'},
    {'name': '无邮箱地址', 'value': 'email'},
    {'name': '无签到记录', 'value': 'signInInfo'},
    {'name': '无 Cookie', 'value': 'cookie'},
    {'name': '无 PassKey', 'value': 'passkey'},
    {'name': '无 AuthKey', 'value': 'authKey'},
    {'name': '无站点数据', 'value': 'statusInfo'},
    {'name': '注册时间不正常', 'value': 'timeJoin'},
    {'name': '有邀请', 'value': 'invitation'},
    {'name': '无做种', 'value': 'noSeed'},
    {'name': '有下载', 'value': 'leech'},
    {'name': '分享率异常', 'value': 'ratio'},
  ].map((item) => MetaDataItem.fromJson(item)).toList();

  @override
  void onInit() async {
    searchKey = '';
    filterKey = 'available';
    siteCardView = SPUtil.getBool('mySite-siteCardView', defaultValue: false);
    sortKey = SPUtil.getString('mySite-sortKey', defaultValue: 'mySiteSortId');
    sortReversed = SPUtil.getBool('mySite-sortReversed', defaultValue: false);
    openByInnerExplorer = SPUtil.getBool('openByInnerExplorer', defaultValue: true);
    baseUrl = SPUtil.getString('server');
    loading = true;
    loadingFromServer = true;
    update();
    await initData();
    super.onInit();
  }

  initData() async {
    if (!initFlag) {
      return;
    }

    await loadCacheInfo();
    filterByKey();
    update();
    // 启动后台 Isolate
    Future.microtask(() async {
      Logger.instance.i('开始从数据库加载数据...');
      // 模拟后台获取数据
      await getWebSiteListFromServer();
      await getSiteStatusFromServer();
      loadingFromServer = false;
      Logger.instance.i('从数据库加载数据完成！');
      update(); // UI 更新
    });
  }

  Map<String, WebSite> buildTrackerToWebSite() {
    return webSiteList.values.toList().asMap().entries.fold({}, (result, entry) {
      result[entry.value.tracker] = entry.value;
      return result;
    });
  }

  updateTagList() {
    tagList = tagList
        .toSet()
        .where((item) => item.isNotEmpty)
        .map((item) => item.trim())
        .toSet()
        .whereType<String>()
        .toList();
    tagList.sort((a, b) => a.compareTo(b));
  }

  /*///@title 从缓存加载站点信息数据
  ///@description TODO
  ///@updateTime 2024-10-28
   */
  loadCacheInfo() async {
    try {
      // 记录开始时间
      Logger.instance.d('开始从缓存加载站点数据');
      DateTime startTime = DateTime.now();
      Map webSiteListMap = await SPUtil.getCache('$baseUrl - webSiteList');
      Map mySiteListMap = await SPUtil.getCache('$baseUrl - mySiteList');

      if (webSiteListMap.isNotEmpty) {
        Logger.instance.d('共获取到站点配置缓存：${webSiteListMap['webSiteList'].length} 条');
        List<WebSite> webSiteObjectList =
            webSiteListMap['webSiteList'].map((item) => WebSite.fromJson(item)).toList().cast<WebSite>();
        webSiteList = webSiteObjectList.asMap().entries.fold({}, (result, entry) {
          result[entry.value.name] = entry.value;
          return result;
        });
        Logger.instance.d('获取站点配置缓存耗时: ${DateTime.now().difference(startTime).inMilliseconds} 毫秒');
      }

      if (mySiteListMap.isNotEmpty) {
        try {
          Logger.instance.d('共获取站点信息缓存：${mySiteListMap['mySiteList'].length} 条');
          mySiteList = mySiteListMap['mySiteList']?.map((item) => MySite.fromJson(item)).toList().cast<MySite>();
          for (var site in mySiteList) {
            tagList.addAll(site.tags);
          }
          updateTagList();

          if (mySiteList.isNotEmpty) loading = false;
          Logger.instance.d('获取站点信息缓存耗时: ${DateTime.now().difference(startTime).inMilliseconds} 毫秒');
        } catch (e, trace) {
          Logger.instance.e(e);
          Logger.instance.d(trace);
        }
      }
    } catch (e, trace) {
      String msg = '从缓存加载站点数据失败$e';
      Logger.instance.e(msg);
      Logger.instance.d(trace);
    }
  }

  Future<void> getWebSiteListFromServer() async {
    // 记录开始时间
    DateTime startTime = DateTime.now();
    CommonResponse value = await getWebSiteList();
    if (value.code == 0) {
      webSiteList = value.data;
    } else {
      Logger.instance.e(value.msg);
      Get.snackbar(
        '',
        value.msg.toString(),
      );
    }
    // 记录结束时间
    DateTime endTime = DateTime.now();
    // 计算耗时
    Duration duration = endTime.difference(startTime);
    Logger.instance.d('获取站点配置程序耗时: ${duration.inMilliseconds} 毫秒');
  }

  Future<void> getSiteStatusFromServer() async {
    // 记录开始时间
    DateTime startTime = DateTime.now();
    CommonResponse res = await getMySiteList();

    // 记录结束时间
    var endTime = DateTime.now();
    // 计算耗时
    var duration = endTime.difference(startTime);
    Logger.instance.d('加载站点信息列表程序耗时: ${duration.inMilliseconds} 毫秒');
    if (res.succeed) {
      mySiteList = res.data;
      for (var site in mySiteList) {
        tagList.addAll(site.tags);
      }
      updateTagList();
      filterByKey();
      loading = false;
    } else {
      Logger.instance.e(res.msg);
      Get.snackbar(
        '',
        res.msg.toString(),
      );
    }
    // 记录结束时间
    endTime = DateTime.now();
    // 计算耗时
    duration = endTime.difference(startTime);
    Logger.instance.d('解析站点信息列表程序耗时: ${duration.inMilliseconds} 毫秒');
  }

  Future<CommonResponse> saveMySiteToServer(MySite mySite) async {
    CommonResponse response;
    if (mySite.id != 0) {
      response = await editMySite(mySite);
    } else {
      response = await saveMySite(mySite);
    }
    return response;
  }

  Future<CommonResponse> removeSiteFromServer(MySite mySite) async {
    return await removeMySite(mySite);
  }

  void sortStatusList() {
    Logger.instance.i('当前排序方式：$sortKey');
    SPUtil.setString('mySite-sortKey', sortKey);
    SPUtil.setBool('mySite-sortReversed', sortReversed);
    // 拆分数据为有消息和无消息两组
    // 有消息的数据
    List<MySite> mailStatusList = showStatusList
        .where((item) => item.statusInfo.isNotEmpty && (item.mail ?? 0) + (item.notice ?? 0) > 0)
        .toList();
    // 对有消息的数据排序
    if (mailStatusList.isNotEmpty) {
      mailStatusList.sort((a, b) => (b.mail! + b.notice!).compareTo(a.mail! + a.notice!));
    }
    // 无消息的数据
    List<MySite> otherStatusList = showStatusList
        .where((item) =>
            item.statusInfo.isEmpty || (item.statusInfo.isNotEmpty && (item.mail ?? 0) + (item.notice ?? 0) <= 0))
        .toList();
    // 根据不同的排序键调用不同的排序方法
    switch (sortKey) {
      case 'mySiteId':
        otherStatusList.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'mySiteSortId':
        otherStatusList.sort((a, b) => a.sortId.compareTo(b.sortId));
        break;
      case 'statusUploadedDelta':
        otherStatusList.sort((a, b) => a.dailyDelta.uploaded.compareTo(b.dailyDelta.uploaded));
        break;
      case 'statusDownloadedDelta':
        otherStatusList.sort((a, b) => a.dailyDelta.downloaded.compareTo(b.dailyDelta.downloaded));
        break;
      case 'siteName':
        otherStatusList.sort((a, b) => a.site.compareTo(b.site));
        break;
      case 'mySiteNickname':
        otherStatusList.sort((a, b) => a.nickname.compareTo(b.nickname));
        break;
      case 'mySiteJoined':
        otherStatusList.sort((a, b) => a.timeJoin.compareTo(b.timeJoin));
        break;
      case 'updatedAt':
        otherStatusList.sort(
            (a, b) => a.latestStatusInfo?.updatedAt.compareTo(b.latestStatusInfo?.updatedAt ?? DateTime(2012)) ?? 0);
        break;
      case 'siteUrl':
        otherStatusList.sort((a, b) => a.mirror!.compareTo(b.mirror!));
        break;
      case 'latestActive':
        otherStatusList.sort((a, b) => (a.latestActive ?? DateTime(2012)).compareTo(b.latestActive ?? DateTime(2012)));
        break;
      case 'statusSeedVolume':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.seedVolume ?? 0).compareTo(b.latestStatusInfo?.seedVolume ?? 0));
        break;
      case 'statusMyBonus':
        otherStatusList.sort((a, b) => (a.latestStatusInfo?.myBonus ?? 0).compareTo(b.latestStatusInfo?.myBonus ?? 0));
        break;
      case 'statusMyScore':
        otherStatusList.sort((a, b) => (a.latestStatusInfo?.myScore ?? 0).compareTo(b.latestStatusInfo?.myScore ?? 0));
        break;
      case 'statusDownloaded':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.downloaded ?? 0).compareTo(b.latestStatusInfo?.downloaded ?? 0));
        break;
      case 'statusUploaded':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.uploaded ?? 0).compareTo(b.latestStatusInfo?.uploaded ?? 0));
        break;
      case 'statusPublished':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.published ?? 0).compareTo(b.latestStatusInfo?.published ?? 0));
        break;
      case 'statusBonusHour':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.bonusHour ?? 0).compareTo(b.latestStatusInfo?.bonusHour ?? 0));
        break;
      case 'statusInvitation':
        otherStatusList
            .sort((a, b) => (a.latestStatusInfo?.invitation ?? 0).compareTo(b.latestStatusInfo?.invitation ?? 0));
        break;
      case 'statusLeech':
        otherStatusList.sort((a, b) => (a.latestStatusInfo?.leech ?? 0).compareTo(b.latestStatusInfo?.leech ?? 0));
        break;
      case 'statusSeed':
        otherStatusList.sort((a, b) => (a.latestStatusInfo?.seed ?? 0).compareTo(b.latestStatusInfo?.seed ?? 0));
        break;
      case 'statusRatio':
        otherStatusList.sort((a, b) => (a.latestStatusInfo?.ratio ?? 0).compareTo(b.latestStatusInfo?.ratio ?? 0));
        break;
    }

    // 反转序列
    if (sortReversed == true) {
      Logger.instance.d('反转序列！');
      otherStatusList = otherStatusList.reversed.toList();
    }
    showStatusList = [...mailStatusList, ...otherStatusList];
    update();
  }

  List<MySite> filterSiteStatusBySearchKey(List<MySite> toSearchList) {
    if (searchKey.isNotEmpty) {
      return toSearchList.where((site) {
        var lowerCaseSearchKey = searchKey.toLowerCase();
        return site.nickname.toLowerCase().contains(lowerCaseSearchKey) ||
            (site.username?.toLowerCase().contains(lowerCaseSearchKey) ?? false) ||
            (site.email?.toLowerCase().contains(lowerCaseSearchKey) ?? false) ||
            (site.mirror?.toLowerCase().contains(lowerCaseSearchKey) ?? false) ||
            site.site.toLowerCase().contains(lowerCaseSearchKey);
      }).toList();
    } else {
      return toSearchList;
    }
  }

  void filterByKey() {
    StatusInfo? getLatestStatusInfo(MySite item) {
      if (item.statusInfo.isEmpty) return null;
      final latestDate = item.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
      return item.statusInfo[latestDate];
    }

    Logger.instance.i('开始筛选，当前筛选关键字：$filterKey');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<MySite> filtered = List.from(mySiteList);

    Map<String, bool Function(MySite)> conditionMap = {
      'available': (item) => item.available,
      'unavailable': (item) => !item.available,
      'statusUploadedDelta': (item) => item.dailyDelta.uploaded > 0,
      'statusDownloadedDelta': (item) => item.dailyDelta.downloaded > 0,
      'passkey': (item) => item.passkey == null || item.passkey!.isEmpty,
      'authKey': (item) => item.authKey == null || item.authKey!.isEmpty,
      'cookie': (item) => item.cookie == null || item.cookie!.isEmpty,
      'proxy': (item) => item.proxy == null || item.proxy!.isEmpty,
      'timeJoin': (item) => item.timeJoin == '2024-02-01T00:00:00',
      'mail': (item) => item.mail != null && item.mail! > 0,
      'notice': (item) => item.notice != null && item.notice! > 0,
      'signInInfo': (item) =>
          item.available && webSiteList[item.site]?.signIn == true && item.signIn && item.signInInfo.isEmpty,
      'statusInfo': (item) => item.statusInfo.isEmpty,
      'signIn': (item) => item.available && item.signIn && item.signInInfo[today] == null,
      'status': (item) {
        final info = item.statusInfo[today];
        return item.available && (info == null || !isToday(info.updatedAt.toString()));
      },
      'userId': (item) => item.userId == null || item.userId!.isEmpty,
      'username': (item) => item.username == null || item.username!.isEmpty,
      'email': (item) => item.email == null || item.email!.isEmpty,
      'invitation': (item) {
        final info = getLatestStatusInfo(item);
        return info != null && info.invitation > 0;
      },
      'noSeed': (item) {
        if (!item.available) return false;
        final info = getLatestStatusInfo(item);
        return info != null && info.seed <= 0;
      },
      'leech': (item) {
        if (!item.available) return false;
        final info = getLatestStatusInfo(item);
        return info != null && info.leech > 0;
      },
      'ratio': (item) {
        if (item.available) return false;
        final info = getLatestStatusInfo(item);
        return info != null && info.ratio > 0 && info.ratio <= 1;
      },
    };

    // 应用筛选条件
    if (conditionMap.containsKey(filterKey)) {
      filtered = filtered.where(conditionMap[filterKey]!).toList();
    }

    // 标签筛选
    if (selectTag != '全部') {
      filtered = filtered.where((item) => item.tags.contains(selectTag)).toList();
    }

    // 搜索关键词筛选
    filtered = filterSiteStatusBySearchKey(filtered);

    showStatusList = filtered;
    sortStatusList();
  }

  void filterByCondition(bool Function(MySite) condition) {
    showStatusList = mySiteList.where(condition).toList();
  }
}
