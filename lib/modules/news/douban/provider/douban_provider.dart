import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/hot_media.dart';
import '../model/rank_movie.dart';
import '../model/top_movie.dart';
import '../service/douban_service.dart';

const doubanHotMoviesCacheKey = 'news.douban.hot.movies';
const doubanHotTvsCacheKey = 'news.douban.hot.tvs';
const doubanTop250CacheKey = 'news.douban.top250';
const doubanRankMoviesCacheKey = 'news.douban.rank.movies';
const doubanRankTvsCacheKey = 'news.douban.rank.tvs';

final doubanCacheInfoProvider = StateProvider<Map<String, DataCacheInfo>>(
  (_) => const {},
);

final doubanForceRefreshProvider = StateProvider<Set<String>>((_) => const {});

// 热门电影
final doubanHotMoviesProvider = FutureProvider.autoDispose<List<HotMedia>>((
  ref,
) {
  ref.keepAlive();
  return _cachedList(
    ref,
    doubanHotMoviesCacheKey,
    () => DoubanService.getHotMovies('热门'),
    HotMedia.fromJson,
  );
});

// 热门剧集
final doubanHotTvsProvider = FutureProvider.autoDispose<List<HotMedia>>((ref) {
  ref.keepAlive();
  return _cachedList(
    ref,
    doubanHotTvsCacheKey,
    () => DoubanService.getHotTvs('热门'),
    HotMedia.fromJson,
  );
});

// Top250
final doubanTop250Provider = FutureProvider.autoDispose<List<TopMovie>>((ref) {
  ref.keepAlive();
  return _cachedList(
    ref,
    doubanTop250CacheKey,
    DoubanService.getTop250,
    TopMovie.fromJson,
  );
});

// 排行榜（电影）
final doubanRankMoviesProvider = FutureProvider.autoDispose<List<RankMovie>>((
  ref,
) {
  ref.keepAlive();
  return _cachedList(
    ref,
    doubanRankMoviesCacheKey,
    () => DoubanService.getRank(1),
    RankMovie.fromJson,
  );
});

// 排行榜（剧集）
final doubanRankTvsProvider = FutureProvider.autoDispose<List<RankMovie>>((
  ref,
) {
  ref.keepAlive();
  return _cachedList(
    ref,
    doubanRankTvsCacheKey,
    () => DoubanService.getRank(2),
    RankMovie.fromJson,
  );
});

Future<List<T>> _cachedList<T>(
  Ref ref,
  String cacheKey,
  Future<List<T>> Function() loader,
  T Function(Map<String, dynamic>) fromJson,
) async {
  if (!HiveManager.hasAccessToken) return <T>[];

  final forceRefresh = ref.read(doubanForceRefreshProvider).contains(cacheKey);
  if (!forceRefresh) {
    final cached = SessionCache.read<List<T>>(
      cacheKey,
      (data) => (data as List)
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
    if (cached != null) {
      _setDoubanCacheInfo(ref, cacheKey, DataCacheInfo.cached(cached.cachedAt));
      return cached.data;
    }
  }

  try {
    final data = await loader();
    _setDoubanCacheInfo(
      ref,
      cacheKey,
      await SessionCache.write(
        cacheKey,
        data.map((item) => (item as dynamic).toJson()).toList(),
      ),
    );
    return data;
  } finally {
    _clearDoubanForceRefresh(ref, cacheKey);
  }
}

void _setDoubanCacheInfo(Ref ref, String key, DataCacheInfo info) {
  Future<void>.delayed(Duration.zero, () {
    final current = ref.read(doubanCacheInfoProvider);
    ref.read(doubanCacheInfoProvider.notifier).state = {...current, key: info};
  });
}

void _clearDoubanForceRefresh(Ref ref, String key) {
  Future<void>.delayed(Duration.zero, () {
    final current = ref.read(doubanForceRefreshProvider);
    if (!current.contains(key)) return;
    ref.read(doubanForceRefreshProvider.notifier).state = {
      for (final value in current)
        if (value != key) value,
    };
  });
}
