import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/api/api.dart';
import 'package:harvest/utils/logger_helper.dart' as LoggerHelper;

import '../../../../models/authinfo.dart';
import '../../../../models/download.dart';
import '../../../torrent/torrent_controller.dart';
import '../download/download_controller.dart';
import '../models/my_site.dart';
import '../my_site/controller.dart';
import 'models/torrent_info.dart';

class AggSearchController extends GetxController {
  MySiteController mySiteController = Get.find();
  DownloadController downloadController = Get.find();

  String searchKey = '';
  String filterKey = '';
  String sortKey = '';
  List<int> sites = <int>[];
  int maxCount = 0;
  List<SearchTorrentInfo> searchResults = <SearchTorrentInfo>[];
  List<SearchTorrentInfo> showResults = <SearchTorrentInfo>[];
  List<Map<String, dynamic>> searchMsg = <Map<String, dynamic>>[];
  List<String> succeedSearchResults = <String>[];
  List<String> succeedCategories = <String>[];
  List<String> succeedTags = <String>[];
  List<String> selectedCategories = <String>[];
  List<String> succeedSiteList = <String>[];
  List<String> selectedSiteList = <String>[];
  List<String> selectedTags = <String>[];
  List<SearchTorrentInfo> hrResultList = <SearchTorrentInfo>[];
  bool sortReversed = false;
  bool isLoading = false;
  bool isDownloaderLoading = false;
  GetStorage box = GetStorage();
  Map<String, MySite> mySiteMap = <String, MySite>{};

  List<Map<String, String>> sortKeyList = [
    {'name': '发布时间', 'value': 'published'},
    {'name': '大小', 'value': 'size'},
    {'name': '分类', 'value': 'category'},
    {'name': '名称', 'value': 'title'},
    {'name': '免费', 'value': 'free'},
    {'name': '站点', 'value': 'siteId'},
    {'name': '做种', 'value': 'seeders'},
    {'name': '吸血', 'value': 'leechers'},
    {'name': '完成', 'value': 'completers'},
  ];
  List<Map<String, dynamic>> filterKeyList = [];
  List<String> saleStatusList = [];
  List<String> selectedSaleStatusList = [];
  bool hrKey = false;

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

  initData() async {
    await mySiteController.initData();
    mySiteMap = {
      for (var mysite in mySiteController.mySiteList) mysite.site: mysite
    };
    await downloadController.getDownloaderListFromServer();
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
        showResults.sort((a, b) => a.size.compareTo(b.size));
        break;
      case 'seeders':
        showResults.sort((a, b) => a.seeders.compareTo(b.seeders));
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
      filteredResults.removeWhere((element) => element.hr);
    }

    if (selectedSiteList.isNotEmpty) {
      filteredResults
          .retainWhere((element) => selectedSiteList.contains(element.siteId));
    }

    if (selectedCategories.isNotEmpty) {
      filteredResults.retainWhere(
          (element) => selectedCategories.contains(element.category));
    }

    if (selectedSaleStatusList.isNotEmpty) {
      filteredResults.retainWhere(
          (element) => selectedSaleStatusList.contains(element.saleStatus));
    }

    showResults = filteredResults;
    sortResults();
    update();
  }

  cancelSearch() async {
    isLoading = false;
    SSEClient.unsubscribeFromSSE();
    update();
  }

  doSearch() async {
    // 打开加载状态
    isLoading = true;
    // 清空搜索记录
    initSearchResult();

    // 初始化站点数据
    if (mySiteMap.isEmpty) {
      LoggerHelper.Logger.instance.w('重新加载站点列表');
      await initData();
    }
    // 准备基础数据
    Map<String, dynamic> userinfo = box.read('userinfo') ?? {};
    AuthInfo authInfo = AuthInfo.fromJson(userinfo);
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer ${authInfo.authToken}'
    };

    // 打开 SSE 通道，开始搜索
    SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: '${box.read('server')}/api/${Api.WEBSITE_SEARCH}',
        header: headers,
        body: {
          "key": searchKey,
          "max_count": maxCount,
          "sites": sites,
        }).listen((event) {
      Map<String, dynamic> jsonData = json.decode(event.data!);
      LoggerHelper.Logger.instance.w(event.data!);
      if (jsonData['code'] == 0) {
        try {
          List<Map<String, dynamic>> jsonList =
              jsonData['data'].cast<Map<String, dynamic>>();
          List<SearchTorrentInfo> torrentInfoList = jsonList
              .map((jsonItem) => SearchTorrentInfo.fromJson(jsonItem))
              .toList();
          // 写入种子列表
          searchResults.addAll(torrentInfoList);
          hrResultList
              .addAll(torrentInfoList.where((element) => element.hr).toList());
          // 获取种子分类，并去重
          succeedCategories
              .addAll(torrentInfoList.map((e) => e.category).toList());
          succeedCategories = succeedCategories.toSet().toList();
          saleStatusList
              .addAll(torrentInfoList.map((e) => e.saleStatus).toList());
          saleStatusList = saleStatusList.toSet().toList();
          // 写入有数据的站点
          succeedSiteList.add(torrentInfoList[0].siteId);
          searchMsg.insert(0, {
            "success": true,
            "msg": jsonData['msg'],
          });
          filterResults();
          update();
        } catch (e, trace) {
          LoggerHelper.Logger.instance.e(e.toString());
          LoggerHelper.Logger.instance.e(trace.toString());
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
      LoggerHelper.Logger.instance.e('搜索出错啦： ${err.toString()}');
      update();
    }, onDone: () {
      isLoading = false;
      SSEClient.unsubscribeFromSSE();
      LoggerHelper.Logger.instance.e('搜索完成啦！');
    });

    update();
  }

  void initSearchResult() {
    searchResults.clear();
    searchMsg.clear();
    succeedCategories.clear();
    selectedSiteList.clear();
    succeedSiteList.clear();
    showResults.clear();
    update();
  }

  Future<Map<String, String>> getDownloaderCategories(
      Downloader downloader) async {
    isDownloaderLoading = true;
    try {
      Get.put(TorrentController(downloader, false),
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
      TorrentController torrentController = Get.find(
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
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
