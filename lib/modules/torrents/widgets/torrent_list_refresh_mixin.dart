import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';

import '../provider/downloader_provider.dart';

mixin TorrentListRefreshMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  Timer? _refreshTimer;
  Timer? _autoStopTimer;
  Timer? _countdownTimer;

  int get currentDownloaderId;

  void onRefreshSilently();

  void initRefreshListeners() {
    ref.listenManual<int>(speedIntervalProvider, (_, __) => restartAutoRefresh());
    ref.listenManual<int>(speedDurationProvider, (_, __) => restartAutoRefresh());
    ref.listenManual<bool>(speedEnabledProvider, (_, __) => syncTorrentRefreshState());
  }

  void disposeRefreshTimers() {
    _refreshTimer?.cancel();
    _autoStopTimer?.cancel();
    _countdownTimer?.cancel();
    _refreshTimer = null;
    _autoStopTimer = null;
    _countdownTimer = null;
  }

  void syncTorrentRefreshState() {
    if (!mounted) return;
    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(currentDownloaderId));
    ref.read(torrentListProvider(currentDownloaderId).notifier).setWsPaused(!enabled || paused);
    restartAutoRefresh();
  }

  void restartAutoRefresh() {
    stopAutoRefresh(resetRemaining: false);
    if (!mounted) return;

    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(currentDownloaderId));
    if (!enabled || paused) {
      ref.read(torrentRefreshRemainingProvider(currentDownloaderId).notifier).state = 0;
      return;
    }

    final interval = ref.read(speedIntervalProvider);
    final duration = ref.read(speedDurationProvider);
    final totalSeconds = duration * 60;
    ref.read(torrentRefreshRemainingProvider(currentDownloaderId).notifier).state = totalSeconds;

    _refreshTimer = Timer.periodic(Duration(seconds: interval), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      onRefreshSilently();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(torrentRefreshRemainingProvider(currentDownloaderId));
      if (remaining <= 0) {
        timer.cancel();
        return;
      }
      ref.read(torrentRefreshRemainingProvider(currentDownloaderId).notifier).state = remaining - 1;
    });

    _autoStopTimer = Timer(Duration(seconds: totalSeconds), () {
      if (!mounted) return;
      stopAutoRefresh(resetRemaining: true);
      ref.read(torrentRefreshPausedProvider(currentDownloaderId).notifier).state = true;
    });
  }

  void stopAutoRefresh({required bool resetRemaining}) {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (resetRemaining && mounted) {
      ref.read(torrentRefreshRemainingProvider(currentDownloaderId).notifier).state = 0;
    }
  }
}
