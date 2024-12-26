import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart'; // ignore: depend_on_referenced_packages
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
  double duration = 3.14;
  double timerDuration = 3.14;
  int interval = 3;
  Timer? periodicTimer;
  Timer? fiveMinutesTimer;
  bool isDurationValid = true;
  bool realTimeState = true;
  bool isLoading = false;
  late WebSocketChannel channel;
  late WebSocketChannel torrentsChannel;
  String baseUrl = SPUtil.getLocalStorage('server');
  List torrents = [];
  List showTorrents = [];

  DownloadController(this.realTimeState);

  List<MetaDataItem> qBitStatus = [
    {"name": "全部", "value": null},
    {"name": "下载中", "value": TorrentState.downloading},
    {"name": "下载暂停", "value": TorrentState.pausedDL},
    {"name": "上传中", "value": TorrentState.uploading},
    {"name": "做种中", "value": TorrentState.stalledUP},
    {"name": "等待下载", "value": TorrentState.stalledDL},
    {"name": "移动中", "value": TorrentState.moving},
    {"name": "上传暂停", "value": TorrentState.pausedUP},
    {"name": "队列下载中", "value": TorrentState.queuedDL},
    {"name": "队列上传中", "value": TorrentState.queuedUP},
    // {"name": "分配中", "value": TorrentState.allocating},
    {"name": "检查下载", "value": TorrentState.checkingDL},
    // {"name": "检查恢复数据", "value": TorrentState.checkingResumeData},
    {"name": "检查上传", "value": TorrentState.checkingUP},
    {"name": "强制下载", "value": TorrentState.forcedDL},
    // {"name": "强制元数据下载", "value": TorrentState.forcedMetaDL},
    {"name": "强制上传", "value": TorrentState.forcedUP},
    // {"name": "元数据下载中", "value": TorrentState.metaDL},
    {"name": "缺失文件", "value": TorrentState.missingFiles},

    // {"name": "未知状态", "value": TorrentState.unknown},
    {"name": "错误", "value": TorrentState.error},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  List<MetaDataItem> qbSortOptions = [
    {"name": "无", "value": null},
    {'name': '名称', 'value': TorrentSort.name},
    {'name': '类别', 'value': TorrentSort.category},
    {'name': '大小', 'value': TorrentSort.size},
    {'name': '添加时间', 'value': TorrentSort.addedOn},
    // {'name': '总大小', 'value': TorrentSort.totalSize},
    {'name': '完成时间', 'value': TorrentSort.completionOn},
    {'name': '状态', 'value': TorrentSort.state},
    {'name': 'Tracker', 'value': TorrentSort.tracker},
    {'name': '进度', 'value': TorrentSort.progress},
    {'name': '保存路径', 'value': TorrentSort.savePath},
    {'name': '已上传', 'value': TorrentSort.uploaded},
    {'name': '已下载', 'value': TorrentSort.downloaded},
    {'name': '下载速度', 'value': TorrentSort.dlSpeed},
    {'name': '上传速度', 'value': TorrentSort.upSpeed},
    {'name': '最后活动时间', 'value': TorrentSort.lastActivity},
    {'name': '活跃时间', 'value': TorrentSort.timeActive},
    {'name': '完成数', 'value': TorrentSort.completed},
    {'name': 'Leechs 数量', 'value': TorrentSort.numLeechs},
    {'name': 'Seeds 数量', 'value': TorrentSort.numSeeds},
    {'name': '未完成数', 'value': TorrentSort.numIncomplete},
    {'name': '已完成数', 'value': TorrentSort.numComplete},
    {'name': '优先级', 'value': TorrentSort.priority},
    {'name': '已查看完成', 'value': TorrentSort.seenComplete},
  ].map((e) => MetaDataItem.fromJson(e)).toList();

  List<MetaDataItem> qbTrackerStatus = [
    {'name': '禁用', 'value': TrackerStatus.disabled},
    {'name': '未联系', 'value': TrackerStatus.notContacted},
    {'name': '未工作', 'value': TrackerStatus.notWorking},
    {'name': '错误', 'value': TrackerStatus.trackerError},
    {'name': '不可达', 'value': TrackerStatus.unreachable},
    {'name': '更新中', 'value': TrackerStatus.updating},
    {'name': '工作中', 'value': TrackerStatus.working},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  Map<String, WebSite> trackerToWebSiteMap = {};
  Map<String, Category?> qBCategoryMap = {};
  Map<String, List<String>> trackers = {};
  List<String> tags = [];

  TorrentState? torrentState;
  TorrentFilter torrentFilter = TorrentFilter.all;
  String? category;
  String selectedTracker = ' All';
  TorrentSort? sortKey = TorrentSort.name;
  String searchKey = '';

  // 使用StreamController来管理下载状态的流
  final StreamController<List<Downloader>> _downloadStreamController =
      StreamController<List<Downloader>>.broadcast();

  // 提供获取下载状态流的方法
  Stream<List<Downloader>> get downloadStream =>
      _downloadStreamController.stream;

  Map<int, dynamic> speedInfo = {};

  @override
  void onInit() async {
    realTimeState = SPUtil.getBool('realTimeState', defaultValue: true)!;
    isTimerActive = realTimeState;
    duration = SPUtil.getDouble('duration', defaultValue: 3.14)!;
    timerDuration = SPUtil.getDouble('timerDuration', defaultValue: 3.14)!;
    await getDownloaderListFromServer();
    await getDownloaderStatus();
    dataMap = {
      for (var item in dataList)
        "${item.name}-${item.id}-${item.category}": item
    };
    trackerToWebSiteMap = mySiteController.buildTrackerToWebSite();

    if (realTimeState) {
      logger_helper.Logger.instance.d('调用刷新 init');
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
    } catch (e) {
      logger_helper.Logger.instance.e('Error fetching download status: $e');
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

  getDownloaderListFromServer() {
    getDownloaderListApi().then((value) {
      if (value.code == 0) {
        dataList = value.data;
        isLoaded = true;
        _downloadStreamController.add(dataList.toList());
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('', e.toString());
    });
    // 发送最新的下载列表到流中
    if (realTimeState) {
      logger_helper.Logger.instance.d('调用刷新 list');

      refreshDownloadStatus();
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
    stats.speedLimitSettings = SpeedLimitSettings.fromJson(res1["arguments"]);
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
          logger_helper.Logger.instance.d(response.data[0]);
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
        logger_helper.Logger.instance.e('搜索出错啦： ${err.toString()}');
        // searchMsg.add({"success": false, "msg": '搜索出错啦：$err'});
        stopFetchStatus();
      }, onDone: () {
        logger_helper.Logger.instance.e('搜索完成啦！');
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

    qBCategoryMap.addAll({
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
    qBCategoryMap.addAll({
      for (var item in response.data)
        (item)['name']!: Category.fromJson(item as Map<String, dynamic>)
    });
  }

  filterTorrents() {
    showTorrents = torrents;
    if (torrentState != null) {
      showTorrents = showTorrents
          .where((torrent) => torrent.state == torrentState)
          .toList();
    }
    if (category != null) {
      showTorrents = showTorrents
          .where((torrent) => torrent.category == category)
          .toList();
    }
    if (selectedTracker == ' 红种') {
      showTorrents =
          showTorrents.where((torrent) => torrent.tracker!.isEmpty).toList();
    } else if (selectedTracker != ' All') {
      showTorrents = showTorrents
          .where((torrent) =>
              trackers[selectedTracker] != null &&
              trackers[selectedTracker]!.contains(torrent.hash))
          .toList();
    }
    if (searchKey.isNotEmpty) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.name!.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.category!
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()) ||
              torrent.hash!.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
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
      'ratioLimit': ratioLimit,
      'seedingTimeLimit': seedingTimeLimit,
      'inactiveSeedingTimeLimit': inactiveSeedingTimeLimit,
    });
    // Get.snackbar(response.succeed ? '成功啦！' : '出错啦！', response.msg);
    update();
    return response;
  }

  getDownloaderTorrents(Downloader downloader) async {
    // 打开加载状态
    try {
      bool isQb = downloader.category == 'Qb';

      final wsUrl = Uri.parse(
          '${baseUrl.replaceFirst('http', 'ws')}/api/${Api.DOWNLOADER_TORRENTS}');
      torrentsChannel = WebSocketChannel.connect(wsUrl);
      await torrentsChannel.ready;
      // 使用缓存
      String key = 'Downloader-$baseUrl:${downloader.name}-${downloader.id}';
      dynamic data = await SPUtil.getCache(key);
      if (data != null && data.isNotEmpty) {
        if (isQb) {
          parseQbMainData(data);
        } else {
          torrents = data.map((item) => TrTorrent.fromJson(item)).toList();
        }
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
          // LoggerHelper.Logger.instance.d(response.data[0]);
          if (isQb) {
            await SPUtil.setCache(key, response.data, 3600 * 24 * 3);
            parseQbMainData(response.data);

            // rid += 1;
          } else {
            torrents =
                response.data.map((item) => TrTorrent.fromJson(item)).toList();
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

  void parseQbMainData(data) {
    qBCategoryMap = {
      '全部': const Category(name: '全部'),
      '未分类': const Category(name: '', savePath: ''),
      ...{
        for (var entry in data['categories'].entries)
          entry.key: Category.fromJson(entry.value as Map<String, dynamic>)
      }
    };

    trackers = {
      '全部': [],
      ...mergeTrackers(Map<String, List<dynamic>>.from(data['trackers']))
    };
    // LoggerHelper.Logger.instance.d(trackers);
    tags = ["全部", ...List<String>.from(data['tags'] ?? [])];
    torrents = data['torrents'].entries.map((entry) {
      var torrent = Map<String, dynamic>.from(entry.value); // 复制原始数据
      torrent['hash'] = entry.key; // 添加 hash 属性
      return TorrentInfo.fromJson(torrent);
    }).toList();
    logger_helper.Logger.instance.d(torrents[0].toJson());

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
          item.status.add(TransferInfo.fromJson(status[key]));
        } else {
          TransmissionStats stats = TransmissionStats.fromJson(status[key]);
          item.status.add(stats);
        }
        logger_helper.Logger.instance.i(item.status);

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

  stopFetchTorrents() async {
    await torrentsChannel.sink.close(status.normalClosure);
    await torrentsChannel.sink.done;
    torrents.clear();
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
      // LoggerHelper.Logger.instance.i(downloader.name);
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
}
