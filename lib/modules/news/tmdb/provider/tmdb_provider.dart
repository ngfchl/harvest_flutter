import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/movie_detail.dart';
import '../model/person.dart';
import '../model/search_results.dart';
import '../model/tv_show_detail.dart';
import '../service/tmdb_service.dart';
import '../../provider/media_info_settings_provider.dart';

const tmdbPlayingMoviesCacheKey = 'news.tmdb.playing.movies';
const tmdbPopularMoviesCacheKey = 'news.tmdb.popular.movies';
const tmdbUpcomingMoviesCacheKey = 'news.tmdb.upcoming.movies';
const tmdbTopRatedMoviesCacheKey = 'news.tmdb.top_rated.movies';
const tmdbAiringTodayTvsCacheKey = 'news.tmdb.airing_today.tvs';
const tmdbOnTheAirTvsCacheKey = 'news.tmdb.on_the_air.tvs';
const tmdbPopularTvsCacheKey = 'news.tmdb.popular.tvs';
const tmdbTopRatedTvsCacheKey = 'news.tmdb.top_rated.tvs';

final tmdbCacheInfoProvider = StateProvider<Map<String, DataCacheInfo>>(
  (_) => const {},
);

final tmdbForceRefreshProvider = StateProvider<Set<String>>((_) => const {});

// 电影
final playingMoviesProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbPlayingMoviesCacheKey,
    () => TmdbService.getPlayingMovies(),
  );
});

final popularMoviesProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbPopularMoviesCacheKey,
    () => TmdbService.getPopularMovies(),
  );
});

final upcomingMoviesProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbUpcomingMoviesCacheKey,
    () => TmdbService.getUpcomingMovies(),
  );
});

final topRatedMoviesProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbTopRatedMoviesCacheKey,
    () => TmdbService.getTopRatedMovies(),
  );
});

// 剧集
final airingTodayTvsProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbAiringTodayTvsCacheKey,
    () => TmdbService.getAiringTodayTvs(),
  );
});

final onTheAirTvsProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbOnTheAirTvsCacheKey,
    () => TmdbService.getOnTheAirTvs(),
  );
});

final popularTvsProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbPopularTvsCacheKey,
    () => TmdbService.getPopularTvs(),
  );
});

final topRatedTvsProvider = FutureProvider.autoDispose<SearchResults>((ref) {
  ref.keepAlive();
  return _cachedSearchResults(
    ref,
    tmdbTopRatedTvsCacheKey,
    () => TmdbService.getTopRatedTvs(),
  );
});

// 详情
final movieDetailProvider = FutureProvider.autoDispose
    .family<MovieDetail?, int>((ref, id) {
      return TmdbService.getMovieDetail(id);
    });

final tvShowDetailProvider = FutureProvider.autoDispose
    .family<TvShowDetail?, int>((ref, id) {
      return TmdbService.getTvShowDetail(id);
    });

final personDetailProvider = FutureProvider.autoDispose.family<Person?, int>((
  ref,
  id,
) {
  return TmdbService.getPerson(id);
});

Future<SearchResults> _cachedSearchResults(
  Ref ref,
  String cacheKey,
  Future<SearchResults> Function() loader,
) async {
  final enabled = ref.watch(
    mediaInfoSettingsProvider.select((settings) => settings.tmdbEnabled),
  );
  if (!enabled) {
    _clearTmdbForceRefresh(ref, cacheKey);
    return const SearchResults();
  }

  if (!HiveManager.hasAccessToken) return const SearchResults();

  final forceRefresh = ref.read(tmdbForceRefreshProvider).contains(cacheKey);
  if (!forceRefresh) {
    final cached = SessionCache.read<SearchResults>(
      cacheKey,
      (data) => SearchResults.fromJson(Map<String, dynamic>.from(data as Map)),
    );
    if (cached != null) {
      _setTmdbCacheInfo(ref, cacheKey, DataCacheInfo.cached(cached.cachedAt));
      return cached.data;
    }
  }

  try {
    final data = await loader();
    _setTmdbCacheInfo(
      ref,
      cacheKey,
      await SessionCache.write(cacheKey, _searchResultsToCache(data)),
    );
    return data;
  } finally {
    _clearTmdbForceRefresh(ref, cacheKey);
  }
}

Map<String, dynamic> _searchResultsToCache(SearchResults data) => {
  'page': data.page,
  'total_pages': data.totalPages,
  'total_results': data.totalResults,
  'results': data.results.map((item) => item.toJson()).toList(),
  if (data.id != null) 'id': data.id,
  if (data.dates != null) 'dates': data.dates,
};

void _setTmdbCacheInfo(Ref ref, String key, DataCacheInfo info) {
  Future<void>.delayed(Duration.zero, () {
    final current = ref.read(tmdbCacheInfoProvider);
    ref.read(tmdbCacheInfoProvider.notifier).state = {...current, key: info};
  });
}

void _clearTmdbForceRefresh(Ref ref, String key) {
  Future<void>.delayed(Duration.zero, () {
    final current = ref.read(tmdbForceRefreshProvider);
    if (!current.contains(key)) return;
    ref.read(tmdbForceRefreshProvider.notifier).state = {
      for (final value in current)
        if (value != key) value,
    };
  });
}
