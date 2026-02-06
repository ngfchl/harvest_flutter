import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/controller/home_controller.dart';
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../api/douban.dart';
import '../../../../api/tmdb.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../agg_search/controller.dart';
import '../models/tmdb.dart';
import 'douban_api.dart';

class DouBanController extends GetxController {
  final searchController = Get.put(AggSearchController());
  final homeController = Get.put(HomeController());
  final PageController pageController = PageController(initialPage: 0);
  ShadTabsController<String> tabsController = ShadTabsController<String>(value: 'tmdb');

  DouBanHelper douBanHelper = DouBanHelper();
  List<TopMovieInfo> douBanTop250 = [];
  List<HotMediaInfo> douBanMovieHot = [];
  List<HotMediaInfo> douBanTvHot = [];
  List<RankMovie> rankMovieList = [];
  List<int> top250PageNumList = [0, 25, 50, 75, 100, 125, 150, 175, 200, 225];
  List<String> douBanMovieTags = ['热门', '最新', '豆瓣高分', '冷门佳片', '华语', '欧美', '韩国', '日本'];
  List<String> douBanTvTags = ['热门', '国产剧', '综艺', '美剧', '韩剧', '日剧', '日本动画', '纪录片'];

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
  int pageLimit = 100;
  bool isLoading = false;
  bool hasMoreRankData = false;

  bool tmdbLoading = false;
  int selectTmdbMovieTag = 1;
  int selectTmdbTvTag = 5;
  int tmdbTvPage = 1;
  int tmdbMoviePage = 1;
  List<MetaDataItem> tmdbMovieTagMap = [
    MetaDataItem(name: '热门', value: 1),
    MetaDataItem(name: '正在上映', value: 2),
    MetaDataItem(name: '即将上映', value: 3),
    MetaDataItem(name: '高分', value: 4),
  ];
  List<MetaDataItem> tmdbTvTagMap = [
    MetaDataItem(name: '热门', value: 5),
    MetaDataItem(name: '今日播出', value: 6),
    MetaDataItem(name: '正在播出', value: 7),
    MetaDataItem(name: '高分', value: 8),
  ];
  SearchResults tmdbMovies = SearchResults(page: 1, totalPages: 1, totalResults: 0);
  SearchResults tmdbTvs = SearchResults(page: 1, totalPages: 1, totalResults: 0);
  List<MediaItem> showTmdbTvList = [];
  List<MediaItem> showTmdbMovieList = [];

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  Future<void> initData() async {
    getTmdbMovies();
    getTmdbTvs();
    await getRankListByType(selectTypeTag);
    await getDouBanMovieHot(selectMovieTag);
    await getDouBanTvHot(selectTvTag);
    update();
  }

  Future<CommonResponse> getTmdbSourceInfo(int type, {int page = 1}) async {
    tmdbLoading = true;
    update();
    CommonResponse response;
    switch (type) {
      case 1:
        response = await getTMDBPopularMovieApi(page: page);
        break;
      case 2:
        response = await getTMDBPlayingMovieApi(page: page);
        break;
      case 3:
        response = await getTMDBUpcomingMovieApi(page: page);
        break;
      case 4:
        response = await getTMDBTopRateMovieApi(page: page);
        break;
      case 5:
        response = await getTMDBPopularTvApi(page: page);
        break;
      case 6:
        response = await getTMDBAiringTvApi(page: page);
        break;
      case 7:
        response = await getTMDBOnTheAirTvApi(page: page);
        break;
      case 8:
        response = await getTMDBTopRateTvApi(page: page);
        break;
      default:
        response = CommonResponse.error(msg: '未知的媒体类型！');
        break;
    }
    tmdbLoading = false;
    update();
    return response;
  }

  Future<CommonResponse> getTmdbMovies() async {
    CommonResponse response = await getTmdbSourceInfo(selectTmdbMovieTag, page: tmdbMoviePage);
    if (response.succeed) {
      // Logger.instance.i(response.data);
      tmdbMovies = SearchResults.fromJson(response.data);
      // 按 ID 去重后追加
      final existingIds = showTmdbMovieList.map((item) => item.id).toSet();
      Logger.instance.i('已存在 ${existingIds.length} 条数据，服务器共有${tmdbMovies.totalPages}页，${tmdbMovies.totalResults} 条数据');
      final newItems = tmdbMovies.results.where((item) => !existingIds.contains(item.id)).toList();
      Logger.instance.i('本次新增 ${newItems.length} 条数据');
      if (newItems.isNotEmpty) {
        showTmdbMovieList.addAll(newItems);
        update();
      }
      Logger.instance.i('更新后共有 ${showTmdbMovieList.length} 条数据');
    } else {
      Logger.instance.e(response.msg);
    }
    return response;
  }

  Future<CommonResponse> getTmdbTvs() async {
    CommonResponse response = await getTmdbSourceInfo(selectTmdbTvTag, page: tmdbTvPage);
    if (response.succeed) {
      // Logger.instance.i(response.data);
      tmdbTvs = SearchResults.fromJson(response.data);
      final existingIds = showTmdbTvList.map((item) => item.id).toSet();
      Logger.instance.i('已存在 ${existingIds.length} 条数据，服务器共有${tmdbTvs.totalPages}页，${tmdbTvs.totalResults} 条数据');

      final newItems = tmdbTvs.results.where((item) => !existingIds.contains(item.id)).toList();
      Logger.instance.i('本次新增 ${newItems.length} 条数据');
      if (newItems.isNotEmpty) {
        showTmdbTvList.addAll(newItems);
        update();
      }
      Logger.instance.i('更新后共有 ${showTmdbMovieList.length} 条数据');
    } else {
      Logger.instance.e(response.msg);
    }
    return response;
  }

  Future<CommonResponse> getTMDBDetail(info) async {
    isLoading = true;
    update();
    if (info.mediaType == 'movie') {
      return await getTMDBMovieInfoApi(info.id);
    } else {
      return await getTMDBTvInfoApi(info.id);
    }
  }

  Future<void> getDouBanMovieTags() async {
    var response = await getCategoryTagsApi(category: 'movie');
    if (response.succeed) {
      douBanMovieTags = List<String>.from(response.data ?? []);
    }
    update();
  }

  Future<void> getDouBanVideoTags() async {
    var response = await getCategoryTagsApi(category: 'tv');
    if (response.succeed) {
      douBanTvTags = List<String>.from(response.data ?? []);
    }
    update();
  }

  Future<void> getRankListByType(String type) async {
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

    CommonResponse res = await getDouBanRankApi(typeId, start: rankMovieList.length, limit: pageLimit);
    if (res.succeed) {
      if (res.data.isEmpty) {
        hasMoreRankData = false;
      } else {
        hasMoreRankData = res.data.length == pageLimit;
        rankMovieList.addAll(res.data);
      }
    }
    Logger.instance.d(rankMovieList);
    update();
    isLoading = false;
    update();
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

  Future<void> getDouBanMovieHot(String tag) async {
    isLoading = true;
    update();
    CommonResponse res = await getDouBanHotMovieApi(tag, douBanMovieHot.length, pageLimit);
    if (res.succeed) {
      douBanMovieHot.addAll(res.data);
    }
    isLoading = false;
    update();
  }

  Future<void> getDouBanTvHot(String tag) async {
    isLoading = true;
    update();
    CommonResponse res = await getDouBanHotTvApi(tag, douBanTvHot.length, pageLimit);
    if (res.succeed) {
      douBanTvHot.addAll(res.data);
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

  Future getVideoDetail(dynamic item, {bool toSearch = false}) async {
    // if (!kIsWeb) {
    //   Logger.instance.i('WebView');
    //   Get.toNamed(Routes.WEBVIEW, arguments: {
    //     'url': item.douBanUrl,
    //     'cookie': item.cookie,
    //   });
    //   return;
    // }
    isLoading = true;
    update();
    String id = extractDoubanId(item.douBanUrl);
    if (id.isEmpty) {
      Logger.instance.e('影视信息 Id 解析失败： URL：${item.douBanUrl}');
      return;
    }
    var res = await getSubjectInfoApi(id);
    Logger.instance.i(res);
    VideoDetail videoDetail = VideoDetail.fromJson(res.data);
    if (toSearch) {
      goSearchPage(videoDetail);
    }
    res.data = videoDetail;
    isLoading = false;
    update();
    return res;
  }

  Future<void> goSearchPage(dynamic detail) async {
    Get.back();
    String searchKey = detail.title;
    if (detail.imdb.isNotEmpty) {
      searchKey = "${detail.imdb}||$searchKey";
    }
    await goSearch(searchKey);
  }

  Future<void> tmdbGoSearchPage(info) async {
    String searchKey = info.title;
    if (info.imdbId.isNotEmpty) {
      searchKey = "${info.imdbId}||$searchKey";
    }
    await goSearch(searchKey);
  }

  Future<void> goSearch(String searchKey) async {
    homeController.changePage(2);
    homeController.update();
    searchController.searchKeyController.text = searchKey;
    await searchController.doWebsocketSearch();
    searchController.update();
    Logger.instance.i(homeController.initPage);
    Logger.instance.i(homeController.pageController.page);
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
