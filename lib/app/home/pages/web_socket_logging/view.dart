import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import 'controller.dart';

class WebSocketLoggingWidget extends StatelessWidget {
  WebSocketLoggingWidget({super.key});

  final WebSocketLoggingController controller =
      Get.put(WebSocketLoggingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("实时日志"),
        actions: [
          GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.wrap_text_outlined,
                      color: controller.wrapText
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary),
                  onPressed: () {
                    controller.wrapText = !controller.wrapText;
                    controller.update();
                  },
                ),
                const SizedBox(width: 10),
              ],
            );
          }),
          GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                const SizedBox(width: 10),
              ],
            );
          }),
          GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return controller.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.cancel_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          controller.stopFetchLog();
                          controller.update();
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                : const SizedBox.shrink();
          }),
          GetBuilder<WebSocketLoggingController>(builder: (controller) {
            return controller.isLoading
                ? const GFLoader(size: 18)
                : const SizedBox.shrink();
          }),
          const SizedBox(width: 20),
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
                return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    width: MediaQuery.of(context).size.width,
                    child: SelectableText(
                      onSelectionChanged:
                          (TextSelection select, SelectionChangedCause? cause) {
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
  }
}
