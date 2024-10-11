import 'dart:async';

import 'package:get/get.dart'; // ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart' as tr;

import '../../../../api/downloader.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../../utils/storage.dart';
import '../models/transmission.dart';

class DownloadController extends GetxController {
  bool isLoaded = false;
  List<Downloader> dataList = <Downloader>[];
  List<String> pathList = <String>[];
  bool isTimerActive = true; // 使用 RxBool 控制定时器是否激活
  double duration = 3.14;
  double timerDuration = 3.14;
  Timer? periodicTimer;
  Timer? fiveMinutesTimer;
  bool isDurationValid = true;
  bool realTimeState = true;

  DownloadController(this.realTimeState);

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
    if (realTimeState) {
      LoggerHelper.Logger.instance.d('调用刷新 init');
      refreshDownloadStatus();
      // 设置定时器，每隔一定时间刷新下载器数据
      startPeriodicTimer();
      // 设置一个5分钟后执行的定时器
      timerToStop();
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
      LoggerHelper.Logger.instance.d('调用刷新 timer');

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
      LoggerHelper.Logger.instance.e('Error fetching download status: $e');
    }
  }

  Future<void> refreshDownloadStatus() async {
    LoggerHelper.Logger.instance.i('开始刷新下载器状态');
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
      LoggerHelper.Logger.instance.d('调用刷新 list');

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
      return CommonResponse(data: stats, code: 0);
    }
    return CommonResponse(
      code: -1,
      data: res,
      msg: '${downloader.name} 获取实时信息失败！',
    );
  }

  dynamic getIntervalSpeed(Downloader downloader) async {
    return downloader.category == 'Qb'
        ? await getQbSpeed(downloader)
        : await getTrSpeed(downloader);
  }

  Future getQbSpeed(Downloader downloader) async {
    try {
      final client = await getQbInstance(downloader);
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

  Future<CommonResponse> testConnect(Downloader downloader) async {
    try {
      // LoggerHelper.Logger.instance.i(downloader.name);
      if (downloader.category.toLowerCase() == 'qb') {
        await getQbInstance(downloader);
        return CommonResponse(
            data: true, msg: '${downloader.name} 连接成功!', code: 0);
      } else {
        await getTrInstance(downloader);
        return CommonResponse(
            data: true, msg: '${downloader.name} 连接成功!', code: 0);
      }
    } catch (error) {
      return CommonResponse(
          data: false, msg: '${downloader.name} 连接失败!', code: -1);
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
