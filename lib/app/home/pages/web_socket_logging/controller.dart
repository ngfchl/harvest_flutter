import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';

class WebSocketLoggingController extends GetxController {
  List<String> logList = [];
  List<String> showLogList = [];
  String url = 'ws/logging';
  bool isLoading = false;
  bool wrapText = true;
  late WebSocketChannel channel;
  ScrollController scrollController = ScrollController();
  int filterLevel = 0;
  Map<String, int> levelList = {
    'ALL': 0,
    'DEBUG': 1,
    'INFO': 2,
    'WARNING': 3,
    'ERROR': 4,
    'CRITICAL': 5,
  };

  changeLogLevel(int level) {
    filterLevel = level;
    // todo 后端返回日志格式需要处理
    // filterLogs();
    update();
  }

  filterLogs() {
    switch (filterLevel) {
      case 0:
        showLogList = logList;
        break;
      default:
        showLogList = logList.where((line) {
          // 提取日志行的开头部分
          String logPrefix = line.split(' ').first;
          int? logLevel = levelList[logPrefix];
          if (logLevel == null) {
            print('Unknown log level: $logPrefix');
            return true;
          }
          return logLevel >= filterLevel;
        }).toList();
    }
    update();
  }

  fetchingLogList() async {
    // 打开加载状态
    isLoading = true;
    update();
    try {
      String baseUrl = SPUtil.getLocalStorage('server');
      final wsUrl =
          Uri.parse('${baseUrl.replaceFirst('http', 'ws')}/api/ws/logging');
      channel = WebSocketChannel.connect(wsUrl);
      await channel.ready;
      channel.sink.add(json.encode({"limit": 1024, "interval": 1}));
      channel.stream.listen((message) {
        CommonResponse response =
            CommonResponse.fromJson(json.decode(message), (p0) => p0);
        Logger.instance.i(response.msg);
        if (response.code == 0) {
          updateLogs(response.data);
        } else {
          updateLogs(response.msg.toString());
        }
        Logger.instance.d(logList);
      }, onError: (err) {
        Logger.instance.e('读取日志出错啦： ${err.toString()}');
        stopFetchLog();
      }, onDone: () {
        Logger.instance.e('日志读取完成啦！');
        // cancelSearch();
      });
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.d(trace);
      stopFetchLog();
    }
  }

  void updateLogs(dynamic msg)async {
    String type = msg.runtimeType.toString();
    Logger.instance.d(type);
    switch (type) {
      case "String":
        logList.add(msg);
        break;
      case "List<dynamic>":
        logList.addAll(List<String>.from(msg));
        break;
    }
    filterLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
        await Future.delayed(const Duration(seconds: 2));
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });

    update();
  }

  stopFetchLog() {
    isLoading = false;
    channel.sink.close();
    update();
  }

  @override
  void onInit() async {
    logList = [];
    updateLogs("开始打印日志");
    await fetchingLogList();
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void dispose() {
    stopFetchLog();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void onClose() {
    logList.clear();
    stopFetchLog();
    super.onClose();
  }
}
