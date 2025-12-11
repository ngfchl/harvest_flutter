import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/utils/storage.dart';
import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/logger_helper.dart';
import 'controller.dart';

class AppUpgradePage extends StatelessWidget {
  final Widget? child;

  AppUpgradePage({super.key, this.child});

  final AppUpgradeController appUpgradeController = Get.put(AppUpgradeController());

  @override
  Widget build(BuildContext context) {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    final buttonKey = GlobalKey();

    return GetBuilder<AppUpgradeController>(builder: (appUpgradeController) {
      return ShadPopover(
        controller: appUpgradeController.popoverController,
        closeOnTapOutside: false,
        popover: (context) => ShadTabs<String>(
          value: appUpgradeController.currentTab,
          tabBarConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 50),
          contentConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          onChanged: (String value) => appUpgradeController.currentTab = value,
          tabs: [
            ShadTab(
              value: 'latestVersion',
              content: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '当前版本：${appUpgradeController.currentVersion} ${(appUpgradeController.hasNewVersion ? ' -- 新版本!' : '')}',
                              style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                          appUpgradeController.hasNewVersion
                              ? SwitchTile(
                                  title: '服务器版本：v${appUpgradeController.updateInfo?.version}',
                                  contentPadding: EdgeInsets.zero,
                                  scale: 0.75,
                                  value: appUpgradeController.notShowNewVersion,
                                  label:
                                      Text('不再提醒', style: TextStyle(fontSize: 16, color: shadColorScheme.destructive)),
                                  onChanged: (value) {
                                    appUpgradeController.notShowNewVersion = value;
                                    appUpgradeController.update();
                                    SPUtil.setBool('notShowNewVersion', value);
                                  })
                              : Text(
                                  '服务器版本：v${appUpgradeController.updateInfo?.version} ${(appUpgradeController.hasNewVersion ? ' -- 新版本!' : '')}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: appUpgradeController.hasNewVersion
                                          ? shadColorScheme.destructive
                                          : shadColorScheme.foreground)),
                          GetBuilder<AppUpgradeController>(
                              id: 'progressValue',
                              builder: (controller) {
                                if (controller.progressValue != 0 && controller.progressValue < 1) {
                                  return Text(
                                      '正在下载: ${appUpgradeController.newVersion} ${(controller.progressValue * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(fontSize: 12, color: shadColorScheme.foreground));
                                }
                                return const SizedBox.shrink();
                              }),
                        ],
                      ), // TODO: 修改为百分比显示
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...?appUpgradeController.updateInfo?.changelog.split('\n').map(
                                  (e) => Text(e, style: TextStyle(fontSize: 12, color: shadColorScheme.foreground))),
                              ...?appUpgradeController.updateInfo?.downloadLinks.entries
                                  .map((e) => Builder(builder: (context) {
                                        final buttonKey = GlobalKey();
                                        return ShadButton.link(
                                            key: buttonKey,
                                            padding: EdgeInsets.zero,
                                            onPressed: () => doInstallationPackage(context, e, buttonKey),
                                            child: Text(e.key, style: TextStyle(fontSize: 12)));
                                      }))
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            runAlignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ShadButton.outline(
                                size: ShadButtonSize.sm,
                                onPressed: () => appUpgradeController.popoverController.hide(),
                                leading: Icon(
                                  Icons.close_outlined,
                                  size: 16,
                                ),
                                child: Text('关闭'),
                              ),
                              ShadButton(
                                size: ShadButtonSize.sm,
                                leading: Icon(
                                  Icons.downloading_outlined,
                                  size: 16,
                                ),
                                onPressed: () => appUpgradeController.getAppLatestVersionInfo(),
                                child: Text('检查'),
                              ),
                              ShadButton.destructive(
                                size: ShadButtonSize.sm,
                                key: buttonKey,
                                onPressed: () => getDownloadUrlForCurrentPlatform(context, buttonKey),
                                leading: Icon(
                                  Icons.install_desktop_outlined,
                                  size: 16,
                                ),
                                child: Text(appUpgradeController.hasNewVersion ? '更新' : '重装'),
                              ),
                              if (Platform.isIOS)
                                ShadButton.link(
                                  size: ShadButtonSize.sm,
                                  onPressed: () => launchUrl(Uri.parse('https://testflight.apple.com/join/kwLil5xf'),
                                      mode: LaunchMode.externalApplication),
                                  child: Text('TestFlight'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ]),
              ),
              child: Text(
                'APP更新',
                style: TextStyle(
                    color:
                        appUpgradeController.hasNewVersion ? shadColorScheme.destructive : shadColorScheme.foreground),
              ),
            ),
          ],
        ),
        child: child ??
            ShadIconButton.ghost(
              icon: Icon(Icons.update,
                  size: 24,
                  color: appUpgradeController.updateInfo != null &&
                          appUpgradeController.updateInfo?.version != appUpgradeController.currentVersion
                      ? shadColorScheme.destructive
                      : shadColorScheme.foreground),
              onPressed: () async {
                if (appUpgradeController.updateInfo == null) {
                  await appUpgradeController.getAppLatestVersionInfo();
                }
                // if (appUpgradeController.appVersions.isEmpty) {
                //   await appUpgradeController.getAppVersionList();
                // }
                appUpgradeController.popoverController.toggle();
              },
            ),
      );
    });
  }

  Future<void> doInstallationPackage(BuildContext context, MapEntry e, GlobalKey buttonKey) async {
    if (GetPlatform.isDesktop) {
      String? savePath = await FilePicker.platform.saveFile(
        dialogTitle: '保存安装包',
        fileName: e.key, // 例如 "harvest_2025.1103.01+181_arm64.apk"
        // 可选：限制类型（但 saveFile 不强制校验扩展名）
        type: FileType.custom,
        allowedExtensions: ['apk', 'ipa', 'dmg', 'zip'],
      );
      if (savePath != null) {
        await _downloadInstallationPackage(savePath, e.value);
      }
    } else {
      await downloadAndSaveWithFilePicker(e.value, e.key, buttonKey);
    }
  }

  /// 根据当前设备平台，从 downloadLinks 中返回最匹配的下载 URL
  Future getDownloadUrlForCurrentPlatform(BuildContext context, GlobalKey buttonKey) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final String prefix = 'harvest_${appUpgradeController.updateInfo?.version}';
    Map<String, String> downloadLinks = appUpgradeController.updateInfo?.downloadLinks ?? {};
    String? downloadUrl;
    Directory? appDocDir = await getTemporaryDirectory();

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final abis = androidInfo.supportedAbis;
      if (abis.any((abi) => abi.contains('armeabi-v7a'))) {
        appUpgradeController.newVersion = '${prefix}_arm32-android.apk';
      } else if (abis.any((abi) => abi.contains('x86_64'))) {
        appUpgradeController.newVersion = '${prefix}_x86_64-android.apk';
      } else {
        appUpgradeController.newVersion = '${prefix}_arm64-android.apk';
      }
      appDocDir = await getExternalStorageDirectory();
      String savePath = "${appDocDir?.path}/${appUpgradeController.newVersion}";
      downloadUrl ??= downloadLinks[appUpgradeController.newVersion];
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await InstallPlugin.install(savePath);
    } else if (Platform.isIOS) {
      appUpgradeController.newVersion = '${prefix}_arm64-ios.ipa';

      downloadUrl = downloadLinks[appUpgradeController.newVersion];
      await downloadAndSaveWithFilePicker(downloadUrl!, appUpgradeController.newVersion, buttonKey);
    } else if (Platform.isWindows) {
      appUpgradeController.newVersion = '${prefix}_x86_64-windows.zip';
      downloadUrl = downloadLinks[appUpgradeController.newVersion];
      String savePath = "${appDocDir.path}/${appUpgradeController.newVersion}";
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await Process.run('explorer.exe', [savePath.replaceAll('/', '\\')]);
    } else if (Platform.isMacOS) {
      try {
        final result = await Process.run('uname', ['-m']);
        final arch = result.stdout.toString().trim();
        if (arch == 'arm64') {
          appUpgradeController.newVersion = '${prefix}_arm64-macos.dmg';
        } else {
          appUpgradeController.newVersion = '${prefix}_x86_64-macos.dmg';
        }
        downloadUrl ??= downloadLinks[appUpgradeController.newVersion];
        String? savedPath = await FilePicker.platform.saveFile(
          dialogTitle: '保存安装包',
          fileName: appUpgradeController.newVersion,
          type: FileType.custom,
          allowedExtensions: ['apk', 'ipa', 'dmg', 'zip'],
        );
        await _downloadInstallationPackage(savedPath!, downloadUrl!);
        await Process.run('open', [savedPath]);
      } catch (e, stackTrace) {
        Logger.instance.e('打开安装包失败: $e', stackTrace: stackTrace);
        Get.snackbar('更新通知', '当前设备不支持更新', colorText: shadColorScheme.destructiveForeground);
      }
    } else {
      Get.snackbar('更新通知', '不支持的系统平台', colorText: shadColorScheme.destructiveForeground);
    }
  }

  Future<void> _downloadInstallationPackage(String savePath, String fileUrl) async {
    appUpgradeController.progressValue = 0.00001;
    appUpgradeController.update(['progressValue']);
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      final value = count / total;
      if (appUpgradeController.progressValue != value) {
        if (appUpgradeController.progressValue < 1.0) {
          appUpgradeController.progressValue = count / total;
        } else {
          appUpgradeController.progressValue = 0.0;
        }
        appUpgradeController.update(['progressValue']);
        Logger.instance.i("${(appUpgradeController.progressValue * 100).toStringAsFixed(0)}%");
      }
    });
  }

  Future<void> downloadAndSaveWithFilePicker(String fileUrl, String suggestedName, GlobalKey buttonKey) async {
    if (kIsWeb) return;

    // 显示“正在准备下载...”提示（因为要先加载到内存）
    appUpgradeController.progressValue = -1; // 可用 -1 表示“缓冲中”
    appUpgradeController.update(['progressValue']);

    try {
      // Step 1: 下载完整文件到内存（注意：大文件可能 OOM！）
      final response = await Dio().get<List<int>>(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (count, total) {
          // 可选：显示预加载进度（但 saveFile 本身无进度）
          final value = count / total;
          if (value < 1.0) {
            appUpgradeController.progressValue = value;
            appUpgradeController.update(['progressValue']);
          }
        },
      );
      if (Platform.isAndroid) {
        final Uint8List bytes = Uint8List.fromList(response.data!);

        // Step 2: 调用 saveFile 并传入 bytes（移动端必需！）
        String? savedPath = await FilePicker.platform.saveFile(
          dialogTitle: '保存安装包',
          fileName: suggestedName,
          type: FileType.custom,
          allowedExtensions: ['apk', 'ipa', 'dmg', 'zip'],
          bytes: bytes, // ⚠️ 关键：必须传！
        );

        if (savedPath != null) {
          appUpgradeController.progressValue = 1.0;
          appUpgradeController.update(['progressValue']);
          Logger.instance.i('✅ 文件已保存: $savedPath');
        } else {
          Logger.instance.w('用户取消了保存');
        }
      }
      if (Platform.isIOS) {
        // 2. 保存到应用沙盒 Documents 目录
        final dir = await getApplicationDocumentsDirectory();
        final savePath = '${dir.path}/$suggestedName';
        final file = File(savePath);
        await file.writeAsBytes(Uint8List.fromList(response.data!));
        // 获取按钮在屏幕上的位置
        Rect? originRect;
        try {
          final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null && renderBox.hasSize) {
            final offset = renderBox.localToGlobal(Offset.zero);
            originRect = Rect.fromLTWH(
              offset.dx,
              offset.dy,
              renderBox.size.width,
              renderBox.size.height,
            );
          }
        } catch (e) {
          // fallback to screen center if failed
          originRect = const Rect.fromLTWH(100, 100, 100, 50);
        }
        // 3. 分享文件（会弹出“分享表单”，用户可选“存储到文件”）
        await SharePlus.instance.share(ShareParams(
          title: '收割机APP',
          files: [XFile(savePath)],
          text: '分享安装包到...',
          sharePositionOrigin: originRect, // ✅ 关键：非零有效 Rect
        ));

        Logger.instance.i('✅ 已分享文件，用户可保存到“文件”App');
      }
    } catch (e, stack) {
      appUpgradeController.progressValue = 0.0;
      appUpgradeController.update(['progressValue']);
      Logger.instance.e('保存失败: $e', error: e, stackTrace: stack);
    }
  }
}
