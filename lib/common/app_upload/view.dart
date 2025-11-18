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
import '../form_widgets.dart';

class AppUploadPage extends StatelessWidget {
  final Widget? child;

  AppUploadPage({super.key, this.child});

  final popoverController = ShadPopoverController();
  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<HomeController>(builder: (homeController) {
      return ShadPopover(
        controller: popoverController,
        closeOnTapOutside: false,
        popover: (context) => ShadTabs<String>(
          value: 'latestVersion',
          tabBarConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 50),
          contentConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
          tabs: [
            ShadTab(
              value: 'latestVersion',
              content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('当前版本：${homeController.currentVersion}',
                              style: TextStyle(fontSize: 10, color: shadColorScheme.foreground)),
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
                                      style: TextStyle(fontSize: 10, color: shadColorScheme.foreground));
                                }
                                return const SizedBox.shrink();
                              }),
                        ],
                      ),
                    ), // TODO: 修改为百分比显示
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...?homeController.updateInfo?.changelog.split('\n').map((e) => Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(e, style: TextStyle(fontSize: 10, color: shadColorScheme.foreground)),
                                )),
                            ...?homeController.updateInfo?.downloadLinks.entries.map((e) => Builder(builder: (context) {
                                  final buttonKey = GlobalKey();
                                  return ShadButton.link(
                                      key: buttonKey,
                                      onPressed: () => doInstallationPackage(context, e, buttonKey),
                                      child: Text(e.key, style: TextStyle(fontSize: 10)));
                                }))
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ShadButton(
                          size: ShadButtonSize.sm,
                          onPressed: () => getDownloadUrlForCurrentPlatform(context),
                          child:
                              Text(homeController.updateInfo?.version == homeController.currentVersion ? '重新安装' : '更新'),
                        ),
                      ],
                    ),
                  ]),
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
                content: GetBuilder<HomeController>(builder: (controller) {
                  return editAppUpdateForm(context);
                }),
                child: Text('上传新版本', style: TextStyle(color: shadColorScheme.foreground)),
              ),
            ShadTab(
              value: 'versionList',
              content: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: homeController.appVersions.length,
                      itemBuilder: (context, index) {
                        RxBool showlog = false.obs;
                        AppUpdateInfo appUpdateInfo = homeController.appVersions[index];
                        return Column(
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
                        );
                      },
                    ),
                  ),
                ],
              ),
              child: Text('版本列表页面', style: TextStyle(color: shadColorScheme.foreground)),
            ),
          ],
        ),
        child: child ??
            ShadIconButton.ghost(
              icon: Icon(Icons.update,
                  size: 24,
                  color: homeController.updateInfo?.version == homeController.currentVersion
                      ? shadColorScheme.foreground
                      : shadColorScheme.destructive),
              onPressed: () async {
                if (!popoverController.isOpen) {
                  await homeController.getAppLatestVersionInfo();
                  await homeController.getAppVersionList();
                }
                popoverController.toggle();
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
update. 更新版本号：2025.1116.01+182
fixed. 修复windows下打开更新包位置
update. 优化调整移动端安装包下载
update. 优化调整顶栏按钮
update. 调整更新依赖版本
update. 更新模块增加自动检测当前平台并下载更新包
add. 添加新依赖：install_plugin_v3、device_info_plus
update. 优化仪表盘数据重载方法
update. 优化main方法依赖加载
update. 调整搜索结果条目长按客户端进入浏览器，浏览器打开新页面
fixed. 修复点击搜索项目偶现无法打开下载窗口的BUG
update. 打包ipa命名添加ios标志
update. 内置浏览器完善种子详情页种子小标题抓取
update. 优化下拉刷新的提示文字显示
''';
    }
    return GetBuilder<HomeController>(
        id: 'selectedFiles',
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
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
                        Center(
                            child: CircularProgressIndicator(
                          color: shadColorScheme.foreground,
                          strokeWidth: 2,
                        )),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    ShadButton(
                      size: ShadButtonSize.sm,
                      child: Text('上传'),
                      onPressed: () => uploadFiles(changeLogController.text, selectedFiles),
                    ),
                    ShadButton(
                        size: ShadButtonSize.sm,
                        child: Text('保存'),
                        onPressed: () async {
                          // String version = versionController.text;
                          // Map<String, String> downloadLinks = controller.selectedFiles.asMap().map((index, file) =>
                          //     MapEntry(file.uri.pathSegments.last,
                          //         'http://file.ptools.fun/app/$version/${file.uri.pathSegments.last}'));
                          // downloadLinksController.text = jsonEncode(downloadLinks);
                          // await controller.uploadFiles(version);
                        }),
                  ],
                ),
              ],
            ),
          );
        });
  }

  // 假设你已有 CommonResponse 类和 DioUtil
  Future<CommonResponse?> uploadFiles(String changelog, List<File> files, {CancelToken? cancelToken}) async {
    homeController.uploading = true;
    homeController.update(['selectFiles']);

    try {
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

      // 3. 调用你的 addData 方法（或直接用 Dio）
      final response = await DioUtil().post(
        Api.QINIU_UPLOAD_FILES,
        formData: formData,
        cancelToken: cancelToken,
      );
      homeController.uploading = false;
      homeController.update(['selectFiles']);
      CommonResponse? commonResponse;
      if (response.statusCode == 200) {
        commonResponse = CommonResponse.fromJson(response.data, (p0) => null);
      } else {
        String msg = '上传数据失败: ${response.statusCode}';
        commonResponse = CommonResponse.error(msg: msg);
      }
      if (commonResponse.succeed == true) {
        Logger.instance.i('✅ 文件上传请求成功，链接已返回');
        // response.data 应该是 { "harvest_v1.0.apk": "http://...", ... }
        return commonResponse;
      } else {
        Logger.instance.e('❌ 上传失败: ${commonResponse.msg}');
        return commonResponse;
      }
    } catch (e, stack) {
      Logger.instance.e('上传异常: $e', error: e, stackTrace: stack);
      return CommonResponse.error(msg: '上传过程中发生错误: $e');
    }
  }

  /// 根据当前设备平台，从 downloadLinks 中返回最匹配的下载 URL
  Future getDownloadUrlForCurrentPlatform(BuildContext context) async {
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
      // downloadUrl = downloadLinks['${prefix}_ios.ipa'];
      downloadUrl = 'https://testflight.apple.com/join/kwLil5xf';
      await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
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
        // await Share.shareXFiles(
        //   [XFile(savePath)],
        //   subject: '安装包',
        //   text: '请通过“文件”App 安装此应用',
        // );

        Logger.instance.i('✅ 已分享文件，用户可保存到“文件”App');
      }
    } catch (e, stack) {
      homeController.progressValue = 0.0;
      homeController.update(['progressValue']);
      Logger.instance.e('保存失败: $e', error: e, stackTrace: stack);
    }
  }
}
