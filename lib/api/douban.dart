// 豆瓣api
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';

import 'api.dart';
import 'hooks.dart';

getCategoryTagsApi({String category = 'movie'}) async {
  return await fetchBasicList(Api.DOUBAN_TAGS, queryParameters: {'category': category});
}

getCelebrityApi(String celebrityId) async {
  return await fetchDataList('${Api.DOUBAN_CELEBRITY}$celebrityId', (p0) => p0);
}

getSubjectInfoApi(String subjectId) async {
  return await fetchBasicData(Api.DOUBAN_SUBJECT + subjectId);
}

getDouBanHotMovieApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {'category': 'movie', 'tag': tag, 'page_limit': pageLimit});
}

getDouBanHotTvApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {'category': 'tv', 'tag': tag, 'page_limit': pageLimit});
}

getDouBanRankApi(int typeId) async {
  return await fetchDataList(Api.DOUBAN_RANK, (p0) => RankMovie.fromJson(p0), queryParameters: {'type_id': typeId});
}

getDouBanTop250Api() async {
  return await fetchDataList(Api.DOUBAN_TOP250, (p0) => TopMovieInfo.fromJson(p0));
}
