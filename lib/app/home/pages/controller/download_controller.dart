import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:transmission_api/transmission_api.dart';

import '../../../../api/downloader.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart' as LoggerHelper;
import '../../../../utils/storage.dart';
import '../../home_controller.dart';
import '../models/transmission.dart';

class DownloadController extends GetxController {
  bool isLoaded = false;
  RxList<Downloader> dataList = <Downloader>[].obs;
  RxBool isTimerActive = true.obs; // 使用 RxBool 控制定时器是否激活
  final duration = 3.14.obs;
  final timerDuration = 3.14.obs;
  late Timer periodicTimer;
  late Timer fiveMinutesTimer;
  final isDurationValid = true.obs;
  final HomeController homeController = Get.find<HomeController>();

  // 使用StreamController来管理下载状态的流
  final StreamController<List<Downloader>> _downloadStreamController =
      StreamController<List<Downloader>>.broadcast();

  // 提供获取下载状态流的方法
  Stream<List<Downloader>> get downloadStream =>
      _downloadStreamController.stream;

  Map<int, dynamic> speedInfo = {};

  @override
  void onInit() {
    duration.value = SPUtil.getDouble('duration', defaultValue: 3.14)!;
    timerDuration.value =
        SPUtil.getDouble('timerDuration', defaultValue: 3.14)!;
    homeController.initDio();
    getDownloaderListFromServer();
    refreshDownloadStatus();
    // 设置定时器，每隔一定时间刷新下载器数据
    startPeriodicTimer();
    // 设置一个5分钟后执行的定时器
    timerToStop();
    LoggerHelper.Logger.instance.w(periodicTimer);

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

  void startPeriodicTimer() {
    // 设置定时器，每隔一定时间刷新下载器数据
    periodicTimer = Timer.periodic(
        Duration(milliseconds: (duration * 1000).toInt()), (Timer t) {
      // 在定时器触发时获取最新的下载器数据
      refreshDownloadStatus();
    });
    isTimerActive.value = true;
    update();
  }

  // 取消定时器
  void cancelPeriodicTimer() {
    if (periodicTimer.isActive) {
      periodicTimer.cancel();
    }
    isTimerActive.value = false;
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
    getDownloaderList().then((value) {
      if (value.code == 0) {
        dataList.value = value.data;
        isLoaded = true;
        _downloadStreamController.add(dataList.toList());
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('', e.toString());
    });
    // 发送最新的下载列表到流中
    refreshDownloadStatus();

    update();
  }

  Future<CommonResponse> testConnect(Downloader downloader) async {
    try {
      // LoggerHelper.Logger.instance.i(downloader.name);
      if (downloader.category.toLowerCase() == 'qb') {
        await getQbInstance(downloader);
        return CommonResponse(
            data: true, msg: '${downloader.name} 连接成功!', code: 0);
      } else {
        Transmission transmission = getTrInstance(downloader);
        await transmission.v1.session.sessionStats();
        // LoggerHelper.Logger.instance.w(res);
        return CommonResponse(
            data: true, msg: '${downloader.name} 连接成功!', code: 0);
      }
    } catch (error) {
      return CommonResponse(
          data: false, msg: '${downloader.name} 连接失败!', code: -1);
    }
  }

  Future getQbSpeed(Downloader downloader) async {
    try {
      QBittorrentApiV2 qbittorrent = await getQbInstance(downloader);
      TransferInfo res = await qbittorrent.transfer.getGlobalTransferInfo();
      return CommonResponse(data: res, code: 0);
    } catch (e, trace) {
      LoggerHelper.Logger.instance.w(trace);
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
      logger: false,
    );
    await qbittorrent.auth.login(
      username: downloader.username,
      password: downloader.password,
    );
    return qbittorrent;
  }

  Future getTrSpeed(Downloader downloader) async {
    Transmission transmission = getTrInstance(downloader);
    var res = await transmission.v1.session.sessionStats();
    // LoggerHelper.Logger.instance.w(res);
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

  Transmission getTrInstance(Downloader downloader) {
    final transmission = Transmission(
        '${downloader.protocol}://${downloader.host}:${downloader.port}',
        AuthKeys(downloader.username, downloader.password),
        logConfig: const ConfigLogger.showNone());
    return transmission;
  }

  dynamic getIntervalSpeed(Downloader downloader) {
    return downloader.category == 'Qb'
        ? getQbSpeed(downloader)
        : getTrSpeed(downloader);
  }

  @override
  void onClose() {
    // 关闭StreamController以避免内存泄漏
    _downloadStreamController.close();
    super.onClose();
  }

  void validateInput(String input, {double min = 3, double max = 10}) {
    try {
      double parsedValue = double.parse(input);
      isDurationValid.value = parsedValue >= 3 && parsedValue <= 10;
    } catch (e) {
      isDurationValid.value = false;
    }
    update();
  }

  saveDownloaderToServer(Downloader downloader) async {
    CommonResponse response;
    if (downloader.id != 0) {
      response = await editDownloader(downloader);
    } else {
      response = await saveDownloader(downloader);
    }
    if (response.code == 0) {
      Get.snackbar(
        '保存成功！',
        response.msg!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 3),
      );
      return true;
    } else {
      Get.snackbar(
        '保存出错啦！',
        response.msg!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
  }
}
