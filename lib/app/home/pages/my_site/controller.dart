import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:harvest/app/home/pages/models/website.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/mysite.dart';
import '../../../../utils/logger_helper.dart';

class MySiteController extends GetxController {
  final searchController = TextEditingController().obs;
  final searchKey = ''.obs;
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

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await getWebSiteListFromServer();
    await getSiteStatusFromServer();
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
      case 'mySiteSortId':
        showStatusList.sort((a, b) => a.sortId.compareTo(b.sortId));
      case 'siteName':
        showStatusList.sort((a, b) => a.site.compareTo(b.site));
      case 'mySiteNickname':
        showStatusList.sort((a, b) => a.nickname.compareTo(b.nickname));
      case 'mySiteJoined':
        showStatusList.sort((a, b) => a.timeJoin.compareTo(b.timeJoin));
      case 'siteUrl':
        showStatusList.sort((a, b) => a.mirror!.compareTo(b.mirror!));
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
}
