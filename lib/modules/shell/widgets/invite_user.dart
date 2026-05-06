import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';

FTile inviteUserTile(BuildContext context) {
  return FTile(
    title: const Text('邀请试用'),
    prefix: Icon(FIcons.userPlus, size: 18),
    onPress: () => _showInviteDialog(context),
  );
}

void _showInviteDialog(BuildContext context) {
  final emailCtrl = TextEditingController();
  bool sending = false;

  showFDialog(
    context: context,
    builder: (ctx, style, animation) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return FDialog(
          style: style
              .copyWith(verticalStyle: (s) => s.copyWith(padding: const EdgeInsets.fromLTRB(20, 16, 20, 4)))
              .call,
          title: const Text('试用邀请'),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTextField(
                controller: emailCtrl,
                hint: '受邀人邮箱',
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      onPress: sending
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              if (email.isEmpty) {
                                Toast.warning('邮箱不能为空');
                                return;
                              }
                              setDialogState(() => sending = true);
                              try {
                                await Http.post(API.ADMIN_USER, queryParameters: {'invite_email': email});
                                if (ctx.mounted) Navigator.pop(ctx);
                                Toast.success('邀请成功');
                              } catch (e) {
                                if (ctx.mounted) {
                                  setDialogState(() => sending = false);
                                }
                                Toast.error('邀请失败: $e');
                              }
                            },
                      child: sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('邀请'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [],
        );
      },
    ),
  );
}
