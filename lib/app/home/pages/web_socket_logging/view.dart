import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return InkWell(
      child: Icon(
        Icons.waves_sharp,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        _showLoggingDialog(context);
      },
    );
  }

  void _showLoggingDialog(context) async {
    await Get.bottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      enableDrag: true,
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: generateLogView(context),
      ),
    ).whenComplete(() {
      Get.delete<WebSocketLoggingController>(); // 释放控制器
    });
  }

  Widget generateLogView(BuildContext context) {
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
            return controller.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.cancel_outlined,
                            color: Theme.of(context).colorScheme.primary),
                        onPressed: () {
                          controller.cancelSearch();
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
              itemCount: controller.logList.length,
              controller: controller.scrollController,
              itemBuilder: (context, index) {
                String res = controller.logList[index];
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
