import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
    final cs = shadcn.Theme.of(context).colorScheme;
    return Stack(
      children: [
        const Positioned.fill(child: _ShellBackground()),
        Positioned.fill(
          child: shadcn.ComponentTheme(
            data: shadcn.ScaffoldTheme(backgroundColor: cs.background),
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
