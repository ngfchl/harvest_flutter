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

    TextEditingController proxyTokenController = TextEditingController(
      text: SPUtil.getString("ProxyToken", defaultValue: ''),
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
          spacing: 10,
          children: [
            CustomTextField(
              autofocus: true,
              controller: tokenController,
              labelText: 'User-Agent',
            ),
            CustomTextField(
              controller: proxyTokenController,
              suffix: ShadIconButton(
                icon: Icon(Icons.clear, color: shadColorScheme.foreground),
                onPressed: () => proxyTokenController.clear(),
                iconSize: 20,
              ),
              labelText: 'ProxyToken',
              helperText: '302转发 Token，用于处理部分Nas自携带的转发页面报302时使用，目前适配：\n'
                  '绿联：获取Cookie：ugreen-proxy-token=xxxxx-xxxx',
              helperStyle: TextStyle(color: shadColorScheme.foreground, fontSize: 10),
            ),
            Row(
              children: [
                Expanded(
                  child: ShadButton.ghost(
                    onPressed: () {
                      tokenController.text = generateRandomString(16, includeSpecialChars: false).toUpperCase();
                    },
                    size: ShadButtonSize.sm,
                    child: Text('随机Token'),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      _saveToken(context, tokenController.text);
                      if (proxyTokenController.text.isNotEmpty) {
                        await SPUtil.setString("ProxyToken", proxyTokenController.text.trim());
                      } else {
                        await SPUtil.remove("ProxyToken");
                      }
                    },
                    child: Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveToken(context, String token) async {
    if (token.isNotEmpty) {
      await SPUtil.setString("CustomUA", token);
      Get.back();
      ShadToaster.of(context).show(
        ShadToast(title: const Text('成功啦'), description: Text('自定义 APP 请求头 UserAgent 设置成功！')),
      );
    } else {
      ShadToaster.of(context).show(
        ShadToast.destructive(
          title: const Text('出错啦'),
          description: Text('APP 请求头不能为空！'),
        ),
      );
    }
  }
}
