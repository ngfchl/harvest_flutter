import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/modules/admin_user/provider/admin_user_provider.dart';
import 'package:harvest/modules/dashboard/provider/dashboard_provider.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/option/provider/option_provider.dart';
import 'package:harvest/modules/option/provider/update_provider.dart';
import 'package:harvest/modules/site/provider/site_provider.dart';
import 'package:harvest/modules/task/provider/crontab_provider.dart';
import 'package:harvest/modules/task/provider/schedule_provider.dart';
import 'package:harvest/modules/user/provider/user_management_provider.dart';

const kDefaultAppAutoRefreshMinutes = 10;
const kMinAppAutoRefreshMinutes = 1;
const kMaxAppAutoRefreshMinutes = 1440;

int normalizeAppAutoRefreshMinutes(int value) {
  return value
      .clamp(kMinAppAutoRefreshMinutes, kMaxAppAutoRefreshMinutes)
      .toInt();
}

final appAutoRefreshIntervalProvider =
    StateNotifierProvider<AppAutoRefreshIntervalNotifier, int>(
  (_) => AppAutoRefreshIntervalNotifier(),
);

final appAutoRefreshRevisionProvider = StateProvider<int>((_) => 0);

final appAutoRefreshControllerProvider = Provider<AppAutoRefreshController>(
  AppAutoRefreshController.new,
);

class AppAutoRefreshIntervalNotifier extends StateNotifier<int> {
  AppAutoRefreshIntervalNotifier()
      : super(
          normalizeAppAutoRefreshMinutes(
            HiveManager.get<int>(StorageKeys.appAutoRefreshIntervalMinutes) ??
                kDefaultAppAutoRefreshMinutes,
          ),
        );

  Future<void> update(int value) async {
    final next = normalizeAppAutoRefreshMinutes(value);
    state = next;
    await HiveManager.set(StorageKeys.appAutoRefreshIntervalMinutes, next);
  }

  Future<void> reset() => update(kDefaultAppAutoRefreshMinutes);
}

class AppAutoRefreshController {
  AppAutoRefreshController(this.ref);

  final Ref ref;
  DateTime _lastRefreshAt = DateTime.now();
  Future<void>? _runningRefresh;

  Duration get interval {
    return Duration(minutes: ref.read(appAutoRefreshIntervalProvider));
  }

  Duration get timeUntilNextRefresh {
    final elapsed = DateTime.now().difference(_lastRefreshAt);
    if (elapsed >= interval) return Duration.zero;
    return interval - elapsed;
  }

  Future<void> refreshIfDue({int? dashboardDays}) async {
    if (timeUntilNextRefresh > Duration.zero) return;
    await refresh(dashboardDays: dashboardDays);
  }

  Future<void> refresh({int? dashboardDays}) {
    final running = _runningRefresh;
    if (running != null) {
      _markRefreshStarted();
      return running;
    }

    final next = _refresh(dashboardDays: dashboardDays);
    _runningRefresh = next;
    return next.whenComplete(() => _runningRefresh = null);
  }

  Future<void> _refresh({int? dashboardDays}) async {
    _markRefreshStarted();
    if (!HiveManager.hasAccessToken) return;

    ref
      ..invalidate(websiteListProvider)
      ..invalidate(unaddedSitesProvider)
      ..invalidate(downloaderSpeedProvider)
      ..invalidate(noticeHistoryProvider)
      ..invalidate(updateProvider)
      ..invalidate(optionProvider)
      ..invalidate(authInfoProvider)
      ..invalidate(managedUserListProvider)
      ..invalidate(adminUserListProvider);

    await Future.wait([
      ref.read(dashboardNotifierProvider.notifier).refresh(days: dashboardDays),
      ref.read(siteInfoListProvider.notifier).refresh(),
      ref.read(downloaderListProvider.notifier).refresh(),
      ref.read(scheduleProvider.notifier).refresh(),
      ref.read(crontabListProvider.notifier).refresh(),
    ]);
  }

  void _markRefreshStarted() {
    _lastRefreshAt = DateTime.now();
    ref.read(appAutoRefreshRevisionProvider.notifier).state++;
  }
}
