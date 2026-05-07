import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/backend_service_status.dart';
import 'server_resource_provider.dart';
import '../service/backend_service_status_service.dart';

class BackendServiceStatusState {
  final BackendServiceSnapshot? data;
  final bool running;
  final bool connected;
  final String? error;

  const BackendServiceStatusState({
    this.data,
    this.running = false,
    this.connected = false,
    this.error,
  });

  BackendServiceStatusState copyWith({
    BackendServiceSnapshot? data,
    bool? running,
    bool? connected,
    String? error,
    bool clearError = false,
  }) {
    return BackendServiceStatusState(
      data: data ?? this.data,
      running: running ?? this.running,
      connected: connected ?? this.connected,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final backendServiceStatusProvider =
    StateNotifierProvider.autoDispose<
      BackendServiceStatusNotifier,
      BackendServiceStatusState
    >((ref) => BackendServiceStatusNotifier(ref));

class BackendServiceStatusNotifier
    extends StateNotifier<BackendServiceStatusState> {
  final Ref ref;
  StreamSubscription<BackendServiceSnapshot>? _subscription;
  Timer? _autoStopTimer;
  bool _stopAfterFirstData = false;

  BackendServiceStatusNotifier(this.ref)
    : super(const BackendServiceStatusState()) {
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
    if (!mounted) return;
    if (!HiveManager.hasAccessToken) {
      state = state.copyWith(running: false, connected: false, error: '未登录');
      return;
    }

    _subscription?.cancel();
    _autoStopTimer?.cancel();
    state = state.copyWith(running: true, connected: false, clearError: true);
    final interval = ref.read(serverResourceIntervalProvider);
    final autoRefresh = ref.read(serverResourceAutoStartProvider);
    _stopAfterFirstData = !autoRefresh;
    final providerWatch = Stopwatch()..start();
    AppLogger.debug(
      '[SSE] backend services provider start interval=$interval autoRefresh=$autoRefresh',
    );
    _subscription = BackendServiceStatusService.watch(interval: interval).listen(
      (data) {
        if (!mounted) return;
        final wasEmpty = state.data == null;
        if (wasEmpty) {
          AppLogger.debug(
            '[SSE] backend services provider first data elapsed=${providerWatch.elapsedMilliseconds}ms serverTs=${data.timestamp?.toIso8601String() ?? '-'}',
          );
        }
        state = state.copyWith(
          data: data,
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
    _stopAfterFirstData = false;
    if (!mounted) return;
    state = state.copyWith(running: false, connected: false);
  }

  void _resetAutoStop() {
    _autoStopTimer?.cancel();
    final totalSeconds = ref.read(serverResourceDurationProvider) * 60;
    _autoStopTimer = Timer(Duration(seconds: totalSeconds), stop);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _autoStopTimer?.cancel();
    super.dispose();
  }
}
