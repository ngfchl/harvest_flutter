DateTime parseDateTimeOrEpoch(String? value) {
  if (value == null || value.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);
  return parseFlexibleLocalDateTime(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? parseFlexibleLocalDateTime(String? value) {
  if (value == null) return null;
  var text = value
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (text.isEmpty || text.startsWith('0001')) return null;

  text = text
      .replaceAll('注册日期：', '')
      .replaceAll('注册日期:', '')
      .replaceAll('注册日期', '')
      .replaceAll(RegExp(r'\[[^\]]*\]'), '')
      .replaceAll(RegExp(r'\([^)]*\)'), '')
      .trim();
  if (text.isEmpty) return null;

  final timestamp = _parseTimestamp(text);
  if (timestamp != null) return timestamp;

  final normalizedIso = _normalizeIsoLikeDateTime(text);
  final iso = DateTime.tryParse(normalizedIso);
  if (iso != null) return iso.isUtc ? iso.toLocal() : iso;

  final english = _parseEnglishDateTime(text);
  if (english != null) return english;

  final numeric = _parseNumericDateTime(text);
  if (numeric != null) return numeric;

  return null;
}

String formatFlexibleLocalDateTimeString(String? value, {String empty = '-'}) {
  final parsed = parseFlexibleLocalDateTime(value);
  return parsed == null ? empty : formatDateTimeSecond(parsed);
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

String formatDateTimeSecond(DateTime dt) {
  return '${formatDateTimeMinute(dt)}:${dt.second.toString().padLeft(2, '0')}';
}

String formatDateOnly(DateTime dt) {
  return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String formatDateStringToMinute(String? value, {String empty = '-'}) {
  if (value == null || value.startsWith('0001')) return empty;
  final parsed = parseFlexibleLocalDateTime(value);
  return parsed == null ? value : formatDateTimeMinute(parsed);
}

String formatDateStringToDate(String? value, {String empty = '-'}) {
  if (value == null || value.isEmpty || value.startsWith('0001')) return empty;
  final text = formatRawDateTime(value).trim();
  final separator = text.indexOf(RegExp(r'[ T]'));
  final parsed = parseFlexibleLocalDateTime(text);
  if (parsed == null && separator > 0) return text.substring(0, separator);
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
  final parsed = parseFlexibleLocalDateTime(value);
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
  final parsed = parseFlexibleLocalDateTime(value);
  return parsed == null ? empty : formatWeeksDays(parsed, today: today);
}

String calcWeeksDays(String datetime) {
  return formatWeeksDays(parseFlexibleLocalDateTime(datetime) ?? DateTime.parse(datetime));
}

String calculateTimeElapsed(String pastTime) {
  final currentTime = DateTime.now();
  final pastDateTime = parseFlexibleLocalDateTime(pastTime) ?? DateTime.parse(pastTime);
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

DateTime? _parseTimestamp(String text) {
  if (!RegExp(r'^\d{10}(?:\.\d+)?$|^\d{13}$').hasMatch(text)) return null;
  final value = double.tryParse(text);
  if (value == null) return null;
  final milliseconds = text.length == 13 ? value.round() : (value * 1000).round();
  return DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
}

String _normalizeIsoLikeDateTime(String text) {
  var normalized = text.trim();
  normalized = normalized.replaceAll(RegExp(r'年|/|\.'), '-');
  normalized = normalized.replaceAll('月', '-').replaceAll('日', ' ');
  normalized = normalized.replaceFirstMapped(
    RegExp(r'^(\d{2})-(\d{1,2})-(\d{1,2})(?=\s+\d{1,2}:\d{2})'),
    (match) => '20${match.group(1)}-${match.group(2)}-${match.group(3)}',
  );
  return normalized.trim();
}

DateTime? _parseNumericDateTime(String text) {
  final match = RegExp(
    r'^(\d{2,4})[-/.年](\d{1,2})[-/.月](\d{1,2})(?:日)?(?:[ T]+(\d{1,2}):(\d{2})(?::(\d{2}))?)?',
  ).firstMatch(text);
  if (match == null) return null;
  final yearText = match.group(1)!;
  final year = yearText.length == 2 ? 2000 + int.parse(yearText) : int.parse(yearText);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final hour = int.tryParse(match.group(4) ?? '') ?? 0;
  final minute = int.tryParse(match.group(5) ?? '') ?? 0;
  final second = int.tryParse(match.group(6) ?? '') ?? 0;
  return _validLocalDateTime(year, month, day, hour, minute, second);
}

DateTime? _parseEnglishDateTime(String text) {
  var normalized = text
      .replaceAll(',', ' ')
      .replaceAll(RegExp(r'\b(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday|Mon|Tue|Wed|Thu|Fri|Sat|Sun)\b', caseSensitive: false), ' ')
      .replaceAllMapped(RegExp(r'\b(\d{1,2})(st|nd|rd|th)\b', caseSensitive: false), (match) => match.group(1)!)
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized.isEmpty) return null;

  final parts = normalized.split(' ');
  final monthIndex = parts.indexWhere((part) => _englishMonth(part) != null);
  if (monthIndex < 0) return null;

  int? day;
  int? year;
  final month = _englishMonth(parts[monthIndex])!;

  if (monthIndex > 0 && RegExp(r'^\d{1,2}$').hasMatch(parts[monthIndex - 1])) {
    day = int.parse(parts[monthIndex - 1]);
  }
  if (monthIndex + 1 < parts.length && RegExp(r'^\d{1,2}$').hasMatch(parts[monthIndex + 1])) {
    day ??= int.parse(parts[monthIndex + 1]);
  }

  for (final part in parts) {
    if (RegExp(r'^\d{4}$').hasMatch(part)) {
      year = int.parse(part);
      break;
    }
  }
  if (day == null || year == null) return null;

  var hour = 0;
  var minute = 0;
  var second = 0;
  final timeIndex = parts.indexWhere((part) => RegExp(r'^\d{1,2}:\d{2}(?::\d{2})?$').hasMatch(part));
  if (timeIndex >= 0) {
    final timeParts = parts[timeIndex].split(':');
    hour = int.parse(timeParts[0]);
    minute = int.parse(timeParts[1]);
    second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
    final meridiem = timeIndex + 1 < parts.length ? parts[timeIndex + 1].toUpperCase() : '';
    if (meridiem == 'PM' && hour < 12) hour += 12;
    if (meridiem == 'AM' && hour == 12) hour = 0;
  }

  return _validLocalDateTime(year, month, day, hour, minute, second);
}

int? _englishMonth(String value) {
  final key = value.toLowerCase();
  const months = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };
  return months[key];
}

DateTime? _validLocalDateTime(int year, int month, int day, int hour, int minute, int second) {
  try {
    final date = DateTime(year, month, day, hour, minute, second);
    if (date.year != year ||
        date.month != month ||
        date.day != day ||
        date.hour != hour ||
        date.minute != minute ||
        date.second != second) {
      return null;
    }
    return date;
  } catch (_) {
    return null;
  }
}
