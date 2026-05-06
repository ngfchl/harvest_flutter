import 'dart:async';
import 'dart:convert';

import 'package:harvest/core/utils/utils.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../model/downloader_speed.dart';

class DownloaderWsService {
  WebSocketChannel? _channel;
  StreamSubscription? _channelSub;
  StreamController<Map<String, DownloaderSpeedData>>? _controller;
  Timer? _reconnectTimer;
  bool _closed = false;
  int _interval = 1;

  final String baseUrl;
  final String? token;

  DownloaderWsService({required this.baseUrl, this.token});

  Stream<Map<String, DownloaderSpeedData>> connect({int interval = 1}) {
    _closed = false;
    _interval = interval;
    _controller = StreamController<Map<String, DownloaderSpeedData>>.broadcast(
      onCancel: () => disconnect(),
    );
    _doConnect();
    return _controller!.stream;
  }

  void _doConnect() {
    if (_closed) return;

    try {
      // 构造 ws url，token 走 query 参数
      final httpUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final wsBase = httpUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');

      var wsUrl = '$wsBase/api/ws/downloader/speed';
      if (token != null && token!.isNotEmpty) {
        wsUrl += '?token=$token';
      }

      AppLogger.info(
        '[WS] downloader speed connecting url=$wsBase/api/ws/downloader/speed '
        'token=${token?.isNotEmpty == true ? 'present' : 'none'} interval=$_interval',
      );

      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _channel = channel;

      channel.ready
          .then((_) {
            if (_closed || _channel != channel) return;
            AppLogger.info('[WS] downloader speed connected');
            // 连接成功后发送订阅参数
            channel.sink.add(jsonEncode({'interval': _interval}));
          })
          .catchError((e) {
            AppLogger.error('[WS] downloader speed ready error', e);
            _scheduleReconnect();
          });

      _channelSub = channel.stream.listen(
        (data) {
          if (_closed) return;
          try {
            final json = jsonDecode(data.toString()) as Map<String, dynamic>;
            if (json['code'] == 0 && json['data'] != null) {
              final dataMap = json['data'] as Map<String, dynamic>;
              final result = <String, DownloaderSpeedData>{};
              for (final entry in dataMap.entries) {
                if (entry.value != null) {
                  result[entry.key] = DownloaderSpeedData.fromJson(
                    entry.key,
                    entry.value as Map<String, dynamic>,
                  );
                }
              }
              AppLogger.verbose(
                '[WS] downloader speed frame parsed items=${result.length}',
              );
              _controller?.add(result);
            } else {
              AppLogger.warn(
                '[WS] downloader speed frame ignored code=${json['code']} hasData=${json['data'] != null}',
              );
            }
          } catch (e, st) {
            AppLogger.error('[WS] downloader speed parse error', e, st);
          }
        },
        onError: (e) {
          AppLogger.error('[WS] downloader speed stream error', e);
          if (!_closed) _scheduleReconnect();
        },
        onDone: () {
          AppLogger.warn('[WS] downloader speed stream closed');
          if (!_closed) _scheduleReconnect();
        },
      );
    } catch (e, st) {
      AppLogger.error('[WS] downloader speed connect error', e, st);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_closed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_closed) {
        AppLogger.info('[WS] downloader speed reconnecting');
        _doConnect();
      }
    });
  }

  void disconnect() {
    _closed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    final sub = _channelSub;
    final channel = _channel;
    _channelSub = null;
    _channel = null;
    try {
      unawaited(channel?.sink.close(ws_status.normalClosure));
    } catch (_) {}
    unawaited(sub?.cancel());
    final controller = _controller;
    _controller = null;
    if (controller != null && !controller.isClosed) {
      unawaited(controller.close());
    }
    AppLogger.info('[WS] downloader speed disconnected');
  }
}
