import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/loader/gf_loader.dart';

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
  final SearchTorrentInfo info;

  final TextEditingController urlController = TextEditingController();
  final TextEditingController savePathController = TextEditingController();
  final TextEditingController cookieController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController renameController = TextEditingController();
  final TextEditingController upLimitController = TextEditingController();
  final TextEditingController dlLimitController =
      TextEditingController(text: '150');
  final TextEditingController ratioLimitController =
      TextEditingController(text: '0');
  final isLoading = false.obs;

  DownloadForm({
    super.key,
    required this.categories,
    required this.downloader,
    required this.info,
  }) : torrentController = Get.put(TorrentController(downloader, false));

  @override
  Widget build(BuildContext context) {
    Logger.instance.i(categories);
    MySite? mysite = searchController.mySiteMap[info.siteId];

    WebSite? webSite =
        searchController.mySiteController.webSiteList[mysite?.site];
    savePathController.text = categories[categories.keys.first]!;
    cookieController.text = mysite?.cookie ?? '';
    upLimitController.text =
        webSite != null ? webSite.limitSpeed.toString() : '0';
    urlController.text = info.magnetUrl;
    RxBool advancedConfig = false.obs;
    RxBool paused = false.obs;
    RxBool rootFolder = false.obs;
    RxBool autoTMM = false.obs;
    RxBool firstLastPiecePrio = false.obs;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GetBuilder<DownloadController>(
        builder: (controller) {
          return Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '种子名称: ${info.subtitle.isNotEmpty ? info.subtitle : info.title}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
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
                        onConfirm: (value, index) {
                          categoryController.text = value;
                          savePathController.text = categories[value] ?? '';
                        },
                      )
                    : CustomTextField(
                        controller: categoryController,
                        labelText: '分类',
                      ),
                if (categories.isNotEmpty || advancedConfig.value)
                  CustomTextField(
                    controller: savePathController,
                    labelText: '路径',
                  ),
                Obx(() {
                  return SwitchListTile(
                      title: const Text(
                        '高级选项',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      value: advancedConfig.value,
                      onChanged: (bool val) {
                        advancedConfig.value = val;
                      });
                }),
                Obx(() {
                  return SwitchListTile(
                      title: const Text(
                        '暂停下载',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      value: paused.value,
                      onChanged: (bool val) {
                        paused.value = val;
                      });
                }),
                if (downloader.category.toLowerCase() == 'qb')
                  Obx(() {
                    return SwitchListTile(
                        title: const Text(
                          '内容布局',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        value: rootFolder.value,
                        onChanged: (bool val) {
                          rootFolder.value = val;
                        });
                  }),
                if (downloader.category.toLowerCase() == 'qb')
                  Obx(() {
                    return SwitchListTile(
                        title: const Text(
                          '自动管理',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        value: autoTMM.value,
                        onChanged: (bool val) {
                          autoTMM.value = val;
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
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
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
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
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
                            if (downloader.category.toLowerCase() == 'qb')
                              SwitchListTile(
                                  title: const Text(
                                    '优先下载首尾数据块',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white70),
                                  ),
                                  value: firstLastPiecePrio.value,
                                  onChanged: (bool val) {
                                    firstLastPiecePrio.value = val;
                                  }),
                          ],
                        )
                      : const SizedBox.shrink();
                }),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => cancelForm(context),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                      ),
                      child: const Text('取消'),
                    ),
                    Obx(() {
                      return ElevatedButton.icon(
                        onPressed: () {
                          isLoading.value = true;
                          submitForm({
                            'mySite': mysite,
                            'magnet': urlController.text,
                            'savePath': savePathController.text,
                            'category': categoryController.text,
                            'paused': paused.value,
                            'rootFolder': rootFolder.value,
                            'autoTMM': autoTMM.value,
                            'firstLastPiecePrio': firstLastPiecePrio.value,
                            'rename': renameController.text,
                            'upLimit':
                                int.tryParse(upLimitController.text) ?? 0,
                            'dlLimit':
                                int.tryParse(dlLimitController.text) ?? 0,
                            'ratioLimit':
                                int.tryParse(ratioLimitController.text) ?? 0,
                          });
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
      ),
    );
  }

  void submitForm(Map<String, dynamic> formData) async {
    try {
      final TorrentController torrentController =
          Get.put(TorrentController(downloader, false));
      print(formData);
      final res =
          await torrentController.addTorrentFilesToQb(downloader, formData);
      Logger.instance.i(res.msg);
      Get.back();
      if (res.code == 0) {
        Get.snackbar('种子推送成功！', res.msg!,
            backgroundColor: Colors.green.shade300, colorText: Colors.white);
      } else {
        Get.snackbar('种子推送失败！', res.msg!,
            backgroundColor: Colors.red.shade300, colorText: Colors.white);
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
