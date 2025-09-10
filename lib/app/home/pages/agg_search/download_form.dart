import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:harvest/api/downloader.dart';
import 'package:harvest/app/home/pages/download/qbittorrent.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/models/common_response.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/form_widgets.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart';
import '../download/download_controller.dart';
import '../models/my_site.dart';
import '../models/website.dart';
import 'controller.dart';
import 'models/torrent_info.dart';

class DownloadForm extends StatelessWidget {
  final Map<String, Category> categories;
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
    tagsController.text = info?.tags.join(',') ?? '';
    if (categories.isNotEmpty) {
      savePathController.text = categories.values.first.savePath ??
          (downloader.category.toLowerCase() == 'qb' ? downloader.prefs.savePath : downloader.prefs.downloadDir);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 初始化分类列表
    categories.remove('全部');
    categories.remove('未分类');
    bool isQb = downloader.category.toLowerCase() == 'qb';
    return CustomCard(child: isQb ? _buildQbittorrentForm(context) : _buildTransmissionForm(context));
  }

  Form _buildQbittorrentForm(BuildContext context) {
    QbittorrentPreferences prefs = downloader.prefs;
    if (savePathController.text.isEmpty) {
      savePathController.text = prefs.savePath;
    }
    RxBool advancedConfig = false.obs;
    RxBool paused = prefs.startPausedEnabled.obs;
    Rx<String> contentLayout = prefs.torrentContentLayout.obs;
    Rx<String?> stopCondition = (prefs.torrentStopCondition == 'None' ? null : prefs.torrentStopCondition).obs;
    Rx<bool> autoTMM = prefs.autoTmmEnabled.obs;
    RxBool firstLastPiecePrio = false.obs;
    RxBool isSkipChecking = false.obs;
    RxBool addToTopOfQueue = false.obs;
    RxBool isSequentialDownload = false.obs;
    RxBool forced = false.obs;

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (info != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: EllipsisText(
                text: info!.subtitle.isNotEmpty ? info!.subtitle : info!.title,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                ellipsis: '...',
                maxLines: 1,
              ),
            ),
          Expanded(
            child: ListView(children: [
              CustomTextField(
                controller: urlController,
                labelText: '链接',
              ),
              // if (downloader.category.toLowerCase() == 'qb')
              categories.isNotEmpty
                  ? CustomPickerField(
                      controller: categoryController,
                      labelText: '分类',
                      data: categories.keys.toList(),
                      onChanged: (value, index) {
                        categoryController.text = value;
                        savePathController.text = categories[value]?.savePath ?? downloader.prefs.savePath;
                      },
                    )
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
              ),
              Obx(() {
                return SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(
                      '暂停下载',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: paused.value,
                    onChanged: (bool val) {
                      paused.value = val;
                    });
              }),
              Obx(() {
                return SwitchListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: const Text(
                      '高级选项',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: advancedConfig.value,
                    onChanged: (bool val) {
                      advancedConfig.value = val;
                    });
              }),

              Obx(() {
                return advancedConfig.value
                    ? Column(
                        children: [
                          SwitchListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text(
                                '添加到队列顶部',
                                style: TextStyle(fontSize: 12),
                              ),
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
                                  const Text('种子停止条件'),
                                  DropdownButton(
                                      value: stopCondition.value,
                                      items: const [
                                        DropdownMenuItem(
                                          value: null,
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '无'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'MetadataReceived',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                              '已收到元数据'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'FilesChecked',
                                          child: Text(
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
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
                                  const Text('内容布局'),
                                  DropdownButton(
                                      isDense: true,
                                      value: contentLayout.value,
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'Original',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '原始')),
                                        DropdownMenuItem(
                                            value: 'Subfolder',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
                                                '子文件夹')),
                                        DropdownMenuItem(
                                            value: 'NoSubfolder',
                                            child: Text(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                ),
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
                            return SwitchListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: const Text(
                                  '跳过哈希校验',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: isSkipChecking.value,
                                onChanged: (bool val) {
                                  isSkipChecking.value = val;
                                });
                          }),
                          Obx(() {
                            return SwitchListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: const Text(
                                  '自动管理',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: autoTMM.value,
                                onChanged: (bool val) {
                                  autoTMM.value = val;
                                });
                          }),
                          Obx(() {
                            return SwitchListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: const Text(
                                  '强制启动',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: forced.value,
                                onChanged: (bool val) {
                                  forced.value = val;
                                });
                          }),
                          SwitchListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text(
                                '按顺序下载',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: isSequentialDownload.value,
                              onChanged: (bool val) {
                                isSequentialDownload.value = val;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text(
                                '优先下载首尾数据块',
                                style: TextStyle(fontSize: 12),
                              ),
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
              ElevatedButton.icon(
                onPressed: () => cancelForm(context),
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.redAccent.withAlpha(150)),
                ),
                icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                label: const Text(
                  '取消',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Obx(() {
                return ElevatedButton.icon(
                  onPressed: () async {
                    isLoading.value = true;
                    double? ratioLimit = double.tryParse(ratioLimitController.text);
                    int? upLimit = int.tryParse(upLimitController.text);
                    int? dlLimit = int.tryParse(dlLimitController.text);
                    await submitForm({
                      'site_id': info?.siteId,
                      'tid': info?.tid,
                      'urls': urlController.text,
                      'save_path': savePathController.text,
                      'category': categoryController.text,
                      'is_paused': paused.value,
                      'rename': renameController.text,
                      'tags': tagsController.text,
                      'cookie': cookieController.text,
                      'content_layout': contentLayout.value,
                      'stop_condition': stopCondition.value == 'None' ? null : stopCondition.value,
                      'is_skip_checking': isSkipChecking.value,
                      'is_sequential_download': isSequentialDownload.value,
                      'is_first_last_piece_priority': firstLastPiecePrio.value,
                      'use_auto_torrent_management': autoTMM.value,
                      'add_to_top_of_queue': addToTopOfQueue.value,
                      'forced': forced.value,
                      'upLimit': (upLimit != null && upLimit > 0) ? upLimit * 1024 : null,
                      'dlLimit': (dlLimit != null && dlLimit > 0) ? dlLimit * 1024 : null,
                      'ratioLimit': ratioLimit,
                    }, context);
                    isLoading.value = false;
                  },
                  icon: isLoading.value ? Center(child: const CircularProgressIndicator()) : const Icon(Icons.download),
                  label: const Text('下载'),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  _buildTransmissionForm(BuildContext context) {
    RxBool advancedConfig = false.obs;
    RxBool paused = false.obs;

    return Form(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (info != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: EllipsisText(
              text: info!.subtitle.isNotEmpty ? info!.subtitle : info!.title,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
              ellipsis: '...',
              maxLines: 1,
            ),
          ),
        Expanded(
          child: ListView(children: [
            CustomTextField(
              controller: urlController,
              labelText: '链接',
            ),
            // if (downloader.category.toLowerCase() == 'qb')
            categories.isNotEmpty
                ? CustomPickerField(
                    controller: categoryController,
                    labelText: '分类',
                    data: categories.keys.toList(),
                    onChanged: (value, index) {
                      categoryController.text = value;
                      savePathController.text = categories[value]?.savePath ?? downloader.prefs.downloadDir;
                    },
                  )
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
              return SwitchListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text(
                    '暂停下载',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: paused.value,
                  onChanged: (bool val) {
                    paused.value = val;
                  });
            }),
            Obx(() {
              return SwitchListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: const Text(
                    '高级选项',
                    style: TextStyle(fontSize: 12),
                  ),
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
            ElevatedButton.icon(
              onPressed: () => cancelForm(context),
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                ),
                backgroundColor: WidgetStateProperty.all(Colors.redAccent.withAlpha(150)),
              ),
              icon: const Icon(Icons.cancel_outlined, color: Colors.white),
              label: const Text(
                '取消',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Obx(() {
              return ElevatedButton.icon(
                onPressed: () async {
                  isLoading.value = true;
                  double? ratioLimit = double.tryParse(ratioLimitController.text);
                  int? upLimit = int.tryParse(upLimitController.text);
                  int? dlLimit = int.tryParse(dlLimitController.text);
                  await submitForm({
                    'site_id': info?.siteId,
                    'tid': info?.tid,
                    'urls': urlController.text,
                    'save_path': savePathController.text,
                    'tags': tagsController.text.split(','),
                    'cookie': cookieController.text,
                    'is_paused': paused.value,
                    'upLimit': (upLimit != null && upLimit > 0) ? upLimit * 1024 : null,
                    'dlLimit': (dlLimit != null && dlLimit > 0) ? dlLimit * 1024 : null,
                    'ratioLimit': ratioLimit,
                  }, context);
                  isLoading.value = false;
                },
                icon: isLoading.value ? Center(child: const CircularProgressIndicator()) : const Icon(Icons.download),
                label: const Text('下载'),
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

openDownloaderListSheet(BuildContext context, SearchTorrentInfo info) async {
  DownloadController downloadController = Get.find();
  if (downloadController.dataList.isEmpty) {
    await downloadController.getDownloaderListFromServer();
    if (downloadController.dataList.isEmpty) {
      Get.snackbar('无下载器可用', '请先到下载管理添加下载器后重试！');
      return;
    }
  }
  Get.bottomSheet(CustomCard(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '请选择下载器',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        Flexible(
          child: ListView(
            children: downloadController.dataList.map((downloader) {
              return CustomCard(
                child: GetBuilder<AggSearchController>(
                    id: '${downloader.id} - ${downloader.name}',
                    builder: (controller) {
                      return ListTile(
                        title: Text(
                          downloader.name,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        subtitle: Text(
                          '${downloader.protocol}://${downloader.host}:${downloader.port}',
                          style: const TextStyle(),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: Image.asset(
                            'assets/images/${downloader.category.toLowerCase()}.png',
                          ).image,
                        ),
                        trailing: controller.isDownloaderLoading
                            ? const CircularProgressIndicator()
                            : const SizedBox.shrink(),
                        onTap: () async {
                          CommonResponse response = await controller.getDownloaderCategoryList(downloader);
                          if (!response.succeed) {
                            Get.snackbar(
                              '警告',
                              response.msg,
                              colorText: Theme.of(context).colorScheme.error,
                            );
                            return;
                          }
                          Map<String, Category> categorise = response.data;
                          Get.bottomSheet(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                            enableDrag: true,
                            CustomCard(
                              height: 400,
                              padding: const EdgeInsets.all(12),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '添加种子',
                                    style: ShadTheme.of(context).textTheme.h4,
                                  ),
                                ),
                                Expanded(
                                  child: DownloadForm(
                                    categories: categorise,
                                    downloader: downloader,
                                    info: info,
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      );
                    }),
              );
            }).toList(),
          ),
        )
      ],
    ),
  ));
}
