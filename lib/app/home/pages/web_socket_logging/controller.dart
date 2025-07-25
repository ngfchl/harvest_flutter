import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/listener/event_listener.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../models/authinfo.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/flutter_client_sse.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/storage.dart';

class WebSocketLoggingController extends GetxController {
  List<String> logList = [];
  List<String> showLogList = [];
  String url = 'ws/logging';
  bool isLoading = false;
  bool wrapText = true;
  late StreamSubscription<SSEModel> subscription;
  ScrollController? scrollController;
  int filterLevel = 0;
  Map<String, int> levelList = {
    'ALL': 0,
    'DEBUG': 1,
    'INFO': 2,
    'WARNING': 3,
    'ERROR': 4,
    'CRITICAL': 5,
  };
  String baseUrl = SPUtil.getLocalStorage('server');
  late WebSocketChannel channel;
  GlobalKey inTimeAPILogFloatingKey =
      GlobalKey(debugLabel: "inTimeAPILogFloatingWindows");

  late Floating floating;
  var oneListener = FloatingEventListener();

  @override
  void onInit() async {
    Logger.instance.d(scrollController);

    scrollController = ScrollController();
    update();

    oneListener
      ..openListener = () async {
        Logger.instance.d('显示试试 API 日志');
        scrollController ??= ScrollController();
        update();
        await fetchingWebSocketLogList();
      }
      ..hideFloatingListener = () {
        // scrollController?.dispose();
        // scrollController = null;
      }
      ..closeListener = () {
        exit();
      };

    logList = [];
    updateLogs("开始打印日志");
    await fetchingWebSocketLogList();
    super.onInit();
  }

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

  fetchingWebSocketLogList() async {
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

  fetchingLogList() async {
    // 打开加载状态
    isLoading = true;
    update();
    // 准备基础数据
    try {
      Map userinfo = SPUtil.getMap('userinfo');
      AuthInfo authInfo = AuthInfo.fromJson(userinfo as Map<String, dynamic>);
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer ${authInfo.authToken}'
      };
      List<Future<void>> futures = [];
      // 打开 SSE 通道，开始搜索

      subscription = SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: '$baseUrl/api/option/logging',
        header: headers,
        body: {
          "limit": 1024,
          "interval": 1,
        },
      ).listen((event) async {
        Map<String, dynamic> jsonData = json.decode(event.data!);
        CommonResponse response = CommonResponse.fromJson(jsonData, (p0) => p0);
        if (response.succeed) {
          updateLogs(response.data);
        } else {
          updateLogs(response.msg.toString());
        }
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
    }
    update();
  }

  void updateLogs(dynamic msg) async {
    String type = msg.runtimeType.toString();
    Logger.instance.d(type);
    Logger.instance.d(msg);
    switch (type) {
      case "String":
        logList.add(msg);
        break;
      case "List<dynamic>":
        logList.addAll(List<String>.from(msg));
        break;
    }
    if (logList.length > 300) {
      logList = logList.sublist(logList.length - 300);
    }
    filterLogs();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        if (scrollController?.hasClients ?? false) {
          scrollController?.animateTo(
            scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
          await Future.delayed(const Duration(seconds: 2));
          scrollController?.animateTo(
            scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        Logger.instance.e(e.toString());
      }
    });

    update();
  }

  stopFetchLog() async {
    isLoading = false;
    // subscription.cancel();
    await channel.sink.close(status.normalClosure);
    // SSEClient.disableRetry();
    // SSEClient.unsubscribeFromSSE();
    update();
  }

  exit() {
    stopFetchLog();
    logList.clear();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void dispose() {
    // scrollController?.dispose();
    // scrollController = null;
    super.dispose();
  }

  @override
  void onClose() {
    scrollController?.dispose();
    scrollController = null;
    exit();
    super.onClose();
  }
}
