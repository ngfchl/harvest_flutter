import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String formatCreatedTimeToDateString(item) {
  return DateFormat("MM-dd").format(item.createdAt);
}
String formatUpdatedTimeToDateString(item) {
  return DateFormat("MM-dd").format(item.updatedAt);
}

String formatCreatedTimeToMonthString(item) {
  return DateFormat("yyyy-MM").format(item.createdAt);
}

String generateRandomString(
  int length, {
  bool includeNumbers = true,
  bool includeSpecialChars = true,
  bool includeUppercase = true,
}) {
  const lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  const numbers = '0123456789';
  const specialChars = '¥#%@&*+-_^';

  // 基础字符集为小写字母
  String charset = lowercaseChars;

  // 根据参数条件添加其他字符集
  if (includeNumbers) charset += numbers;
  if (includeSpecialChars) charset += specialChars;
  if (includeUppercase) charset += lowercaseChars.toUpperCase();

  Random random = Random();
  return String.fromCharCodes(
    List.generate(
      length,
      (_) => charset.codeUnitAt(random.nextInt(charset.length)),
    ),
  );
}

///
/// 生成随机索引列表
///
List<int> getRandomIndices(int listLength, int count) {
  Random random = Random();
  List<int> indices = [];
  while (indices.length < count) {
    int randomIndex = random.nextInt(listLength);
    if (!indices.contains(randomIndex)) {
      indices.add(randomIndex);
    }
  }
  return indices;
}

checkEditController(TextEditingController controller, String field, context) {
  if (controller.text.isEmpty) {
    Get.snackbar('字段检查', '$field 不能为空！',
        colorText: Theme.of(context).colorScheme.error);
    return false;
  }
  return true;
}
