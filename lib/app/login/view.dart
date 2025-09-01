import 'dart:io';

import 'package:app_service/app_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../api/api.dart';
import '../../common/card_view.dart';
import '../../common/custom_ua.dart';
import '../../common/form_widgets.dart';
import '../../common/logging.dart';
import '../../models/common_response.dart';
import '../../models/login_user.dart';
import '../../utils/logger_helper.dart';
import '../../utils/storage.dart';
import '../routes/app_pages.dart';
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
          border: Border.all(
              color: Theme.of(context).colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        );
      }
      return InkWell(
        onTap: () async {
          if (!server.selected) {
            controller.selectServer(server, shouldSave: true);
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
            onConfirm: () async {
              CommonResponse response = await controller.deleteServer(server);
              if (response.code == 0) {
                Get.snackbar(
                  '删除',
                  '服务器已成功删除',
                  snackPosition: SnackPosition.BOTTOM,
                  colorText: Theme.of(context).colorScheme.primary,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  '删除',
                  '删除服务器失败',
                  snackPosition: SnackPosition.BOTTOM,
                  colorText: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 3),
                );
              }
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
          height: 150,
          width: 150,
          child: CustomCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.computer,
                      size: 32, color: Theme.of(context).colorScheme.primary),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        server.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '${Uri.parse(server.entry).host}:${Uri.parse(server.entry).port}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary),
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
        height: 150,
        width: 150,
        child: CustomCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.add_circle_outline,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
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
    String cacheServer = 'https://images.weserv.nl/?url=';
    return GetBuilder<LoginController>(builder: (controller) {
      return Stack(
        children: [
          GetBuilder<LoginController>(
              id: 'login_view_background_image',
              builder: (controller) {
                if (controller.useBackground) {
                  return Positioned.fill(
                    child: controller.useLocalBackground &&
                            !controller.backgroundImage.startsWith('http')
                        ? Image.file(
                            File(controller.backgroundImage),
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl:
                                '${controller.useImageProxy ? cacheServer : ''}${controller.backgroundImage}',
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Image.asset(
                                'assets/images/background.png',
                                fit: BoxFit.cover),
                            fit: BoxFit.cover,
                          ),
                  );
                }

                return SizedBox.shrink();
              }),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor:
                  Theme.of(context).colorScheme.surface.withOpacity(0.5),
              title: Text(
                '服务器列表',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              actions: [
                ...[
                  IconButton(
                      onPressed: () async {
                        final CommonResponse res =
                            await controller.clearServerCache();
                        if (res.succeed) {
                          Get.snackbar(
                            '清除缓存服务器',
                            '服务器缓存已成功清除',
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Theme.of(context).colorScheme.primary,
                            duration: const Duration(seconds: 3),
                          );
                        } else {
                          Get.snackbar(
                            '清除服务器',
                            '清除服务器缓存失败',
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Theme.of(context).colorScheme.error,
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.cleaning_services_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  const LoggingView(),
                  const SizedBox(width: 15),
                  DarkModeSwitch(
                    borderColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 15),
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: ThemeModal(
                      itemSize: 28,
                    ),
                  ),
                  const SizedBox(width: 15)
                ],
                CustomUAWidget(
                  child: Icon(
                    Icons.settings,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
            body: CustomCard(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Wrap(spacing: 20, runSpacing: 20, children: [
                        ...controller.serverList
                            .map((server) => _buildGridTile(server)),
                        _buildAddServerTile(),
                      ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: ElevatedButton.icon(
                          icon: controller.isLoading
                              ? Center(
                                  child: SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                                )
                              : Icon(Icons.link,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary),
                          label: Text(
                            '连接服务器',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            // 设置背景颜色为绿色
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40.0),
                            // 调整内边距使得按钮更宽
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5.0), // 边角圆角大小可自定义
                            ),
                          ),
                          onPressed: controller.hasSelectedServer
                              ? () async {
                                  // 连接服务器的操作逻辑
                                  CommonResponse res =
                                      await controller.doLogin();

                                  if (res.succeed) {
                                    await Future.delayed(
                                        Duration(milliseconds: 2500), () {
                                      Get.offNamed(Routes.HOME);
                                      Get.snackbar(
                                        res.succeed ? '登录成功！' : '登录失败',
                                        res.succeed
                                            ? '登录成功！欢迎回来，${controller.selectedServer?.username}'
                                            : res.msg,
                                        colorText: res.succeed
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .error,
                                      );
                                    });
                                  } else {
                                    Get.snackbar(
                                      '登录失败',
                                      res.msg,
                                      colorText:
                                          Theme.of(context).colorScheme.error,
                                    );
                                  }
                                  controller.isLoading = false;
                                  controller.update();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (controller.switchServerLoading)
                    Center(child: CircularProgressIndicator())
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  void showEditOrCreateServerSheet(Server? serverToEdit) async {
    final formKey = GlobalKey<FormState>();
    String defaultEntry =
        kIsWeb ? Uri.base.origin : 'http://192.168.123.5:35173';
    TextEditingController nameController =
        TextEditingController(text: serverToEdit?.name ?? 'DefaultServer');
    TextEditingController entryController =
        TextEditingController(text: serverToEdit?.entry ?? defaultEntry);
    TextEditingController usernameController =
        TextEditingController(text: serverToEdit?.username ?? 'admin');
    TextEditingController passwordController =
        TextEditingController(text: serverToEdit?.password ?? 'adminadmin');
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
                  CustomTextField(
                    controller: entryController,
                    labelText: '地址',
                    readOnly: kIsWeb,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      decoration: InputDecoration(
                        labelText: '密码',
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        fillColor: Colors.transparent,
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
                            color: Theme.of(context).colorScheme.primary,
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
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                        label: Text(
                          '取消',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
                        onPressed: () {
                          // 清理表单控制器
                          nameController.clear();
                          entryController.clear();
                          // 关闭底部表单
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // 防止重复点击
                          if (controller.isLoading) return;
                          controller.isLoading = true; // 开始加载状态
                          controller.update();

                          if (formKey.currentState!.validate()) {
                            final server = Server(
                              id: serverToEdit?.id ?? 0,
                              name: nameController.text,
                              entry: entryController.text,
                              username: usernameController.text,
                              password: passwordController.text,
                              selected: serverToEdit?.selected ?? false,
                            );

                            CommonResponse flag =
                                await controller.testServerConnection(server);
                            if (flag.succeed) {
                              CommonResponse result =
                                  await controller.saveServer(server);
                              Get.snackbar(server.id == 0 ? '保存结果' : '更新结果',
                                  "服务器连接成功：${result.msg}",
                                  // snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                  colorText: server.id == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.error);
                              Navigator.pop(context);
                            } else {
                              Get.snackbar('测试失败', flag.msg,
                                  colorText:
                                      Theme.of(context).colorScheme.error);
                              controller.isLoading = false;
                              controller.update();
                            }
                          } else {
                            Get.snackbar('出错啦', '服务器信息校验失败！',
                                duration: const Duration(seconds: 3),
                                colorText: Theme.of(context).colorScheme.error);
                          }
                          controller.isLoading = false;
                          controller.update();
                        },
                        icon: controller.isLoading
                            ? Center(
                                child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )),
                              )
                            : Icon(
                                Icons.autorenew,
                                size: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        label: Text(
                          controller.isLoading ? '测试...' : '保存',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
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

  void connectToServer() async {
    controller.isLoading = true;
    controller.update();
    // 连接到服务器
    if (controller.selectedServer == null ||
        controller.selectedServer?.id == 0 ||
        controller.selectedServer!.username.isEmpty ||
        controller.selectedServer!.password.isEmpty) {
      // 判断是否为新添加的服务器
      Get.snackbar(
        '服务器信息设置有误',
        '无法连接到服务器，请检查用户名和密码',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    controller.initDio(controller.selectedServer!);
    LoginUser loginUser = LoginUser(
      username: controller.selectedServer?.username,
      password: controller.selectedServer?.password,
    );
    await doLogin(loginUser);
    controller.isLoading = false;
    controller.update();
  }

  Future<bool> doLogin(LoginUser loginUser) async {
    try {
      var res = await controller.dioUtil
          .post(Api.LOGIN_URL, formData: loginUser.toJson());
      Logger.instance.i(res.statusCode);
      Logger.instance.i(res.data);
      if (res.data['code'] == 0) {
        SPUtil.setMap('userinfo', res.data["data"]);
        SPUtil.setBool('isLogin', true);
        Get.snackbar(
          '登录成功！',
          "欢迎 ${loginUser.username} 回来",
          colorText: Theme.of(context).colorScheme.primary,
        );
        Get.offNamed(Routes.HOME);
        return true;
      }
      Get.snackbar(
        '登录失败',
        res.data['msg'],
        colorText: Theme.of(context).colorScheme.error,
      );
    } catch (e, stackTrace) {
      Logger.instance.e(stackTrace.toString());
      Get.snackbar(
        '登录失败',
        e.toString(),
        colorText: Theme.of(context).colorScheme.error,
      );
    }
    SPUtil.setBool('isLogin', false);
    controller.isLoading = false;
    controller.update();
    return false;
  }

  @override
  void dispose() {
    Get.delete<LoginController>();
    super.dispose();
  }
}
