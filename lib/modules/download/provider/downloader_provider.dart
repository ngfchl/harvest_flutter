import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/downloader.dart';
import '../model/downloader_category.dart';
import '../service/downloader_service.dart';

final downloaderListProvider =
    AsyncNotifierProvider<DownloaderListNotifier, List<Downloader>>(
      DownloaderListNotifier.new,
    );

const _downloaderListCacheKey = 'downloader.list';

final downloaderListCacheInfoProvider = StateProvider<DataCacheInfo>(
  (_) => const DataCacheInfo.none(),
);

class DownloaderListNotifier extends AsyncNotifier<List<Downloader>> {
  @override
  Future<List<Downloader>> build() async {
    if (!HiveManager.hasAccessToken) return const <Downloader>[];

    final cached = SessionCache.read<List<Downloader>>(
      _downloaderListCacheKey,
      (data) => (data as List)
          .map(
            (item) =>
                Downloader.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    if (cached != null) {
      Future<void>.delayed(Duration.zero, () {
        ref.read(downloaderListCacheInfoProvider.notifier).state =
            DataCacheInfo.cached(cached.cachedAt);
        if (HiveManager.hasAccessToken) refresh();
      });
      return cached.data;
    }

    return _fetchAndCache(updateCacheInfo: false);
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.valueOrNull ?? const <Downloader>[]);
      return;
    }

    // state = const AsyncValue.loading();
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(_fetchAndCache);
    state = next.hasError && previous != null
        ? AsyncValue.data(previous)
        : next;
  }

  Future<List<Downloader>> _fetchAndCache({bool updateCacheInfo = true}) async {
    if (!HiveManager.hasAccessToken) return const <Downloader>[];

    final list = await DownloaderService.fetchList();
    final info = await SessionCache.write(
      _downloaderListCacheKey,
      list.map((e) => e.toJson()).toList(),
    );
    if (updateCacheInfo) {
      ref.read(downloaderListCacheInfoProvider.notifier).state = info;
    }
    return list;
  }

  Future<void> add(Downloader d) async {
    await DownloaderService.add(d);
    await refresh();
  }

  Future<void> edit(Downloader d) async {
    await DownloaderService.edit(d);
    await refresh();
  }

  Future<void> remove(int id) async {
    await DownloaderService.remove(id);
    await refresh();
  }
}

/// 种子路径列表
final downloaderPathsProvider = FutureProvider<List<String>>((ref) async {
  if (!HiveManager.hasAccessToken) return const <String>[];
  return await DownloaderService.fetchPaths();
});

/// 单个下载器 prefs
final downloaderPrefsProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, id) {
      if (!HiveManager.hasAccessToken) return null;
      return DownloaderService.fetchPrefs(id);
    });

/// 下载器标签
final downloaderTagsProvider = FutureProvider.family<List<String>, int>((
  ref,
  id,
) {
  if (!HiveManager.hasAccessToken) return Future.value(const <String>[]);
  return DownloaderService.fetchTags(id);
});

/// 下载器分类（QB）
final downloaderCategoriesProvider =
    FutureProvider.family<List<DownloaderCategory>, int>((ref, id) {
      if (!HiveManager.hasAccessToken) {
        return Future.value(const <DownloaderCategory>[]);
      }
      return DownloaderService.fetchCategories(id);
    });
