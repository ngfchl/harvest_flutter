import 'dart:async';

import 'package:get/get.dart';
import 'package:transmission_api/transmission_api.dart';

import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../common/meta_item.dart';
import '../../models/common_response.dart';
import '../../models/download.dart';
import '../../utils/storage.dart';
import '../home/pages/models/transmission.dart';
import '../home/pages/models/website.dart';
import '../home/pages/my_site/controller.dart';
import '../torrent/models/transmission_base_torrent.dart';

class TrController extends GetxController {
  MySiteController mySiteController = Get.find();
  late V1 client;
  bool isLoading = false;
  String searchKey = '';
  int freeSpace = 1;
  String sortKey = 'name';
  bool sortReversed = false;
  List<TrTorrent> torrents = [];
  List<TrTorrent> showTorrents = [];
  Map<String, String> categoryMap = {};
  List<Map<String, String>> categories = <Map<String, String>>[];
  String category = '全部';
  Downloader downloader;
  Map<String, List<String>> trackers = {};
  String defaultSavePath = '/downloads/';
  int? trTorrentState;
  double duration = 3;
  double timerDuration = 3;
  Timer? periodicTimer;
  Map<String, WebSite?> trackerToWebSiteMap = {'全部': null};

  String? selectedTracker = '全部';

  TrController(this.downloader);

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

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    isLoading = true;
    update();
    trackerToWebSiteMap.addAll(mySiteController.buildTrackerToWebSite());
    duration = SPUtil.getDouble('duration', defaultValue: 3.0)!;
    timerDuration = SPUtil.getDouble('timerDuration', defaultValue: 3.0)!;

    /// 初始化 qb 客户端
    sortKey = SPUtil.getLocalStorage(
            '${downloader.host}:${downloader.port}-sortKey') ??
        'name';
    client = getTrInstance(downloader);

    /// 获取分类信息

    /// 获取上传下载信息
    await getTrSpeed();

    /// 订阅所有种子

    await getAllTorrents();
    getTrackerList();
    isLoading = false;
    update();
  }

  getTrackerList() {
    for (var torrent in torrents) {
      if (torrent.trackerStats.isEmpty == true) {
        continue;
      }
      String host = Uri.parse(torrent.trackerStats.first!.announce).host;
      trackers[host] ??= [];
      trackers[host]!.add(torrent.hashString);
    }
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(
        Duration(milliseconds: (duration * 1000).toInt()), (Timer t) async {
      // 在定时器触发时获取最新的下载器数据
      LoggerHelper.Logger.instance.i('调用刷新 timer');

      await getAllTorrents();
    });
    timerToStop();
    update();
  }

  void timerToStop() {
    Timer(Duration(seconds: (timerDuration * 60).toInt()), () {
      if (periodicTimer != null && periodicTimer?.isActive == true) {
        periodicTimer?.cancel();
      }
      update();
    });
  }

  V1 getTrInstance(Downloader downloader) {
    Transmission transmission = Transmission(
        '${downloader.protocol}://${downloader.host}:${downloader.port}',
        AuthKeys(downloader.username, downloader.password),
        logConfig: const ConfigLogger.showNone());
    return transmission.v1;
  }

  Future getTrSpeed() async {
    var res = await client.session.sessionStats();
    if (res['result'] == "success") {
      return CommonResponse(
          data: TransmissionStats.fromJson(res["arguments"]), code: 0);
    }
    return CommonResponse(
      code: -1,
      data: res,
      msg: '${downloader.name} 获取实时信息失败！',
    );
  }

  Future<String> getTrDefaultSavePath() async {
    var res =
        await client.session.sessionGet(fields: SessionArgs().downloadDir());
    return res['arguments']['download-dir'];
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
    // LoggerHelper.Logger.instance.w('搜索关键字：${searchKey.value}');

    if (searchKey.isNotEmpty) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.name.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.hashString
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()))
          .toList();
    }
  }

  filterTorrentsByTracker() {
    LoggerHelper.Logger.instance.i(selectedTracker);
    if (selectedTracker == null) {
      showTorrents = showTorrents
          .where((torrent) => torrent.trackerStats.isEmpty == true)
          .toList();
    } else if (selectedTracker != null && selectedTracker == '全部') {
    } else if (selectedTracker != null && selectedTracker?.isNotEmpty == true) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.trackerStats.isNotEmpty &&
              torrent.trackerStats.first?.announce
                      .toLowerCase()
                      .contains(selectedTracker.toString().toLowerCase()) ==
                  true)
          .toList();
    }
    LoggerHelper.Logger.instance.i(showTorrents.length);
  }

  filterTorrents() {
    showTorrents = torrents;
    update();
    LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByCategory();
    LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByState();
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsBySearchKey();
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByTracker();
    sortTorrents();
    update();
    LoggerHelper.Logger.instance.i(showTorrents.length);
  }

  Future<void> controlTorrents({
    required String command,
    required List<String> hashes,
    String category = '',
    bool deleteFiles = false,
    bool enable = true,
    int limit = 0,
    int ratioLimit = 0,
    int seedingTimeLimit = 0,
  }) async {
    LoggerHelper.Logger.instance.w(command);
    LoggerHelper.Logger.instance.w(hashes);
    switch (command) {
      case 'reannounce':
        client.torrent.torrentReannounce(ids: hashes);
      case 'delete':
        client.torrent.torrentRemove(ids: hashes, deleteLocalData: deleteFiles);
      case 'resume':
        client.torrent.torrentStart(ids: hashes);
      case 'ForceStart':
        client.torrent.torrentStartNow(ids: hashes);
      case 'pause':
        client.torrent.torrentStop(ids: hashes);
      case 'recheck':
        client.torrent.torrentVerify(ids: hashes);
      case 'uploadLimit':
        client.torrent.torrentSet(
            TorrentSetArgs().uploadLimited(true).uploadLimit(limit),
            ids: hashes);
      case 'downloadLimit':
        client.torrent.torrentSet(
            TorrentSetArgs().downloadLimited(true).downloadLimit(limit),
            ids: hashes);
      case 'ShareLimit':
        client.torrent.torrentSet(
            TorrentSetArgs().seedRatioLimit(limit as double),
            ids: hashes);
    }

    getAllTorrents();
    LoggerHelper.Logger.instance.i(categories);

    update();
  }

  Future<void> getAllTorrents() async {
    Map res = await client.torrent.torrentGet(
      fields: TorrentFields()
          .id
          .name
          .downloadDir
          .addedDate
          .sizeWhenDone
          .startDate
          .status
          .totalSize
          .percentDone
          .trackerStats
          .leftUntilDone
          .rateDownload
          .rateUpload
          .recheckProgress
          .peersGettingFromUs
          .peersSendingToUs
          .uploadRatio
          .hashString
          .magnetLink
          .uploadedEver
          .downloadedEver
          .error
          .errorString
          .doneDate
          .queuePosition
          .bandwidthPriority
          .availability
          .comment
          .downloadLimited
          .downloadLimit
          .downloadLimitMode
          .downloaders
          .fileCount
          .files
          .isFinished
          .isStalled
          .percentComplete
          .secondsDownloading
          .secondsSeeding
          .seedRatioLimited
          .seedRatioLimit
          .seedRatioMode
          .uploadLimitMode
          .uploadLimited
          .uploadLimit
          .uploadRatio
          .pieces
          .activityDate,
    );

    LoggerHelper.Logger.instance.w(res['arguments']["torrents"][0]);
    if (res['result'] == "success") {
      torrents = res['arguments']["torrents"]
          .map<TrTorrent>((item) => TrTorrent.fromJson(item))
          .toList();
      await getAllCategory();
      filterTorrents();
    }
  }

  sortTorrents() {
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
        Get.snackbar('出错啦！', '未知排序规则：${sortKey}');
    }

    if (sortReversed) {
      LoggerHelper.Logger.instance.w('反转序列！');
      showTorrents = showTorrents.reversed.toList();
    }
  }

  getAllCategory() async {
    defaultSavePath = await getTrDefaultSavePath();
    Set<Map<String, String>> uniqueCategories = {
      {'name': '全部', 'value': 'all_torrents'}
    };
    // 取全部
    if (torrents.isEmpty) {
      await getAllTorrents();
    }
    List<String> dirs = torrents
        .map((element) =>
            element.downloadDir.replaceAll(RegExp(r'\/$'), '').toString())
        .toSet()
        .toList();
    uniqueCategories
        .addAll(dirs.map((e) => {'name': e.split('/').last, 'value': e}));
    // 去重
    categoryMap = dirs.fold({}, (map, element) {
      map[element.split('/').last] = element;
      return map;
    });
    categoryMap['全部'] = '全部';
    LoggerHelper.Logger.instance.w('TR 路径：$categoryMap');
    LoggerHelper.Logger.instance.w('TR 路径：$defaultSavePath');
    categories = uniqueCategories.toList();
  }

  getTrFreeSpace() async {
    defaultSavePath = await getTrDefaultSavePath();
    // LoggerHelper.Logger.instance.w(res['arguments']['download-dir']);

    Map response = await client.system.freeSpace(path: defaultSavePath);
    freeSpace =
        TrFreeSpace.fromJson(response['arguments'] as Map<String, dynamic>)
            .sizeBytes!;
  }

  void filterTorrentsByCategory() {
    LoggerHelper.Logger.instance.i(category);
    if (category != '全部') {
      showTorrents = showTorrents.where((torrent) {
        return torrent.downloadDir.contains(category);
      }).toList();
    }
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

  removeErrorTracker() {}

  toggleSpeedLimit() {}
}
