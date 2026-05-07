import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/http/http_error.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/api.dart';
import '../../../core/http/hooks.dart';
import 'package:harvest/core/utils/utils.dart';
import '../model/dashboard_data.dart';

part 'dashboard_provider.g.dart';

const _dashboardCacheKey = 'dashboard.data';

final dashboardCacheInfoProvider = StateProvider<DataCacheInfo>(
  (_) => const DataCacheInfo.none(),
);

final dashboardRefreshSerialProvider = StateProvider<int>((_) => 0);

DateTime? _dashboardUpdatedAt(DashboardData data) {
  final updatedAt = data.updatedAt?.trim();
  if (updatedAt == null || updatedAt.isEmpty) return null;
  return DateTime.tryParse(updatedAt);
}

@Riverpod(keepAlive: true)
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardData? build() {
    if (!HiveManager.hasAccessToken) return null;

    final cached = SessionCache.read<DashboardData>(
      _dashboardCacheKey,
      (data) => DashboardData.fromJson(Map<String, dynamic>.from(data as Map)),
    );
    if (cached == null) return null;

    Future<void>.delayed(Duration.zero, () {
      ref.read(dashboardCacheInfoProvider.notifier).state = DataCacheInfo(
        isCached: true,
        cachedAt: _dashboardUpdatedAt(cached.data),
      );
    });
    return cached.data;
  }

  Future<void> refresh({int? days}) async {
    final token = HiveManager.get<String>(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return;

    try {
      final data = await fetchModel(
        API.DASHBOARD_DATA,
        DashboardData.fromJson,
        queryParameters: days == null ? null : {'days': days},
      );
      if (data == null) return;

      state = data;
      await SessionCache.write(_dashboardCacheKey, data.toJson());
      ref.read(dashboardCacheInfoProvider.notifier).state = DataCacheInfo(
        isCached: false,
        cachedAt: _dashboardUpdatedAt(data),
      );
      ref.read(dashboardRefreshSerialProvider.notifier).state++;
      // if (response != null) {
      //   state = DashboardData.fromJson(response);
      // }
    } catch (e) {
      if (isSilentAuthCancel(e)) return;
      AppLogger.error("获取仪表盘数据失败: $e");
    }
  }
}
