import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:harvest/api/downloader.dart';
import 'package:harvest/app/home/pages/models/qbittorrent.dart';
import 'package:harvest/app/home/pages/models/torrent_info.dart';
import 'package:harvest/models/common_response.dart';
import 'package:harvest/utils/storage.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/form_widgets.dart';
import '../../../../utils/logger_helper.dart';
import '../models/download.dart';
import '../models/my_site.dart';
import '../models/website.dart';
import 'download_controller.dart';

class DownloadForm extends StatelessWidget {
  final Map<String, Category?> categories;
  final Downloader downloader;
  final SearchTorrentInfo? info;
  final MySite? mysite;
  final WebSite? website;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController savePathController = TextEditingController();
  final TextEditingController cookieController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController renameController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController upLimitController = TextEditingController();
  final TextEditingController dlLimitController = TextEditingController();
  final TextEditingController ratioLimitController = TextEditingController();
  final isLoading = false.obs;

  DownloadForm({
    super.key,
    required this.categories,
    required this.downloader,
    this.info,
    this.mysite,
    this.website,
  }) {
    // 初始化控制器的值
    cookieController.text = mysite?.cookie ?? info?.cookie ?? '';
    upLimitController.text = website?.limitSpeed.toString() ?? '';
    urlController.text = info?.magnetUrl ?? '';
    tagsController.text = '';
    savePathController.text = categories.isNotEmpty
        ? categories.values.first?.savePath
        : (downloader.category.toLowerCase() == 'qb' ? downloader.prefs.savePath : downloader.prefs.downloadDir);
  }

  @override
  Widget build(BuildContext context) {
    // 初始化分类列表
    categories.remove('全部');
    categories.remove('未分类');
    bool isQb = downloader.category.toLowerCase() == 'qb';
    return isQb ? _buildQbittorrentForm(context) : _buildTransmissionForm(context);
  }

  Form _buildQbittorrentForm(BuildContext context) {
    QbittorrentPreferences prefs = downloader.prefs;
    if (savePathController.text.isEmpty) {
      savePathController.text = prefs.savePath;
    }
    Logger.instance.d("保存路径：${savePathController.text}");
    RxBool advancedConfig = false.obs;
    RxBool paused = prefs.startPausedEnabled.obs;
    Rx<String> contentLayout = prefs.torrentContentLayout.obs;
    Rx<String> category = (categories.isEmpty ? '' : categories.keys.first).obs;
    Rx<String?> stopCondition = (prefs.torrentStopCondition == 'None' ? null : prefs.torrentStopCondition).obs;
    Rx<bool> autoTMM = prefs.autoTmmEnabled.obs;
    RxBool firstLastPiecePrio = false.obs;
    RxBool isSkipChecking = false.obs;
    RxBool addToTopOfQueue = false.obs;
    RxBool isSequentialDownload = false.obs;
    RxBool forced = false.obs;
    RxList<String> tags = SPUtil.getStringList("custom_torrent_tags",
        defaultValue: ['harvest-app', '电影', '电视剧', '动漫', '综艺', '纪录片', '体育', '音乐', '动画', '游戏']).obs;
    RxList<String> selectedTags = [
      ...?info?.tags,
      'harvest-app',
    ].obs;
    tags.sort();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Form(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(children: [
                CustomTextField(
                  controller: urlController,
                  labelText: '链接',
                ),
                // if (downloader.category.toLowerCase() == 'qb')
                categories.isNotEmpty
                    ? Obx(() {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              ...categories.keys.sorted().map(
                                    (key) => FilterChip(
                                      label:
                                          Text(key, style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                      labelPadding: EdgeInsets.zero,
                                      selected: category.value == key,
                                      backgroundColor: shadColorScheme.background,
                                      selectedColor: shadColorScheme.background,
                                      checkmarkColor: shadColorScheme.foreground,
                                      selectedShadowColor: shadColorScheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                      showCheckmark: true,
                                      elevation: 2,
                                      onSelected: (bool value) {
                                        if (value) {
                                          category.value = key;
                                          categoryController.text = key;
                                          String? savePath = categories[key]?.savePath;
                                          savePathController.text = savePath != null && savePath.isNotEmpty
                                              ? savePath
                                              : downloader.prefs.savePath;
                                        }
                                      },
                                    ),
                                  ),
                            ],
                          ),
                        );
                      })
                    : CustomTextField(
                        controller: categoryController,
                        labelText: '分类',
                      ),
                InkWell(
                  onLongPress: () {
                    savePathController.text = prefs.savePath;
                  },
                  child: CustomTextField(
                    controller: savePathController,
                    labelText: '路径',
                  ),
                ),
                CustomTextField(
                  controller: tagsController,
                  labelText: ' 标签',
                  helperText: '多个标签用英文都好`,`分隔',
                  suffixIcon: ShadIconButton.ghost(
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                    ),
                    onPressed: () {
                      tagsController.text = '';
                    },
                  ),
                ),
                Obx(() {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 3,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        label: Text(
                          '清理',
                          style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                        ),
                        labelPadding: EdgeInsets.zero,
                        backgroundColor: shadColorScheme.destructive,
                        labelStyle: TextStyle(fontSize: 12, color: shadColorScheme.destructiveForeground),
                        pressElevation: 5,
                        elevation: 3,
                        onPressed: () {
                          Get.defaultDialog(
                            title: '提示',
                            titleStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                            content: Text(
                              '确定要重置自定义标签吗？',
                              style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                            ),
                            backgroundColor: shadColorScheme.background,
                            cancel: ShadButton.outline(
                              size: ShadButtonSize.sm,
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('取消'),
                            ),
                            confirm: ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              onPressed: () {
                                tags.clear();
                                SPUtil.remove("custom_torrent_tags");
                                Get.back();
                              },
                              child: Text('重置'),
                            ),
                          );
                        },
                      ),
                      ...tags.map((tag) => FilterChip(
                            label: Text(
                              tag,
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                            ),
                            selected: selectedTags.contains(tag),
                            labelPadding: EdgeInsets.zero,
                            backgroundColor: shadColorScheme.primary.withOpacity(0.8),
                            labelStyle: TextStyle(fontSize: 12, color: shadColorScheme.primaryForeground),
                            selectedColor: Colors.green,
                            selectedShadowColor: Colors.blue,
                            pressElevation: 5,
                            elevation: 3,
                            onSelected: (value) {
                              if (value) {
                                selectedTags.add(tag);
                                selectedTags.value = selectedTags.toSet().toList();
                              } else {
                                selectedTags.remove(tag);
                              }
                            },
                          )),
                    ],
                  );
                }),
                Obx(() {
                  return SwitchTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: '暂停下载',
                      fontSize: 12,
                      value: paused.value,
                      onChanged: (bool val) {
                        paused.value = val;
                      });
                }),
                Obx(() {
                  return SwitchTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: '高级选项',
                      value: advancedConfig.value,
                      onChanged: (bool val) {
                        advancedConfig.value = val;
                      });
                }),
                Obx(() {
                  return advancedConfig.value
                      ? Column(
                          children: [
                            SwitchTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: '添加到队列顶部',
                                value: addToTopOfQueue.value,
                                onChanged: (bool val) {
                                  addToTopOfQueue.value = val;
                                }),
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('种子停止条件', style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                    DropdownButton(
                                        value: stopCondition.value,
                                        dropdownColor: shadColorScheme.background,
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground), '无'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'MetadataReceived',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '已收到元数据'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'FilesChecked',
                                            child: Text(
                                                style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                '选种的文件'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          stopCondition.value = value;
                                        }),
                                  ],
                                ),
                              );
                            }),
                            Obx(() {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('内容布局', style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                    DropdownButton(
                                        isDense: true,
                                        value: contentLayout.value,
                                        dropdownColor: shadColorScheme.background,
                                        items: [
                                          DropdownMenuItem(
                                              value: 'Original',
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '原始')),
                                          DropdownMenuItem(
                                              value: 'Subfolder',
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '子文件夹')),
                                          DropdownMenuItem(
                                              value: 'NoSubfolder',
                                              child: Text(
                                                  style: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                                                  '不创建子文件夹')),
                                        ],
                                        onChanged: (value) {
                                          contentLayout.value = value!;
                                        }),
                                  ],
                                ),
                              );
                            }),
                            Obx(() {
                              return SwitchTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: '跳过哈希校验',
                                  value: isSkipChecking.value,
                                  onChanged: (bool val) {
                                    isSkipChecking.value = val;
                                  });
                            }),
                            Obx(() {
                              return SwitchTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: '自动管理',
                                  value: autoTMM.value,
                                  onChanged: (bool val) {
                                    autoTMM.value = val;
                                  });
                            }),
                            Obx(() {
                              return SwitchTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                  title: '强制启动',
                                  value: forced.value,
                                  onChanged: (bool val) {
                                    forced.value = val;
                                  });
                            }),
                            SwitchTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: '按顺序下载',
                                value: isSequentialDownload.value,
                                onChanged: (bool val) {
                                  isSequentialDownload.value = val;
                                }),
                            SwitchTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: '优先下载首尾数据块',
                                value: firstLastPiecePrio.value,
                                onChanged: (bool val) {
                                  firstLastPiecePrio.value = val;
                                }),
                            CustomTextField(
                              controller: renameController,
                              labelText: '重命名',
                            ),
                            CustomTextField(
                              controller: cookieController,
                              labelText: ' Cookie',
                            ),
                            CustomTextField(
                              controller: upLimitController,
                              labelText: ' 上传限速',
                              keyboardType: TextInputType.number,
                              suffixText: 'MB/s',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                TextInputFormatter.withFunction((oldValue, newValue) {
                                  try {
                                    final int value = int.parse(newValue.text);
                                    if (value < -2) {
                                      return oldValue;
                                    }
                                    return newValue;
                                  } catch (e) {
                                    return oldValue;
                                  }
                                }),
                              ],
                            ),
                            CustomTextField(
                              controller: dlLimitController,
                              labelText: '下载限速',
                              keyboardType: TextInputType.number,
                              suffixText: 'MB/s',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                TextInputFormatter.withFunction((oldValue, newValue) {
                                  try {
                                    final int value = int.parse(newValue.text);
                                    if (value < -2) {
                                      return oldValue;
                                    }
                                    return newValue;
                                  } catch (e) {
                                    return oldValue;
                                  }
                                }),
                              ],
                            ),
                            CustomTextField(
                              controller: ratioLimitController,
                              labelText: '分享率限制',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                TextInputFormatter.withFunction((oldValue, newValue) {
                                  try {
                                    final int value = int.parse(newValue.text);
                                    if (value < -2) {
                                      return oldValue;
                                    }
                                    return newValue;
                                  } catch (e) {
                                    return oldValue;
                                  }
                                }),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink();
                }),
                const SizedBox(height: 10),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ShadButton.outline(
                  size: ShadButtonSize.sm,
                  onPressed: () => cancelForm(context),
                  leading: const Icon(Icons.cancel_outlined, size: 18),
                  child: Text('取消'),
                ),
                Obx(() {
                  return ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      isLoading.value = true;
                      if (tagsController.text.isNotEmpty) {
                        tags.addAll(tagsController.text.split(','));
                      }
                      SPUtil.setStringList('custom_torrent_tags', tags.toSet().toList());
                      double? ratioLimit = double.tryParse(ratioLimitController.text);
                      int? upLimit = int.tryParse(upLimitController.text);
                      int? dlLimit = int.tryParse(dlLimitController.text);
                      List<String> finalTags = <String>{
                        if (tagsController.text.isNotEmpty) ...tagsController.text.split(','),
                        ...selectedTags
                      }.where((element) => element.isNotEmpty).toList();
                      await submitForm({
                        'site_id': info?.siteId,
                        'tid': info?.tid,
                        'urls': urlController.text,
                        'save_path': savePathController.text,
                        'category': categoryController.text,
                        'is_paused': paused.value,
                        'rename': renameController.text,
                        'tags': finalTags,
                        'cookie': cookieController.text,
                        'content_layout': contentLayout.value,
                        'stop_condition': stopCondition.value == 'None' ? null : stopCondition.value,
                        'is_skip_checking': isSkipChecking.value,
                        'is_sequential_download': isSequentialDownload.value,
                        'is_first_last_piece_priority': firstLastPiecePrio.value,
                        'use_auto_torrent_management': autoTMM.value,
                        'add_to_top_of_queue': addToTopOfQueue.value,
                        'forced': forced.value,
                        'upload_limit': (upLimit != null && upLimit > 0)
                            ? upLimit * 1024 * 1024 * 0.92
                            : website != null
                                ? website!.limitSpeed * 1024 * 1024 * 0.92
                                : null,
                        'download_limit': (dlLimit != null && dlLimit > 0) ? dlLimit * 1024 * 1024 : null,
                        'ratio_limit': ratioLimit,
                      }, context);
                      isLoading.value = false;
                    },
                    leading: isLoading.value
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: shadColorScheme.primaryForeground,
                              ),
                            ),
                          )
                        : const Icon(Icons.download, size: 18),
                    child: const Text('下载'),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransmissionForm(BuildContext context) {
    RxBool advancedConfig = false.obs;
    RxBool paused = false.obs;
    Rx<String> category = categories.keys.first.obs;
    RxList<String> tags = SPUtil.getStringList("custom_torrent_tags",
        defaultValue: ['电影', '电视剧', '动漫', '综艺', '纪录片', '体育', '音乐', '动画', '游戏']).obs;
    RxList<String> selectedTags = [
      ...?info?.tags,
      'harvest-app',
    ].obs;
    tags.sort();
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: ListView(children: [
            CustomTextField(
              controller: urlController,
              labelText: '链接',
            ),
            // if (downloader.category.toLowerCase() == 'qb')
            categories.isNotEmpty
                ? Obx(() {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                      child: Wrap(
                        runSpacing: 8,
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ...categories.keys.sorted().map(
                                (key) => FilterChip(
                                  label: Text(key, style: TextStyle(fontSize: 12, color: shadColorScheme.foreground)),
                                  selected: category.value == key,
                                  backgroundColor: shadColorScheme.background,
                                  selectedColor: shadColorScheme.background,
                                  labelPadding: EdgeInsets.zero,
                                  checkmarkColor: shadColorScheme.foreground,
                                  selectedShadowColor: shadColorScheme.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                  showCheckmark: true,
                                  elevation: 2,
                                  onSelected: (bool value) {
                                    if (value) {
                                      category.value = key;
                                      categoryController.text = key;
                                      savePathController.text =
                                          categories[key]?.savePath ?? downloader.prefs.downloadDir;
                                    }
                                  },
                                ),
                              ),
                        ],
                      ),
                    );
                  })
                : CustomTextField(
                    controller: categoryController,
                    labelText: '分类',
                  ),
            if (categories.isNotEmpty || advancedConfig.value)
              InkWell(
                onLongPress: () {
                  savePathController.text = downloader.prefs.downloadDir;
                },
                child: CustomTextField(
                  controller: savePathController,
                  labelText: '路径',
                ),
              ),
            CustomTextField(
              controller: tagsController,
              labelText: ' 标签',
              helperText: '多个标签用英文都好`,`分隔',
            ),
            Obx(() {
              return Wrap(
                spacing: 8,
                runSpacing: 3,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionChip(
                    label: Text(
                      '清理',
                      style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                    ),
                    labelPadding: EdgeInsets.zero,
                    backgroundColor: shadColorScheme.destructive,
                    labelStyle: TextStyle(fontSize: 12, color: shadColorScheme.destructiveForeground),
                    pressElevation: 5,
                    elevation: 3,
                    onPressed: () {
                      Get.defaultDialog(
                        title: '提示',
                        titleStyle: TextStyle(fontSize: 14, color: shadColorScheme.foreground),
                        content: Text(
                          '确定要重置自定义标签吗？',
                          style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                        ),
                        backgroundColor: shadColorScheme.background,
                        cancel: ShadButton.outline(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            Get.back();
                          },
                          child: Text('取消'),
                        ),
                        confirm: ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          onPressed: () {
                            tags.clear();
                            SPUtil.remove("custom_torrent_tags");
                            Get.back();
                          },
                          child: Text('重置'),
                        ),
                      );
                    },
                  ),
                  ...tags.map((tag) => FilterChip(
                        label: Text(
                          tag,
                          style: TextStyle(color: shadColorScheme.foreground, fontSize: 12),
                        ),
                        selected: selectedTags.contains(tag),
                        labelPadding: EdgeInsets.zero,
                        backgroundColor: shadColorScheme.primary.withOpacity(0.8),
                        labelStyle: TextStyle(fontSize: 12, color: shadColorScheme.primaryForeground),
                        selectedColor: Colors.green,
                        selectedShadowColor: Colors.blue,
                        pressElevation: 5,
                        elevation: 3,
                        onSelected: (value) {
                          if (value) {
                            selectedTags.add(tag);
                            selectedTags.value = selectedTags.toSet().toList();
                          } else {
                            selectedTags.remove(tag);
                          }
                        },
                      )),
                ],
              );
            }),
            Obx(() {
              return SwitchTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: '暂停下载',
                  value: paused.value,
                  onChanged: (bool val) {
                    paused.value = val;
                  });
            }),
            Obx(() {
              return SwitchTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: '高级选项',
                  value: advancedConfig.value,
                  onChanged: (bool val) {
                    advancedConfig.value = val;
                  });
            }),

            Obx(() {
              return advancedConfig.value
                  ? Column(
                      children: [
                        CustomTextField(
                          controller: cookieController,
                          labelText: ' Cookie',
                        ),
                        CustomTextField(
                          controller: upLimitController,
                          labelText: ' 上传限速',
                          keyboardType: TextInputType.number,
                          suffixText: 'MB/s',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              try {
                                final int value = int.parse(newValue.text);
                                if (value < 0) {
                                  return oldValue;
                                }
                                return newValue;
                              } catch (e) {
                                return oldValue;
                              }
                            }),
                          ],
                        ),
                        CustomTextField(
                          controller: dlLimitController,
                          labelText: '下载限速',
                          keyboardType: TextInputType.number,
                          suffixText: 'MB/s',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              try {
                                final int value = int.parse(newValue.text);
                                if (value < 0) {
                                  return oldValue;
                                }
                                return newValue;
                              } catch (e) {
                                return oldValue;
                              }
                            }),
                          ],
                        ),
                        CustomTextField(
                          controller: ratioLimitController,
                          labelText: '分享率限制',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              try {
                                final int value = int.parse(newValue.text);
                                if (value < 0) {
                                  return oldValue;
                                }
                                return newValue;
                              } catch (e) {
                                return oldValue;
                              }
                            }),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox.shrink();
            }),
            const SizedBox(height: 10),
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: () => cancelForm(context),
              leading: const Icon(Icons.cancel_outlined),
              child: const Text('取消'),
            ),
            Obx(() {
              return ShadButton.destructive(
                size: ShadButtonSize.sm,
                onPressed: () async {
                  isLoading.value = true;
                  if (tagsController.text.isNotEmpty) {
                    tags.addAll(tagsController.text.split(','));
                  }
                  SPUtil.setStringList('custom_torrent_tags', tags.toSet().toList());
                  double? ratioLimit = double.tryParse(ratioLimitController.text);
                  int? upLimit = int.tryParse(upLimitController.text);
                  int? dlLimit = int.tryParse(dlLimitController.text);
                  List<String> finalTags = <String>{
                    if (tagsController.text.isNotEmpty) ...tagsController.text.split(','),
                    ...selectedTags
                  }.where((element) => element.isNotEmpty).toList();
                  await submitForm({
                    'site_id': info?.siteId,
                    'tid': info?.tid,
                    'urls': urlController.text,
                    'save_path': savePathController.text,
                    'tags': finalTags,
                    'cookie': cookieController.text,
                    'is_paused': paused.value,
                    'upload_limit': (upLimit != null && upLimit > 0)
                        ? upLimit * 1024 * 0.92
                        : website != null
                            ? website!.limitSpeed * 1024 * 0.92
                            : null,
                    'download_limit': (dlLimit != null && dlLimit > 0) ? dlLimit * 1024 : null,
                    'ratio_limit': ratioLimit,
                  }, context);
                  isLoading.value = false;
                },
                leading: isLoading.value
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: shadColorScheme.primaryForeground,
                          ),
                        ),
                      )
                    : const Icon(Icons.download),
                child: const Text('下载'),
              );
            }),
          ],
        ),
      ],
    ));
  }

  Future<void> submitForm(Map<String, dynamic> formData, context) async {
    try {
      Logger.instance.i('提交表单: $formData');
      CommonResponse res = await pushTorrentToDownloader(downloaderId: downloader.id!, formData: formData);

      Logger.instance.i(res.msg);
      if (res.succeed) {
        Get.back();
        Get.snackbar(
          '种子推送成功！',
          res.msg,
          colorText: ShadTheme.of(context).colorScheme.foreground,
        );
      } else {
        Get.snackbar(
          '种子推送失败！',
          res.msg,
          colorText: ShadTheme.of(context).colorScheme.destructive,
        );
      }
    } finally {}
  }

  void cancelForm(context) {
    // 清空表单数据
    savePathController.clear();
    urlController.clear();
    cookieController.clear();
    categoryController.clear();
    renameController.clear();
    upLimitController.clear();
    dlLimitController.clear();
    ratioLimitController.clear();
    Navigator.of(context).pop();
  }
}

Future<void> openDownloaderListSheet(
    BuildContext context, SearchTorrentInfo info, WebSite? website, MySite? mySite) async {
  DownloadController downloadController = Get.find();
  if (downloadController.dataList.isEmpty) {
    await downloadController.getDownloaderListFromServer();
    if (downloadController.dataList.isEmpty) {
      Get.snackbar('无下载器可用', '请先到下载管理添加下载器后重试！');
      return;
    }
  }

  var shadColorScheme = ShadTheme.of(context).colorScheme;
  Rx<Widget> window = SizedBox().obs;
  Rx<int> selectedDownloader = 0.obs;
  Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // 设置圆角半径
      ), GetBuilder<DownloadController>(builder: (controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '请选择下载器',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (info.subtitle.isNotEmpty && info.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EllipsisText(
                text: info.subtitle.isNotEmpty ? info.subtitle : info.title,
                style: TextStyle(fontSize: 12, color: shadColorScheme.primary),
                ellipsis: '...',
                maxLines: 1,
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Wrap(
                  spacing: 8.0, // 水平间距
                  runSpacing: 8.0, // 垂直间距
                  children: downloadController.dataList.map((downloader) {
                    return GetBuilder<DownloadController>(
                        id: "${downloader.host}:${downloader.port}-categories",
                        builder: (controller) {
                          return FilterChip(
                            label: Text(
                              downloader.name,
                              style: TextStyle(color: shadColorScheme.foreground, fontSize: 15),
                            ),
                            tooltip: '${downloader.protocol}://${downloader.host}:${downloader.port}',
                            avatar: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircleAvatar(
                                backgroundImage: Image.asset(
                                  'assets/images/${downloader.category.toLowerCase()}.png',
                                ).image,
                              ),
                            ),
                            labelPadding: EdgeInsets.zero,
                            backgroundColor: shadColorScheme.background,
                            selectedColor: shadColorScheme.background,
                            checkmarkColor: shadColorScheme.foreground,
                            selectedShadowColor: shadColorScheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            showCheckmark: true,
                            elevation: 2,
                            selected: selectedDownloader.value == downloader.id,
                            onSelected: (value) async {
                              window.value = SizedBox();
                              selectedDownloader.value = downloader.id!;
                              downloadController.isCategoryLoading = true;
                              downloadController.update();
                              CommonResponse response = await controller.getDownloaderCategoryList(downloader);
                              if (!response.succeed) {
                                Get.snackbar(
                                  '警告',
                                  response.msg,
                                  colorText: shadColorScheme.destructive,
                                );
                                downloadController.isCategoryLoading = false;
                                downloadController.update(["${downloader.host}:${downloader.port}-categories"]);
                                return;
                              }
                              Map<String, Category?> categorise = response.data;
                              window.value = SizedBox(
                                child: DownloadForm(
                                  categories: categorise,
                                  downloader: downloader,
                                  info: info,
                                  website: website,
                                  mysite: mySite,
                                ),
                              );
                            },
                          );
                        });
                  }).toList(),
                ),
                Obx(() {
                  return Expanded(
                      child: downloadController.isCategoryLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: shadColorScheme.foreground,
                                strokeWidth: 2,
                              ),
                            )
                          : window.value);
                })
              ],
            ),
          ),
        ],
      ),
    );
  }));
}
