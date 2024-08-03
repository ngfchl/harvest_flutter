import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/utils/storage.dart';

import '../../../../utils/logger_helper.dart';
import 'controller.dart';

class LoggingPage extends StatelessWidget {
  LoggingPage({super.key});

  final controller = Get.put(LoggingController());

  @override
  Widget build(BuildContext context) {
    final GlobalKey webViewKey = GlobalKey();
    return Scaffold(
      body: GetBuilder<LoggingController>(builder: (controller) {
        return Column(
          children: [
            if (controller.progress < 100)
              LinearProgressIndicator(
                value: controller.progress / 100,
                backgroundColor: Colors.grey.withAlpha(33),
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      controller.currentLog = 'logging';
                      controller.switchLogging();
                    },
                    child: const Text('服务')),
                ElevatedButton(
                    onPressed: () {
                      controller.currentLog = 'taskList';
                      controller.switchLogging();
                    },
                    child: const Text('任务')),
                ElevatedButton(
                    onPressed: () {
                      controller.currentLog = 'taskLog';
                      controller.switchLogging();
                    },
                    child: const Text('Log')),
                ElevatedButton(
                    onPressed: () {
                      controller.currentLog = 'accessLog';
                      controller.switchLogging();
                    },
                    child: const Text('Web')),
              ],
            ),
            Expanded(
              child: CustomCard(
                child: InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: WebUri(controller.accessUrl)),
                  initialSettings: InAppWebViewSettings(
                    isInspectable: kDebugMode,
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    iframeAllow: "camera; microphone",
                    iframeAllowFullscreen: true,
                    defaultFontSize: 24,
                  ),
                  onWebViewCreated: (inAppWebViewController) async {
                    controller.webController = inAppWebViewController;
                    controller.isLoading = true;
                    controller.update();
                  },
                  onLoadStart: (inAppWebViewController, _) async {
                    controller.isLoading = true;
                    controller.update();
                  },
                  onLoadStop: (inAppWebViewController, webUri) async {
                    Logger.instance
                        .w((await inAppWebViewController.getTitle())!);
                    controller.isLoading = false;
                    if (!controller.accessUrl.contains('flower')) {
                      await controller.webController
                          ?.evaluateJavascript(source: """
                                      document.getElementsByTagName('body')[0].style.fontSize = '${controller.fontSize}px';
                                      document.getElementsByTagName('body')[0].style.lineHeight = '1.8';
                                      document.getElementsByTagName('pre')[0].style.wordWrap = 'break-word';
                                      document.getElementsByTagName('pre')[0].style.whiteSpace = 'pre-wrap';
                                    """);
                    }
                    controller.update();
                  },
                  onProgressChanged: (inAppWebViewController, progress) async {
                    Logger.instance.i('当前进度: $progress');
                    controller.progress = progress;
                    controller.update();
                  },
                  onReceivedError: (inAppWebViewController, _, err) {
                    // inAppWebViewController.reload();
                  },
                ),
              ),
            ),
            CustomCard(
              height: !controller.accessUrl.contains('flower') ? 105 : 56,
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Column(
                  children: [
                    if (!controller.accessUrl.contains('flower'))
                      Row(
                        children: [
                          Text('获取日志长度：${controller.logLength}'),
                          Expanded(
                            child: Slider(
                                min: 1,
                                max: 10,
                                value: controller.logLength / 1024,
                                onChanged: (value) {
                                  controller.logLength = value.toInt() * 1024;
                                  controller.switchLogging();
                                  controller.webController?.loadUrl(
                                      urlRequest: URLRequest(
                                          url: WebUri(controller.accessUrl)));
                                }),
                          ),
                        ],
                      ),
                    Row(
                      children: [
                        Text('页面字体大小：${controller.fontSize}'),
                        Expanded(
                          child: Slider(
                              min: 12,
                              max: 36,
                              value: controller.fontSize / 1,
                              onChanged: (value) async {
                                controller.fontSize = value.toInt();
                                SPUtil.setLocalStorage(
                                    'loggingFontSize', controller.fontSize);
                                controller.update();
                                // 初始化时或页面加载完成后设置字体大小
                                var res = await controller.webController
                                    ?.evaluateJavascript(source: """
                                        document.getElementsByTagName('body')[0].style.fontSize = '${controller.fontSize}px';
                                      """);
                                Logger.instance.i(res.toString());
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30)
          ],
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              await controller.webController?.reload();
            },
            icon: Icon(Icons.cached_sharp,
                size: 28, color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
