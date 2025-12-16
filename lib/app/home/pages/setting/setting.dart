import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/api/api.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';
import 'package:harvest/utils/storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../api/hooks.dart';
import '../../../../api/option.dart';
import '../../../../common/corner_badge.dart';
import '../../../../common/utils.dart';
import '../../../../models/common_response.dart';
import '../../../../theme/theme_service.dart';
import '../../../../theme/theme_view.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/logger_helper.dart';
import '../models/color_storage.dart';
import '../models/option.dart';
import 'setting_controller.dart';

typedef OptionFormBuilder = Widget Function(Option? option, BuildContext context);

class SettingPage extends StatelessWidget {
  SettingPage({super.key, param});

  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    var opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            SPUtil.getBool('useBackground') ? Colors.transparent : shadColorScheme.background.withOpacity(opacity),
        body: GetBuilder<SettingController>(builder: (controller) {
          return EasyRefresh(
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
            onRefresh: () => controller.getOptionList,
            child: ListView(
              children: [
                ...[
                  _versionCard(context),
                  _followSystemDarkForm(),
                  _siteCardForm(context),
                  _noticeTestForm(context),
                  _telegramWebHookForm(context),
                  ...(controller.isLoading
                      ? [
                          Expanded(
                            child: Center(
                                child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                          )
                        ]
                      : _optionListView(context)),
                ],
              ],
            ),
          );
        }),
        // floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadIconButton.ghost(
                onPressed: () {
                  controller.getOptionList();
                },
                icon: Icon(
                  Icons.refresh_outlined,
                  size: 24,
                  color: shadColorScheme.primary,
                )),
            ShadIconButton.ghost(
              onPressed: () {
                _openAddOptionForm(context);
              },
              icon: Icon(
                Icons.add_outlined,
                size: 24,
                color: shadColorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomCard _versionCard(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: ShadIconButton.ghost(
          icon: Icon(
            Icons.info_outline,
            color: shadColorScheme.foreground,
          ),
          onPressed: null,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Version',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
            Text(
              '${controller.packageInfo.version}+${controller.packageInfo.buildNumber}',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
          ],
        ),
        onTap: () async {
          Get.defaultDialog(
            title: '关于 ${controller.packageInfo.appName}',
            middleText: '${controller.packageInfo.appName} 版本: ${controller.packageInfo.version}',
            content: AboutDialog(
              applicationIcon: Image.asset(
                'assets/images/avatar.png',
                height: 50,
                width: 50,
              ),
              applicationVersion: controller.packageInfo.version,
              applicationName: controller.packageInfo.appName,
              applicationLegalese: controller.applicationLegalese,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Harvest 本义收割,收获，本软件致力于让你更轻松的玩转国内 PT 站点，与收割机有异曲同工之妙，故此得名。',
                    style: TextStyle(color: shadColorScheme.foreground),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  ThemeTag _followSystemDarkForm() {
    return ThemeTag();
  }

  Widget _autoImportTagsForm(Option? option, BuildContext context) {
    Logger.instance.d('自动添加标签: ${option?.value.repeat}');
    RxBool repeat = (option == null ? false : (option.value.repeat ?? false)).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              '自动添加标签',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
            leading: ShadIconButton.ghost(
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
            subtitle: Text(
              '站点未设置标签时是否自动添加配置文件中的标签',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
            onTap: () {
              isEdit.value = !isEdit.value;
            },
            trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                color: shadColorScheme.foreground),
          ),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SwitchTile(
                      contentPadding: EdgeInsets.zero,
                      title: '自动添加标签',
                      value: repeat.value,
                      onChanged: (bool v) async {
                        repeat.value = v;
                      }),
                  ShadButton.destructive(
                      size: ShadButtonSize.sm,
                      child: Text('保存'),
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
                          Get.snackbar('配置保存成功', '${controller.optionMap['auto_import_tags']} 配置：${res.msg}',
                              colorText: shadColorScheme.foreground);
                        } else {
                          Get.snackbar('配置保存失败', '${controller.optionMap['auto_import_tags']} 配置出错啦：${res.msg}',
                              colorText: shadColorScheme.destructive);
                        }
                      }),
                ],
              ),
            ),
        ],
      );
    });
  }

  void _openAddOptionForm(BuildContext context) {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();
    Logger.instance
        .d(controller.optionChoice.where((e) => !controller.optionList.any((element) => element.name == e.value)));
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
        title: '添加配置项',
        radius: 5,
        titleStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 16, fontWeight: FontWeight.bold),
        backgroundColor: shadColorScheme.background,
        content: Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.optionChoice
                        .where((e) => !controller.optionList.any((element) => element.name == e.value))
                        .map((choice) => CustomCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Center(
                                      child: Text(
                                    choice.name,
                                    style: TextStyle(color: shadColorScheme.foreground),
                                  )),
                                  hoverColor: shadColorScheme.primary,
                                  onTap: () {
                                    Logger.instance.d(choice.value);
                                    if (optionForms[choice.value] != null) {
                                      Get.back();
                                      Get.bottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: shadColorScheme.background,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: SingleChildScrollView(
                                            child: optionForms[choice.value]!(null, context),
                                          ),
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

  List<Widget> _optionListView(BuildContext context) {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();

    return controller.optionList
        .map((option) => CustomCard(
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              child: Slidable(
                  key: ValueKey("${option.name}-${option.id}"),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.2,
                    children: [
                      SlidableAction(
                        flex: 1,
                        // icon: Icons.delete_outline,
                        padding: EdgeInsets.zero,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        onPressed: (BuildContext context) async {
                          var shadColorScheme = ShadTheme.of(context).colorScheme;
                          Get.defaultDialog(
                            title: '确认',
                            radius: 5,
                            titleStyle:
                                const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                            middleText: '确定要删除配置信息吗？',
                            actions: [
                              ShadButton.outline(
                                size: ShadButtonSize.sm,
                                onPressed: () {
                                  Get.back(result: false);
                                },
                                child: const Text('取消'),
                              ),
                              ShadButton.destructive(
                                size: ShadButtonSize.sm,
                                onPressed: () async {
                                  Get.back(result: true);
                                  CommonResponse res = await controller.removeOption(option);
                                  if (res.code == 0) {
                                    Get.snackbar('删除通知', res.msg.toString(), colorText: shadColorScheme.foreground);
                                  } else {
                                    Get.snackbar('删除通知', res.msg.toString(), colorText: shadColorScheme.destructive);
                                  }
                                  await controller.getOptionList();
                                },
                                child: const Text('确认'),
                              ),
                            ],
                          );
                        },
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        label: '删除',
                      ),
                    ],
                  ),
                  child: optionForms[option.name]?.call(option, context) ?? const SizedBox()),
            ))
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
      'meow_push': _meowForm,
      'server_chan_push': _serverChanForm,
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

  Widget _aggregationSearchForm(Option? option, BuildContext context) {
    TextEditingController limitController = TextEditingController(text: option?.value.limit.toString() ?? '30');
    TextEditingController maxCountController = TextEditingController(text: option?.value.maxCount.toString() ?? '30');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '聚合搜索配置',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
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
                      ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          child: Text('保存'),
                          onPressed: () async {
                            if (option == null) {
                              option = Option(
                                id: 0,
                                name: 'aggregation_search',
                                isActive: isActive.value,
                                value: OptionValue(
                                  limit: int.tryParse(limitController.text) ?? 30,
                                  maxCount: int.tryParse(maxCountController.text) ?? 30,
                                ),
                              );
                            } else {
                              option?.isActive = isActive.value;
                              option?.value = OptionValue(
                                limit: int.tryParse(limitController.text) ?? 30,
                                maxCount: int.tryParse(maxCountController.text) ?? 30,
                              );
                            }
                            final res = await controller.saveOption(option!);
                            if (res.code == 0) {
                              Get.back();
                              Get.snackbar('配置保存成功', '${controller.optionMap['aggregation_search']} 配置：${res.msg}',
                                  colorText: shadColorScheme.foreground);
                              isEdit.value = false;
                            } else {
                              Get.snackbar('配置保存失败', '${controller.optionMap['aggregation_search']} 配置出错啦：${res.msg}',
                                  colorText: shadColorScheme.destructive);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _tmdbApiAuthForm(Option? option, BuildContext context) {
    TextEditingController proxyController = TextEditingController(text: option?.value.proxy ?? '');
    TextEditingController apiKeyController = TextEditingController(text: option?.value.apiKey ?? '');
    TextEditingController secretController = TextEditingController(text: option?.value.secretKey ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'TMDB配置',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
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
                  CustomTextField(controller: secretController, labelText: '访问令牌'),
                  CustomTextField(controller: proxyController, labelText: '代理地址'),
                  SwitchTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: 'TMDB开关',
                      value: isActive.value,
                      onChanged: (value) {
                        isActive.value = value;
                      }),
                  Row(
                    children: [
                      ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          child: Text('保存'),
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
                            final res = await controller.saveOption(option!);
                            if (res.code == 0) {
                              Get.back();
                              Get.snackbar('配置保存成功', '${controller.optionMap['tmdb_api_auth']} 配置：${res.msg}',
                                  colorText: shadColorScheme.foreground);
                              isEdit.value = false;
                            } else {
                              Get.snackbar('配置保存失败', '${controller.optionMap['tmdb_api_auth']} 配置出错啦：${res.msg}',
                                  colorText: shadColorScheme.destructive);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _noticeCategoryEnableForm(Option? option, BuildContext context) {
    final isActive = (option == null ? true : option.isActive).obs;
    final aliyundriveNotice = (option == null ? true : option.value.aliyundriveNotice).obs;
    final siteData = (option == null ? true : option.value.siteData).obs;
    final todayData = (option == null ? true : option.value.todayData).obs;
    final packageTorrent = (option == null ? true : option.value.packageTorrent).obs;
    final deleteTorrent = (option == null ? true : option.value.deleteTorrent).obs;
    final rssTorrent = (option == null ? true : option.value.rssTorrent).obs;
    final pushTorrent = (option == null ? true : option.value.pushTorrent).obs;
    final programUpgrade = (option == null ? true : option.value.programUpgrade).obs;
    final ptppImport = (option == null ? true : option.value.ptppImport).obs;
    final announcement = (option == null ? true : option.value.announcement).obs;
    final message = (option == null ? true : option.value.message).obs;
    final signInSuccess = (option == null ? true : option.value.signInSuccess).obs;
    final siteDataSuccess = (option == null ? true : option.value.siteDataSuccess).obs;
    final cookieSync = (option == null ? true : option.value.cookieSync).obs;
    final isEdit = (option == null).obs;
    Logger.instance.d(option);
    Logger.instance.d(aliyundriveNotice.value);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ListTile(
            title: Text(
              '通知开关',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: option != null
                ? ShadIconButton.ghost(
                    onPressed: () async {
                      option?.isActive = !option!.isActive;
                      await controller.saveOption(option!);
                    },
                    icon: option?.isActive == true
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.clear, color: Colors.red))
                : const SizedBox.shrink(),
            onTap: () {
              isEdit.value = !isEdit.value;
            },
            trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                color: shadColorScheme.foreground)),
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
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '阿里云盘',
                            value: aliyundriveNotice.value!,
                            onChanged: (value) {
                              aliyundriveNotice.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '站点数据',
                            value: siteData.value!,
                            onChanged: (value) {
                              siteData.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '成功站点消息',
                            value: siteDataSuccess.value!,
                            onChanged: (value) {
                              siteDataSuccess.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '今日数据',
                            value: todayData.value!,
                            onChanged: (value) {
                              todayData.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '拆包',
                            value: packageTorrent.value!,
                            onChanged: (value) {
                              packageTorrent.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '删种',
                            value: deleteTorrent.value!,
                            onChanged: (value) {
                              deleteTorrent.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: 'RSS',
                            value: rssTorrent.value!,
                            onChanged: (value) {
                              rssTorrent.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '种子推送',
                            value: pushTorrent.value!,
                            onChanged: (value) {
                              pushTorrent.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: 'Docker 升级',
                            value: programUpgrade.value!,
                            onChanged: (value) {
                              programUpgrade.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: 'PTPP 导入',
                            value: ptppImport.value!,
                            onChanged: (value) {
                              ptppImport.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '公告详情',
                            value: announcement.value!,
                            onChanged: (value) {
                              announcement.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '短消息详情',
                            value: message.value!,
                            onChanged: (value) {
                              message.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '签到成功消息',
                            value: signInSuccess.value!,
                            onChanged: (value) {
                              signInSuccess.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: 'CookieCloud 同步',
                            value: cookieSync.value!,
                            onChanged: (value) {
                              cookieSync.value = value;
                            }),
                      ],
                    ),
                  ),
                  ShadButton.destructive(
                      size: ShadButtonSize.sm,
                      child: Text('保存'),
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
                          Get.snackbar('配置保存成功', '${controller.optionMap['notice_category_enable']} 配置：${res.msg}',
                              colorText: shadColorScheme.foreground);
                          isEdit.value = false;
                        } else {
                          Get.snackbar('配置保存失败', '${controller.optionMap['notice_category_enable']} 配置出错啦：${res.msg}',
                              colorText: shadColorScheme.destructive);
                        }
                      }),
                ],
              ),
            ),
          ),
      ]);
    });
  }

  Widget _noticeContentItem(Option? option, BuildContext context) {
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
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isEdit = (option == null).obs;
    Logger.instance.d(option);

    return Obx(() {
      return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ListTile(
            title: Text(
              '站点详情',
              style: TextStyle(color: shadColorScheme.foreground),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: option != null
                ? ShadIconButton.ghost(
                    onPressed: () async {
                      option?.isActive = !option!.isActive;
                      await controller.saveOption(option!);
                    },
                    icon: option?.isActive == true
                        ? const Icon(Icons.check, color: Colors.green)
                        : const Icon(Icons.clear, color: Colors.red))
                : const SizedBox.shrink(),
            onTap: () {
              isEdit.value = !isEdit.value;
            },
            trailing: ExpandIcon(
                isExpanded: isEdit.value,
                onPressed: (value) {
                  isEdit.value = !isEdit.value;
                },
                color: shadColorScheme.foreground)),
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
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '等级',
                            value: level.value!,
                            onChanged: (value) {
                              level.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '魔力',
                            value: bonus.value!,
                            onChanged: (value) {
                              bonus.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '时魔',
                            value: perBonus.value!,
                            onChanged: (value) {
                              perBonus.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '积分',
                            value: score.value!,
                            onChanged: (value) {
                              score.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '分享率',
                            value: ratio.value!,
                            onChanged: (value) {
                              ratio.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '做种体积',
                            value: seedingVol.value!,
                            onChanged: (value) {
                              seedingVol.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '上传量',
                            value: uploaded.value!,
                            onChanged: (value) {
                              uploaded.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '下载量',
                            value: downloaded.value!,
                            onChanged: (value) {
                              downloaded.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '做种数量',
                            value: seeding.value!,
                            onChanged: (value) {
                              seeding.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '吸血数量',
                            value: leeching.value!,
                            onChanged: (value) {
                              leeching.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: '邀请',
                            value: invite.value!,
                            onChanged: (value) {
                              invite.value = value;
                            }),
                        SwitchTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: 'HR',
                            value: hr.value!,
                            onChanged: (value) {
                              hr.value = value;
                            }),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                                Get.snackbar('配置保存成功', '${controller.optionMap['notice_content_item']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar(
                                    '配置保存失败', '${controller.optionMap['notice_content_item']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ]);
    });
  }

  Widget _monkeyTokenForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '安全 Token',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: tokenController, labelText: '令牌'),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          onPressed: () async {
                            tokenController.text = generateRandomString(8);
                            await Clipboard.setData(ClipboardData(text: tokenController.text));
                          },
                          child: Text('随机Token')),
                      ShadButton.secondary(
                          size: ShadButtonSize.sm,
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: tokenController.text));
                          },
                          child: Text('复制Token')),
                      ShadButton.destructive(
                          size: ShadButtonSize.sm,
                          child: Text('保存'),
                          onPressed: () async {
                            if (option == null) {
                              option = Option(
                                id: 0,
                                name: 'monkey_token',
                                isActive: isActive.value,
                                value: OptionValue(token: tokenController.text),
                              );
                            } else {
                              option?.isActive = isActive.value;
                              option?.value = OptionValue(token: tokenController.text);
                            }
                            final res = await controller.saveOption(option!);
                            if (res.code == 0) {
                              Get.back();
                              Get.snackbar('配置保存成功', '${controller.optionMap['monkey_token']} 配置：${res.msg}',
                                  colorText: shadColorScheme.foreground);
                              isEdit.value = false;
                            } else {
                              Get.snackbar('配置保存失败', '${controller.optionMap['monkey_token']} 配置出错啦：${res.msg}',
                                  colorText: shadColorScheme.destructive);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _qyWechatForm(Option? option, BuildContext context) {
    TextEditingController corpIdController = TextEditingController(text: option?.value.corpId ?? '');
    TextEditingController corpSecretController = TextEditingController(text: option?.value.corpSecret ?? '');
    TextEditingController toUidController = TextEditingController(text: option?.value.toUid ?? '@all');
    TextEditingController agentIdController = TextEditingController(text: option?.value.agentId ?? '');
    TextEditingController refreshTokenController = TextEditingController(text: option?.value.refreshToken ?? '');
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    TextEditingController serverController = TextEditingController(text: option?.value.server ?? '');
    TextEditingController proxyController = TextEditingController(text: option?.value.proxy ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '企业微信',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: corpIdController, labelText: '企业 ID'),
                  CustomTextField(controller: corpSecretController, labelText: '企业密钥'),
                  CustomTextField(controller: agentIdController, labelText: '应用 ID'),
                  CustomTextField(controller: toUidController, labelText: '接收 ID'),
                  CustomTextField(controller: refreshTokenController, labelText: 'EncodingAESKey'),
                  CustomTextField(controller: tokenController, labelText: 'Token'),
                  CustomTextField(controller: serverController, labelText: '背景图地址'),
                  CustomTextField(controller: proxyController, labelText: '固定代理'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                                      refreshToken: refreshTokenController.text,
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['wechat_work_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['wechat_work_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _fileListForm(Option? option, BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    TextEditingController usernameController = TextEditingController(text: option?.value.username ?? '');
    TextEditingController passwordController = TextEditingController(text: option?.value.password ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'FileList',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: usernameController, labelText: '账号'),
                  CustomTextField(controller: passwordController, labelText: '密码'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['FileList']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['FileList']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _noticeTestForm(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: '这是一个消息标题');
    TextEditingController messageController = TextEditingController(text: '*这是一条测试消息*  \n__这是二号标题__\n```这是消息```');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isEdit = false.obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: Text(
                  '通知测试',
                  style: TextStyle(color: shadColorScheme.foreground),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: ShadIconButton.ghost(
                  icon: Icon(Icons.notification_important_outlined, color: shadColorScheme.foreground),
                  onPressed: null,
                ),
                onTap: () {
                  isEdit.value = !isEdit.value;
                },
                trailing: ExpandIcon(
                    isExpanded: isEdit.value,
                    onPressed: (value) {
                      isEdit.value = !isEdit.value;
                    },
                    color: shadColorScheme.foreground)),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(autofocus: true, controller: titleController, labelText: '消息标题'),
                    CustomTextField(
                      controller: messageController,
                      labelText: '消息内容',
                      maxLines: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ShadButton.destructive(
                              size: ShadButtonSize.sm,
                              child: Text('发送'),
                              onPressed: () async {
                                final res = await noticeTestApi({
                                  "title": titleController.text,
                                  "message": messageController.text,
                                });
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar('测试消息内容发送成功', '测试消息内容发送成功：${res.msg}',
                                      colorText: shadColorScheme.foreground);
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar('测试消息内容发送失败', '测试消息内容发送出错啦：${res.msg}',
                                      colorText: shadColorScheme.destructive);
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

  Widget _iyuuForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    TextEditingController proxyController = TextEditingController(text: option?.value.proxy ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool repeat = (option == null ? true : option.value.repeat!).obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '爱语飞飞',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: tokenController, labelText: '令牌'),
                  SwitchTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: '辅种开关',
                      value: repeat.value,
                      onChanged: (value) {
                        repeat.value = value;
                      }),
                  // CustomTextField(
                  //     controller: proxyController, labelText: '服务器'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['iyuu_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['iyuu_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _meowForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    TextEditingController serverController = TextEditingController(text: option?.value.server ?? '');
    TextEditingController maxCountController = TextEditingController(text: option?.value.maxCount.toString() ?? '200');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '喵呜通知',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: tokenController, labelText: '喵呜令牌'),
                  CustomTextField(autofocus: true, controller: maxCountController, labelText: 'HTML高度'),
                  CustomTextField(controller: serverController, labelText: '服务器'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
                            onPressed: () async {
                              if (option == null) {
                                option = Option(
                                  id: 0,
                                  name: 'meow_push',
                                  isActive: isActive.value,
                                  value: OptionValue(
                                    token: tokenController.text,
                                    server: serverController.text,
                                    maxCount: int.tryParse(maxCountController.text) ?? 200,
                                  ),
                                );
                              } else {
                                option?.isActive = isActive.value;
                                option?.value = OptionValue(
                                  token: tokenController.text,
                                  server: serverController.text,
                                  maxCount: int.tryParse(maxCountController.text) ?? 200,
                                );
                              }
                              final res = await controller.saveOption(option!);
                              if (res.succeed) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['meow_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['meow_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _serverChanForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    TextEditingController channelController = TextEditingController(text: option?.value.server ?? '');
    TextEditingController noIpController = TextEditingController(text: option?.value.maxCount.toString() ?? '1');
    TextEditingController openidController = TextEditingController(text: option?.value.appId ?? '');

    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'Server酱',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: tokenController, labelText: 'SendKey'),
                  CustomTextField(autofocus: true, controller: openidController, labelText: 'OpenId'),
                  CustomTextField(autofocus: true, controller: channelController, labelText: '消息通道'),
                  CustomTextField(autofocus: true, controller: noIpController, labelText: '隐藏调用IP'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
                            onPressed: () async {
                              if (option == null) {
                                option = Option(
                                  id: 0,
                                  name: 'server_chan_push',
                                  isActive: isActive.value,
                                  value: OptionValue(
                                    token: tokenController.text,
                                    server: channelController.text,
                                    count: int.tryParse(noIpController.text) ?? 1,
                                    appId: openidController.text,
                                  ),
                                );
                              } else {
                                option?.isActive = isActive.value;
                                option?.value = OptionValue(
                                  token: tokenController.text,
                                  server: channelController.text,
                                  count: int.tryParse(noIpController.text) ?? 1,
                                  appId: openidController.text,
                                );
                              }
                              final res = await controller.saveOption(option!);

                              if (res.succeed) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['server_chan_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['server_chan_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _pushDeerForm(Option? option, BuildContext context) {
    TextEditingController keyController = TextEditingController(text: option?.value.key ?? '');
    TextEditingController proxyController = TextEditingController(text: option?.value.proxy ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'PushDeer',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: keyController, labelText: 'Key'),
                  CustomTextField(controller: proxyController, labelText: '服务器'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['pushdeer_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['pushdeer_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _aliDriveForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.refreshToken ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool welfare = true.obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '阿里云盘',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(maxLines: 3, autofocus: true, controller: tokenController, labelText: '保存令牌'),
                  SwitchTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: '领取福利',
                      value: welfare.value,
                      onChanged: (value) {
                        welfare.value = value;
                      }),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['aliyun_drive']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['aliyun_drive']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _ssdForumForm(Option? option, BuildContext context) {
    TextEditingController cookieController = TextEditingController(text: option?.value.cookie ?? '');
    TextEditingController userAgentController = TextEditingController(text: option?.value.userAgent ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    TextEditingController todaySayController =
        TextEditingController(text: option != null ? option.value.todaySay! : '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'SSDForum',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(maxLines: 5, autofocus: true, controller: cookieController, labelText: 'Cookie'),
                  const SizedBox(height: 5),
                  CustomTextField(maxLines: 3, controller: userAgentController, labelText: 'UserAgent'),
                  CustomTextField(maxLines: 5, controller: todaySayController, labelText: '今天想说'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['ssdforum']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['ssdforum']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _baiduOcrForm(Option? option, BuildContext context) {
    TextEditingController appIdController = TextEditingController(text: option?.value.appId ?? '');
    TextEditingController apiKeyController = TextEditingController(text: option?.value.apiKey ?? '');
    TextEditingController secretController = TextEditingController(text: option?.value.secretKey ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                '百度 OCR',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: appIdController, labelText: '应用 ID'),
                  CustomTextField(controller: apiKeyController, labelText: 'APIKey'),
                  CustomTextField(controller: secretController, labelText: 'Secret'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['baidu_ocr']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['baidu_ocr']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _barkForm(Option? option, BuildContext context) {
    TextEditingController deviceIdController = TextEditingController(text: option?.value.deviceKey ?? '');
    TextEditingController serverController = TextEditingController(text: option?.value.server ?? '');
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'Bark',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: deviceIdController, labelText: '设备ID'),
                  CustomTextField(controller: serverController, labelText: '服务器'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['bark_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['bark_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _telegramWebHookForm(BuildContext context) {
    String? baseUrl = SPUtil.getLocalStorage('server');
    String webhook = SPUtil.getString('TELEGRAM_WEBHOOK', defaultValue: '');
    TextEditingController urlController = TextEditingController(
      text: baseUrl != null && baseUrl.startsWith('https') ? baseUrl : webhook,
    );
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    final isEdit = false.obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListTile(
                title: Text(
                  "Telegram Webhook",
                  style: TextStyle(color: shadColorScheme.foreground),
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: ShadIconButton.ghost(
                  onPressed: () async {},
                  icon: Icon(Icons.telegram_outlined, color: shadColorScheme.foreground),
                ),
                onTap: () {
                  isEdit.value = !isEdit.value;
                },
                trailing: ExpandIcon(
                    isExpanded: isEdit.value,
                    onPressed: (value) {
                      isEdit.value = !isEdit.value;
                    },
                    color: shadColorScheme.foreground)),
            if (isEdit.value)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                      autofocus: true,
                      controller: urlController,
                      labelText: 'WebHook地址',
                      helperText: '请仅输入Telegram Webhook地址域名部分，以/结尾，例：https://harvest.example.com/',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
                            onPressed: () => _saveWebHook(context, urlController.text),
                          ),
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

  void _saveWebHook(BuildContext context, String url) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (url.isNotEmpty) {
      if (!url.startsWith('https://')) {
        Get.snackbar(
          'WebHook 地址验证失败！',
          'WebHook 必须使用 https 协议且只能使用 80、443、88、8443端口！',
          colorText: shadColorScheme.destructive,
        );
        return;
      }
      CommonResponse response = await addData(Api.TELEGRAM_WEBHOOK, null, queryParameters: {"host": url});
      if (response.succeed) {
        Get.back();
        SPUtil.setLocalStorage('TELEGRAM_WEBHOOK', url);
      }
      Get.snackbar(
        '保存成功',
        response.msg,
        colorText: response.succeed ? shadColorScheme.foreground : shadColorScheme.destructive,
      );
    } else {
      Get.snackbar(
        '保存失败',
        'WebHook 地址不能为空！',
        colorText: shadColorScheme.destructive,
      );
    }
  }

  Widget _pushPlusForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'PushPlus',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: tokenController, labelText: '令牌'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['pushplus_push']} 保存成功：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['pushplus_push']} 保存出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _wxPusherForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.token ?? '');
    TextEditingController appIdController = TextEditingController(text: option?.value.appId ?? '');
    TextEditingController uidController = TextEditingController(text: option?.value.uids ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'WxPusher',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: appIdController, labelText: '应用 ID'),
                  CustomTextField(controller: tokenController, labelText: '令牌'),
                  CustomTextField(controller: uidController, labelText: '接收人'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['wxpusher_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['wxpusher_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _telegramForm(Option? option, BuildContext context) {
    TextEditingController tokenController = TextEditingController(text: option?.value.telegramToken ?? '');
    TextEditingController proxyController = TextEditingController(text: option?.value.proxy ?? '');
    TextEditingController chatIdController = TextEditingController(text: option?.value.telegramChatId ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'Telegram配置',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: chatIdController, labelText: 'ID'),
                  CustomTextField(controller: tokenController, labelText: '令牌'),
                  CustomTextField(controller: proxyController, labelText: '代理'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['telegram_push']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['telegram_push']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _cookieCloudForm(Option? option, BuildContext context) {
    TextEditingController serverController = TextEditingController(text: option?.value.server ?? '');
    TextEditingController keyController = TextEditingController(text: option?.value.key ?? '');
    TextEditingController passwordController = TextEditingController(text: option?.value.password ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ListTile(
              title: Text(
                'CookieCloud',
                style: TextStyle(color: shadColorScheme.foreground),
              ),
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: option != null
                  ? ShadIconButton.ghost(
                      onPressed: () async {
                        option?.isActive = !option!.isActive;
                        await controller.saveOption(option!);
                      },
                      icon: option!.isActive
                          ? const Icon(Icons.check, color: Colors.green)
                          : const Icon(Icons.clear, color: Colors.red))
                  : const SizedBox.shrink(),
              onTap: () {
                isEdit.value = !isEdit.value;
              },
              trailing: ExpandIcon(
                  isExpanded: isEdit.value,
                  onPressed: (value) {
                    isEdit.value = !isEdit.value;
                  },
                  color: shadColorScheme.foreground)),
          if (isEdit.value)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  CustomTextField(autofocus: true, controller: serverController, labelText: '服务器'),
                  CustomTextField(controller: keyController, labelText: 'Key'),
                  CustomTextField(controller: passwordController, labelText: '密码'),
                  Row(
                    children: [
                      Expanded(
                        child: ShadButton.destructive(
                            size: ShadButtonSize.sm,
                            child: Text('保存'),
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
                              final res = await controller.saveOption(option!);
                              if (res.code == 0) {
                                Get.back();
                                Get.snackbar('配置保存成功', '${controller.optionMap['cookie_cloud']} 配置：${res.msg}',
                                    colorText: shadColorScheme.foreground);
                                isEdit.value = false;
                              } else {
                                Get.snackbar('配置保存失败', '${controller.optionMap['cookie_cloud']} 配置出错啦：${res.msg}',
                                    colorText: shadColorScheme.destructive);
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  _openColorPicker(ShadColorScheme shadColorScheme, Rx<Color> rxColor, String key) {
    Get.defaultDialog(
      title: '选择颜色',
      radius: 8,
      titleStyle: TextStyle(color: shadColorScheme.foreground),
      backgroundColor: shadColorScheme.background,
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (key == SiteColorKeys.siteCardColor)
              Obx(() {
                final bg = Get.find<BackgroundService>();
                return Row(
                  children: [
                    Text(
                      '卡片透明度',
                      style: TextStyle(color: shadColorScheme.foreground),
                    ),
                    Expanded(
                      child: ShadSlider(
                          min: 0.1,
                          max: 1,
                          // divisions: 10,
                          label: bg.opacity.value.toString(),
                          initialValue: bg.opacity.value,
                          onChanged: (value) async {
                            bg.opacity.value = value;
                            bg.save();
                          }),
                    ),
                  ],
                );
              }),
            MaterialPicker(
              // 使用 `flutter_colorpicker` 包
              pickerColor: rxColor.value,
              // labelTypes: [],
              onColorChanged: (color) async {
                Logger.instance.d('选择的颜色: ${color.value}');
                rxColor.value = color;
                await SiteColorConfig.save(scheme: shadColorScheme, key: key, color: color);
              },
            ),
          ],
        ),
      ),
    );
  }

  _siteCardForm(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool signed = true.obs;
    SiteColorConfig siteColorConfig = SiteColorConfig.load(shadColorScheme);
    // Rx<Color> toSignColor = Color(0xFFF44336).obs;
    // Rx<Color> signedColor = Color(0xFF388E3C).obs;
    // Rx<Color> siteCardColor = shadColorScheme.foreground.obs;
    // Rx<Color> siteNameColor = shadColorScheme.foreground.obs;
    // Rx<Color> mailColor = shadColorScheme.foreground.obs;
    // Rx<Color> noticeColor = shadColorScheme.foreground.obs;
    // Rx<Color> regTimeColor = shadColorScheme.foreground.obs;
    // Rx<Color> keepAccountColor = shadColorScheme.destructive.obs;
    // Rx<Color> graduationColor = shadColorScheme.destructive.obs;
    // Rx<Color> inviteColor = shadColorScheme.foreground.obs;
    // Rx<Color> loadingColor = shadColorScheme.foreground.obs;
    // Rx<Color> uploadIconColor = shadColorScheme.primary.obs;
    // Rx<Color> uploadNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> downloadIconColor = shadColorScheme.destructive.obs;
    // Rx<Color> downloadNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> ratioIconColor = shadColorScheme.primary.obs;
    // Rx<Color> ratioNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> seedIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> seedNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> perBonusIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> perBonusNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> bonusIconColor = shadColorScheme.foreground.obs;
    // Rx<Color> bonusNumColor = shadColorScheme.foreground.obs;
    // Rx<Color> updatedAtColor = shadColorScheme.foreground.obs;
    // Rx<Color> hrColor = shadColorScheme.destructive.obs;
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    return Obx(() {
      return GestureDetector(
        onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.siteCardColor, SiteColorKeys.siteCardColor),
        child: CustomCard(
          color: siteColorConfig.siteCardColor.value.withOpacity(opacity),
          child: Column(children: [
            CornerBadge(
              color: signed.value == true ? siteColorConfig.signedColor.value : siteColorConfig.toSignColor.value,
              label: signed.value == true ? '已签到' : '未签到',
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/avatar.png'),
                ),
                onTap: () => signed.value = !signed.value,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.siteNameColor, SiteColorKeys.siteNameColor),
                      child: Text(
                        '站点名称',
                        style: TextStyle(
                          fontSize: 13,
                          color: siteColorConfig.siteNameColor.value,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.mailColor, SiteColorKeys.mailColor),
                      child: Row(
                        children: [
                          Icon(
                            Icons.mail,
                            size: 12,
                            color: siteColorConfig.mailColor.value,
                          ),
                          Text(
                            '2',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.noticeColor.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.noticeColor, SiteColorKeys.noticeColor),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications,
                            size: 12,
                            color: siteColorConfig.noticeColor.value,
                          ),
                          Text(
                            '1',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.noticeColor.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomPopup(
                      showArrow: false,
                      barrierColor: Colors.transparent,
                      backgroundColor: shadColorScheme.background,
                      content: SingleChildScrollView(
                        child: SizedBox(
                            width: 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...[
                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text("下一等级：EliteUser",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF008B8B),
                                        )),
                                  ),
                                  // if (status.uploaded < nextLevelToUploadedByte)
                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('上传量：100GB/750GB',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),
                                  // if (status.downloaded < nextLevelToDownloadedByte)
                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('下载量：100GB/150GB',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('需发种数量：0/40',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('做种积分：4W/8W',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('魔力值：15W/20W',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('升级日期：${DateFormat('yyyy-MM-dd').format(DateTime.now())}/2036-01-01',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('保留账号：true',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),

                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('毕业：false',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),
                                  PopupMenuItem<String>(
                                    height: 13,
                                    child: Text('即将获得：即将获得的权益',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: shadColorScheme.destructive,
                                        )),
                                  ),
                                ],
                                Text('已经获得的权益',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: shadColorScheme.foreground,
                                    )),
                              ],
                            )),
                      ),
                      child: Text(
                        'PowerUser',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFDAA520),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.regTimeColor, SiteColorKeys.regTimeColor),
                      child: Text(
                        '⌚️${calcWeeksDays('2025-02-01')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: siteColorConfig.regTimeColor.value,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openColorPicker(
                          shadColorScheme, siteColorConfig.keepAccountColor, SiteColorKeys.keepAccountColor),
                      child: Text(
                        '🔥保号',
                        style: TextStyle(
                          fontSize: 10,
                          color: siteColorConfig.keepAccountColor.value,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _openColorPicker(
                          shadColorScheme, siteColorConfig.graduationColor, SiteColorKeys.graduationColor),
                      child: Text(
                        '🎓毕业',
                        style: TextStyle(
                          fontSize: 10,
                          color: siteColorConfig.graduationColor.value,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          _openColorPicker(shadColorScheme, siteColorConfig.inviteColor, SiteColorKeys.inviteColor),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_outlined,
                            size: 12,
                            color: siteColorConfig.inviteColor.value,
                          ),
                          Text(
                            '8',
                            style: TextStyle(
                              fontSize: 10,
                              color: siteColorConfig.inviteColor.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: GestureDetector(
                  onTap: () =>
                      _openColorPicker(shadColorScheme, siteColorConfig.loadingColor, SiteColorKeys.loadingColor),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: siteColorConfig.loadingColor.value,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.uploadIconColor, SiteColorKeys.uploadIconColor),
                                  child: Icon(
                                    Icons.upload_outlined,
                                    color: siteColorConfig.uploadIconColor.value,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.uploadNumColor, SiteColorKeys.uploadNumColor),
                                  child: Text(
                                    '1.97 TB(120)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.uploadNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadIconColor,
                                      SiteColorKeys.downloadIconColor),
                                  child: Icon(
                                    Icons.download_outlined,
                                    color: siteColorConfig.downloadIconColor.value,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.downloadNumColor,
                                      SiteColorKeys.downloadNumColor),
                                  child: Text(
                                    '305.65 GB (0)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.downloadNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.ratioIconColor, SiteColorKeys.ratioIconColor),
                                  child: Icon(
                                    Icons.ios_share,
                                    color: siteColorConfig.ratioIconColor.value,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.ratioNumColor, SiteColorKeys.ratioNumColor),
                                  child: Text(
                                    '3 (6.61)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.ratioNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.seedIconColor, SiteColorKeys.seedIconColor),
                                  child: Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 14,
                                    color: siteColorConfig.seedIconColor.value,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.seedNumColor, SiteColorKeys.seedNumColor),
                                  child: Text(
                                    '2.38 TB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.seedNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusIconColor,
                                      SiteColorKeys.perBonusIconColor),
                                  child: Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: siteColorConfig.perBonusIconColor.value,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusNumColor,
                                      SiteColorKeys.perBonusNumColor),
                                  child: Text(
                                    '149.50',
                                    // '(${  status.siteSpFull != null && status.siteSpFull! > 0 ? ((status.statusBonusHour! / status.siteSpFull!) * 100).toStringAsFixed(2) : '0'}%)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.perBonusNumColor.value,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _openColorPicker(shadColorScheme, siteColorConfig.perBonusNumColor,
                                      SiteColorKeys.perBonusNumColor),
                                  child: Text(
                                    // formatNumber(status.bonusHour),
                                    '(73%)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.perBonusNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              textBaseline: TextBaseline.ideographic,
                              children: [
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.bonusIconColor, SiteColorKeys.bonusNumColor),
                                  child: Icon(
                                    Icons.score,
                                    size: 14,
                                    color: siteColorConfig.bonusIconColor.value,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                GestureDetector(
                                  onTap: () => _openColorPicker(
                                      shadColorScheme, siteColorConfig.bonusNumColor, SiteColorKeys.bonusNumColor),
                                  child: Text(
                                    '322W(267W)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: siteColorConfig.bonusNumColor.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _openColorPicker(
                            shadColorScheme, siteColorConfig.updatedAtColor, SiteColorKeys.updatedAtColor),
                        child: Text(
                          '最近更新：1小时前',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: siteColorConfig.updatedAtColor.value,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _openColorPicker(shadColorScheme, siteColorConfig.hrColor, SiteColorKeys.hrColor),
                            child: Text(
                              'HR: 0/0/20',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: siteColorConfig.hrColor.value,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]),
        ),
      );
    });
  }
}
