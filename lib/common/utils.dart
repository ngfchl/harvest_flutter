import 'dart:math';

import 'package:intl/intl.dart';

import '../app/home/pages/models/my_site.dart';

String formatCreatedTimeToDateString(StatusInfo item) {
  return DateFormat("yyyy-MM-dd").format(DateTime.parse(item.createdAt));
}

String generateRandomString(int length) {
  const charset = 'abcdefghijklmnopqrstuvwxyz0123456789¥#%@&*+-_^';
  Random random = Random();
  return String.fromCharCodes(
    List.generate(
        length, (_) => charset.codeUnitAt(random.nextInt(charset.length))),
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
