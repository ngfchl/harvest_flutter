import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_floating/floating/assist/floating_slide_type.dart';
import 'package:flutter_floating/floating/floating.dart';
import 'package:flutter_floating/floating/manager/floating_manager.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import 'controller.dart';

class WebSocketLoggingWidget extends StatelessWidget {
  const WebSocketLoggingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Icon(
        Icons.waves_sharp,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        final WebSocketLoggingController controller =
            Get.put(WebSocketLoggingController());
        double width = MediaQuery.of(context).size.width * 0.75;
        double height = MediaQuery.of(context).size.height * 0.5;
        if (GetPlatform.isDesktop) {
          width = 500;
          height = 500;
        }
        controller.floating = floatingManager.createFloating(
            controller.inTimeAPILogFloatingKey,
            Floating(
              GetBuilder<WebSocketLoggingController>(builder: (controller) {
                return SizedBox(
                    height: height,
                    width: width,
                    child: _showLoggingDialog(context));
              }),
              slideType: FloatingSlideType.onLeftAndTop,
              isShowLog: false,
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
      return Scaffold(
        appBar: AppBar(
          title: const Text("API日志"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.wrap_text_outlined,
                size: 24,
                color: controller.wrapText
                    ? Colors.orange
                    : Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                controller.wrapText = !controller.wrapText;
                controller.update();
              },
            ),
            // IconButton(
            //   icon: Icon(Icons.remove_red_eye_outlined,
            //       color: Theme.of(context).colorScheme.error),
            //   onPressed: () {
            //     controller.floating.hideFloating();
            //     controller.update();
            //   },
            // ),
            // const SizedBox(width: 10),

            CustomPopup(
              showArrow: false,
              backgroundColor: Theme.of(context).colorScheme.surface,
              barrierColor: Colors.transparent,
              content: SizedBox(
                width: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...controller.levelList.entries.map(
                      (l) => PopupMenuItem<String>(
                        child: Text(
                          l.key.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        onTap: () async {
                          controller.changeLogLevel(l.value);
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
            controller.isLoading
                ? IconButton(
                    icon: const GFLoader(size: 24),
                    onPressed: () {
                      controller.stopFetchLog();
                      controller.update();
                    },
                  )
                : IconButton(
                    icon: Icon(
                      Icons.play_arrow_outlined,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      controller.fetchingLogList();
                      controller.update();
                    },
                  ),
            IconButton(
              icon: Icon(
                Icons.exit_to_app_outlined,
                size: 24,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                controller.floating.close();
              },
            ),
          ],
        ),
        body: CustomCard(
          color: Theme.of(context).colorScheme.surface,
          child: GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return ListView.builder(
                itemCount: controller.showLogList.length,
                controller: controller.scrollController,
                itemBuilder: (context, index) {
                  String res = controller.showLogList[index];
                  return CustomCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      width: MediaQuery.of(context).size.width,
                      child: SelectableText(
                        onSelectionChanged: (TextSelection select,
                            SelectionChangedCause? cause) {
                          Clipboard.setData(ClipboardData(
                              text: res.toString().trim().substring(
                                    select.start,
                                    select.end,
                                  ))).then((_) {
                            GFToast.showToast("已复制", context);
                          });
                        },
                        res.toString().trim(),
                        maxLines: controller.wrapText ? null : 1,
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                          overflow: TextOverflow.visible,
                        ),
                      ));
                });
          }),
        ),
      );
    });
  }
}
