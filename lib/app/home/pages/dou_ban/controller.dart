import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/controller/home_controller.dart';

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
  String selectMovieTag = '热门';
  String selectTvTag = '热门';
  int initPage = 0;
  bool isLoading = false;

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
    douBanMovieTags = await douBanHelper.getDouBanTags(category: 'movie');
    update();
  }

  getDouBanVideoTags() async {
    douBanTvTags = await douBanHelper.getDouBanTags(category: 'tv');
    update();
  }

  getDouBanTop250() async {
    douBanTop250.clear();
    await getDouBanTop250Api();
  }

  getDouBanTop250Api() async {
    if (initPage >= 225) {
      return;
    }
    var res = await douBanHelper.getDouBanTop250(initPage);
    douBanTop250.addAll(res);
    initPage += 25;
    update();
  }

  getDouBanMovieHot(String tag) async {
    isLoading = true;
    update();
    var res = await douBanHelper.getDouBanHot(
        category: 'movie', tag: tag, pageLimit: 51);
    douBanMovieHot.clear();
    douBanMovieHot = res;
    isLoading = false;
    update();
  }

  getDouBanTvHot(String tag) async {
    isLoading = true;
    update();
    var res = await douBanHelper.getDouBanHot(
        category: 'tv', tag: tag, pageLimit: 51);
    douBanTvHot.clear();
    douBanTvHot = res;
    isLoading = false;
    update();
  }

  getVideoDetail(String url) async {
    isLoading = true;
    update();
    var res = await douBanHelper.getSubjectInfo(url);
    isLoading = false;
    update();
    return res;
  }

  goSearchPage(info) async {
    Get.back();
    searchController.searchKeyController.text = info.title;
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
