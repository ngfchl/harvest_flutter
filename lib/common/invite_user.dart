import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../api/api.dart';
import '../api/hooks.dart';
import 'form_widgets.dart';

class InviteUser extends StatelessWidget {
  final Widget child;

  const InviteUser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: child,
      onTap: () {
        _showCustomUADialog(context);
      },
    );
  }

  void _showCustomUADialog(BuildContext context) {
    TextEditingController emailController = TextEditingController();

    Get.defaultDialog(
      title: "试用邀请",
      titleStyle: const TextStyle(fontSize: 18),
      radius: 10,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CustomTextField(
                  autofocus: true,
                  controller: emailController,
                  labelText: '受邀人邮箱',
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: FullWidthButton(
                        text: '取消',
                        backgroundColor: Colors.green,
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FullWidthButton(
                        text: '邀请',
                        onPressed: () async {
                          _inviteUser(context, emailController.text);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _inviteUser(BuildContext context, String email) async {
    if (email.isNotEmpty) {
      var response = await addData(Api.INVITE_USER, null, queryParameters: {'invite_email': email});
      if (response.succeed) {
        Get.back();

        Get.snackbar(
          '邀请成功',
          response.msg,
          colorText: ShadTheme.of(context).colorScheme.foreground,
        );
      } else {
        Get.snackbar(
          '邀请失败',
          response.msg,
          colorText: ShadTheme.of(context).colorScheme.destructive,
        );
      }
    } else {
      Get.snackbar(
        '邀请失败',
        '邮箱不能为空！',
        colorText: ShadTheme.of(context).colorScheme.ring,
      );
    }
  }
}
