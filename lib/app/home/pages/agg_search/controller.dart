import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/dou_ban/douban_api.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/logger_helper.dart' as LoggerHelper;
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../models/download.dart';
import '../../../../utils/storage.dart';
import '../../../torrent/torrent_controller.dart';
import '../dou_ban/model.dart';
import '../download/download_controller.dart';
import '../models/my_site.dart';
import '../my_site/controller.dart';
import 'douban_search.dart';
import 'models/douban.dart';
import 'models/torrent_info.dart';

class AggSearchController extends GetxController
    with GetSingleTickerProviderStateMixin {
  MySiteController mySiteController = Get.find();
  DownloadController downloadController = Get.put(DownloadController(false));
  late WebSocketChannel channel;
  TextEditingController searchKeyController = TextEditingController();
  String filterKey = '';
  String sortKey = 'seeders';
  List<int> sites = <int>[];
  int maxCount = 0;
  List<SearchTorrentInfo> searchResults = <SearchTorrentInfo>[];
  List<SearchTorrentInfo> showResults = <SearchTorrentInfo>[];
  List<DouBanSearchResult> showDouBanResults = <DouBanSearchResult>[];
  List<Map<String, dynamic>> searchMsg = <Map<String, dynamic>>[];
  List<String> succeedSearchResults = <String>[];
  List<String> succeedCategories = <String>[];
  List<String> succeedTags = <String>[];
  List<String> succeedResolution = <String>[];
  List<String> selectedCategories = <String>[];
  List<String> succeedSiteList = <String>[];
  List<String> selectedSiteList = <String>[];
  List<String> selectedTags = <String>[];
  List<String> selectedResolution = <String>[];
  List<SearchTorrentInfo> hrResultList = <SearchTorrentInfo>[];
  bool sortReversed = false;
  bool isLoading = false;
  bool isDownloaderLoading = false;
  Map<String, MySite> mySiteMap = <String, MySite>{};
  List<Tab> tabs = [
    const Tab(text: '豆瓣搜索'),
    const Tab(text: '资源搜索'),
  ];
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

  late TabController tabController;
  late VideoDetail selectVideoDetail;

  @override
  void onInit() async {
    filterKeyList.insertAll(0, [
      {'name': '站点', 'value': succeedSiteList},
      {'name': '免费', 'value': saleStatusList},
      {'name': '分类', 'value': succeedCategories},
    ]);
    tabController = TabController(length: 2, vsync: this);
    await initData();
    super.onInit();
  }

  initData() async {
    sites = SPUtil.getStringList('custom_search_sites', defaultValue: [])
        .map((e) => int.parse(e))
        .toList();
    maxCount = sites.length;
    if (mySiteController.mySiteList.isEmpty) {
      await mySiteController.initData();
    }
    mySiteMap = {
      for (var mysite in mySiteController.mySiteList) mysite.site: mysite
    };
    await downloadController.getDownloaderListFromServer();
    update();
  }

  saveDefaultSites() async {
    maxCount = sites.length;
    SPUtil.setStringList(
        'custom_search_sites', sites.map((e) => e.toString()).toList());
    update();
  }

  sortResults() {
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
        showResults.sort((a, b) => a.published.compareTo(b.published));
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
    List<SearchTorrentInfo> filteredResults = List.from(searchResults);

    if (hrKey) {
      filteredResults.removeWhere((element) => !element.hr);
    }

    if (selectedSiteList.isNotEmpty) {
      filteredResults
          .retainWhere((element) => selectedSiteList.contains(element.siteId));
    }
    if (selectedResolution.isNotEmpty) {
      filteredResults.retainWhere((element) => selectedResolution.any(
            (item) =>
                element.title.toLowerCase().contains(item.toLowerCase()) ||
                element.subtitle.toLowerCase().contains(item.toLowerCase()),
          ));
    }
    if (selectedCategories.isNotEmpty) {
      filteredResults.retainWhere(
          (element) => selectedCategories.contains(element.category));
    }
    if (selectedTags.isNotEmpty) {
      filteredResults.retainWhere((element) => selectedTags.any(
            (item) => element.tags.contains(item),
          ));
    }
    if (selectedSaleStatusList.isNotEmpty) {
      filteredResults.retainWhere(
          (element) => selectedSaleStatusList.contains(element.saleStatus));
    }

    showResults = filteredResults;
    sortResults();
    update();
  }

  cancelSearch() {
    isLoading = false;
    channel.sink.close(status.goingAway);
    update();
  }

  doDouBanSearch() async {
    if (searchKeyController.text.isEmpty) {
      LoggerHelper.Logger.instance.d("搜索关键字不能为空");
      return;
    }
    DouBanSearchHelper helper = DouBanSearchHelper();
    isLoading = true;
    changeTab(0);
    update();
    var response = await helper.doSearch(
      q: searchKeyController.text,
    );
    showDouBanResults = response.data!;
    LoggerHelper.Logger.instance.d(showDouBanResults);
    showDouBanResults.sort((a, b) => b.target.year.compareTo(a.target.year));
    // showResults.clear();
    isLoading = false;
    update();
  }

  getSubjectInfo(String subject) async {
    isLoading = true;
    update();
    DouBanHelper helper = DouBanHelper();
    selectVideoDetail = await helper.getSubjectInfo(subject);
    isLoading = false;
    update();
  }

  goSearchPage(String subject) async {
    await getSubjectInfo(subject);
    String searchKey = selectVideoDetail.title;
    if (selectVideoDetail.imdb.isNotEmpty) {
      searchKey = "${selectVideoDetail.imdb}||$searchKey";
    }
    searchKeyController.text = searchKey;
    await doWebsocketSearch();
  }

  changeTab(int index) {
    tabController.animateTo(index);
    update();
  }

  doWebsocketSearch() async {
    // 打开加载状态
    isLoading = true;
    // 清空搜索记录
    initSearchResult();
    changeTab(1);
    // 初始化站点数据
    if (mySiteMap.isEmpty) {
      LoggerHelper.Logger.instance.d('重新加载站点列表');
      await initData();
    }
    try {
      String baseUrl = SPUtil.getLocalStorage('server');
      final wsUrl =
          Uri.parse('${baseUrl.replaceFirst('http', 'ws')}/api/ws/search');
      channel = WebSocketChannel.connect(wsUrl);

      await channel.ready;
      channel.sink.add(json.encode({
        "key": searchKeyController.text,
        "max_count": sites.length == mySiteMap.length ? maxCount : sites.length,
        "sites": sites,
      }));
      channel.stream.listen((message) {
        CommonResponse response =
            CommonResponse.fromJson(json.decode(message), (p0) => p0);
        LoggerHelper.Logger.instance.i(response.msg);
        if (response.code == 0) {
          List<SearchTorrentInfo> torrentInfoList =
              List<Map<String, dynamic>>.from(response.data)
                  .map((jsonItem) => SearchTorrentInfo.fromJson(jsonItem))
                  .toList();
          // 写入种子列表
          searchResults.addAll(torrentInfoList);
          hrResultList
              .addAll(torrentInfoList.where((element) => element.hr).toList());
          succeedTags.addAll(torrentInfoList.expand((element) => element.tags));
          if (succeedTags.isNotEmpty) {
            succeedTags = succeedTags.toSet().toList();
            succeedTags.sort();
            LoggerHelper.Logger.instance.d(succeedTags);
          }
          succeedResolution.addAll(torrentInfoList
              .map((item) => resolutionKeyList
                  .firstWhereOrNull((MetaDataItem resolution) =>
                      item.title
                          .toLowerCase()
                          .contains(resolution.value.toLowerCase()) ||
                      item.subtitle
                          .toLowerCase()
                          .contains(resolution.value.toLowerCase()))
                  ?.value)
              .whereType<String>() // 将结果转换为 List<String>
              .toList());
          succeedResolution = succeedResolution.toSet().toList();
          LoggerHelper.Logger.instance.d(succeedResolution);
          // 获取种子分类，并去重
          succeedCategories
              .addAll(torrentInfoList.map((e) => e.category).toList());
          succeedCategories = succeedCategories.toSet().toList();
          saleStatusList
              .addAll(torrentInfoList.map((e) => e.saleStatus).toList());
          saleStatusList = saleStatusList.toSet().toList();
          // 写入有数据的站点
          if (torrentInfoList.isNotEmpty) {
            succeedSiteList.add(torrentInfoList[0].siteId);
            searchMsg.insert(0, {"success": true, "msg": response.msg});
            filterResults();
          }
          update();
        } else {
          searchMsg.add({"success": false, "msg": response.msg});
          update();
        }
      }, onError: (err) {
        LoggerHelper.Logger.instance.e('搜索出错啦： ${err.toString()}');
        searchMsg.add({"success": false, "msg": '搜索出错啦：$err'});
        cancelSearch();
      }, onDone: () {
        LoggerHelper.Logger.instance.e('搜索完成啦！');
        cancelSearch();
      });
    } catch (e, trace) {
      LoggerHelper.Logger.instance.e(e);
      LoggerHelper.Logger.instance.d(trace);
      searchMsg.add({"success": false, "msg": '搜索出错啦：$e'});
      cancelSearch();
    }
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
    update();
  }

  Future<CommonResponse> getMTeamDlLink(
      MySite mySite, SearchTorrentInfo torrent) async {
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

  Future<Map<String, String>> getDownloaderCategories(
      Downloader downloader) async {
    isDownloaderLoading = true;
    try {
      TorrentController torrentController = Get.put(
          TorrentController(downloader, false),
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
      // TorrentController torrentController = Get.find(
      //     tag:
      //         '${downloader.protocol}://${downloader.host}:${downloader.port}');
      if (downloader.category.toLowerCase() == 'tr') {
        torrentController.getAllTorrents();
      }
      update(['${downloader.id} - ${downloader.name}']);
      await torrentController.getAllCategory();
      isDownloaderLoading = false;
      update(['${downloader.id} - ${downloader.name}']);
      update();
      torrentController.update();

      return torrentController.categoryList;
    } catch (e, trace) {
      LoggerHelper.Logger.instance.e(e);
      LoggerHelper.Logger.instance.e(trace);
      isDownloaderLoading = false;
      return {};
    }
  }
}
