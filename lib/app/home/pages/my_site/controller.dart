import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:harvest/models/common_response.dart';
import 'package:intl/intl.dart';

import '../../../../api/mysite.dart';
import '../../../../utils/logger_helper.dart';

class MySiteController extends GetxController {
  final searchController = TextEditingController().obs;
  final searchKey = ''.obs;
  final filterKey = ''.obs;
  RxList<MySite> mySiteList = <MySite>[].obs;
  RxList<MySite> showStatusList = <MySite>[].obs;
  final isLoaded = false.obs;
  final sortKey = 'statusMail'.obs;
  final sortReversed = false.obs;
  Map<String, WebSite> webSiteList = {};

  List<Map<String, String>> siteSortOptions = [
    {'name': '消息数目', 'value': 'statusMail'},
    {'name': '站点ID', 'value': 'mySiteId'},
    {'name': '排序ID', 'value': 'mySiteSortId'},
    {'name': '站点名称', 'value': 'siteName'},
    {'name': '站点昵称', 'value': 'mySiteNickname'},
    {'name': '注册时间', 'value': 'mySiteJoined'},
    {'name': '站点链接', 'value': 'siteUrl'},
    {'name': '做种体积', 'value': 'statusSeedVolume'},
    {'name': '站点魔力', 'value': 'statusMyBonus'},
    {'name': '站点积分', 'value': 'statusMyScore'},
    {'name': '下载量', 'value': 'statusDownloaded'},
    {'name': '上传量', 'value': 'statusUploaded'},
    {'name': '时魔', 'value': 'statusBonusHour'},
    {'name': '邀请', 'value': 'statusInvitation'},
    {'name': '正在下载', 'value': 'statusLeech'},
    {'name': '正在做种', 'value': 'statusSeed'},
    {'name': '分享率', 'value': 'statusRatio'},
  ];

  List<Map<String, String>> filterOptions = [
    {'name': '清除筛选', 'value': ''},
    {'name': '未签到', 'value': 'signIn'},
    {'name': '有新邮件', 'value': 'mail'},
    {'name': '有新公告', 'value': 'notice'},
    {'name': '无今日数据', 'value': 'status'},
    {'name': '站点启用', 'value': 'available'},
    {'name': '站点禁用', 'value': 'unavailable'},
    {'name': '无代理', 'value': 'proxy'},
    {'name': '无 UID', 'value': 'userId'},
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
  ];

  @override
  void onInit() async {
    searchKey.value = '';
    filterKey.value = '';
    await initData();
    super.onInit();
  }

  initData() async {
    await getWebSiteListFromServer();
    await getSiteStatusFromServer();
    update();
  }

  Future<void> getWebSiteListFromServer() async {
    await getWebSiteList().then((value) {
      if (value.code == 0) {
        webSiteList = value.data;
      } else {
        Logger.instance.w(value.msg);
        Get.snackbar(
          '',
          value.msg.toString(),
        );
      }
    }).catchError((e, stackTrace) {
      Logger.instance.e(e.toString());
      Logger.instance.e(stackTrace.toString());
      Get.snackbar('', e.toString());
    });
  }

  Future<bool> saveMySiteToServer(MySite mySite) async {
    CommonResponse response;
    if (mySite.id != 0) {
      response = await editMySite(mySite);
    } else {
      response = await saveMySite(mySite);
    }
    if (response.code == 0) {
      Get.snackbar(
        '保存成功！',
        response.msg!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 3),
      );
      return true;
    } else {
      Get.snackbar(
        '保存出错啦！',
        response.msg!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }

  Future<void> getSiteStatusFromServer() async {
    await getMySiteList().then((value) {
      if (value.code == 0) {
        mySiteList.value = value.data;
        isLoaded.value = true;
        filterByKey();
        filterSiteStatusBySearchKey();
        update();
      } else {
        Logger.instance.w(value.msg);
        Get.snackbar(
          '',
          value.msg.toString(),
        );
      }
    }).catchError((e, stackTrace) {
      Logger.instance.e(e.toString());
      Logger.instance.e(stackTrace.toString());
      Get.snackbar('', e.toString());
    });
  }

  void sortStatusList() {
    // 排除空数据
    showStatusList.value =
        showStatusList.where((item) => item.statusInfo.isNotEmpty).toList();

    // 根据不同的排序键调用不同的排序方法
    switch (sortKey.value) {
      case 'statusMail':
        sortByComparable((a, b) => b.mail.compareTo(a.mail));
        break;
      case 'mySiteId':
        sortByComparable((a, b) => a.id.compareTo(b.id));
        break;
      case 'mySiteSortId':
        sortByComparable((a, b) => a.sortId.compareTo(b.sortId));
        break;
      case 'siteName':
        sortByComparable((a, b) => a.site.compareTo(b.site));
        break;
      case 'mySiteNickname':
        sortByComparable((a, b) => a.nickname.compareTo(b.nickname));
        break;
      case 'mySiteJoined':
        sortByComparable((a, b) => a.timeJoin.compareTo(b.timeJoin));
        break;
      case 'siteUrl':
        sortByComparable((a, b) => a.mirror!.compareTo(b.mirror!));
        break;
      case 'statusSeedVolume':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.seedVolume
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.seedVolume));
        break;
      case 'statusMyBonus':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.myBonus
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.myBonus));
        break;
      case 'statusMyScore':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.myScore
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.myScore));
        break;
      case 'statusDownloaded':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.downloaded
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.downloaded));
        break;
      case 'statusUploaded':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.uploaded
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.uploaded));
        break;
      case 'statusBonusHour':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.bonusHour
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.bonusHour));
        break;
      case 'statusInvitation':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.invitation
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.invitation));
        break;
      case 'statusLeech':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.leech
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.leech));
        break;
      case 'statusSeed':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.seed
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.seed));
        break;
      case 'statusRatio':
        sortByStatusInfo((a, b) => a.statusInfo[a.getStatusMaxKey()]!.ratio
            .compareTo(b.statusInfo[b.getStatusMaxKey()]!.ratio));
        break;
    }

    // 反转序列
    if (sortReversed.value) {
      Logger.instance.w('反转序列！');
      showStatusList.value = showStatusList.reversed.toList();
    }

    // 按照邮件地址排序（默认排序）
    // showStatusList.sort((a, b) => b.mail.compareTo(a.mail));
  }

// 使用泛型以及 Comparable 接口来实现通用的比较逻辑
  void sortByComparable(int Function(MySite a, MySite b) compare) {
    showStatusList.sort((a, b) => compare(a, b));
  }

// 对 statusInfo 中的数据进行排序
  void sortByStatusInfo(int Function(MySite a, MySite b) compare) {
    showStatusList.sort((a, b) {
      String aKey = a.getStatusMaxKey();
      String bKey = b.getStatusMaxKey();
      if (aKey.isNotEmpty && bKey.isNotEmpty) {
        return compare(a, b);
      }
      return aKey.isNotEmpty ? 1 : -1;
    });
  }

  filterSiteStatusBySearchKey() {
    Logger.instance.w('搜索关键字：${searchKey.value}');
    filterKey.value = '';
    if (searchKey.value.isNotEmpty) {
      showStatusList.value = mySiteList
          .where((site) =>
              site.nickname
                  .toLowerCase()
                  .contains(searchKey.value.toLowerCase()) ||
              site.mirror!
                  .toLowerCase()
                  .contains(searchKey.value.toLowerCase()) ||
              site.site.toLowerCase().contains(searchKey.value.toLowerCase()))
          .toList();
    } else {
      showStatusList.value = mySiteList;
    }

    sortStatusList();
  }

  void filterByKey() {
    Logger.instance.i('开始筛选，当前筛选关键字：${filterKey.value}');
    searchKey.value = '';
    String today = DateFormat('yyyy-mm-dd').format(DateTime.now());

    switch (filterKey.value) {
      case 'available':
        filterByCondition((item) => item.available);
        break;
      case 'unavailable':
        filterByCondition((item) => !item.available);
        break;
      case 'passkey':
        filterByCondition((item) => item.passkey!.isEmpty);
        break;
      case 'authKey':
        filterByCondition((item) => item.authKey!.isEmpty);
        break;
      case 'cookie':
        filterByCondition((item) => item.cookie!.isEmpty);
        break;
      case 'proxy':
        filterByCondition((item) => item.proxy == null || item.proxy!.isEmpty);
        break;
      case 'timeJoin':
        filterByCondition((item) {
          Logger.instance.i(item.timeJoin);
          return item.timeJoin == '2024-02-01T00:00:00';
        });
        break;
      case 'mail':
        filterByCondition((item) => item.mail > 0);
        break;
      case 'notice':
        filterByCondition((item) => item.notice > 0);
        break;
      case 'signInInfo':
        filterByCondition((item) =>
            item.available &&
            webSiteList[item.site]!.signIn &&
            item.signIn &&
            item.signInInfo.isEmpty);
        break;
      case 'statusInfo':
        filterByCondition((item) => item.statusInfo.isEmpty);
        break;
      case 'signIn':
        filterByCondition((item) =>
            item.available && item.signIn && item.signInInfo[today] == null);
        break;
      case 'status':
        filterByCondition(
            (item) => item.available && item.statusInfo[today] == null);
        break;
      case 'userId':
        filterByCondition(
            (item) => item.userId == null || item.userId!.isEmpty);
        break;
      case 'invitation':
        filterByCondition((item) {
          String statusLatestDate =
              item.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
          return item.statusInfo[statusLatestDate] != null &&
              item.statusInfo[statusLatestDate]!.invitation > 0;
        });
        break;
      case 'noSeed':
        filterByCondition((item) {
          if (!item.available || item.statusInfo.isEmpty) return false;
          String statusLatestDate =
              item.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
          return item.statusInfo[statusLatestDate] != null &&
              item.statusInfo[statusLatestDate]!.seed <= 0;
        });
        break;
      case 'leech':
        filterByCondition((item) {
          if (!item.available || item.statusInfo.isEmpty) return false;
          String statusLatestDate =
              item.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
          return item.statusInfo[statusLatestDate] != null &&
              item.statusInfo[statusLatestDate]!.leech > 0;
        });
        break;
      case 'ratio':
        filterByCondition((item) {
          if (item.available || item.statusInfo.isEmpty) return false;
          String statusLatestDate =
              item.statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
          return item.statusInfo[statusLatestDate] != null &&
              item.statusInfo[statusLatestDate]!.ratio > 0 &&
              item.statusInfo[statusLatestDate]!.ratio <= 1;
        });
        break;
      default:
        showStatusList.value = mySiteList;
    }

    Logger.instance.i('筛选结果：${showStatusList.length}');
    sortStatusList();
    update();
  }

  void filterByCondition(bool Function(MySite) condition) {
    showStatusList.value = mySiteList.where(condition).toList();
  }
}
