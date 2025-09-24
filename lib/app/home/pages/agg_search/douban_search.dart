import 'package:dio/dio.dart';
import 'package:harvest/app/home/pages/models/subject.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';
import '../models/douban.dart';

class DouBanSearchHelper {
  late Dio _dio;

  DouBanSearchHelper() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://frodo.douban.com/',
      headers: {
        'Referer': 'https://servicewechat.com/wx2f9b06c1de1ccfca/91/page-frame.html',
        'User-Agent': 'MicroMessenger/'
      },
    ));
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
    ));
  }

  Future<CommonResponse<Subject?>> getSubjectInfoApi({required String subject}) async {
    String key = "DouBanSubject-$subject";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty) {
      var params = {
        "apikey": "0ac44ae016490db2204ce0a042db2916",
      };
      var response = await _dio.get("api/v2/subject/$subject", queryParameters: params);
      if (response.statusCode != 200) {
        return CommonResponse.error(msg: "获取影视详情出错啦！${response.statusCode}");
      }
      var movieInfo = response.data;
      data = {key: movieInfo};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 24 * 7);
    }
    return CommonResponse.success(data: Subject.fromJson(data[key]));
  }

  Future<CommonResponse<List<DouBanSearchResult>>> doSearch({required String q}) async {
    String key = "DouBanSearchResult-$q";
    Map<String, dynamic> data = await SPUtil.getCache(key);
    if (data.isEmpty || data[key].isEmpty) {
      var params = {
        "q": q,
        "count": 100,
        "apikey": "0ac44ae016490db2204ce0a042db2916",
      };
      var response = await _dio.get("api/v2/search/movie", queryParameters: params);
      if (response.statusCode != 200) {
        return CommonResponse.error(msg: "搜索出错啦！${response.statusCode}");
      }
      var subjects = response.data['items'];
      data = {key: subjects};
      Logger.instance.d(data);
      await SPUtil.setCache(key, data, 60 * 60 * 12);
    }
    Logger.instance.d(data[key]);
    List<DouBanSearchResult> infoList = data[key]
        .where((el) => el['layout'] != 'person' && el['layout'] != 'book')
        .map((el) => DouBanSearchResult.fromJson(el))
        .toList()
        .cast<DouBanSearchResult>();
    return CommonResponse.success(data: infoList);
  }
}
