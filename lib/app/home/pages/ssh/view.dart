import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ellipsis_text/flutter_ellipsis_text.dart';
import 'package:get/get.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/common/form_widgets.dart';

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
                                  return CustomCard(
                                      key: ValueKey('${container.id}'),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: 240,
                                                      child: Row(
                                                        children: [
                                                          if (container.hasNew)
                                                            const Icon(
                                                              Icons
                                                                  .arrow_circle_up_outlined,
                                                              size: 13,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          Expanded(
                                                            child: EllipsisText(
                                                              text: container
                                                                  .name
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          13),
                                                              ellipsis: '...',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    isRunning
                                                        ? CustomTextTag(
                                                            labelText: container
                                                                .status!
                                                                .toString())
                                                        : CustomTextTag(
                                                            labelText: container
                                                                .status!
                                                                .toString(),
                                                            backgroundColor:
                                                                Colors
                                                                    .redAccent,
                                                          ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    EllipsisText(
                                                      text: container.image
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 11),
                                                      ellipsis: '...',
                                                    ),
                                                    const SizedBox(
                                                      width: 5,
                                                    ),
                                                    if (container.hasNew)
                                                      ElevatedButton(
                                                          onPressed: () =>
                                                              controller
                                                                  .getNewImage(
                                                                      container
                                                                          .image
                                                                          .toString()),
                                                          child: const Text(
                                                            '下载镜像',
                                                            style: TextStyle(
                                                                fontSize: 11),
                                                          )),
                                                    ElevatedButton(
                                                        onPressed: () => controller
                                                            .checkNewImage(
                                                                container.image
                                                                    .toString()),
                                                        child: const Text(
                                                          '检查更新',
                                                          style: TextStyle(
                                                              fontSize: 11),
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 28,
                                                    maxWidth: 28,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  onPressed: () async {
                                                    await controller
                                                        .stopContainer(container
                                                            .name
                                                            .toString());
                                                  },
                                                  icon: const Icon(
                                                    Icons.stop_circle_outlined,
                                                    size: 13,
                                                  ),
                                                ),
                                                IconButton(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 28,
                                                    maxWidth: 28,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  onPressed: () => controller
                                                      .restartContainer(
                                                          container.name
                                                              .toString()),
                                                  icon: const Icon(
                                                    Icons.refresh_outlined,
                                                    size: 13,
                                                  ),
                                                ),
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 28,
                                                    maxWidth: 28,
                                                  ),
                                                  onPressed: () {
                                                    Get.defaultDialog(
                                                      title: '重建容器',
                                                      middleText:
                                                          '本操作会删除旧容器并使用原来的配置重建容器，具有一定的风险性，请谨慎操作',
                                                      middleTextStyle:
                                                          TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error),
                                                      onConfirm: () {
                                                        controller
                                                            .rebuildContainer(
                                                                container.name
                                                                    .toString(),
                                                                container.image
                                                                    .toString());
                                                        Get.back();
                                                      },
                                                      onCancel: () =>
                                                          Get.back(),
                                                      textCancel: '取消',
                                                      textConfirm: '继续',
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.upload_outlined,
                                                    size: 13,
                                                  ),
                                                ),
                                                IconButton(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxHeight: 28,
                                                    maxWidth: 28,
                                                  ),
                                                  onPressed: () async {
                                                    String newCommand =
                                                        await controller
                                                            .generateNewContainerCommand(
                                                                container
                                                                    .name
                                                                    .toString(),
                                                                container.image
                                                                    .toString());
                                                    Clipboard.setData(
                                                            ClipboardData(
                                                                text:
                                                                    newCommand))
                                                        .then((_) {
                                                      // 可选：在复制后显示消息
                                                      Logger.instance
                                                          .i('文本已复制到剪切板');
                                                    });
                                                  },
                                                  icon: const Icon(
                                                    Icons.copy_outlined,
                                                    size: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ));
                                });
                          })),
                  CustomCard(
                      height: MediaQuery.of(context).size.height * 0.2,
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
}
