import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../provider/update_provider.dart';
import 'update_panel.dart';

class UpdatePage extends ConsumerWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = _UpdatePageThemeTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final pageBackground = appSurfaceColor(context, cs.background);

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: GlobalDrawerSwipeArea(
        child: AppBackground(
          child: shadcn.Scaffold(
            backgroundColor: pageBackground,
            headers: [
              shadcn.AppBar(
                height: kAppHeaderHeight - 12,
                padding: appHeaderPadding(context),
                backgroundColor: pageBackground,
                title: Text(
                  '程序更新',
                  style: theme.typography.large.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                leading: [
                  shadcn.IconButton.ghost(
                    icon: Icon(
                      shadcn.LucideIcons.arrowLeft,
                      size: tokens.iconSm,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
                trailing: const [DebugThemeButton.shadcn()],
              ),
            ],
            child: shadcn.RefreshTrigger(
              onRefresh: () => ref.read(updateProvider.notifier).refresh(),
              child: ListView(
                padding: tokens.edgeOnly(top: 8, bottom: 24),
                children: const [UpdatePanel(maxCommitCount: 12)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatePageThemeTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  _UpdatePageThemeTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _UpdatePageThemeTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale =
        ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(
          0.55,
          1.45,
        );
    final textScale = theme.scaling.clamp(0.86, 1.30);
    return _UpdatePageThemeTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  double get iconSm => font(16);

  EdgeInsets edgeOnly({
    num left = 0,
    num top = 0,
    num right = 0,
    num bottom = 0,
  }) => EdgeInsets.only(
    left: size(left),
    top: size(top),
    right: size(right),
    bottom: size(bottom),
  );
}
