import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/server_resource_status.dart';

class ServerResourceService {
  static Stream<ServerResourceStatus> watch({required int interval}) async* {
    HttpClient? client;
    var eventCount = 0;
    final stopwatch = Stopwatch()..start();
    try {
      client = HttpClient()
        ..autoUncompress = false
        ..maxConnectionsPerHost = 5
        ..idleTimeout = const Duration(seconds: 60);

      final uri = Uri.parse(
        '${AppConfig.baseUrl}${API.SERVER_STATUS}',
      ).replace(queryParameters: {'interval': '$interval'});
      AppLogger.debug('[SSE] server resource open uri=$uri interval=$interval');

      var token = HiveManager.get<String>(StorageKeys.accessToken);
      var response = await _doConnect(client, uri, token, stopwatch);

      if (response.statusCode == 401) {
        final oldToken = token;
        AppLogger.info('[SSE] server resource 401, waiting for token refresh...');
        await Future<void>.delayed(const Duration(seconds: 2));
        final freshToken = HiveManager.get<String>(StorageKeys.accessToken);
        if (freshToken != null && freshToken.isNotEmpty && freshToken != oldToken) {
          AppLogger.info('[SSE] server resource retrying with refreshed token');
          client.close(force: true);
          client = HttpClient()
            ..autoUncompress = false
            ..maxConnectionsPerHost = 5
            ..idleTimeout = const Duration(seconds: 60);
          response = await _doConnect(client, uri, freshToken, stopwatch);
        } else {
          throw HttpException('服务器状态连接失败: 401', uri: uri);
        }
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('服务器状态连接失败: ${response.statusCode}', uri: uri);
      }

      AppLogger.info('[SSE] server resource connected status=${response.statusCode}');
      AppLogger.debug(
        '[SSE] server resource connected status=${response.statusCode} elapsed=${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );

      String buffer = '';
      await for (final chunk in response) {
        buffer += utf8
            .decode(chunk, allowMalformed: true)
            .replaceAll('\r\n', '\n')
            .replaceAll('\r', '\n');
        while (buffer.contains('\n\n')) {
          final index = buffer.indexOf('\n\n');
          final event = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 2);
          final status = _parseEvent(event);
          if (status != null) {
            eventCount++;
            if (eventCount == 1) {
              AppLogger.debug(
                '[SSE] server resource first data elapsed=${_formatElapsed(stopwatch.elapsedMilliseconds)} serverTs=${status.timestamp?.toIso8601String() ?? '-'}',
              );
            }
            yield status;
          }
        }
      }

      final remaining = buffer.trim();
      if (remaining.isNotEmpty) {
        final status = _parseEvent(remaining);
        if (status != null) {
          eventCount++;
          if (eventCount == 1) {
            AppLogger.debug(
              '[SSE] server resource first data elapsed=${_formatElapsed(stopwatch.elapsedMilliseconds)} serverTs=${status.timestamp?.toIso8601String() ?? '-'} remaining=true',
            );
          }
          yield status;
        }
      }
    } catch (e, st) {
      AppLogger.error('[SSE] server resource error', e, st);
      Error.throwWithStackTrace(e, st);
    } finally {
      client?.close(force: true);
      AppLogger.debug(
        '[SSE] server resource closed events=$eventCount elapsed=${_formatElapsed(stopwatch.elapsedMilliseconds)}',
      );
      AppLogger.info('[SSE] server resource closed events=$eventCount');
    }
  }

  static Future<HttpClientResponse> _doConnect(
    HttpClient client,
    Uri uri,
    String? token,
    Stopwatch stopwatch,
  ) async {
    AppLogger.debug('[SSE] server resource request ready elapsed=${_formatElapsed(stopwatch.elapsedMilliseconds)}');
    final request = await client.getUrl(uri);
    request.headers.set('Accept-Encoding', 'identity');
    request.headers.set('Accept', 'text/event-stream');
    request.headers.set('Cache-Control', 'no-cache');

    if (token != null && token.isNotEmpty) {
      request.headers.set('Authorization', 'Bearer $token');
    }

    AppLogger.info('[SSE] server resource connecting');
    return request.close();
  }

  static String _formatElapsed(int milliseconds) =>
      '${milliseconds}ms(${(milliseconds / 1000).toStringAsFixed(3)}s)';

  static ServerResourceStatus? _parseEvent(String event) {
    if (event.trim().isEmpty) return null;
    final lines = event.split('\n');
    final dataLines = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('data:')) {
        dataLines.add(trimmed.substring(5).trim());
      } else if (trimmed.startsWith('{')) {
        dataLines.add(trimmed);
      }
    }
    final jsonText = dataLines.join('\n').trim();
    if (jsonText.isEmpty) return null;

    try {
      final json = jsonDecode(jsonText) as Map<String, dynamic>;
      if (json['code'] != 0 || json['data'] == null) return null;
      final data = Map<String, dynamic>.from(json['data'] as Map);
      if (data['type'] == 'connected') return null;
      return ServerResourceStatus.fromJson(data);
    } catch (e, st) {
      AppLogger.error('[SSE] server resource parse error', e, st);
      return null;
    }
  }
}
