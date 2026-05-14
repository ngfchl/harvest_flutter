import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show MaterialPageRoute;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../search/unified_search_page.dart';
import 'shell_bottom_navigation.dart';

class ShellScaffold extends StatelessWidget {
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

  static const _routeItemCount = 5;

  static const _items = [
    _AdaptiveShellNavItem(
      label: '资讯',
      sfSymbol: 'newspaper',
      selectedSfSymbol: 'newspaper.fill',
      cupertinoIcon: CupertinoIcons.news,
      selectedCupertinoIcon: CupertinoIcons.news_solid,
      pageIndex: 0,
    ),
    _AdaptiveShellNavItem(
      label: '站点',
      sfSymbol: 'globe',
      selectedSfSymbol: 'globe',
      cupertinoIcon: CupertinoIcons.globe,
      selectedCupertinoIcon: CupertinoIcons.globe,
      pageIndex: 1,
    ),
    _AdaptiveShellNavItem(
      label: '仪表',
      sfSymbol: 'square.grid.2x2',
      selectedSfSymbol: 'square.grid.2x2.fill',
      cupertinoIcon: CupertinoIcons.square_grid_2x2,
      selectedCupertinoIcon: CupertinoIcons.square_grid_2x2_fill,
      pageIndex: 2,
    ),
    _AdaptiveShellNavItem(
      label: '下载',
      sfSymbol: 'arrow.down.circle',
      selectedSfSymbol: 'arrow.down.circle.fill',
      cupertinoIcon: CupertinoIcons.arrow_down_circle,
      selectedCupertinoIcon: CupertinoIcons.arrow_down_circle_fill,
      pageIndex: 3,
    ),
    _AdaptiveShellNavItem(
      label: '任务',
      sfSymbol: 'checkmark.square',
      selectedSfSymbol: 'checkmark.square.fill',
      cupertinoIcon: CupertinoIcons.checkmark_square,
      selectedCupertinoIcon: CupertinoIcons.checkmark_square_fill,
      pageIndex: 4,
    ),
    _AdaptiveShellNavItem(
      label: '搜索',
      sfSymbol: 'magnifyingglass',
      selectedSfSymbol: 'magnifyingglass',
      cupertinoIcon: CupertinoIcons.search,
      selectedCupertinoIcon: CupertinoIcons.search,
      pageIndex: -1,
      isSearch: true,
    ),
  ];

  List<_AdaptiveShellNavItem> get _visibleItems => showNews
      ? _items
      : _items.where((item) => item.pageIndex != 0).toList(growable: false);

  int get _selectedPageIndex => index.clamp(0, _routeItemCount - 1).toInt();

  int get _selectedIndex {
    final visualIndex = _visibleItems.indexWhere(
      (item) => item.pageIndex == _selectedPageIndex,
    );
    return visualIndex >= 0 ? visualIndex : 0;
  }

  int get _searchIndex => _visibleItems.length - 1;

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

    final target = _visibleItems[tappedIndex].pageIndex;
    if (target >= 0) onChange(target);
  }

  @override
  Widget build(BuildContext context) {
    final useNativeIOSBottomBar =
        PlatformInfo.isIOS && PlatformInfo.isIOS26OrHigher();
    final effectiveDashboardChrome = dashboardChrome && !useNativeIOSBottomBar;

    if (useNativeIOSBottomBar) {
      final colors = shadcn.Theme.of(context).colorScheme;

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
            for (final item in _visibleItems)
              AdaptiveNavigationDestination(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
                isSearch: item.isSearch,
              ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              header,
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return _CustomShellScaffoldBody(
      header: header,
      selectedIndex: _selectedPageIndex,
      onChange: onChange,
      onSearchPress: () => _openSearchPage(context),
      dashboardChrome: effectiveDashboardChrome,
      showNews: showNews,
      useShaderLiquidGlass: false,
      child: child,
    );
  }
}

class _CustomShellScaffoldBody extends StatelessWidget {
  final Widget header;
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onChange;
  final VoidCallback onSearchPress;
  final bool dashboardChrome;
  final bool showNews;
  final bool useShaderLiquidGlass;

  const _CustomShellScaffoldBody({
    required this.header,
    required this.child,
    required this.selectedIndex,
    required this.onChange,
    required this.onSearchPress,
    required this.dashboardChrome,
    required this.showNews,
    required this.useShaderLiquidGlass,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
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
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ShellBottomControls(
            index: selectedIndex,
            onChange: onChange,
            onSearchPress: onSearchPress,
            dashboardChrome: dashboardChrome,
            showNews: showNews,
            useShaderLiquidGlass: useShaderLiquidGlass,
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
  final int pageIndex;
  final bool isSearch;

  const _AdaptiveShellNavItem({
    required this.label,
    required this.sfSymbol,
    required this.selectedSfSymbol,
    required this.cupertinoIcon,
    required this.selectedCupertinoIcon,
    required this.pageIndex,
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
    if (PlatformInfo.isIOS && PlatformInfo.isIOS26OrHigher()) return 0;
    return ShellBottomNavigation.reservedHeight(context);
  }
}
