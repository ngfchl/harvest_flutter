import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harvest/common/utils.dart';

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
      text:
          SPUtil.getString("CustomUA", defaultValue: 'Harvest APP Client/1.0'),
    );

    Get.defaultDialog(
      title: "自定义 UserAgent",
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
                  controller: tokenController,
                  labelText: '令牌',
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: FullWidthButton(
                        text: '随机Token',
                        backgroundColor: Colors.green,
                        onPressed: () {
                          tokenController.text = generateRandomString(16,
                                  includeSpecialChars: false)
                              .toUpperCase();
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: FullWidthButton(
                        text: '保存',
                        onPressed: () async {
                          _saveToken(context, tokenController.text);
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

  void _saveToken(BuildContext context, String token) async {
    if (token.isNotEmpty) {
      await SPUtil.setString("CustomUA", token);
      Get.back();
      Get.snackbar(
        '保存成功',
        '自定义 APP 请求头设置成功！',
        colorText: Colors.white70,
        backgroundColor: Theme.of(context).colorScheme.primary,
      );
    } else {
      Get.snackbar(
        '保存失败',
        'APP 请求头不能为空！',
        colorText: Colors.white70,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }
}
