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
    // {'name': '站点链接', 'value': 'siteUrl'},
    {'name': '做种体积', 'value': 'statusSeedVolume'},
    {'name': '站点魔力', 'value': 'statusMyBonus'},
    {'name': '站点积分', 'value': 'statusMyScore'},
    {'name': '下载量', 'value': 'statusDownloaded'},
    {'name': '上传量', 'value': 'statusUploaded'},
    // {'name': '时魔', 'value': 'statusBonusHour'},
    {'name': '邀请', 'value': 'statusInvitation'},
    {'name': '正在下载', 'value': 'statusLeech'},
    {'name': '正在做种', 'value': 'statusSeed'},
    // {'name': '分享率', 'value': 'statusRatio'},
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

  sortStatusList() {
    switch (sortKey.value) {
      case 'mySiteId':
        showStatusList.sort((a, b) => a.id.compareTo(b.id));
        break;
      case 'mySiteSortId':
        showStatusList.sort((a, b) => a.sortId.compareTo(b.sortId));
        break;
      case 'siteName':
        showStatusList.sort((a, b) => a.site.compareTo(b.site));
        break;
      case 'mySiteNickname':
        showStatusList.sort((a, b) => a.nickname.compareTo(b.nickname));
        break;
      case 'mySiteJoined':
        showStatusList.sort((a, b) => a.timeJoin.compareTo(b.timeJoin));
        break;
      case 'siteUrl':
        showStatusList.sort((a, b) => a.mirror!.compareTo(b.mirror!));
        break;
      // case 'statusSeedVolume':
      //   showStatusList
      //       .sort((a, b) => a.statusSeedVolume.compareTo(b.statusSeedVolume));
      // case 'statusMyBonus':
      //   showStatusList
      //       .sort((a, b) => a.statusMyBonus.compareTo(b.statusMyBonus));
      // case 'statusMyScore':
      //   showStatusList
      //       .sort((a, b) => a.statusMyScore.compareTo(b.statusMyScore));
      // case 'statusDownloaded':
      //   showStatusList
      //       .sort((a, b) => a.statusDownloaded.compareTo(b.statusDownloaded));
      // case 'statusUploaded':
      //   showStatusList
      //       .sort((a, b) => a.statusUploaded.compareTo(b.statusUploaded));
      // case 'statusMail':
      //   showStatusList.sort((a, b) => b.statusMail.compareTo(a.statusMail));
      // case 'statusBonusHour':
      //   showStatusList
      //       .sort((a, b) => a.statusBonusHour.compareTo(b.statusBonusHour));
      // case 'statusInvitation':
      //   showStatusList
      //       .sort((a, b) => a..compareTo(b.statusInvitation));
      // case 'statusLeech':
      //   showStatusList.sort((a, b) => a.statusLeech.compareTo(b.statusLeech));
      // case 'statusSeed':
      //   showStatusList.sort((a, b) => a.statusSeed.compareTo(b.statusSeed));
      // case 'statusRatio':
      //   showStatusList.sort((a, b) => a.statusRatio.compareTo(b.statusRatio));
    }
    if (sortReversed.value) {
      Logger.instance.w('反转序列！');
      showStatusList.value = showStatusList.reversed.toList();
    }
    showStatusList.sort((a, b) => b.notice.compareTo(a.notice));
    showStatusList.sort((a, b) => b.mail.compareTo(a.mail));
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
