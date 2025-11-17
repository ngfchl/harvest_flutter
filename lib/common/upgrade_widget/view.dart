import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../app/home/controller/home_controller.dart';

class UpgradeWidgetPage extends StatelessWidget {
  UpgradeWidgetPage({super.key});

  final HomeController homeController = Get.find();
  final popoverController = ShadPopoverController();

  @override
  Widget build(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<HomeController>(builder: (controller) {
      return ShadPopover(
        controller: popoverController,
        popover: (context) => GetBuilder<HomeController>(builder: (controller) {
          List<Tab> tabs = [
            // if (controller.homeController.updateLogState != null)
            const Tab(text: '更新日志'),
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
                    // if (controller.homeController.updateLogState != null)
                    GetBuilder<HomeController>(builder: (homeController) {
                      return Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: homeController.updateLogState?.updateNotes.map((note) {
                                    return CheckboxListTile(
                                      dense: true,
                                      value: homeController.updateLogState?.localLogs.hex == note.hex,
                                      selected: homeController.updateLogState?.localLogs.hex == note.hex,
                                      onChanged: null,
                                      title: Text(
                                        note.data.trimRight(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: homeController.updateLogState?.update == true &&
                                                    note.date.compareTo(homeController.updateLogState!.localLogs.date) >
                                                        0
                                                ? Colors.red
                                                : shadColorScheme.foreground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        note.date,
                                        style:
                                            TextStyle(fontSize: 10, color: shadColorScheme.background.withOpacity(0.8)),
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ShadButton.destructive(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(color: shadColorScheme.destructiveForeground),
                                ),
                              ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () => homeController.initUpdateLogState(),
                                child: const Text('检查更新'),
                              ),
                              if (homeController.updateLogState?.update == true)
                                ShadButton(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    final res = await homeController.doDockerUpdate();
                                    Get.back();
                                    Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                                  },
                                  child: const Text('更新'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8)
                        ],
                      );
                    }),
                    GetBuilder<HomeController>(builder: (homeController) {
                      return SizedBox(
                        height: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                final res = await homeController.doDockerUpdate();
                                Get.back();
                                Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                              },
                              child: const Text('更新主服务'),
                            ),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                final res = await homeController.doWebUIUpdate();
                                Get.back();
                                Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                              },
                              child: const Text('更新WebUI'),
                            ),
                            ShadButton(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                final res = await homeController.doSitesUpdate();
                                Get.back();
                                Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                              },
                              child: const Text('更新站点配置'),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        }),
        child: GetBuilder<HomeController>(builder: (homeController) {
          return ShadIconButton.ghost(
            icon: Icon(Icons.upload_outlined,
                size: 24,
                color: homeController.updateLogState?.update == true
                    ? shadColorScheme.destructive
                    : shadColorScheme.foreground),
            onPressed: () async {
              if (homeController.updateLogState == null) {
                homeController.initUpdateLogState();
                // Get.snackbar('请稍后', '更新日志获取中，请稍后...', colorText: shadColorScheme.foreground);
              }
              popoverController.toggle();
            },
          );
        }),
      );
    });
  }
}
