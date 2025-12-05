import 'dart:async';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart' as qb;
import 'package:transmission_api/transmission_api.dart';

import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../common/meta_item.dart';
import '../../models/common_response.dart';
import '../../utils/storage.dart';
import '../home/pages/models/download.dart';
import '../home/pages/models/transmission.dart';
import '../home/pages/models/transmission_base_torrent.dart';
import '../home/pages/models/website.dart';
import '../home/pages/my_site/controller.dart';

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
  Map<String, qb.Category> categoryMap = {};
  List<Map<String, String>> categories = <Map<String, String>>[];
  String selectedCategory = '全部';
  Downloader downloader;
  List<String> labels = [];
  Map<String, List<String>> trackers = {};
  String defaultSavePath = '/downloads/';
  int? trTorrentState;
  double duration = 3;
  double timerDuration = 3;
  Timer? periodicTimer;
  Map<String, WebSite?> trackerToWebSiteMap = {'全部': null};
  TransmissionStats? trStats;
  int torrentCount = 0;
  String? selectedTracker = '全部';
  String? selectedLabel = '全部';
  String selectedError = '全部';
  List<String> errors = [];
  bool exitState = false;
  int pageSize = 20;

  TrController(this.downloader);

  List<String> selectedTorrents = [];
  bool selectMode = false;

  List<MetaDataItem> trSortOptions = [
    {'name': '名称', 'value': 'name'},
    {'name': 'ID', 'value': 'id'},
    {'name': '状态', 'value': 'status'},
    {'name': '总大小', 'value': 'totalSize'},
    {'name': '队列位置', 'value': 'queuePosition'},
    {'name': '完成日期', 'value': 'doneDate'},
    {'name': '下载进度', 'value': 'percentDone'},
    {'name': '已上传', 'value': 'uploadedEver'},
    {'name': '已下载', 'value': 'downloaded'},
    {'name': '下载速度', 'value': 'rateDownload'},
    {'name': '上传速度', 'value': 'rateUpload'},
    {'name': '校验进度', 'value': 'recheckProgress'},
    {'name': '活动日期', 'value': 'activityDate'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();
  List<MetaDataItem> trStatus = [
    {"name": "全部", "value": null},
    // {"name": "红种", "value": 99},
    {"name": "下载中", "value": 4},
    // {"name": "活动中", "value": 100},
    {"name": "做种中", "value": 6},
    {"name": "已停止", "value": 0},
    {"name": "校验中", "value": 2},
    {"name": "校验队列", "value": 1},
    {"name": "排队下载", "value": 3},
    {"name": "排队上传", "value": 5},
  ].map((e) => MetaDataItem.fromJson(e)).toList();

  bool trackerLoading = false;
  Map<String, List<String>> trackerHashes = {};

  @override
  void onInit() async {
    isLoading = true;
    update();
    await initData();
    isLoading = false;
    update();
    super.onInit();
  }

  Future<void> initData() async {
    pageSize = SPUtil.getInt('pageSize', defaultValue: 30) * 100;
    trackerToWebSiteMap.addAll(mySiteController.buildTrackerToWebSite());
    duration = SPUtil.getDouble('duration', defaultValue: 3.0);
    timerDuration = SPUtil.getDouble('timerDuration', defaultValue: 3.0);

    /// 初始化 qb 客户端
    sortKey = SPUtil.getLocalStorage('${downloader.host}:${downloader.port}-sortKey-DIRECT') ?? 'name';
    client = getTrInstance(downloader);

    /// 获取分类信息

    /// 获取上传下载信息
    await getTrSpeed();

    /// 订阅所有种子
    await getAllTorrents();
  }

  void getTrackerList() {
    for (var torrent in torrents) {
      if (torrent.trackerStats.isEmpty == true) {
        continue;
      }
      String host = Uri.parse(torrent.trackerStats.first.announce).host;
      trackers.putIfAbsent(host, () => []).add(torrent.hashString);
    }

    /// 生成Map site.name: hashes
    for (final website in mySiteController.webSiteList.values) {
      for (final entry in trackers.entries) {
        if (website.tracker.contains(entry.key)) {
          trackerHashes.putIfAbsent(website.name, () => []).addAll(entry.value);
        }
      }
    }
    // 去重 value
    trackerHashes.updateAll((_, list) => list.toSet().toList());
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(Duration(milliseconds: (duration * 1000).toInt()), (Timer t) async {
      // 在定时器触发时获取最新的下载器数据
      logger_helper.Logger.instance.i('调用刷新 timer');
      await getTrSpeed();
      update();
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
    Transmission transmission = Transmission('${downloader.protocol}://${downloader.host}:${downloader.port}',
        AuthKeys(downloader.username, downloader.password),
        logConfig: const ConfigLogger.showAll());
    return transmission.v1;
  }

  Future getTrSpeed() async {
    var res = await client.session.sessionStats();
    if (res['result'] == "success") {
      trStats = TransmissionStats.fromJson(res["arguments"]);
      torrentCount = trStats!.torrentCount;
    }
  }

  Future<String> getTrDefaultSavePath() async {
    var res = await client.session.sessionGet(fields: SessionArgs().downloadDir());
    return res['arguments']['download-dir'];
  }

  void filterTorrentsByState() {
    if (trTorrentState == null) {
      return;
    }
    switch (trTorrentState) {
      case 99:
        showTorrents = showTorrents.where((torrent) => torrent.error > 0).toList();
        break;
      case 100:
        showTorrents = showTorrents.where((torrent) => torrent.rateUpload > 0 || torrent.rateDownload > 0).toList();
        break;
      default:
        showTorrents = showTorrents.where((torrent) => torrent.status == trTorrentState).toList();
        break;
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

  void filterTorrentsBySearchKey() {
    // LoggerHelper.Logger.instance.d('搜索关键字：${searchKey.value}');

    if (searchKey.isNotEmpty) {
      showTorrents = showTorrents
          .where((torrent) =>
              torrent.name.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.errorString.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.hashString.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
    }
  }

  void filterTorrentsByTracker() {
    logger_helper.Logger.instance.i(selectedTracker);
    if (selectedTracker == null) {
      showTorrents = showTorrents.where((torrent) => torrent.trackerStats.isEmpty == true).toList();
    } else if (selectedTracker != null && selectedTracker == '全部') {
    } else if (selectedTracker != null && selectedTracker == '红种') {
      showTorrents = showTorrents.where((torrent) => torrent.error == 2).toList();
    } else if (selectedTracker != null && selectedTracker?.isNotEmpty == true) {
      showTorrents = showTorrents
          .where((torrent) => trackerHashes[selectedTracker]?.contains(torrent.hashString) == true)
          .toList();
    }
    logger_helper.Logger.instance.i(showTorrents.length);
  }

  void filterTorrents() {
    showTorrents = torrents;
    update();
    logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByCategory();
    logger_helper.Logger.instance.d(showTorrents.length);
    filterTorrentsByState();
    // LoggerHelper.Logger.instance.d(showTorrents.length);
    filterTorrentsBySearchKey();
    // LoggerHelper.Logger.instance.d(showTorrents.length);
    filterTorrentsByTracker();
    filterTorrentsByError();
    // logger_helper.Logger.instance.d(showTorrents.length);
    sortTorrents();
    update();
    logger_helper.Logger.instance.i(showTorrents.length);
  }

  Future<Map<dynamic, dynamic>> controlTorrents({
    required String command,
    required List<String> ids,
    List<String> labels = const [],
    String location = '',
    String name = '',
    bool deleteFiles = false,
    bool enable = true,
    int limit = 0,
    int ratioLimit = 0,
    int seedingTimeLimit = 0,
    String trackerList = '',
  }) async {
    logger_helper.Logger.instance.d(command);
    logger_helper.Logger.instance.d("正在操作 ${ids.length} 个种子");
    Map<dynamic, dynamic> result = {};
    switch (command) {
      case 'torrentReannounce':
        result = await client.torrent.torrentReannounce(ids: ids);
        break;
      case 'torrentSetLabels':
        result = await client.torrent.torrentSet(TorrentSetArgs().labels(labels), ids: ids);
        break;
      case 'torrentSetTrackerList':
        result = await client.torrent.torrentSet(TorrentSetArgs().trackerList(trackerList), ids: ids);
        break;
      case 'torrentRemove':
        torrents.removeWhere((element) => ids.contains(element.hashString));
        filterTorrents();
        result = await client.torrent.torrentRemove(ids: ids, deleteLocalData: deleteFiles);
        break;
      case 'torrentStart':
        result = await client.torrent.torrentStart(ids: ids);
        break;
      case 'torrentStartNow':
        result = await client.torrent.torrentStartNow(ids: ids);
        break;
      case 'torrentStop':
        result = await client.torrent.torrentStop(ids: ids);
        break;
      case 'queueMoveTop':
        result = await client.queue.queueMoveTop(ids: ids);
        break;
      case 'queueMoveBottom':
        result = await client.queue.queueMoveBottom(ids: ids);
        break;
      case 'queueMoveUp':
        result = await client.queue.queueMoveUp(ids: ids);
        break;
      case 'queueMoveDown':
        result = await client.queue.queueMoveDown(ids: ids);
        break;
      case 'torrentVerify':
        result = await client.torrent.torrentVerify(ids: ids);
        break;
      case 'torrentRenamePath':
        result = await client.torrent.torrentRenamePath(ids: ids, path: location, name: name);
        break;
      case 'torrentSetLocation':
        result = await client.torrent.torrentSetLocation(ids: ids, location: location, move: enable);
        break;
      case 'uploadLimit':
        result = await client.torrent.torrentSet(TorrentSetArgs().uploadLimited(true).uploadLimit(limit), ids: ids);
        break;
      case 'downloadLimit':
        result = await client.torrent.torrentSet(TorrentSetArgs().downloadLimited(true).downloadLimit(limit), ids: ids);
        break;
      case 'setShareLimit':
        result = await client.torrent.torrentSet(TorrentSetArgs().seedRatioLimit(limit as double), ids: ids);
        break;
    }
    logger_helper.Logger.instance.d(result);
    await getAllTorrents();
    logger_helper.Logger.instance.i(categories);
    update();
    return result;
  }

  Future<void> getAllTorrents() async {
    TorrentFields fields = TorrentFields()
        .activityDate
        .addedDate
        .bandwidthPriority
        .comment
        .doneDate
        .downloadDir
        .downloadLimited
        .downloadLimit
        .downloadedEver
        .error
        .errorString
        .files
        .fileStats
        .hashString
        .id
        .isFinished
        .isStalled
        .leftUntilDone
        .labels
        .magnetLink
        .name
        .peersGettingFromUs
        .peersSendingToUs
        .percentDone
        .percentComplete
        .queuePosition
        .rateDownload
        .rateUpload
        .recheckProgress
        .secondsDownloading
        .secondsSeeding
        .seedRatioLimited
        .seedRatioLimit
        .seedRatioMode
        .sizeWhenDone
        .startDate
        .status
        .totalSize
        .trackerStats
        .trackerList
        .uploadLimitMode
        .uploadLimited
        .uploadLimit
        .uploadRatio
        .uploadedEver;

    if (torrents.isEmpty) {
      List<int> ids = await getTorrentIds();
      for (int i = 0; i < ids.length; i += pageSize) {
        if (exitState) {
          break;
        }
        List<int> batchIds = ids.sublist(i, (i + pageSize) >= ids.length ? ids.length : (i + pageSize));
        Map res = await client.torrent.torrentGet(fields: fields, ids: batchIds);
        torrents.addAll(res['arguments']["torrents"].map<TrTorrent>((item) => TrTorrent.fromJson(item)).toList());
        filterTorrents();
        isLoading = false;
      }
    } else {
      Map res = await client.torrent.torrentGet(fields: fields);
      if (res['result'] == "success") {
        torrents = res['arguments']["torrents"].map<TrTorrent>((item) => TrTorrent.fromJson(item)).toList();
      }
    }
    labels = torrents.expand((e) => e.labels).toSet().toList();
    errors.addAll(torrents.map<String>((item) => item.errorString).toSet().where((el) => el.isNotEmpty).toList());
    getTrackerList();
    await getAllCategory();
    filterTorrents();
  }

  Future<List<int>> getTorrentIds() async {
    Map res = await client.torrent.torrentGet(fields: TorrentFields().id);
    if (res['result'] == "success") {
      List<int> ids = (res['arguments']["torrents"] as List).map((e) => e["id"] as int).toList();
      return ids;
    } else {
      logger_helper.Logger.instance.e('Failed to fetch torrent count');
      return [];
    }
  }

  String getTrMetaName(String hashString) {
    // 查找第一个匹配的 tracker 键
    final trackerKey = trackerHashes.entries.firstWhereOrNull((entry) => entry.value.contains(hashString))?.key;

    // 根据 trackerKey 查找对应的 WebSite 名称
    return trackerToWebSiteMap[trackerKey]?.name ?? trackerKey ?? '未知';
  }

  void sortTorrents() {
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
        showTorrents.sort((a, b) => a.queuePosition.toString().compareTo(b.queuePosition.toString()));
      case 'doneDate':
        showTorrents.sort((a, b) => a.doneDate.compareTo(b.doneDate));
      case 'percentDone':
        showTorrents.sort((a, b) => a.percentDone.compareTo(b.percentDone));
      case 'uploadedEver':
        showTorrents.sort((a, b) => a.uploadedEver.compareTo(b.uploadedEver));
      case 'downloaded':
        showTorrents.sort((a, b) => a.downloadedEver.compareTo(b.downloadedEver));
      case 'rateDownload':
        showTorrents.sort((a, b) => a.rateDownload.compareTo(b.rateDownload));
      case 'rateUpload':
        showTorrents.sort((a, b) => a.rateUpload.compareTo(b.rateUpload));
      case 'recheckProgress':
        showTorrents.sort((a, b) => a.recheckProgress.compareTo(b.recheckProgress));
      case 'activityDate':
        showTorrents.sort((a, b) => a.activityDate.compareTo(b.activityDate));
      default:
        Get.snackbar('出错啦！', '未知排序规则：$sortKey');
    }

    if (sortReversed) {
      logger_helper.Logger.instance.d('反转序列！');
      showTorrents = showTorrents.reversed.toList();
    }
  }

  Future<void> getAllCategory() async {
    defaultSavePath = await getTrDefaultSavePath();
    Set<Map<String, String>> uniqueCategories = {
      {'name': '全部', 'value': 'all_torrents'}
    };
    // 取全部
    if (torrents.isEmpty) {
      await getAllTorrents();
    }
    List<String> dirs =
        torrents.map((element) => element.downloadDir.replaceAll(RegExp(r'\/$'), '').toString()).toSet().toList();
    uniqueCategories.addAll(dirs.map((e) => {'name': e.split('/').last, 'value': e}));
    // 去重
    categoryMap = dirs.fold({}, (map, element) {
      var key = element.split('/').last;
      map[key] = qb.Category(name: key, savePath: element);
      return map;
    });
    logger_helper.Logger.instance.d('TR 路径：$categoryMap');
    logger_helper.Logger.instance.d('TR 路径：$defaultSavePath');
    categories = uniqueCategories.toList();
  }

  Future<void> getTrFreeSpace() async {
    defaultSavePath = await getTrDefaultSavePath();
    // LoggerHelper.Logger.instance.d(res['arguments']['download-dir']);

    Map response = await client.system.freeSpace(path: defaultSavePath);
    freeSpace = TrFreeSpace.fromJson(response['arguments'] as Map<String, dynamic>).sizeBytes!;
  }

  void filterTorrentsByCategory() {
    logger_helper.Logger.instance.i(selectedCategory);
    if (selectedCategory != '全部') {
      showTorrents = showTorrents.where((torrent) {
        return torrent.downloadDir.contains(selectedCategory);
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
    exitState = true;
    super.onClose();
  }

  /*///@title 一键替换站点 tracker
  ///@description TODO
  ///@updateTime
  */
  Future<CommonResponse> replaceTrackers({required String site, required String newTracker}) async {
    List<String> hashes = trackerHashes[site] ?? [];
    hashes = hashes.toSet().toList();
    logger_helper.Logger.instance.d(hashes);
    if (hashes.isEmpty) {
      return CommonResponse.success(msg: '本下载器没有 $site 站点的种子！');
    }
    try {
      var res = await client.torrent.torrentSet(TorrentSetArgs().trackerList(newTracker), ids: hashes);
      logger_helper.Logger.instance.d("Tracker 替换响应：$res");
    } catch (e, trace) {
      logger_helper.Logger.instance.e(e);
      logger_helper.Logger.instance.e(trace);
      String msg = '$site 站点替换 tracker 失败！';
      return CommonResponse.error(msg: msg);
    }
    String msg = "$site 站点查找到${hashes.length}个种子，已替换";
    return CommonResponse.success(msg: msg);
  }

  Future<CommonResponse> removeErrorTracker() async {
    try {
      List<String> toRemoveTorrentList = [];
      var groupedTorrents = groupBy(torrents, (t) => t.name);
      for (var group in groupedTorrents.values) {
        var hasTracker = group.any((t) => t.error != 2);
        if (!hasTracker) {
          group.sort((t1, t2) => t2.percentDone.compareTo(t1.percentDone));
          toRemoveTorrentList.addAll(group.skip(1).map((t) => t.hashString));
        } else {
          toRemoveTorrentList.addAll(group.where((element) => element.error == 2).map((t) => t.hashString));
        }
      }

      logger_helper.Logger.instance.i(toRemoveTorrentList);
      logger_helper.Logger.instance.i(toRemoveTorrentList.length);
      if (toRemoveTorrentList.isEmpty) {
        return CommonResponse.success(msg: '没有需要清理的种子！');
      }
      await controlTorrents(command: 'delete', ids: toRemoveTorrentList, deleteFiles: false);
      showTorrents.removeWhere((element) => toRemoveTorrentList.contains(element.hashString));
      String msg = '清理出错种子成功，本次共清理${toRemoveTorrentList.length}个种子！';
      logger_helper.Logger.instance.i(msg);
      return CommonResponse.success(msg: msg);
    } catch (e) {
      logger_helper.Logger.instance.e('出错啦！${e.toString()}');
      return CommonResponse.error(msg: '清理出错种子失败！${e.toString()}');
    }
  }

  Future<CommonResponse> toggleSpeedLimit() async {
    try {
      Map res = await client.session.sessionGet(fields: SessionArgs().altSpeedEnabled());
      logger_helper.Logger.instance.i(res);
      res =
          await client.session.sessionSet(args: SessionArgs().altSpeedEnabled(!res['arguments']['alt-speed-enabled']));
      logger_helper.Logger.instance.i(res);
      if (res['result'] == 'success') {
        return CommonResponse.success(msg: '切换成功！');
      } else {
        return CommonResponse.error(msg: '切换失败！${res['result']}');
      }
    } catch (e, stackTrace) {
      logger_helper.Logger.instance.e(e.toString());
      logger_helper.Logger.instance.e(stackTrace);
      return CommonResponse.error(msg: '切换失败！${e.toString()}');
    }
  }
}
