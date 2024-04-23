import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/api/mysite.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/pages/agg_search/download_form.dart';
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
    final GlobalKey webViewKey = GlobalKey();
    InAppWebViewController? webController;
    final cookieManager = CookieManager.instance();
    String domain = Uri.parse(controller.url).host;
    List<String> cookieList = controller.mySite != null
        ? controller.mySite!.cookie!.split(';').map((item) {
            return "document.cookie='$item;domain=$domain;'";
          }).toList()
        : [];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(
          controller.pageTitle.value,
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          if (controller.info != null)
            GFIconButton(
              icon: const Icon(
                Icons.link_outlined,
                size: 24,
              ),
              onPressed: () async {
                Uri uri = Uri.parse(controller.info!.magnetUrl);
                if (!await launchUrl(uri)) {
                  Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
                }
              },
              type: GFButtonType.transparent,
            ),
          if (controller.info != null)
            GFIconButton(
              icon: const Icon(
                Icons.download_outlined,
                size: 24,
              ),
              onPressed: () {
                openDownloaderListSheet(context, controller.info!);
              },
              type: GFButtonType.transparent,
            ),
          GFIconButton(
            icon: const Icon(
              Icons.travel_explore_outlined,
              size: 24,
            ),
            onPressed: () async {
              Uri uri = Uri.parse(controller.url);
              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？');
              }
            },
            type: GFButtonType.transparent,
          ),
          if (controller.mySite != null)
            GFIconButton(
              icon: const Icon(
                Icons.cookie_outlined,
                size: 24,
              ),
              onPressed: () async {
                List<Cookie> cookies =
                    await cookieManager.getCookies(url: WebUri(controller.url));
                String cookieStr =
                    cookies.map((e) => '${e.name}=${e.value}').join('; ');
                Logger.instance.w(cookieStr);
                controller.mySite?.cookie = cookieStr;
                final response = await editMySite(controller.mySite!);
                if (response.code == 0) {
                  Get.snackbar(
                    '保存成功！',
                    response.msg!,
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.green.shade400,
                    duration: const Duration(seconds: 3),
                  );
                } else {
                  Get.snackbar(
                    '保存出错啦！',
                    response.msg!,
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.red.shade400,
                    duration: const Duration(seconds: 3),
                  );
                }
              },
              type: GFButtonType.transparent,
            ),
          GFIconButton(
            icon: const Icon(
              Icons.refresh,
              size: 24,
            ),
            onPressed: () {
              webController?.reload();
            },
            type: GFButtonType.transparent,
          ),
          GetBuilder<WebViewPageController>(builder: (controller) {
            return controller.isLoading
                ? const GFLoader(
                    size: GFSize.SMALL,
                  )
                : const SizedBox.shrink();
          }),
          const SizedBox(width: 10)
        ],
      ),
      body: GetBuilder<WebViewPageController>(builder: (controller) {
        return Column(
          children: [
            if (controller.progress < 100)
              LinearProgressIndicator(
                value: controller.progress / 100,
                backgroundColor: Colors.grey.withAlpha(33),
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
              ),
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                    url: WebUri(controller.url),
                    headers: {
                      "Cookie": controller.mySite != null
                          ? controller.mySite!.cookie!
                          : ''
                    }),
                initialSettings: InAppWebViewSettings(
                  isInspectable: kDebugMode,
                  mediaPlaybackRequiresUserGesture: false,
                  allowsInlineMediaPlayback: true,
                  iframeAllow: "camera; microphone",
                  userAgent: controller.mySite != null
                      ? controller.mySite?.userAgent
                      : 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
                  iframeAllowFullscreen: true,
                ),
                initialUserScripts: UnmodifiableListView<UserScript>([
                  UserScript(
                    source: cookieList.join("\n"),
                    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  )
                ]),
                onWebViewCreated: (inAppWebViewController) async {
                  webController = inAppWebViewController;
                  controller.isLoading = true;
                  controller.update();
                },
                onLoadStart: (inAppWebViewController, _) async {
                  controller.isLoading = true;
                  controller.update();
                },
                onLoadStop: (inAppWebViewController, webUri) async {
                  Logger.instance.w((await inAppWebViewController.getTitle())!);
                  controller.isLoading = false;
                  controller.canGoBack =
                      await inAppWebViewController.canGoBack();
                  controller.canGoForward =
                      await inAppWebViewController.canGoForward();
                  controller.pageTitle.value =
                      (await inAppWebViewController.getTitle()) ?? '';
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
          ],
        );
      }),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton:
          GetBuilder<WebViewPageController>(builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (controller.canGoBack)
              GFIconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  webController?.goBack();
                },
              ),
            if (controller.canGoForward)
              GFIconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  webController?.goForward();
                },
              ),
          ],
        );
      }),
    );
  }
}
