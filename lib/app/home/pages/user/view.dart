import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/components/typography/gf_typography.dart';
import 'package:harvest/app/home/pages/user/UserModel.dart';
import 'package:harvest/common/card_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../../controller/home_controller.dart';
import 'controller.dart';

class UserWidget extends StatelessWidget {
  UserWidget({super.key});

  final UserController controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: (controller.userinfo?.isStaff == true ||
              controller.userinfo?.isStaff == true)
          ? IconButton(
              icon: Icon(
                Icons.add,
                size: 20,
                color: ShadTheme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                _showEditBottomSheet(context: context);
              },
            )
          : null,
      body: GetBuilder<UserController>(builder: (controller) {
        return controller.isLoading
            ? const Center(child: GFLoader())
            : EasyRefresh(
                onRefresh: () => controller.getUserListFromServer(),
                child: SingleChildScrollView(
                  child: ListView.builder(
                      physics: const ScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: controller.userList.length,
                      itemBuilder: (BuildContext context, int index) {
                        UserModel user = controller.userList[index];
                        return CustomCard(
                          child: Slidable(
                            key: ValueKey('${user.id}_${user.username}'),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  flex: 1,
                                  icon: Icons.edit,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                  onPressed: (context) async {
                                    _showEditBottomSheet(
                                        user: user, context: context);
                                  },
                                  backgroundColor: const Color(0xFF0392CF),
                                  foregroundColor: Colors.white,
                                  // icon: Icons.edit,
                                  label: '编辑',
                                ),
                                if (!user.isStaff &&
                                    user.username != controller.userinfo?.user)
                                  SlidableAction(
                                    flex: 1,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    onPressed: (context) async {
                                      Get.defaultDialog(
                                        title: '确认',
                                        radius: 5,
                                        titleStyle: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.deepPurple),
                                        middleText: '确定要删除用户吗？',
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.back(result: false);
                                            },
                                            child: const Text('取消'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              Get.back(result: true);
                                              controller.userList.remove(user);
                                              controller.update();
                                              CommonResponse res =
                                                  await controller
                                                      .removeUserModel(user);
                                              if (res.code == 0) {
                                                Get.snackbar(
                                                    '删除通知', res.msg.toString(),
                                                    colorText: ShadTheme.of(context)
                                                        .colorScheme
                                                        .primary);
                                              } else {
                                                Get.snackbar(
                                                    '删除通知', res.msg.toString(),
                                                    colorText: ShadTheme.of(context)
                                                        .colorScheme
                                                        .ring);
                                              }
                                            },
                                            child: const Text('确认'),
                                          ),
                                        ],
                                      );
                                    },
                                    icon: Icons.delete_outline,
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    // icon: Icons.delete,
                                    label: '删除',
                                  ),
                              ],
                            ),
                            child: GFListTile(
                              title: Text(
                                user.username,
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        ShadTheme.of(context).colorScheme.primary),
                              ),
                              icon: Text(
                                controller.userinfo?.user == user.username
                                    ? 'me'
                                    : '',
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        ShadTheme.of(context).colorScheme.primary),
                              ),
                              subTitle: Text(
                                user.isStaff ? '管理员' : '观影账号',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: ShadTheme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              hoverColor: ShadTheme.of(context).colorScheme.ring,
                              avatar: Text(
                                user.isStaff ? '👑' : '🎩',
                                style: const TextStyle(
                                  fontSize: 48,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              );
      }),
    );
  }

  void _showEditBottomSheet({UserModel? user, required BuildContext context}) {
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController(text: '');
    final rePasswordController = TextEditingController(text: '');
    RxBool isActive = user != null ? user.isActive.obs : true.obs;
    RxBool showPassword = true.obs;
    RxBool showRePassword = true.obs;
    Get.bottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      CustomCard(
        height: 320,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GFTypography(
                text: user != null ? '编辑用户：${user.username}' : '添加用户',
                icon: const Icon(Icons.add),
                dividerWidth: 200,
                textColor: ShadTheme.of(context).colorScheme.foreground,
                dividerColor: ShadTheme.of(context).colorScheme.foreground,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: usernameController,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          labelStyle:
                              TextStyle(fontSize: 12, color: Colors.black54),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x19000000)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x16000000)),
                          ),
                          suffixIcon: Icon(
                            Icons.man,
                            size: 18,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '用户名不能为空';
                          }
                          return null;
                        },
                      ),
                    ),
                    Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                showPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 18,
                              ),
                              onPressed: () {
                                showPassword.value = !showPassword.value;
                                controller.update();
                              },
                            ),
                          ),
                          obscureText: showPassword.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '密码不能为空';
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                    Obx(() {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: rePasswordController,
                          maxLines: 1,
                          decoration: InputDecoration(
                            labelText: '密码校验',
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
                                showRePassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 18,
                              ),
                              onPressed: () {
                                showRePassword.value = !showRePassword.value;
                                controller.update();
                              },
                            ),
                          ),
                          obscureText: showRePassword.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '密码不能为空';
                            }
                            if (value != passwordController.text) {
                              return '两次输入的密码不一致！';
                            }
                            return null;
                          },
                        ),
                      );
                    }),
                    if (user?.isStaff != true)
                      Obx(() {
                        return SwitchTile(
                          title: '可用',
                          value: isActive.value,
                          onChanged: (value) {
                            isActive.value = value;
                          },
                        );
                      }),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        ShadTheme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '取消',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        ShadTheme.of(context).colorScheme.primary),
                  ),
                  onPressed: () async {
                    if (usernameController.text.isEmpty) {
                      Get.snackbar(
                        '用户名校验',
                        '用户名不能为空！',
                        colorText: ShadTheme.of(context).colorScheme.ring,
                      );
                      return;
                    }
                    if (passwordController.text != rePasswordController.text) {
                      Get.snackbar(
                        '密码校验错误',
                        '两次输入的密码不一致！',
                        colorText: ShadTheme.of(context).colorScheme.ring,
                      );
                      return;
                    }
                    if (user != null) {
                      // 如果 user 不为空，表示是修改操作
                      user?.username = usernameController.text;
                      user?.password = passwordController.text;
                    } else {
                      // 如果 user 为空，表示是添加操作
                      user = UserModel(
                        id: 0,
                        username: usernameController.text,
                        password: passwordController.text,
                        isActive: true,
                        isStaff: false,
                      );
                    }
                    Logger.instance.i(user?.toJson());
                    CommonResponse response =
                        await controller.saveUserModel(user!);
                    if (response.code == 0) {
                      Get.back();
                      Get.snackbar(
                        '保存成功！',
                        response.msg,
                        snackPosition: SnackPosition.TOP,
                        colorText: ShadTheme.of(context).colorScheme.primary,
                        duration: const Duration(seconds: 3),
                      );
                      if (controller.userinfo?.user == user?.username) {
                        HomeController home = Get.find<HomeController>();
                        home.logout();
                      }
                      await controller.getUserListFromServer();
                      controller.update();
                    } else {
                      Get.snackbar(
                        '保存出错啦！',
                        response.msg,
                        snackPosition: SnackPosition.TOP,
                        colorText: ShadTheme.of(context).colorScheme.ring,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  child: const Text(
                    '保存',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
