import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart' as tr;

import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../models/download.dart';
import '../home/pages/controller/download_controller.dart';
import '../home/pages/models/transmission.dart';
import 'models/transmission_base_torrent.dart';

class TorrentController extends GetxController {
  DownloadController downloadController = Get.find();

  late Downloader downloader;
  final torrents = [].obs;
  final showTorrents = [].obs;
  final categories = <Map<String, String>>[].obs;
  final category = 'all_torrents'.obs;
  late Timer periodicTimer;
  RxBool isTimerActive = true.obs; // 使用 RxBool 控制定时器是否激活
  final sortKey = 'name'.obs;
  final sortReversed = false.obs;
  final searchController = TextEditingController().obs;
  final searchKey = ''.obs;
  final statusList = RxList().obs;
  final freeSpace = 1.obs;
  Rx<TorrentState?> torrentState = Rx<TorrentState?>(null);
  Rx<int?> trTorrentState = Rx<int?>(null);
  Rx<TorrentFilter> torrentFilter = Rx<TorrentFilter>(TorrentFilter.all);

  List filters = [
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
  ];

  List status = [
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
    {"name": "检查恢复数据", "value": TorrentState.checkingResumeData},
    {"name": "检查上传", "value": TorrentState.checkingUP},
    {"name": "强制下载", "value": TorrentState.forcedDL},
    {"name": "强制元数据下载", "value": TorrentState.forcedMetaDL},
    {"name": "强制上传", "value": TorrentState.forcedUP},
    {"name": "元数据下载中", "value": TorrentState.metaDL},
    {"name": "缺失文件", "value": TorrentState.missingFiles},

    // {"name": "未知状态", "value": TorrentState.unknown},
    {"name": "错误", "value": TorrentState.error},
  ];
  List<Map<String, String>> trSortOptions = [
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
  ];
  List<Map<String, dynamic>> trStatus = [
    {"name": "全部", "value": null},
    {"name": "下载ing", "value": 4},
    {"name": "做种ing", "value": 6},
    {"name": "已停止", "value": 0},
    {"name": "校验ing", "value": 2},
    {"name": "校验队列", "value": 1},
    {"name": "排队下载", "value": 3},
    {"name": "排队上传", "value": 5},
  ];
  List<Map<String, String>> qbSortOptions = [
    {'name': '名称', 'value': 'name'},
    {'name': '类别', 'value': 'category'},
    {'name': '大小', 'value': 'size'},
    {'name': '添加时间', 'value': 'addedOn'},
    {'name': '总大小', 'value': 'totalSize'},
    {'name': '状态', 'value': 'state'},
    {'name': '追踪器', 'value': 'tracker'},
    {'name': '进度', 'value': 'progress'},
    {'name': '已上传', 'value': 'uploaded'},
    {'name': '已下载', 'value': 'downloaded'},
    {'name': '下载速度', 'value': 'dlSpeed'},
    {'name': '上传速度', 'value': 'upSpeed'},
    {'name': '最后活动时间', 'value': 'lastActivity'},
    {'name': '活跃时间', 'value': 'timeActive'},
    {'name': '保存路径', 'value': 'savePath'},
    {'name': '完成数', 'value': 'completed'},
    {'name': '完成时间', 'value': 'completionOn'},
    {'name': 'Leechs 数量', 'value': 'numLeechs'},
    {'name': 'Seeds 数量', 'value': 'numSeeds'},
    {'name': '未完成数', 'value': 'numIncomplete'},
    {'name': '已完成数', 'value': 'numComplete'},
    {'name': '优先级', 'value': 'priority'},
    {'name': '已查看完成', 'value': 'seenComplete'},
  ];

  @override
  void onInit() {
    downloader = Get.arguments;
    if (downloader.category.toLowerCase() == 'qb') {
      getAllCategory();
    }
    getFreeSpace();
    getAllTorrents();
    startPeriodicTimer();
    Timer(Duration(seconds: (downloadController.timerDuration * 60).toInt()),
        () {
      // 定时器触发后执行的操作，这里可以取消periodicTimer、关闭资源等
      periodicTimer.cancel();
      // 你可以在这里添加其他需要在定时器触发后执行的逻辑
    });

    super.onInit();
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(
        Duration(milliseconds: (downloadController.duration * 1000).toInt()),
        (Timer t) async {
      // 在定时器触发时获取最新的下载器数据
      getAllTorrents();
      getFreeSpace();

      dynamic status = await downloadController.getIntervalSpeed(downloader);
      LoggerHelper.Logger.instance.w('state77:${status.code}');
      if (status.code == 0) {
        LoggerHelper.Logger.instance.w(statusList.value.length);
        statusList.value.add(status.data);
        if (statusList.value.length > 30) {
          statusList.value.removeAt(0);
        }
      }
    });
    isTimerActive.value = true;
    update();
  }

  void cancelPeriodicTimer() {
    if (periodicTimer.isActive) {
      periodicTimer.cancel();
    }
    isTimerActive.value = false;
    update();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    periodicTimer.cancel();
    categories.clear();
    torrents.clear();
    showTorrents.clear();
    trTorrentState.value = null;
    category.value = 'all_torrent';
    super.onClose();
  }

  getAllCategory() async {
    if (categories.isNotEmpty) {
      return;
    }
    if (downloader.category.toLowerCase() == 'qb') {
      categories.value = <Map<String, String>>[
        {'name': '全部', 'value': 'all_torrents'},
        {'name': '未分类', 'value': ''},
      ];
      QBittorrentApiV2 qbittorrent =
          await downloadController.getQbInstance(downloader);
      categories.addAll((await qbittorrent.torrents.getCategories())
          .keys
          .map<Map<String, String>>((e) => {'name': e, 'value': e})
          .toList());

      LoggerHelper.Logger.instance.w(categories.length);
    } else {
      Set<Map<String, String>> uniqueCategories = {
        {'name': '全部', 'value': 'all_torrents'}
      };
      // 取全部
      uniqueCategories.addAll(torrents
          .map((element) => element.downloadDir!.replaceAll(RegExp(r'\/$'), ''))
          .toSet()
          .map((e) => {'name': e, 'value': e}));
      // 去重

      LoggerHelper.Logger.instance.w('TR 路径：${uniqueCategories.length}');

      categories.value = uniqueCategories.toList();
    }
    update();
  }

  sortTorrents() {
    if (downloader.category.toLowerCase() == 'qb') {
      switch (sortKey.value) {
        case 'name':
          showTorrents.sort((a, b) => a.name!.compareTo(b.name!));
        case 'category':
          showTorrents.sort((a, b) => a.category!.compareTo(b.category!));
        case 'size':
          showTorrents.sort((a, b) => a.size!.compareTo(b.size!));
        case 'addedOn':
          showTorrents.sort((a, b) => a.addedOn!.compareTo(b.addedOn!));
        case 'totalSize':
          showTorrents.sort((a, b) => a.totalSize!.compareTo(b.totalSize!));
        case 'state':
          showTorrents.sort(
              (a, b) => a.state!.toString().compareTo(b.state!.toString()));
        case 'tracker':
          showTorrents.sort((a, b) => a.tracker!.compareTo(b.tracker!));
        case 'progress':
          showTorrents.sort((a, b) => a.progress!.compareTo(b.progress!));
        case 'uploaded':
          showTorrents.sort((a, b) => a.uploaded!.compareTo(b.uploaded!));
        case 'downloaded':
          showTorrents.sort((a, b) => a.downloaded!.compareTo(b.downloaded!));
        case 'dlSpeed':
          showTorrents.sort((a, b) => a.dlSpeed!.compareTo(b.dlSpeed!));
        case 'upSpeed':
          showTorrents.sort((a, b) => a.upSpeed!.compareTo(b.upSpeed!));
        case 'lastActivity':
          showTorrents
              .sort((a, b) => a.lastActivity!.compareTo(b.lastActivity!));
        case 'timeActive':
          showTorrents.sort((a, b) => a.timeActive!.compareTo(b.timeActive!));
        case 'savePath':
          showTorrents.sort((a, b) => a.savePath!.compareTo(b.savePath!));
        case 'completed':
          showTorrents.sort((a, b) => a.completed!.compareTo(b.completed!));
        case 'completionOn':
          showTorrents
              .sort((a, b) => a.completionOn!.compareTo(b.completionOn!));
        case 'numLeechs':
          showTorrents.sort((a, b) => a.numLeechs!.compareTo(b.numLeechs!));
        case 'numSeeds':
          showTorrents.sort((a, b) => a.numSeeds!.compareTo(b.numSeeds!));
        case 'numIncomplete':
          showTorrents
              .sort((a, b) => a.numIncomplete!.compareTo(b.numIncomplete!));
        case 'numComplete':
          showTorrents.sort((a, b) => a.numComplete!.compareTo(b.numComplete!));
        case 'priority':
          showTorrents.sort((a, b) => a.priority!.compareTo(b.priority!));
        case 'seenComplete':
          showTorrents
              .sort((a, b) => a.seenComplete!.compareTo(b.seenComplete!));
        default:
          Get.snackbar('出错啦！', '未知排序规则：${sortKey.value}');
      }
    } else {
      switch (sortKey.value) {
        case 'name':
          showTorrents.sort((a, b) => a.name!.compareTo(b.name!));
        case 'id':
          showTorrents.sort((a, b) => a.id!.compareTo(b.id!));
        case 'status':
          showTorrents.sort((a, b) => a.status!.compareTo(b.status!));
        // case 'addedOn':
        //   torrents
        //       .sort(( a, b) => a.addedOn!.compareTo(b.addedOn!));
        case 'totalSize':
          showTorrents.sort((a, b) => a.totalSize!.compareTo(b.totalSize!));
        case 'queuePosition':
          showTorrents.sort((a, b) => a.queuePosition!
              .toString()
              .compareTo(b.queuePosition!.toString()));
        case 'doneDate':
          showTorrents.sort((a, b) => a.doneDate!.compareTo(b.doneDate!));
        case 'percentDone':
          showTorrents.sort((a, b) => a.percentDone!.compareTo(b.percentDone!));
        case 'uploadedEver':
          showTorrents
              .sort((a, b) => a.uploadedEver!.compareTo(b.uploadedEver!));
        case 'downloaded':
          showTorrents
              .sort((a, b) => a.downloadedEver!.compareTo(b.downloadedEver!));
        case 'rateDownload':
          showTorrents
              .sort((a, b) => a.rateDownload!.compareTo(b.rateDownload!));
        case 'rateUpload':
          showTorrents.sort((a, b) => a.rateUpload!.compareTo(b.rateUpload!));
        case 'recheckProgress':
          showTorrents
              .sort((a, b) => a.recheckProgress!.compareTo(b.recheckProgress!));
        case 'activityDate':
          showTorrents
              .sort((a, b) => a.activityDate!.compareTo(b.activityDate!));
        default:
          Get.snackbar('出错啦！', '未知排序规则：${sortKey.value}');
      }
    }
    if (sortReversed.value) {
      LoggerHelper.Logger.instance.w('反转序列！');
      showTorrents.value = showTorrents.reversed.toList();
    }
  }

  void filterTorrentsByCategory() {
    if (category.value == 'all_torrents') return;

    showTorrents.value = showTorrents.where((torrent) {
      if (downloader.category.toLowerCase() == 'qb') {
        return category.value.isEmpty
            ? torrent.category.isEmpty
            : torrent.category == category.value;
      } else {
        return torrent.downloadDir == category.value;
      }
    }).toList();
  }

  filterTorrentsByState() {
    final isQbCategory = downloader.category.toLowerCase() == 'qb';
    final selectedState =
        isQbCategory ? torrentState.value : trTorrentState.value;

    LoggerHelper.Logger.instance.w('状态：$selectedState');
    if (selectedState != null) {
      showTorrents.value = showTorrents
          .where((torrent) => isQbCategory
              ? torrent.state == selectedState
              : torrent.status == selectedState)
          .toList();
    }
  }

  filterTorrentsBySearchKey() {
    LoggerHelper.Logger.instance.w('搜索关键字：${searchKey.value}');

    if (searchKey.value.isNotEmpty) {
      showTorrents.value = showTorrents
          .where((torrent) => torrent.name!
              .toLowerCase()
              .contains(searchKey.value.toLowerCase()))
          .toList();
    }
  }

  filterTorrents() {
    showTorrents.value = torrents;
    LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByCategory();
    LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByState();
    LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsBySearchKey();
    LoggerHelper.Logger.instance.w(showTorrents.length);
    update();
  }

  Future<void> getAllTorrents() async {
    if (downloader.category.toLowerCase() == 'qb') {
      QBittorrentApiV2 qbittorrent =
          await downloadController.getQbInstance(downloader);

      torrents.value = await qbittorrent.torrents.getTorrentsList(
        options: TorrentListOptions(
            // category: category.value != 'all_torrents' ? category.value : null,
            // sort: TorrentSort.name,
            filter: torrentFilter.value),
      );

      LoggerHelper.Logger.instance.w(torrents.length);
    } else {
      tr.Transmission transmission =
          downloadController.getTrInstance(downloader);
      Map res = await transmission.v1.torrent.torrentGet(
          fields: tr.TorrentFields()
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
              .activityDate);

      LoggerHelper.Logger.instance.w(res['arguments']["torrents"][0]);
      if (res['result'] == "success") {
        torrents.value = res['arguments']["torrents"]
            .map<TransmissionBaseTorrent>(
                (item) => TransmissionBaseTorrent.fromJson(item))
            .toList();
        await getAllCategory();
      }
    }
    // if (sortReversed.value) {
    //   LoggerHelper.Logger.instance.w('反转序列！');
    //   showTorrents.value = showTorrents.reversed.toList();
    //   sortReversed.value = false;
    // }
    filterTorrents();
    sortTorrents();
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
    LoggerHelper.Logger.instance.w(command);
    LoggerHelper.Logger.instance.w(hashes);
    if (downloader.category.toLowerCase() == 'qb') {
      QBittorrentApiV2 qbittorrent =
          await downloadController.getQbInstance(downloader);
      switch (command) {
        case 'pause':
          await qbittorrent.torrents
              .pauseTorrents(torrents: Torrents(hashes: hashes));
        case 'reannounce':
          await qbittorrent.torrents
              .reannounceTorrents(torrents: Torrents(hashes: hashes));
        case 'recheck':
          await qbittorrent.torrents
              .recheckTorrents(torrents: Torrents(hashes: hashes));
        case 'resume':
          await qbittorrent.torrents
              .resumeTorrents(torrents: Torrents(hashes: hashes));
        case 'SuperSeeding':
          await qbittorrent.torrents.setSuperSeeding(
              torrents: Torrents(hashes: hashes), enable: enable);
        case 'AutoManagement':
          await qbittorrent.torrents.setAutoManagement(
              torrents: Torrents(hashes: hashes), enable: enable);
        case 'Category':
          await qbittorrent.torrents.setCategory(
              torrents: Torrents(hashes: hashes), category: category);
        case 'DownloadLimit':
          await qbittorrent.torrents.setDownloadLimit(
              torrents: Torrents(hashes: hashes), limit: limit);
        case 'UploadLimit':
          await qbittorrent.torrents
              .setUploadLimit(torrents: Torrents(hashes: hashes), limit: limit);
        case 'ForceStart':
          await qbittorrent.torrents.setForceStart(
              torrents: Torrents(hashes: hashes), enable: enable);
        case 'ShareLimit':
          await qbittorrent.torrents.setShareLimit(
              torrents: Torrents(hashes: hashes),
              ratioLimit: ratioLimit,
              seedingTimeLimit: seedingTimeLimit);
        case 'delete':
          await qbittorrent.torrents
              .deleteTorrents(torrents: Torrents(hashes: hashes));
        default:
          Get.snackbar('出错啦！', '未知操作：$command');
      }

      torrents.value = await qbittorrent.torrents
          .getTorrentsList(options: const TorrentListOptions());
      LoggerHelper.Logger.instance.w(torrents.length);
    } else {
      tr.Transmission transmission =
          downloadController.getTrInstance(downloader);
      switch (command) {
        case 'reannounce':
          transmission.v1.torrent.torrentReannounce(ids: hashes);
        case 'delete':
          transmission.v1.torrent
              .torrentRemove(ids: hashes, deleteLocalData: deleteFiles);
        case 'resume':
          transmission.v1.torrent.torrentStart(ids: hashes);
        case 'ForceStart':
          transmission.v1.torrent.torrentStartNow(ids: hashes);
        case 'pause':
          transmission.v1.torrent.torrentStop(ids: hashes);
        case 'recheck':
          transmission.v1.torrent.torrentVerify(ids: hashes);
        case 'uploadLimit':
          transmission.v1.torrent.torrentSet(
              tr.TorrentSetArgs().uploadLimited(true).uploadLimit(limit),
              ids: hashes);
        case 'downloadLimit':
          transmission.v1.torrent.torrentSet(
              tr.TorrentSetArgs().downloadLimited(true).downloadLimit(limit),
              ids: hashes);
        case 'ShareLimit':
          transmission.v1.torrent.torrentSet(
              tr.TorrentSetArgs().seedRatioLimit(limit as double),
              ids: hashes);
      }
    }
    getAllTorrents();
    update();
  }

  getTrFreeSpace() async {
    tr.Transmission transmission = downloadController.getTrInstance(downloader);
    LoggerHelper.Logger.instance.w(transmission.v1.rpc);

    var res = await transmission.v1.session
        .sessionGet(fields: tr.SessionArgs().downloadDir());
    LoggerHelper.Logger.instance.w(res['arguments']['download-dir']);

    Map response = await transmission.v1.system
        .freeSpace(path: res['arguments']['download-dir']);
    freeSpace.value =
        TrFreeSpace.fromJson(response['arguments'] as Map<String, dynamic>)
            .sizeBytes!;
  }

  getQbFreeSpace() async {
    QBittorrentApiV2 qb = await downloadController.getQbInstance(downloader);
    MainData m = await qb.sync.getMainData();
    freeSpace.value = m.serverState!.freeSpaceOnDisk!;
  }

  getFreeSpace() async {
    if (downloader.category.toLowerCase() == 'qb') {
      getQbFreeSpace();
    } else {
      getTrFreeSpace();
    }
  }
}
