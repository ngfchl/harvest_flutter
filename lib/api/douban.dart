// 豆瓣api
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/models/common_response.dart';

import 'api.dart';
import 'hooks.dart';

Future<CommonResponse<List?>> getCategoryTagsApi({String category = 'movie'}) async {
  return await fetchBasicList(Api.DOUBAN_TAGS, queryParameters: {'category': category});
}

Future<CommonResponse<List<Map<String, dynamic>>>> getCelebrityApi(String celebrityId) async {
  return await fetchDataList('${Api.DOUBAN_CELEBRITY}$celebrityId', (p0) => p0);
}

Future<CommonResponse> getSubjectInfoApi(String subjectId) async {
  return await fetchBasicData(Api.DOUBAN_SUBJECT + subjectId);
}

Future<CommonResponse<List<HotMediaInfo>>> getDouBanHotMovieApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {'category': 'movie', 'tag': tag, 'page_limit': pageLimit});
}

Future<CommonResponse<List<HotMediaInfo>>> getDouBanHotTvApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {'category': 'tv', 'tag': tag, 'page_limit': pageLimit});
}

Future<CommonResponse<List<RankMovie>>> getDouBanRankApi(int typeId, {int start = 0, int limit = 100}) async {
  return await fetchDataList(Api.DOUBAN_RANK, (p0) => RankMovie.fromJson(p0),
      queryParameters: {'type_id': typeId, 'start': start, 'limit': limit});
}

Future<CommonResponse<List<TopMovieInfo>>> getDouBanTop250Api() async {
  return await fetchDataList(Api.DOUBAN_TOP250, (p0) => TopMovieInfo.fromJson(p0));
}
