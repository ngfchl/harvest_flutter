import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:harvest/widgets/app_dialog.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

Future<bool> showRecheckConfirmDialog(BuildContext context, {required int count}) async {
  final result = await appShowDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '重新校验',
                style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('将对当前列表 $count 个种子执行重新校验。', style: TextStyle(color: cs.mutedForeground, fontSize: 13)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button.ghost(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                  const SizedBox(width: 8),
                  Button.primary(onPressed: () => Navigator.pop(ctx, true), child: const Text('确认')),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
