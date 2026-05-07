import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
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
  final bool dashboardChrome;

  const ShellScaffold({
    super.key,
    required this.header,
    required this.child,
    required this.index,
    required this.onChange,
    this.scaffoldStyle,
    this.dashboardChrome = false,
  });

  static const _routeItemCount = 5;

  static const _items = [
    _AdaptiveShellNavItem(
      label: '资讯',
      sfSymbol: 'newspaper',
      selectedSfSymbol: 'newspaper.fill',
      cupertinoIcon: CupertinoIcons.news,
      selectedCupertinoIcon: CupertinoIcons.news_solid,
    ),
    _AdaptiveShellNavItem(
      label: '站点',
      sfSymbol: 'globe',
      selectedSfSymbol: 'globe',
      cupertinoIcon: CupertinoIcons.globe,
      selectedCupertinoIcon: CupertinoIcons.globe,
    ),
    _AdaptiveShellNavItem(
      label: '仪表',
      sfSymbol: 'square.grid.2x2',
      selectedSfSymbol: 'square.grid.2x2.fill',
      cupertinoIcon: CupertinoIcons.square_grid_2x2,
      selectedCupertinoIcon: CupertinoIcons.square_grid_2x2_fill,
    ),
    _AdaptiveShellNavItem(
      label: '下载',
      sfSymbol: 'arrow.down.circle',
      selectedSfSymbol: 'arrow.down.circle.fill',
      cupertinoIcon: CupertinoIcons.arrow_down_circle,
      selectedCupertinoIcon: CupertinoIcons.arrow_down_circle_fill,
    ),
    _AdaptiveShellNavItem(
      label: '任务',
      sfSymbol: 'checkmark.square',
      selectedSfSymbol: 'checkmark.square.fill',
      cupertinoIcon: CupertinoIcons.checkmark_square,
      selectedCupertinoIcon: CupertinoIcons.checkmark_square_fill,
    ),
    _AdaptiveShellNavItem(
      label: '搜索',
      sfSymbol: 'magnifyingglass',
      selectedSfSymbol: 'magnifyingglass',
      cupertinoIcon: CupertinoIcons.search,
      selectedCupertinoIcon: CupertinoIcons.search,
      isSearch: true,
    ),
  ];

  int get _selectedIndex => index.clamp(0, _routeItemCount - 1).toInt();

  int get _searchIndex => _items.length - 1;

  void _openSearchPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UnifiedSearchPage()));
  }

  void _handleNavigationTap(BuildContext context, int tappedIndex) {
    if (tappedIndex == _searchIndex) {
      _openSearchPage(context);
      return;
    }

    onChange(tappedIndex.clamp(0, _routeItemCount - 1).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDashboardChrome = dashboardChrome && !PlatformInfo.isIOS;

    if (PlatformInfo.isIOS) {
      final colors = FTheme.of(context).colors;

      return AdaptiveScaffold(
        minimizeBehavior: TabBarMinimizeBehavior.never,
        enableBlur: true,
        bottomNavigationBar: AdaptiveBottomNavigationBar(
          useNativeBottomBar: true,
          selectedIndex: _selectedIndex,
          onTap: (tappedIndex) => _handleNavigationTap(context, tappedIndex),
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.foreground.withValues(alpha: 0.58),
          items: [
            for (final item in _items)
              AdaptiveNavigationDestination(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
                isSearch: item.isSearch,
              ),
          ],
        ),
        body: FScaffold(
          scaffoldStyle: scaffoldStyle,
          header: header,
          childPad: false,
          child: child,
        ),
      );
    }

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
            index: _selectedIndex,
            onChange: onChange,
            onSearchPress: () => _openSearchPage(context),
            dashboardChrome: effectiveDashboardChrome,
          ),
        ),
      ],
    );
  }
}

class _AdaptiveShellNavItem {
  final String label;
  final String sfSymbol;
  final String selectedSfSymbol;
  final IconData cupertinoIcon;
  final IconData selectedCupertinoIcon;
  final bool isSearch;

  const _AdaptiveShellNavItem({
    required this.label,
    required this.sfSymbol,
    required this.selectedSfSymbol,
    required this.cupertinoIcon,
    required this.selectedCupertinoIcon,
    this.isSearch = false,
  });

  Object get icon {
    if (PlatformInfo.isIOS26OrHigher()) return sfSymbol;
    return cupertinoIcon;
  }

  Object get selectedIcon {
    if (PlatformInfo.isIOS26OrHigher()) return selectedSfSymbol;
    return selectedCupertinoIcon;
  }
}

class ShellBottomSpacing {
  const ShellBottomSpacing._();

  static double value(BuildContext context) {
    if (PlatformInfo.isIOS) return 0;
    return ShellBottomNavigation.reservedHeight(context);
  }
}
