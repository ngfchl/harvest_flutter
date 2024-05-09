import 'package:get/get.dart';
import 'package:harvest/app/home/controller/home_controller.dart';

import '../../../../utils/logger_helper.dart';
import '../agg_search/controller.dart';
import 'douban_api.dart';
import 'model.dart';

class DouBanController extends GetxController {
  final searchController = Get.put(AggSearchController());
  final homeController = Get.put(HomeController());
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
    var res = await douBanHelper.getDouBanTop250(0);
    douBanTop250.clear();
    douBanTop250 = res;
    update();
  }

  getDouBanMovieHot(String tag) async {
    var res = await douBanHelper.getDouBanHot(
        category: 'movie', tag: tag, pageLimit: 50);
    douBanMovieHot.clear();
    douBanMovieHot = res;
    update();
  }

  getDouBanTvHot(String tag) async {
    var res = await douBanHelper.getDouBanHot(
        category: 'tv', tag: tag, pageLimit: 50);
    douBanTvHot.clear();
    douBanTvHot = res;
    update();
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
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
