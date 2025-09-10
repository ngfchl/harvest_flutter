import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/storage.dart';
import 'package:harvest/utils/string_utils.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/logger_helper.dart';
import 'controller.dart';

class FileManagePage extends StatelessWidget {
  FileManagePage({super.key});

  final FileManageController controller = Get.put(FileManageController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FileManageController>(
        id: 'file_manage',
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text(
              //   '文件管理',
              //   style: TextStyle(
              //     color: ShadTheme.of(context).colorScheme.foreground,
              //   ),
              // ),
              CustomCard(
                child: Text(
                  controller.currentPath,
                  style: TextStyle(
                    fontSize: 10,
                    color: ShadTheme.of(context).colorScheme.foreground,
                  ),
                ),
              ),
              CustomCard(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () async {
                        controller.currentPath = '/downloads';
                        await controller.initSourceData();
                      },
                      icon: Icon(
                        Icons.home_outlined,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        controller.isLoading = true;
                        controller.update(['file_manage']);
                        await controller.initSourceData();
                      },
                      icon: Icon(
                        Icons.refresh,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (controller.currentPath == '/downloads') {
                          return;
                        }
                        controller.isLoading = true;
                        controller.update(['file_manage']);
                        var pathList = controller.currentPath.split('/');
                        pathList.removeLast();
                        controller.currentPath = pathList.join("/");
                        await controller.initSourceData();
                      },
                      icon: Icon(
                        Icons.arrow_upward_outlined,
                        color: ShadTheme.of(context).colorScheme.foreground,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    EasyRefresh(
                      onRefresh: () => controller.initSourceData(),
                      child: controller.items.isEmpty
                          ? Center(
                              child: SingleChildScrollView(
                                child: Text(
                                  '暂无文件',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ShadTheme.of(context).colorScheme.foreground,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: controller.items.length,
                              itemBuilder: (BuildContext context, int index) {
                                var item = controller.items[index];
                                return CustomCard(
                                  child: Slidable(
                                    key: ValueKey(item.path),
                                    startActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          flex: 1,
                                          // padding: EdgeInsets.all(8),
                                          icon: Icons.delete_outline,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                          onPressed: (context) async {
                                            TextEditingController nameController =
                                                TextEditingController(text: item.name);
                                            Get.defaultDialog(
                                              title: '重命名',
                                              radius: 5,
                                              titleStyle: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                                              middleText: '确定要重新命名吗？',
                                              content: CustomTextField(controller: nameController, labelText: "重命名为"),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Get.back(result: false);
                                                  },
                                                  child: const Text('取消'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Get.back(result: true);
                                                    doFileAction(item.path, 'rename_dir', newFileName: "newFileName");
                                                  },
                                                  child: const Text('确认'),
                                                ),
                                              ],
                                            );
                                          },
                                          backgroundColor: const Color(0xFF0A9D96),
                                          foregroundColor: Colors.white,
                                          label: '重命名',
                                        ),
                                      ],
                                    ),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      extentRatio: 0.25,
                                      children: [
                                        SlidableAction(
                                          flex: 1,
                                          icon: Icons.delete_outline,
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                          onPressed: (context) async {
                                            Get.defaultDialog(
                                              title: '确认',
                                              radius: 5,
                                              titleStyle: const TextStyle(
                                                  fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                                              middleText: '确定要删除任务吗？',
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Get.back(result: false);
                                                  },
                                                  child: const Text('取消'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Get.back(result: true);
                                                    // CommonResponse res =
                                                    // await controller.removeDownloader(downloader);
                                                    // if (res.code == 0) {
                                                    //   Get.snackbar('删除通知', res.msg.toString(),
                                                    //       colorText: ShadTheme.of(context).colorScheme.foreground);
                                                    // } else {
                                                    //   Get.snackbar('删除通知', res.msg.toString(),
                                                    //       colorText: Get.theme.colorScheme.error);
                                                    // }
                                                    // await controller.getDownloaderListFromServer(
                                                    //     withStatus: true);
                                                  },
                                                  child: const Text('确认'),
                                                ),
                                              ],
                                            );
                                          },
                                          backgroundColor: const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          // icon: Icons.delete,
                                          label: '删除',
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        item.name,
                                        style: TextStyle(
                                          color: ShadTheme.of(context).colorScheme.foreground,
                                        ),
                                      ),
                                      subtitle: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.modified,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: ShadTheme.of(context).colorScheme.foreground,
                                            ),
                                          ),
                                          if (!item.isDir)
                                            Text(
                                              FileSizeConvert.parseToFileSize(item.size),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: ShadTheme.of(context).colorScheme.foreground,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: CircleAvatar(
                                        backgroundColor: Colors.transparent,
                                        child: item.isDir
                                            ? Icon(
                                                Icons.folder,
                                                color: ShadTheme.of(context).colorScheme.foreground,
                                              )
                                            : Text(
                                                item.ext.toString(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ShadTheme.of(context).colorScheme.foreground,
                                                ),
                                              ),
                                      ),
                                      onLongPress: () {
                                        Get.defaultDialog(
                                          title: '常用操作',
                                          content: CustomCard(
                                            child: Wrap(
                                              alignment: WrapAlignment.spaceAround,
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                // ElevatedButton.icon(
                                                //   onPressed: () async {},
                                                //   icon: Icon(Icons.open_in_new),
                                                //   label: Text("打开目录"),
                                                // ),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    doFileAction(item.path, 'search_tmdb');
                                                  },
                                                  icon: Icon(Icons.movie_filter_outlined),
                                                  label: Text("刮削资源"),
                                                ),
                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    doFileAction(item.path, 'search_seed');
                                                  },
                                                  icon: Icon(Icons.local_movies_outlined),
                                                  label: Text("查询做种"),
                                                ),

                                                ElevatedButton.icon(
                                                  onPressed: () async {
                                                    doFileAction(item.path, 'hard_link', newFileName: "newFileName");
                                                  },
                                                  icon: Icon(Icons.hardware),
                                                  label: Text("硬链接"),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      onTap: () async {
                                        if (item.isDir) {
                                          controller.isLoading = true;
                                          controller.update(['file_manage']);
                                          controller.currentPath = item.path;
                                          await controller.initSourceData();
                                        } else {
                                          Logger.instance.d('文件后缀名：${item.ext}，文件类型：${item.mimeType}');
                                          CommonResponse res = await controller.getFileSourceUrl(item.path);
                                          Logger.instance.d(res.toString());
                                          if (res.succeed) {
                                            Clipboard.setData(ClipboardData(text: res.data));
                                            if (item.mimeType.startsWith('image')) {
                                              showImage(res.data);
                                            } else if (item.mimeType.startsWith('video')) {
                                              showPlayer(res.data, context);
                                            } else if (item.mimeType.startsWith('audio')) {
                                              showPlayer(res.data, context);
                                            } else {
                                              Get.defaultDialog(
                                                title: '文件操作',
                                                content: CustomCard(
                                                  child: Wrap(
                                                    alignment: WrapAlignment.spaceAround,
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: [
                                                      ElevatedButton.icon(
                                                        onPressed: () async {
                                                          await pickAndDownload(res.data);
                                                        },
                                                        icon: Icon(Icons.download_outlined),
                                                        label: Text("下载"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            Get.snackbar(
                                              '提示',
                                              res.msg,
                                              colorText: Get.theme.colorScheme.error,
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    if (controller.isLoading)
                      Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  /*///@title
  ///@description TODO 文件操作
  ///@updateTime
   */
  doFileAction(String path, String action, {String? newFileName}) {}

  Map<String, String> buildSchemes(String url) {
    final schemes = <String, String>{};

    var encodeUrl = Uri.encodeComponent(url);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      schemes.addAll({
        'VLC': 'vlc://$encodeUrl',
        'VidHub': 'open-vidhub://x-callback-url/open?url=$encodeUrl',
        'FileBar': 'filebox://play?url=$encodeUrl',
        'SenPlayer': 'SenPlayer://x-callback-url/play?url=$encodeUrl',
        'Infuse': 'infuse://x-callback-url/play?url=$encodeUrl',
      });
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      // macOS 上常见播放器只能通过 open -a 调用
      schemes.addAll({
        'IINA': 'iina://weblink?url=$encodeUrl',
        'VLC': 'vlc://$encodeUrl', // 部分版本支持
        'Infuse': 'Infuse://$encodeUrl', // 部分版本支持
      });
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      // Windows 常用 PotPlayer / VLC
      schemes.addAll({
        'VLC': 'vlc://$encodeUrl', // 仅部分版本支持
        'PotPlayer': 'potplayer://$encodeUrl', // PotPlayer 支持 URL Scheme
      });
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      schemes.addAll({
        'VLC': 'vlc://$encodeUrl',
        'MPV': 'mpv://$encodeUrl',
      });
    }

    return schemes;
  }

  /// 调用桌面端外部播放器
  Future<void> openWithPlayer(String player, String url) async {
    if (Platform.isMacOS) {
      // macOS: 使用 open -a 调用应用
      switch (player.toLowerCase()) {
        case 'vlc':
          await Process.run('open', ['-a', 'VLC', url]);
          break;
        case 'iina':
          Logger.instance.d('调用 iina');
          var res = await Process.run(
            '/Applications/IINA.app/Contents/MacOS/iina-cli',
            [url],
          );
          // await Process.run('open', ['-a', '/Applications/IINA.app', url]);
          Logger.instance.d('调用 iina 结果: ${res.stdout} \n ${res.stderr}');
          break;
        case 'infuse':
          await Process.run('open', ['-a', 'infuse', url]);
          break;
        case 'mpv':
          await Process.run('open', ['-a', 'mpv', url]);
          break;
        default:
          throw Exception("未支持的播放器: $player");
      }
    } else if (Platform.isWindows) {
      // Windows: 直接调用可执行文件 (需在 PATH 或已知安装路径)
      switch (player.toLowerCase()) {
        case 'vlc':
          Uri encodedUrl = Uri.parse('vlc-x-callback://${Uri.encodeComponent(url)}');
          Logger.instance.d(await canLaunchUrl(encodedUrl));
          if (await canLaunchUrl(encodedUrl)) {
            await launchUrl(encodedUrl, mode: LaunchMode.externalApplication);
          } else {
            await Process.start('C:\\Program Files\\VideoLAN\\VLC\\vlc.exe', [url]);
          }
          break;
        case 'potplayer':
          Uri encodedUrl = Uri.parse('potplayer://$url');
          if (await canLaunchUrl(encodedUrl)) {
            await launchUrl(encodedUrl, mode: LaunchMode.externalApplication);
          }
          break;
        case 'mpc':
          Uri encodedUrl = Uri.parse('mpc-hc://$url');
          if (await canLaunchUrl(encodedUrl)) {
            await launchUrl(encodedUrl, mode: LaunchMode.externalApplication);
          }
          break;
        default:
          throw Exception("未支持的播放器: $player");
      }
    } else if (Platform.isLinux) {
      // Linux: 常见播放器
      switch (player.toLowerCase()) {
        case 'vlc':
          await Process.run('vlc', [url]);
          break;
        case 'mpv':
          await Process.run('mpv', [url]);
          break;
        case 'smplayer':
          await Process.run('smplayer', [url]);
          break;
        default:
          throw Exception("未支持的播放器: $player");
      }
    } else {
      throw Exception("当前平台不支持外部调用: ${Platform.operatingSystem}");
    }
  }

  void showPlayer(String url, BuildContext context) async {
    final schemes = buildSchemes(url);
    var opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
      title: '打开方式',
      titleStyle: TextStyle(color: shadColorScheme.foreground),
      backgroundColor: shadColorScheme.background.withOpacity(opacity),
      content: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 10,
        runSpacing: 10,
        children: [
          if (defaultTargetPlatform == TargetPlatform.iOS)
            ...schemes.entries.toList().map(
                  (entry) => ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(entry.value);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        Logger.instance.w('无法使用${entry.key}外部播放器');
                      }
                    },
                    label: Text(
                      entry.key.toString(),
                    ),
                  ),
                ),
          if (defaultTargetPlatform == TargetPlatform.android)
            ElevatedButton.icon(
              onPressed: () async {
                final intent = AndroidIntent(
                  action: 'action_view',
                  data: url,
                  type: 'video/*',
                );
                intent.launch();
              },
              icon: Icon(Icons.open_in_new_rounded),
              label: Text('打开'),
            ),
          if (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows)
            ...schemes.entries.toList().map(
                  (entry) => ShadButton.outline(
                    onPressed: () async {
                      openWithPlayer(entry.key, url);
                    },
                    child: Text(
                      entry.key.toString(),
                    ),
                  ),
                ),
          if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)
            ElevatedButton.icon(
              onPressed: () async {
                VlcPlayerController vlcController = VlcPlayerController.network(
                  url,
                  hwAcc: HwAcc.full,
                  autoPlay: true,
                  options: VlcPlayerOptions(),
                );

                Get.dialog(
                  CustomCard(
                    width: double.infinity,
                    height: Get.height * 0.7,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: VlcPlayer(
                            controller: vlcController,
                            aspectRatio: 16 / 9,
                            placeholder: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    vlcController.play();
                                  },
                                  icon: Icon(Icons.play_arrow_outlined)),
                              IconButton(
                                  onPressed: () {
                                    vlcController.pause();
                                  },
                                  icon: Icon(Icons.pause_outlined)),
                              IconButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  icon: Icon(Icons.exit_to_app_outlined)),
                              IconButton(onPressed: () {}, icon: Icon(Icons.fullscreen_outlined)),
                              IconButton(onPressed: () {}, icon: Icon(Icons.fullscreen_exit_outlined)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  barrierDismissible: false,
                ).whenComplete(() {
                  vlcController.stop();
                  vlcController.dispose();
                });
              },
              icon: Icon(Icons.play_arrow_outlined),
              label: Text("播放"),
            ),
          ShadButton.outline(
            onPressed: () async {
              await pickAndDownload(url);
            },
            leading: Icon(Icons.download_outlined),
            child: Text("下载"),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndDownload(String url) async {
    RxDouble progress = 0.0.obs; // 0 ~ 100
    RxBool downloading = false.obs;
    // 1. 权限

    if (GetPlatform.isMobile &&
        await Permission.storage.request().isDenied &&
        await Permission.photos.request().isDenied) {
      Get.snackbar('权限失败', '需要存储权限');
      return;
    }

    /// 选择保存位置并下载
    // 1. 系统文件选择器（无需 Get.dialog）
    Logger.instance.w('文件名: ${Uri.parse(url).pathSegments.last.split('/').last}');
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: '选择保存位置',
      fileName: Uri.parse(url).pathSegments.last.split('/').last,
    );
    if (savePath == null) return; // 用户取消

    // 2. 下载（带 GetX 加载圈）
    Get.dialog(
      Center(child: Obx(() {
        return CircularProgressIndicator(
          value: progress.value / 100,
          strokeWidth: 2,
        );
      })),
      barrierDismissible: false,
      name: '下载到',
    );

    try {
      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          progress.value = (received / total * 100).toDouble();
        },
      );
      // 4. 成功
      Get.back(); // 关闭加载圈
      Get.snackbar('完成', '文件已保存到 $savePath');
    } catch (e) {
      Get.back();
      Get.snackbar('失败', e.toString());
    } finally {
      downloading.value = false;
      progress.value = 0;
    }
  }

  void showImage(String url) {
    Get.dialog(
      CustomCard(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  child: PhotoView(
                    maxScale: PhotoViewComputedScale.covered * 5, // 允许用户放大
                    minScale: PhotoViewComputedScale.contained,
                    initialScale: PhotoViewComputedScale.contained, // 默认显示整个图片
                    imageProvider:
                        CachedNetworkImageProvider(url, cacheKey: Uri.parse(url).pathSegments.last.split('/').last),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (GetPlatform.isDesktop || GetPlatform.isWeb) {
                        await pickAndDownload(url);
                      } else {
                        if (GetPlatform.isAndroid) {
                          if (!await Permission.storage.request().isGranted ||
                              !await Permission.photos.request().isGranted) {
                            Get.snackbar('权限失败', '需要存储权限以保存图片');
                            return;
                          }
                        } else if (GetPlatform.isIOS) {
                          final status = await Permission.photosAddOnly.status;
                          Logger.instance.d('photosAddOnly status: $status');
                          if (!status.isGranted) {
                            Get.snackbar('权限失败', '需要相册写入权限');
                            return;
                          }
                        }
                        // Get.dialog(
                        //   const Center(child: CircularProgressIndicator()),
                        //   barrierDismissible: false,
                        //   name: 'album_download',
                        // );

                        try {
                          // 1. 先下到临时目录
                          final tempDir = await getTemporaryDirectory();
                          final tempFile = File('${tempDir.path}/${Uri.parse(url).pathSegments.last.split('/').last}');
                          Logger.instance.d('临时文件URL: ${Uri.parse(url).pathSegments.last.split('/').last}');
                          Logger.instance.d('临时文件保存路径: ${tempFile.path}');
                          await Dio().download(url, tempFile.path);

                          // 2. 写相册（自动区分 iOS/Android）
                          final result = await ImageGallerySaverPlus.saveFile(tempFile.path);
                          Get.back(); // 关闭加载圈

                          if (result['isSuccess'] == true) {
                            Get.snackbar('✅ 已保存', '图片已存入系统相册');
                          } else {
                            Logger.instance.e(result['errorMessage']);
                            Get.snackbar('❌ 保存失败', '保存失败!!!!!');
                          }
                        } catch (e) {
                          Get.back();
                          Logger.instance.e(e);
                          Get.snackbar('❌ 下载失败', '❌ 下载失败');
                        }
                      }
                    },
                    icon: Icon(Icons.save_alt_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.exit_to_app_outlined),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
