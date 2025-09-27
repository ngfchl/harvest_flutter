import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../app/home/controller/home_controller.dart';

class CustomUpgradeWidget extends StatelessWidget {
  const CustomUpgradeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return InkWell(
        onTap: () async {
          if (controller.updateLogState == null) {
            await controller.initUpdateLogState();
            Get.snackbar('请稍后', '更新日志获取中，请稍后...', colorText: ShadTheme.of(context).colorScheme.foreground);
          }
          var shadColorScheme = ShadTheme.of(context).colorScheme;

          controller.initUpdateLogState();
          Get.bottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0), // 圆角半径
            ),
            GetBuilder<HomeController>(builder: (controller) {
              List<Tab> tabs = [
                if (controller.updateLogState != null) const Tab(text: '更新日志'),
                const Tab(text: '手动更新'),
              ];
              return SizedBox(
                height: 300,
                child: DefaultTabController(
                  length: tabs.length,
                  child: Scaffold(
                    appBar: TabBar(tabs: tabs),
                    body: TabBarView(
                      children: [
                        if (controller.updateLogState != null)
                          SizedBox(
                            height: 300,
                            child: Column(
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
                                          style: TextStyle(
                                              fontSize: 10, color: shadColorScheme.background.withOpacity(0.8)),
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
                                          Get.snackbar('更新通知', res.msg,
                                              colorText: ShadTheme.of(context).colorScheme.foreground);
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
                                  Get.snackbar('更新通知', res.msg,
                                      colorText: ShadTheme.of(context).colorScheme.foreground);
                                },
                                child: const Text('更新主服务'),
                              ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () async {
                                  final res = await controller.doWebUIUpdate();
                                  Get.back();
                                  Get.snackbar('更新通知', res.msg,
                                      colorText: ShadTheme.of(context).colorScheme.foreground);
                                },
                                child: const Text('更新WebUI'),
                              ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                onPressed: () async {
                                  final res = await controller.doSitesUpdate();
                                  Get.back();
                                  Get.snackbar('更新通知', res.msg,
                                      colorText: ShadTheme.of(context).colorScheme.foreground);
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
          );
        },
        child: Icon(Icons.upload,
            size: 24,
            color:
                controller.updateLogState?.update == true ? Colors.red : ShadTheme.of(context).colorScheme.foreground),
      );
    });
  }
}
