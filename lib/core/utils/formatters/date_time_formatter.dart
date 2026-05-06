DateTime parseDateTimeOrEpoch(String? value) {
  if (value == null || value.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

String formatRawDateTime(String raw) {
  try {
    final dotIndex = raw.indexOf('.');
    if (dotIndex > 0) return raw.substring(0, dotIndex);
    return raw;
  } catch (_) {
    return raw;
  }
}

String formatDateTimeMinute(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String formatDateOnly(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String formatDateStringToMinute(String? value, {String empty = '-'}) {
  if (value == null || value.startsWith('0001')) return empty;
  try {
    return formatDateTimeMinute(DateTime.parse(value));
  } catch (_) {
    return value;
  }
}

String formatDateStringToDate(String? value, {String empty = '-'}) {
  if (value == null || value.isEmpty || value.startsWith('0001')) return empty;
  final text = formatRawDateTime(value).trim();
  final separator = text.indexOf(RegExp(r'[ T]'));
  if (separator > 0) return text.substring(0, separator);
  final parsed = DateTime.tryParse(text);
  return parsed == null ? text : formatDateOnly(parsed);
}

String formatTimeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}年前';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}月前';
  if (diff.inDays > 0) return '${diff.inDays}天前';
  if (diff.inHours > 0) return '${diff.inHours}小时前';
  if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
  return '刚刚';
}

String formatDateStringAgo(String? value, {String empty = ''}) {
  if (value == null || value.isEmpty || value.startsWith('0001')) return empty;
  final parsed = DateTime.tryParse(value);
  return parsed == null ? empty : formatTimeAgo(parsed);
}

String formatWeeksDays(DateTime time, {String today = '今天'}) {
  final diff = DateTime.now().difference(time);
  final weeks = diff.inDays ~/ 7;
  final days = diff.inDays % 7;
  if (weeks + days == 0) return today;
  if (days == 0) return '$weeks周';
  return '$weeks周$days天';
}

String formatDateStringWeeksDays(String? value, {String empty = '', String today = '今天'}) {
  if (value == null || value.isEmpty || value.startsWith('0001')) return empty;
  final parsed = DateTime.tryParse(value);
  return parsed == null ? empty : formatWeeksDays(parsed, today: today);
}

String calcWeeksDays(String datetime) {
  return formatWeeksDays(DateTime.parse(datetime));
}

String calculateTimeElapsed(String pastTime) {
  final currentTime = DateTime.now();
  final pastDateTime = DateTime.parse(pastTime);
  final difference = currentTime.difference(pastDateTime);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    return '$years 年${months > 0 ? '$months个月' : ''}前';
  }
  if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return '$months 个月前';
  }
  if (difference.inDays > 0) return '${difference.inDays} 天前';
  if (difference.inHours > 0) return '${difference.inHours} 小时前';
  if (difference.inMinutes > 0) return '${difference.inMinutes} 分钟前';
  return '刚刚';
}

String calcAccountAge(String? timeJoin) {
  if (timeJoin == null || timeJoin.isEmpty) return '0 天';
  try {
    final elapsed = calculateTimeElapsed(timeJoin);
    final weeksDays = calcWeeksDays(timeJoin);
    return '$elapsed ($weeksDays)';
  } catch (_) {
    return '0 天';
  }
}

String formatMonthDay(String value) {
  try {
    final dt = DateTime.parse(value);
    return '${dt.month}/${dt.day}';
  } catch (_) {
    return value.length > 10 ? value.substring(0, 10) : value;
  }
}
