import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/douban.dart';
import '../../../../utils/logger_helper.dart';
import 'model.dart';

class DouBanController extends GetxController {
  List<MovieInfo> douBanTop250 = [];
  List<HotMediaInfo> douBanMovieHot = [];
  List<HotMediaInfo> douBanTvHot = [];
  List<String> douBanMovieTags = [
    '热门',
    '最新',
    '豆瓣高分',
    '冷门佳片',
    '华语',
    '欧美',
    '韩国',
    '日本'
  ];
  List<String> douBanTvTags = [
    '热门',
    '国产剧',
    '综艺',
    '美剧',
    '韩剧',
    '日剧',
    '日本动画',
    '纪录片'
  ];
  String selectMovieTag = '热门';
  String selectTvTag = '热门';

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await getDouBanTop250();
    await getDouBanMovieHot(selectMovieTag);
    await getDouBanTvHot(selectTvTag);
    // await getDouBanMovieTags();
    // await getDouBanVideoTags();
    update();
  }

  getDouBanMovieTags() async {
    CommonResponse res = await getCategoryTagsApi('movie');
    Logger.instance.i(res.data);
    douBanMovieTags = res.data.map<String>((e) => e.toString()).toList();
    update();
  }

  getDouBanVideoTags() async {
    CommonResponse res = await getCategoryTagsApi('tv');
    Logger.instance.i(res.data);
    douBanTvTags = res.data.map<String>((e) => e.toString()).toList();
    update();
  }

  getDouBanTop250() async {
    CommonResponse res = await getDouBanTop250Api();
    douBanTop250.clear();
    douBanTop250 = res.data;
    update();
  }

  getDouBanMovieHot(String tag) async {
    CommonResponse res = await getDouBanHotMovieApi(tag, 50);
    douBanMovieHot.clear();
    douBanMovieHot = res.data;
    update();
  }

  getDouBanTvHot(String tag) async {
    CommonResponse res = await getDouBanHotTvApi(tag, 50);
    douBanTvHot.clear();
    douBanTvHot = res.data;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
