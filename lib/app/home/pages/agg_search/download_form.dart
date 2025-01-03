import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:harvest/common/card_view.dart';

import '../../../../common/form_widgets.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart';
import '../../../torrent/torrent_controller.dart';
import '../download/download_controller.dart';
import '../models/my_site.dart';
import '../models/website.dart';
import 'controller.dart';
import 'models/torrent_info.dart';

class DownloadForm extends StatelessWidget {
  final AggSearchController searchController = Get.put(AggSearchController());
  final TorrentController torrentController;

  final Map<String, String> categories;
  final Downloader downloader;
  final SearchTorrentInfo? info;

  final TextEditingController urlController = TextEditingController();
  final TextEditingController savePathController = TextEditingController();
  final TextEditingController cookieController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController renameController = TextEditingController();
  final TextEditingController upLimitController =
      TextEditingController(text: '150');
  final TextEditingController dlLimitController =
      TextEditingController(text: '150');
  final TextEditingController ratioLimitController =
      TextEditingController(text: '0');
  final isLoading = false.obs;

  DownloadForm({
    super.key,
    required this.categories,
    required this.downloader,
    this.info,
  }) : torrentController = Get.put(TorrentController(downloader, false));

  @override
  Widget build(BuildContext context) {
    Logger.instance.d(categories);
    MySite? mysite;
    if (info != null) {
      mysite = searchController.mySiteMap[info!.siteId];
      WebSite? webSite =
          searchController.mySiteController.webSiteList[mysite?.site];
      cookieController.text = mysite?.cookie ?? '';
      upLimitController.text =
          webSite != null ? webSite.limitSpeed.toString() : '0';
      urlController.text = info!.magnetUrl;
    } else {}
    savePathController.text =
        categories[categories.keys.first] ?? torrentController.defaultSavePath;
    RxBool advancedConfig = false.obs;
    RxBool paused = false.obs;
    Rx<bool> rootFolder = false.obs;
    Rx<bool> autoTMM = false.obs;
    RxBool firstLastPiecePrio = false.obs;
    return GetBuilder<DownloadController>(
      builder: (controller) {
        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (info != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: EllipsisText(
                    text: info!.subtitle.isNotEmpty
                        ? info!.subtitle
                        : info!.title,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary),
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
                            savePathController.text =
                                categories[value] != null &&
                                        categories[value]!.isNotEmpty
                                    ? categories[value]!
                                    : torrentController.defaultSavePath;
                          },
                        )
                      : CustomTextField(
                          controller: categoryController,
                          labelText: '分类',
                        ),
                  if (categories.isNotEmpty || advancedConfig.value)
                    InkWell(
                      onLongPress: () {
                        savePathController.text =
                            torrentController.defaultSavePath;
                      },
                      child: CustomTextField(
                        controller: savePathController,
                        labelText: '路径',
                      ),
                    ),
                  Obx(() {
                    return SwitchListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
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
                              if (downloader.category.toLowerCase() == 'qb')
                                Column(
                                  children: [
                                    Obx(() {
                                      return SwitchListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                          dense: true,
                                          title: const Text(
                                            '内容布局',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          value: rootFolder.value,
                                          onChanged: (bool val) {
                                            rootFolder.value = val;
                                          });
                                    }),
                                    Obx(() {
                                      return SwitchListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
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
                                    SwitchListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8),
                                        title: const Text(
                                          '优先下载首尾数据块',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        value: firstLastPiecePrio.value,
                                        onChanged: (bool val) {
                                          firstLastPiecePrio.value = val;
                                        }),
                                  ],
                                ),
                              CustomTextField(
                                controller: cookieController,
                                labelText: ' Cookie',
                              ),
                              if (downloader.category.toLowerCase() == 'qb')
                                CustomTextField(
                                  controller: renameController,
                                  labelText: '重命名',
                                ),
                              CustomTextField(
                                controller: upLimitController,
                                labelText: ' 上传限速',
                                keyboardType: TextInputType.number,
                                suffixText: 'MB/s',
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    try {
                                      final int value =
                                          int.parse(newValue.text);
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
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    try {
                                      final int value =
                                          int.parse(newValue.text);
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
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    try {
                                      final int value =
                                          int.parse(newValue.text);
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
                      backgroundColor: WidgetStateProperty.all(
                          Colors.redAccent.withAlpha(150)),
                    ),
                    icon:
                        const Icon(Icons.cancel_outlined, color: Colors.white),
                    label: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Obx(() {
                    return ElevatedButton.icon(
                      onPressed: () async {
                        isLoading.value = true;
                        double? ratioLimit =
                            double.tryParse(ratioLimitController.text);
                        int? upLimit = int.tryParse(upLimitController.text);
                        int? dlLimit = int.tryParse(dlLimitController.text);
                        await submitForm({
                          'mySite': mysite,
                          'magnet': urlController.text,
                          'savePath': savePathController.text,
                          'category': categoryController.text,
                          'paused': paused.value,
                          'rootFolder': rootFolder.value,
                          'autoTMM': autoTMM.value,
                          'firstLastPiecePrio': firstLastPiecePrio.value,
                          'rename': renameController.text,
                          'upLimit': upLimit! > 0 ? upLimit : null,
                          'dlLimit': dlLimit! > 0 ? dlLimit : null,
                          'ratioLimit': ratioLimit != null && ratioLimit > 0
                              ? ratioLimit
                              : null,
                        }, context);
                        isLoading.value = false;
                      },
                      icon: isLoading.value
                          ? const GFLoader(size: 18)
                          : const Icon(Icons.download),
                      label: const Text('下载'),
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitForm(Map<String, dynamic> formData, context) async {
    try {
      final TorrentController torrentController = Get.put(
          TorrentController(downloader, false),
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
      dynamic res;
      if (downloader.category.toLowerCase() == 'qb') {
        res = await torrentController.addTorrentFilesToQb(downloader, formData);
      } else {
        res = await torrentController.addTorrentFilesToTr(downloader, formData);
      }

      Logger.instance.i(res.msg);
      if (res.code == 0) {
        Get.back();
        Get.snackbar('种子推送成功！', res.msg!,
            colorText: Theme.of(context).colorScheme.primary);
      } else {
        Get.snackbar('种子推送失败！', res.msg!,
            colorText: Theme.of(context).colorScheme.error);
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

openDownloaderListSheet(BuildContext context, SearchTorrentInfo info) {
  DownloadController downloadController = Get.find();
  Get.bottomSheet(CustomCard(
    margin: const EdgeInsets.all(8),
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
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
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
                          // if (downloader.category.toLowerCase() != 'qb') {
                          //   Get.snackbar('警告', '目前仅支持 QB，Tr 相关功能正在开发中！',
                          //       backgroundColor: Colors.amber.shade300,colorText: Theme.of(context).colorScheme.primary);
                          //   return;
                          // }

                          await controller
                              .getDownloaderCategories(downloader)
                              .then((value) {
                            Map<String, String> categorise = value;
                            Get.back();
                            Get.bottomSheet(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              enableDrag: true,
                              CustomCard(
                                height: 400,
                                padding: const EdgeInsets.all(12),
                                child: Column(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GFTypography(
                                      text: '添加种子',
                                      icon: const Icon(Icons.add),
                                      dividerWidth: 108,
                                      textColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      dividerColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                          });
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
