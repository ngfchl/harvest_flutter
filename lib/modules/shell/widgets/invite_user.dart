import 'package:flutter/material.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget inviteUserTile(BuildContext context) {
  return _InviteTile(onTap: () => _showInviteDialog(context));
}

void showInviteUserDialog(BuildContext context) {
  _showInviteDialog(context);
}

class _InviteTile extends StatelessWidget {
  final VoidCallback onTap;

  const _InviteTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [Icon(shadcn.LucideIcons.userPlus, size: 18), SizedBox(width: 10), Text('邀请试用')]),
      ),
    );
  }
}

void _showInviteDialog(BuildContext context) {
  final emailCtrl = TextEditingController();
  bool sending = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          title: const Text('试用邀请'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              shadcn.TextField(
                controller: emailCtrl,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                hintText: "",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: shadcn.Button.outline(
                      onPressed: () => Navigator.pop(ctx),
                      child: Center(child: const Text('取消')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: shadcn.Button.primary(
                      onPressed: sending
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
                                if (ctx.mounted) setDialogState(() => sending = false);
                                Toast.error('邀请失败: $e');
                              }
                            },
                      child: sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: shadcn.CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Center(child: const Text('邀请')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
