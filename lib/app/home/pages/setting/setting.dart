import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';

import '../../../../common/glass_widget.dart';
import '../../../../common/utils.dart';
import '../../../../utils/logger_helper.dart';
import '../models/option.dart';
import 'setting_controller.dart';

typedef OptionFormBuilder = Widget Function(Option? option);

class SettingPage extends StatelessWidget {
  SettingPage({super.key, param});

  final controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: GlassWidget(
          child: GetBuilder<SettingController>(builder: (controller) {
            return EasyRefresh(
              onRefresh: controller.getOptionList,
              child: Column(
                children: [
                  _versionCard(),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ..._optionListView(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: IconButton(
            onPressed: () {
              _openAddOptionForm();
            },
            icon: const Icon(Icons.add)),
      ),
    );
  }

  _versionCard() {
    return CustomCard(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      child: ListTile(
        dense: true,
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
            // backgroundColor: Colors.white,
            content: AboutDialog(
              applicationIcon: Image.asset(
                'assets/images/logo.png',
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

  void _openAddOptionForm() {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();
    Get.defaultDialog(
        title: '选择配置项',
        content: SingleChildScrollView(
          child: Column(
            children: controller.optionChoice
                .where((e) => !controller.optionList
                    .any((element) => element.name == e.value))
                .map((choice) => CustomCard(
                      child: ListTile(
                          title: Center(child: Text(choice.name)),
                          hoverColor: Colors.teal,
                          focusColor: Colors.teal,
                          splashColor: Colors.teal,
                          onTap: () {
                            Logger.instance.i(choice.value);
                            if (optionForms[choice.value] != null) {
                              Get.back();
                              Get.bottomSheet(
                                SingleChildScrollView(
                                    child: CustomCard(
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.zero,
                                        child:
                                            optionForms[choice.value]!(null))),
                                backgroundColor: Colors.transparent,
                              );
                            }
                          }),
                    ))
                .toList(),
          ),
        ));
  }

  List<Widget> _optionListView() {
    Map<String, OptionFormBuilder> optionForms = _optionFormMap();
    List<Widget> children = [];
    for (var option in controller.optionList) {
      children.add(optionForms[option.name]!(option));
    }
    return controller.optionList
        .map((option) =>
            optionForms[option.name]?.call(option) ?? const SizedBox())
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
    };
    return optionForms;
  }

  Widget _monkeyTokenForm(Option? option) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
          children: [
            ListTile(
                title: const Text('油猴 Token'),
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
                        controller: tokenController, labelText: '令牌'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _qyWechatForm(Option? option) {
    TextEditingController corpIdController =
        TextEditingController(text: option?.value.corpId ?? '');
    TextEditingController corpSecretController =
        TextEditingController(text: option?.value.corpSecret ?? '');
    TextEditingController toUidController =
        TextEditingController(text: option?.value.toUid ?? '@all');
    TextEditingController agentIdController =
        TextEditingController(text: option?.value.agentId ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
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
                        controller: corpIdController, labelText: '企业 ID'),
                    CustomTextField(
                        controller: corpSecretController, labelText: '企业密钥'),
                    CustomTextField(
                        controller: agentIdController, labelText: '应用 ID'),
                    CustomTextField(
                        controller: toUidController, labelText: '接收 ID'),
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
                                        proxy: proxyController.text),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                      corpSecret: corpSecretController.text,
                                      agentId: agentIdController.text,
                                      corpId: corpIdController.text,
                                      toUid: toUidController.text,
                                      proxy: proxyController.text);
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _fileListForm(Option? option) {
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
                        controller: usernameController, labelText: '账号'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _iyuuForm(Option? option) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    TextEditingController proxyController =
        TextEditingController(text: option?.value.proxy ?? '');
    RxBool repeat = true.obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
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
                        controller: tokenController, labelText: '令牌'),
                    SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('辅种开关'),
                        value: repeat.value,
                        onChanged: (value) {
                          repeat.value = value;
                        }),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _pushDeerForm(Option? option) {
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
                        controller: keyController, labelText: 'Key'),
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
                                    name: 'iyuu_push',
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _aliDriveForm(Option? option) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.refreshToken ?? '');
    RxBool welfare = true.obs;
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
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
                        controller: tokenController,
                        labelText: '保存令牌'),
                    SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
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
                                    name: 'iyuu_push',
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _ssdForumForm(Option? option) {
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
                        maxLines: 10,
                        controller: cookieController,
                        labelText: 'Cookie'),
                    const SizedBox(height: 5),
                    CustomTextField(
                        maxLines: 3,
                        controller: userAgentController,
                        labelText: 'UserAgent'),
                    CustomTextField(
                        maxLines: 10,
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
                                    name: 'iyuu_push',
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _baiduOcrForm(Option? option) {
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
                        controller: appIdController, labelText: '应用 ID'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _barkForm(Option? option) {
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
                        controller: deviceIdController, labelText: '设备ID'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _pushPlusForm(Option? option) {
    TextEditingController tokenController =
        TextEditingController(text: option?.value.token ?? '');
    final isActive = (option == null ? true : option.isActive).obs;
    final isEdit = (option == null).obs;
    return Obx(() {
      return CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
        child: Column(
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
                        controller: tokenController, labelText: '令牌'),
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
                                      deviceKey: tokenController.text,
                                      template: 'markdown',
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    deviceKey: tokenController.text,
                                    template: 'markdown',
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 保存成功：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _wxPusherForm(Option? option) {
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
                        controller: appIdController, labelText: '应用 ID'),
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
                                      appId: tokenController.text,
                                      token: tokenController.text,
                                      uids: uidController.text,
                                    ),
                                  );
                                } else {
                                  option?.isActive = isActive.value;
                                  option?.value = OptionValue(
                                    appId: tokenController.text,
                                    token: tokenController.text,
                                    uids: uidController.text,
                                  );
                                }
                                final res =
                                    await controller.saveOption(option!);
                                if (res.code == 0) {
                                  Get.back();
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _telegramForm(Option? option) {
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
                        controller: chatIdController, labelText: 'ID'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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

  Widget _cookieCloudForm(Option? option) {
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
                        controller: serverController, labelText: '服务器'),
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
                                  Get.snackbar(
                                    '配置保存成功',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.green.shade300,
                                  );
                                  isEdit.value = false;
                                } else {
                                  Get.snackbar(
                                    '配置保存失败',
                                    '${controller.optionChoice.firstWhere((element) => element.value == option?.name).name} 数据保存出错啦：${res.msg}',
                                    colorText: Colors.white,
                                    backgroundColor: Colors.red.shade300,
                                  );
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
