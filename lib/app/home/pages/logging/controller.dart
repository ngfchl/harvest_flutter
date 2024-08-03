import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

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

  @override
  void onInit() {
    fontSize = SPUtil.getLocalStorage('loggingFontSize') ?? 20;
    accessUrl = '${baseUrl}logging';
    super.onInit();
  }

  connectAccessLog() {
    accessUrl =
        '${baseUrl}logging/tail.html?processname=uvicorn&limit=$logLength';
  }

  connectTaskLog() {
    accessUrl =
        '$baseUrl/supervisor/tail.html?processname=celery-worker&limit=$logLength';
  }

  connectTaskList() {
    accessUrl = '$baseUrl/flower/tasks';
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
