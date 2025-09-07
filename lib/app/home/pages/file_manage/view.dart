import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/string_utils.dart';
import 'package:photo_view/photo_view.dart';
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
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '文件管理',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        controller.currentPath = '/downloads';
                        await controller.initSourceData();
                      },
                      icon: Icon(
                        Icons.home_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        var pathList = controller.currentPath.split('/');
                        pathList.removeLast();
                        controller.currentPath = pathList.join("/");
                        await controller.initSourceData();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  controller.currentPath,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child:
                      GetBuilder<FileManageController>(builder: (controller) {
                    return Stack(
                      children: [
                        EasyRefresh(
                          onRefresh: () => controller.initSourceData(),
                          child: ListView.builder(
                            itemCount: controller.items.length,
                            itemBuilder: (BuildContext context, int index) {
                              var item = controller.items[index];
                              return CustomCard(
                                child: ListTile(
                                  title: Text(
                                    item.name,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item.modified,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      if (!item.isDir)
                                        Text(
                                          FileSizeConvert.parseToFileSize(
                                              item.size),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: item.isDir
                                        ? Icon(
                                            Icons.folder,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          )
                                        : Text(
                                            item.ext.toString(),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ),
                                  ),
                                  onTap: () async {
                                    if (item.isDir) {
                                      controller.currentPath = item.path;
                                      controller.isLoading = true;
                                      controller.update(['file_manage']);
                                      await controller.initSourceData();
                                      // controller.update(['file_manage']);
                                    } else {
                                      Logger.instance.d('非文件夹');
                                      CommonResponse res = await controller
                                          .getFileSourceUrl(item.path);
                                      Logger.instance.d(res.toString());
                                      if (res.succeed) {
                                        Clipboard.setData(
                                            ClipboardData(text: res.data));
                                        if (item.mimeType.startsWith('image')) {
                                          showImage(res.data);
                                        } else if (item.mimeType
                                            .startsWith('video')) {
                                          showPlayer(res.data);
                                        } else if (item.mimeType
                                            .startsWith('audio')) {
                                          showPlayer(res.data);
                                        } else {
                                          Get.snackbar(
                                            '提示',
                                            '不支持的文件类型：${item.mimeType}，访问链接已复制到剪切板',
                                            colorText: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          );
                                        }
                                      } else {
                                        Get.snackbar(
                                          '提示',
                                          res.msg,
                                          colorText: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        );
                                      }
                                    }
                                  },
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
                    );
                  }),
                ),
              ],
            ),
          );
        });
  }

  Map<String, String> buildSchemes(String url) {
    final schemes = <String, String>{};

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      schemes.addAll({
        'VLC': 'vlc://$url',
        'VidHub': 'vidhub://$url',
        'Infuse':
            'infuse://x-callback-url/play?url=${Uri.encodeComponent(url)}',
        'nPlayer': 'nplayer-$url', // 会自动转为 nplayer-http://
        'PlayerXtreme': 'playerxtreme://$url',
        'OPlayer': 'oplayer://$url',
        'KMPlayer': 'kmplayer://$url',
        'MXPlayer': 'mxplayer://$url',
      });
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      // macOS 上常见播放器只能通过 open -a 调用
      schemes.addAll({
        'IINA': 'iina://weblink?url=${Uri.encodeComponent(url)}',
        'VLC': 'vlc://$url', // 部分版本支持
        'Infuse': 'Infuse://$url', // 部分版本支持
      });
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      // Windows 常用 PotPlayer / VLC
      schemes.addAll({
        'VLC': 'vlc://$url', // 仅部分版本支持
        'PotPlayer': 'potplayer://$url', // PotPlayer 支持 URL Scheme
      });
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      schemes.addAll({
        'VLC': 'vlc://$url',
        'MPV': 'mpv://$url',
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
          await Process.run('vlc', [url]);
          break;
        case 'potplayer':
          await Process.run('potplayer', [url]);
          break;
        case 'mpc':
          await Process.run('mpc-hc', [url]);
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

  void showPlayer(String url) async {
    final schemes = buildSchemes(url);
    Get.defaultDialog(
      title: '打开方式',
      content: CustomCard(
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 10,
          runSpacing: 10,
          children: [
            if (defaultTargetPlatform == TargetPlatform.iOS)
              ...schemes.entries.toList().map(
                    (entry) => ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(entry.value);
                        if (!await launchUrl(uri,
                            mode: LaunchMode.externalApplication)) {
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
                    (entry) => ElevatedButton.icon(
                      onPressed: () async {
                        openWithPlayer(entry.key, url);
                      },
                      label: Text(
                        entry.key.toString(),
                      ),
                    ),
                  ),
            if (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)
              ElevatedButton.icon(
                onPressed: () async {
                  VlcPlayerController vlcController =
                      VlcPlayerController.network(
                    url,
                    hwAcc: HwAcc.full,
                    autoPlay: true,
                    options: VlcPlayerOptions(),
                  );

                  Get.defaultDialog(
                      title: '播放',
                      content: CustomCard(
                        width: Get.width,
                        child: VlcPlayer(
                          controller: vlcController,
                          aspectRatio: 16 / 9,
                          placeholder:
                              Center(child: CircularProgressIndicator()),
                        ),
                      )).whenComplete(() {
                    vlcController.stop();
                    vlcController.dispose();
                  });
                },
                icon: Icon(Icons.play_arrow_outlined),
                label: Text("播放"),
              ),
            ElevatedButton.icon(
              onPressed: () async {
                Get.snackbar('提示', '下载功能开发中，敬请期待');
                // await Dio().download(url);
              },
              icon: Icon(Icons.download_outlined),
              label: Text("下载"),
            ),
          ],
        ),
      ),
    );
  }

  void showImage(String url) {
    Get.defaultDialog(
      title: '海报预览',
      content: CustomCard(
        borderRadius: BorderRadius.circular(5),
        height: Get.height * 0.8,
        width: Get.width,
        child: InkWell(
          onTap: () => Get.back(),
          child: PhotoView(
            maxScale: 5.0,
            minScale: 0.8,
            imageProvider: CachedNetworkImageProvider(url),
          ),
        ),
      ),
    );
  }
}
