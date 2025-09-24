import 'package:harvest/models/common_response.dart';

import 'api.dart';
import 'hooks.dart';

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBSearchApi(
    String query) async {
  return await fetchDataList('${Api.TMDB_SEARCH}/$query', (p0) => p0);
}

Future<CommonResponse> getTMDBPersonInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_PERSON}/$query');
}

Future<CommonResponse> getTMDBMovieInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_MOVIE_INFO}/$query');
}

Future<CommonResponse> getTMDBTvInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_TV_INFO}/$query');
}

Future<CommonResponse> getTMDBTvSeasonInfoApi(int tvId, int seasonId) async {
  return await fetchBasicData('${Api.TMDB_SEASON}/$tvId/$seasonId');
}

Future<CommonResponse> getTMDBTvSeasonEpisodeInfoApi(
    int tvId, int seasonId, int episodeId) async {
  return await fetchBasicData('${Api.TMDB_EPISODE}/$tvId/$seasonId/$episodeId');
}

Future<CommonResponse> getTMDBLatestMovieApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_MOVIES);
}

Future<CommonResponse> getTMDBLatestTvApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_TV);
}

Future<CommonResponse<List<Map<String, dynamic>>>>
    getTMDBPopularMovieApi() async {
  return await fetchDataList(Api.TMDB_POPULAR_MOVIES, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBPopularTvApi() async {
  return await fetchDataList(Api.TMDB_POPULAR_TVS, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>>
    getTMDBTopRateMovieApi() async {
  return await fetchDataList(Api.TMDB_TOP_MOVIES, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBTopRateTvApi() async {
  return await fetchDataList(Api.TMDB_TOP_TVS, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>>
    getTMDBUpcomingMovieApi() async {
  return await fetchDataList(Api.TMDB_UPCOMING, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBAiringTvApi() async {
  return await fetchDataList(Api.TMDB_AIRING_TODAY, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>>
    getTMDBOnTheAirTvApi() async {
  return await fetchDataList(Api.TMDB_ON_THE_AIR, (p0) => p0);
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBMatchMovieApi(
    String query) async {
  return await fetchDataList(Api.TMDB_MATCH_MOVIE, (p0) => p0,
      queryParameters: {"query": query});
}

Future<CommonResponse<List<Map<String, dynamic>>>> getTMDBMatchTvApi(
    String query) async {
  return await fetchDataList(Api.TMDB_MATCH_TV, (p0) => p0,
      queryParameters: {"query": query});
}
