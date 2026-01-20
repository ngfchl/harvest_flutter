import 'package:flutter/material.dart';
import 'package:flutter_floating/flutter_floating.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/card_view.dart';
import 'controller.dart';

class WebSocketLoggingWidget extends StatelessWidget {
  const WebSocketLoggingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadIconButton.ghost(
      icon: Icon(
        Icons.waves_sharp,
        size: 20,
        color: ShadTheme.of(context).colorScheme.foreground,
      ),
      onPressed: () {
        final WebSocketLoggingController controller = Get.put(WebSocketLoggingController());
        double width = MediaQuery.of(context).size.width * 0.75;
        double height = MediaQuery.of(context).size.height * 0.5;
        if (GetPlatform.isDesktop) {
          width = 500;
          height = 500;
        }
        controller.floating = floatingManager.createFloating(
            controller.inTimeAPILogFloatingKey,
            FloatingOverlay(
              GetBuilder<WebSocketLoggingController>(builder: (controller) {
                return SizedBox(height: height, width: width, child: _showLoggingDialog(context));
              }),
              slideType: FloatingEdgeType.onLeftAndTop,
              top: 0,
            ));
        controller.floating.open(context);
        controller.floating.addFloatingListener(controller.oneListener);
        controller.update();
      },
    );
  }

  Widget _showLoggingDialog(BuildContext context) {
    return GetBuilder<WebSocketLoggingController>(builder: (controller) {
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: shadColorScheme.background,
        appBar: AppBar(
          title: Text(
            "实时访问日志",
            style: TextStyle(color: shadColorScheme.foreground),
          ),
          toolbarHeight: 40,
          backgroundColor: shadColorScheme.background,
          actions: [
            ShadMenubar(
              border: ShadBorder.none,
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              items: [
                ShadMenubarItem(
                  items: [
                    ...controller.levelList.entries.map(
                      (l) => ShadContextMenuItem(
                        child: Text(
                          l.key.toUpperCase(),
                          style: TextStyle(
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onPressed: () async {
                          controller.changeLogLevel(l.value);
                        },
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.event_note,
                    size: 20,
                    color: shadColorScheme.foreground,
                  ),
                ),
              ],
            ),

            IconButton(
              icon: Icon(
                Icons.wrap_text_outlined,
                size: 20,
                color: controller.wrapText ? Colors.orange : shadColorScheme.foreground,
              ),
              onPressed: () {
                controller.wrapText = !controller.wrapText;
                controller.update();
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.remove_red_eye_outlined,
            //       color: ShadTheme.of(context).colorScheme.error),
            //   onPressed: () {
            //     controller.floating.hideFloating();
            //     controller.update();
            //   },
            // ),
            // const SizedBox(width: 10),

            controller.isLoading
                ? ShadIconButton.ghost(
                    icon: SizedBox(
                      width: 14,
                      height: 14,
                      child:
                          Center(child: CircularProgressIndicator(color: shadColorScheme.foreground, strokeWidth: 2)),
                    ),
                    onPressed: () {
                      controller.stopFetchLog();
                      controller.update();
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.play_arrow_outlined,
                      size: 20,
                      color: shadColorScheme.foreground,
                    ),
                    onPressed: () {
                      controller.fetchingWebSocketLogList();
                      controller.update();
                    },
                  ),
            IconButton(
              icon: Icon(
                Icons.exit_to_app_outlined,
                size: 20,
                color: shadColorScheme.destructive,
              ),
              onPressed: () {
                controller.floating.close();
              },
            ),
          ],
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          // 使用 LayoutBuilder 提供的 constraints 获取宽度
          final width = constraints.maxWidth - 2;
          return GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return ListView.builder(
                itemCount: controller.showLogList.length,
                controller: controller.scrollController,
                itemBuilder: (context, index) {
                  String res = controller.showLogList[index];

                  return CustomCard(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                      width: width,
                      child: SelectableText(
                        // onSelectionChanged: (TextSelection select, SelectionChangedCause? cause) {
                        //   Clipboard.setData(ClipboardData(
                        //       text: res.toString().trim().substring(
                        //             select.start,
                        //             select.end,
                        //           ))).then((_) {});
                        // },
                        res.toString().trim(),
                        maxLines: controller.wrapText ? null : 1,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: shadColorScheme.foreground,
                          overflow: TextOverflow.visible,
                        ),
                      ));
                });
          });
        }),
      );
    });
  }
}
