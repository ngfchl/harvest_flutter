import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/admin_user/admin_user_page.dart';
import 'package:harvest/modules/news/provider/media_info_settings_provider.dart';
import 'package:harvest/modules/option/widgets/option_page.dart';
import 'package:harvest/modules/option/widgets/update_page.dart';
import 'package:harvest/modules/shell/widgets/log_floating_overlay.dart';
import 'package:harvest/modules/site/site_timeline_page.dart';
import 'package:harvest/modules/user/provider/user_management_provider.dart';
import 'package:harvest/modules/user/user_management_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class GlobalDrawerSwipeArea extends ConsumerStatefulWidget {
  final Widget child;
  final double edgeWidth;
  final double openThreshold;

  const GlobalDrawerSwipeArea({
    super.key,
    required this.child,
    this.edgeWidth = 32,
    this.openThreshold = 24,
  });

  @override
  ConsumerState<GlobalDrawerSwipeArea> createState() =>
      _GlobalDrawerSwipeAreaState();
}

class _GlobalDrawerSwipeAreaState extends ConsumerState<GlobalDrawerSwipeArea> {
  double _dragDistance = 0;
  bool _opening = false;

  void _start(DragStartDetails details) {
    _dragDistance = 0;
  }

  void _update(DragUpdateDetails details) {
    if (_opening) return;
    final delta = details.primaryDelta ?? 0;
    if (delta <= 0) {
      _dragDistance = 0;
      return;
    }
    _dragDistance += delta;
    if (_dragDistance > widget.openThreshold) {
      _dragDistance = 0;
      _opening = true;
      unawaited(
        showGlobalDrawer(context, ref).whenComplete(() {
          if (mounted) _opening = false;
        }),
      );
    }
  }

  void _end(DragEndDetails details) {
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: widget.edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: _start,
            onHorizontalDragUpdate: _update,
            onHorizontalDragEnd: _end,
            onHorizontalDragCancel: () => _dragDistance = 0,
          ),
        ),
      ],
    );
  }
}

Future<void> showGlobalDrawer(BuildContext context, WidgetRef ref) async {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final maxWidth = screenWidth < 320 ? screenWidth : 320.0;
  final minWidth = maxWidth < 248 ? maxWidth : 248.0;
  final width = (screenWidth * 0.76).clamp(minWidth, maxWidth).toDouble();
  final completer = shadcn.openDrawerOverlay<void>(
    context: context,
    position: shadcn.OverlayPosition.left,
    expands: false,
    constraints: BoxConstraints.tightFor(width: width),
    alignment: Alignment.centerLeft,
    barrierDismissible: true,
    draggable: true,
    transformBackdrop: false,
    showDragHandle: false,
    builder: (drawerContext) => Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: SizedBox(
        width: width,
        child: _GlobalDrawerPanel(drawerContext: drawerContext, ref: ref),
      ),
    ),
  );
  await completer.future;
}

class _GlobalDrawerPanel extends StatelessWidget {
  final BuildContext drawerContext;
  final WidgetRef ref;

  const _GlobalDrawerPanel({required this.drawerContext, required this.ref});

  Future<void> _close() => shadcn.closeDrawer<void>(drawerContext);

  void _afterClose(
    void Function(NavigatorState nav, BuildContext context) action,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = navigatorKey.currentState;
      final context = navigatorKey.currentContext;
      if (nav == null || context == null || !context.mounted) return;
      action(nav, context);
    });
  }

  Future<void> _go(String route) async {
    await _close();
    _afterClose((nav, context) {
      nav.popUntil((route) => route.isFirst);
      context.go(route);
    });
  }

  Future<void> _push(Widget page) async {
    await _close();
    _afterClose((nav, _) {
      nav.popUntil((route) => route.isFirst);
      unawaited(nav.push(MaterialPageRoute(builder: (_) => page)));
    });
  }

  Future<void> _pushRoute(String route) async {
    await _close();
    _afterClose((nav, context) {
      nav.popUntil((route) => route.isFirst);
      context.push(route);
    });
  }

  Future<void> _openLogs() async {
    await _close();
    _afterClose((_, context) => LogOverlayManager.toggle(context));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final typo = theme.typography;
    final authInfo = ref.watch(authInfoProvider).valueOrNull;
    final showAdminUser = _authInfoEmail(authInfo) == 'ngfchl@126.com';
    final showNews = ref.watch(mediaInfoSettingsProvider).enabled;
    final currentPath = _currentPath(context);

    return SizedBox.expand(
      child: Material(
        color: cs.background,
        child: SafeArea(
          right: false,
          child: Container(
            margin: tokens.edgeOnly(top: 6, right: 6, bottom: 6),
            decoration: BoxDecoration(
              color: cs.background,
              border: Border.all(
                color: cs.border.withValues(alpha: 0.7),
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(theme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: cs.foreground.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(8, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: tokens.edgeOnly(
                    left: 14,
                    top: 10,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '导航菜单',
                              style: typo.base.copyWith(
                                color: cs.foreground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: tokens.size(1)),
                            Text(
                              '左侧快速访问应用页面与工具',
                              style: typo.xSmall.copyWith(
                                color: cs.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      shadcn.IconButton.ghost(
                        size: shadcn.ButtonSize.small,
                        density: shadcn.ButtonDensity.iconDense,
                        onPressed: _close,
                        icon: const SizedBox(
                          width: 28,
                          height: 28,
                          child: Icon(shadcn.LucideIcons.x, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                ColoredBox(
                  color: cs.border.withValues(alpha: 0.72),
                  child: const SizedBox(height: 1),
                ),
                Expanded(
                  child: ListView(
                    padding: tokens.edgeOnly(
                      left: 8,
                      top: 8,
                      right: 8,
                      bottom: 12,
                    ),
                    children: [
                      _DrawerGroup(
                        title: '主要页面',
                        children: [
                          _DrawerTile(
                            label: '仪表',
                            icon: shadcn.LucideIcons.layoutDashboard,
                            selected: currentPath.startsWith('/dashboard'),
                            onTap: () => _go('/dashboard'),
                          ),
                          if (showNews)
                            _DrawerTile(
                              label: '资讯',
                              icon: shadcn.LucideIcons.newspaper,
                              selected: currentPath.startsWith('/home'),
                              onTap: () => _go('/home'),
                            ),
                          _DrawerTile(
                            label: '站点数据',
                            icon: shadcn.LucideIcons.globe,
                            selected: currentPath.startsWith('/sites'),
                            onTap: () => _go('/sites'),
                          ),
                          _DrawerTile(
                            label: '站点时间轴',
                            icon: shadcn.LucideIcons.gitBranchPlus,
                            onTap: () => _push(const SiteTimelinePage()),
                          ),
                          _DrawerTile(
                            label: '下载器',
                            icon: shadcn.LucideIcons.download,
                            selected: currentPath.startsWith('/downloads'),
                            onTap: () => _go('/downloads'),
                          ),
                          _DrawerTile(
                            label: '任务列表',
                            icon: shadcn.LucideIcons.listTodo,
                            selected: currentPath.startsWith('/tasks'),
                            onTap: () => _go('/tasks'),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.size(8)),
                      _DrawerGroup(
                        title: '管理与工具',
                        children: [
                          _DrawerTile(
                            label: '设置中心',
                            icon: shadcn.LucideIcons.settings,
                            onTap: () => _push(const OptionPage()),
                          ),
                          _DrawerTile(
                            label: '用户中心',
                            icon: shadcn.LucideIcons.user,
                            onTap: () => _push(const UserManagementPage()),
                          ),
                          _DrawerTile(
                            label: '授权管理',
                            icon: shadcn.LucideIcons.shieldCheck,
                            enabled: showAdminUser,
                            onTap: () {
                              if (!showAdminUser) {
                                Toast.warning('当前账号无授权管理权限');
                                return;
                              }
                              unawaited(_push(const AdminUserPage()));
                            },
                          ),
                          _DrawerTile(
                            label: '程序更新',
                            icon: shadcn.LucideIcons.arrowUpFromLine,
                            onTap: () => _push(const UpdatePage()),
                          ),
                          if (!kIsWeb)
                            _DrawerTile(
                              label: 'APP升级',
                              icon: shadcn.LucideIcons.circleArrowUp,
                              onTap: () => _pushRoute('/app-upgrade'),
                            ),
                          _DrawerTile(
                            label: '日志中心',
                            icon: shadcn.LucideIcons.terminal,
                            onTap: _openLogs,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlobalDrawerTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  const _GlobalDrawerTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _GlobalDrawerTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale =
        ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(
          0.58,
          1.18,
        );
    final textScale = theme.scaling.clamp(0.86, 1.22);
    return _GlobalDrawerTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

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

  EdgeInsets symmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: size(horizontal),
        vertical: size(vertical),
      );
}

class _DrawerGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: tokens.edgeOnly(left: 6, right: 6, bottom: 5),
          child: Text(
            title,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final fg = !enabled
        ? cs.mutedForeground
        : selected
        ? cs.primary
        : cs.foreground;

    return Padding(
      padding: tokens.edgeOnly(bottom: 3),
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: shadcn.Button.ghost(
          onPressed: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: tokens.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.background.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(
                color: selected
                    ? cs.primary.withValues(alpha: 0.26)
                    : cs.background.withValues(alpha: 0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: tokens.font(15), color: fg),
                SizedBox(width: tokens.size(8)),
                Expanded(
                  child: Text(
                    label,
                    style: theme.typography.small.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    shadcn.LucideIcons.chevronRight,
                    size: tokens.font(14),
                    color: cs.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _currentPath(BuildContext context) {
  try {
    return GoRouterState.of(context).uri.path;
  } catch (_) {
    return '';
  }
}

String? _authInfoEmail(dynamic data) {
  if (data is Map) {
    final v = data['username'] ?? data['mail'] ?? data['user_email'];
    if (v != null) return v.toString();
  }
  try {
    final v = data?.username ?? data?.mail ?? data?.userEmail;
    if (v != null) return v.toString();
  } catch (_) {}
  return null;
}
