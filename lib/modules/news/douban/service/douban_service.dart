import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';

import '../model/hot_media.dart';
import '../model/rank_movie.dart';
import '../model/search_result.dart';
import '../model/top_movie.dart';
import '../model/video_detail.dart';

class DoubanService {
  // ────────────────────── 搜索 ──────────────────────

  static Future<List<DoubanSearchResult>> search(String query) {
    return fetchModelList(
      API.DOUBAN_SEARCH,
      DoubanSearchResult.fromJson,
      queryParameters: {'q': query},
    );
  }

  // ────────────────────── 热门 ──────────────────────

  static Future<List<HotMedia>> getHotMovies(
    String tag, {
    int pageStart = 0,
    int pageLimit = 20,
  }) {
    return fetchModelList(
      API.DOUBAN_HOT,
      HotMedia.fromJson,
      queryParameters: {
        'category': 'movie',
        'tag': tag,
        'page_start': pageStart,
        'page_limit': pageLimit,
      },
    );
  }

  static Future<List<HotMedia>> getHotTvs(
    String tag, {
    int pageStart = 0,
    int pageLimit = 20,
  }) {
    return fetchModelList(
      API.DOUBAN_HOT,
      HotMedia.fromJson,
      queryParameters: {
        'category': 'tv',
        'tag': tag,
        'page_start': pageStart,
        'page_limit': pageLimit,
      },
    );
  }

  // ────────────────────── Top250 ──────────────────────

  static Future<List<TopMovie>> getTop250() {
    return fetchModelList(API.DOUBAN_TOP250, TopMovie.fromJson);
  }

  // ────────────────────── 排行榜 ──────────────────────

  static Future<List<RankMovie>> getRank(
    int typeId, {
    int start = 0,
    int limit = 100,
  }) {
    return fetchModelList(
      API.DOUBAN_RANK,
      RankMovie.fromJson,
      queryParameters: {'type_id': typeId, 'start': start, 'limit': limit},
    );
  }

  // ────────────────────── 标签 ──────────────────────

  static Future<List<String>> getTags({String category = 'movie'}) async {
    final list = await fetchBasicList(
      API.DOUBAN_RANK,
      queryParameters: {'category': category},
    );
    return list.whereType<String>().toList();
  }

  // ────────────────────── 详情 ──────────────────────

  static Future<VideoDetail?> getSubject(String subjectId) {
    return fetchModel('${API.DOUBAN_SUBJECT}$subjectId', VideoDetail.fromJson);
  }
}
