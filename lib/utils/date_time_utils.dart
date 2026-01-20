import 'package:intl/intl.dart';

/// 格式化时间戳为可读
String formatTimestampToDateTime(int timestamp,
        {String format = 'yyyy-MM-dd HH:mm:ss', String fallback = '未知'}) =>
    DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));

/// 判断两个日期时间是否是同一天
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

/// 是否今日
bool isToday(String dateString) {
  final DateTime parsedDate = DateTime.parse(dateString);
  final today = DateTime.now().subtract(Duration(
      hours: DateTime.now().timeZoneOffset.inHours)); // 考虑到时区，获取本地今天的日期（不考虑时间）

  return parsedDate.year == today.year &&
      parsedDate.month == today.month &&
      parsedDate.day == today.day;
}

/// 给一个时间戳计算时长
String calcDurationFromTimeStamp(int timestamp) {
  return formatDuration(DateTime.now()
      .difference(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000))
      .inSeconds);
}

/// 时长处理
String formatDuration(int seconds) {
  Duration duration = Duration(seconds: seconds);

  final years = duration.inDays ~/ 365;
  final months = (duration.inDays % 365) ~/ 30;
  final days = (duration.inDays % 365) % 30;
  final hours = duration.inHours % 24;
  final minutes = (duration.inMinutes % 60);
  final remainingSeconds = (duration.inSeconds % 60);

  // 构建格式化的时间间隔字符串
  final parts = <String>[
    if (years > 0) '$years年',
    if (months > 0) '$months月',
    if (days > 0) '$days天',
    if (hours > 0) '$hours小时',
    if (minutes > 0 && duration.inHours < 1) '$minutes分',
    if (remainingSeconds > 0 && duration.inDays < 1) '$remainingSeconds秒',
  ];

  return parts.length > 2 ? parts.sublist(0, 2).join() : parts.join();
}

////@title 获取今天的日期字符串
///@description
///@updateTime  2025/03/27
String getDateString(DateTime dt) {
  return DateFormat('yyyy-MM-dd').format(dt);
}

////@title 获取今天的日期字符串
///@description 获取今天的日期字符串
///@updateTime 2025/03/27
String getTodayString() {
  var dt = DateTime.now();
  return getDateString(dt);
}

////@title 获取昨天的日期字符串
///@description 获取昨天的日期字符串
///@updateTime
String getYesterdayString() {
  var dt = DateTime.now().subtract(const Duration(days: 1));
  return getDateString(dt);
}

////@title 获取过去12个月的最后一天的日期列表
///@description
///@updateTime  2025/03/27
List<String> getLastDaysOfPastYear() {
  DateTime now = DateTime.now();
  return List.generate(12, (i) {
    DateTime lastDay = DateTime(now.year, now.month - i + 1, 0);
    return getDateString(lastDay);
  }).skip(1).toList().reversed.toList();
}

////@title 获取当前月份的天数
///@description
///@updateTime  2025/03/27
int getDaysInCurrentMonth() {
  DateTime now = DateTime.now();
  return DateTime(now.year, now.month + 1, 0).day;
}
