// provider/site_provider.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/model/site_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/site_info.dart';
import '../service/site_service.dart';

part 'site_provider.g.dart';

const _siteInfoCacheKey = 'site.info.list';

final siteInfoCacheInfoProvider = StateProvider<DataCacheInfo>((_) => const DataCacheInfo.none());

final siteRefreshingIdsProvider = StateProvider<Set<int>>((_) => const <int>{});

@riverpod
class WebsiteList extends _$WebsiteList {
  @override
  Future<List<WebSite>> build() {
    if (!HiveManager.hasAccessToken) return Future.value(const <WebSite>[]);
    return SiteService.fetchWebsiteList();
  }
}

@Riverpod(keepAlive: true)
class SiteInfoList extends _$SiteInfoList {
  @override
  Future<List<SiteInfo>> build() async {
    if (!HiveManager.hasAccessToken) return const <SiteInfo>[];

    final cached = SessionCache.read<List<SiteInfo>>(
      _siteInfoCacheKey,
      (data) => (data as List).map((item) => SiteInfo.fromJson(Map<String, dynamic>.from(item as Map))).toList(),
    );
    if (cached != null) {
      Future<void>.delayed(Duration.zero, () {
        ref.read(siteInfoCacheInfoProvider.notifier).state = DataCacheInfo.cached(cached.cachedAt);
        if (HiveManager.hasAccessToken) refresh();
      });
      return cached.data;
    }

    return _fetchAndCache(updateCacheInfo: false);
  }

  // ── 3. refresh 加 cached 参数 ──
  Future<void> refresh({bool cached = true}) async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.valueOrNull ?? const <SiteInfo>[]);
      return;
    }

    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(() => _fetchAndCache(cached: cached));
    state = next.hasError && previous != null ? AsyncValue.data(previous) : next;
  }

  // ── 2. _fetchAndCache 加 cached 参数 ──
  Future<List<SiteInfo>> _fetchAndCache({bool updateCacheInfo = true, bool cached = true}) async {
    if (!HiveManager.hasAccessToken) return const <SiteInfo>[];

    final list = await SiteService.fetchMySiteList(cached: cached);
    final info = await SessionCache.write(_siteInfoCacheKey, list.map((e) => e.toJson()).toList());
    if (updateCacheInfo) {
      ref.read(siteInfoCacheInfoProvider.notifier).state = info;
    }
    return list;
  }

  Future<void> create(SiteInfo site) async {
    await SiteService.createSite(site);
    await refresh(cached: false);
  }

  Future<void> importCustomSiteToml(List<PlatformFile> files, {bool overwrite = false}) async {
    await SiteService.importCustomSiteToml(files, overwrite: overwrite);
    try {
      await refresh();
      ref.invalidate(websiteListProvider);
    } catch (e, st) {
      AppLogger.error('自定义站点配置上传成功，但刷新站点列表失败', e, st);
    }
  }

  // ── 4. 增删改走 cached: false ──

  Future<void> updateSite(SiteInfo site) async {
    await SiteService.updateSite(site);
    await refresh(cached: false);
  }

  Future<void> delete(int id) async {
    await SiteService.deleteSite(id);
    await refresh(cached: false);
  }

  /// 刷新单个站点状态
  Future<String> refreshStatus(int siteId) async {
    final refreshingIds = ref.read(siteRefreshingIdsProvider.notifier);
    refreshingIds.state = {...refreshingIds.state, siteId};
    try {
      final message = await SiteService.refreshSiteStatus(siteId);
      await refresh();
      return message;
    } finally {
      refreshingIds.state = {...refreshingIds.state}..remove(siteId);
    }
  }

  /// 执行签到
  Future<String> signIn(int siteId) async {
    final message = await SiteService.signInSite(siteId);
    await refresh();
    return message;
  }

  /// 执行辅种
  Future<String> repeat(int siteId) async {
    final message = await SiteService.repeatTorrents(siteId);
    await refresh();
    return message;
  }
}

@Riverpod(keepAlive: true) // ← 改这里
Future<List<String>> unaddedSites(ref) {
  ref.watch(siteInfoListProvider);
  if (!HiveManager.hasAccessToken) return Future.value(const <String>[]);
  return SiteService.fetchUnadded();
}
