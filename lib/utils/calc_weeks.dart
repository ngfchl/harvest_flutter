String calcWeeksDays(String datetime) {
  int days = DateTime.now().difference(DateTime.parse(datetime)).inDays;
  int weeks = days ~/ 7;
  int day = days % 7;

  if (weeks + day == 0) {
    return '今天';
  }
  if (day == 0) {
    return '$weeks周';
  }
  return '$weeks周$day天';
}

String calculateTimeElapsed(String pastTime) {
  /*
  计算过去多久了
   */
  DateTime currentTime = DateTime.now();
  DateTime pastDateTime = DateTime.parse(pastTime); // 将传入的字符串解析为 DateTime 对象

  Duration difference = currentTime.difference(pastDateTime); // 计算时间差

  if (difference.inDays > 365) {
    int years = (difference.inDays / 365).floor();
    int months = ((difference.inDays % 365) / 30).floor();
    return '$years 年${months > 0 ? '$months个月' : ''}前';
  } else if (difference.inDays > 30) {
    int months = (difference.inDays / 30).floor();
    return '$months 个月前';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} 天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} 小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} 分钟前';
  } else {
    return '刚刚';
  }
}
