import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void showDesktopConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      required Future<void> Function() onConfirm,
      bool destructive = false,
    }) {
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: destructive ? cs.destructive : cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(color: cs.mutedForeground, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    destructive
                        ? shadcn.Button.destructive(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onConfirm();
                      },
                      child: const Text('确认'),
                    )
                        : shadcn.Button.primary(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onConfirm();
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class DesktopInputDialog extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final TextEditingController primaryController;
  final String? secondaryLabel;
  final TextEditingController? secondaryController;
  final bool primaryEnabled;
  final Future<void> Function() onSubmit;

  const DesktopInputDialog({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.primaryController,
    required this.onSubmit,
    this.secondaryLabel,
    this.secondaryController,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: cs.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              shadcn.TextField(
                controller: primaryController,
                enabled: primaryEnabled,
                hintText: "",
              ),
              if (secondaryController != null && secondaryLabel != null) ...[
                const SizedBox(height: 12),
                shadcn.TextField(
                  controller: secondaryController!,
                  hintText: "",
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  shadcn.Button.ghost(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  shadcn.Button.primary(
                    onPressed: onSubmit,
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
