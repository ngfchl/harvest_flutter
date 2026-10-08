import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

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

class ResourceSearchService {
  static Stream<SearchEvent> search(
    String query, {
    int maxCount = 5,
    List<String> sites = const [],
  }) async* {
    HttpClient? client;
    var eventCount = 0;
    try {
      client = HttpClient()
        ..autoUncompress = false
        ..maxConnectionsPerHost = 5  // 限制连接数
        ..idleTimeout = const Duration(seconds: 60);
      
      final baseUrl = HiveManager.get(StorageKeys.baseUrl);

      final uri = Uri.parse('$baseUrl/api/mysite/search');
      AppLogger.info(
        '[SSE] resource search connecting queryLength=${query.length} '
        'maxCount=$maxCount sites=${sites.length}',
      );
      final request = await client.postUrl(uri);

      // Token
      final token = HiveManager.get(StorageKeys.accessToken);

      // Headers
      request.headers.set('Accept-Encoding', 'identity'); // ← 加这行
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'text/event-stream');
      request.headers.set('Cache-Control', 'no-cache');

      if (token != null && token.toString().isNotEmpty) {
        request.headers.set('Authorization', 'Bearer $token');
      }

      // Body
      // Body — 用 add 传 UTF-8 字节
      final body = utf8.encode(
        jsonEncode({'key': query, 'max_count': maxCount, 'sites': sites}),
      );
      request.headers.set('Content-Length', body.length.toString());
      request.add(body);

      final response = await request.close();
      AppLogger.info(
        '[SSE] resource search connected status=${response.statusCode}',
      );

      String buffer = '';
      await for (final chunk in response) {
        buffer += utf8.decode(chunk, allowMalformed: true);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final event = _parseLine(line);
          if (event != null) {
            eventCount++;
            if (event.succeed) {
              AppLogger.verbose(
                '[SSE] resource event code=${event.code} msg=${event.msg}',
              );
            } else {
              AppLogger.warn(
                '[SSE] resource event failed code=${event.code} msg=${event.msg}',
              );
            }
            yield event;
          }
        }
      }

      if (buffer.trim().isNotEmpty) {
        final event = _parseLine(buffer);
        if (event != null) {
          eventCount++;
          yield event;
        }
      }
    } catch (e, trace) {
      AppLogger.error('[SSE] resource search error', e, trace);
      yield SearchEvent(code: -1, msg: '连接失败: $e', data: null, succeed: false);
    } finally {
      client?.close(force: true);
      AppLogger.info('[SSE] resource search closed events=$eventCount');
    }
  }

  static SearchEvent? _parseLine(String line) {
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
}
