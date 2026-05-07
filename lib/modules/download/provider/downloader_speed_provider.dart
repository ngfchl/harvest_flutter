import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

import '../model/downloader_speed.dart';
import '../service/downloader_ws_service.dart';

// ══════════════════════════════════════════════════════════
//  常量
// ══════════════════════════════════════════════════════════

const kDefaultInterval = 5; // 秒
const kDefaultDuration = 5; // 分钟
const kMinInterval = 1;
const kMaxInterval = 60;
const kMinDuration = 1;
const kMaxDuration = 60;

// ══════════════════════════════════════════════════════════
//  设置 Providers
// ══════════════════════════════════════════════════════════

/// 刷新间隔（持久化）
final speedIntervalProvider = StateNotifierProvider<SpeedIntervalNotifier, int>(
  (ref) {
    return SpeedIntervalNotifier();
  },
);

class SpeedIntervalNotifier extends StateNotifier<int> {
  SpeedIntervalNotifier()
    : super(
        HiveManager.get<int>(StorageKeys.downloaderSpeedInterval) ??
            kDefaultInterval,
      );

  void update(int value) {
    final clamped = value.clamp(kMinInterval, kMaxInterval);
    state = clamped;
    HiveManager.set(StorageKeys.downloaderSpeedInterval, clamped);
  }
}

/// 自动停止时长（分钟，持久化）
final speedDurationProvider = StateNotifierProvider<SpeedDurationNotifier, int>(
  (ref) {
    return SpeedDurationNotifier();
  },
);

class SpeedDurationNotifier extends StateNotifier<int> {
  SpeedDurationNotifier()
    : super(
        HiveManager.get<int>(StorageKeys.downloaderSpeedDuration) ??
            kDefaultDuration,
      );

  void update(int value) {
    final clamped = value.clamp(kMinDuration, kMaxDuration);
    state = clamped;
    HiveManager.set(StorageKeys.downloaderSpeedDuration, clamped);
  }
}

/// 初次加载是否自动刷新（持久化）
final speedEnabledProvider = StateNotifierProvider<SpeedEnabledNotifier, bool>((
  ref,
) {
  return SpeedEnabledNotifier();
});

class SpeedEnabledNotifier extends StateNotifier<bool> {
  SpeedEnabledNotifier()
    : super(HiveManager.get<bool>(StorageKeys.downloaderSpeedEnabled) ?? true);

  void toggle() {
    state = !state;
    HiveManager.set(StorageKeys.downloaderSpeedEnabled, state);
  }

  void set(bool value) {
    state = value;
    HiveManager.set(StorageKeys.downloaderSpeedEnabled, value);
  }
}

/// 手动暂停（不持久化）
final speedPausedProvider = StateProvider<bool>((_) => false);

/// 剩余时间（秒），UI 读取显示倒计时
final speedRemainingProvider = StateProvider<int>((_) => 0);

// ══════════════════════════════════════════════════════════
//  速度数据 Provider
// ══════════════════════════════════════════════════════════

final downloaderSpeedProvider =
    StateNotifierProvider.autoDispose<
      DownloaderSpeedNotifier,
      Map<String, DownloaderSpeedData>
    >((ref) => DownloaderSpeedNotifier(ref));

class DownloaderSpeedNotifier
    extends StateNotifier<Map<String, DownloaderSpeedData>> {
  final Ref ref;
  DownloaderWsService? _service;
  StreamSubscription? _subscription;
  Timer? _autoStopTimer;
  Timer? _countdownTimer;

  DownloaderSpeedNotifier(this.ref) : super({}) {
    // 监听暂停状态
    ref.listen<bool>(speedPausedProvider, (prev, paused) {
      if (paused == true) {
        _pause();
      } else {
        _resume();
      }
    });

    // 监听间隔变化
    ref.listen<int>(speedIntervalProvider, (prev, next) {
      if (prev != next && _isRunning) {
        debugPrint('[Speed] 间隔变更: ${prev}s → ${next}s, 重连中...');
        _restart();
      }
    });

    // 监听时长变化
    ref.listen<int>(speedDurationProvider, (prev, next) {
      if (prev != next && _isRunning) {
        debugPrint('[Speed] 时长变更: ${prev}min → ${next}min, 重置计时...');
        _resetAutoStop();
      }
    });

    // ✅ 延迟启动，避免在初始化阶段修改其他 provider
    Future.microtask(() {
      if (!mounted) return;
      final enabled = ref.read(speedEnabledProvider);
      final paused = ref.read(speedPausedProvider);
      if (HiveManager.hasAccessToken && enabled && !paused) {
        _connect();
      } else {
        debugPrint('[Speed] 初始加载已禁用, 跳过连接');
      }
    });
  }

  bool get _isRunning => _subscription != null;

  void refresh() {
    if (!mounted) return;
    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(speedPausedProvider);
    if (!enabled || paused) return;
    _restart();
  }

  void setAlternativeSpeedMode({
    required int downloaderId,
    required bool enabled,
    String? wsKey,
  }) {
    final matchedKey = _findStateKey(downloaderId: downloaderId, wsKey: wsKey);
    if (matchedKey == null) return;

    final data = state[matchedKey];
    if (data == null) return;

    final prefs = Map<String, dynamic>.from(data.prefs)
      ..['use_alt_speed_limits'] = enabled
      ..['alternative_speed_enabled'] = enabled
      ..['alternativeSpeedEnabled'] = enabled
      ..['alt-speed-enabled'] = enabled
      ..['altSpeedEnabled'] = enabled
      ..['slow_mode'] = enabled
      ..['slowMode'] = enabled;

    state = {
      ...state,
      matchedKey: data.copyWith(
        info: data.info.copyWith(
          alternativeSpeedEnabled: enabled,
          speedLimitEnabled:
              enabled ||
              data.info.uploadLimit > 0 ||
              data.info.downloadLimit > 0,
        ),
        prefs: prefs,
      ),
    };
  }

  String? _findStateKey({required int downloaderId, String? wsKey}) {
    final id = downloaderId.toString().toLowerCase();
    final normalizedWsKey = wsKey?.toLowerCase();
    for (final entry in state.entries) {
      final key = entry.key.toLowerCase();
      final dataId = entry.value.downloaderId.toLowerCase();
      if (key == id || dataId == id) return entry.key;
      if (normalizedWsKey != null &&
          (key == normalizedWsKey || dataId == normalizedWsKey)) {
        return entry.key;
      }
    }
    return null;
  }

  void _connect() {
    if (!HiveManager.hasAccessToken) {
      _pause();
      return;
    }

    final baseUrl = HiveManager.get(StorageKeys.baseUrl);
    final token =
        HiveManager.get<String>(StorageKeys.accessToken) ??
        HiveManager.get(StorageKeys.accessToken)?.toString();

    _service?.disconnect();
    _service = DownloaderWsService(baseUrl: baseUrl, token: token);

    final interval = ref.read(speedIntervalProvider);
    _startListening(interval);
    _resetAutoStop();
  }

  void _startListening(int interval) {
    _subscription?.cancel();
    final stream = _service!.connect(interval: interval);
    _subscription = stream.listen(
      (data) {
        if (!mounted) return;
        state = {...state, ...data};
      },
      onError: (e) {
        debugPrint('[Speed] error: $e');
      },
    );
    debugPrint('[Speed] 开始监听, interval=${interval}s');
  }

  /// 重置自动停止计时器
  void _resetAutoStop() {
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();

    final durationMin = ref.read(speedDurationProvider);
    final totalSeconds = durationMin * 60;

    // 剩余秒数初始化
    ref.read(speedRemainingProvider.notifier).state = totalSeconds;

    // 每秒倒计时
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(speedRemainingProvider);
      if (remaining > 0) {
        ref.read(speedRemainingProvider.notifier).state = remaining - 1;
      } else {
        timer.cancel();
      }
    });

    // 到时自动停止
    _autoStopTimer = Timer(Duration(seconds: totalSeconds), () {
      if (!mounted) return;
      debugPrint('[Speed] $durationMin分钟到时, 自动停止');
      _countdownTimer?.cancel();
      ref.read(speedRemainingProvider.notifier).state = 0;
      ref.read(speedPausedProvider.notifier).state = true;
    });
  }

  void _restart() {
    _connect();
  }

  void _pause() {
    _subscription?.cancel();
    _subscription = null;
    _service?.disconnect();
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    if (!mounted) return;
    ref.read(speedRemainingProvider.notifier).state = 0;
    debugPrint('[Speed] paused');
  }

  void _resume() {
    final enabled = ref.read(speedEnabledProvider);
    if (enabled) {
      _connect();
      debugPrint('[Speed] resumed');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _service?.disconnect();
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
