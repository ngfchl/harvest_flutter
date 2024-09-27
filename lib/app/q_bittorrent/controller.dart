import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/meta_item.dart';
import 'package:harvest/models/common_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';

import '../../models/download.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../home/pages/models/website.dart';
import '../home/pages/my_site/controller.dart';

class QBittorrentController extends GetxController {
  MySiteController mySiteController = Get.find();

  Downloader downloader;
  late QBittorrentApiV2 client;
  StreamSubscription<List<TorrentInfo>>? torrentListSubscription;
  StreamSubscription<MainData>? mainDataSubscription;
  late Preferences configuration;
  TorrentState? torrentState;
  TorrentFilter torrentFilter = TorrentFilter.all;
  List<TorrentInfo> torrents = [];
  List<TorrentInfo> allTorrents = [];
  List<TorrentInfo> showTorrents = [];
  Map<String, Category?> categoryMap = {};
  Map<String, WebSite> trackerToWebSiteMap = {};
  ServerState? serverState;
  String? category;
  String selectedTracker = ' All';
  TorrentSort? sortKey = TorrentSort.name;
  String searchKey = '';
  int freeSpace = 0;
  int subInterval = 5;
  List<ServerState> statusList = [];
  bool sortReversed = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  Map<String, List<String>> trackers = {};

  bool toggleSpeedLimitLoading = false;

  QBittorrentController(this.downloader);

  List<MetaDataItem> filters = [
    {"name": "全部", "value": TorrentFilter.all},
    {"name": "下载中", "value": TorrentFilter.downloading},
    {"name": "活动中", "value": TorrentFilter.active},
    {"name": "暂停中", "value": TorrentFilter.paused},
    {"name": "上传中", "value": TorrentFilter.seeding},
    {"name": "静默中", "value": TorrentFilter.inactive},
    {"name": "移动中", "value": TorrentFilter.moving},
    {"name": "已完成", "value": TorrentFilter.completed},
    {"name": "已恢复", "value": TorrentFilter.resumed},
    {"name": "等待中", "value": TorrentFilter.stalled},
    {"name": "校验中", "value": TorrentFilter.checking},
    {"name": "下载队列", "value": TorrentFilter.stalledDownloading},
    {"name": "上传队列", "value": TorrentFilter.stalledUploading},
    {"name": "错误", "value": TorrentFilter.errored},
  ].map((e) => MetaDataItem.fromJson(e)).toList();

  List<MetaDataItem> status = [
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

  @override
  void onInit() async {
    isLoading = true;

    /// 初始化 qb 客户端
    client = await getQbInstance(downloader);
    await initData();
    super.onInit();
  }

  initData() async {
    sortKey = stringToTorrentSort(SPUtil.getLocalStorage(
        '${downloader.host}:${downloader.port}-sortKey'));

    /// 获取分类信息
    categoryMap = {
      '全部': const Category(name: '全部'),
      '未分类': const Category(name: '', savePath: ''),
    };
    categoryMap.addAll(await client.torrents.getCategories());

    /// 生成 tracker：website
    trackerToWebSiteMap = mySiteController.buildTrackerToWebSite();

    /// 获取上传下载信息
    await getQbStatus();

    /// 订阅所有种子
    subTorrentList();
    update();
  }

  Future getQbStatus() async {
    mainDataSubscription = client.sync
        .subscribeMainData(interval: Duration(seconds: subInterval))
        .listen((event) {
      allTorrents = event.torrents!.values.toList();
      serverState = event.serverState;
      statusList.add(event.serverState!);
      trackers = {' All': [], ' 红种': []};
      trackers.addAll(mergeTrackers(event.trackers));
      if (statusList.length > 30) {
        statusList.removeAt(0);
      }
      update();
    });
  }

  subTorrentList() {
    if (torrentListSubscription != null) {
      torrentListSubscription?.cancel();
    }
    torrentListSubscription = client.torrents
        .subscribeTorrentsList(
            options: TorrentListOptions(
              filter: torrentFilter,
              category: category,
              sort: sortKey,
              reverse: sortReversed,
              // hashes: showTorrents.map((e) => e.hash!).toList(),
            ),
            interval: Duration(seconds: subInterval))
        .listen((event) {
      isLoading = false;
      if (event.isNotEmpty) {
        torrents = event;
        filterTorrents();
      }
      update();
    });
  }

  Map<String, List<String>> mergeTrackers(Map<String, List<String>>? trackers) {
    return trackers?.entries.fold({}, (merged, entry) {
          var host = Uri.parse(entry.key).host;
          var tracker = trackerToWebSiteMap.keys.firstWhere(
              (element) => element.contains(host),
              orElse: () => host);
          host = trackerToWebSiteMap[tracker]?.name ?? tracker;
          merged?.putIfAbsent(host, () => []);
          merged?[host]!.addAll(entry.value);
          return merged;
        }) ??
        {};
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
          .where((TorrentInfo torrent) =>
              torrent.name!.toLowerCase().contains(searchKey.toLowerCase()) ||
              torrent.category!
                  .toLowerCase()
                  .contains(searchKey.toLowerCase()) ||
              torrent.hash!.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
    }
    update();
  }

  Future<void> controlTorrents({
    required String command,
    required List<String> hashes,
    String category = '',
    bool deleteFiles = false,
    bool enable = true,
    int limit = 0,
    RatioLimit ratioLimit = const RatioLimit.none(),
    RatioLimit seedingTimeLimit = const RatioLimit.none(),
  }) async {
    Logger.instance.w(command);
    Logger.instance.w(hashes);
    switch (command) {
      case 'pause':
        await client.torrents.pauseTorrents(torrents: Torrents(hashes: hashes));
      case 'reannounce':
        await client.torrents
            .reannounceTorrents(torrents: Torrents(hashes: hashes));
      case 'recheck':
        await client.torrents
            .recheckTorrents(torrents: Torrents(hashes: hashes));
      case 'resume':
        await client.torrents
            .resumeTorrents(torrents: Torrents(hashes: hashes));
      case 'SuperSeeding':
        await client.torrents.setSuperSeeding(
            torrents: Torrents(hashes: hashes), enable: enable);
      case 'AutoManagement':
        await client.torrents.setAutoManagement(
            torrents: Torrents(hashes: hashes), enable: enable);
      case 'Category':
        await client.torrents.setCategory(
            torrents: Torrents(hashes: hashes), category: category);
      case 'DownloadLimit':
        await client.torrents
            .setDownloadLimit(torrents: Torrents(hashes: hashes), limit: limit);
      case 'UploadLimit':
        await client.torrents
            .setUploadLimit(torrents: Torrents(hashes: hashes), limit: limit);
      case 'ForceStart':
        await client.torrents
            .setForceStart(torrents: Torrents(hashes: hashes), enable: enable);
      case 'ShareLimit':
        await client.torrents.setShareLimit(
            torrents: Torrents(hashes: hashes),
            ratioLimit: ratioLimit,
            seedingTimeLimit: seedingTimeLimit,
            inactiveSeedingTimeLimit: const RatioLimit.none());
      case 'delete':
        await client.torrents
            .deleteTorrents(torrents: Torrents(hashes: hashes));
      default:
        Get.snackbar('出错啦！', '未知操作：$command');
    }
    showTorrents.removeWhere((element) => hashes.contains(element.hash));
    update();
    torrents = await client.torrents
        .getTorrentsList(options: const TorrentListOptions());
    update();
  }

  Future<QBittorrentApiV2> getQbInstance(Downloader downloader) async {
    QBittorrentApiV2 qbittorrent = QBittorrentApiV2(
      baseUrl: '${downloader.protocol}://${downloader.host}:${downloader.port}',
      cookiePath:
          '${(await getApplicationDocumentsDirectory()).path}/${downloader.host}/${downloader.port}',
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      logger: false,
    );
    await qbittorrent.auth.login(
      username: downloader.username,
      password: downloader.password,
    );
    return qbittorrent;
  }

  ///@title 移除红种
  ///@description 移除红种
  ///@updateTime
  Future<CommonResponse> removeErrorTracker() async {
    try {
      List<String> toRemoveTorrentList = [];
      var groupedTorrents = groupBy(torrents, (t) => t.contentPath);
      for (var group in groupedTorrents.values) {
        var hasTracker = group.any((t) => t.tracker?.isNotEmpty == true);
        if (!hasTracker) {
          group.sort((t1, t2) => t2.progress!.compareTo(t1.progress!));
          toRemoveTorrentList.addAll(group.skip(1).map((t) => t.hash!));
        } else {
          toRemoveTorrentList.addAll(group
              .where((element) => element.tracker!.isEmpty)
              .map((t) => t.hash!));
        }
      }

      Logger.instance.i(toRemoveTorrentList);
      Logger.instance.i(toRemoveTorrentList.length);
      if (toRemoveTorrentList.isEmpty) {
        return CommonResponse.success(msg: '没有需要清理的种子！');
      }
      await controlTorrents(
          command: 'delete', hashes: toRemoveTorrentList, deleteFiles: false);
      showTorrents
          .removeWhere((element) => toRemoveTorrentList.contains(element.hash));
      String msg = '清理出错种子成功，本次共清理${toRemoveTorrentList.length}个种子！';
      Logger.instance.i(msg);
      return CommonResponse.success(msg: msg);
    } catch (e) {
      Logger.instance.e('出错啦！${e.toString()}');
      return CommonResponse.error(msg: '清理出错种子失败！${e.toString()}');
    }
  }

  @override
  void onClose() {
    torrentListSubscription?.cancel();
    mainDataSubscription?.cancel();
    super.onClose();
  }

  toggleSpeedLimit() async {
    toggleSpeedLimitLoading = true;
    update();
    await client.transfer.toggleSpeedLimitsMode();
    await mainDataSubscription?.cancel();
    await getQbStatus();
    await Future.delayed(const Duration(seconds: 2));
    toggleSpeedLimitLoading = false;
    update();
  }

  // 辅助方法，用于将字符串转换为 TorrentSort 枚举值
  TorrentSort? stringToTorrentSort(String? value) {
    final map = {
      'added_on': TorrentSort.addedOn,
      'amount_left': TorrentSort.amountLeft,
      'auto_tmm': TorrentSort.autoTmm,
      'availability': TorrentSort.availability,
      'category': TorrentSort.category,
      'completed': TorrentSort.completed,
      'completion_on': TorrentSort.completionOn,
      'content_path': TorrentSort.contentPath,
      'dl_limit': TorrentSort.dlLimit,
      'dlspeed': TorrentSort.dlSpeed,
      'downloaded': TorrentSort.downloaded,
      'downloaded_session': TorrentSort.downloadedSession,
      'eta': TorrentSort.eta,
      'f_l_piece_prio': TorrentSort.fLPiecePrio,
      'force_start': TorrentSort.forceStart,
      'hash': TorrentSort.hash,
      'last_activity': TorrentSort.lastActivity,
      'magnet_uri': TorrentSort.magnetUri,
      'max_ratio': TorrentSort.maxRatio,
      'max_seeding_time': TorrentSort.maxSeedingTime,
      'name': TorrentSort.name,
      'num_complete': TorrentSort.numComplete,
      'num_incomplete': TorrentSort.numIncomplete,
      'num_leechs': TorrentSort.numLeechs,
      'num_seeds': TorrentSort.numSeeds,
      'priority': TorrentSort.priority,
      'progress': TorrentSort.progress,
      'ratio': TorrentSort.ratio,
      'ratio_limit': TorrentSort.ratioLimit,
      'save_path': TorrentSort.savePath,
      'seeding_time': TorrentSort.seedingTime,
      'seeding_time_limit': TorrentSort.seedingTimeLimit,
      'seen_complete': TorrentSort.seenComplete,
      'seq_dl': TorrentSort.seqDl,
      'size': TorrentSort.size,
      'state': TorrentSort.state,
      'super_seeding': TorrentSort.superSeeding,
      'tags': TorrentSort.tags,
      'time_active': TorrentSort.timeActive,
      'total_size': TorrentSort.totalSize,
      'tracker': TorrentSort.tracker,
      'up_limit': TorrentSort.upLimit,
      'uploaded': TorrentSort.uploaded,
      'uploaded_session': TorrentSort.uploadedSession,
      'upspeed': TorrentSort.upSpeed,
    };

    return map[value]; // 如果找不到对应的枚举值，则返回 TorrentSort.name
  }
}
