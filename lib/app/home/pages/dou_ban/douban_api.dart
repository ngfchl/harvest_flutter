import 'package:dio/dio.dart';
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/utils/storage.dart';
import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import '../../../../utils/logger_helper.dart';

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
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
    ));
  }

  Future<List<TopMovieInfo>> getDouBanTop250(int pageNum) async {
    String url = 'top250?start=$pageNum';
    String key = "DouBanCelebrityInfo-$url";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      Response<dynamic> response = await _dio.get(url);
      var resultList = parseDouBanTop250(response.data);
      data = {key: resultList};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 24 * 7);
    }
    List<TopMovieInfo> topMovieInfoList =
        data[key].map((info) => TopMovieInfo.fromJson(info)).toList().cast<TopMovieInfo>();
    return topMovieInfoList;
  }

  List<Map<String, dynamic>> parseDouBanTop250(data) {
    var document = parse(data.toString()).documentElement!;
    var elements = document.querySelectorAll('ol.grid_view > li > div.item');

    List<Map<String, dynamic>> resultList = elements.map((element) {
      var rank = element.querySelector('div > em')?.text.trim() ?? '';
      var doubanUrl = element.querySelector('div > a')?.attributes['href']?.trim() ?? '';
      var poster = element.querySelector('div > a > img')?.attributes['src']?.trim() ?? '';
      var title = element.querySelector('div > a > img')?.attributes['alt']?.trim() ?? '';
      var subtitle =
          element.querySelector('div.info > div.hd > a > span')?.text.trim().split('/').map((e) => e.trim()).toList();
      var cast = element.querySelector('./div/div/p[1]//text()[1]')?.text.trim() ?? '';
      var desc =
          element.querySelector('div.bd > p:nth-child(1)')?.text.trim().split('\n').map((e) => e.trim()).toList();
      var ratingNum = element.querySelector('span.rating_num')?.text.trim() ?? '';
      var evaluateNum = element.querySelector('div.bd > div.star > span:last-child')?.text.trim() ?? '';
      var quote = element.querySelector('div > p.quote > span.inq')?.text.trim() ?? '';

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
      return m;
    }).toList();

    return resultList;
  }

  Future<Map<String, dynamic>> getCelebrityInfo(int celebrityId) async {
    String key = "DouBanCelebrityInfo-$celebrityId";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      String url = 'celebrity/$celebrityId/';
      Response<dynamic> response = await _dio.get(url);
      data = {key: response.data};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 24 * 7);
    }
    return data[key];
  }

  Future<Map<String, dynamic>> getSubjectCast(int subjectId) async {
    String key = "DouBanSubjectCast-$subjectId";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      String url = 'subject/$subjectId/celebrities';
      Response<dynamic> response = await _dio.get(url);
      data = {key: response.data};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 24 * 7);
    }
    return data[key];
  }

  Future<VideoDetail> getSubjectInfo(String subject) async {
    String key = "DouBanSubject-$subject";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      if (!subject.startsWith('https://')) {
        subject = 'subject/$subject/';
      }
      Response<dynamic> response = await _dio.get(subject);
      if (response.statusCode != 200) {
        await Future.delayed(const Duration(seconds: 2));
        response = await _dio.get(subject);
      }
      String html = response.data;
      var document = parse(html).documentElement;
      HtmlXPath selector = HtmlXPath.node(document!);

      String title = selector.queryXPath('//h1/span[1]/text()').attr?.trim() ?? '';
      String year = selector.queryXPath('//h1/span[2]/text()').attr?.trim() ?? '';
      List<Map<String, dynamic>> director = selector
          .queryXPath('//div[@id="info"]/span[1]/span[2]/a')
          .nodes
          .map((e) => {
                'name': e.text?.trim(),
                'url': e.attributes['href']?.trim(),
              })
          .toList();
      List<Map<String, dynamic>> writer = selector
          .queryXPath('//div[@id="info"]/span[2]/span[2]/a')
          .nodes
          .map((e) => {
                'name': e.text?.trim(),
                'url': e.attributes['href']?.trim(),
              })
          .toList();
      List<Map<String, dynamic>> actors = selector
          .queryXPath('//div[@id="info"]/span[3]/span[2]/a')
          .nodes
          .map((e) => {
                'name': e.text?.trim(),
                'url': e.attributes['href']?.trim(),
              })
          .toList();
      List<Map<String, String?>> celebrities = selector
          .queryXPath('//li[@class="celebrity"]')
          .nodes
          .map((e) => {
                'name': e.children.first.attributes['title'],
                'url': e.children.first.attributes['href'],
                'imgUrl': e.children.first.children.first.attributes['style']
                    ?.split(',')
                    .last
                    .replaceAll('background-image: url(', '')
                    .replaceAll('url(', '')
                    .replaceAll(')', '')
                    .trim(),
                'role': e.children.last.children.last.text,
              })
          .toList();
      List<String?> genres =
          selector.queryXPath('//div[@id="info"]//span[@property="v:genre"]').nodes.map((e) => e.text?.trim()).toList();
      String officialSite = selector.queryXPath('//div[@id="info"]/a/@href').attr?.trim() ?? '';

      String regionXPath = '//div[@id="info"]/text()';
      var regionNodes = document.queryXPath(regionXPath);
      List<String>? mediaBaseInfo =
          regionNodes.attr?.split('\n').map((e) => e.trim()).where((element) => element.isNotEmpty).toList();
      List<String>? region = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('制片国家/地区:'), orElse: () => '')
          .replaceAll('制片国家/地区:', '')
          .split('/')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
      List<String>? language = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('语言:'), orElse: () => '')
          .replaceAll('语言:', '')
          .split('/')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();

      List<String>? alias = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('又名:'), orElse: () => '')
          .replaceAll('又名:', '')
          .split('/')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
      List<String>? releaseDate = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('上映日期:'), orElse: () => '')
          .replaceAll('上映日期:', '')
          .split('/')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
      String? season = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('季数:'), orElse: () => '1')
          .replaceAll('季数:', '')
          .trim();
      String? episode = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('集数:'), orElse: () => '')
          .replaceAll('集数:', '')
          .trim();
      String? duration = selector
          .queryXPath(
              '//div[@id="info"]/span[contains(text(),"片长")]/following-sibling::span[@property="v:runtime"]/@content')
          .attr
          ?.trim();
      if (releaseDate == null || releaseDate.isEmpty) {
        releaseDate = mediaBaseInfo
            ?.firstWhere((element) => element.startsWith('首播:'), orElse: () => '')
            .replaceAll('首播:', '')
            .split('/')
            .map((e) => e.trim())
            .where((element) => element.isNotEmpty)
            .toList();
      }
      if (duration == null || duration.isEmpty) {
        duration = mediaBaseInfo
            ?.firstWhere((element) => element.startsWith('单集片长:'), orElse: () => '')
            .replaceAll('单集片长:', '')
            .trim();
      }
      String? imdb = mediaBaseInfo
          ?.firstWhere((element) => element.startsWith('IMDb:'), orElse: () => '')
          .replaceAll('IMDb:', '')
          .trim();

      String rate = selector.queryXPath('//div[@class="rating_self clearfix"]/strong/text()').attr?.trim() ?? '';
      String evaluate = selector.queryXPath('//a[@class="rating_people"]/span/text()').attr?.trim() ?? '';

      List<String?>? summary = selector
          .queryXPath('//span[@property="v:summary"]/text()')
          .attr
          ?.split('\n')
          .map((e) => e.trim())
          .where((element) => element.isNotEmpty)
          .toList();
      List<String?>? pictures = selector
          .queryXPath('//ul[contains(@class,"related-pic-bd")]/li/a/img/@src')
          .attrs
          .map((e) => e?.trim())
          .toList();

      String hadSeen = selector
              .queryXPath('//div[@class="subject-others-interests-ft"]/a[contains(@href,"status=P")]/text()')
              .attr
              ?.trim() ??
          '';
      String wantLook = selector
              .queryXPath('//div[@class="subject-others-interests-ft"]/a[contains(@href,"status=F")]/text()')
              .attr
              ?.trim() ??
          '';
      Logger.instance.i(pictures);
      Logger.instance.i(rate);
      Map<String, dynamic> movieInfo = {
        'title': title,
        'year': year,
        'director': director,
        'writer': writer,
        'actors': actors,
        'celebrities': celebrities,
        'genres': genres,
        'official_site': officialSite,
        'region': region,
        'language': language,
        'duration': duration,
        'release_date': releaseDate,
        'alias': alias,
        'imdb': imdb,
        'rate': rate,
        'pictures': pictures,
        'evaluate': evaluate,
        'summary': summary,
        'had_seen': hadSeen,
        'want_look': wantLook,
        'season': season,
        'episode': episode,
      };
      data = {key: movieInfo};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 24 * 7);
    }
    return VideoDetail.fromJson(data[key]);
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
    String key = "DouBanHot-$category-$tag";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      String url = 'j/search_subjects';
      Map<String, dynamic> params = {
        "type": category,
        "tag": tag,
        "page_limit": pageLimit,
        "page_start": 0,
      };
      Response<dynamic> response = await _dio.get(url, queryParameters: params);
      List<dynamic> subjects = response.data['subjects'];
      data = {key: subjects};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 18);
    }
    return data[key].map((e) => HotMediaInfo.fromJson(e)).toList().cast<HotMediaInfo>();
  }

  Future<List<RankMovie>> getTypeRank(int typeId) async {
    String key = "TypeRank-$typeId";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      String path = "j/chart/top_list?interval_id=100%3A90";
      Map<String, dynamic> params = {
        "type": typeId,
        // "interval_id": "100%3A90",
        "start": 0,
        "limit": 100
      };
      Response<dynamic> response = await _dio.get(path, queryParameters: params);
      data = {key: response.data};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 18);
    }
    return data[key].map((el) => RankMovie.fromJson(el)).toList().cast<RankMovie>();
  }

  void closeDio() {
    _dio.close();
  }
}
