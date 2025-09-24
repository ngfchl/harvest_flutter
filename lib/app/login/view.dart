import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      var themeData = ShadTheme.of(context);
      if (server.selected) {
        decoration = BoxDecoration(
          border: Border.all(color: themeData.colorScheme.foreground, width: 2),
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
                  colorText: themeData.colorScheme.foreground,
                  duration: const Duration(seconds: 3),
                );
              } else {
                Get.snackbar(
                  '删除',
                  '删除服务器失败',
                  snackPosition: SnackPosition.BOTTOM,
                  colorText: themeData.colorScheme.destructiveForeground,
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
                  child: Icon(Icons.computer, size: 32, color: themeData.colorScheme.foreground),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        server.name,
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.h4.copyWith(color: themeData.colorScheme.foreground),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '${Uri.parse(server.entry).host}:${Uri.parse(server.entry).port}',
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.p.copyWith(color: themeData.colorScheme.foreground),
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
    var themeData = ShadTheme.of(context);
    return GestureDetector(
      onTap: () {
        showEditOrCreateServerSheet(null);
      },
      child: SizedBox(
        height: 150,
        width: 150,
        child: CustomCard(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 32,
                    color: themeData.colorScheme.foreground,
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
                            style: themeData.textTheme.h4.copyWith(color: themeData.colorScheme.foreground),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        '',
                        textAlign: TextAlign.center,
                        style: themeData.textTheme.p,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String cacheServer = 'https://images.weserv.nl/?url=';
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<LoginController>(builder: (controller) {
      CancelToken cancelToken = CancelToken();
      var themeData = ShadTheme.of(context);
      return Stack(
        children: [
          GetBuilder<LoginController>(
              id: 'login_view_background_image',
              builder: (controller) {
                if (controller.useBackground) {
                  return Positioned.fill(
                    child: controller.useLocalBackground && !controller.backgroundImage.startsWith('http')
                        ? Image.file(
                            File(controller.backgroundImage),
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: '${controller.useImageProxy ? cacheServer : ''}${controller.backgroundImage}',
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/images/background.png', fit: BoxFit.cover),
                            fit: BoxFit.cover,
                            cacheKey: controller.backgroundImage,
                          ),
                  );
                }

                return SizedBox.shrink();
              }),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: themeData.colorScheme.background.withOpacity(opacity),
              elevation: 1,
              title: Text(
                '服务器列表',
                style: themeData.textTheme.h4,
              ),
              actions: [
                ...[
                  ShadIconButton.ghost(
                      onPressed: () async {
                        showShadDialog(
                          context: context,
                          builder: (context) => ShadDialog.alert(
                            title: const Text('警告'),
                            description: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('确认清除服务器列表？'),
                            ),
                            actions: [
                              ShadButton.destructive(
                                child: const Text('取消'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              ShadButton(
                                child: const Text('清除'),
                                onPressed: () async {
                                  Navigator.of(context).pop(true);
                                  final CommonResponse res = await controller.clearServerCache();
                                  if (res.succeed) {
                                    controller.initServerList();
                                    ShadToaster.of(context).show(
                                      ShadToast(
                                        description: Text('服务器缓存已成功清除'),
                                      ),
                                    );
                                  } else {
                                    ShadToaster.of(context).show(
                                      ShadToast.destructive(
                                        description: Text('清除服务器缓存失败：${res.msg}'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.cleaning_services_outlined,
                        size: 18,
                      )),
                  const LoggingView(),
                ],
                CustomUAWidget(
                  child: Icon(
                    Icons.verified_user,
                    size: 20,
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
                  Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Wrap(spacing: 20, runSpacing: 20, children: [
                            ...controller.serverList.map((server) => _buildGridTile(server)),
                            _buildAddServerTile(),
                          ]),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36.0,
                              vertical: 20,
                            ),
                            child: controller.isLoading
                                ? ShadButton.destructive(
                                    onPressed: () {
                                      cancelToken.cancel();
                                    },
                                    leading: SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: shadColorScheme.destructiveForeground,
                                      ),
                                    ),
                                    child: const Text('连接中，点击取消'),
                                  )
                                : ShadButton(
                                    onPressed: !controller.hasSelectedServer
                                        ? null
                                        : () async {
                                            // 连接服务器的操作逻辑
                                            CommonResponse res = await controller.doLogin(cancelToken);

                                            if (res.succeed) {
                                              await Future.delayed(Duration(milliseconds: 1500), () {
                                                Get.offNamed(Routes.HOME);

                                                ShadToaster.of(context).show(
                                                  ShadToast(
                                                    description:
                                                        Text('登录成功！欢迎回来，${controller.selectedServer?.username}'),
                                                  ),
                                                );
                                              });
                                            } else {
                                              ShadToaster.of(context).show(
                                                ShadToast.destructive(
                                                  description: Text(res.msg),
                                                ),
                                              );
                                            }

                                            controller.isLoading = false;
                                            controller.update();
                                          },
                                    leading: const Icon(LucideIcons.link),
                                    child: const Text('连接服务器'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (controller.switchServerLoading)
                    Center(
                        child: CircularProgressIndicator(
                      color: shadColorScheme.primary,
                    ))
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
    String defaultEntry = kIsWeb ? Uri.base.origin : 'http://192.168.123.5:35173';
    TextEditingController nameController = TextEditingController(text: serverToEdit?.name ?? 'DefaultServer');
    TextEditingController entryController = TextEditingController(text: serverToEdit?.entry ?? defaultEntry);
    TextEditingController usernameController = TextEditingController(text: serverToEdit?.username ?? 'admin');
    TextEditingController passwordController = TextEditingController(text: serverToEdit?.password ?? 'adminadmin');
    CancelToken cancelToken = CancelToken();
    await Get.bottomSheet(
      enableDrag: true,
      GetBuilder<LoginController>(builder: (controller) {
        var themeData = ShadTheme.of(context);
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
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                    child: TextFormField(
                      controller: passwordController,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: themeData.colorScheme.foreground,
                      ),
                      decoration: InputDecoration(
                        labelText: '密码',
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        fillColor: Colors.transparent,
                        labelStyle: const TextStyle(fontSize: 12, color: Colors.black54),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0x19000000)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0x16000000)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showPassword ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: themeData.colorScheme.foreground,
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
                        icon: Icon(Icons.cancel_outlined, size: 18, color: themeData.colorScheme.destructiveForeground),
                        label: Text(
                          '取消',
                          style: TextStyle(
                            color: themeData.colorScheme.destructiveForeground,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.colorScheme.destructive,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 边角圆角大小可自定义
                          ),
                        ),
                        onPressed: () {
                          // 清理表单控制器
                          try {
                            cancelToken.cancel();
                            nameController.clear();
                            entryController.clear();
                          } catch (e, trace) {
                            Logger.instance.e(e.toString());
                            Logger.instance.d(trace);
                          }

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
                                await controller.testServerConnection(server, cancelToken: cancelToken);
                            if (flag.succeed) {
                              CommonResponse result = await controller.saveServer(server);
                              Get.snackbar(server.id == 0 ? '保存结果' : '更新结果', "服务器连接成功：${result.msg}",
                                  // snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                  colorText: server.id == 0
                                      ? themeData.colorScheme.foreground
                                      : themeData.colorScheme.destructiveForeground);
                              Navigator.pop(context);
                            } else {
                              Get.snackbar('测试失败', flag.msg, colorText: themeData.colorScheme.destructiveForeground);
                              controller.isLoading = false;
                              controller.update();
                            }
                          } else {
                            Get.snackbar('出错啦', '服务器信息校验失败！',
                                duration: const Duration(seconds: 3),
                                colorText: themeData.colorScheme.destructiveForeground);
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
                                      color: themeData.colorScheme.primary,
                                    )),
                              )
                            : Icon(
                                Icons.autorenew,
                                size: 18,
                                color: themeData.colorScheme.primaryForeground,
                              ),
                        label: Text(
                          controller.isLoading ? '测试...' : '保存',
                          style: TextStyle(
                            color: themeData.colorScheme.primaryForeground,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeData.colorScheme.foreground,
                          // 设置背景颜色为绿色
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0), // 边角圆角大小可自定义
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
    ).whenComplete(() {
      controller.isLoading = false;
      controller.update();
    });
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
        colorText: ShadTheme.of(context).colorScheme.destructiveForeground,
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
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    try {
      var res = await controller.dioUtil.post(Api.LOGIN_URL, formData: loginUser.toJson());
      Logger.instance.i(res.statusCode);
      Logger.instance.i(res.data);
      if (res.data['code'] == 0) {
        SPUtil.setMap('userinfo', res.data["data"]);
        SPUtil.setBool('isLogin', true);
        Get.snackbar(
          '登录成功！',
          "欢迎 ${loginUser.username} 回来",
          colorText: shadColorScheme.foreground,
        );
        Get.offNamed(Routes.HOME);
        return true;
      }
      Get.snackbar(
        '登录失败',
        res.data['msg'],
        colorText: shadColorScheme.destructiveForeground,
      );
    } catch (e, stackTrace) {
      Logger.instance.e(stackTrace.toString());
      Get.snackbar(
        '登录失败',
        e.toString(),
        colorText: shadColorScheme.destructiveForeground,
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
