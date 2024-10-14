import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/mysite.dart';
import '../../../models/common_response.dart';

Future<void> signAllSiteButton() async {
  final res = await signIn(null);
  Get.back();
  if (res.code == 0) {
    Get.snackbar(
      '签到任务',
      '签到任务信息：${res.msg}',
      colorText: Colors.white,
      backgroundColor: Colors.green.withOpacity(0.7),
    );
  } else {
    Get.snackbar(
      '签到失败',
      '签到任务执行出错啦：${res.msg}',
      colorText: Colors.white,
      backgroundColor: Colors.red.withOpacity(0.7),
    );
  }
}

Future<void> importFromPTPP() async {
  final res = await importFromPTPPApi();
  Get.back();
  if (res.code == 0) {
    Get.snackbar(
      'PTPP导入任务',
      'PTPP导入任务信息：${res.msg}',
    );
  } else {
    Get.snackbar(
      'PTPP导入任务失败',
      'PTPP导入任务执行出错啦：${res.msg}',
    );
  }
}

Future<void> importFromCookieCloud() async {
  final res = await importFromCookieCloudApi();
  Get.back();
  if (res.code == 0) {
    Get.snackbar(
      'CookieCloud任务',
      'CookieCloud任务信息：${res.msg}',
    );
  } else {
    Get.snackbar(
      'CookieCloud失败',
      'CookieCloud任务执行出错啦：${res.msg}',
    );
  }
}

Future<void> getAllStatusButton() async {
  final res = await getNewestStatus(null);
  Get.back();
  if (res.code == 0) {
    Get.snackbar(
      '更新数据',
      '更新数据任务信息：${res.msg}',
    );
  } else {
    Get.snackbar(
      '更新数据',
      '更新数据执行出错啦：${res.msg}',
    );
  }
}

Future<void> clearMyCacheButton(String key) async {
  CommonResponse res = await clearMyCacheApi(key);
  Get.snackbar(
    '清除缓存',
    '清除缓存：${res.msg}',
  );
}

Future<void> bulkUpgradeHandler(Map<String, dynamic> data) async {
  CommonResponse res = await bulkUpgrade(data);
  if (res.code == 0) {
    Get.snackbar(
      '批量操作通知',
      res.msg.toString(),
    );
  } else {
    Get.snackbar(
      '批量操作通知',
      res.msg.toString(),
    );
  }
}
