import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'shell_bottom_navigation.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget header;
  final Widget child;
  final int index;
  final ValueChanged<int> onChange;
  final VoidCallback onSearchPress;
  final Object? scaffoldStyle;
  final bool dashboardChrome;
  final bool showBottomControls;
  final bool showNews;
  final bool restricted;

  const ShellScaffold({
    super.key,
    required this.header,
    required this.child,
    required this.index,
    required this.onChange,
    required this.onSearchPress,
    this.scaffoldStyle,
    this.dashboardChrome = false,
    this.showBottomControls = true,
    this.showNews = true,
    this.restricted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Stack(
      children: [
        const Positioned.fill(child: _ShellBackground()),
        Positioned.fill(
          child: shadcn.ComponentTheme(
            data: shadcn.ScaffoldTheme(backgroundColor: cs.background),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: [
                  header,
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
        if (showBottomControls)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ShellBottomControls(
              index: index,
              onChange: onChange,
              onSearchPress: onSearchPress,
              dashboardChrome: dashboardChrome,
              showNews: showNews,
              restricted: restricted,
            ),
          ),
      ],
    );
  }
}

class _ShellBackground extends StatelessWidget {
  const _ShellBackground();

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ColoredBox(color: cs.background);
  }
}

class ShellBottomSpacing {
  const ShellBottomSpacing._();

  static double value(BuildContext context) {
    return ShellBottomNavigation.reservedHeight(context);
  }
}
