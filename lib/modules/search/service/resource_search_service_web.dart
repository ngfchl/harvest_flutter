import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:web/web.dart' as web;

import 'resource_search_service.dart' as base;

/// Web 平台专属实现:fetch + ReadableStream 真流式读取,
/// 逐块解析 SSE 事件(浏览器 XHR 会整包缓冲,不适用)。
class ResourceSearchServiceWeb {
  static Stream<base.SearchEvent> search(
    String query, {
    int maxCount = 5,
    List<String> sites = const [],
  }) async* {
    var eventCount = 0;
    try {
      final baseUrl = HiveManager.get(StorageKeys.baseUrl) ?? '';
      final uri = '$baseUrl/api/mysite/search';

      AppLogger.info(
        '[SSE-web] resource search connecting queryLength=${query.length} '
        'maxCount=$maxCount sites=${sites.length}',
      );

      final token = HiveManager.get(StorageKeys.accessToken);
      final headers = web.Headers();
      headers.append('Accept', 'text/event-stream');
      headers.append('Cache-Control', 'no-cache');
      headers.append('Content-Type', 'application/json');
      if (token != null && token.toString().isNotEmpty) {
        headers.append('Authorization', 'Bearer $token');
      }

      final init = web.RequestInit(
        method: 'POST',
        headers: headers,
        body: jsonEncode({
          'key': query,
          'max_count': maxCount,
          'sites': sites,
        }).toJS,
      );

      final response = await web.window.fetch(uri.toJS, init).toDart;
      if (!response.ok) {
        throw Exception('HTTP ${response.status}');
      }

      final body = response.body;
      if (body == null) {
        throw Exception('响应无内容流');
      }

      final reader = body.getReader() as web.ReadableStreamDefaultReader;
      String buffer = '';

      while (true) {
        final result = await reader.read().toDart;
        if (result.done) break;

        final value = result.value;
        Uint8List chunk;
        if (value.isA<JSUint8Array>()) {
          chunk = (value as JSUint8Array).toDart;
        } else {
          // 兜底:按字符串处理
          chunk = Uint8List.fromList(
            utf8.encode((value.dartify() ?? '').toString()),
          );
        }

        buffer += utf8
            .decode(chunk, allowMalformed: true)
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n');
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final event = base.parseLine(line);
          if (event != null) {
            eventCount++;
            yield event;
          }
        }
      }

      if (buffer.trim().isNotEmpty) {
        final event = base.parseLine(buffer);
        if (event != null) {
          eventCount++;
          yield event;
        }
      }
    } catch (e, trace) {
      AppLogger.error('[SSE-web] resource search error', e, trace);
      yield base.SearchEvent(code: -1, msg: '连接失败: $e', data: null, succeed: false);
    } finally {
      AppLogger.info('[SSE-web] resource search closed events=$eventCount');
    }
  }
}
