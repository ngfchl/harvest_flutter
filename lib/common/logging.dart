import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/models/flower.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart' as logger_helper;
import '../app/home/pages/logging/controller.dart';
import '../utils/storage.dart';
import 'card_view.dart';

class LoggingView extends StatelessWidget {
  const LoggingView({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(
        Icons.event_note_sharp,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        _showLoggingDialog(context);
      },
    );
  }

  void _showLoggingDialog(BuildContext context) {
    Get.put(LoggingController());
    var server = SPUtil.getLocalStorage('server');
    final GlobalKey webViewKey = GlobalKey();
    List<Tab> tabs = const [
      Tab(text: 'APP日志'),
      Tab(text: 'API日志'),
      Tab(text: '任务列表'),
    ];
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.5;
    if (GetPlatform.isDesktop) {
      width = MediaQuery.of(context).size.width * 0.5;
      height = MediaQuery.of(context).size.height * 0.5;
    }
    Floating floating = floatingManager.createFloating(
        "inTimeAPPLogFloatingWindows",
        Floating(
          SizedBox(
              height: height,
              width: width,
              child: DefaultTabController(
                  length: tabs.length,
                  child: GetBuilder<LoggingController>(
                    builder: (controller) {
                      return Scaffold(
                        bottomNavigationBar: TabBar(tabs: tabs),
                        appBar: AppBar(
                          title: const Text('实时日志'),
                          actions: [
                            IconButton(
                              onPressed: () async {
                                controller.filterLevel = Level.all;
                                await controller.clearLogs();
                                controller.update();
                              },
                              icon: Icon(
                                Icons.refresh,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            CustomPopup(
                              showArrow: false,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              barrierColor: Colors.transparent,
                              content: SizedBox(
                                width: 100,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...Level.values.map(
                                      (l) => PopupMenuItem<String>(
                                        child: Text(
                                          l.name.toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        onTap: () async {
                                          controller.filterLevel = l;
                                          controller.update();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.event_note,
                                size: 24,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: Icon(Icons.exit_to_app_outlined,
                                  color: Theme.of(context).colorScheme.error),
                              onPressed: () {
                                Floating floating = floatingManager
                                    .getFloating("inTimeAPPLogFloatingWindows");
                                floating.close();
                                Get.delete<LoggingController>();
                                Get.back();
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                        body: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            ValueListenableBuilder<List<OutputEvent>>(
                                valueListenable:
                                    logger_helper.memoryLogOutput.logsNotifier,
                                builder: (context, logs, child) {
                                  final filteredLogs = logs
                                      .where((log) =>
                                          log.level.index >=
                                          controller.filterLevel.index)
                                      .toList();
                                  return ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    controller: controller.scrollController,
                                    itemCount: filteredLogs.length,
                                    itemBuilder: (context, index) {
                                      final log = filteredLogs[index];
                                      return CustomCard(
                                        padding: const EdgeInsets.all(8),
                                        child: SelectableText(
                                          log.lines.join('\n'),
                                        ), // 确保 log 可以转换为字符串
                                      );
                                    },
                                  );
                                }),
                            GetPlatform.isWeb
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            String url =
                                                '$server/api/flower/tasks';
                                            await openUrl(url);
                                          },
                                          child: const Text('任务列表')),
                                      ElevatedButton(
                                          onPressed: () async {
                                            Get.back();
                                            String url = '$server/supervisor';
                                            await openUrl(url);
                                          },
                                          child: const Text('服务日志')),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      if (controller.progress < 100)
                                        LinearProgressIndicator(
                                          value: controller.progress / 100,
                                          backgroundColor:
                                              Colors.grey.withAlpha(33),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  Colors.blue),
                                        ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                controller.currentLog =
                                                    'logging';
                                                controller.switchLogging();
                                              },
                                              child: const Text('服务')),
                                          // ElevatedButton(
                                          //     onPressed: () {
                                          //       controller.currentLog =
                                          //           'taskList';
                                          //       controller.switchLogging();
                                          //     },
                                          //     child: const Text('任务')),
                                          // ElevatedButton(
                                          //     onPressed: () {
                                          //       controller.currentLog =
                                          //           'taskLog';
                                          //       controller.switchLogging();
                                          //     },
                                          //     child: const Text('Log')),
                                          ElevatedButton(
                                              onPressed: () {
                                                controller.currentLog =
                                                    'accessLog';
                                                controller.switchLogging();
                                              },
                                              child: const Text('Web')),
                                        ],
                                      ),
                                      Expanded(
                                        child: CustomCard(
                                          child: InAppWebView(
                                            key: webViewKey,
                                            initialUrlRequest: URLRequest(
                                                url: WebUri(
                                                    controller.accessUrl)),
                                            initialSettings:
                                                InAppWebViewSettings(
                                              isInspectable: kDebugMode,
                                              mediaPlaybackRequiresUserGesture:
                                                  false,
                                              allowsInlineMediaPlayback: true,
                                              iframeAllow: "camera; microphone",
                                              iframeAllowFullscreen: true,
                                              defaultFontSize: 24,
                                            ),
                                            onWebViewCreated:
                                                (inAppWebViewController) async {
                                              controller.webController =
                                                  inAppWebViewController;
                                              controller.isLoading = true;
                                              controller.update();
                                            },
                                            onLoadStart:
                                                (inAppWebViewController,
                                                    _) async {
                                              controller.isLoading = true;
                                              controller.update();
                                            },
                                            onLoadStop: (inAppWebViewController,
                                                webUri) async {
                                              logger_helper.Logger.instance.d(
                                                  (await inAppWebViewController
                                                      .getTitle())!);
                                              controller.isLoading = false;
                                              if (!controller.accessUrl
                                                  .contains('flower')) {
                                                await controller.webController
                                                    ?.evaluateJavascript(
                                                        source: """
                                          document.getElementsByTagName('body')[0].style.fontSize = '${controller.fontSize}px';
                                          document.getElementsByTagName('body')[0].style.lineHeight = '1.8';
                                          document.getElementsByTagName('pre')[0].style.wordWrap = 'break-word';
                                          document.getElementsByTagName('pre')[0].style.whiteSpace = 'pre-wrap';
                                        """);
                                              }
                                              controller.update();
                                            },
                                            onProgressChanged:
                                                (inAppWebViewController,
                                                    progress) async {
                                              logger_helper.Logger.instance
                                                  .i('当前进度: $progress');
                                              controller.progress = progress;
                                              controller.update();
                                            },
                                            onReceivedError:
                                                (inAppWebViewController, _,
                                                    err) {
                                              // inAppWebViewController.reload();
                                            },
                                          ),
                                        ),
                                      ),
                                      CustomCard(
                                        // height: !controller.accessUrl
                                        //         .contains('flower')
                                        //     ? 105
                                        //     : 56,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // if (!controller.accessUrl
                                            //     .contains('flower'))
                                            //   Row(
                                            //     children: [
                                            //       Text(
                                            //           '获取日志长度：${controller.logLength}'),
                                            //       Expanded(
                                            //         child: Slider(
                                            //             min: 1,
                                            //             max: 10,
                                            //             value: controller
                                            //                     .logLength /
                                            //                 1024,
                                            //             onChanged: (value) {
                                            //               controller
                                            //                       .logLength =
                                            //                   value.toInt() *
                                            //                       1024;
                                            //               controller
                                            //                   .switchLogging();
                                            //               controller.webController?.loadUrl(
                                            //                   urlRequest: URLRequest(
                                            //                       url: WebUri(
                                            //                           controller
                                            //                               .accessUrl)));
                                            //             }),
                                            //       ),
                                            //     ],
                                            //   ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    '页面字体大小：${controller.fontSize}'),
                                                Expanded(
                                                  child: Slider(
                                                      min: 12,
                                                      max: 36,
                                                      value:
                                                          controller.fontSize /
                                                              1,
                                                      onChanged: (value) async {
                                                        controller.fontSize =
                                                            value.toInt();
                                                        SPUtil.setLocalStorage(
                                                            'loggingFontSize',
                                                            controller
                                                                .fontSize);
                                                        // 初始化时或页面加载完成后设置字体大小
                                                        var res = await controller
                                                            .webController
                                                            ?.evaluateJavascript(
                                                                source: """
                                          document.getElementsByTagName('body')[0].style.fontSize = '${controller.fontSize}px';
                                        """);
                                                        controller.update();

                                                        logger_helper
                                                            .Logger.instance
                                                            .i(res.toString());
                                                      }),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // const SizedBox(height: 30)
                                    ],
                                  ),
                            ListView.builder(
                              itemCount: controller.taskList.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TaskItem item = controller.taskList[index];
                                return CustomCard(
                                  margin: const EdgeInsets.only(
                                      left: 8, right: 8, top: 6, bottom: 2),
                                  child: Slidable(
                                    key: ValueKey(item.uuid),
                                    endActionPane: item.state.toLowerCase() ==
                                                'success' ||
                                            item.state.toLowerCase() == 'failed'
                                        ? ActionPane(
                                            motion: const ScrollMotion(),
                                            extentRatio: 0.25,
                                            children: [
                                              SlidableAction(
                                                flex: 1,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                onPressed: (context) async {
                                                  Get.defaultDialog(
                                                    title: '任务执行结果',
                                                    content: item.state
                                                                .toLowerCase() ==
                                                            'success'
                                                        ? Text(item.result)
                                                        : Text(item.traceback
                                                            .toString()),
                                                  );
                                                },
                                                backgroundColor:
                                                    const Color(0xFF0A9D96),
                                                foregroundColor: Colors.white,
                                                icon: Icons.copy_sharp,
                                                label: '结果',
                                              ),
                                            ],
                                          )
                                        : ActionPane(
                                            motion: const ScrollMotion(),
                                            extentRatio: 0.5,
                                            children: [
                                              SlidableAction(
                                                flex: 1,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                onPressed: (context) async {
                                                  Get.defaultDialog(
                                                    title: '确认',
                                                    radius: 5,
                                                    titleStyle: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            Colors.deepPurple),
                                                    middleText: '确定要删除任务吗？',
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Get.back(
                                                              result: false);
                                                        },
                                                        child: const Text('取消'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Get.back(
                                                              result: true);
                                                          var res =
                                                              await controller
                                                                  .abortTask(
                                                                      item);
                                                          if (res.code == 0) {
                                                            Get.snackbar(
                                                                '删除通知',
                                                                res.msg
                                                                    .toString(),
                                                                colorText: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary);
                                                          } else {
                                                            Get.snackbar(
                                                                '删除通知',
                                                                res.msg
                                                                    .toString(),
                                                                colorText: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error);
                                                          }
                                                        },
                                                        child: const Text('确认'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                backgroundColor:
                                                    const Color(0xFFB11211),
                                                foregroundColor: Colors.white,
                                                // icon: Icons.delete,
                                                label: '取消',
                                              ),
                                              SlidableAction(
                                                flex: 1,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(8)),
                                                onPressed: (context) async {
                                                  Get.defaultDialog(
                                                    title: '确认',
                                                    radius: 5,
                                                    titleStyle: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color:
                                                            Colors.deepPurple),
                                                    middleText: '确定要删除任务吗？',
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Get.back(
                                                              result: false);
                                                        },
                                                        child: const Text('取消'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          Get.back(
                                                              result: true);
                                                          var res =
                                                              await controller
                                                                  .revokeTask(
                                                                      item);
                                                          if (res.code == 0) {
                                                            Get.snackbar(
                                                                '删除通知',
                                                                res.msg
                                                                    .toString(),
                                                                colorText: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary);
                                                          } else {
                                                            Get.snackbar(
                                                                '删除通知',
                                                                res.msg
                                                                    .toString(),
                                                                colorText: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .error);
                                                          }
                                                        },
                                                        child: const Text('确认'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                                backgroundColor:
                                                    const Color(0xFFE30303),
                                                foregroundColor: Colors.white,
                                                // icon: Icons.delete,
                                                label: '中断',
                                              ),
                                            ],
                                          ),
                                    child: ListTile(
                                      title: Text(item.name),
                                      subtitle: Text(
                                          DateTime.fromMillisecondsSinceEpoch(
                                                  (item.started * 1000).toInt())
                                              .toString()),
                                      trailing: SizedBox(
                                          width: 60,
                                          child: CustomTextTag(
                                              labelText:
                                                  item.state.toLowerCase())),
                                      onTap: () {},
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ))),
          slideType: FloatingSlideType.onLeftAndTop,
          isShowLog: false,
          top: 0,
        ));
    floating.open(context);
  }

  Future<void> openUrl(String url) async {
    Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        '打开网页出错',
        '打开网页出错，不支持的客户端？',
      );
    }
  }
}
