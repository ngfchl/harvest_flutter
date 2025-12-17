import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:get/get.dart';
import 'package:harvest/api/tmdb.dart' as tmdb;
import 'package:harvest/app/home/pages/dou_ban/douban_api.dart';
import 'package:harvest/app/home/pages/models/dou_ban_info.dart';
import 'package:harvest/app/home/pages/models/douban.dart';
import 'package:harvest/app/home/pages/models/torrent_info.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/logger_helper.dart' as logger_helper;
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../api/api.dart';
import '../../../../api/downloader.dart';
import '../../../../models/authinfo.dart';
import '../../../../utils/flutter_client_sse.dart';
import '../../../../utils/storage.dart';
import '../download/download_controller.dart';
import '../models/download.dart';
import '../models/my_site.dart';
import '../models/option.dart';
import '../my_site/controller.dart';
import 'douban_search.dart';
import 'models.dart';

class AggSearchController extends GetxController with GetSingleTickerProviderStateMixin {
  MySiteController mySiteController = Get.find();
  DownloadController downloadController = Get.put(DownloadController(false));
  TextEditingController searchKeyController = TextEditingController();
  String filterKey = '';
  String sortKey = 'seeders';
  late WebSocketChannel channel;
  List<int> sites = <int>[];
  int maxCount = 0;
  List<SearchTorrentInfo> searchResults = <SearchTorrentInfo>[];
  List<SearchTorrentInfo> showResults = <SearchTorrentInfo>[];
  List<DouBanSearchResult> showDouBanResults = <DouBanSearchResult>[];
  List<Map<String, dynamic>> searchMsg = <Map<String, dynamic>>[];
  List<String> searchHistory = <String>[];
  List<String> succeedSearchResults = <String>[];
  List<String> succeedCategories = <String>[];
  List<String> succeedTags = <String>[];
  List<String> succeedResolution = <String>[];
  List<String> selectedCategories = <String>[];
  List<String> succeedSiteList = <String>[];
  List<String> selectedSiteList = <String>[];
  List<String> selectedTags = <String>[];
  List<String> selectedResolution = <String>[];
  List<String> selectedSeason = <String>[];
  List<String> selectedEpisode = <String>[];
  List<SearchTorrentInfo> hrResultList = <SearchTorrentInfo>[];
  int calcSize = 1024 * 1024 * 1024;
  double maxSize = 100 * 1024 * 1024 * 1024;
  double minSize = 0;

  bool sortReversed = false;
  bool isLoading = false;
  bool downloaderListLoading = false;
  bool isDownloaderLoading = false;
  String dataSource = 'TMDB';
  Floating? floating;
  Map<String, MySite> mySiteMap = <String, MySite>{};
  List<MetaDataItem> sortKeyList = [
    {'name': '发布时间', 'value': 'published'},
    {'name': '大小', 'value': 'size'},
    {'name': '分类', 'value': 'category'},
    {'name': '名称', 'value': 'title'},
    {'name': '免费', 'value': 'free'},
    {'name': '站点', 'value': 'siteId'},
    {'name': '做种', 'value': 'seeders'},
    {'name': '吸血', 'value': 'leechers'},
    {'name': '完成', 'value': 'completers'},
  ].map((m) => MetaDataItem.fromJson(m)).toList();

  List<MetaDataItem> resolutionKeyList = [
    {'name': '480P', 'value': '480P'},
    {'name': '720P', 'value': '720P'},
    {'name': '1080i', 'value': '1080i'},
    {'name': '1080P', 'value': '1080P'},
    {'name': '2160P', 'value': '2160P'},
    {'name': '4K', 'value': '4K'},
    {'name': '8K', 'value': '8K'},
  ].map((m) => MetaDataItem.fromJson(m)).toList();

  List<Map<String, dynamic>> filterKeyList = [];
  List<String> saleStatusList = [];
  List<String> selectedSaleStatusList = [];
  bool hrKey = false;
  Option? option;
  List<MediaItem> results = [];
  ShadTabsController<String> tabsController = ShadTabsController<String>(value: 'warehouse');
  String selectedWarehouse = '';
  late VideoDetail selectVideoDetail;
  String baseUrl = SPUtil.getLocalStorage('server');

  @override
  void onInit() async {
    filterKeyList.insertAll(0, [
      {'name': '站点', 'value': succeedSiteList},
      {'name': '免费', 'value': saleStatusList},
      {'name': '分类', 'value': succeedCategories},
    ]);
    await initData();
    super.onInit();
  }

  Future<void> updateSearchHistory(String element) async {
    element = element.trim();
    if (element.isEmpty) {
      return;
    }
    searchHistory.insert(0, element);
    searchHistory = searchHistory.toSet().toList();
    SPUtil.setStringList('search_history', searchHistory);
    update([
      Key('agg_search_history'),
    ]);
  }

  Future<CommonResponse> searchTMDB() async {
    if (searchKeyController.text.isEmpty) {
      return CommonResponse.error(msg: "搜索关键字不能为空！");
    }
    results.clear();
    isLoading = true;
    changeTab('warehouse');
    selectedWarehouse = 'TMDB';
    updateSearchHistory(searchKeyController.text);
    update();
    logger_helper.Logger.instance.d(searchKeyController.text);
    CommonResponse response = await tmdb.getTMDBSearchApi(searchKeyController.text);
    if (response.succeed != true) {
      isLoading = false;
      update();
      return response;
    }
    results = response.data
        .map((item) {
          try {
            return MediaItem.fromJson(item);
          } catch (e) {
            return null;
          }
        })
        .whereType<MediaItem>()
        .toList();
    logger_helper.Logger.instance.d(results);
    results.sort((a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));
    logger_helper.Logger.instance.d(results);
    isLoading = false;
    update();
    return response;
  }

  getTMDBMovieDetail(int id) async {
    var res = await tmdb.getTMDBMovieInfoApi(id);
    logger_helper.Logger.instance.d(res);
    if (!res.succeed) {
      return res;
    }
    return CommonResponse.success(data: MovieDetail.fromJson(res.data as Map<String, dynamic>));
  }

  getTMDBTVDetail(int id) async {
    var res = await tmdb.getTMDBTvInfoApi(id);
    logger_helper.Logger.instance.d(res);
    if (!res.succeed) {
      return res;
    }
    return CommonResponse.success(data: TvShowDetail.fromJson(res.data as Map<String, dynamic>));
  }

  dynamic getTMDBDetail(info) {
    isLoading = true;
    update();
    if (info.mediaType == 'movie') {
      return getTMDBMovieDetail(info.id);
    } else {
      return getTMDBTVDetail(info.id);
    }
  }

  doTMDBSearch(info) async {
    String searchKey;
    String? imdbId;
    if (info.runtimeType == MediaItem) {
      var detail = await getTMDBDetail(info);
      if (!detail.succeed) {
        isLoading = false;
        logger_helper.Logger.instance.e(detail.msg);
        update();
        return detail;
      }
      searchKey = detail.title;
      imdbId = detail.imdbId;
    } else {
      searchKey = info.title;
      imdbId = info.imdbId;
    }

    if (imdbId?.isNotEmpty == true) {
      searchKey = "$imdbId||$searchKey";
    }
    searchKeyController.text = searchKey;
    await doWebsocketSearch();
  }

  Future<void> initData() async {
    // minSize = SPUtil.getDouble('searchFilterFileMinSize',
    //     defaultValue: 1.0 * calcSize)!;
    // maxSize = SPUtil.getDouble('searchFilterFileMaxSize',
    //     defaultValue: 100.0 * calcSize)!;
    sites = SPUtil.getStringList('custom_search_sites', defaultValue: []).map((e) => int.parse(e)).toList();
    searchHistory = SPUtil.getStringList('search_history', defaultValue: []);
    maxCount = sites.length;
    if (mySiteController.mySiteList.isEmpty) {
      await mySiteController.initData();
    }
    mySiteMap = {for (var mysite in mySiteController.mySiteList) mysite.site: mysite};
    if (downloadController.dataList.isEmpty) {
      await downloadController.getDownloaderListFromServer();
    }

    update();
  }

  Future<void> saveDefaultSites() async {
    maxCount = sites.length;
    SPUtil.setStringList('custom_search_sites', sites.map((e) => e.toString()).toList());
    update();
  }

  Future<void> initDefaultSites() async {
    sites = SPUtil.getStringList('custom_search_sites', defaultValue: []).map((e) => int.parse(e)).toList();
    update();
  }

  void sortResults() {
    if (sortKey.isEmpty) {
      return;
    }
    switch (sortKey) {
      case 'siteId':
        showResults.sort((a, b) => a.siteId.compareTo(b.siteId));
        break;
      case 'category':
        showResults.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'title':
        showResults.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'published':
        showResults.sort((a, b) {
          String aPublish;
          String bPublish;
          if (a.published is DateTime) {
            aPublish = DateFormat('yyyy-MM-dd HH:mm:ss').format(a.published);
          } else {
            aPublish = a.published;
          }
          if (b.published is DateTime) {
            bPublish = DateFormat('yyyy-MM-dd HH:mm:ss').format(b.published);
          } else {
            bPublish = b.published;
          }
          return aPublish.compareTo(bPublish);
        });
        break;
      case 'size':
        showResults.sort((a, b) => b.size.compareTo(a.size));
        break;
      case 'seeders':
        showResults.sort((a, b) => b.seeders.compareTo(a.seeders));
        break;
      case 'leechers':
        showResults.sort((a, b) => a.leechers.compareTo(b.leechers));
        break;
      case 'completers':
        showResults.sort((a, b) => a.completers.compareTo(b.completers));
        break;
    }
    if (sortReversed) {
      showResults = showResults.reversed.toList();
    }
    update();
  }

  void filterResults() {
    // 过滤结果
    final filteredResults = searchResults.where((element) {
      final title = element.title.toLowerCase();
      final subtitle = element.subtitle.toLowerCase();

      // HR 过滤
      if (hrKey && !element.hr) return false;

      // 站点
      if (selectedSiteList.isNotEmpty && !selectedSiteList.contains(element.siteId)) return false;

      // 分辨率
      if (selectedResolution.isNotEmpty &&
          !selectedResolution.any((r) => title.contains(r.toLowerCase()) || subtitle.contains(r.toLowerCase()))) {
        return false;
      }

      // 分类
      if (selectedCategories.isNotEmpty && !selectedCategories.contains(element.category)) return false;

      // 标签
      if (selectedTags.isNotEmpty && !selectedTags.any((tag) => element.tags.contains(tag))) return false;

      // 季
      if (selectedSeason.isNotEmpty && !selectedSeason.any((s) => title.contains(s.toLowerCase()))) return false;

      // 集
      if (selectedEpisode.isNotEmpty && !selectedEpisode.any((e) => title.contains(e.toLowerCase()))) return false;

      // 销售状态
      if (selectedSaleStatusList.isNotEmpty && !selectedSaleStatusList.contains(element.saleStatus)) return false;

      // 大小范围
      if (element.size < minSize || element.size > maxSize) return false;

      return true;
    }).toList();
    logger_helper.Logger.instance.d(filteredResults.length);

    showResults = filteredResults;
    sortResults();
    update();
  }

  Future<void> cancelSearch() async {
    isLoading = false;
    // SSEClient.disableRetry();
    // SSEClient.unsubscribeFromSSE();
    try {
      await channel.sink.close(status.normalClosure);
    } catch (err) {
      logger_helper.Logger.instance.e(err);
    }
    update();
  }

  Future<void> doDouBanSearch() async {
    if (searchKeyController.text.isEmpty) {
      logger_helper.Logger.instance.d("搜索关键字不能为空");
      return;
    }
    showDouBanResults.clear();
    update();
    DouBanSearchHelper helper = DouBanSearchHelper();
    isLoading = true;
    changeTab('warehouse');
    selectedWarehouse = '豆瓣';
    update();
    var response = await helper.doSearch(
      q: searchKeyController.text,
    );
    showDouBanResults = response.data!;
    logger_helper.Logger.instance.d(showDouBanResults);
    showDouBanResults.sort((a, b) => b.target.rating.value.compareTo(a.target.rating.value));
    // showResults.clear();
    isLoading = false;
    update();
  }

  Future<void> getSubjectInfo(String subject) async {
    isLoading = true;
    update();
    DouBanHelper helper = DouBanHelper();
    selectVideoDetail = await helper.getSubjectInfo(subject);
    isLoading = false;
    update();
  }

  Future<void> goSearchPage(String subject) async {
    await getSubjectInfo(subject);
    String searchKey = selectVideoDetail.title;
    if (selectVideoDetail.imdb.isNotEmpty) {
      searchKey = "${selectVideoDetail.imdb}||$searchKey";
    }
    searchKeyController.text = searchKey;
    await doWebsocketSearch();
  }

  void changeTab(String tab) {
    tabsController.select(tab);
    update();
  }

  Future<void> doWebsocketSearch() async {
    // 打开加载状态
    isLoading = true;
    // 清空搜索记录
    initSearchResult();
    changeTab('agg_search');
    // 初始化站点数据
    if (mySiteMap.isEmpty) {
      logger_helper.Logger.instance.d('重新加载站点列表');
      await initData();
    }
    try {
      final wsUrl = Uri.parse('${baseUrl.replaceFirst('http', 'ws')}/api/ws/search');
      channel = WebSocketChannel.connect(wsUrl);
      updateSearchHistory(searchKeyController.text);
      await channel.ready;
      channel.sink.add(json.encode({
        "key": searchKeyController.text,
        "max_count": sites.length == mySiteMap.length ? maxCount : sites.length,
        "sites": sites,
      }));

      channel.stream.listen((message) {
        CommonResponse response = CommonResponse.fromJson(json.decode(message), (p0) => p0);
        logger_helper.Logger.instance.i(response.msg);
        if (response.code == 0) {
          List<SearchTorrentInfo> torrentInfoList = List<Map<String, dynamic>>.from(response.data)
              .map((jsonItem) => SearchTorrentInfo.fromJson(jsonItem))
              .toList();
          // 写入种子列表
          searchResults.addAll(torrentInfoList);
          hrResultList.addAll(torrentInfoList.where((element) => element.hr).toList());
          succeedTags.addAll(torrentInfoList.expand((element) => element.tags));
          if (succeedTags.isNotEmpty) {
            succeedTags = succeedTags.toSet().toList();
            succeedTags.sort();
            logger_helper.Logger.instance.d(succeedTags);
          }
          succeedResolution.addAll(torrentInfoList
              .map((item) => resolutionKeyList
                  .firstWhereOrNull((MetaDataItem resolution) =>
                      item.title.toLowerCase().contains(resolution.value.toLowerCase()) ||
                      item.subtitle.toLowerCase().contains(resolution.value.toLowerCase()))
                  ?.value)
              .whereType<String>() // 将结果转换为 List<String>
              .toList());
          succeedResolution = succeedResolution.toSet().toList();
          succeedResolution.sort();
          logger_helper.Logger.instance.d(succeedResolution);
          // 获取种子分类，并去重
          succeedCategories.addAll(torrentInfoList.map((e) => e.category).toList());
          succeedCategories = succeedCategories.toSet().toList();
          succeedCategories.sort();
          saleStatusList.addAll(torrentInfoList.map((e) => e.saleStatus).toList());
          saleStatusList = saleStatusList.toSet().toList();
          saleStatusList.sort();
          // 写入有数据的站点
          if (torrentInfoList.isNotEmpty) {
            succeedSiteList.add(torrentInfoList[0].siteId);
            succeedSiteList.sort();
            searchMsg.insert(0, {"success": true, "msg": response.msg});
            filterResults();
          }
          update();
        } else {
          searchMsg.add({"success": false, "msg": response.msg});
          update();
        }
      }, onError: (err) {
        logger_helper.Logger.instance.e('搜索出错啦： ${err.toString()}');
        searchMsg.add({"success": false, "msg": '搜索出错啦：$err'});
        cancelSearch();
      }, onDone: () {
        logger_helper.Logger.instance.e('搜索完成啦！');
        cancelSearch();
      });
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.d(trace);
      searchMsg.add({"success": false, "msg": '搜索出错啦：$e'});
      cancelSearch();
    }
  }

  Future<void> doSearch() async {
    // 打开加载状态
    isLoading = true;
    // 清空搜索记录
    initSearchResult();
    changeTab('agg_search');
    // 初始化站点数据
    if (mySiteMap.isEmpty) {
      logger_helper.Logger.instance.w('重新加载站点列表');
      await initData();
    }
    // 准备基础数据
    try {
      Map userinfo = SPUtil.getMap('userinfo');
      AuthInfo authInfo = AuthInfo.fromJson(userinfo as Map<String, dynamic>);
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${authInfo.authToken}'
      };

      // 打开 SSE 通道，开始搜索
      SSEClient.subscribeToSSE(
          method: SSERequestType.POST,
          url: '$baseUrl/api/${Api.WEBSITE_SEARCH}',
          header: headers,
          body: {
            "key": searchKeyController.text,
            "max_count": sites.length == mySiteMap.length ? maxCount : sites.length,
            "sites": sites,
          }).listen((event) {
        Map<String, dynamic> jsonData = json.decode(event.data!);
        logger_helper.Logger.instance.w(event.data!);
        if (jsonData['code'] == 0) {
          try {
            if (jsonData['data'] is bool) {
              logger_helper.Logger.instance.w('搜索完成，断开连接！');
              isLoading = false;
              cancelSearch();
              update();
              return;
            }
            List<Map<String, dynamic>> jsonList = jsonData['data'].cast<Map<String, dynamic>>();
            List<SearchTorrentInfo> torrentInfoList =
                jsonList.map((jsonItem) => SearchTorrentInfo.fromJson(jsonItem)).toList();
            // 写入种子列表
            searchResults.addAll(torrentInfoList);
            hrResultList.addAll(torrentInfoList.where((element) => element.hr).toList());
            succeedTags.addAll(torrentInfoList.expand((element) => element.tags));
            if (succeedTags.isNotEmpty) {
              succeedTags = succeedTags.toSet().toList();
              succeedTags.sort();
              logger_helper.Logger.instance.d(succeedTags);
            }
            succeedResolution.addAll(torrentInfoList
                .map((item) => resolutionKeyList
                    .firstWhereOrNull((MetaDataItem resolution) =>
                        item.title.toLowerCase().contains(resolution.value.toLowerCase()) ||
                        item.subtitle.toLowerCase().contains(resolution.value.toLowerCase()))
                    ?.value)
                .whereType<String>() // 将结果转换为 List<String>
                .toList());
            succeedResolution = succeedResolution.toSet().toList();
            logger_helper.Logger.instance.d(succeedResolution);
            // 获取种子分类，并去重
            succeedCategories.addAll(torrentInfoList.map((e) => e.category).toList());
            succeedCategories = succeedCategories.toSet().toList();
            saleStatusList.addAll(torrentInfoList.map((e) => e.saleStatus).toList());
            saleStatusList = saleStatusList.toSet().toList();
            // 写入有数据的站点
            if (torrentInfoList.isNotEmpty) {
              succeedSiteList.add(torrentInfoList[0].siteId);
              searchMsg.insert(0, {
                "success": true,
                "msg": jsonData['msg'],
              });
              filterResults();
            }
            update();
          } catch (e, trace) {
            logger_helper.Logger.instance.e(e.toString());
            logger_helper.Logger.instance.e(trace.toString());
            isLoading = false;
            SSEClient.unsubscribeFromSSE();
            update();
          }
        } else {
          searchMsg.add({
            "success": false,
            "msg": jsonData['msg'],
          });
          update();
        }
      }, onError: (err) {
        isLoading = false;
        SSEClient.unsubscribeFromSSE();
        logger_helper.Logger.instance.e('搜索出错啦： ${err.toString()}');
        update();
      }, onDone: () {
        isLoading = false;
        SSEClient.unsubscribeFromSSE();
        logger_helper.Logger.instance.e('搜索完成啦！');
      });
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.d(trace);
      searchMsg.add({"success": false, "msg": '搜索出错啦：$e'});
      cancelSearch();
    }
    update();
  }

  void initSearchResult() {
    searchResults.clear();
    searchMsg.clear();
    succeedTags.clear();
    succeedResolution.clear();
    succeedCategories.clear();
    selectedSiteList.clear();
    succeedSiteList.clear();
    showResults.clear();
    selectedSiteList.clear();
    selectedResolution.clear();
    selectedCategories.clear();
    selectedTags.clear();
    selectedSaleStatusList.clear();
    update();
  }

  Future<CommonResponse> getMTeamDlLink(MySite mySite, SearchTorrentInfo torrent) async {
    String url = '${mySite.mirror}api/torrent/genDlToken';
    final res = await Dio(BaseOptions(headers: {
      'x-api-key': '${mySite.authKey}',
      'User-Agent': mySite.userAgent,
    })).post(
      url,
      queryParameters: {"id": torrent.tid},
    );
    if (res.data['code'] == "0" || res.data['code'] == 0) {
      return CommonResponse.success(data: res.data['data']);
    }
    return CommonResponse.error(msg: res.data['message']);
  }

  Future<CommonResponse> getDownloaderCategoryList(Downloader downloader) async {
    isDownloaderLoading = true;
    update();
    try {
      CommonResponse response = await getDownloaderCategories(downloader.id!);
      if (!response.succeed) {
        return response;
      }
      Map<String, Category> data = {
        for (var item in response.data) (item)['name']!: Category.fromJson(item as Map<String, dynamic>)
      };
      isDownloaderLoading = false;
      update();
      return CommonResponse.success(data: data);
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.e(trace);
      return CommonResponse.error(msg: '获取分类出错啦：$e');
    }
  }
// Future<Map<String, String>> getDownloaderCategories(
//     Downloader downloader) async {
//   isDownloaderLoading = true;
//   try {
//     TorrentController torrentController = Get.put(
//         TorrentController(downloader, false),
//         tag:
//             '${downloader.protocol}://${downloader.host}:${downloader.port}');
//     // TorrentController torrentController = Get.find(
//     //     tag:
//     //         '${downloader.protocol}://${downloader.host}:${downloader.port}');
//     if (downloader.category.toLowerCase() == 'tr') {
//       torrentController.getAllTorrents();
//     }
//     update(['${downloader.id} - ${downloader.name}']);
//     await torrentController.getAllCategory();
//     isDownloaderLoading = false;
//     update(['${downloader.id} - ${downloader.name}']);
//     update();
//     torrentController.update();
//
//     return torrentController.categoryList;
//   } catch (e, trace) {
//     logger_helper.Logger.instance.e(e);
//     logger_helper.Logger.instance.e(trace);
//     isDownloaderLoading = false;
//     return {};
//   }
// }
}
