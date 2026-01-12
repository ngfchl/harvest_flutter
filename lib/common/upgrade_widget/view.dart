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
            Tab(
              child: Text(
                'Docker更新',
                style: TextStyle(
                    fontSize: 12,
                    color: controller.updateLogState?.update == true
                        ? shadColorScheme.destructive
                        : shadColorScheme.foreground),
              ),
            ),
            Tab(
              child: Text(
                '配置更新',
                style: TextStyle(
                    fontSize: 12,
                    color: controller.updateSitesState?.update == true
                        ? shadColorScheme.destructive
                        : shadColorScheme.foreground),
              ),
            ),
            Tab(
              child: Text(
                '手动更新',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ];
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
            child: DefaultTabController(
              length: tabs.length,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: TabBar(tabs: tabs,
                    indicatorColor: shadColorScheme.primary,
                ),
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
                              ShadButton.ghost(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('取消'),
                              ),
                              ShadButton.secondary(
                                size: ShadButtonSize.sm,
                                onPressed: () => homeController.initUpdateLogState(),
                                child: const Text('检查更新'),
                              ),
                              if (homeController.updateLogState?.update == true)
                                ShadButton.destructive(
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
                      return Column(
                        children: [
                          Expanded(
                            child: ListView(
                              children: homeController.updateSitesState?.updateNotes.map((note) {
                                    return CheckboxListTile(
                                      dense: true,
                                      value: homeController.updateSitesState?.localLogs.hex == note.hex,
                                      selected: homeController.updateSitesState?.localLogs.hex == note.hex,
                                      onChanged: null,
                                      title: Text(
                                        note.data.trimRight(),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: homeController.updateSitesState?.update == true &&
                                                    note.date.compareTo(
                                                            homeController.updateSitesState!.localLogs.date) >
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
                              ShadButton.ghost(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back();
                                },
                                child: Text('取消'),
                              ),
                              ShadButton.secondary(
                                size: ShadButtonSize.sm,
                                onPressed: () => homeController.initUpdateSitesState(),
                                child: const Text('检查更新'),
                              ),
                              if (homeController.updateSitesState?.update == true)
                                ShadButton.destructive(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    final res = await homeController.doSitesUpdate();
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
                            ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                final res = await homeController.doDockerUpdate();
                                Get.back();
                                Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                              },
                              child: const Text('更新主服务'),
                            ),
                            ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              onPressed: () async {
                                final res = await homeController.doWebUIUpdate();
                                Get.back();
                                Get.snackbar('更新通知', res.msg, colorText: shadColorScheme.foreground);
                              },
                              child: const Text('更新WebUI'),
                            ),
                            ShadButton.destructive(
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
                color: homeController.updateLogState?.update == true || homeController.updateSitesState?.update == true
                    ? shadColorScheme.destructive
                    : shadColorScheme.foreground),
            onPressed: () async {
              if (homeController.updateLogState == null) {
                homeController.initUpdateLogState();
              }
              if (homeController.updateSitesState == null) {
                homeController.initUpdateSitesState();
              }
              popoverController.toggle();
            },
          );
        }),
      );
    });
  }
}
