import 'package:flutter/material.dart';

import '../formatters/date_time_formatter.dart';
import '../formatters/file_size_formatter.dart';
import '../formatters/number_formatter.dart';
import '../parsers/size_parser.dart';

// ──────────────────── 格式化 ────────────────────
String formatTime(String raw) {
  return formatRawDateTime(raw);
}

String fmtBytes(int bytes) => formatCompactBytes(bytes);
// ═══════════════════════════════════════════════════
//  解析带单位的字符串 → bytes
// ═══════════════════════════════════════════════════

int parseSize(String s) => parseSizeToBytes(s);

String fmtCompact(double v) => formatCompactNumber(v);

String fmtRatio(num v) => formatRatio(v);

String fmtDate(String? d) => formatDateStringToMinute(d);

String maskKey(String? k) {
  if (k == null || k.isEmpty) return '-';
  if (k.length <= 8) return '****';
  return '****${k.substring(k.length - 8)}';
}

// ──────────────────── 等级颜色 ────────────────────

Color levelColor(String l) => switch (l) {
  'StaffLeader' => Color(0xFF8B0000),
  'SysOp' => Color(0xFFA0522D),
  'Administrator' => Color(0xFF4B0082),
  'Moderator' => Color(0xFF6495ED),
  'Assistant' => Color(0xFF806DEC),
  'Editor' => Color(0xFF9ACD32),
  'Honor' => Color(0xFFE03C8A),
  'ForumModerator' => Color(0xFF1CC6D5),
  'Retiree' => Color(0xFF1CC6D5),
  'Uploader' => Color(0xFFDC143C),
  'VIP' => Color(0xFF009F00),
  'SVIP' => Color(0xFF009F00),
  'NexusGod' => Color(0xFF9C4F96),
  'God' => Color(0xFF9C4F96),
  'Master' => Color(0xFF003366),
  'NexusMaster' => Color(0xFF38ACEC),
  'UltimateUser' => Color(0xFF006400),
  'ExtremeUser' => Color(0xFFFF8C00),
  'VeteranUser' => Color(0xFF483D8B),
  'InsaneUser' => Color(0xFF8B008B),
  'CrazyUser' => Color(0xFF00BFFF),
  'EliteUser' => Color(0xFF008B8B),
  'PowerUser' => Color(0xFFDAA520),
  'Peasant' => Color(0xFF708090),
  _ => Colors.grey,
};
