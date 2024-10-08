import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../../utils/logger_helper.dart' as logger_helper;
import '../../../../utils/storage.dart';

class LoggingController extends GetxController {
  int progress = 0;
  bool isLoading = false;
  String baseUrl = '${SPUtil.getLocalStorage('server')}';
  String accessUrl = '';
  String currentLog = '';
  int logLength = 2048;
  int fontSize = 20;
  InAppWebViewController? webController;
  bool shouldScrollToBottom = true;
  Level filterLevel = Level.info;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    fontSize = SPUtil.getLocalStorage('loggingFontSize') ?? 20;
    accessUrl = '$baseUrl/supervisor';
    logger_helper.memoryLogOutput.logsNotifier.addListener(onNewLog);
    scrollController.addListener(onScroll);
    // localLogs = await readFile();
    super.onInit();
  }

  onScroll() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == 0) {
        shouldScrollToBottom = false;
      } else {
        shouldScrollToBottom = true;
      }
    } else {
      shouldScrollToBottom = false;
    }
    update();
  }

  onNewLog() {
    if (shouldScrollToBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
    }
    update();
  }

  clearLogs() {
    logger_helper.memoryLogOutput.clearLogs();
    update();
  }

  setLogLevel(Level level) {
    filterLevel = level;
    update();
  }

  Future<List<String>> readFile() async {
    // 获取应用文档目录
    final filePath = '${Directory.systemTemp.path}/log.txt';
    final file = File(filePath);
    // 读取文件
    List<String> contents = await file.readAsLines();
    return contents;
  }

  switchLogging() async {
    switch (currentLog) {
      case 'logging':
        accessUrl = '$baseUrl/supervisor';
        break;
      case 'accessLog':
        accessUrl =
            '$baseUrl/supervisor/tail.html?processname=uvicorn&limit=$logLength';
        break;
      case 'taskLog':
        accessUrl =
            '$baseUrl/supervisor/tail.html?processname=celery-worker&limit=$logLength';
        break;
      case 'taskList':
        accessUrl = '$baseUrl/flower/tasks';
        break;
    }
    await webController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(accessUrl)));
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
}
