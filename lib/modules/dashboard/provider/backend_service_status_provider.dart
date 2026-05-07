import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/backend_service_status.dart';
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

  BackendServiceStatusNotifier(this.ref)
    : super(const BackendServiceStatusState());

  void toggle() => state.running ? stop() : start();

  void start() {
    if (!mounted) return;
    if (!HiveManager.hasAccessToken) {
      state = state.copyWith(running: false, connected: false, error: '未登录');
      return;
    }

    _subscription?.cancel();
    state = state.copyWith(running: true, connected: false, clearError: true);
    _subscription = BackendServiceStatusService.watch().listen(
      (data) {
        if (!mounted) return;
        state = state.copyWith(
          data: data,
          running: true,
          connected: true,
          clearError: true,
        );
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
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    if (!mounted) return;
    state = state.copyWith(running: false, connected: false);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
