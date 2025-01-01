import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // ignore: depend_on_referenced_packages
import 'package:harvest/app/home/pages/download/qbittorrent.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart' as tr;
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../api/api.dart';
import '../../../../api/downloader.dart';
import '../../../../common/meta_item.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../../../utils/storage.dart';
import '../../../torrent/models/transmission_base_torrent.dart';
import '../models/transmission.dart';
import '../models/website.dart';
import '../my_site/controller.dart';

class DownloadController extends GetxController {
  bool isLoaded = false;
  MySiteController mySiteController = Get.find();
  List<Downloader> dataList = <Downloader>[];
  Map<String, Downloader> dataMap = {};
  List<String> pathList = <String>[];
  bool isTimerActive = true; // 使用 RxBool 控制定时器是否激活
  double duration = 1.5;
  double timerDuration = 3.14;
  int interval = 3;
  Timer? periodicTimer;
  Timer? fiveMinutesTimer;
  bool isDurationValid = true;
  bool realTimeState = false;
  bool isLoading = false;
  bool isTorrentsLoading = false;
  late WebSocketChannel channel;
  late WebSocketChannel torrentsChannel;
  String baseUrl = SPUtil.getLocalStorage('server');
  List torrents = [];
  List showTorrents = [];

  DownloadController(this.realTimeState);

  List<MetaDataItem> qBitStatus = [
    {"name": "全部", "value": null},
    {"name": "下载中", "value": 'downloading'},
    {"name": "下载暂停", "value": 'pausedDL'},
    {"name": "上传中", "value": 'uploading'},
    {"name": "做种中", "value": 'stalledUP'},
    {"name": "等待下载", "value": 'stalledDL'},
    {"name": "移动中", "value": 'moving'},
    {"name": "上传暂停", "value": 'pausedUP'},
    {"name": "队列下载中", "value": 'queuedDL'},
    {"name": "队列上传中", "value": 'queuedUP'},
    // {"name": "分配中", "value": 'allocating'},
    {"name": "检查下载", "value": 'checkingDL'},
    // {"name": "检查恢复数据", "value": 'checkingResumeData'},
    {"name": "检查上传", "value": 'checkingUP'},
    {"name": "强制下载", "value": 'forcedDL'},
    // {"name": "强制元数据下载", "value": 'forcedMetaDL'},
    {"name": "强制上传", "value": 'forcedUP'},
    // {"name": "元数据下载中", "value": 'metaDL'},
    {"name": "缺失文件", "value": 'missingFiles'},

    // {"name": "未知状态", "value": unknown},
    {"name": "错误", "value": 'error'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  List<MetaDataItem> qbSortOptions = [
    {"name": "无", "value": null},
    {'name': '名称', 'value': 'name'},
    {'name': '类别', 'value': 'category'},
    {'name': '大小', 'value': 'size'},
    {'name': '添加时间', 'value': 'addedOn'},
    // {'name': '总大小', 'value': 'totalSize'},
    {'name': '完成时间', 'value': 'completionOn'},
    {'name': '状态', 'value': 'state'},
    {'name': 'Tracker', 'value': 'tracker'},
    {'name': '进度', 'value': 'progress'},
    {'name': '保存路径', 'value': 'savePath'},
    {'name': '已上传', 'value': 'uploaded'},
    {'name': '已下载', 'value': 'downloaded'},
    {'name': '下载速度', 'value': 'dlSpeed'},
    {'name': '上传速度', 'value': 'upSpeed'},
    {'name': '最后活动时间', 'value': 'lastActivity'},
    {'name': '活跃时间', 'value': 'timeActive'},
    {'name': '完成数', 'value': 'completed'},
    {'name': 'Leechs 数量', 'value': 'numLeechs'},
    {'name': 'Seeds 数量', 'value': 'numSeeds'},
    {'name': '未完成数', 'value': 'numIncomplete'},
    {'name': '已完成数', 'value': 'numComplete'},
    {'name': '优先级', 'value': 'priority'},
    {'name': '已查看完成', 'value': 'seenComplete'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();

  List<MetaDataItem> qbTrackerStatus = [
    {'name': '禁用', 'value': 'disabled'},
    {'name': '未联系', 'value': 'notContacted'},
    {'name': '未工作', 'value': 'notWorking'},
    {'name': '错误', 'value': 'trackerError'},
    {'name': '不可达', 'value': 'unreachable'},
    {'name': '更新中', 'value': 'updating'},
    {'name': '工作中', 'value': 'working'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  Map<String, WebSite> trackerToWebSiteMap = {};
  Map<String, Category?> categoryMap = {};
  Map<String, List<String>> trackers = {};
  List<String> tags = ['全部'];
  List<String> errors = ['全部'];
  List<dynamic> serverStatus = [];
  String selectedTag = '全部';
  int torrentFilter = 0;
  String selectedError = '全部';
  dynamic torrentState = '全部';
  String? selectedCategory = '全部';
  String selectedTracker = '全部';
  String sortKey = 'name';
  String searchKey = '';
  TextEditingController searchController = TextEditingController();

  List<MetaDataItem> trSortOptions = [
    {'name': '名称', 'value': 'name'},
    {'name': 'ID', 'value': 'id'},
    {'name': '状态', 'value': 'status'},
    {'name': '总大小', 'value': 'totalSize'},
    {'name': '队列位置', 'value': 'queuePosition'},
    {'name': '完成日期', 'value': 'doneDate'},
    {'name': '完成百分比', 'value': 'percentDone'},
    {'name': '已上传', 'value': 'uploadedEver'},
    {'name': '已下载', 'value': 'downloaded'},
    {'name': '下载速度', 'value': 'rateDownload'},
    {'name': '上传速度', 'value': 'rateUpload'},
    {'name': '校验进度', 'value': 'recheckProgress'},
    {'name': '活动日期', 'value': 'activityDate'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  List<MetaDataItem> trStatus = [
    {"name": "全部", "value": null},
    {"name": "红种", "value": 99},
    {"name": "下载中", "value": 4},
    // {"name": "活动中", "value": 100},
    {"name": "做种中", "value": 6},
    {"name": "已停止", "value": 0},
    {"name": "校验中", "value": 2},
    {"name": "校验队列", "value": 1},
    {"name": "排队下载", "value": 3},
    {"name": "排队上传", "value": 5},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  int? trTorrentState;
  bool sortReversed = false;
  dynamic currentPrefs = false;

  // 使用StreamController来管理下载状态的流
  final StreamController<List<Downloader>> _downloadStreamController =
      StreamController<List<Downloader>>.broadcast();

  // 提供获取下载状态流的方法
  Stream<List<Downloader>> get downloadStream =>
      _downloadStreamController.stream;

  Map<int, dynamic> speedInfo = {};

  bool toggleSpeedLimitLoading = false;

  @override
  void onInit() async {
    realTimeState = SPUtil.getBool('realTimeState', defaultValue: true)!;
    isTimerActive = realTimeState;
    duration = SPUtil.getDouble('duration', defaultValue: 3.14)!;
    timerDuration = SPUtil.getDouble('timerDuration', defaultValue: 3.14)!;
    downloadStream.listen((downloaders) {
      for (var downloader in downloaders) {
        // 查找 dataList 中 id 相同的元素
        int index =
            dataList.indexWhere((element) => element.id == downloader.id);

        if (index != -1) {
          // 如果找到了，替换为新的 downloader
          dataList[index] = downloader;
        } else {
          // 如果没有找到，可以选择添加到 dataList 中
          dataList.add(downloader);
        }
      }
      dataMap = {
        for (var item in dataList)
          "${item.name}-${item.id}-${item.category}": item
      };
      update();
    });
    await getDownloaderListFromServer();

    trackerToWebSiteMap = mySiteController.buildTrackerToWebSite();

    if (realTimeState) {
      logger_helper.Logger.instance.d('调用刷新 init');
      await getDownloaderStatus();

      // refreshDownloadStatus();
      // 设置定时器，每隔一定时间刷新下载器数据
      // startPeriodicTimer();
      // 设置一个5分钟后执行的定时器
      // timerToStop();
    }
    super.onInit();
  }

  void timerToStop() {
    fiveMinutesTimer =
        Timer(Duration(seconds: (timerDuration * 60).toInt()), () {
      // 定时器触发后执行的操作，这里可以取消periodicTimer、关闭资源等
      cancelPeriodicTimer();
      // 你可以在这里添加其他需要在定时器触发后执行的逻辑
    });
  }

  toggleRealTimeState() {
    realTimeState = !realTimeState;
    isTimerActive = !realTimeState;
    isTimerActive ? cancelPeriodicTimer() : startPeriodicTimer();
    update();
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(
        Duration(milliseconds: (duration * 1000).toInt()), (Timer t) {
      // 在定时器触发时获取最新的下载器数据
      logger_helper.Logger.instance.d('调用刷新 timer');

      refreshDownloadStatus();
    });
    isTimerActive = true;
    update();
  }

  // 取消定时器
  void cancelPeriodicTimer() {
    if (periodicTimer != null && periodicTimer?.isActive == true) {
      periodicTimer?.cancel();
    }
    isTimerActive = false;
    update();
  }

  Future<void> fetchStatusForItem(Downloader item) async {
    try {
      dynamic status = await getIntervalSpeed(item);
      if (status.code == 0) {
        item.status.add(status.data);
      }

      if (item.status.length > 30) {
        item.status.removeAt(0);
      }
      _downloadStreamController.sink.add([item]);
      update();
    } catch (e, trace) {
      logger_helper.Logger.instance.e('Error fetching download status: $e');
      logger_helper.Logger.instance.e('Error fetching download status: $trace');
    }
  }

  Future<void> refreshDownloadStatus() async {
    logger_helper.Logger.instance.i('开始刷新下载器状态');
    List<Future<void>> futures = [];
    for (Downloader item in dataList) {
      if (item.isActive) {
        Future<void> fetchStatus = fetchStatusForItem(item);
        futures.add(fetchStatus);
      }
    }

    await Future.wait(futures);
  }

  getDownloaderListFromServer() async {
    isLoaded = false;
    update();
    CommonResponse response = await getDownloaderListApi();
    if (response.succeed) {
      dataList.clear();
      dataList = response.data;
      isLoaded = true;
      _downloadStreamController.sink.add(dataList.toList());
    } else {
      Get.snackbar('出错啦', response.msg);
    }
    update();
  }

  Future<CommonResponse> removeDownloader(Downloader downloader) async {
    CommonResponse res = await removeDownloaderApi(downloader);
    await getDownloaderListFromServer();
    update();
    return res;
  }

  Future<QBittorrentApiV2> getQbInstance(Downloader downloader) async {
    final qbittorrent = QBittorrentApiV2(
      baseUrl: '${downloader.protocol}://${downloader.host}:${downloader.port}',
      cookiePath:
          '${(await getApplicationDocumentsDirectory()).path}/${downloader.host}/${downloader.port}',
      logger: false,
    );
    await qbittorrent.auth.login(
      username: downloader.username,
      password: downloader.password,
    );
    return qbittorrent;
  }

  Future<tr.Transmission> getTrInstance(Downloader downloader) async {
    final transmission = tr.Transmission(
        '${downloader.protocol}://${downloader.host}:${downloader.port}',
        tr.AuthKeys(downloader.username, downloader.password),
        logConfig: const tr.ConfigLogger.showNone());
    return transmission;
  }

  Future getTrSpeed(Downloader downloader) async {
    final client = await getTrInstance(downloader);
    var res = await client.v1.session.sessionStats();
    var res1 = await client.v1.session.sessionGet(
        fields: tr.SessionArgs()
            .speedLimitDown()
            .speedLimitDownEnabled()
            .speedLimitUp()
            .speedLimitUpEnabled());

    TransmissionStats stats = TransmissionStats.fromJson(res["arguments"]);
    downloader.prefs = TransmissionConfig.fromJson(res1["arguments"]);
    if (res['result'] == "success") {
      return CommonResponse.success(data: stats);
    }
    return CommonResponse.error(
      data: res,
      msg: '${downloader.name} 获取实时信息失败！',
    );
  }

  dynamic getIntervalSpeed(Downloader downloader) async {
    return downloader.category == 'Qb'
        ? await getQbSpeed(downloader)
        : await getTrSpeed(downloader);
  }

  getDownloaderStatus() async {
    // 打开加载状态
    isLoading = true;
    update();
    try {
      final wsUrl = Uri.parse(
          '${baseUrl.replaceFirst('http', 'ws')}/api/${Api.DOWNLOADER_STATUS}');
      channel = WebSocketChannel.connect(wsUrl);

      await channel.ready;
      channel.sink.add(json.encode({
        "interval": duration,
      }));
      List<Future<void>> futures = [];
      channel.stream.listen((message) async {
        CommonResponse response =
            CommonResponse.fromJson(json.decode(message), (p0) => p0);
        if (response.code == 0) {
          logger_helper.Logger.instance.d(response.data);
          Future<void> fetchStatus = fetchItemStatus(response.data);
          futures.add(fetchStatus);
          await Future.wait(futures);
          update();
        } else {
          logger_helper.Logger.instance.i(response.msg);
          // searchMsg.add({"success": false, "msg": response.msg});
          update();
        }
      }, onError: (err) {
        logger_helper.Logger.instance.e('获取下载器状态出错啦： ${err.toString()}');
        // searchMsg.add({"success": false, "msg": '搜索出错啦：$err'});
        stopFetchStatus();
      }, onDone: () {
        logger_helper.Logger.instance.e('获取下载器状态结束啦！');
        stopFetchStatus();
      });
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.d(trace);
      // searchMsg.add({"success": false, "msg": '搜索出错啦：$e'});
      stopFetchStatus();
    }
  }

  getQbMainData(Downloader downloader) async {
    CommonResponse response = await getMainData(downloader.id!);
    if (!response.succeed) {
      return response;
    }

    categoryMap.addAll({
      for (var entry in response.data['categories'].entries)
        entry.key: Category.fromJson(entry.value as Map<String, dynamic>)
    });

    trackers.addAll(mergeTrackers(
        Map<String, List<dynamic>>.from(response.data['trackers'])));

    update();
  }

  Map<String, List<String>> mergeTrackers(Map<String, List<dynamic>> trackers) {
    return trackers.entries.fold({}, (merged, entry) {
          var host = Uri.parse(entry.key).host;
          var tracker = trackerToWebSiteMap.keys.firstWhere(
              (element) => element.contains(host),
              orElse: () => host);
          host = trackerToWebSiteMap[tracker]?.name ?? tracker;
          merged?.putIfAbsent(host, () => []);
          merged?[host]!.addAll(List<String>.from(entry.value));
          return merged;
        }) ??
        {};
  }

  getDownloaderTorrentDetailInfo(
      Downloader downloader, String torrentHash) async {
    return await getTorrentDetailInfo(downloader.id!, torrentHash);
  }

  getDownloaderCategoryList(Downloader downloader) async {
    CommonResponse response = await getDownloaderCategories(downloader.id!);
    if (!response.succeed) {
      return response;
    }
    categoryMap.addAll({
      for (var item in response.data)
        (item)['name']!: Category.fromJson(item as Map<String, dynamic>)
    });
  }

  filterTrTorrents() {
    isTorrentsLoading = false;
    showTorrents = torrents;
    update();
    logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByCategory();
    // logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByState();
    // logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByError();
    // logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByLabel();
    // logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsBySearchKey();
    // logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByTracker();
    sortTrTorrents();
    update();
    logger_helper.Logger.instance.i(showTorrents.length);
  }

  sortTrTorrents() {
    switch (sortKey) {
      case 'name':
        showTorrents.sort((a, b) => a.name.compareTo(b.name));
      case 'id':
        showTorrents.sort((a, b) => a.id.compareTo(b.id));
      case 'status':
        showTorrents.sort((a, b) => a.status.compareTo(b.status));
      // case 'addedOn':
      //   torrents
      //       .sort(( a, b) => a.addedOn.compareTo(b.addedOn));
      case 'totalSize':
        showTorrents.sort((a, b) => a.totalSize.compareTo(b.totalSize));
      case 'queuePosition':
        showTorrents.sort((a, b) =>
            a.queuePosition.toString().compareTo(b.queuePosition.toString()));
      case 'doneDate':
        showTorrents.sort((a, b) => a.doneDate.compareTo(b.doneDate));
      case 'percentDone':
        showTorrents.sort((a, b) => a.percentDone.compareTo(b.percentDone));
      case 'uploadedEver':
        showTorrents.sort((a, b) => a.uploadedEver.compareTo(b.uploadedEver));
      case 'downloaded':
        showTorrents
            .sort((a, b) => a.downloadedEver.compareTo(b.downloadedEver));
      case 'rateDownload':
        showTorrents.sort((a, b) => a.rateDownload.compareTo(b.rateDownload));
      case 'rateUpload':
        showTorrents.sort((a, b) => a.rateUpload.compareTo(b.rateUpload));
      case 'recheckProgress':
        showTorrents
            .sort((a, b) => a.recheckProgress.compareTo(b.recheckProgress));
      case 'activityDate':
        showTorrents.sort((a, b) => a.activityDate.compareTo(b.activityDate));
      default:
        Get.snackbar('出错啦！', '未知排序规则：$sortKey');
    }

    if (sortReversed) {
      logger_helper.Logger.instance.d('反转序列！');
      showTorrents = showTorrents.reversed.toList();
    }
    update();
  }

  void filterTorrentsByCategory() {
    logger_helper.Logger.instance.i(selectedCategory);
    if (selectedCategory != null && selectedCategory != '全部') {
      showTorrents = showTorrents.where((torrent) {
        return torrent.downloadDir.contains(selectedCategory);
      }).toList();
    }
  }

  void filterTorrentsByError() {
    logger_helper.Logger.instance.i(selectedCategory);
    if (selectedError.isNotEmpty && selectedError != '全部') {
      showTorrents = showTorrents.where((torrent) {
        return torrent.errorString.contains(selectedError);
      }).toList();
    }
  }

  void filterTorrentsByLabel() {
    logger_helper.Logger.instance.i(selectedTag);
    if (selectedTag.isNotEmpty && selectedTag != '全部') {
      showTorrents = showTorrents.where((torrent) {
        return torrent.errorString.contains(selectedTag);
      }).toList();
    }
  }

  filterTorrentsByState() {
    if (trTorrentState == null) {
      return;
    }
    switch (trTorrentState) {
      case 99:
        showTorrents =
            showTorrents.where((torrent) => torrent.error > 0).toList();
        break;
      case 100:
        showTorrents = showTorrents
            .where(
                (torrent) => torrent.rateUpload > 0 || torrent.rateDownload > 0)
            .toList();
        break;
      default:
        showTorrents = showTorrents
            .where((torrent) => torrent.status == trTorrentState)
            .toList();
        break;
    }
  }

  filterTorrentsBySearchKey() {
    // logger_helper.Logger.instance.d('搜索关键字：${searchKey.value}');

    if (searchKey.isNotEmpty) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.name.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.errorString
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()) ||
              torrent.hashString
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()))
          .toList();
    }
  }

  filterTorrentsByTracker() {
    logger_helper.Logger.instance.i(selectedTracker);

    if (selectedTracker.isNotEmpty && selectedTracker != '全部') {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.trackerStats.isNotEmpty &&
              torrent.trackerStats.first?.announce
                      .toLowerCase()
                      .contains(selectedTracker.toString().toLowerCase()) ==
                  true)
          .toList();
    }
    // logger_helper.Logger.instance.i(showTorrents.length);
  }

  filterTorrents(bool isQb) {
    searchKey = searchController.text;
    isTorrentsLoading = false;
    isQb ? filterQbTorrents() : filterTrTorrents();
    update();
  }

  filterQbTorrents() {
    showTorrents = torrents;

    if (searchKey.isNotEmpty) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.name!.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.category
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()) ||
              torrent.infohashV1
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()))
          .toList();
    }
    // logger_helper.Logger.instance.d(showTorrents.length);

    if (torrentState != null && torrentState != '全部') {
      showTorrents = showTorrents
          .where((torrent) => torrent.state == torrentState)
          .toList();
    }
    // logger_helper.Logger.instance.d(showTorrents.length);

    if (selectedCategory != null && selectedCategory != '全部') {
      showTorrents = showTorrents
          .where((torrent) => torrent.category == selectedCategory)
          .toList();
    }
    // logger_helper.Logger.instance.d(showTorrents.length);

    if (selectedTracker == '红种') {
      showTorrents =
          showTorrents.where((torrent) => torrent.tracker!.isEmpty).toList();
    } else if (selectedTracker != '全部') {
      showTorrents = showTorrents
          .where((torrent) =>
              trackers[selectedTracker] != null &&
              trackers[selectedTracker]!.contains(torrent.infohashV1))
          .toList();
    }

    logger_helper.Logger.instance.d(showTorrents.length);

    sortQbTorrents();
    update();
  }

  sortQbTorrents() {
    switch (sortKey) {
      case 'addedOn':
        showTorrents.sort((a, b) => a.addedOn.compareTo(b.addedOn));
      case 'amountLeft':
        showTorrents.sort((a, b) => a.amountLeft.compareTo(b.amountLeft));
      case 'name':
        showTorrents.sort((a, b) => a.name.compareTo(b.name));
      case 'contentPath':
        showTorrents.sort((a, b) => a.contentPath.compareTo(b.contentPath));
      case 'category':
        torrents.sort((a, b) => a.category.compareTo(b.category));
      case 'seenComplete':
        torrents.sort((a, b) => a.seenComplete.compareTo(b.seenComplete));
      case 'size':
        showTorrents.sort((a, b) => a.size.compareTo(b.size));
      case 'numComplete':
        showTorrents.sort((a, b) =>
            a.numComplete.toString().compareTo(b.numComplete.toString()));
      case 'state':
        showTorrents
            .sort((a, b) => a.state.toString().compareTo(b.state.toString()));
      case 'lastActivity':
        showTorrents.sort((a, b) => a.lastActivity.compareTo(b.lastActivity));
      case 'progress':
        showTorrents.sort((a, b) => a.progress.compareTo(b.progress));
      case 'ratio':
        showTorrents.sort((a, b) => a.ratio.compareTo(b.ratio));
      case 'seedingTime':
        showTorrents.sort((a, b) => a.seedingTime.compareTo(b.seedingTime));
      case 'downloaded':
        showTorrents
            .sort((a, b) => a.downloadedEver.compareTo(b.downloadedEver));
      case 'upSpeed':
        showTorrents.sort((a, b) => a.rateDownload.compareTo(b.rateDownload));
      case 'rateUpload':
        showTorrents.sort((a, b) => a.rateUpload.compareTo(b.rateUpload));
      case 'dlSpeed':
        showTorrents
            .sort((a, b) => a.recheckProgress.compareTo(b.recheckProgress));
      case 'numComplete':
        showTorrents.sort((a, b) => a.numComplete.compareTo(b.activityDate));
      default:
        Get.snackbar('出错啦！', '未知排序规则：$sortKey');
    }
    if (sortReversed) {
      logger_helper.Logger.instance.d('反转序列！');
      showTorrents = showTorrents.reversed.toList();
    }

    update();
  }

  Future<CommonResponse> controlTorrents({
    required Downloader downloader,
    required String command,
    required List<String> hashes,
    String category = '',
    bool deleteFiles = false,
    bool enable = true,
    int limit = 0,
    RatioLimit ratioLimit = const RatioLimit.none(),
    RatioLimit seedingTimeLimit = const RatioLimit.none(),
    RatioLimit inactiveSeedingTimeLimit = const RatioLimit.none(),
  }) async {
    logger_helper.Logger.instance.d(command);
    logger_helper.Logger.instance.d(hashes);
    CommonResponse response =
        await controlTorrent(downloaderId: downloader.id!, command: {
      'command': command,
      'hashes': hashes.join('|'),
      'category': category,
      'delete_files': deleteFiles,
      'enable': enable,
      'limit': limit,
      'ratioLimit': ratioLimit.ratio,
      'seedingTimeLimit': seedingTimeLimit.ratio,
      'inactiveSeedingTimeLimit': inactiveSeedingTimeLimit.ratio,
    });
    // Get.snackbar(response.succeed ? '成功啦！' : '出错啦！', response.msg);
    update();
    return response;
  }

  getDownloaderTorrents(Downloader downloader) async {
    // 打开加载状态
    try {
      bool isQb = downloader.category == 'Qb';
      isTorrentsLoading = true;
      serverStatus.clear();
      update();
      final wsUrl = Uri.parse(
          '${baseUrl.replaceFirst('http', 'ws')}/api/${Api.DOWNLOADER_TORRENTS}');
      torrentsChannel = WebSocketChannel.connect(wsUrl);
      await torrentsChannel.ready;
      // 使用缓存
      String key = 'Downloader-$baseUrl:${downloader.name}-${downloader.id}';
      dynamic data = await SPUtil.getCache(key);

      if (data[key] != null && data[key].isNotEmpty) {
        data = data[key];
        if (isQb) {
          parseQbMainData(data);
        } else {
          parseTrData(data);
        }
        update();
      }

      int rid = 0;
      torrentsChannel.sink.add(json.encode({
        "downloader_id": downloader.id,
        "interval": duration,
        "rid": rid,
      }));

      torrentsChannel.stream.listen((message) async {
        logger_helper.Logger.instance.d('开始刷新种子列表！Rid：$rid');
        CommonResponse response =
            CommonResponse.fromJson(json.decode(message), (p0) => p0);
        if (response.code == 0) {
          // logger_helper.Logger.instance.d(response.data[0]);
          await SPUtil.setCache(key, {key: response.data}, 3600 * 24 * 3);
          if (isQb) {
            parseQbMainData(response.data);
            // rid += 1;
          } else {
            parseTrData(response.data);
          }
          update();
        } else {
          logger_helper.Logger.instance.i(response.msg);
          // searchMsg.add({"success": false, "msg": response.msg});
          update();
        }
      }, onError: (err) async {
        logger_helper.Logger.instance.e('刷新种子列表出错啦： ${err.toString()}');
        // searchMsg.add({"success": false, "msg": '搜索出错啦：$err'});
        await stopFetchTorrents();
      }, onDone: () async {
        logger_helper.Logger.instance.e('本次种子传输结束啦！');
      });
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.d(trace);
      // searchMsg.add({"success": false, "msg": '搜索出错啦：$e'});
      await stopFetchTorrents();
    }
  }

  parseTrData(data) {
    if (data.runtimeType == List ||
        data['torrents'] == null ||
        data['status'].isEmpty) return;
    torrents =
        data['torrents'].map((item) => TrTorrent.fromJson(item)).toList();
    tags.addAll(
        torrents.expand<String>((item) => item.labels).toSet().toList());

    errors.addAll(torrents
        .map<String>((item) => item.errorString)
        .toSet()
        .where((el) => el.isNotEmpty)
        .toList());
    categoryMap = {
      '全部': const Category(name: '全部', savePath: null),
      for (var dir in torrents
          .map((e) => e.downloadDir.replaceAll(RegExp(r'\/$'), '').toString())
          .toSet())
        dir.split('/').last: Category(
          name: dir.split('/').last,
          savePath: dir,
        ),
    };
    trackers = {'全部': []};
    // 遍历 torrents，构建 trackerHashes 数据
    for (var torrent in torrents) {
      if (torrent.trackerStats.isEmpty) continue;

      final String host = Uri.parse(torrent.trackerStats.first.announce).host;

      // 如果 tracker 映射到的网站存在，则更新 trackerHashes
      if (trackerToWebSiteMap.containsKey(host)) {
        final website = trackerToWebSiteMap[host]!;
        trackers.putIfAbsent(website.name, () => []).add(torrent.hashString);
      }
    }

    // serverStatus.clear();
    TransmissionStats state = TransmissionStats.fromJson(data['status']);
    serverStatus.add(state);

    filterTrTorrents();

    update();
  }

  void parseQbMainData(data) {
    categoryMap = {
      '全部': const Category(name: '全部'),
      '未分类': const Category(name: '未分类', savePath: ''),
      if (data['categories'] != null) ...{
        for (var entry in data['categories'].entries)
          entry.key: Category.fromJson(entry.value as Map<String, dynamic>)
      }
    };

    trackers = {
      '全部': [],
      if (data['trackers'] != null)
        ...mergeTrackers(Map<String, List<dynamic>>.from(data['trackers']))
    };
    // logger_helper.Logger.instance.d(trackers);
    tags = [
      "全部",
      if (data['tags'] != null) ...List<String>.from(data['tags'] ?? [])
    ];
    torrents = data['torrents'].entries.map((entry) {
      var torrent = Map<String, dynamic>.from(entry.value); // 复制原始数据
      torrent['hash'] = entry.key; // 添加 hash 属性
      return QbittorrentTorrentInfo.fromJson(torrent);
    }).toList();
    isTorrentsLoading = false;
    ServerState state = ServerState.fromJson(data['server_state']);
    serverStatus.add(state);
    filterQbTorrents();
    update();
  }

  Future<void> fetchItemStatus(Map<String, dynamic> status) async {
    try {
      if (dataMap.isEmpty) {
        dataMap = {
          for (var item in dataList)
            "${item.name}-${item.id}-${item.category}": item
        };
      }
      String key = status.keys.first;
      Downloader? item = dataMap[key];
      logger_helper.Logger.instance.i(key);
      logger_helper.Logger.instance.i(item);
      if (item != null) {
        if (item.category == 'Qb') {
          item.status.add(ServerState.fromJson(status[key]["info"]));
          item.prefs = QbittorrentPreferences.fromJson(status[key]['prefs']);
        } else {
          TransmissionStats stats =
              TransmissionStats.fromJson(status[key]["info"]);
          item.prefs = TransmissionConfig.fromJson(status[key]['prefs']);
          item.status.add(stats);
        }
        logger_helper.Logger.instance
            .i('下载器${item.name}状态：${item.status.length}');

        if (item.status.length > 30) {
          item.status.removeAt(0);
        }
        _downloadStreamController.sink.add([item]);
      } else {
        logger_helper.Logger.instance.i(dataMap);
      }
      update();
    } catch (e, trace) {
      logger_helper.Logger.instance.e('Error fetching download status: $e');
      logger_helper.Logger.instance.e('Error fetching download status: $trace');
      logger_helper.Logger.instance
          .e('Error fetching download status: $status');
    }
  }

  clearFilterOption() {
    serverStatus.clear();
    trackers.clear();
    searchController.text = '';
    searchKey = '';
    selectedTag = '全部';
    selectedError = '全部';
    selectedCategory = '全部';
    selectedTracker = '全部';
    torrentState = null;
  }

  stopFetchTorrents() async {
    await torrentsChannel.sink.close(status.normalClosure);
    await torrentsChannel.sink.done;
    torrents.clear();
    clearFilterOption();
    update();
  }

  toggleFetchStatus() async {
    isLoading ? await stopFetchStatus() : await getDownloaderStatus();
  }

  stopFetchStatus() async {
    isLoading = false;
    await channel.sink.close(status.normalClosure);
    update();
  }

  Future getQbSpeed(Downloader downloader) async {
    try {
      final client = await getQbInstance(downloader);
      TransferInfo res = await client.transfer.getGlobalTransferInfo();
      return CommonResponse.success(data: res);
    } catch (e, trace) {
      logger_helper.Logger.instance.e(trace);
      return CommonResponse.error(msg: '${downloader.name} 获取实时信息失败！');
    }
  }

  Future<CommonResponse> testConnect(Downloader downloader) async {
    try {
      // logger_helper.Logger.instance.i(downloader.name);
      if (downloader.category.toLowerCase() == 'qb') {
        await getQbInstance(downloader);
        return CommonResponse.success(msg: '${downloader.name} 连接成功!');
      } else {
        await getTrInstance(downloader);
        return CommonResponse.success(msg: '${downloader.name} 连接成功!');
      }
    } catch (error) {
      return CommonResponse.error(msg: '${downloader.name} 连接失败!');
    }
  }

  @override
  void onClose() {
    // 关闭StreamController以避免内存泄漏
    _downloadStreamController.close();
    cancelPeriodicTimer();
    Get.delete<DownloadController>();
    super.onClose();
  }

  void validateInput(String input, {double min = 3, double max = 10}) {
    try {
      double parsedValue = double.parse(input);
      isDurationValid = parsedValue >= 3 && parsedValue <= 10;
    } catch (e) {
      isDurationValid = false;
    }
    update();
  }

  saveDownloaderToServer(Downloader downloader) async {
    CommonResponse response;
    if (downloader.id != 0) {
      response = await editDownloaderApi(downloader);
    } else {
      response = await saveDownloaderApi(downloader);
    }
    return response;
  }

  getTorrentsPathList() async {
    return await getDownloaderPaths();
  }

  reseedDownloader(int downloaderId) async {
    return await repeatSingleDownloader(downloaderId);
  }

  toggleSpeedLimit(Downloader downloader, bool state) async {
    toggleSpeedLimitLoading = true;
    update();
    CommonResponse response = await toggleSpeedLimitApi(downloader.id!, state);
    toggleSpeedLimitLoading = false;
    if (response.succeed) {
      // await stopFetchStatus();
      // await getDownloaderStatus();
      Get.snackbar('提示', response.msg);
      getDownloaderListFromServer();
      update();
      return;
    }
    Get.snackbar('出错啦！', response.msg, colorText: Colors.red);
  }

  getPrefs(Downloader downloader) async {
    CommonResponse response = await getPrefsApi(downloader.id!);
    return response;
  }

  setPrefs(Downloader downloader, dynamic prefs) async {
    CommonResponse response = await setPrefsApi(downloader.id!, prefs.toJson());
    return response;
  }

  // todo 批量更换 tracker
  replaceTrackers({required String site, required String newTracker}) async {
    CommonResponse response =
        CommonResponse(code: 0, msg: 'msg', succeed: true);
    return response;
  }

  // todo 移除红种
  removeErrorTracker() async {
    CommonResponse response =
        CommonResponse(code: 0, msg: 'msg', succeed: true);
    return response;
  }
}
