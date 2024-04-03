import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/utils/logger_helper.dart';

import 'controller.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final controller = Get.find<WebViewPageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<WebViewPageController>(builder: (controller) {
        final GlobalKey webViewKey = GlobalKey();
        InAppWebViewController? webController;
        String domain = Uri.parse(controller.mySite.mirror!).host;
        List<String> cookieList =
            controller.mySite.cookie!.split(';').map((item) {
          return "document.cookie='$item;domain=$domain;'";
        }).toList();
        UserScript cookieScript = UserScript(
          source: cookieList.join("\n"),
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        );

        // Logger.instance.i(cookieList);
        InAppWebViewSettings settings = InAppWebViewSettings(
          isInspectable: kDebugMode,
          mediaPlaybackRequiresUserGesture: false,
          allowsInlineMediaPlayback: true,
          iframeAllow: "camera; microphone",
          userAgent: controller.mySite.userAgent,
          iframeAllowFullscreen: true,
        );
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(controller.pageTitle.value),
              actions: [
                GFIconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    webController?.reload();
                  },
                  type: GFButtonType.transparent,
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                        url: WebUri(controller.url),
                        headers: {"Cookie": controller.mySite.cookie!}),
                    initialSettings: settings,
                    initialUserScripts:
                        UnmodifiableListView<UserScript>([cookieScript]),
                    onWebViewCreated: (inAppWebViewController) async {
                      webController = inAppWebViewController;
                    },
                    onLoadStart: (inAppWebViewController, _) async {},
                    onLoadStop: (inAppWebViewController, webUri) async {
                      Logger.instance
                          .w((await inAppWebViewController.getTitle())!);
                    },
                    onProgressChanged:
                        (inAppWebViewController, progress) async {
                      Logger.instance.i('当前进度: $progress');
                    },
                    onReceivedError: (inAppWebViewController, _, err) {
                      // inAppWebViewController.reload();
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: GFIconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                Get.bottomSheet(Container(
                  color: Colors.blueGrey.shade300,
                  height: 500,
                  width: double.infinity,
                  child: const Text('下载器列表'),
                ));
              },
            ),
          ),
        );
      }),
    );
  }
}
