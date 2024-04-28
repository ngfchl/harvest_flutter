import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/card_view.dart';
import '../../common/form_widgets.dart';
import '../../common/glass_widget.dart';
import '../../models/common_response.dart';
import '../../utils/logger_helper.dart';
import 'controller.dart';
import 'models/server.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController controller = Get.find();

  Widget _buildGridTile(Server server) {
    return GetBuilder<LoginController>(builder: (controller) {
      BoxDecoration decoration = BoxDecoration(
        border: Border.all(color: Colors.transparent),
      );

      if (server.selected) {
        decoration = BoxDecoration(
          border: Border.all(color: Colors.green, width: 2),
          borderRadius: BorderRadius.circular(8),
        );
      }
      return InkWell(
        onTap: () async {
          if (!server.selected) {
            controller.selectServer(server);
          }
        },
        onDoubleTap: () async {
          showEditOrCreateServerSheet(server);
        },
        onLongPress: () async {
          await Get.defaultDialog(
            title: '确认删除',
            content: Text('您确定要删除${server.name}吗？'),
            barrierDismissible: false,
            onConfirm: () {
              controller.deleteServer(server);
              Navigator.pop(context);
            },
            onCancel: () {
              Navigator.pop(context);
            },
            textConfirm: '删除',
            textCancel: '取消',
          );
        },
        child: Container(
          decoration: decoration,
          height: 120,
          width: 120,
          child: CustomCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.computer, size: 32),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        server.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '${server.domain}:${server.port}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAddServerTile() {
    return GestureDetector(
      onTap: () {
        showEditOrCreateServerSheet(null);
      },
      child: SizedBox(
        height: 120,
        width: 120,
        child: CustomCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.add_circle_outline, size: 32),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          '添加服务器',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('服务器列表'),
          backgroundColor: Colors.grey.shade300,
        ),
        body: GlassWidget(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GetBuilder<LoginController>(builder: (controller) {
                return Wrap(spacing: 12, runSpacing: 8, children: [
                  ...controller.serverList
                      .map((server) => _buildGridTile(server)),
                  _buildAddServerTile(),
                ]);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: ElevatedButton.icon(
                  icon: controller.isLoading
                      ? const Center(
                          child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white70)),
                        )
                      : const Icon(Icons.link, size: 18, color: Colors.white70),
                  label: const Text(
                    '连接服务器',
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    // 设置背景颜色为绿色
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    // 调整内边距使得按钮更宽
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0), // 边角圆角大小可自定义
                    ),
                  ),
                  onPressed: controller.hasSelectedServer
                      ? () async {
                          // 连接服务器的操作逻辑
                          controller.connectToServer();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void showEditOrCreateServerSheet(Server? serverToEdit) async {
    final formKey = GlobalKey<FormState>();
    TextEditingController nameController =
        TextEditingController(text: serverToEdit?.name ?? 'Server');
    TextEditingController protocolController =
        TextEditingController(text: serverToEdit?.protocol ?? 'http');
    TextEditingController domainController =
        TextEditingController(text: serverToEdit?.domain ?? '192.168.123.5');
    TextEditingController usernameController =
        TextEditingController(text: serverToEdit?.username ?? 'admin');
    TextEditingController passwordController =
        TextEditingController(text: serverToEdit?.password ?? 'adminadmin');
    TextEditingController portController =
        TextEditingController(text: serverToEdit?.port.toString() ?? '28000');
    await Get.bottomSheet(
      enableDrag: true,
      GetBuilder<LoginController>(builder: (controller) {
        return CustomCard(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextField(
                    controller: nameController,
                    labelText: '名称',
                  ),
                  CustomPickerField(
                    controller: protocolController,
                    labelText: '选择协议',
                    data: const ["http", "https"],
                    onConfirm: (p, position) {
                      protocolController.text = p;
                    },
                    onChanged: (p, position) {
                      protocolController.text = p;
                    },
                  ),
                  CustomTextField(
                    controller: domainController,
                    labelText: '主机',
                  ),
                  CustomPortField(
                    controller: portController,
                    labelText: '端口',
                  ),
                  CustomTextField(
                    controller: usernameController,
                    labelText: '账号',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8),
                    child: TextFormField(
                      controller: passwordController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '密码',
                        labelStyle: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0x19000000)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0x16000000)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 18,
                          ),
                          onPressed: () {
                            controller.showPassword = !controller.showPassword;
                            controller.update();
                          },
                        ),
                      ),
                      obscureText: controller.showPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '密码不能为空';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 新增取消按钮
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel_outlined,
                            size: 18, color: Colors.white70),
                        label: const Text(
                          '取消',
                          style: TextStyle(color: Colors.white70),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,

                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
                        onPressed: () {
                          // 清理表单控制器
                          nameController.clear();
                          domainController.clear();
                          portController.clear();
                          // 关闭底部表单
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final server = Server(
                            id: 0,
                            name: nameController.text,
                            protocol: protocolController.text,
                            domain: domainController.text,
                            port: int.parse(portController.text),
                            username: usernameController.text,
                            password: passwordController.text,
                            selected: false,
                          );
                          bool flag =
                              await controller.testServerConnection(server);
                          if (flag) {
                            Get.snackbar(
                              '连接状态',
                              '服务器连接成功',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green.shade400,
                              duration: const Duration(seconds: 3),
                            );
                          } else {
                            Get.snackbar(
                              '连接状态',
                              '服务器连接失败',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red.shade400,
                              duration: const Duration(seconds: 3),
                            );
                          }
                        },
                        icon: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Icon(Icons.autorenew,
                                size: 18, color: Colors.white70),
                        label: Text(
                          controller.isLoading ? '测试...' : '测试',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save,
                            size: 18, color: Colors.white70),
                        label: Text(
                          serverToEdit == null ? '添加' : '保存',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final server = Server(
                              id: serverToEdit?.id ?? 0,
                              name: nameController.text,
                              protocol: protocolController.text,
                              domain: domainController.text,
                              port: int.parse(portController.text),
                              username: usernameController.text,
                              password: passwordController.text,
                              selected: serverToEdit?.selected ?? false,
                            );
                            Logger.instance.i(server);
                            CommonResponse result =
                                await controller.saveServer(server);
                            Logger.instance.i(result);
                            if (result.code == 0) {
                              Get.snackbar(
                                server.id == 0 ? '保存结果' : '更新结果',
                                result.msg!,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade400,
                                duration: const Duration(seconds: 3),
                              );
                              Navigator.pop(context);
                            } else {
                              Get.snackbar(
                                server.id == 0 ? '保存结果' : '更新结果',
                                server.id == 0
                                    ? '保存服务器时出错：${result.msg}'
                                    : '更新服务器时出错：${result.msg}',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.shade400,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }
}
