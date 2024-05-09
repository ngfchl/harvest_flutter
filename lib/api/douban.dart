// 豆瓣api
import '../app/home/pages/dou_ban/model.dart';
import 'api.dart';
import 'hooks.dart';

getCategoryTagsApi(String type) async {
  return await fetchBasicList(Api.DOUBAN_TAGS,
      queryParameters: {'category': type});
}

getCelebrityApi(String celebrityId) async {
  return await fetchDataList('${Api.DOUBAN_CELEBRITY}$celebrityId', (p0) => p0);
}

getSubjectInfoApi(String subjectId) async {
  return await fetchDataList(Api.DOUBAN_TAGS, (p0) => p0);
}

getDouBanHotMovieApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {
        'category': 'movie',
        'tag': tag,
        'page_limit': pageLimit
      });
}

getDouBanHotTvApi(String tag, int pageLimit) async {
  return await fetchDataList(Api.DOUBAN_HOT, (p0) => HotMediaInfo.fromJson(p0),
      queryParameters: {'category': 'tv', 'tag': tag, 'page_limit': pageLimit});
}

getDouBanTop250Api() async {
  return await fetchDataList(
      Api.DOUBAN_TOP250, (p0) => TopMovieInfo.fromJson(p0));
}
