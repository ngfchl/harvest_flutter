import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../modules/shell/widgets/theme_dialog.dart';

class DebugThemeButton extends StatelessWidget {
  final bool shadcnStyle;
  final EdgeInsetsGeometry padding;

  const DebugThemeButton({super.key, this.padding = EdgeInsets.zero}) : shadcnStyle = true;

  const DebugThemeButton.material({super.key, this.padding = EdgeInsets.zero}) : shadcnStyle = false;

  const DebugThemeButton.shadcn({super.key, this.padding = EdgeInsets.zero}) : shadcnStyle = true;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    if (shadcnStyle) {
      return Padding(
        padding: padding,
        child: Tooltip(
          tooltip: (_) => const Text('主题设置'),
          child: IconButton.ghost(icon: const Icon(LucideIcons.palette), onPressed: () => showThemeDialog(context)),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Tooltip(
        tooltip: (_) => const Text('主题设置'),
        child: IconButton.ghost(icon: const Icon(LucideIcons.palette), onPressed: () => showThemeDialog(context)),
      ),
    );
  }
}
