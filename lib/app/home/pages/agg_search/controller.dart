import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/api/api.dart';
import 'package:harvest/utils/logger_helper.dart' as LoggerHelper;

import '../../../../models/authinfo.dart';
import '../models/my_site.dart';
import '../my_site/controller.dart';
import 'models/torrent_info.dart';

class AggSearchController extends GetxController {
  MySiteController mySiteController = Get.find();
  RxString searchKey = ''.obs;
  RxList<int> sites = <int>[].obs;
  RxInt maxCount = 10.obs;
  RxList<TorrentInfo> searchResults = <TorrentInfo>[].obs;
  RxList<Map<String, dynamic>> searchMsg = <Map<String, dynamic>>[].obs;
  RxList<String> succeedSearchResults = <String>[].obs;

  RxBool isLoading = false.obs;
  GetStorage box = GetStorage();
  RxMap<String, MySite> mySiteMap = <String, MySite>{}.obs;

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await mySiteController.initData();
    mySiteMap.value = {
      for (var mysite in mySiteController.mySiteList) mysite.site: mysite
    };
  }

  cancelSearch() async {
    isLoading.value = false;
    SSEClient.unsubscribeFromSSE();
    update();
  }

  doSearch() async {
    // 清空搜索记录
    searchResults.clear();
    searchMsg.clear();
    update();

    // 打开加载状态
    isLoading.value = true;
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
          "key": searchKey.value,
          "max_count": maxCount.value,
          "sites": sites,
        }).listen((event) {
      Map<String, dynamic> jsonData = json.decode(event.data!);
      LoggerHelper.Logger.instance.w(event.data!);
      if (jsonData['code'] == 0) {
        try {
          List<Map<String, dynamic>> jsonList =
              jsonData['data'].cast<Map<String, dynamic>>();
          List<TorrentInfo> torrentInfoList = jsonList
              .map((jsonItem) => TorrentInfo.fromJson(jsonItem))
              .toList();
          searchResults.addAll(torrentInfoList);
          searchMsg.insert(0, {
            "success": true,
            "msg": jsonData['msg'],
          });
          update();
        } catch (e, trace) {
          LoggerHelper.Logger.instance.e(e.toString());
          LoggerHelper.Logger.instance.e(trace.toString());
          isLoading.value = false;
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
      LoggerHelper.Logger.instance.e('搜索出错啦： ${err.toString()}');
      isLoading.value = false;
      update();
    }, onDone: () {
      LoggerHelper.Logger.instance.e('搜索完成啦！');
      isLoading.value = false;
      SSEClient.unsubscribeFromSSE();
      update();
    });
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
