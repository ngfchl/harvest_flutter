import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../search/unified_search_page.dart';
import 'shell_bottom_navigation.dart';

class ShellScaffold extends StatelessWidget {
  final Widget header;
  final Widget child;
  final int index;
  final ValueChanged<int> onChange;
  final FScaffoldStyle Function(FScaffoldStyle)? scaffoldStyle;

  const ShellScaffold({
    super.key,
    required this.header,
    required this.child,
    required this.index,
    required this.onChange,
    this.scaffoldStyle,
  });

  void _openSearchPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UnifiedSearchPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FScaffold(
            scaffoldStyle: scaffoldStyle,
            header: header,
            childPad: false,
            child: child,
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
          ),
        ),
      ],
    );
  }
}

class ShellBottomSpacing {
  const ShellBottomSpacing._();

  static double value(BuildContext context) {
    return ShellBottomNavigation.reservedHeight(context);
  }
}
