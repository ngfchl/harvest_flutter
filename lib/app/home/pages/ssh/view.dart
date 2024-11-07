import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';

import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import 'controller.dart';
import 'models.dart';

class SshWidget extends StatelessWidget {
  SshWidget({super.key});

  final SshController controller = Get.put(SshController());

  @override
  Widget build(BuildContext context) {
    TextEditingController commandController = TextEditingController();

    return GetBuilder<SshController>(builder: (controller) {
      return Scaffold(
        body: controller.connected
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: commandController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '请输入命令',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              await controller.execute(commandController.text);
                            },
                            child: const Text('发送')),
                        ElevatedButton(
                            onPressed: () {
                              controller.clear();
                            },
                            child: const Text('清除')),
                        ElevatedButton(
                            onPressed: () {
                              controller.getContainerList();
                            },
                            child: const Text('刷新')),
                        ElevatedButton(
                            onPressed: () {
                              controller.disconnect();
                            },
                            child: const Text('断开')),
                      ],
                    ),
                  ),
                  Expanded(
                      child: StreamBuilder<List<DockerContainer>>(
                          stream: controller.containerStream,
                          builder: (context, snapshot) {
                            return ListView.builder(
                                itemCount: controller.containerList.length,
                                itemBuilder: (context, index) {
                                  DockerContainer container =
                                      controller.containerList[index];
                                  bool isRunning = container.status!
                                      .toLowerCase()
                                      .startsWith('up');
                                  return buildContainerCard(container,
                                      isRunning, controller, context);
                                });
                          })),
                  CustomCard(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                          itemCount: controller.results.length,
                          itemBuilder: (context, index) {
                            String res = controller.results[index];
                            return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                width: MediaQuery.of(context).size.width,
                                child: SelectableText(
                                  res.toString().trim(),
                                  style: const TextStyle(fontSize: 11),
                                ));
                          })),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppBar(
                    title: const Text('SSH Client'),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CustomTextTag(
                      labelText: 'SSH 连接设备为危险操作，请你一定要知晓每一个 SSH 命令的含义确认操作',
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '本功能仅支持使用 root 账户登录或者不使用 root账户可以直接操作的设备。已知不可用设备：群晖、极空间，',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller.hostController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '请输入服务器地址',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller.portController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '请输入 SSH 端口',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller.usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '请输入账号',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '请输入密码',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: controller.proxyController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '默认代理',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwitchListTile(
                        title: const Text('记住密码'),
                        value: controller.remember,
                        onChanged: (bool value) {
                          controller.remember = value;
                          controller.update();
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FullWidthButton(
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        await controller.connect();
                        try {
                          if (!controller.connected) {
                            Get.snackbar('登录失败！', '登录失败啦，请检查用户名密码！');
                          }
                        } catch (e, trace) {
                          Logger.instance.e(e);
                          Logger.instance.e(trace);
                        }
                      },
                      text: '连接',
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget buildContainerCard(DockerContainer container, bool isRunning,
      SshController controller, BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(8),
      child: Slidable(
        key: ValueKey('${container.id}_${container.name}'),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 1 / 3,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                CommonResponse res =
                    await controller.stopContainer(container.name.toString());
                if (res.code == 0) {
                  Get.snackbar('通知', res.msg.toString(),
                      colorText: Theme.of(context).colorScheme.primary);
                } else {
                  Get.snackbar('通知', res.msg.toString(),
                      colorText: Theme.of(context).colorScheme.error);
                }
              },
              backgroundColor: const Color(0xFF0A9D96),
              foregroundColor: Colors.white,
              icon: Icons.stop_circle_outlined,
              label: '停止',
            ),
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) =>
                  controller.restartContainer(container.name.toString()),
              backgroundColor: const Color(0xFF0392CF),
              foregroundColor: Colors.white,
              // icon: Icons.edit,
              label: '重启',
              icon: Icons.refresh_outlined,
            ),
            container.hasNew
                ? SlidableAction(
                    flex: 1,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onPressed: (context) =>
                        controller.getNewImage(container.image.toString()),
                    backgroundColor: const Color(0xFF0392CF),
                    foregroundColor: Colors.white,
                    // icon: Icons.edit,
                    label: '下载',
                    icon: Icons.download_outlined,
                  )
                : SlidableAction(
                    flex: 1,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    onPressed: (context) =>
                        controller.checkNewImage(container.image.toString()),
                    backgroundColor: const Color(0xFF0392CF),
                    foregroundColor: Colors.white,
                    // icon: Icons.edit,
                    label: '检查',
                    icon: Icons.check_outlined,
                  ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                Get.defaultDialog(
                  title: '重建容器',
                  middleText: '本操作会删除旧容器并使用原来的配置重建容器，具有一定的风险性，请谨慎操作',
                  middleTextStyle:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                  onConfirm: () {
                    controller.rebuildContainer(
                        container.name.toString(), container.image.toString());
                    Get.back();
                  },
                  onCancel: () => Get.back(),
                  textCancel: '取消',
                  textConfirm: '继续',
                );
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.upload_outlined,
              label: '重建',
            ),
            SlidableAction(
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              onPressed: (context) async {
                String newCommand =
                    await controller.generateNewContainerCommand(
                        container.name.toString(), container.image.toString());
                Clipboard.setData(ClipboardData(text: newCommand)).then((_) {
                  // 可选：在复制后显示消息
                  Logger.instance.i('重建命令已复制到剪切板');
                });
              },
              backgroundColor: const Color(0xFF069556),
              foregroundColor: Colors.white,
              icon: Icons.copy_outlined,
              label: '复制',
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 240,
                        child: Row(
                          children: [
                            if (container.hasNew)
                              const Icon(
                                Icons.arrow_circle_up_outlined,
                                size: 13,
                                color: Colors.green,
                              ),
                            Expanded(
                              child: EllipsisText(
                                text: container.name.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                ellipsis: '...',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        container.status!.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: isRunning
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EllipsisText(
                        text: container.image.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        ellipsis: '...',
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      if (container.hasNew)
                        ElevatedButton(
                            onPressed: () => controller
                                .getNewImage(container.image.toString()),
                            child: const Text(
                              '下载镜像',
                              style: TextStyle(fontSize: 11),
                            )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
