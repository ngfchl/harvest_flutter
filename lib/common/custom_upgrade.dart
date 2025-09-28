import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app/home/controller/home_controller.dart';

class CustomUpgradeWidget extends StatelessWidget {
  CustomUpgradeWidget({super.key});

  final popoverController = ShadPopoverController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      var shadColorScheme = ShadTheme.of(context).colorScheme;
      return ShadPopover(
        controller: popoverController,
        popover: (context) => GetBuilder<HomeController>(builder: (controller) {
          List<Tab> tabs = [
            if (controller.updateLogState != null) const Tab(text: '更新日志'),
            const Tab(text: '手动更新'),
          ];
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
            child: DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: TabBar(tabs: tabs),
                body: TabBarView(
                  children: [
                    if (controller.updateLogState != null)
                      Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: controller.updateLogState!.updateNotes.map((note) {
                                return CheckboxListTile(
                                  dense: true,
                                  value: controller.updateLogState?.localLogs.hex == note.hex,
                                  selected: controller.updateLogState?.localLogs.hex == note.hex,
                                  onChanged: null,
                                  title: Text(
                                    note.data.trimRight(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: controller.updateLogState?.update == true &&
                                                note.date.compareTo(controller.updateLogState!.localLogs.date) > 0
                                            ? Colors.red
                                            : shadColorScheme.foreground,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    note.date,
                                    style: TextStyle(fontSize: 10, color: shadColorScheme.background.withOpacity(0.8)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              if (controller.updateLogState!.update == true)
                                ShadButton(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    final res = await controller.doDockerUpdate();
                                    Get.back();
                                    Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                                  },
                                  child: const Text('更新'),
                                ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back();
                                },
                                child: const Text('取消'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8)
                        ],
                      ),
                    SizedBox(
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () async {
                              final res = await controller.doDockerUpdate();
                              Get.back();
                              Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                            },
                            child: const Text('更新主服务'),
                          ),
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () async {
                              final res = await controller.doWebUIUpdate();
                              Get.back();
                              Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                            },
                            child: const Text('更新WebUI'),
                          ),
                          ShadButton(
                            size: ShadButtonSize.sm,
                            onPressed: () async {
                              final res = await controller.doSitesUpdate();
                              Get.back();
                              Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                            },
                            child: const Text('更新站点配置'),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }),
        child: ShadIconButton.ghost(
          icon: Icon(Icons.upload_outlined,
              size: 24,
              color:
                  controller.updateLogState?.update == true ? shadColorScheme.destructive : shadColorScheme.foreground),
          onPressed: () async {
            if (controller.updateLogState == null) {
              controller.initUpdateLogState();
              Get.snackbar('请稍后', '更新日志获取中，请稍后...', colorText: shadColorScheme.foreground);
              return;
            }
            popoverController.toggle();
          },
        ),
      );
    });
  }
}
