import 'package:harvest/models/common_response.dart';

import '../app/home/pages/models/tmdb.dart';
import 'api.dart';
import 'hooks.dart';

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBSearchApi(String query) async {
  return await fetchDataList('${Api.TMDB_SEARCH}/$query', (p0) => p0);
}

Future<CommonResponse> getTMDBPersonInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_PERSON}/$query');
}

Future<CommonResponse> getTMDBMovieInfoApi(int query) async {
  var res =  await fetchBasicData('${Api.TMDB_MOVIE_INFO}/$query');
  if (!res.succeed) {
    return res;
  }
  return CommonResponse.success(data: MovieDetail.fromJson(res.data as Map<String, dynamic>));
}

Future<CommonResponse> getTMDBTvInfoApi(int query) async {
  var res = await fetchBasicData('${Api.TMDB_TV_INFO}/$query');
  if (!res.succeed) {
    return res;
  }
  return CommonResponse.success(data: TvShowDetail.fromJson(res.data as Map<String, dynamic>));

}

Future<CommonResponse> getTMDBTvSeasonInfoApi(int tvId, int seasonId) async {
  return await fetchBasicData('${Api.TMDB_SEASON}/$tvId/$seasonId');
}

Future<CommonResponse> getTMDBTvSeasonEpisodeInfoApi(int tvId, int seasonId, int episodeId) async {
  return await fetchBasicData('${Api.TMDB_EPISODE}/$tvId/$seasonId/$episodeId');
}

Future<CommonResponse> getTMDBLatestMovieApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_MOVIES);
}

Future<CommonResponse> getTMDBLatestTvApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_TV);
}

Future<CommonResponse> getTMDBPopularMovieApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_POPULAR_MOVIES}?page=$page");
}

Future<CommonResponse> getTMDBPopularTvApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_POPULAR_TVS}?page=$page");
}

Future<CommonResponse> getTMDBTopRateMovieApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_TOP_MOVIES}?page=$page");
}

Future<CommonResponse> getTMDBTopRateTvApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_TOP_TVS}?page=$page");
}

Future<CommonResponse> getTMDBUpcomingMovieApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_UPCOMING_MOVIES}?page=$page");
}

Future<CommonResponse> getTMDBPlayingMovieApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_PLAYING_MOVIES}?page=$page");
}

Future<CommonResponse> getTMDBAiringTvApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_AIRING_TODAY}?page=$page");
}

Future<CommonResponse> getTMDBOnTheAirTvApi({int page = 1}) async {
  return await fetchBasicData("${Api.TMDB_ON_THE_AIR}?page=$page");
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBMatchMovieApi(String query) async {
  return await fetchDataList(Api.TMDB_MATCH_MOVIE, (p0) => p0, queryParameters: {"query": query});
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBMatchTvApi(String query) async {
  return await fetchDataList(Api.TMDB_MATCH_TV, (p0) => p0, queryParameters: {"query": query});
}

Future<CommonResponse> saveTMDBMatchApi(String path, Map<String, dynamic> mediaInfo) async {
  return await addData(Api.TMDB_MATCH_SAVE, {"file_path": path, "media_data": mediaInfo});
}
