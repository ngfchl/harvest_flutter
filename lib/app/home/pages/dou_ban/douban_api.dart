import 'package:dio/dio.dart';
import 'package:harvest/app/home/pages/dou_ban/model.dart';
import 'package:html/parser.dart';

class DouBanHelper {
  late Dio _dio;

  DouBanHelper() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://movie.douban.com/',
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36 Edg/121.0.0.0',
        'Host': 'movie.douban.com',
        'Referer': 'https://movie.douban.com/',
        'Sec-Ch-Ua-Platform': 'macOS',
        'Connection': 'keep-alive',
      },
    ));
  }

  Future<List<TopMovieInfo>> getDouBanTop250(int pageNum) async {
    String url = 'top250?start=$pageNum';
    Response<dynamic> response = await _dio.get(url);
    var result = parseDouBanTop250(response.data);
    return result;
  }

  List<TopMovieInfo> parseDouBanTop250(data) {
    var document = parse(data.toString()).documentElement!;
    var elements = document.querySelectorAll('ol.grid_view > li > div.item');

    List<TopMovieInfo> resultList = elements.map((element) {
      var rank = element.querySelector('div > em')?.text.trim() ?? '';
      var doubanUrl =
          element.querySelector('div > a')?.attributes['href']?.trim() ?? '';
      var poster =
          element.querySelector('div > a > img')?.attributes['src']?.trim() ??
              '';
      var title =
          element.querySelector('div > a > img')?.attributes['alt']?.trim() ??
              '';
      var subtitle = element
          .querySelector('div.info > div.hd > a > span')
          ?.text
          .trim()
          .split('/')
          .map((e) => e.trim())
          .toList();
      var cast =
          element.querySelector('./div/div/p[1]//text()[1]')?.text.trim() ?? '';
      var desc = element
          .querySelector('div.bd > p:nth-child(1)')
          ?.text
          .trim()
          .split('\n')
          .map((e) => e.trim())
          .toList();
      var ratingNum =
          element.querySelector('span.rating_num')?.text.trim() ?? '';
      var evaluateNum = element
              .querySelector('div.bd > div.star > span:last-child')
              ?.text
              .trim() ??
          '';
      var quote =
          element.querySelector('div > p.quote > span.inq')?.text.trim() ?? '';

      Map<String, dynamic> m = {
        'rank': rank,
        'douban_url': doubanUrl,
        'poster': poster,
        'title': title,
        'subtitle': subtitle,
        'cast': desc?[0].trim(),
        'desc': desc?[1].split('/').map((e) => e.trim()).toList(),
        'rating_num': ratingNum,
        'evaluate_num': evaluateNum,
        'quote': quote,
      };
      return TopMovieInfo.fromJson(m);
    }).toList();
    return resultList;
  }

  Future<Map<String, dynamic>> getCelebrityInfo(int celebrityId) async {
    String url = 'celebrity/$celebrityId/';
    Response<dynamic> response = await _dio.get(url);
    return response.data;
  }

  Future<Map<String, dynamic>> getSubjectCast(int subjectId) async {
    String url = 'subject/$subjectId/celebrities';
    Response<dynamic> response = await _dio.get(url);
    return response.data;
  }

  Future<Map<String, dynamic>> getSubjectInfo(int subjectId) async {
    String url = 'subject/$subjectId/';
    Response<dynamic> response = await _dio.get(url);
    return response.data;
  }

  Future<List<String>> getDouBanTags({String category = 'movie'}) async {
    String url = 'j/search_tags';
    Map<String, dynamic> params = {"type": category};
    Response<dynamic> response = await _dio.get(url, queryParameters: params);
    Map<String, dynamic> tags = response.data;
    return List<String>.from(tags['tags']);
  }

  Future<List<HotMediaInfo>> getDouBanHot({
    String category = 'movie',
    String tag = '热门',
    int pageLimit = 100,
  }) async {
    String url = 'j/search_subjects';
    Map<String, dynamic> params = {
      "type": category,
      "tag": tag,
      "page_limit": pageLimit,
      "page_start": 0,
    };
    Response<dynamic> response = await _dio.get(url, queryParameters: params);
    List<dynamic> subjects = response.data['subjects'];
    return subjects.map((e) => HotMediaInfo.fromJson(e)).toList();
  }

  void closeDio() {
    _dio.close();
  }
}
