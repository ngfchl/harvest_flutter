import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../core/theme/app_background_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../search/unified_search_page.dart';
import 'shell_bottom_navigation.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget header;
  final Widget child;
  final int index;
  final ValueChanged<int> onChange;
  final Object? scaffoldStyle;
  final bool dashboardChrome;
  final bool showNews;

  const ShellScaffold({
    super.key,
    required this.header,
    required this.child,
    required this.index,
    required this.onChange,
    this.scaffoldStyle,
    this.dashboardChrome = false,
    this.showNews = true,
  });

  void _openSearchPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UnifiedSearchPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    final cs = shadcn.Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: _ShellBackground(themeState: themeState)),
        Positioned.fill(
          child: shadcn.ComponentTheme(
            data: shadcn.ScaffoldTheme(
              backgroundColor: cs.background.withValues(
                alpha: themeState.surfaceOpacity,
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: [
                  header,
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ShellBottomControls(
            index: index,
            onChange: onChange,
            onSearchPress: () => _openSearchPage(context),
            dashboardChrome: dashboardChrome,
            showNews: showNews,
          ),
        ),
      ],
    );
  }
}

class _ShellBackground extends StatelessWidget {
  final ThemeState themeState;

  const _ShellBackground({required this.themeState});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    Widget background = ColoredBox(color: cs.background);
    if (themeState.useBackground) {
      final overlayOpacity =
          (1.0 - themeState.surfaceOpacity).clamp(0.0, 1.0).toDouble();
      background = Stack(
        fit: StackFit.expand,
        children: [
          background,
          appThemeBackgroundImage(themeState),
          ColoredBox(color: cs.background.withValues(alpha: overlayOpacity)),
        ],
      );
    }
    return background;
  }
}


class ShellBottomSpacing {
  const ShellBottomSpacing._();

  static double value(BuildContext context) {
    return ShellBottomNavigation.reservedHeight(context);
  }
}
