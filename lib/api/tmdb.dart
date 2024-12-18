import 'api.dart';
import 'hooks.dart';

getTMDBSearchApi(String query) async {
  return await fetchDataList('${Api.TMDB_SEARCH}/$query', (p0) => p0);
}

getTMDBPersonInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_PERSON}/$query');
}

getTMDBMovieInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_MOVIE_INFO}/$query');
}

getTMDBTvInfoApi(int query) async {
  return await fetchBasicData('${Api.TMDB_TV_INFO}/$query');
}

getTMDBTvSeasonInfoApi(int tvId, int seasonId) async {
  return await fetchBasicData('${Api.TMDB_SEASON}/$tvId/$seasonId');
}

getTMDBTvSeasonEpisodeInfoApi(int tvId, int seasonId, int episodeId) async {
  return await fetchBasicData('${Api.TMDB_EPISODE}/$tvId/$seasonId/$episodeId');
}

getTMDBLatestMovieApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_MOVIES);
}

getTMDBLatestTvApi() async {
  return await fetchBasicData(Api.TMDB_LATEST_TV);
}

getTMDBPopularMovieApi() async {
  return await fetchDataList(Api.TMDB_POPULAR_MOVIES, (p0) => p0);
}

getTMDBPopularTvApi() async {
  return await fetchDataList(Api.TMDB_POPULAR_TVS, (p0) => p0);
}

getTMDBTopRateMovieApi() async {
  return await fetchDataList(Api.TMDB_TOP_MOVIES, (p0) => p0);
}

getTMDBTopRateTvApi() async {
  return await fetchDataList(Api.TMDB_TOP_TVS, (p0) => p0);
}

getTMDBUpcomingMovieApi() async {
  return await fetchDataList(Api.TMDB_UPCOMING, (p0) => p0);
}

getTMDBAiringTvApi() async {
  return await fetchDataList(Api.TMDB_AIRING_TODAY, (p0) => p0);
}

getTMDBOnTheAirTvApi() async {
  return await fetchDataList(Api.TMDB_ON_THE_AIR, (p0) => p0);
}
