import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/common_response.dart';
import '../../utils/logger_helper.dart';
import '../upgrade_widget/model.dart';

class AppUpgradeController extends GetxController {
  double progressValue = 0.0;
  final popoverController = ShadPopoverController();
  AppUpdateInfo? updateInfo;
  bool notShowNewVersion = false;
  bool hasNewVersion = false;
  String currentTab = 'latestVersion';
  String newVersion = '';
  String currentVersion = '';
  final Dio dio = Dio();

  List<AppUpdateInfo> appVersions = [];

  @override
  void onInit() async {
    try {
      Logger.instance.d('开始检测 APP 更新');
      notShowNewVersion = SPUtil.getBool('notShowNewVersion', defaultValue: false);
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      getAppVersionList();
      getAppLatestVersionInfo();
    } catch (e, trace) {
      Logger.instance.e('检测 APP 更新失败');
      Logger.instance.e(trace);
    }

    super.onInit();
  }

  Future<void> getAppVersionList() async {
    var response = await dio.get('https://repeat.ptools.fun/api/app/version/list');
    if (response.statusCode == 200) {
      CommonResponse res = CommonResponse.fromJson(
          response.data,
          (p0) =>
              p0 == null ? [] : (p0 as List).map((e) => AppUpdateInfo.fromJson(e as Map<String, dynamic>)).toList());
      if (!res.succeed) {
        return;
      }
      appVersions = res.data;
    }
    update();
  }

  Future<void> getAppLatestVersionInfo() async {
    Logger.instance.d('getAppLatestVersionInfo');
    final response = await dio.get<Map<String, dynamic>>('https://repeat.ptools.fun/api/app/version/latest');
    CommonResponse res = CommonResponse.fromJson(
      response.data!,
      (json) => json == null ? null : AppUpdateInfo.fromJson(json),
    );
    if (res.succeed) {
      updateInfo = res.data;
      hasNewVersion = (updateInfo?.version ?? '0.0.0').compareTo(currentVersion) > 0;
      if (notShowNewVersion && hasNewVersion) {
        popoverController.show();
      }
    } else {
      Get.snackbar('更新日志', '获取更新日志失败！${res.msg}', colorText: Colors.red);
    }
    update();
  }
}
