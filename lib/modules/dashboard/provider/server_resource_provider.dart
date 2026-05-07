import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/server_resource_status.dart';
import '../service/server_resource_service.dart';

const kDefaultServerResourceInterval = 5;
const kDefaultServerResourceDuration = 5;
const kDefaultServerResourceAutoStart = false;
const kMinServerResourceInterval = 1;
const kMaxServerResourceInterval = 60;
const kMinServerResourceDuration = 1;
const kMaxServerResourceDuration = 60;
const kMaxServerResourceHistory = 60;

final serverResourceIntervalProvider =
    StateNotifierProvider<ServerResourceIntervalNotifier, int>(
      (_) => ServerResourceIntervalNotifier(),
    );

class ServerResourceIntervalNotifier extends StateNotifier<int> {
  ServerResourceIntervalNotifier()
    : super(
        HiveManager.get<int>(StorageKeys.serverResourceInterval) ??
            kDefaultServerResourceInterval,
      );

  void update(int value) {
    final clamped = value
        .clamp(kMinServerResourceInterval, kMaxServerResourceInterval)
        .toInt();
    state = clamped;
    HiveManager.set(StorageKeys.serverResourceInterval, clamped);
  }
}

final serverResourceDurationProvider =
    StateNotifierProvider<ServerResourceDurationNotifier, int>(
      (_) => ServerResourceDurationNotifier(),
    );

class ServerResourceDurationNotifier extends StateNotifier<int> {
  ServerResourceDurationNotifier()
    : super(
        HiveManager.get<int>(StorageKeys.serverResourceDuration) ??
            kDefaultServerResourceDuration,
      );

  void update(int value) {
    final clamped = value
        .clamp(kMinServerResourceDuration, kMaxServerResourceDuration)
        .toInt();
    state = clamped;
    HiveManager.set(StorageKeys.serverResourceDuration, clamped);
  }
}

final serverResourceAutoStartProvider =
    StateNotifierProvider<ServerResourceAutoStartNotifier, bool>(
      (_) => ServerResourceAutoStartNotifier(),
    );

class ServerResourceAutoStartNotifier extends StateNotifier<bool> {
  ServerResourceAutoStartNotifier()
    : super(
        HiveManager.get<bool>(StorageKeys.serverResourceAutoStart) ??
            kDefaultServerResourceAutoStart,
      );

  void update(bool value) {
    state = value;
    HiveManager.set(StorageKeys.serverResourceAutoStart, value);
  }
}

final serverResourceRemainingProvider = StateProvider<int>((_) => 0);

class ServerResourceState {
  final ServerResourceStatus? data;
  final List<ServerResourceStatus> history;
  final bool running;
  final String? error;
  final bool connected;

  const ServerResourceState({
    this.data,
    this.history = const [],
    this.running = false,
    this.error,
    this.connected = false,
  });

  ServerResourceState copyWith({
    ServerResourceStatus? data,
    List<ServerResourceStatus>? history,
    bool? running,
    String? error,
    bool? connected,
    bool clearError = false,
  }) {
    return ServerResourceState(
      data: data ?? this.data,
      history: history ?? this.history,
      running: running ?? this.running,
      error: clearError ? null : error ?? this.error,
      connected: connected ?? this.connected,
    );
  }
}

final serverResourceProvider =
    StateNotifierProvider.autoDispose<
      ServerResourceNotifier,
      ServerResourceState
    >((ref) => ServerResourceNotifier(ref));

class ServerResourceNotifier extends StateNotifier<ServerResourceState> {
  final Ref ref;
  StreamSubscription<ServerResourceStatus>? _subscription;
  Timer? _autoStopTimer;
  Timer? _countdownTimer;
  bool _stopAfterFirstData = false;

  ServerResourceNotifier(this.ref) : super(const ServerResourceState()) {
    ref.listen<int>(serverResourceIntervalProvider, (prev, next) {
      if (prev != next && state.running) start();
    });
    ref.listen<int>(serverResourceDurationProvider, (prev, next) {
      if (prev != next && state.running && !_stopAfterFirstData) {
        _resetAutoStop();
      }
    });
    ref.listen<bool>(serverResourceAutoStartProvider, (prev, next) {
      if (prev != next && state.running) start();
    });
  }

  void toggle() => state.running ? stop() : start();

  void start() {
    if (!HiveManager.hasAccessToken) {
      state = state.copyWith(running: false, error: '未登录');
      return;
    }
    _subscription?.cancel();
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    final interval = ref.read(serverResourceIntervalProvider);
    final autoRefresh = ref.read(serverResourceAutoStartProvider);
    _stopAfterFirstData = !autoRefresh;
    state = state.copyWith(running: true, connected: false, clearError: true);
    final providerWatch = Stopwatch()..start();
    AppLogger.debug(
      '[SSE] server resource provider start interval=$interval autoRefresh=$autoRefresh',
    );
    if (_stopAfterFirstData) {
      ref.read(serverResourceRemainingProvider.notifier).state = 0;
    }
    _subscription = ServerResourceService.watch(interval: interval).listen(
      (data) {
        if (!mounted) return;
        final wasEmpty = state.data == null;
        if (wasEmpty) {
          AppLogger.debug(
            '[SSE] server resource provider first data elapsed=${providerWatch.elapsedMilliseconds}ms serverTs=${data.timestamp?.toIso8601String() ?? '-'}',
          );
        }
        final history = [...state.history, data];
        final start = history.length > kMaxServerResourceHistory
            ? history.length - kMaxServerResourceHistory
            : 0;
        state = state.copyWith(
          data: data,
          history: List.unmodifiable(history.sublist(start)),
          running: true,
          connected: true,
          clearError: true,
        );
        if (_stopAfterFirstData) {
          stop();
        }
      },
      onError: (error) {
        if (!mounted) return;
        state = state.copyWith(running: false, connected: false, error: '连接失败');
      },
      onDone: () {
        if (!mounted) return;
        state = state.copyWith(
          running: false,
          connected: false,
          error: state.data == null ? '连接失败' : null,
        );
      },
    );
    if (autoRefresh) {
      _resetAutoStop();
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    _stopAfterFirstData = false;
    if (!mounted) return;
    ref.read(serverResourceRemainingProvider.notifier).state = 0;
    state = state.copyWith(running: false, connected: false);
  }

  void _resetAutoStop() {
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    final totalSeconds = ref.read(serverResourceDurationProvider) * 60;
    ref.read(serverResourceRemainingProvider.notifier).state = totalSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(serverResourceRemainingProvider);
      if (remaining <= 0) {
        timer.cancel();
        return;
      }
      ref.read(serverResourceRemainingProvider.notifier).state = remaining - 1;
    });

    _autoStopTimer = Timer(Duration(seconds: totalSeconds), stop);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
