import 'dart:convert';

import 'package:harvest/core/utils/utils.dart';

/// SSE 搜索服务平台分发入口:
/// - 原生平台(iOS/Android/macOS/Windows/Linux)走 dart:io HttpClient 实现
/// - Web 平台走 fetch + ReadableStream 真流式实现(XHR 整包缓冲不适用)
///
/// 两个实现共享本文件的 [SearchEvent] 模型与 [parseLine] 行解析逻辑。
export 'resource_search_service_io.dart'
    if (dart.library.js_interop) 'resource_search_service_web.dart'
    show ResourceSearchService;

class SearchEvent {
  final int code;
  final String msg;
  final dynamic data;
  final bool succeed;

  SearchEvent({
    required this.code,
    required this.msg,
    required this.data,
    required this.succeed,
  });

  factory SearchEvent.fromJson(Map<String, dynamic> json) {
    return SearchEvent(
      code: json['code'] as int? ?? 0,
      msg: json['msg'] as String? ?? '',
      data: json['data'],
      succeed: json['succeed'] as bool? ?? false,
    );
  }
}

/// SSE 行解析:剥离 `data:` 前缀后按 JSON 解析,供两个平台实现复用。
SearchEvent? parseLine(String line) {
  final trimmed = line.trim();
  if (trimmed.isEmpty) return null;

  String jsonStr = trimmed;
  if (jsonStr.startsWith('data:')) {
    jsonStr = jsonStr.substring(5).trim();
  }
  if (jsonStr.isEmpty) return null;

  try {
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return SearchEvent.fromJson(json);
  } catch (e) {
    AppLogger.warn(
      '[SSE] failed to parse event line length=${jsonStr.length}: $e',
    );
    return null;
  }
}
