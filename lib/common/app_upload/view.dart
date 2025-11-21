import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:harvest/common/upgrade_widget/model.dart';
import 'package:install_plugin_v3/install_plugin_v3.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api.dart';
import '../../app/home/controller/home_controller.dart';
import '../../models/common_response.dart';
import '../../utils/dio_util.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../card_view.dart';
import '../form_widgets.dart';

class AppUploadPage extends StatelessWidget {
  final Widget? child;

  AppUploadPage({super.key, this.child});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    final buttonKey = GlobalKey();

    return GetBuilder<HomeController>(builder: (homeController) {
      return ShadPopover(
        controller: homeController.popoverController,
        closeOnTapOutside: false,
        popover: (context) => ShadTabs<String>(
          value: 'latestVersion',
          tabBarConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 50),
          contentConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
                          Text('当前版本：${homeController.currentVersion}',
                              style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                          Text('服务器版本：v${homeController.updateInfo?.version}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: homeController.updateInfo?.version == homeController.currentVersion
                                      ? shadColorScheme.foreground
                                      : shadColorScheme.destructive)),
                          GetBuilder<HomeController>(
                              id: 'progressValue',
                              builder: (controller) {
                                if (controller.progressValue != 0 && controller.progressValue < 1) {
                                  return Text(
                                      '正在下载: ${homeController.newVersion} ${(controller.progressValue * 100).toStringAsFixed(0)}%',
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
                              ...?homeController.updateInfo?.changelog.split('\n').map(
                                  (e) => Text(e, style: TextStyle(fontSize: 12, color: shadColorScheme.foreground))),
                              ...?homeController.updateInfo?.downloadLinks.entries
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
                                onPressed: () => homeController.popoverController.hide(),
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
                                onPressed: () => homeController.getAppLatestVersionInfo(),
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
                                child: Text(
                                    homeController.updateInfo?.version == homeController.currentVersion ? '重装' : '更新'),
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
                    color: homeController.updateInfo?.version == homeController.currentVersion
                        ? shadColorScheme.foreground
                        : shadColorScheme.destructive),
              ),
            ),
            if (homeController.authInfo?.username == 'ngfchl@126.com')
              ShadTab(
                value: 'versionUpload',
                content: GetBuilder<HomeController>(
                    id: 'versionUpload',
                    builder: (controller) {
                      return editAppUpdateForm(context);
                    }),
                child: Text('上传新版本', style: TextStyle(color: shadColorScheme.foreground)),
              ),
            ShadTab(
              value: 'versionList',
              content: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: homeController.appVersions.length,
                        itemBuilder: (context, index) {
                          RxBool showlog = false.obs;
                          AppUpdateInfo appUpdateInfo = homeController.appVersions[index];
                          return CustomCard(
                            color: shadColorScheme.background,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  dense: true,
                                  title: Text('v${appUpdateInfo.version}',
                                      style: TextStyle(
                                        color: shadColorScheme.foreground,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  subtitle: Obx(() {
                                    if (showlog.value) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(appUpdateInfo.changelog,
                                              style: TextStyle(color: shadColorScheme.foreground.withOpacity(0.7))),
                                          ...appUpdateInfo.downloadLinks.entries.map((e) => Builder(builder: (context) {
                                                final buttonKey = GlobalKey();
                                                return ShadButton.link(
                                                    key: buttonKey,
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () => doInstallationPackage(context, e, buttonKey),
                                                    child: Text(e.key, style: TextStyle(fontSize: 10)));
                                              }))
                                        ],
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                  onTap: () => showlog.value = !showlog.value,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () => homeController.popoverController.hide(),
                      leading: Icon(
                        Icons.close_outlined,
                        size: 16,
                      ),
                      child: Text('关闭'),
                    ),
                  ],
                ),
              ),
              child: Text('版本列表页面', style: TextStyle(color: shadColorScheme.foreground)),
            ),
          ],
        ),
        child: child ??
            ShadIconButton.ghost(
              icon: Icon(Icons.update,
                  size: 24,
                  color: homeController.updateInfo != null &&
                          homeController.updateInfo?.version != homeController.currentVersion
                      ? shadColorScheme.destructive
                      : shadColorScheme.foreground),
              onPressed: () async {
                if (homeController.updateInfo == null) {
                  await homeController.getAppLatestVersionInfo();
                }
                if (homeController.appVersions.isEmpty) {
                  await homeController.getAppVersionList();
                }
                homeController.popoverController.toggle();
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

  Widget editAppUpdateForm(BuildContext context) {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    TextEditingController changeLogController = TextEditingController(text: '');
    RxList<File> selectedFiles = <File>[].obs;
    if (kDebugMode) {
      changeLogController.text = '''
update. 更新版本号：2025.1120.01+183
update. 完成直连TR功能菜单
update. 完成直连QB功能菜单
fixed. 区分下载器直连与中转模式排序Key
update. 开始更新Transmission
update. 优化设置页面主题细节
fixed. 修复 qbittorrent 种子详情页未加载完时显示异常的 BUG
update. 优化APP升级页面下显示效果
update. 优化 Qbittorrent 直连
update. 优化启动时 APP 更新检测逻辑
update. 调整主题设置页面关闭逻辑
update. 恢复下载器智联模块
update. 微调APP升级模块
update. 添加有邀请站点列表
add. 完成APP更新发布界面
update. APP更新相关代码移出到指定文件
add. 添加七牛上传接口地址
fixed. 修复App更新日志访问失败导致升级窗口打开失败的BUG
''';
    }
    return GetBuilder<HomeController>(
        id: 'selectedFiles',
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              spacing: 10,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          CustomTextField(
                            maxLines: 10,
                            controller: changeLogController,
                            labelText: '更新日志',
                            scrollPhysics: const ScrollPhysics(),
                            maxLength: 4096,
                          ),
                          ListTile(
                            title: Text(
                              '安装包',
                              style: TextStyle(
                                fontSize: 12,
                                color: shadColorScheme.foreground,
                              ),
                            ),
                            trailing: ShadButton.ghost(
                                size: ShadButtonSize.sm,
                                leading: Icon(
                                  Icons.photo_library,
                                  size: 13,
                                  color: shadColorScheme.foreground,
                                ),
                                child: Text(
                                  '选择文件',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: shadColorScheme.foreground,
                                  ),
                                ),
                                onPressed: () async {
                                  const lastPathKey = 'last_file_picker_path';
                                  final lastPath = SPUtil.getLocalStorage(lastPathKey);
                                  final result = await FilePicker.platform.pickFiles(
                                    allowMultiple: true,
                                    initialDirectory: lastPath ?? Directory.current.path,
                                    type: FileType.custom,
                                    allowedExtensions: ['apk', 'ipa', 'zip', 'dmg'],
                                  );

                                  if (result != null) {
                                    Logger.instance.i('选择的文件: ${result.files}');
                                    final path = result.paths.first;
                                    Logger.instance.i('选择的文件路径: $path');
                                    final lastDirectory = path?.substring(0, path.lastIndexOf('/'));
                                    Logger.instance.i('选择的文件目录: $lastDirectory');
                                    SPUtil.setLocalStorage(lastPathKey, lastDirectory);
                                    selectedFiles.value = result.paths.map((path) => File(path!)).toList();
                                    Logger.instance.i('选择的文件: $selectedFiles');
                                    controller.update(['selectedFiles']);
                                  }
                                }),
                          ),
                          Obx(() {
                            if (selectedFiles.isNotEmpty) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: selectedFiles.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                      title: Text(
                                        selectedFiles[index].uri.pathSegments.last,
                                        style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                                      ),
                                      trailing: ShadIconButton.ghost(
                                          icon: Icon(Icons.close, size: 12, color: shadColorScheme.destructive),
                                          onPressed: () {
                                            selectedFiles.removeAt(index);
                                            controller.update(['selectedFiles']);
                                          }));
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],
                      ),
                      if (controller.uploading)
                        Center(child: CircularProgressIndicator(color: shadColorScheme.foreground)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    ShadButton.outline(
                      size: ShadButtonSize.sm,
                      onPressed: () => homeController.popoverController.hide(),
                      leading: Icon(
                        Icons.close_outlined,
                        size: 16,
                      ),
                      child: Text('关闭'),
                    ),
                    ShadButton(
                      size: ShadButtonSize.sm,
                      leading: controller.uploading
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: Center(child: CircularProgressIndicator(color: shadColorScheme.primaryForeground)))
                          : Icon(
                              Icons.upload_outlined,
                              size: 16,
                              color: shadColorScheme.primaryForeground,
                            ),
                      onPressed: () => uploadFiles(context, changeLogController.text, selectedFiles),
                      child: Text('上传'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

// 假设你已有 CommonResponse 类和 DioUtil
  Future<void> uploadFiles(BuildContext context, String changelog, List<File> files, {CancelToken? cancelToken}) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    homeController.uploading = true;
    homeController.update(['versionUpload']);

    try {
      Logger.instance.i('开始上传APP文件');
      // 2. 构建 FormData
      final formData = FormData();
      formData.fields.add(MapEntry('changelog', changelog));
      for (final platformFile in files) {
        final fileBytes = await platformFile.readAsBytes();
        formData.files.add(
          MapEntry(
            'files', // 必须与 Django 的 `files: List[UploadedFile] = File(...)` 字段名一致
            MultipartFile.fromBytes(
              fileBytes,
              filename: platformFile.path.split('/').last,
            ),
          ),
        );
      }
      Logger.instance.i('组装好FormData，开始上传');
      // 3. 调用你的 addData 方法（或直接用 Dio）
      final response = await DioUtil().post(
        Api.QINIU_UPLOAD_FILES,
        formData: formData,
        cancelToken: cancelToken,
      );
      Logger.instance.i('上传成功，返回数据: ${response.data}');
      homeController.uploading = false;
      homeController.update(['versionUpload']);
      CommonResponse? commonResponse;
      if (response.statusCode == 200) {
        commonResponse = CommonResponse.fromJson(response.data, (p0) => null);
      } else {
        String msg = '上传数据失败: ${response.statusCode}';
        commonResponse = CommonResponse.error(msg: msg);
      }
      if (commonResponse.succeed == true) {
        Logger.instance.i('✅ APP文件上传请求成功，链接已返回');
        homeController.popoverController.hide();
        Get.snackbar('✅ APP文件上传请求成功', commonResponse.msg, colorText: shadColorScheme.foreground);
      } else {
        Logger.instance.e('❌ APP上传失败: ${commonResponse.msg}');
        Get.snackbar('❌ APP文件上传失败', commonResponse.msg, colorText: shadColorScheme.destructive);
      }
    } catch (e, stack) {
      Logger.instance.e('上传异常: $e', error: e, stackTrace: stack);
      Get.snackbar('❌ APP文件上传失败', '上传异常: $e', colorText: shadColorScheme.destructive);
    }
  }

  /// 根据当前设备平台，从 downloadLinks 中返回最匹配的下载 URL
  Future getDownloadUrlForCurrentPlatform(BuildContext context, GlobalKey buttonKey) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final String prefix = 'harvest_${homeController.updateInfo?.version}';
    Map<String, String> downloadLinks = homeController.updateInfo?.downloadLinks ?? {};
    String? downloadUrl;
    Directory? appDocDir = await getTemporaryDirectory();

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
      appDocDir = await getExternalStorageDirectory();
      String savePath = "${appDocDir?.path}/${homeController.newVersion}";
      downloadUrl ??= downloadLinks[homeController.newVersion];
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await InstallPlugin.install(savePath);
    } else if (Platform.isIOS) {
      homeController.newVersion = '${prefix}_ios.ipa';

      downloadUrl = downloadLinks[homeController.newVersion];
      await downloadAndSaveWithFilePicker(downloadUrl!, homeController.newVersion, buttonKey);
    } else if (Platform.isWindows) {
      homeController.newVersion = '${prefix}_x86_64-win.zip';
      downloadUrl = downloadLinks[homeController.newVersion];
      String savePath = "${appDocDir.path}/${homeController.newVersion}";
      await _downloadInstallationPackage(savePath, downloadUrl!);
      await Process.run('explorer.exe', [savePath.replaceAll('/', '\\')]);
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

  Future<void> downloadAndSaveWithFilePicker(String fileUrl, String suggestedName, GlobalKey buttonKey) async {
    if (kIsWeb) return;

    // 显示“正在准备下载...”提示（因为要先加载到内存）
    homeController.progressValue = -1; // 可用 -1 表示“缓冲中”
    homeController.update(['progressValue']);

    try {
      // Step 1: 下载完整文件到内存（注意：大文件可能 OOM！）
      final response = await Dio().get<List<int>>(
        fileUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (count, total) {
          // 可选：显示预加载进度（但 saveFile 本身无进度）
          final value = count / total;
          if (value < 1.0) {
            homeController.progressValue = value;
            homeController.update(['progressValue']);
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
          homeController.progressValue = 1.0;
          homeController.update(['progressValue']);
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
      homeController.progressValue = 0.0;
      homeController.update(['progressValue']);
      Logger.instance.e('保存失败: $e', error: e, stackTrace: stack);
    }
  }
}
