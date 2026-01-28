import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

String formatCreatedTimeToDateString(item) {
  return DateFormat("MM-dd").format(item.createdAt);
}

String formatUpdatedTimeToDateString(item) {
  return DateFormat("MM-dd").format(item.updatedAt);
}

String formatCreatedTimeToMonthString(item) {
  return DateFormat("yy-MM").format(item.createdAt);
}

String maskString(String input) {
  if (input.isEmpty) return input;

  // 私有方法：应用用户名掩码规则
  String maskUsername(String text) {
    final length = text.length;
    if (length == 1) return '$text**';
    if (length == 2) return '${text[0]}**${text[1]}';

    // 长度≥3: 保留首尾，中间替换为两个星号
    return '${text[0]}**${text[length - 1]}';
  }

  // 检测是否为邮箱格式（包含@且前后有内容）
  final emailMatch = RegExp(r'^(.+)@(.+)\.(.+)$').firstMatch(input);

  if (emailMatch != null) {
    final username = emailMatch.group(1)!;
    final domain = '${emailMatch.group(2)!}.${emailMatch.group(3)!}';

    // 掩码用户名部分，保留域名
    return '${maskUsername(username)}@$domain';
  }

  // 普通字符串掩码处理
  return maskUsername(input);
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

bool checkEditController(TextEditingController controller, String field, context) {
  if (controller.text.isEmpty) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('出错啦'),
        description: Text('$field 不能为空！'),
      ),
    );
    return false;
  }
  return true;
}

/// 计算宽度因子
double getWidthFactor(context) {
  final size = MediaQuery.of(context).size;
  double factor = size.width - 200;
  if (factor < 800) return 1.0; // 手机屏幕
  if (factor < 1200) return 0.5; // 平板屏幕
  if (factor < 1800) return 1 / 3; // 平板屏幕
  return 0.25; // 桌面屏幕
}
