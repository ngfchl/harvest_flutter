import 'package:intl/intl.dart';

/// 格式化时间戳为可读
String formatTimestampToDateTime(int timestamp,
        {String format = 'yyyy-MM-dd HH:mm:ss', String fallback = '未知'}) =>
    DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000));

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
