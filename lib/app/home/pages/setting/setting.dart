import 'package:app_service/app_service.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/utils/storage.dart';

import '../../../../api/option.dart';
import '../../../../common/utils.dart';
import '../../../../utils/logger_helper.dart';
import '../models/option.dart';
import 'setting_controller.dart';

typedef OptionFormBuilder = Widget Function(
    Option? option, BuildContext context);

class SettingPage extends StatelessWidget {
  SettingPage({super.key, param});

  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GetBuilder<SettingController>(builder: (controller) {
          return EasyRefresh(
            onRefresh: controller.getOptionList,
            child: Column(
              children: [
                _versionCard(context),
                _followSystemDarkForm(),
                _noticeTestForm(context),
                Flexible(
                  child: ListView(
                    children: controller.isLoaded
                        ? [const Center(child: CircularProgressIndicator())]
                        : [
                            ..._optionListView(context),
                          ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        }),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: CustomCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    controller.getOptionList();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: 18,
                  )),
              IconButton(
                  onPressed: () {
                    _openAddOptionForm(context);
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  _versionCard(context) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: IconButton(
          icon: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: null,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Version'),
            Text(
                '${controller.packageInfo.version}+${controller.packageInfo.buildNumber}'),
          ],
        ),
        onTap: () async {
          Get.defaultDialog(
            title: '关于 ${controller.packageInfo.appName}',
            middleText:
                '${controller.packageInfo.appName} 版本: ${controller.packageInfo.version}',
            content: AboutDialog(
              applicationIcon: Image.asset(
                'assets/images/avatar.png',
                height: 50,
                width: 50,
              ),
              applicationVersion: controller.packageInfo.version,
              applicationName: controller.packageInfo.appName,
              applicationLegalese: controller.applicationLegalese,
              children: const [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                      'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  _followSystemDarkForm() {
    final appService = Get.find<AppService>();
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('跟随系统'),
          leading: IconButton(
              icon: appService.followSystem.value
                  ? const Icon(Icons.brightness_auto_outlined)
                  : appService.isDarkMode.value
                      ? const Icon(Icons.brightness_4_outlined)
                      : const Icon(Icons.brightness_5_outlined),
              onPressed: () {}),
          // secondary: const Text('跟随系统主题'),
          trailing: Switch(
              value: appService.followSystem.value,
              onChanged: (bool v) async {
                appService.followSystem.value = v;
                await SPUtil.setBool('followSystemDark', v);
                Logger.instance.d('系统主题跟随状态: $v');
              }),
        ),
      );
    });
  }

  Widget _autoImportTagsForm(Option? option, context) {
    Logger.instance.d('自动添加标签: ${option?.value.repeat}');
    RxBool repeat =
        (option == null ? false : (option.value.repeat ?? false)).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('自动添加标签'),
              leading: IconButton(
                icon: repeat.value
                    ? const Icon(
                        Icons.hdr_auto,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.front_hand_outlined,
                        color: Colors.red,
                      ),
                onPressed: () {
                  option?.isActive = !option!.isActive;
                },
              ),
              subtitle: const Text('站点未设置标签时是否自动添加配置文件中的标签'),
              trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                expandedColor: Colors.teal,
              ),
            ),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('自动添加标签'),
                        value: repeat.value,
                        onChanged: (bool v) async {
                          repeat.value = v;
                        }),
                    FullWidthButton(
                        text: '保存',
                        onPressed: () async {
                          if (option == null) {
                            option = Option(
                              id: 0,
                              name: 'auto_import_tags',
                              isActive: true,
                              value: OptionValue(repeat: repeat.value),
                            );
                          } else {
                            option?.isActive = true;
                            option?.value = OptionValue(repeat: repeat.value);
                          }
                          Logger.instance.d('自动匹配: ${option?.value.repeat}');
                          Logger.instance.d('自动匹配: ${option?.toJson()}');
                          final res = await controller.saveOption(option!);
                          if (res.code == 0) {
                            Get.snackbar('配置保存成功',
                                '${controller.optionMap['auto_import_tags']} 配置：${res.msg}',
                                colorText:
                                    Theme.of(context).colorScheme.primary);
                          } else {
                            Get.snackbar('配置保存失败',
                                '${controller.optionMap['auto_import_tags']} 配置出错啦：${res.msg}',
                                colorText: Theme.of(context).colorScheme.error);
                          }
                        }),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  void _openAddOptionForm(context) {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();
    Logger.instance.i(optionForms);
    Logger.instance.d(controller.optionChoice.where((e) =>
        !controller.optionList.any((element) => element.name == e.value)));
    Get.bottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        CustomCard(
          child: Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('请选择配置项'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.optionChoice
                        .where((e) => !controller.optionList
                            .any((element) => element.name == e.value))
                        .map((choice) => CustomCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Center(child: Text(choice.name)),
                                  hoverColor: Colors.teal,
                                  focusColor: Colors.teal,
                                  splashColor: Colors.teal,
                                  onTap: () {
                                    Logger.instance.d(choice.value);
                                    if (optionForms[choice.value] != null) {
                                      Get.back();
                                      Get.bottomSheet(
                                        isScrollControlled: true,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        SingleChildScrollView(
                                          child: optionForms[choice.value]!(
                                              null, context),
                                        ),
                                      );
                                    }
                                  }),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  List<Widget> _optionListView(context) {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();
    List<Widget> children = [];
    for (var option in controller.optionList) {
      children.add(optionForms[option.name]!(option, context));
    }
    return controller.optionList
        .map((option) =>
            optionForms[option.name]?.call(option, context) ?? const SizedBox())
        .toList();
  }

  Map<String, OptionFormBuilder> _optionFormMap() {
    final Map<String, OptionFormBuilder> optionForms = {
      'monkey_token': _monkeyTokenForm,
      'wechat_work_push': _qyWechatForm,
      'wxpusher_push': _wxPusherForm,
      'pushdeer_push': _pushDeerForm,
      'bark_push': _barkForm,
      'iyuu_push': _iyuuForm,
      'pushplus_push': _pushPlusForm,
      'telegram_push': _telegramForm,
      'aliyun_drive': _aliDriveForm,
      'baidu_ocr': _baiduOcrForm,
      'ssdforum': _ssdForumForm,
      'cookie_cloud': _cookieCloudForm,
      'FileList': _fileListForm,
      'notice_category_enable': _noticeCategoryEnableForm,
      'notice_content_item': _noticeContentItem,
      'tmdb_api_auth': _tmdbApiAuthForm,
      'aggregation_search': _aggregationSearchForm,
      'auto_import_tags': _autoImportTagsForm,
    };
    return optionForms;
  }

  Widget _aggregationSearchForm(Option? option, context) {
    TextEditingController limitController =
        TextEditingController(text: option?.value.limit.toString() ?? '30');
    TextEditingController maxCountController =
        TextEditingController(text: option?.value.maxCount.toString() ?? '30');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('聚合搜索配置'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                      autofocus: true,
                      controller: maxCountController,
                      labelText: '站点数量限制',
                      helperText: '单次搜索的站点数量，太高数据返回较慢，0表示不限制',
                    ),
                    CustomTextField(
                      autofocus: true,
                      controller: limitController,
                      labelText: '并发数量限制',
                      helperText: '并发搜索站点数量，太高会占用太多内存，0表示不限制',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'aggregation_search',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      limit:
                                          int.tryParse(limitController.text) ??
                                              30,
                                      maxCount: int.tryParse(
                                              maxCountController.text) ??
                                          30,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    limit: int.tryParse(limitController.text) ??
                                        30,
                                    maxCount:
                                        int.tryParse(maxCountController.text) ??
                                            30,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['aggregation_search']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['aggregation_search']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _tmdbApiAuthForm(Option? option, context) {
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    TextEditingController apiKeyController =
        TextEditingController(text: option?.value.apiKey ?? '');
    TextEditingController secretController =
        TextEditingController(text: option?.value.secretKey ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('TMDB配置'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                      autofocus: true,
                      controller: apiKeyController,
                      labelText: 'API密钥',
                    ),
                    CustomTextField(
                        controller: secretController, labelText: '访问令牌'),
                    CustomTextField(
                        controller: proxyController, labelText: '代理地址'),
                    SwitchListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('TMDB开关'),
                        value: isActive.value,
                        onChanged: (value) {
                          isActive.value = value;
                        }),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'tmdb_api_auth',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      proxy: proxyController.text,
                                      apiKey: apiKeyController.text,
                                      secretKey: secretController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    proxy: proxyController.text,
                                    apiKey: apiKeyController.text,
                                    secretKey: secretController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['tmdb_api_auth']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['tmdb_api_auth']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _noticeCategoryEnableForm(Option? option, context) {
    final isActive = (option == null ? true : option.isActive).obs;
    final aliyundriveNotice =
        (option == null ? true : option.value.aliyundriveNotice).obs;
    final siteData = (option == null ? true : option.value.siteData).obs;
    final todayData = (option == null ? true : option.value.todayData).obs;
    final packageTorrent =
        (option == null ? true : option.value.packageTorrent).obs;
    final deleteTorrent =
        (option == null ? true : option.value.deleteTorrent).obs;
    final rssTorrent = (option == null ? true : option.value.rssTorrent).obs;
    final pushTorrent = (option == null ? true : option.value.pushTorrent).obs;
    final programUpgrade =
        (option == null ? true : option.value.programUpgrade).obs;
    final ptppImport = (option == null ? true : option.value.ptppImport).obs;
    final announcement =
        (option == null ? true : option.value.announcement).obs;
    final message = (option == null ? true : option.value.message).obs;
    final signInSuccess =
        (option == null ? true : option.value.signInSuccess).obs;
    final siteDataSuccess =
        (option == null ? true : option.value.siteDataSuccess).obs;
    final cookieSync = (option == null ? true : option.value.cookieSync).obs;
    final isEdit = (option == null).obs;
    Logger.instance.d(option);
    Logger.instance.d(aliyundriveNotice.value);

    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ListTile(
              title: const Text('通知开关'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? IconButton(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option?.isActive == true
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                expandedColor: Colors.teal,
              )),
          if (isEdit.value)
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('阿里云'),
                              value: aliyundriveNotice.value!,
                              onChanged: (value) {
                                aliyundriveNotice.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('站点数据'),
                              value: siteData.value!,
                              onChanged: (value) {
                                siteData.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('成功站点消息'),
                              value: siteDataSuccess.value!,
                              onChanged: (value) {
                                siteDataSuccess.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('今日数据'),
                              value: todayData.value!,
                              onChanged: (value) {
                                todayData.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('拆包'),
                              value: packageTorrent.value!,
                              onChanged: (value) {
                                packageTorrent.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('删种'),
                              value: deleteTorrent.value!,
                              onChanged: (value) {
                                deleteTorrent.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('RSS'),
                              value: rssTorrent.value!,
                              onChanged: (value) {
                                rssTorrent.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('种子推送'),
                              value: pushTorrent.value!,
                              onChanged: (value) {
                                pushTorrent.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('Docker 升级'),
                              value: programUpgrade.value!,
                              onChanged: (value) {
                                programUpgrade.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('PTPP 导入'),
                              value: ptppImport.value!,
                              onChanged: (value) {
                                ptppImport.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('公告详情'),
                              value: announcement.value!,
                              onChanged: (value) {
                                announcement.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('短消息详情'),
                              value: message.value!,
                              onChanged: (value) {
                                message.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('签到成功消息'),
                              value: signInSuccess.value!,
                              onChanged: (value) {
                                signInSuccess.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('CookieCloud 同步'),
                              value: cookieSync.value!,
                              onChanged: (value) {
                                cookieSync.value = value;
                              }),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FullWidthButton(
                          text: '保存',
                          onPressed: () async {
                            if (option == null) {
                              option = Option(
                                id: 0,
                                name: 'notice_category_enable',
                                isActive: isActive.value,
                                value: OptionValue(
                                  aliyundriveNotice: aliyundriveNotice.value,
                                  siteData: siteData.value,
                                  siteDataSuccess: siteDataSuccess.value,
                                  todayData: todayData.value,
                                  packageTorrent: packageTorrent.value,
                                  deleteTorrent: deleteTorrent.value,
                                  rssTorrent: rssTorrent.value,
                                  pushTorrent: pushTorrent.value,
                                  programUpgrade: programUpgrade.value,
                                  ptppImport: ptppImport.value,
                                  announcement: announcement.value,
                                  message: message.value,
                                  signInSuccess: signInSuccess.value,
                                  cookieSync: cookieSync.value,
                                ),
                              );
                            } else {
                              option?.isActive = isActive.value;
                              option?.value = OptionValue(
                                aliyundriveNotice: aliyundriveNotice.value,
                                siteData: siteData.value,
                                todayData: todayData.value,
                                packageTorrent: packageTorrent.value,
                                deleteTorrent: deleteTorrent.value,
                                rssTorrent: rssTorrent.value,
                                pushTorrent: pushTorrent.value,
                                programUpgrade: programUpgrade.value,
                                ptppImport: ptppImport.value,
                                announcement: announcement.value,
                                message: message.value,
                                signInSuccess: signInSuccess.value,
                                siteDataSuccess: siteDataSuccess.value,
                                cookieSync: cookieSync.value,
                              );
                            }
                            final res = await controller.saveOption(option!);
                            if (res.code == 0) {
                              Get.back();
                              Get.snackbar('配置保存成功',
                                  '${controller.optionMap['notice_category_enable']} 配置：${res.msg}',
                                  colorText:
                                      Theme.of(context).colorScheme.primary);
                              isEdit.value = false;
                            } else {
                              Get.snackbar('配置保存失败',
                                  '${controller.optionMap['notice_category_enable']} 配置出错啦：${res.msg}',
                                  colorText:
                                      Theme.of(context).colorScheme.error);
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
        ]),
      );
    });
  }

  Widget _noticeContentItem(Option? option, context) {
    final isActive = (option == null ? true : option.isActive).obs;
    final level = (option == null ? true : option.value.level).obs;
    final bonus = (option == null ? true : option.value.bonus).obs;
    final perBonus = (option == null ? true : option.value.perBonus).obs;
    final score = (option == null ? true : option.value.score).obs;
    final ratio = (option == null ? true : option.value.ratio).obs;
    final seedingVol = (option == null ? true : option.value.seedingVol).obs;
    final uploaded = (option == null ? true : option.value.uploaded).obs;
    final downloaded = (option == null ? true : option.value.downloaded).obs;
    final seeding = (option == null ? true : option.value.seeding).obs;
    final leeching = (option == null ? true : option.value.leeching).obs;
    final invite = (option == null ? true : option.value.invite).obs;
    final hr = (option == null ? true : option.value.hr).obs;

    final isEdit = (option == null).obs;
    Logger.instance.d(option);

    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ListTile(
              title: const Text('站点详情'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? IconButton(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option?.isActive == true
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                expandedColor: Colors.teal,
              )),
          if (isEdit.value)
            SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('等级'),
                              value: level.value!,
                              onChanged: (value) {
                                level.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('魔力'),
                              value: bonus.value!,
                              onChanged: (value) {
                                bonus.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('时魔'),
                              value: perBonus.value!,
                              onChanged: (value) {
                                perBonus.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('积分'),
                              value: score.value!,
                              onChanged: (value) {
                                score.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('分享率'),
                              value: ratio.value!,
                              onChanged: (value) {
                                ratio.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('做种体积'),
                              value: seedingVol.value!,
                              onChanged: (value) {
                                seedingVol.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('上传量'),
                              value: uploaded.value!,
                              onChanged: (value) {
                                uploaded.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('下载量'),
                              value: downloaded.value!,
                              onChanged: (value) {
                                downloaded.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('做种数量'),
                              value: seeding.value!,
                              onChanged: (value) {
                                seeding.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('吸血数量'),
                              value: leeching.value!,
                              onChanged: (value) {
                                leeching.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('邀请'),
                              value: invite.value!,
                              onChanged: (value) {
                                invite.value = value;
                              }),
                          SwitchListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              title: const Text('HR'),
                              value: hr.value!,
                              onChanged: (value) {
                                hr.value = value;
                              }),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FullWidthButton(
                          text: '保存',
                          onPressed: () async {
                            if (option == null) {
                              option = Option(
                                id: 0,
                                name: 'notice_content_item',
                                isActive: isActive.value,
                                value: OptionValue(
                                  level: level.value,
                                  bonus: bonus.value,
                                  perBonus: perBonus.value,
                                  score: score.value,
                                  ratio: ratio.value,
                                  seedingVol: seedingVol.value,
                                  uploaded: uploaded.value,
                                  downloaded: downloaded.value,
                                  seeding: seeding.value,
                                  leeching: leeching.value,
                                  invite: invite.value,
                                  hr: hr.value,
                                ),
                              );
                            } else {
                              option?.isActive = isActive.value;
                              option?.value = OptionValue(
                                level: level.value,
                                bonus: bonus.value,
                                perBonus: perBonus.value,
                                score: score.value,
                                ratio: ratio.value,
                                seedingVol: seedingVol.value,
                                uploaded: uploaded.value,
                                downloaded: downloaded.value,
                                seeding: seeding.value,
                                leeching: leeching.value,
                                invite: invite.value,
                                hr: hr.value,
                              );
                            }
                            final res = await controller.saveOption(option!);
                            if (res.code == 0) {
                              Get.back();
                              Get.snackbar('配置保存成功',
                                  '${controller.optionMap['notice_content_item']} 配置：${res.msg}',
                                  colorText:
                                      Theme.of(context).colorScheme.primary);
                              isEdit.value = false;
                            } else {
                              Get.snackbar('配置保存失败',
                                  '${controller.optionMap['notice_content_item']} 配置出错啦：${res.msg}',
                                  colorText:
                                      Theme.of(context).colorScheme.error);
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
        ]),
      );
    });
  }

  Widget _monkeyTokenForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('安全 Token'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: tokenController,
                        labelText: '令牌'),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '随机Token',
                              backgroundColor: Colors.green,
                              onPressed: () async {
                                tokenController.text = generateRandomString(8);
                              }),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'monkey_token',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                        token: tokenController.text),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value =
                                      OptionValue(token: tokenController.text);
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['monkey_token']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['monkey_token']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _qyWechatForm(Option? option, context) {
    TextEditingController corpIdController =
        TextEditingController(text: option?.value.corpId ?? '');
    TextEditingController corpSecretController =
        TextEditingController(text: option?.value.corpSecret ?? '');
    TextEditingController toUidController =
        TextEditingController(text: option?.value.toUid ?? '@all');
    TextEditingController agentIdController =
        TextEditingController(text: option?.value.agentId ?? '');
    TextEditingController refreshTokenController =
        TextEditingController(text: option?.value.refreshToken ?? '');
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    TextEditingController serverController =
        TextEditingController(text: option?.value.server ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('企业微信'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: corpIdController,
                        labelText: '企业 ID'),
                    CustomTextField(
                        controller: corpSecretController, labelText: '企业密钥'),
                    CustomTextField(
                        controller: agentIdController, labelText: '应用 ID'),
                    CustomTextField(
                        controller: toUidController, labelText: '接收 ID'),
                    CustomTextField(
                        controller: refreshTokenController,
                        labelText: 'EncodingAESKey'),
                    CustomTextField(
                        controller: tokenController, labelText: 'Token'),
                    CustomTextField(
                        controller: serverController, labelText: '背景图地址'),
                    CustomTextField(
                        controller: proxyController, labelText: '固定代理'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'wechat_work_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                        corpSecret: corpSecretController.text,
                                        agentId: agentIdController.text,
                                        corpId: corpIdController.text,
                                        toUid: toUidController.text,
                                        refreshToken:
                                            refreshTokenController.text,
                                        token: tokenController.text,
                                        server: serverController.text,
                                        proxy: proxyController.text),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                      corpSecret: corpSecretController.text,
                                      agentId: agentIdController.text,
                                      corpId: corpIdController.text,
                                      toUid: toUidController.text,
                                      refreshToken: refreshTokenController.text,
                                      token: tokenController.text,
                                      server: serverController.text,
                                      proxy: proxyController.text);
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['wechat_work_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['wechat_work_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _fileListForm(Option? option, context) {
    TextEditingController usernameController =
        TextEditingController(text: option?.value.username ?? '');
    TextEditingController passwordController =
        TextEditingController(text: option?.value.password ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('FileList'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: usernameController,
                        labelText: '账号'),
                    CustomTextField(
                        controller: passwordController, labelText: '密码'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                      id: 0,
                                      name: 'FileList',
                                      isActive: isActive.value,
                                      value: OptionValue(
                                        username: usernameController.text,
                                        password: passwordController.text,
                                      ));
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    username: usernameController.text,
                                    password: passwordController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['FileList']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['FileList']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _noticeTestForm(context) {
    TextEditingController titleController =
        TextEditingController(text: '这是一个消息标题');
    TextEditingController messageController =
        TextEditingController(text: '*这是一条测试消息*  \n__这是二号标题__\n```这是消息```');
    final isEdit = false.obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('通知测试'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const IconButton(
                  icon: Icon(Icons.notification_important_outlined,
                      color: Colors.green),
                  onPressed: null,
                ),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: titleController,
                        labelText: '消息标题'),
                    CustomTextField(
                      controller: messageController,
                      labelText: '消息内容',
                      maxLines: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '发送',
                              onPressed: () async {
                                final res = await noticeTestApi({
                                  "title": titleController.text,
                                  "message": messageController.text,
                                });
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar(
                                      '测试消息内容发送成功', '测试消息内容发送成功：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                      '测试消息内容发送失败', '测试消息内容发送出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _iyuuForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    RxBool repeat = (option == null ? true : option.value.repeat!).obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('爱语飞飞'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: tokenController,
                        labelText: '令牌'),
                    SwitchListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('辅种开关'),
                        value: repeat.value,
                        onChanged: (value) {
                          repeat.value = value;
                        }),
                    // CustomTextField(
                    //     controller: proxyController, labelText: '服务器'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'iyuu_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      token: tokenController.text,
                                      proxy: proxyController.text,
                                      repeat: repeat.value,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    token: tokenController.text,
                                    proxy: proxyController.text,
                                    repeat: repeat.value,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['iyuu_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['iyuu_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _pushDeerForm(Option? option, context) {
    TextEditingController keyController =
        TextEditingController(text: option?.value.key ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('PushDeer'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: keyController,
                        labelText: 'Key'),
                    CustomTextField(
                        controller: proxyController, labelText: '服务器'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'pushdeer_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      token: keyController.text,
                                      proxy: proxyController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    token: keyController.text,
                                    proxy: proxyController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['pushdeer_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['pushdeer_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _aliDriveForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.refreshToken ?? '');
    RxBool welfare = true.obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('阿里云盘'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        maxLines: 3,
                        autofocus: true,
                        controller: tokenController,
                        labelText: '保存令牌'),
                    SwitchListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        title: const Text('领取福利'),
                        value: welfare.value,
                        onChanged: (value) {
                          welfare.value = value;
                        }),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'aliyun_drive',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      refreshToken: tokenController.text,
                                      welfare: welfare.value,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    refreshToken: tokenController.text,
                                    welfare: welfare.value,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['aliyun_drive']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['aliyun_drive']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _ssdForumForm(Option? option, context) {
    TextEditingController cookieController =
        TextEditingController(text: option?.value.cookie ?? '');
    TextEditingController userAgentController =
        TextEditingController(text: option?.value.userAgent ?? '');
    TextEditingController todaySayController = TextEditingController(
        text: option != null ? option.value.todaySay! : '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('SSDForum'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        maxLines: 5,
                        autofocus: true,
                        controller: cookieController,
                        labelText: 'Cookie'),
                    const SizedBox(height: 5),
                    CustomTextField(
                        maxLines: 3,
                        controller: userAgentController,
                        labelText: 'UserAgent'),
                    CustomTextField(
                        maxLines: 5,
                        controller: todaySayController,
                        labelText: '今天想说'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'ssdforum',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      cookie: cookieController.text,
                                      userAgent: userAgentController.text,
                                      todaySay: todaySayController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    cookie: cookieController.text,
                                    userAgent: userAgentController.text,
                                    todaySay: todaySayController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['ssdforum']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['ssdforum']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _baiduOcrForm(Option? option, context) {
    TextEditingController appIdController =
        TextEditingController(text: option?.value.appId ?? '');
    TextEditingController apiKeyController =
        TextEditingController(text: option?.value.apiKey ?? '');
    TextEditingController secretController =
        TextEditingController(text: option?.value.secretKey ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('百度 OCR'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: appIdController,
                        labelText: '应用 ID'),
                    CustomTextField(
                        controller: apiKeyController, labelText: 'APIKey'),
                    CustomTextField(
                        controller: secretController, labelText: 'Secret'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'baidu_ocr',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      appId: appIdController.text,
                                      apiKey: apiKeyController.text,
                                      secretKey: secretController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    appId: appIdController.text,
                                    apiKey: apiKeyController.text,
                                    secretKey: secretController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['baidu_ocr']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['baidu_ocr']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _barkForm(Option? option, context) {
    TextEditingController deviceIdController =
        TextEditingController(text: option?.value.deviceKey ?? '');
    TextEditingController serverController =
        TextEditingController(text: option?.value.server ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('Bark'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: deviceIdController,
                        labelText: '设备ID'),
                    CustomTextField(
                        controller: serverController, labelText: '服务器'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'bark_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      deviceKey: deviceIdController.text,
                                      server: serverController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    deviceKey: deviceIdController.text,
                                    server: serverController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['bark_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['bark_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _pushPlusForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('PushPlus'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: tokenController,
                        labelText: '令牌'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'pushplus_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      token: tokenController.text,
                                      template: 'markdown',
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    token: tokenController.text,
                                    template: 'markdown',
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['pushplus_push']} 保存成功：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['pushplus_push']} 保存出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _wxPusherForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    TextEditingController appIdController =
        TextEditingController(text: option?.value.appId ?? '');
    TextEditingController uidController =
        TextEditingController(text: option?.value.uids ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('WxPusher'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: appIdController,
                        labelText: '应用 ID'),
                    CustomTextField(
                        controller: tokenController, labelText: '令牌'),
                    CustomTextField(
                        controller: uidController, labelText: '接收人'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'wxpusher_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      appId: appIdController.text,
                                      token: tokenController.text,
                                      uids: uidController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    appId: appIdController.text,
                                    token: tokenController.text,
                                    uids: uidController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['wxpusher_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['wxpusher_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _telegramForm(Option? option, context) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.telegramToken ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    TextEditingController chatIdController =
        TextEditingController(text: option?.value.telegramChatId ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('Telegram'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: chatIdController,
                        labelText: 'ID'),
                    CustomTextField(
                        controller: tokenController, labelText: '令牌'),
                    CustomTextField(
                        controller: proxyController, labelText: '代理'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'telegram_push',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      telegramToken: tokenController.text,
                                      telegramChatId: chatIdController.text,
                                      proxy: proxyController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    telegramToken: tokenController.text,
                                    telegramChatId: chatIdController.text,
                                    proxy: proxyController.text,
                                  );
                                }
                                Logger.instance.i(option?.toJson());
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['telegram_push']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['telegram_push']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _cookieCloudForm(Option? option, context) {
    TextEditingController serverController =
        TextEditingController(text: option?.value.server ?? '');
    TextEditingController keyController =
        TextEditingController(text: option?.value.key ?? '');
    TextEditingController passwordController =
        TextEditingController(text: option?.value.password ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: const Text('CookieCloud'),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: option != null
                    ? IconButton(
                        onPressed: () async {
                          option?.isActive = !option!.isActive;
                          await controller.saveOption(option!);
                        },
                        icon: option!.isActive
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.clear, color: Colors.red))
                    : const SizedBox.shrink(),
                trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  expandedColor: Colors.teal,
                )),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                        autofocus: true,
                        controller: serverController,
                        labelText: '服务器'),
                    CustomTextField(
                        controller: keyController, labelText: 'Key'),
                    CustomTextField(
                        controller: passwordController, labelText: '密码'),
                    Row(
                      children: [
                        Expanded(
                          child: FullWidthButton(
                              text: '保存',
                              onPressed: () async {
                                if (option == null) {
                                  option = Option(
                                    id: 0,
                                    name: 'cookie_cloud',
                                    isActive: isActive.value,
                                    value: OptionValue(
                                      server: serverController.text,
                                      key: keyController.text,
                                      password: passwordController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    server: serverController.text,
                                    key: keyController.text,
                                    password: passwordController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('配置保存成功',
                                      '${controller.optionMap['cookie_cloud']} 配置：${res.msg}',
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .primary);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('配置保存失败',
                                      '${controller.optionMap['cookie_cloud']} 配置出错啦：${res.msg}',
                                      colorText:
                                          Theme.of(context).colorScheme.error);
                                }
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
