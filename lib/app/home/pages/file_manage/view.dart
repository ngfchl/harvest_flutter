import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/string_utils.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../api/tmdb.dart';
import '../../../../common/media_card.dart';
import '../../../../common/video_player_page/video_page.dart';
import '../../../../utils/logger_helper.dart';
import '../models/source.dart';
import '../models/tmdb.dart';
import 'controller.dart';

class FileManagePage extends StatelessWidget {
  FileManagePage({super.key});

  final FileManageController controller = Get.put(FileManageController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FileManageController>(
        id: 'file_manage',
        builder: (controller) {
          List<String> pathList = controller.currentPath.replaceFirst('/.hardlink', '').split('/');

          var shadColorScheme = ShadTheme.of(context).colorScheme;
          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ShadIconButton.ghost(
                  onPressed: () async {
                    controller.currentPath = '/downloads';
                    await controller.initSourceData();
                  },
                  icon: Icon(
                    Icons.home_outlined,
                    color: shadColorScheme.primary,
                    size: 24,
                  ),
                ),
                ShadIconButton.ghost(
                  onPressed: () async {
                    controller.isLoading = true;
                    controller.update(['file_manage']);
                    await controller.initSourceData(noCache: true);
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: shadColorScheme.primary,
                    size: 24,
                  ),
                ),
                ShadIconButton.ghost(
                  onPressed: () => controller.onBackPressed(),
                  icon: Icon(
                    Icons.arrow_back_outlined,
                    color: shadColorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
            body: Column(
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
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 1,
                      children: [
                        for (int i = 0; i < pathList.length; i++) ...[
                          if (pathList[i].isNotEmpty)
                            ShadButton.ghost(
                              size: ShadButtonSize.sm,
                              padding: EdgeInsets.symmetric(horizontal: 1),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 120),
                                child: Tooltip(
                                  message: pathList[i],
                                  child: EllipsisText(
                                    text: "/${pathList[i]}",
                                    ellipsis: '...',
                                    maxLines: 1,
                                    isShowMore: false,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: shadColorScheme.foreground,
                                    ),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                // 点击返回到某层的逻辑
                                String path = pathList.sublist(0, i + 1).join('/');
                                Logger.instance.d("跳转到: $path");
                                controller.isLoading = true;
                                controller.update(['file_manage']);
                                controller.currentPath = path;
                                await controller.initSourceData();
                              },
                            ),
                        ]
                      ],
                    )),
                Expanded(
                  child: Stack(
                    children: [
                      EasyRefresh(
                        header: ClassicHeader(
                          dragText: '下拉刷新...',
                          readyText: '松开刷新',
                          processingText: '正在刷新...',
                          processedText: '刷新完成',
                          textStyle: TextStyle(
                            fontSize: 16,
                            color: shadColorScheme.foreground,
                            fontWeight: FontWeight.bold,
                          ),
                          messageStyle: TextStyle(
                            fontSize: 12,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                        onRefresh: () => controller.initSourceData(),
                        child: controller.items.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  child: Text(
                                    '暂无文件',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: shadColorScheme.foreground,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: controller.items.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var item = controller.items[index];
                                  return buildCustomCard(item, shadColorScheme, context);
                                },
                              ),
                      ),
                      if (controller.isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildCustomCard(SourceItemView item, ShadColorScheme shadColorScheme, BuildContext context) {
    return GetBuilder<FileManageController>(
        id: 'file_manage_${item.path}',
        builder: (controller) {
          return RepaintBoundary(
            child: CustomCard(
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
                      borderRadius:
                          const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                      onPressed: (context) async {
                        TextEditingController nameController = TextEditingController(text: item.name);
                        Get.defaultDialog(
                          title: '重命名',
                          radius: 5,
                          titleStyle:
                              const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                          middleText: '确定要重新命名吗？',
                          backgroundColor: shadColorScheme.background,
                          content: CustomTextField(controller: nameController, labelText: "重命名为"),
                          actions: [
                            ShadButton.outline(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: const Text('取消'),
                            ),
                            ShadButton.destructive(
                              onPressed: () async {
                                Get.back(result: true);
                                CommonResponse res = await controller.edisSource(item.path, nameController.text);
                                if (res.succeed) {
                                  ShadToaster.of(context).show(
                                    ShadToast(title: const Text('成功啦'), description: Text(res.msg)),
                                  );
                                  await controller.initSourceData(noCache: true);
                                } else {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text(res.msg),
                                    ),
                                  );
                                }
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
                      borderRadius:
                          const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                      onPressed: (context) async {
                        Get.defaultDialog(
                          title: '确认',
                          radius: 5,
                          titleStyle:
                              const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                          middleText: '确定要删除文件吗？',
                          actions: [
                            ShadButton.outline(
                              onPressed: () {
                                Get.back(result: false);
                              },
                              child: Text(
                                '取消',
                                style: TextStyle(color: shadColorScheme.destructiveForeground),
                              ),
                            ),
                            ShadButton.destructive(
                              onPressed: () async {
                                Get.back(result: true);
                                CommonResponse res = await controller.removeSource(item.path);
                                if (res.succeed) {
                                  ShadToaster.of(context).show(
                                    ShadToast(title: const Text('成功啦'), description: Text(res.msg)),
                                  );
                                  var r = controller.items.remove(item);
                                  Logger.instance.d(r);
                                  controller.update(["file_manage"]);
                                  await controller.initSourceData(noCache: true);
                                } else {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text(res.msg),
                                    ),
                                  );
                                }
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
                  title: EllipsisText(
                    text: item.name,
                    ellipsis: '...',
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 12,
                      color: shadColorScheme.foreground,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.modified,
                        style: TextStyle(
                          fontSize: 11,
                          color: shadColorScheme.foreground,
                        ),
                      ),
                      if (!item.isDir)
                        Text(
                          FileSizeConvert.parseToFileSize(item.size),
                          style: TextStyle(
                            fontSize: 12,
                            color: shadColorScheme.foreground,
                          ),
                        ),
                    ],
                  ),
                  trailing: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: buildItemWidget(item, shadColorScheme),
                  ),
                  onLongPress: () {
                    Get.defaultDialog(
                      title: '常用操作',
                      titleStyle: TextStyle(color: shadColorScheme.foreground),
                      backgroundColor: shadColorScheme.background,
                      content: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          //  ShadButton.ghost(
                          //   onPressed: () async {},
                          //   icon: Icon(Icons.open_in_new, color: shadColorScheme.foreground,
                          //                     size: 16,),
                          //   label: Text("打开目录"),
                          // ),
                          if (item.isDir) ...[
                            ShadButton.ghost(
                              onPressed: () async {
                                Get.back();
                                RxBool unlinkExisting = false.obs;
                                Get.defaultDialog(
                                  title: '硬链接',
                                  content: SwitchTile(
                                      title: '重建',
                                      value: unlinkExisting.value,
                                      onChanged: (v) => unlinkExisting.value = v),
                                  actions: [
                                    ShadButton.ghost(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text('取消'),
                                    ),
                                    ShadButton.outline(
                                      onPressed: () async {
                                        Get.back();
                                        CommonResponse res = await controller.hardLinkSource(item.path,
                                            unlinkExisting: unlinkExisting.value);

                                        ShadToaster.of(context).show(
                                          res.succeed
                                              ? ShadToast(title: const Text('成功啦'), description: Text(res.msg))
                                              : ShadToast.destructive(
                                                  title: const Text('出错啦'), description: Text(res.msg)),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                              leading: Icon(
                                Icons.movie_filter_outlined,
                                color: shadColorScheme.foreground,
                                size: 16,
                              ),
                              child: Tooltip(message: item.path, child: Text("硬链接")),
                            ),
                            ShadButton.ghost(
                              onPressed: () async {
                                Get.back();
                                controller.isLoading = true;
                                controller.update(['file_manage']);
                                var response = await getTMDBMatchMovieApi(item.name);
                                controller.isLoading = false;
                                controller.update(['file_manage']);
                                if (!response.succeed) {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text(response.msg),
                                    ),
                                  );
                                  return;
                                }
                                if (response.data != null && response.data!.isEmpty) {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text('未查询到相关影视信息！'),
                                    ),
                                  );
                                  return;
                                }
                                Logger.instance.d(response.data);
                                Get.defaultDialog(
                                  title: '影视信息查询结果',
                                  titleStyle: TextStyle(color: shadColorScheme.foreground),
                                  backgroundColor: shadColorScheme.background,
                                  content: SizedBox(
                                    height: 500,
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                        shrinkWrap: true, // 👈 关键，避免无限高度
                                        itemCount: response.data is List ? response.data!.length : 0,
                                        itemBuilder: (context, index) {
                                          MediaItem media = MediaItem.fromJson(response.data![index]);
                                          return MediaItemCard(
                                            media: media,
                                            onDetail: (media) {},
                                            onSearch: (media) async {},
                                            onTap: () {
                                              Get.defaultDialog(
                                                backgroundColor: shadColorScheme.background,
                                                radius: 10,
                                                title: "写入刮削信息中...",
                                                titleStyle: TextStyle(fontSize: 16, color: shadColorScheme.foreground),
                                                content: Text("是否确认写入刮削信息？"),
                                                confirm: ShadButton.destructive(
                                                  size: ShadButtonSize.sm,
                                                  child: Text("确定"),
                                                  onPressed: () async {
                                                    Get.back();
                                                    var response =
                                                        await controller.writeScrapeInfoApi(item.path, media);
                                                    if (!response.succeed) {
                                                      ShadToaster.of(context).show(
                                                        ShadToast.destructive(
                                                          title: const Text('出错啦'),
                                                          description: Text(response.msg),
                                                        ),
                                                      );
                                                    } else {
                                                      ShadToaster.of(context).show(
                                                        ShadToast(
                                                            title: const Text('成功啦'), description: Text(response.msg)),
                                                      );
                                                    }
                                                  },
                                                ),
                                                cancel: ShadButton.outline(
                                                  size: ShadButtonSize.sm,
                                                  child: Text("取消"),
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                  ),
                                );
                              },
                              leading: Icon(
                                Icons.movie_filter_outlined,
                                color: shadColorScheme.foreground,
                                size: 16,
                              ),
                              child: Text("电影刮削"),
                            ),
                            ShadButton.ghost(
                              onPressed: () async {
                                Get.back();
                                controller.isLoading = true;
                                controller.update(['file_manage']);
                                var response = await getTMDBMatchTvApi(item.name);
                                controller.isLoading = false;
                                controller.update(['file_manage']);
                                if (!response.succeed) {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text(response.msg),
                                    ),
                                  );
                                  return;
                                }
                                if (response.data!.isEmpty) {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('出错啦'),
                                      description: Text('未查询到相关影视信息！'),
                                    ),
                                  );
                                  return;
                                }
                                Logger.instance.d(response.data);
                                Get.defaultDialog(
                                    title: '影视信息查询结果',
                                    titleStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 16),
                                    backgroundColor: shadColorScheme.background,
                                    content: SizedBox(
                                        height: 500,
                                        width: double.maxFinite,
                                        child: ListView.builder(
                                            shrinkWrap: true, // 👈 关键，避免无限高度
                                            itemCount: response.data is List ? response.data!.length : 0,
                                            itemBuilder: (context, index) {
                                              MediaItem media = MediaItem.fromJson(response.data![index]);
                                              return MediaItemCard(
                                                media: media,
                                                onDetail: (media) {},
                                                onSearch: (media) async {},
                                                onTap: () async {
                                                  Get.defaultDialog(
                                                    title: "写入刮削信息中...",
                                                    content: Text("是否确认写入刮削信息？"),
                                                    onConfirm: () async {
                                                      Get.back();
                                                      var response =
                                                          await controller.writeScrapeInfoApi(item.path, media);
                                                      if (!response.succeed) {
                                                        ShadToaster.of(context).show(
                                                          ShadToast.destructive(
                                                            title: const Text('出错啦'),
                                                            description: Text(response.msg),
                                                          ),
                                                        );
                                                      } else {
                                                        ShadToaster.of(context).show(
                                                          ShadToast(
                                                              title: const Text('成功啦'),
                                                              description: Text(response.msg)),
                                                        );
                                                      }
                                                    },
                                                    onCancel: () async {
                                                      Get.back();
                                                    },
                                                  );
                                                },
                                              );
                                            })));
                              },
                              leading: Icon(
                                Icons.movie_filter_outlined,
                                color: shadColorScheme.foreground,
                                size: 16,
                              ),
                              child: Text("电视剧刮削"),
                            ),
                          ],
                          ShadButton.ghost(
                            onPressed: () async {
                              doFileAction(item.path, 'search_seed');
                            },
                            leading: Icon(
                              Icons.local_movies_outlined,
                              color: shadColorScheme.foreground,
                              size: 16,
                            ),
                            child: Text("做种查询"),
                          ),
                          ShadButton.ghost(
                            onPressed: () async {
                              CommonResponse res = await controller.getFileSourceUrl(item.path);
                              if (res.succeed) {
                                await pickAndDownload(res.data, context);
                              }
                            },
                            leading: Icon(
                              Icons.download_outlined,
                              color: shadColorScheme.foreground,
                              size: 16,
                            ),
                            child: Text("下载"),
                          ),
                          // ShadButton.ghost(
                          //   onPressed: () async {
                          //     doFileAction(item.path, 'hard_link', newFileName: "newFileName");
                          //   },
                          //   leading: Icon(Icons.hardware,color: shadColorScheme.foreground,
                          //                     size: 16,),
                          //   child: Text("硬链接"),
                          // ),
                          if (!item.isDir)
                            ShadButton.ghost(
                              onPressed: () async {
                                Logger.instance.d('文件后缀名：${item.ext}，文件类型：${item.mimeType}');
                                CommonResponse res = await controller.getFileSourceUrl(item.path);
                                Logger.instance.d(res.toString());
                                if (res.succeed) {
                                  Clipboard.setData(ClipboardData(text: res.data));
                                  if (item.mimeType?.startsWith('image') == true) {
                                    showImage(res.data, context);
                                  } else if (item.mimeType?.startsWith('video') == true) {
                                    showPlayer(res.data, context);
                                  } else if (item.mimeType?.startsWith('audio') == true) {
                                    showPlayer(res.data, context);
                                  } else {
                                    Get.defaultDialog(
                                      title: '文件操作',
                                      backgroundColor: shadColorScheme.background,
                                      content: Wrap(
                                        alignment: WrapAlignment.spaceAround,
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: [
                                          ShadButton.ghost(
                                            onPressed: () async {
                                              await pickAndDownload(res.data, context);
                                            },
                                            leading: Icon(Icons.download_outlined,
                                                size: 16, color: shadColorScheme.foreground),
                                            child: Text(
                                              "下载",
                                              style: TextStyle(color: shadColorScheme.foreground),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  ShadToaster.of(context).show(
                                    ShadToast.destructive(
                                      title: const Text('提示'),
                                      description: Text(res.msg),
                                    ),
                                  );
                                }
                              },
                              leading: Icon(
                                Icons.hardware,
                                color: shadColorScheme.foreground,
                                size: 16,
                              ),
                              child: Text("打开"),
                            ),
                        ],
                      ),
                    );
                  },
                  onTap: () async {
                    if (item.isDir) {
                      controller.isLoading = true;
                      controller.update(['file_manage']);
                      controller.currentPath = item.path;
                      CommonResponse response = await controller.initSourceData();
                      if (!response.succeed) {
                        ShadToaster.of(context).show(ShadToast(description: Text(response.msg)));
                      }
                    } else {
                      Logger.instance.d('文件后缀名：${item.ext}，文件类型：${item.mimeType}');
                      CommonResponse res = await controller.getFileSourceUrl(item.path);
                      Logger.instance.d(res.toString());
                      if (res.succeed) {
                        Clipboard.setData(ClipboardData(text: res.data));
                        if (item.mimeType?.startsWith('image') == true) {
                          showImage(res.data, context);
                        } else if (item.mimeType?.startsWith('video') == true ||
                            item.mimeType?.startsWith('audio') == true) {
                          Get.dialog(CustomCard(
                              child: VideoPlayerPage(
                            initialUrl: res.data,
                          )));
                        } else {
                          Get.defaultDialog(
                            title: '文件操作',
                            titleStyle: TextStyle(
                              color: shadColorScheme.foreground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: shadColorScheme.background,
                            content: Wrap(
                              alignment: WrapAlignment.spaceAround,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                ShadButton.ghost(
                                  size: ShadButtonSize.sm,
                                  onPressed: () async {
                                    await pickAndDownload(res.data, context);
                                  },
                                  leading: Icon(
                                    Icons.download_outlined,
                                    color: shadColorScheme.foreground,
                                    size: 16,
                                  ),
                                  child: Text("下载", style: TextStyle(color: shadColorScheme.foreground)),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        ShadToaster.of(context).show(
                          ShadToast(title: const Text('提示'), description: Text(res.msg)),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          );
        });
  }

  Widget buildImageItem(String path, ShadColorScheme shadColorScheme, bool isFolder) {
    return FutureBuilder<String?>(
      future: controller.getFileSourceUrl(path).then((res) => res.data),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 45,
              maxHeight: 80,
            ),
            child: CachedNetworkImage(
              imageUrl: snapshot.data!,
              fit: BoxFit.fitHeight,
              height: 80,
              width: 45,
              cacheKey: path,
              progressIndicatorBuilder: (context, url, progress) => SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: progress.progress,
                  strokeWidth: 2,
                  color: shadColorScheme.foreground,
                ),
              ),
              errorWidget: (context, url, error) => isFolder
                  ? Icon(
                      Icons.folder,
                      color: Colors.deepOrangeAccent,
                      size: 32,
                    )
                  : Icon(
                      Icons.folder,
                      color: shadColorScheme.foreground,
                      size: 32,
                    ),
            ),
          );
        } else {
          // 加载中或出错时显示图标isFolder
          return isFolder
              ? Icon(
                  Icons.folder,
                  color: Colors.deepOrangeAccent,
                  size: 32,
                )
              : Icon(
                  Icons.folder,
                  color: shadColorScheme.foreground,
                  size: 32,
                );
        }
      },
    );
  }

  Widget buildItemWidget(SourceItemView item, ShadColorScheme shadColorScheme) {
    // 如果 item 本身是图片
    if (!item.isDir && item.mimeType?.startsWith('image') == true) {
      return buildImageItem(item.path, shadColorScheme, false);
    }
    if (item.isDir) {
      // 先找 cover 开头的图片
      final coverImage = item.children?.firstWhereOrNull(
        (e) => e.name.toLowerCase().startsWith('cover') == true && e.mimeType?.startsWith('image') == true,
      );

      // 如果没有 cover，再找第一个 image 类型文件
      final firstImage = coverImage ??
          item.children?.firstWhereOrNull(
            (e) => e.mimeType?.startsWith('image') == true,
          );
      if (firstImage != null) {
        Logger.instance.d('图片资源：${firstImage.path}');
        // 返回图片资源
        return buildImageItem(firstImage.path, shadColorScheme, true);
      } else {
        // 没有图片显示文件夹图标
        return Icon(
          Icons.folder,
          color: Colors.deepOrangeAccent,
          size: 32,
        );
      }
    } else {
      // 普通文件显示扩展名
      return Text(
        item.ext.toString(),
        style: TextStyle(
          fontSize: 12,
          color: shadColorScheme.foreground,
        ),
      );
    }
  }

  /*///@title
  ///@description TODO 文件操作
  ///@updateTime
   */
  void doFileAction(String path, String action, {String? newFileName}) {}

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
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    final schemes = buildSchemes(url);
    Get.defaultDialog(
      title: '打开方式',
      titleStyle: TextStyle(color: shadColorScheme.foreground),
      backgroundColor: shadColorScheme.background,
      content: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 10,
        runSpacing: 10,
        children: [
          if (defaultTargetPlatform == TargetPlatform.iOS)
            ...schemes.entries.toList().map(
                  (entry) => ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      final uri = Uri.parse(entry.value);
                      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                        Logger.instance.w('无法使用${entry.key}外部播放器');
                      }
                    },
                    child: Text(
                      entry.key.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: shadColorScheme.foreground,
                      ),
                    ),
                  ),
                ),
          if (defaultTargetPlatform == TargetPlatform.android)
            ShadButton.ghost(
              size: ShadButtonSize.sm,
              onPressed: () async {
                final intent = AndroidIntent(
                  action: 'action_view',
                  data: url,
                  type: 'video/*',
                );
                intent.launch();
              },
              leading: Icon(
                Icons.open_in_new_rounded,
                color: shadColorScheme.foreground,
                size: 16,
              ),
              child: Text(
                '打开',
                style: TextStyle(
                  fontSize: 14,
                  color: shadColorScheme.foreground,
                ),
              ),
            ),
          if (defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.windows)
            ...schemes.entries.toList().map(
                  (entry) => ShadButton.ghost(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      openWithPlayer(entry.key, url);
                    },
                    child: Text(
                      entry.key.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: shadColorScheme.foreground,
                      ),
                    ),
                  ),
                ),
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () async {
              Get.dialog(CustomCard(
                  child: VideoPlayerPage(
                initialUrl: url,
              )));
            },
            child: Text(
              'MediaKit',
              style: TextStyle(
                fontSize: 14,
                color: shadColorScheme.foreground,
              ),
            ),
          ),
          ShadButton.ghost(
            size: ShadButtonSize.sm,
            onPressed: () async {
              await pickAndDownload(url, context);
            },
            child: Text(
              "下载",
              style: TextStyle(
                fontSize: 14,
                color: shadColorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickAndDownload(String url, BuildContext context) async {
    RxDouble progress = 0.0.obs; // 0 ~ 100
    RxBool downloading = false.obs;
    // 1. 权限

    if (GetPlatform.isMobile &&
        await Permission.storage.request().isDenied &&
        await Permission.photos.request().isDenied) {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('出错啦'),
          description: Text('需要存储权限！'),
        ),
      );
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
      ShadToaster.of(context).show(
        ShadToast(title: const Text('成功啦'), description: Text('文件已保存到 $savePath')),
      );
    } catch (e) {
      Get.back();
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('出错啦'),
          description: Text(e.toString()),
        ),
      );
    } finally {
      downloading.value = false;
      progress.value = 0;
    }
  }

  void showImage(String url, BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    var uri = Uri.parse(url);
    var expire = int.tryParse(uri.queryParameters['expire'] ?? '0');
    var duration = expire != null ? expire * 1000 - DateTime.now().millisecondsSinceEpoch : 60 * 60 * 1000;
    Logger.instance.w('图片参数: $expire ${DateTime.now().millisecondsSinceEpoch}');
    String key = uri.path.replaceAll('/', '.');
    CacheManager instance = CacheManager(
      Config(
        key,
        stalePeriod: Duration(milliseconds: duration),
        maxNrOfCacheObjects: 20,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileSystem: IOFileSystem(key),
        fileService: HttpFileService(),
      ),
    );
    Get.dialog(
      KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              // ESC 按下处理逻辑
              Get.back();
            }
          }
        },
        child: CustomCard(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: PhotoView(
                      maxScale: PhotoViewComputedScale.covered * 5,
                      // 允许用户放大
                      minScale: PhotoViewComputedScale.contained,
                      initialScale: PhotoViewComputedScale.contained,
                      // 默认显示整个图片
                      imageProvider: CachedNetworkImageProvider(url, cacheKey: key, cacheManager: instance),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShadIconButton.ghost(
                      onPressed: () async {
                        if (GetPlatform.isDesktop || GetPlatform.isWeb) {
                          await pickAndDownload(url, context);
                        } else {
                          if (GetPlatform.isAndroid) {
                            if (!await Permission.storage.request().isGranted ||
                                !await Permission.photos.request().isGranted) {
                              ShadToaster.of(context).show(
                                ShadToast.destructive(
                                  title: const Text('出错啦'),
                                  description: Text('需要存储权限以保存图片！'),
                                ),
                              );
                              return;
                            }
                          } else if (GetPlatform.isIOS) {
                            final status = await Permission.photosAddOnly.status;
                            Logger.instance.d('photosAddOnly status: $status');
                            if (!status.isGranted) {
                              ShadToaster.of(context).show(
                                ShadToast.destructive(
                                  title: const Text('出错啦'),
                                  description: Text('需要相册写入权限！'),
                                ),
                              );
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
                            final tempFile =
                                File('${tempDir.path}/${Uri.parse(url).pathSegments.last.split('/').last}');
                            Logger.instance.d('临时文件URL: ${Uri.parse(url).pathSegments.last.split('/').last}');
                            Logger.instance.d('临时文件保存路径: ${tempFile.path}');
                            await Dio().download(url, tempFile.path);

                            // 2. 写相册（自动区分 iOS/Android）
                            final result = await ImageGallerySaverPlus.saveFile(tempFile.path);
                            Get.back(); // 关闭加载圈

                            if (result['isSuccess'] == true) {
                              ShadToaster.of(context).show(
                                ShadToast(title: const Text('成功啦'), description: Text('图片已存入系统相册！')),
                              );
                            } else {
                              Logger.instance.e(result['errorMessage']);
                              ShadToaster.of(context).show(
                                ShadToast.destructive(
                                  title: const Text('出错啦'),
                                  description: Text('❌ 保存失败！'),
                                ),
                              );
                            }
                          } catch (e) {
                            Get.back();
                            Logger.instance.e(e);
                            ShadToaster.of(context).show(
                              ShadToast.destructive(
                                title: const Text('出错啦'),
                                description: Text('❌ 下载失败！'),
                              ),
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.save_alt_outlined,
                        color: shadColorScheme.foreground,
                        size: 16,
                      ),
                    ),
                    ShadIconButton.ghost(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        Icons.exit_to_app_outlined,
                        color: shadColorScheme.foreground,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
