import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart' as tr;

import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../models/common_response.dart';
import '../../models/download.dart';
import '../home/pages/models/transmission.dart';
import 'models/transmission_base_torrent.dart';

class TorrentController extends GetxController {
  late Downloader downloader;
  dynamic client;
  final torrents = [].obs;
  final showTorrents = [].obs;
  final categories = <Map<String, String>>[].obs;
  final category = 'all_torrents'.obs;
  Timer? periodicTimer;
  RxBool isTimerActive = true.obs; // 使用 RxBool 控制定时器是否激活
  final sortKey = 'name'.obs;
  final sortReversed = false.obs;
  bool realTimeState = true;
  final searchController = TextEditingController().obs;
  final searchKey = ''.obs;
  final statusList = RxList().obs;
  final freeSpace = 1.obs;
  final timerDuration = 3.14.obs;
  final duration = 3.14.obs;
  bool isLoading = false;
  Rx<TorrentState?> torrentState = Rx<TorrentState?>(null);
  Rx<int?> trTorrentState = Rx<int?>(null);
  Rx<TorrentFilter> torrentFilter = Rx<TorrentFilter>(TorrentFilter.all);
  Map<String, String> categoryList = {};

  TorrentController(this.downloader, this.realTimeState);

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
  void onInit() async {
    await initClient();
    await getAllCategory();

    getFreeSpace();
    getAllTorrents();
    if (realTimeState) {
      startPeriodicTimer();

      Timer(Duration(seconds: (timerDuration * 60).toInt()), () {
        // 定时器触发后执行的操作，这里可以取消periodicTimer、关闭资源等
        periodicTimer?.cancel();
        // 你可以在这里添加其他需要在定时器触发后执行的逻辑
      });
    }
    super.onInit();
  }

  initClient() async {
    if (downloader.category.toLowerCase() == 'qb') {
      client = await getQbInstance(downloader);
    } else {
      client = getTrInstance(downloader);
    }
  }

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(
        Duration(milliseconds: (duration * 1000).toInt()), (Timer t) async {
      // 在定时器触发时获取最新的下载器数据
      getAllTorrents();
      getFreeSpace();

      dynamic status = await getIntervalSpeed(downloader);
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
    if (periodicTimer!.isActive) {
      periodicTimer?.cancel();
    }
    isTimerActive.value = false;
    update();
  }

  @override
  void onClose() {
    if (periodicTimer != null) periodicTimer?.cancel();
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
    if (client == null) {
      await initClient();
    }
    if (downloader.category.toLowerCase() == 'qb') {
      categories.value = <Map<String, String>>[
        {'name': '全部', 'value': 'all_torrents'},
        {'name': '未分类', 'value': ''},
      ];

      Map<String, Category> cList = await client.torrents.getCategories();
      if (cList.isEmpty) {
        await getAllTorrents();
        categoryList =
            torrents.map((element) => element.savePath).fold({}, (map, el) {
          map[el] = el;
          return map;
        });
        ;
      } else {
        categoryList = cList.values.fold({}, (map, element) {
          map[element.name!] = element.savePath ?? '';
          return map;
        });
      }
      categories.addAll(
          categoryList.keys.map((e) => {'name': e, 'value': e}).toList());

      // LoggerHelper.Logger.instance.w(categories);
    } else {
      Set<Map<String, String>> uniqueCategories = {
        {'name': '全部', 'value': 'all_torrents'}
      };
      // 取全部
      if (torrents.isEmpty) {
        await getAllTorrents();
      }
      List<String> dirs = torrents
          .map((element) =>
              element.downloadDir!.replaceAll(RegExp(r'\/$'), '').toString())
          .toSet()
          .toList();
      LoggerHelper.Logger.instance.w(dirs);
      uniqueCategories
          .addAll(dirs.map((e) => {'name': e.split('/').last, 'value': e}));
      // 去重
      categoryList = dirs.fold({}, (map, element) {
        map[element.split('/').last] = element;
        return map;
      });
      // LoggerHelper.Logger.instance.w('TR 路径：${uniqueCategories.length}');

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

    // LoggerHelper.Logger.instance.w('状态：$selectedState');
    if (selectedState != null) {
      showTorrents.value = showTorrents
          .where((torrent) => isQbCategory
              ? torrent.state == selectedState
              : torrent.status == selectedState)
          .toList();
    }
  }

  filterTorrentsBySearchKey() {
    // LoggerHelper.Logger.instance.w('搜索关键字：${searchKey.value}');

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
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByCategory();
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsByState();
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    filterTorrentsBySearchKey();
    // LoggerHelper.Logger.instance.w(showTorrents.length);
    update();
  }

  Future<void> getAllTorrents() async {
    if (downloader.category.toLowerCase() == 'qb') {
      torrents.value = await client.torrents.getTorrentsList(
        options: TorrentListOptions(
            // category: category.value != 'all_torrents' ? category.value : null,
            // sort: TorrentSort.name,
            filter: torrentFilter.value),
      );
    } else {
      Map res = await client.v1.torrent.torrentGet(
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

      // LoggerHelper.Logger.instance.w(res['arguments']["torrents"][0]);
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
      switch (command) {
        case 'pause':
          await client.torrents
              .pauseTorrents(torrents: Torrents(hashes: hashes));
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
          await client.torrents.setDownloadLimit(
              torrents: Torrents(hashes: hashes), limit: limit);
        case 'UploadLimit':
          await client.torrents
              .setUploadLimit(torrents: Torrents(hashes: hashes), limit: limit);
        case 'ForceStart':
          await client.torrents.setForceStart(
              torrents: Torrents(hashes: hashes), enable: enable);
        case 'ShareLimit':
          await client.torrents.setShareLimit(
              torrents: Torrents(hashes: hashes),
              ratioLimit: ratioLimit,
              seedingTimeLimit: seedingTimeLimit);
        case 'delete':
          await client.torrents
              .deleteTorrents(torrents: Torrents(hashes: hashes));
        default:
          Get.snackbar('出错啦！', '未知操作：$command');
      }

      torrents.value = await client.torrents
          .getTorrentsList(options: const TorrentListOptions());
      LoggerHelper.Logger.instance.w(torrents.length);
    } else {
      switch (command) {
        case 'reannounce':
          client.v1.torrent.torrentReannounce(ids: hashes);
        case 'delete':
          client.v1.torrent
              .torrentRemove(ids: hashes, deleteLocalData: deleteFiles);
        case 'resume':
          client.v1.torrent.torrentStart(ids: hashes);
        case 'ForceStart':
          client.v1.torrent.torrentStartNow(ids: hashes);
        case 'pause':
          client.v1.torrent.torrentStop(ids: hashes);
        case 'recheck':
          client.v1.torrent.torrentVerify(ids: hashes);
        case 'uploadLimit':
          client.v1.torrent.torrentSet(
              tr.TorrentSetArgs().uploadLimited(true).uploadLimit(limit),
              ids: hashes);
        case 'downloadLimit':
          client.v1.torrent.torrentSet(
              tr.TorrentSetArgs().downloadLimited(true).downloadLimit(limit),
              ids: hashes);
        case 'ShareLimit':
          client.v1.torrent.torrentSet(
              tr.TorrentSetArgs().seedRatioLimit(limit as double),
              ids: hashes);
      }
    }
    getAllTorrents();
    update();
  }

  getTrFreeSpace() async {
    var res = await client.v1.session
        .sessionGet(fields: tr.SessionArgs().downloadDir());
    // LoggerHelper.Logger.instance.w(res['arguments']['download-dir']);

    Map response = await client.v1.system
        .freeSpace(path: res['arguments']['download-dir']);
    freeSpace.value =
        TrFreeSpace.fromJson(response['arguments'] as Map<String, dynamic>)
            .sizeBytes!;
  }

  getQbFreeSpace() async {
    MainData m = await client.sync.getMainData();
    freeSpace.value = m.serverState!.freeSpaceOnDisk!;
  }

  getFreeSpace() async {
    if (downloader.category.toLowerCase() == 'qb') {
      getQbFreeSpace();
    } else {
      getTrFreeSpace();
    }
  }

  Map<String, String> cookieStringToMap(String cookieString) {
    // 分割Cookie字符串以获得各个键值对
    List<String> pairs = cookieString.split('; ');

    Map<String, String> cookieMap = {};
    for (String pair in pairs) {
      // 在键值对中找到等号位置
      int eqIndex = pair.indexOf('=');

      // 如果找到了等号，则分割键和值
      if (eqIndex != -1) {
        String key = pair.substring(0, eqIndex).trim();
        String value = pair.substring(eqIndex + 1).trim();

        // 将键值对添加到Map中
        cookieMap[key] = value;
      } else if (pair.isNotEmpty) {
        // 有时可能存在没有等号的键（例如，安全选项）
        cookieMap[pair.trim()] = '';
      }
    }

    return cookieMap;
  }

  /// 获取磁力链接的种子文件Bytes
  /// @param downloadUrl 磁力链接
  /// @returns 种子文件Bytes
  Future<CommonResponse<FileBytes>> getDownloadFileBytes(
      String downloadUrl, String cookie, String userAgent) async {
    try {
      String filePath =
          '${(await getApplicationDocumentsDirectory()).path}/download.torrent';
      final response = await Dio().download(
        downloadUrl,
        filePath,
        options: Options(responseType: ResponseType.bytes, headers: {
          "Cookie": cookieStringToMap(cookie),
          "User-Agent": userAgent
        }),
      );
      LoggerHelper.Logger.instance.i(response.statusCode);
      LoggerHelper.Logger.instance.i(response.headers);
      if (response.statusCode == 200) {
        String? filename = response.headers.map['content-disposition']?.first
            .split('filename=')[1];
        if (filename != null && filename.isNotEmpty) {
          print('Default filename: $filename');
        } else {
          print('No default filename found in headers');
          filename = 'defaultFileName.torrent';
        }
        Uint8List fileBytes =
            Uint8List.fromList(await File(filePath).readAsBytes());
        FileBytes file = FileBytes(filename: filename, bytes: fileBytes);
        LoggerHelper.Logger.instance.i(file.filename);
        return CommonResponse.success(data: file);
      } else {
        String msg = '下载种子文件失败！${response.statusCode}';
        LoggerHelper.Logger.instance.i(msg);
        return CommonResponse.error(msg: msg);
      }
    } catch (e, trace) {
      String msg = '下载种子文件失败！$e';
      LoggerHelper.Logger.instance.i(msg);
      LoggerHelper.Logger.instance.i(trace);
      return CommonResponse.error(msg: msg);
    }
  }

  Future<CommonResponse> addTorrentFilesToQb(
    Downloader downloader,
    Map<String, dynamic> data,
  ) async {
    MySite mySite = data['mySite'];
    try {
      final downloadResponse = await getDownloadFileBytes(
        data['magnet'],
        mySite.cookie!,
        mySite.userAgent!,
      );

      String msg;
      NewTorrents torrents;

      if (downloadResponse.code != 0) {
        msg = '种子文件下载失败，使用下载链接进行下载...';
        torrents = NewTorrents.urls(
          urls: [data["magnet"]],
          savePath: data['savePath'],
          cookie: data['cookie'],
          category: data['category'],
          paused: data['paused'],
          rootFolder: data['rootFolder'],
          rename: data['rename'],
          upLimit: data['upLimit'],
          dlLimit: data['dlLimit'],
          ratioLimit: data['ratioLimit'].toDouble(),
          autoTMM: data['autoTMM'],
          firstLastPiecePrio: data['firstLastPiecePrio'],
        );
      } else {
        msg = '种子文件下载成功，已推送到下载队列...';
        torrents = NewTorrents.bytes(
          bytes: [downloadResponse.data!],
          savePath: data['savePath'],
          category: data['category'],
          paused: data['paused'],
          rootFolder: data['rootFolder'],
          rename: data['rename'],
          upLimit: data['upLimit'],
          dlLimit: data['dlLimit'],
          ratioLimit: data['ratioLimit'].toDouble(),
          autoTMM: data['autoTMM'],
          firstLastPiecePrio: data['firstLastPiecePrio'],
        );
      }

      LoggerHelper.Logger.instance.i(msg);
      await client.torrents.addNewTorrents(
        torrents: torrents,
      );

      return CommonResponse.success(msg: '添加下载任务成功！$msg');
    } on QBittorrentException catch (e) {
      String msg =
          '推送种子文件失败，使用下载链接进行下载，请检查下载器！${e.statusCode} ${e.statusMessage}';
      LoggerHelper.Logger.instance.e(e.runtimeType);
      LoggerHelper.Logger.instance.e(e);
      LoggerHelper.Logger.instance.e(msg);

      await client.torrents.addNewTorrents(
        torrents: NewTorrents.urls(
          urls: [data["magnet"]],
          savePath: data['savePath'],
          cookie: data['cookie'],
          category: data['category'],
          paused: data['paused'],
          rootFolder: data['rootFolder'],
          rename: data['rename'],
          upLimit: data['upLimit'],
          dlLimit: data['dlLimit'],
          ratioLimit: data['ratioLimit'].toDouble(),
          autoTMM: data['autoTMM'],
          firstLastPiecePrio: data['firstLastPiecePrio'],
        ),
      );

      return CommonResponse.error(msg: msg);
    } catch (e) {
      String msg = '添加下载任务失败！$e';
      return CommonResponse.error(msg: msg);
    }
  }

  Future getQbSpeed(Downloader downloader) async {
    try {
      TransferInfo res = await client.transfer.getGlobalTransferInfo();
      return CommonResponse(data: res, code: 0);
    } catch (e, trace) {
      LoggerHelper.Logger.instance.e(trace);
      return CommonResponse(
        code: -1,
        data: null,
        msg: '${downloader.name} 获取实时信息失败！',
      );
    }
  }

  Future<QBittorrentApiV2> getQbInstance(Downloader downloader) async {
    final qbittorrent = QBittorrentApiV2(
      baseUrl: '${downloader.protocol}://${downloader.host}:${downloader.port}',
      cookiePath: (await getApplicationDocumentsDirectory()).path,
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

  Future getTrSpeed(Downloader downloader) async {
    var res = await client.v1.session.sessionStats();
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

  tr.Transmission getTrInstance(Downloader downloader) {
    final transmission = tr.Transmission(
        '${downloader.protocol}://${downloader.host}:${downloader.port}',
        tr.AuthKeys(downloader.username, downloader.password),
        logConfig: const tr.ConfigLogger.showNone());
    return transmission;
  }

  dynamic getIntervalSpeed(Downloader downloader) {
    return downloader.category == 'Qb'
        ? getQbSpeed(downloader)
        : getTrSpeed(downloader);
  }
}
