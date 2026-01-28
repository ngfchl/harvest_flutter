import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:harvest/app/home/pages/app_publish/model.dart';
import 'package:harvest/common/card_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/form_widgets.dart';
import '../../../../utils/calc_weeks.dart';
import '../../../../utils/logger_helper.dart';
import '../../../../utils/platform.dart';
import 'controller.dart';

class AppPublishPage extends StatelessWidget {
  AppPublishPage({super.key});

  final AppPublishController controller = Get.put(AppPublishController());

  @override
  Widget build(BuildContext context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<AppPublishController>(builder: (controller) {
      return CustomCard(
          child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(builder: (context, constraints) {
          final contentHeight = constraints.maxHeight - 50; // 减去 tabBar 高度
          return ShadTabs<String>(
            controller: controller.tabsController,
            onChanged: (String value) => controller.tabsController.select(value),
            tabBarConstraints: const BoxConstraints(maxHeight: 50),
            contentConstraints: BoxConstraints(maxHeight: contentHeight),
            decoration: ShadDecoration(
              color: Colors.transparent,
            ),
            tabs: [
              ShadTab(
                value: 'userManageMent',
                content: GetBuilder<AppPublishController>(builder: (controller) {
                  return Scaffold(
                    backgroundColor: Colors.transparent,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      toolbarHeight: 40,
                      actions: [
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.record_voice_over_outlined,
                            color: shadColorScheme.foreground,
                            size: 20,
                          ),
                          onPressed: () async {
                            TextEditingController countController = TextEditingController(text: '3');
                            Get.defaultDialog(
                              title: '重置邀请',
                              radius: 5,
                              titleStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: shadColorScheme.foreground,
                              ),
                              backgroundColor: shadColorScheme.background,
                              content: Column(
                                children: [
                                  CustomTextField(
                                    controller: countController,
                                    labelText: '邀请数量',
                                    prefixIcon: Icon(
                                      Icons.money_outlined,
                                      color: shadColorScheme.foreground,
                                      size: 20,
                                    ),
                                    suffix: ShadIconButton.ghost(
                                      icon: Icon(
                                        Icons.autorenew_outlined,
                                        color: shadColorScheme.foreground,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        countController.text = ' 5';
                                      },
                                    ),
                                  ),
                                  ShadRadioGroup<int>(
                                    axis: Axis.horizontal,
                                    // initialValue: 168,
                                    spacing: 8,
                                    runSpacing: 8,
                                    onChanged: (int? value) {
                                      countController.text = value.toString();
                                    },
                                    items: [
                                      ShadRadio(
                                        label: Text('1'),
                                        value: 1,
                                      ),
                                      ShadRadio(
                                        label: Text('2'),
                                        value: 2,
                                      ),
                                      ShadRadio(
                                        label: Text('3'),
                                        value: 3,
                                      ),
                                      ShadRadio(
                                        label: Text('4'),
                                        value: 4,
                                      ),
                                      ShadRadio(
                                        label: Text('5'),
                                        value: 5,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                ShadButton.outline(
                                  size: ShadButtonSize.sm,
                                  child: Text('取消'),
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                                GetBuilder<AppPublishController>(builder: (controller) {
                                  return ShadButton.destructive(
                                    size: ShadButtonSize.sm,
                                    leading: !controller.loading
                                        ? null
                                        : SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: Center(
                                                child: CircularProgressIndicator(
                                              color: shadColorScheme.destructiveForeground,
                                            )),
                                          ),
                                    onPressed: () async {
                                      if (controller.loading == true) {
                                        return;
                                      }
                                      try {
                                        controller.loading = true;
                                        controller.update();
                                        var result =
                                            await controller.resetAdminUserInvite(int.parse(countController.text));
                                        if (result.succeed) {
                                          controller.getAdminUserList();
                                          Get.back();
                                        } else {
                                          ShadToaster.of(context).show(
                                            ShadToast.destructive(
                                              title: const Text('出错啦'),
                                              description: Text(result.msg),
                                            ),
                                          );
                                        }
                                      } catch (e, trace) {
                                        Logger.instance.e(e);
                                        Logger.instance.e(trace);
                                        ShadToaster.of(context).show(
                                          ShadToast.destructive(
                                            title: const Text('出错啦'),
                                            description: Text(e.toString()),
                                          ),
                                        );
                                      } finally {
                                        controller.loading = false;
                                        controller.update();
                                      }
                                    },
                                    child: Text('重置'),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.refresh_outlined,
                            color: shadColorScheme.foreground,
                            size: 20,
                          ),
                          onPressed: () async {
                            controller.loading = true;
                            controller.update();
                            await controller.getAdminUserList();
                            controller.loading = false;
                            controller.update();
                          },
                        ),
                        ShadIconButton.ghost(
                          icon: Icon(
                            Icons.add_reaction_outlined,
                            color: shadColorScheme.foreground,
                            size: 20,
                          ),
                          onPressed: () async {
                            TextEditingController emailController = TextEditingController();
                            Get.bottomSheet(
                              SafeArea(
                                child: SizedBox(
                                  height: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      spacing: 8,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '添加用户',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: shadColorScheme.foreground,
                                          ),
                                        ),
                                        CustomTextField(controller: emailController, labelText: '邮箱'),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ShadButton.outline(
                                              size: ShadButtonSize.sm,
                                              child: Text('取消'),
                                              onPressed: () {
                                                Get.back();
                                              },
                                            ),
                                            ShadButton.destructive(
                                              size: ShadButtonSize.sm,
                                              child: Text('保存'),
                                              onPressed: () async {
                                                var result = await controller.createAdminUser(emailController.text);
                                                if (result.succeed) {
                                                  Get.back();
                                                  controller.getAdminUserList();
                                                } else {
                                                  ShadToaster.of(context).show(
                                                    ShadToast.destructive(
                                                      title: const Text('出错啦'),
                                                      description: Text(result.msg),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              backgroundColor: shadColorScheme.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    body: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              EasyRefresh(
                                onRefresh: () async {
                                  controller.loading = true;
                                  controller.update();
                                  await controller.getAdminUserList();
                                  controller.loading = false;
                                  controller.update();
                                },
                                child: ListView(children: [
                                  ...controller.showUsers.map(
                                    (user) => CustomCard(
                                      key: Key("${user.id}-${user.email}"),
                                      child: ShadContextMenuRegion(
                                        decoration: ShadDecoration(
                                          labelStyle: TextStyle(),
                                          descriptionStyle: TextStyle(),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 100),
                                        items: [
                                          ShadContextMenuItem(
                                            leading: Icon(
                                              size: 14,
                                              Icons.lock_outline,
                                              color: shadColorScheme.foreground,
                                            ),
                                            child: Text(style: TextStyle(fontSize: 12), '重置授权'),
                                            onPressed: () => resetAuth(context, user),
                                          ),
                                          ShadContextMenuItem(
                                            leading: Icon(
                                              size: 14,
                                              Icons.email_outlined,
                                              color: shadColorScheme.foreground,
                                            ),
                                            child: Text(style: TextStyle(fontSize: 12), '发送邮件'),
                                            onPressed: () => sendMail(context, user),
                                          ),
                                          ShadContextMenuItem(
                                            leading: Icon(
                                              size: 14,
                                              Icons.edit_outlined,
                                              color: shadColorScheme.foreground,
                                            ),
                                            child: Text(style: TextStyle(fontSize: 12), '编辑信息'),
                                            onPressed: () => editUser(context, user),
                                          ),
                                          ShadContextMenuItem(
                                            leading: Icon(
                                              size: 14,
                                              Icons.delete_outline,
                                              color: shadColorScheme.foreground,
                                            ),
                                            child: Text(style: TextStyle(fontSize: 12), '删除用户'),
                                            onPressed: () => removeAdminUser(user, context),
                                          ),
                                        ],
                                        child: Slidable(
                                          key: ValueKey('${user.id}_${user.email}'),
                                          startActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            extentRatio: PlatformTool.isSmallScreenPortrait() ? 1 / 2 : 1 / 5,
                                            children: [
                                              SlidableAction(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                                onPressed: (context) => resetAuth(context, user),
                                                flex: 1,
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                icon: Icons.lock_outline,
                                                label: '授权',
                                              ),
                                              SlidableAction(
                                                borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                onPressed: (context) => sendMail(context, user),
                                                flex: 1,
                                                backgroundColor: Colors.teal,
                                                foregroundColor: Colors.white,
                                                icon: Icons.email_outlined,
                                                label: '邮件',
                                              ),
                                            ],
                                          ),
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            extentRatio: PlatformTool.isSmallScreenPortrait() ? 1 / 3 : 1 / 4,
                                            children: [
                                              SlidableAction(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                                onPressed: (context) => editUser(context, user),
                                                flex: 1,
                                                backgroundColor: Colors.orange,
                                                foregroundColor: Colors.white,
                                                icon: Icons.edit_outlined,
                                                label: '编辑',
                                              ),
                                              SlidableAction(
                                                borderRadius: const BorderRadius.only(
                                                    topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                                onPressed: (context) => removeAdminUser(user, context),
                                                flex: 1,
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete_outline,
                                                label: '删除',
                                              ),
                                            ],
                                          ),
                                          child: ListTile(
                                            dense: true,
                                            title: Tooltip(
                                              message:
                                                  "创建时间：${user.createdAt.toString()}${user.updatedAt?.startsWith('000') == true ? '' : '，更新时间：${user.updatedAt.toString()}'} ${user.invitedById != null ? "【邀请人：${user.invitedById}】" : ''}",
                                              child: Text(
                                                "${user.email}${user.updatedAt?.startsWith('000') == true ? '' : ' 更新于：${calculateTimeElapsed(user.updatedAt.toString())}'}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: shadColorScheme.foreground,
                                                ),
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${user.username}【邀请数：${user.invite}】',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: shadColorScheme.foreground,
                                              ),
                                            ),
                                            trailing: Text(
                                              user.timeExpire.toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: user.timeExpire?.contains('授权码已过期') == true
                                                    ? shadColorScheme.destructive
                                                    : shadColorScheme.foreground,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]),
                              ),
                              if (controller.loading)
                                Center(
                                  child: SizedBox(
                                      height: 32,
                                      width: 32,
                                      child: CircularProgressIndicator(color: shadColorScheme.foreground)),
                                ),
                            ],
                          ),
                        ),
                        ShadInput(
                          placeholder: const Text('搜索'),
                          leading: Text(
                            '${controller.showUsers.length}',
                            style: TextStyle(fontSize: 11, color: shadColorScheme.foreground),
                          ),
                          trailing: ShadIconButton.ghost(
                            width: 16,
                            height: 16,
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.backspace_outlined, size: 16, color: shadColorScheme.foreground),
                            onPressed: () {
                              if (controller.searchKey.isEmpty) {
                                return;
                              }
                              controller.searchKey = controller.searchKey.substring(0, controller.searchKey.length - 1);
                              controller.filterUser();
                            },
                          ),
                          onChanged: (value) {
                            controller.searchKey = value;
                            controller.filterUser();
                          },
                        ),
                      ],
                    ),
                  );
                }),
                child: Text('用户管理', style: TextStyle(color: shadColorScheme.foreground)),
              ),
            ],
          );
        }),
      ));
    });
  }

  void editUser(BuildContext context, AdminUser user) async {
    if (controller.loading == true) {
      return;
    }
    controller.loading = true;
    controller.update();
    var res = await controller.getAdminUser(user.id!);
    Logger.instance.i(res?.toJson() ?? 'null');
    controller.loading = false;
    controller.update();
    await showAdminUserEdit(user, context);
  }

  void sendMail(BuildContext context, AdminUser user) {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
      title: '发送邮件',
      radius: 5,
      backgroundColor: shadColorScheme.background,
      titleStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 16),
      content: Text(
        '确定吗？',
        style: TextStyle(color: shadColorScheme.foreground, fontSize: 14),
      ),
      actions: [
        ShadButton.ghost(
          size: ShadButtonSize.sm,
          child: Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        GetBuilder<AppPublishController>(builder: (controller) {
          return ShadButton.destructive(
            size: ShadButtonSize.sm,
            leading: !controller.loading
                ? null
                : SizedBox(
                    width: 16,
                    height: 16,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: shadColorScheme.destructiveForeground,
                    )),
                  ),
            onPressed: () async {
              if (controller.loading == true) {
                return;
              }
              controller.loading = true;
              controller.update();
              var result = await controller.sendAdminUserToken(user.id!);
              if (result.succeed) {
                Get.back();
              } else {
                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    title: const Text('出错啦'),
                    description: Text(result.msg),
                  ),
                );
              }
              controller.loading = false;
              controller.update();
            },
            child: Text('发送'),
          );
        }),
      ],
    );
  }

  void resetAuth(BuildContext context, AdminUser user) {
    TextEditingController payController = TextEditingController(text: '168');
    TextEditingController expireController = TextEditingController(text: '36600');
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    RxBool tryUser = false.obs;
    Get.defaultDialog(
      title: '重置授权',
      radius: 5,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: shadColorScheme.foreground,
      ),
      backgroundColor: shadColorScheme.background,
      content: Column(
        children: [
          CustomTextField(
            controller: payController,
            labelText: '付款金额',
            prefixIcon: Icon(
              Icons.money_outlined,
              color: shadColorScheme.foreground,
              size: 20,
            ),
            suffix: ShadIconButton.ghost(
              icon: Icon(
                Icons.autorenew_outlined,
                color: shadColorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                if (payController.text != '168') {
                  payController.text = '168';
                } else {
                  payController.text = '0';
                }
              },
            ),
          ),
          CustomTextField(
            controller: expireController,
            labelText: '授权时长',
            prefixIcon: Icon(
              Icons.more_time_outlined,
              color: shadColorScheme.foreground,
              size: 20,
            ),
            suffix: ShadIconButton.ghost(
              icon: Icon(
                Icons.autorenew_outlined,
                color: shadColorScheme.foreground,
                size: 20,
              ),
              onPressed: () {
                if (expireController.text == '36600') {
                  expireController.text = '366';
                } else {
                  expireController.text = '36600';
                }
              },
            ),
          ),
          Obx(() {
            return SwitchTile(
              title: '试用用户',
              leading: Icon(
                Icons.man_2_outlined,
                size: 20,
                color: shadColorScheme.foreground,
              ),
              value: tryUser.value,
              onChanged: (bool value) {
                tryUser.value = value;
              },
            );
          }),
          ShadRadioGroup<int>(
            axis: Axis.horizontal,
            // initialValue: 168,
            spacing: 8,
            runSpacing: 8,
            onChanged: (int? value) {
              payController.text = value.toString();
            },
            items: [
              ShadRadio(
                label: Text('8折'),
                value: (168 * 0.8).toInt(),
              ),
              ShadRadio(
                label: Text('85折'),
                value: (168 * 0.85).toInt(),
              ),
              ShadRadio(
                label: Text('9折'),
                value: (168 * 0.9).toInt(),
              ),
              ShadRadio(
                label: Text('95折'),
                value: (168 * 0.95).toInt(),
              ),
              // ShadRadio(
              //   label: Text('全价'),
              //   value: 168,
              // ),
            ],
          ),
        ],
      ),
      actions: [
        ShadButton.outline(
          size: ShadButtonSize.sm,
          child: Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        GetBuilder<AppPublishController>(builder: (controller) {
          return ShadButton.destructive(
            size: ShadButtonSize.sm,
            leading: !controller.loading
                ? null
                : SizedBox(
                    width: 16,
                    height: 16,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: shadColorScheme.destructiveForeground,
                    )),
                  ),
            onPressed: () async {
              if (controller.loading == true) {
                return;
              }
              try {
                controller.loading = true;
                controller.update();
                var result = await controller.resetAdminUserToken(user.id!, {
                  "pay": int.parse(payController.text),
                  "expire": int.parse(expireController.text),
                  "try_user": tryUser.value
                });
                if (result.succeed) {
                  controller.getAdminUserList();
                  Get.back();
                } else {
                  ShadToaster.of(context).show(
                    ShadToast.destructive(
                      title: const Text('出错啦'),
                      description: Text(result.msg),
                    ),
                  );
                }
              } catch (e, trace) {
                Logger.instance.e(e);
                Logger.instance.e(trace);
                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    title: const Text('出错啦'),
                    description: Text(e.toString()),
                  ),
                );
              } finally {
                controller.loading = false;
                controller.update();
              }
            },
            child: Text('授权'),
          );
        }),
      ],
    );
  }

  Future<void> removeAdminUser(AdminUser user, BuildContext context) async {
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
      title: '删除用户',
      backgroundColor: shadColorScheme.background,
      titleStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 16),
      content: Text(
        '确定要删除此用户吗？',
        style: TextStyle(color: shadColorScheme.foreground, fontSize: 14),
      ),
      radius: 5,
      actions: [
        ShadButton.ghost(
          size: ShadButtonSize.sm,
          child: Text('取消'),
          onPressed: () {
            Get.back();
          },
        ),
        GetBuilder<AppPublishController>(builder: (controller) {
          return ShadButton.destructive(
            size: ShadButtonSize.sm,
            leading: !controller.loading
                ? null
                : SizedBox(
                    width: 16,
                    height: 16,
                    child: Center(
                        child: CircularProgressIndicator(
                      color: shadColorScheme.destructiveForeground,
                    )),
                  ),
            onPressed: () async {
              if (controller.loading == true) {
                return;
              }
              controller.loading = true;
              controller.update();
              var result = await controller.deleteAdminUser(user.id!);
              if (result.succeed) {
                controller.showUsers.remove(user);
                controller.users.remove(user);
                Get.back();
                await controller.getAdminUserList();
              } else {
                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    title: const Text('出错啦'),
                    description: Text(result.msg),
                  ),
                );
              }
              controller.loading = false;
              controller.update();
            },
            child: Text('删除'),
          );
        }),
      ],
    );
  }

  Future<void> showAdminUserEdit(AdminUser? user, BuildContext context) async {
    TextEditingController usernameController = TextEditingController(text: user?.username ?? '');
    TextEditingController payController = TextEditingController(text: user?.pay.toString() ?? '168');
    TextEditingController inviteController = TextEditingController(text: user?.invite.toString() ?? '3');
    TextEditingController markedController = TextEditingController(text: user?.marked ?? '');
    final shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '正在${user == null ? '添加' : '修改'}用户信息',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  CustomTextField(
                    controller: usernameController,
                    labelText: '用户名称',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  CustomTextField(
                    controller: payController,
                    labelText: '付款金额',
                    prefixIcon: Icon(Icons.money_outlined),
                  ),
                  CustomTextField(
                    controller: inviteController,
                    labelText: '邀请数目',
                    prefixIcon: Icon(Icons.qr_code_outlined),
                  ),
                  CustomTextField(
                    controller: markedController,
                    labelText: '备注信息',
                    maxLines: 6,
                    prefixIcon: Icon(Icons.mark_email_read_outlined),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ShadButton.outline(
                size: ShadButtonSize.sm,
                child: Text('取消'),
                onPressed: () {
                  Get.back();
                },
              ),
              ShadButton.destructive(
                size: ShadButtonSize.sm,
                child: Text('保存'),
                onPressed: () async {
                  if (user == null) {
                    return;
                  }
                  AdminUser newUser = user.copyWith(
                    username: usernameController.text,
                    pay: int.tryParse(payController.text) ?? user.pay,
                    invite: int.tryParse(inviteController.text) ?? user.invite,
                    marked: markedController.text,
                  );
                  controller.loading = true;
                  controller.update();
                  var result = await controller.editAdminUser(newUser);
                  controller.loading = false;
                  controller.update();
                  if (result.succeed) {
                    Get.back();
                    await controller.getAdminUserList();
                  } else {
                    ShadToaster.of(context).show(
                      ShadToast.destructive(
                        title: const Text('出错啦'),
                        description: Text(result.msg),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ]),
      ),
      backgroundColor: shadColorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
    );
  }
}
