import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/storage.dart';
import 'form_widgets.dart';

class CustomUAWidget extends StatelessWidget {
  final Widget child;

  const CustomUAWidget({super.key, required this.child});

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
    TextEditingController tokenController = TextEditingController(
      text: SPUtil.getString("CustomUA", defaultValue: 'Harvest APP Client/1.0'),
    );

    var shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.defaultDialog(
      title: "自定义 UserAgent",
      titleStyle: TextStyle(fontSize: 16, color: shadColorScheme.foreground),
      radius: 10,
      backgroundColor: shadColorScheme.background,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomTextField(
              autofocus: true,
              controller: tokenController,
              labelText: 'User-Agent',
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ShadButton.destructive(
                    onPressed: () {
                      tokenController.text = generateRandomString(16, includeSpecialChars: false).toUpperCase();
                    },
                    size: ShadButtonSize.sm,
                    child: Text(
                      '随机Token',
                      style: TextStyle(color: shadColorScheme.destructiveForeground),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ShadButton(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      _saveToken(context, tokenController.text);
                    },
                    child: Text(
                      '保存',
                      style: TextStyle(color: shadColorScheme.primaryForeground),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveToken(BuildContext context, String token) async {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    if (token.isNotEmpty) {
      await SPUtil.setString("CustomUA", token);
      Get.back();
      Get.snackbar(
        '保存成功',
        '自定义 APP 请求头设置成功！',
        colorText: Colors.white70,
        backgroundColor: shadColorScheme.primary,
      );
    } else {
      Get.snackbar(
        '保存失败',
        'APP 请求头不能为空！',
        backgroundColor: shadColorScheme.destructive,
      );
    }
  }
}
