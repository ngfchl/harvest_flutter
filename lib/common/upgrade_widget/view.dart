import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/home/controller/home_controller.dart';
import '../../utils/logger_helper.dart';

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
            const Tab(text: 'APP更新'),
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
                              children: homeController.updateLogState!.updateNotes.map((note) {
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
                                                note.date.compareTo(homeController.updateLogState!.localLogs.date) > 0
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
                              if (homeController.updateLogState!.update == true)
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
                    // if (GetPlatform.isAndroid)
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('当前版本：${homeController.currentVersion}', style: TextStyle(fontSize: 10)),
                      Text('服务器版本：v${homeController.updateInfo?.version}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: homeController.updateInfo?.version == homeController.currentVersion
                                  ? shadColorScheme.foreground
                                  : shadColorScheme.destructiveForeground)),
                      GetBuilder<HomeController>(
                          id: 'progressValue',
                          builder: (controller) {
                            if (controller.progressValue != 0 && controller.progressValue < 1) {
                              return Text(
                                  '正在下载: ${homeController.newVersion} ${(controller.progressValue * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(fontSize: 10));
                            }
                            return const SizedBox.shrink();
                          }), // TODO: 修改为百分比显示
                      Expanded(
                        child: ListView(
                          children: [
                            ...?homeController.updateInfo?.changelog
                                .split('\n')
                                .map((e) => Text(e, style: TextStyle(fontSize: 10)))
                          ],
                        ),
                      ),
                      ShadButton(
                        size: ShadButtonSize.sm,
                        onPressed: () => getDownloadUrlForCurrentPlatform(context),
                        child:
                            Text(homeController.updateInfo?.version == homeController.currentVersion ? '重新安装' : '更新'),
                      ),
                    ])
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

                Get.snackbar('请稍后', '更新日志获取中，请稍后...', colorText: shadColorScheme.foreground);
              }
              await homeController.getAppLatestVersionInfo();
              popoverController.toggle();
            },
          );
        }),
      );
    });
  }

  /// 根据当前设备平台，从 downloadLinks 中返回最匹配的下载 URL
  Future getDownloadUrlForCurrentPlatform(BuildContext context) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final String prefix = 'harvest_${homeController.updateInfo?.version}';
    Map<String, String> downloadLinks = homeController.updateInfo?.downloadLinks ?? {};
    String? downloadUrl;
    var appDocDir = await getTemporaryDirectory();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final abis = androidInfo.supportedAbis;
      if (abis.any((abi) => abi.contains('armeabi-v7a'))) {
        homeController.newVersion = '${prefix}_arm32.apk';
      } else if (abis.any((abi) => abi.contains('x86_64'))) {
        homeController.newVersion = '${prefix}_x86_64.apk';
      } else {
        homeController.newVersion = '${prefix}_arm64.apk';
      }
      String savePath = "${appDocDir.path}/${homeController.newVersion}";
      downloadUrl ??= downloadLinks[homeController.newVersion];
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await InstallPlugin.install(savePath);
    } else if (Platform.isIOS) {
      // downloadUrl = downloadLinks['${prefix}_ios.ipa'];
      downloadUrl = 'https://testflight.apple.com/join/kwLil5xf';
      await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
    } else if (Platform.isWindows) {
      homeController.newVersion = '${prefix}_x86_64-win.zip';
      downloadUrl = downloadLinks[homeController.newVersion];
      String savePath = "${appDocDir.path}/${homeController.newVersion}";
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await Process.run('explorer.exe', [savePath]);
    } else if (Platform.isMacOS) {
      try {
        final result = await Process.run('uname', ['-m']);
        final arch = result.stdout.toString().trim();
        if (arch == 'arm64') {
          homeController.newVersion = '${prefix}_arm64-macos.dmg';
        } else {
          homeController.newVersion = '${prefix}_x86_64-macos.dmg';
        }
        downloadUrl ??= downloadLinks[homeController.newVersion];
        String savePath = "${appDocDir.path}/${homeController.newVersion}";
        await _downloadInstallationPackage(savePath, downloadUrl!);
        await Process.run('open', [savePath]);
      } catch (e, stackTrace) {
        Logger.instance.e('打开安装包失败: $e', stackTrace: stackTrace);
        Get.snackbar('更新通知', '当前设备不支持更新', colorText: shadColorScheme.destructiveForeground);
      }
    } else {
      Get.snackbar('更新通知', '不支持的系统平台', colorText: shadColorScheme.destructiveForeground);
    }
  }

  Future<void> _downloadInstallationPackage(String savePath, String fileUrl) async {
    homeController.progressValue = 0.00001;
    homeController.update(['progressValue']);
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      final value = count / total;
      if (homeController.progressValue != value) {
        if (homeController.progressValue < 1.0) {
          homeController.progressValue = count / total;
        } else {
          homeController.progressValue = 0.0;
        }
        homeController.update(['progressValue']);
        Logger.instance.i("${(homeController.progressValue * 100).toStringAsFixed(0)}%");
      }
    });
  }
}
