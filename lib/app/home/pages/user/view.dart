import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:harvest/app/home/pages/user/UserModel.dart';
import 'package:harvest/common/card_view.dart';
import 'package:harvest/utils/storage.dart';
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
    double opacity = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: (controller.userinfo?.isStaff == true || controller.userinfo?.isStaff == true)
          ? IconButton(
              icon: Icon(
                Icons.add,
                size: 28,
                color: shadColorScheme.primary,
              ),
              onPressed: () async {
                _showEditBottomSheet(context: context);
              },
            )
          : null,
      body: GetBuilder<UserController>(builder: (controller) {
        return EasyRefresh(
          onRefresh: () => controller.getUserListFromServer(),
          child: Column(
            children: [
              Expanded(
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
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  onPressed: (context) async {
                                    _showEditBottomSheet(user: user, context: context);
                                  },
                                  backgroundColor: const Color(0xFF0392CF),
                                  foregroundColor: Colors.white,
                                  // icon: Icons.edit,
                                  label: '编辑',
                                ),
                                if (!user.isStaff && user.username != controller.userinfo?.user)
                                  SlidableAction(
                                    flex: 1,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    onPressed: (context) async {
                                      Get.defaultDialog(
                                        title: '确认',
                                        radius: 5,
                                        titleStyle: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
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
                                              CommonResponse res = await controller.removeUserModel(user);
                                              if (res.code == 0) {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.foreground);
                                              } else {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.destructive);
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
                            child: ListTile(
                              title: Text(
                                user.username,
                                style: TextStyle(fontSize: 20, color: shadColorScheme.foreground),
                              ),
                              trailing: Text(
                                controller.userinfo?.user == user.username ? 'me' : '',
                                style: TextStyle(fontSize: 12, color: shadColorScheme.foreground),
                              ),
                              subtitle: Text(
                                user.isStaff ? '管理员' : '观影账号',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: shadColorScheme.foreground.withValues(alpha: opacity * 255),
                                ),
                              ),
                              leading: Text(
                                user.isStaff ? '👑' : '🎩',
                                style: const TextStyle(
                                  fontSize: 36,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditBottomSheet({UserModel? user, required BuildContext context}) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController(text: '');
    final rePasswordController = TextEditingController(text: '');
    RxBool isActive = user != null ? user.isActive.obs : true.obs;
    RxBool showPassword = true.obs;
    RxBool showRePassword = true.obs;
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                user != null ? '编辑用户：${user.username}' : '添加用户',
                style: ShadTheme.of(context).textTheme.h4.copyWith(color: shadColorScheme.foreground),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: usernameController,
                      labelText: '用户名',
                      suffixIcon: Icon(Icons.man, color: shadColorScheme.foreground),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '用户名不能为空';
                        }
                        return null;
                      },
                    ),
                    Obx(() {
                      return CustomTextField(
                        controller: passwordController,
                        labelText: '密码',
                        obscureText: showRePassword.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword.value ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: shadColorScheme.foreground,
                          ),
                          onPressed: () {
                            showPassword.value = !showPassword.value;
                            controller.update();
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '密码不能为空';
                          }
                          return null;
                        },
                      );
                    }),
                    Obx(() {
                      return CustomTextField(
                        controller: rePasswordController,
                        labelText: '密码校验',
                        suffixIcon: IconButton(
                          icon: Icon(
                            showRePassword.value ? Icons.visibility : Icons.visibility_off,
                            size: 18,
                            color: shadColorScheme.foreground,
                          ),
                          onPressed: () {
                            showRePassword.value = !showRePassword.value;
                            controller.update();
                          },
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
                      );
                    }),
                    if (user?.isStaff != true)
                      Obx(() {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '可用',
                                style: TextStyle(fontSize: 13, color: shadColorScheme.foreground),
                              ),
                              ShadSwitch(
                                value: isActive.value,
                                onChanged: (value) {
                                  isActive.value = value;
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceAround,
              children: [
                ShadButton.destructive(
                  size: ShadButtonSize.sm,
                  onPressed: () {
                    Get.back();
                  },
                  leading: Icon(
                    Icons.cancel,
                    size: 18,
                    color: shadColorScheme.destructiveForeground,
                  ),
                  child: Text('取消', style: TextStyle(color: shadColorScheme.destructiveForeground)),
                ),
                ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: () async {
                    if (usernameController.text.isEmpty) {
                      Get.snackbar(
                        '用户名校验',
                        '用户名不能为空！',
                        colorText: shadColorScheme.destructive,
                      );
                      return;
                    }
                    if (passwordController.text != rePasswordController.text) {
                      Get.snackbar(
                        '密码校验错误',
                        '两次输入的密码不一致！',
                        colorText: shadColorScheme.destructive,
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
                    CommonResponse response = await controller.saveUserModel(user!);
                    if (response.code == 0) {
                      Get.back();
                      Get.snackbar(
                        '保存成功！',
                        response.msg,
                        snackPosition: SnackPosition.TOP,
                        colorText: shadColorScheme.foreground,
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
                        colorText: shadColorScheme.destructive,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                  leading: Icon(
                    Icons.save,
                    size: 18,
                    color: shadColorScheme.primaryForeground,
                  ),
                  child: Text(
                    '保存',
                    style: TextStyle(color: shadColorScheme.primaryForeground),
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
