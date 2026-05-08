import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../../../core/http/hooks.dart';
import '../model/media_item.dart';
import '../model/movie_detail.dart';
import '../model/person.dart';
import '../model/search_results.dart';
import '../model/tv_show_detail.dart';

class TmdbService {
  static const _imageBase = 'https://image.tmdb.org/t/p/';

  static String imageUrl(String? path, {String size = 'w342'}) {
    if (path == null || path.isEmpty) return '';
    return '$_imageBase$size$path';
  }

  // ────────────────────── 搜索 ──────────────────────

  static Future<List<MediaItem>> search(String query) async {
    final endpoint = '${API.TMDB_SEARCH}/$query';
    AppLogger.debug('[TMDB][search] request query="$query" endpoint=$endpoint');

    final list = await fetchBasicList(endpoint);
    AppLogger.debug('[TMDB][search] raw items=${list.length} query="$query"');

    for (var i = 0; i < list.length && i < 8; i++) {
      final raw = list[i];
      if (raw is Map<String, dynamic>) {
        AppLogger.debug(
          '[TMDB][search][raw#$i] '
          'keys=${raw.keys.toList()} '
          'id=${raw['id']} media_type=${raw['media_type']} '
          'title=${raw['title']} name=${raw['name']} '
          'release_date=${raw['release_date']} first_air_date=${raw['first_air_date']} '
          'poster=${raw['poster_path']} vote=${raw['vote_average']} '
          'overview_len=${(raw['overview'] as String?)?.length ?? 0}',
        );
      } else {
        AppLogger.debug('[TMDB][search][raw#$i] unexpected=${raw.runtimeType}');
      }
    }

    final results = list
        .whereType<Map<String, dynamic>>()
        .map(MediaItem.fromTmdbJson)
        .toList();

    AppLogger.debug('[TMDB][search] parsed items=${results.length} query="$query"');
    for (var i = 0; i < results.length && i < 8; i++) {
      final item = results[i];
      AppLogger.debug(
        '[TMDB][search][parsed#$i] '
        'id=${item.id} mediaType=${item.mediaType} '
        'title="${item.title}" original="${item.originalTitle}" '
        'releaseDate="${item.releaseDate}" poster=${item.posterPath.isNotEmpty} '
        'vote=${item.voteAverage} overview_len=${item.overview.length}',
      );
    }

    return results;
  }

  // ────────────────────── 电影 ──────────────────────

  static Future<SearchResults> getPlayingMovies({int page = 1}) =>
      _fetchList('/api/tmdb/playing/movies', page: page, mediaType: 'movie');

  static Future<SearchResults> getPopularMovies({int page = 1}) =>
      _fetchList('/api/tmdb/popular/movies', page: page, mediaType: 'movie');

  static Future<SearchResults> getUpcomingMovies({int page = 1}) =>
      _fetchList('/api/tmdb/upcoming/movies', page: page, mediaType: 'movie');

  static Future<SearchResults> getTopRatedMovies({int page = 1}) =>
      _fetchList('/api/tmdb/top_rated/movies', page: page, mediaType: 'movie');

  static Future<SearchResults> getLatestMovies({int page = 1}) =>
      _fetchList('/api/tmdb/latest/movies', page: page, mediaType: 'movie');

  static Future<MovieDetail?> getMovieDetail(int id) =>
      fetchModel('/api/tmdb/movie/$id', MovieDetail.fromJson);

  // ────────────────────── 剧集 ──────────────────────

  static Future<SearchResults> getAiringTodayTvs({int page = 1}) =>
      _fetchList('/api/tmdb/airing_today/tvs', page: page, mediaType: 'tv');

  static Future<SearchResults> getOnTheAirTvs({int page = 1}) =>
      _fetchList('/api/tmdb/on_the_air/tvs', page: page, mediaType: 'tv');

  static Future<SearchResults> getPopularTvs({int page = 1}) =>
      _fetchList('/api/tmdb/popular/tvs', page: page, mediaType: 'tv');

  static Future<SearchResults> getTopRatedTvs({int page = 1}) =>
      _fetchList('/api/tmdb/top_rated/tvs', page: page, mediaType: 'tv');

  static Future<SearchResults> getLatestTv({int page = 1}) =>
      _fetchList('/api/tmdb/latest/tv', page: page, mediaType: 'tv');

  static Future<TvShowDetail?> getTvShowDetail(int id) =>
      fetchModel('/api/tmdb/tv/$id', TvShowDetail.fromJson);

  // ────────────────────── 人物 ──────────────────────

  static Future<Person?> getPerson(int id) =>
      fetchModel('/api/tmdb/person/$id', Person.fromJson);

  // ────────────────────── 内部 ──────────────────────

  static Future<SearchResults> _fetchList(
    String path, {
    required int page,
    required String mediaType,
  }) async {
    final json = await fetchBasic(path, queryParameters: {'page': page});
    var results = SearchResults.fromJson(json ?? {});
    results = results.copyWith(
      results: results.results
          .map((e) => e.copyWith(mediaType: mediaType))
          .toList(),
    );
    return results;
  }
}
