import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';

class WebSocketLoggingController extends GetxController {
  List<String> logList = [];
  String url = 'ws/logging';
  bool isLoading = false;
  bool wrapText = true;
  late WebSocketChannel channel;
  ScrollController scrollController = ScrollController();

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
        cancelSearch();
      }, onDone: () {
        Logger.instance.e('日志读取完成啦！');
        // cancelSearch();
      });
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.d(trace);
      cancelSearch();
    }
  }

  void updateLogs(dynamic msg) {
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

    if (logList.length > 12) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      });
    }
    update();
  }

  cancelSearch() {
    isLoading = false;
    channel.sink.close();
    update();
  }

  @override
  void onInit() async {
    logList = [];
    Future.delayed(const Duration(seconds: 2));
    update();
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
    cancelSearch();
    super.dispose();
  }

  @override
  void onClose() {
    logList.clear();
    cancelSearch();
    super.onClose();
  }
}
