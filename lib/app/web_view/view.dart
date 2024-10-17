import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/api/mysite.dart';
import 'package:harvest/app/home/pages/agg_search/models/torrent_info.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import '../home/pages/agg_search/download_form.dart';
import 'controller.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final controller = Get.find<WebViewPageController>();
  InAppWebViewController? webController;

  @override
  Widget build(BuildContext context) {
    final GlobalKey webViewKey = GlobalKey();
    final cookieManager = CookieManager.instance();

    String domain = Uri.parse(controller.url).host;
    List<String> cookieList = controller.mySite != null
        ? controller.mySite!.cookie!.split(';').map((item) {
            return "document.cookie='$item;domain=$domain;'";
          }).toList()
        : [];
    Map<String, String> headers = {
      "Cookie": controller.mySite != null ? controller.mySite!.cookie! : '',
      "User-Agent": controller.mySite != null
          ? controller.mySite!.userAgent!
          : 'Harvest App',
    };
    if (controller.mySite != null &&
        controller.mySite!.mirror!.contains('m-team')) {
      headers['Authorization'] = controller.mySite!.cookie!;
    }
    Logger.instance.d(headers);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Get.defaultDialog(
          title: "退出",
          content: const Text('确定要退出内置浏览器？'),
          onCancel: () {
            Navigator.of(context).pop(true);
          },
          onConfirm: () {
            Navigator.of(context).pop(false);
          },
          textCancel: '退出',
          textConfirm: '取消',
        );
      },
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            controller.pageTitle.value,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            GetBuilder<WebViewPageController>(builder: (controller) {
              if (controller.mySite != null &&
                  controller.mySite?.userId == null &&
                  controller.progress >= 100) {
                return GFIconButton(
                  icon: const Icon(
                    Icons.cookie_sharp,
                    size: 24,
                  ),
                  onPressed: () async {
                    try {
                      String? htmlStr = await webController?.getHtml();
                      var auth = await webController?.webStorage.localStorage
                          .getItem(key: 'auth');
                      Logger.instance.d(auth);
                      // Logger.instance.i(htmlStr);
                      var document = parse(htmlStr).documentElement;
                      HtmlXPath selector = HtmlXPath.node(document!);
                      Logger.instance.d(controller.website!.myUidRule);
                      var result =
                          selector.queryXPath(controller.website!.myUidRule);
                      Logger.instance.d(result.attr);
                      RegExp regex = RegExp(r'\d+(?=\]?$)');
                      Logger.instance.i(
                          '获取到的 UID：${regex.firstMatch(result.attr!.trim())?.group(0)}');
                      String cookies = await webController?.evaluateJavascript(
                          source: "document.cookie");
                      if (controller.mySite != null &&
                          controller.mySite!.mirror!.contains('m-team')) {
                        cookies = await webController?.evaluateJavascript(
                            source: "localStorage.auth");
                      }
                      // 复制到剪切板
                      Clipboard.setData(ClipboardData(text: cookies));
                      Get.snackbar('获取 UID和 Cookie 成功',
                          '你的 UID 是：${regex.firstMatch(result.attr!.trim())?.group(0)}，Cookie已复制到剪切板',
                          colorText: Theme.of(context).colorScheme.primary);
                    } catch (e) {
                      Get.snackbar('获取 UID 失败', '请手动填写站点 UID',
                          colorText: Theme.of(context).colorScheme.error);
                      controller.mySite =
                          controller.mySite?.copyWith(userId: '');
                    }
                  },
                  type: GFButtonType.transparent,
                );
              }
              return const SizedBox.shrink();
            }),
            GetBuilder<WebViewPageController>(builder: (controller) {
              if (controller.info != null && controller.isTorrentPath) {
                return GFIconButton(
                  icon: const Icon(
                    Icons.link_outlined,
                    size: 24,
                  ),
                  onPressed: () async {
                    Clipboard.setData(
                        ClipboardData(text: controller.info!.magnetUrl));
                    Get.snackbar('复制下载链接', '种子下载链接已复制到剪切板！',
                        colorText: Theme.of(context).colorScheme.error);
                  },
                  type: GFButtonType.transparent,
                );
              }
              return const SizedBox.shrink();
            }),
            GetBuilder<WebViewPageController>(builder: (controller) {
              if (controller.info != null && controller.isTorrentPath) {
                return GFIconButton(
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 24,
                  ),
                  onPressed: () {
                    openDownloaderListSheet(context, controller.info!);
                  },
                  type: GFButtonType.transparent,
                );
              }
              return const SizedBox.shrink();
            }),
            GFIconButton(
              icon: const Icon(
                Icons.travel_explore_outlined,
                size: 24,
              ),
              onPressed: () async {
                Uri uri = Uri.parse(controller.url);
                if (!await launchUrl(uri,
                    mode: LaunchMode.externalApplication)) {
                  Get.snackbar('打开网页出错', '打开网页出错，不支持的客户端？',
                      colorText: Theme.of(context).colorScheme.error);
                }
              },
              type: GFButtonType.transparent,
            ),
            GetBuilder<WebViewPageController>(builder: (controller) {
              if (controller.mySite != null && controller.progress >= 100) {
                return GFIconButton(
                  icon: const Icon(
                    Icons.cookie_outlined,
                    size: 24,
                  ),
                  onPressed: () async {
                    List<Cookie> cookies = await cookieManager.getCookies(
                        url: WebUri(controller.url));
                    String cookieStr =
                        cookies.map((e) => '${e.name}=${e.value}').join('; ');

                    Logger.instance.d('获取到的 Cookie：$cookieStr');
                    controller.mySite =
                        controller.mySite?.copyWith(cookie: cookieStr);
                    if (controller.mySite?.userId == null ||
                        controller.mySite?.userId == '') {
                      try {
                        String? htmlStr = await webController?.getHtml();
                        // Logger.instance.i(htmlStr);
                        var document = parse(htmlStr).documentElement;
                        HtmlXPath selector = HtmlXPath.node(document!);
                        var result =
                            selector.queryXPath(controller.website!.myUidRule);
                        var auth = await webController?.webStorage.localStorage
                            .getItem(key: 'auth');
                        Logger.instance.d(auth);
                        RegExp regex = RegExp(r'\d+(?=\]?$)');
                        controller.mySite = controller.mySite?.copyWith(
                          userId:
                              regex.firstMatch(result.attr!.trim())?.group(0),
                          cookie: cookieStr.isNotEmpty ? cookieStr : auth,
                        );
                      } catch (e) {
                        Get.snackbar('获取 UID 失败', '请手动填写站点 UID',
                            colorText: Theme.of(context).colorScheme.error);
                        controller.mySite =
                            controller.mySite?.copyWith(userId: '');
                      }
                    }
                    final response = await editMySite(controller.mySite!);
                    if (response.code == 0) {
                      Get.snackbar(
                        '保存成功！',
                        response.msg!,
                        snackPosition: SnackPosition.TOP,
                        colorText: Theme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 3),
                      );
                    } else {
                      Get.snackbar(
                        '保存出错啦！',
                        response.msg!,
                        snackPosition: SnackPosition.TOP,
                        colorText: Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  type: GFButtonType.transparent,
                );
              }
              return const SizedBox.shrink();
            }),
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
                  initialUrlRequest:
                      URLRequest(url: WebUri(controller.url), headers: headers),
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
                    Logger.instance.d(webUri!.toString);
                    controller.url = webUri.toString();
                    Logger.instance
                        .i('当前页面标题：${await inAppWebViewController.getTitle()}');
                    controller.isLoading = false;
                    controller.canGoBack =
                        await inAppWebViewController.canGoBack();
                    controller.canGoForward =
                        await inAppWebViewController.canGoForward();
                    controller.pageTitle.value =
                        (await inAppWebViewController.getTitle()) ?? '';
                    await getTorrentLink();
                    controller.update();
                  },
                  onProgressChanged: (inAppWebViewController, progress) async {
                    Logger.instance.d('当前进度: $progress');
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
      ),
    );
  }

  getTorrentLink() async {
    controller.isTorrentPath = controller.checkTorrentPath(controller.url);
    Logger.instance.d('当前是否为种子页面: ${controller.isTorrentPath}');
    controller.update();
    if (!controller.isTorrentPath) return;
    String? htmlContent = await webController?.getHtml();
    HtmlXPath selector = HtmlXPath.html(htmlContent!);

    var title = selector
        .queryXPath(controller.website!.detailTitleRule.replaceAll('[1]', ''))
        .attr;
    Logger.instance.d(title);
    String downloadXpath = htmlContent.contains("右键查看")
        ? "//a[contains(text(), '右键查看')]/@href"
        : controller.website!.detailDownloadUrlRule;
    var downloadLink = selector.query(downloadXpath).attrs.firstOrNull;

    if (downloadLink == null) {
      return;
    }
    Logger.instance.d(downloadLink);
    controller.info = SearchTorrentInfo(
        siteId: controller.mySite!.site,
        tid: '',
        poster: '',
        category: '',
        magnetUrl: downloadLink,
        detailUrl: '',
        title: title ?? '',
        subtitle: '',
        saleStatus: '',
        tags: [],
        hr: false,
        published: null,
        size: 0,
        seeders: 0,
        leechers: 0,
        completers: 0);
    Logger.instance.d(controller.info);
    controller.update();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
