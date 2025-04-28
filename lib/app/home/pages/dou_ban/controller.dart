import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/controller/home_controller.dart';

import '../../../../api/douban.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../agg_search/controller.dart';
import 'douban_api.dart';
import 'model.dart';

class DouBanController extends GetxController {
  final searchController = Get.put(AggSearchController());
  final homeController = Get.put(HomeController());
  final PageController pageController = PageController(initialPage: 0);

  DouBanHelper douBanHelper = DouBanHelper();
  List<TopMovieInfo> douBanTop250 = [];
  List<HotMediaInfo> douBanMovieHot = [];
  List<HotMediaInfo> douBanTvHot = [];
  List<RankMovie> rankMovieList = [];
  List<int> top250PageNumList = [0, 25, 50, 75, 100, 125, 150, 175, 200, 225];
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

  Map<String, int> typeMap = {
    "TOP250": 0,
    "剧情": 11,
    "喜剧": 24,
    "动作": 5,
    "爱情": 13,
    "科幻": 17,
    "动画": 25,
    "悬疑": 10,
    "惊悚": 19,
    "恐怖": 20,
    "纪录片": 1,
    "短片": 23,
    "情色": 6,
    "音乐": 14,
    "歌舞": 7,
    "家庭": 28,
    "儿童": 8,
    "传记": 2,
    "历史": 4,
    "战争": 22,
    "犯罪": 3,
    "西部": 27,
    "奇幻": 16,
    "冒险": 15,
    "灾难": 12,
    "武侠": 29,
    "古装": 30,
    "运动": 18,
    "黑色电影": 31
  };

  String selectMovieTag = '热门';
  String selectTvTag = '热门';
  String selectTypeTag = 'TOP250';
  int initPage = 0;
  bool isLoading = false;

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await getRankListByType(selectTypeTag);
    await getDouBanMovieHot(selectMovieTag);
    await getDouBanTvHot(selectTvTag);
    update();
  }

  getDouBanMovieTags() async {
    douBanMovieTags = await getCategoryTagsApi(category: 'movie');
    update();
  }

  getDouBanVideoTags() async {
    douBanTvTags = await getCategoryTagsApi(category: 'tv');
    update();
  }

  getRankListByType(String type) async {
    int? typeId = typeMap[type];
    Logger.instance.d(typeId);
    if (typeId == null || typeId == 0) {
      CommonResponse res = await getDouBanTop250Api();
      if (res.succeed) {
        douBanTop250 = res.data;
      }
      Logger.instance.d(douBanTop250);
      update();
      return;
    }
    isLoading = true;
    update();
    rankMovieList = await douBanHelper.getTypeRank(typeId);
    initPage = 0;
    isLoading = false;
    update();
    Logger.instance.d(rankMovieList);
  }

  // getDouBanTop250Api() async {
  //   if (initPage >= 225) {
  //     return;
  //   }
  //   var res = await douBanHelper.getDouBanTop250(initPage);
  //   douBanTop250.addAll(res);
  //   initPage += 25;
  //   update();
  // }

  getDouBanMovieHot(String tag) async {
    isLoading = true;
    update();
    CommonResponse res = await getDouBanHotMovieApi(tag, 51);
    if (res.succeed) {
      douBanMovieHot.clear();
      douBanMovieHot = res.data;
    }
    isLoading = false;
    update();
  }

  getDouBanTvHot(String tag) async {
    isLoading = true;
    update();
    CommonResponse res = await getDouBanHotTvApi(tag, 51);
    if (res.succeed) {
      douBanTvHot.clear();
      douBanTvHot = res.data;
    }
    isLoading = false;
    update();
  }

  String extractDoubanId(String url) {
    final regex = RegExp(r'/subject/(\d+)/');
    final match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!; // 提取第一个分组，也就是id
    }
    return '';
  }

  getVideoDetail(String url) async {
    isLoading = true;
    update();
    String id = extractDoubanId(url);
    if (id.isEmpty) {
      Logger.instance.e('影视信息 Id 解析失败： URL：$url');
      return;
    }
    var res = await getSubjectInfoApi(id);
    isLoading = false;
    update();
    return res;
  }

  goSearchPage(VideoDetail detail) async {
    Get.back();
    String searchKey = detail.title;
    if (detail.imdb.isNotEmpty) {
      searchKey = "${detail.imdb}||$searchKey";
    }
    searchController.searchKeyController.text = searchKey;
    await searchController.doWebsocketSearch();
    homeController.changePage(1);
    searchController.update();
    homeController.update();
    Logger.instance.i(homeController.initPage);
    Logger.instance.i(homeController.pageController.page);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
