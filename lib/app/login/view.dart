import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/theme/background_container.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/api.dart';
import '../../common/app_upgrade/view.dart';
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
        onDoubleTap: () => showEditOrCreateServerSheet(server),
        onLongPress: () async {
          await Get.defaultDialog(
            title: '确认删除',
            content: Text('您确定要删除${server.name}吗？'),
            barrierDismissible: false,
            onConfirm: () async {
              CommonResponse response = await controller.deleteServer(server);
              ShadToaster.of(context).show(
                response.succeed
                    ? ShadToast(title: const Text('成功啦'), description: Text('服务器已成功删除！'))
                    : ShadToast.destructive(title: const Text('出错啦'), description: Text('服务器已删除失败！')),
              );
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
      onTap: () => showEditOrCreateServerSheet(null),
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
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<LoginController>(builder: (controller) {
      CancelToken cancelToken = CancelToken();
      var themeData = ShadTheme.of(context);
      return BackgroundContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: themeData.colorScheme.background,
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
                            ShadButton.outline(
                              child: const Text('取消'),
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                            ShadButton.destructive(
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
              AppUpgradePage(),
              CustomUAWidget(
                child: Icon(
                  Icons.verified_user,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          body: EasyRefresh(
            onRefresh: () => controller.initServerList(),
            child: CustomCard(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: [
                                    ...controller.serverList.map((server) => _buildGridTile(server)),
                                    _buildAddServerTile(),
                                  ]),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36.0,
                            vertical: 20,
                          ),
                          child: controller.isLoading
                              ? ShadButton.destructive(
                                  onPressed: () {
                                    cancelToken.cancel();
                                    Logger.instance.d('取消登录：${cancelToken.isCancelled}');
                                    controller.isLoading = false;
                                    controller.update();
                                    Get.forceAppUpdate();
                                    // Get.offAndToNamed(Routes.LOGIN);
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
                              : ShadButton.destructive(
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
                                                  description: Text('登录成功！欢迎回来，${controller.selectedServer?.username}'),
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
                                  leading: const Icon(Icons.link_outlined),
                                  child: const Text('连接服务器'),
                                ),
                        ),
                      ],
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
        ),
      );
    });
  }

  void showEditOrCreateServerSheet(Server? serverToEdit) {
    final formKey = GlobalKey<FormState>();
    String defaultEntry = kIsWeb ? Uri.base.origin : (serverToEdit?.entry ?? 'http://192.168.1');
    TextEditingController nameController = TextEditingController(text: serverToEdit?.name ?? 'DefaultServer');
    TextEditingController entryController = TextEditingController(text: defaultEntry);
    TextEditingController usernameController = TextEditingController(text: serverToEdit?.username ?? 'admin');
    TextEditingController passwordController = TextEditingController(text: serverToEdit?.password ?? 'adminadmin');
    CancelToken cancelToken = CancelToken();
    var shadColorScheme = ShadTheme.of(context).colorScheme;

    var serverList = [
      'http://192.168.31.10:25174',
      'http://192.168.31.31:25174',
      'http://192.168.123.5:35173',
      'http://192.168.123.5:25174',
      'http://192.168.123.5:5173',
      'http://192.168.31.10:5173',
      'http://192.168.31.31:5173',
      'http://192.168.1.',
      'http://192.168.2.',
      'http://192.168.3.',
      'http://192.168.50.',
      'http://127.0.0.1',
      'http://127.0.0.1:',
      'http://127.0.0.1:28080',
      'http://127.0.0.1:28000',
      'http://127.0.0.1:25173',
      'http://127.0.0.1:5173',
    ];
    Get.bottomSheet(
      // enableDrag: true,
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
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: defaultEntry),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      Logger.instance.d(textEditingValue.text);
                      entryController.text = textEditingValue.text;
                      List<String> filterList = [];
                      if (textEditingValue.text.isEmpty) {
                        filterList = serverList;
                      } else {
                        filterList = serverList.where((String option) {
                          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                        }).toList();
                      }
                      Logger.instance.d(filterList);
                      return filterList;
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            color: shadColorScheme.card,
                            shadowColor: shadColorScheme.foreground.withOpacity(0.15),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200, minWidth: 200),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: shadColorScheme.foreground.withOpacity(0.05),
                                ),
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: shadColorScheme.foreground,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      entryController.text = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      return CustomTextField(
                        controller: textEditingController,
                        labelText: '地址',
                        focusNode: focusNode, // ✅ 一定要传！
                        readOnly: kIsWeb,
                      );
                    },
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
                        color: shadColorScheme.foreground,
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
                            color: shadColorScheme.foreground,
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
                      ShadButton.outline(
                        leading: Icon(Icons.cancel_outlined, size: 18, color: shadColorScheme.destructiveForeground),
                        child: Text(
                          '取消',
                          style: TextStyle(
                            color: shadColorScheme.destructiveForeground,
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
                      ShadButton.destructive(
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
                              ShadToaster.of(context).show(
                                ShadToast(title: const Text('成功啦'), description: Text("服务器连接成功：${result.msg}")),
                              );
                              Navigator.pop(context);
                            } else {
                              ShadToaster.of(context).show(
                                ShadToast.destructive(
                                  title: const Text('出错啦'),
                                  description: Text(flag.msg),
                                ),
                              );
                              controller.isLoading = false;
                              controller.update();
                            }
                          } else {
                            ShadToaster.of(context).show(
                              ShadToast.destructive(
                                title: const Text('出错啦'),
                                description: Text('服务器信息校验失败！'),
                              ),
                            );
                          }
                          controller.isLoading = false;
                          controller.update();
                        },
                        leading: controller.isLoading
                            ? Center(
                                child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: shadColorScheme.primaryForeground,
                                    )),
                              )
                            : Icon(
                                Icons.autorenew,
                                size: 18,
                                color: shadColorScheme.primaryForeground,
                              ),
                        child: Text(
                          controller.isLoading ? '测试...' : '保存',
                          style: TextStyle(
                            color: shadColorScheme.primaryForeground,
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
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('出错啦'),
          description: Text('无法连接到服务器，请检查用户名和密码！'),
        ),
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
        ShadToaster.of(context).show(
          ShadToast(
              title: const Text('登录成功啦'),
              description: Text(
                "欢迎 ${loginUser.username} 回来",
              )),
        );
        Get.offNamed(Routes.HOME);
        return true;
      }

      ShadToaster.of(context).show(
        ShadToast.destructive(title: const Text('出登录失败错啦'), description: Text(res.data['msg'])),
      );
    } catch (e, stackTrace) {
      Logger.instance.e(stackTrace.toString());
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('登录出错啦'),
          description: Text(e.toString()),
        ),
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
