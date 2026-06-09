import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/admin_user/admin_user_access.dart';
import 'package:harvest/modules/admin_user/admin_user_page.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/login/login_history_provider.dart';
import 'package:harvest/modules/news/provider/media_info_settings_provider.dart';
import 'package:harvest/modules/option/widgets/option_page.dart';
import 'package:harvest/modules/option/widgets/update_page.dart';
import 'package:harvest/modules/shell/widgets/log_floating_overlay.dart';
import 'package:harvest/modules/site/site_timeline_page.dart';
import 'package:harvest/modules/user/provider/user_management_provider.dart';
import 'package:harvest/modules/user/user_management_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

final desktopNavigationSidebarVisibleProvider = StateProvider<bool>(
  (_) => true,
);

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
  final maxWidth = screenWidth < 420 ? screenWidth * 0.78 : 292.0;
  final minWidth = maxWidth < 236 ? maxWidth : 236.0;
  final width = (screenWidth * 0.68).clamp(minWidth, maxWidth).toDouble();
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
        child: GlobalNavigationSidebar(drawerContext: drawerContext, ref: ref),
      ),
    ),
  );
  await completer.future;
}

class GlobalNavigationSidebar extends StatelessWidget {
  final BuildContext? drawerContext;
  final WidgetRef ref;
  final bool persistent;

  const GlobalNavigationSidebar({
    super.key,
    required this.ref,
    this.drawerContext,
    this.persistent = false,
  });

  Future<void> _close() {
    if (persistent || drawerContext == null) return Future<void>.value();
    return shadcn.closeDrawer<void>(drawerContext!);
  }

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

  Future<void> _openLogCenter() async {
    await _pushRoute('/log-center');
  }

  Future<void> _restartServer() async {
    await _close();
    _afterClose((_, context) {
      unawaited(_confirmRestartServer(context));
    });
  }

  Future<void> _confirmRestartServer(BuildContext context) async {
    final ok = await shadcn.showDialog<bool>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('重启服务器'),
        content: const Text('确定要重启服务器吗？重启期间服务会短暂不可用。'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('重启'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    Toast.info('正在重启服务器');
    try {
      await Http.post<dynamic>(API.SERVER_RESTART);
      Toast.success('服务器重启请求已发送');
    } catch (e, st) {
      AppLogger.error('服务器重启失败', e, st);
      Toast.error('服务器重启失败');
    }
  }

  Future<void> _switchAccount() async {
    await _close();
    ref
        .read(authNotifierProvider.notifier)
        .logout(redirectTo: '/login-history');
  }

  Future<void> _logout() async {
    await _close();
    ref.read(authNotifierProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final user = ref.watch(authNotifierProvider).user;
    final authInfo = ref.watch(authInfoProvider).valueOrNull;
    final showAdminUser = canOpenAdminUsers(authInfo);
    final showNews = ref.watch(mediaInfoSettingsProvider).enabled;
    final showAccountSwitcher = ref.watch(loginHistoryProvider).length >= 2;
    final currentPath = _currentPath(context);
    final selectedKey = _selectedNavigationKey(currentPath);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return shadcn.NavigationSidebar(
                  backgroundColor: cs.background,
                  surfaceBlur: 0,
                  surfaceOpacity: 1,
                  spacing: tokens.size(4),
                  labelType: shadcn.NavigationLabelType.expanded,
                  labelPosition: shadcn.NavigationLabelPosition.end,
                  labelSize: shadcn.NavigationLabelSize.large,
                  padding: tokens.edgeOnly(
                    left: 12,
                    top: 8,
                    right: 12,
                    bottom: 10,
                  ),
                  constraints: BoxConstraints.tightFor(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                  ),
                  selectedKey: selectedKey,
                  header: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: tokens.edgeOnly(
                          left: 14,
                          top: persistent ? 46 : 22,
                          right: 8,
                          bottom: 4,
                        ),
                        child: _GlobalDrawerAccountHeader(
                          user: user,
                          server: AppConfig.baseUrl,
                          authInfo: authInfo,
                          trailing: persistent
                              ? null
                              : shadcn.IconButton.ghost(
                                  size: shadcn.ButtonSize.small,
                                  density: shadcn.ButtonDensity.iconDense,
                                  onPressed: _close,
                                  icon: const SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Icon(shadcn.LucideIcons.x, size: 20),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    shadcn.NavigationDivider(
                      color: cs.border.withValues(alpha: 0.72),
                    ),
                  ],
                  footer: [
                    shadcn.NavigationDivider(
                      color: cs.border.withValues(alpha: 0.72),
                    ),
                    _navButton(
                      context,
                      label: '服务重启',
                      icon: shadcn.LucideIcons.serverCog,
                      onPressed: _restartServer,
                    ),
                    if (showAccountSwitcher)
                      _navButton(
                        context,
                        label: '切换账号',
                        icon: shadcn.LucideIcons.users,
                        onPressed: _switchAccount,
                      ),
                    _navButton(
                      context,
                      label: '退出登录',
                      icon: shadcn.LucideIcons.logOut,
                      onPressed: _logout,
                      destructive: true,
                    ),
                  ],
                  children: [
                    _navSectionLabel(context, '常用入口'),
                    _navItem(
                      context,
                      key: 'dashboard',
                      label: '数据仪表',
                      icon: shadcn.LucideIcons.layoutDashboard,
                      onTap: () => _go('/dashboard'),
                    ),
                    _navItem(
                      context,
                      key: 'search',
                      label: '全局搜索',
                      icon: shadcn.LucideIcons.search,
                      onTap: () => _go('/search'),
                    ),
                    _navGap(context, 8),
                    _navSectionLabel(context, '站点内容'),
                    if (showNews)
                      _navItem(
                        context,
                        key: 'news',
                        label: '资讯中心',
                        icon: shadcn.LucideIcons.newspaper,
                        onTap: () => _go('/home'),
                      ),
                    _navItem(
                      context,
                      key: 'sites',
                      label: '站点数据',
                      icon: shadcn.LucideIcons.globe,
                      onTap: () => _go('/sites'),
                    ),
                    _navButton(
                      context,
                      label: '站点动态',
                      icon: shadcn.LucideIcons.gitBranchPlus,
                      onPressed: () => _push(const SiteTimelinePage()),
                    ),
                    _navGap(context, 8),
                    _navSectionLabel(context, '下载任务'),
                    _navItem(
                      context,
                      key: 'downloads',
                      label: '下载管理',
                      icon: shadcn.LucideIcons.download,
                      onTap: () => _go('/downloads'),
                    ),
                    _navItem(
                      context,
                      key: 'tasks',
                      label: '任务列表',
                      icon: shadcn.LucideIcons.listTodo,
                      onTap: () => _go('/tasks'),
                    ),
                    _navGap(context, 8),
                    _navSectionLabel(context, '系统维护'),
                    _navButton(
                      context,
                      label: '设置中心',
                      icon: shadcn.LucideIcons.settings,
                      onPressed: () => _push(const OptionPage()),
                    ),
                    _navButton(
                      context,
                      label: '程序更新',
                      icon: shadcn.LucideIcons.arrowUpFromLine,
                      onPressed: () => _push(const UpdatePage()),
                    ),
                    if (!kIsWeb)
                      _navButton(
                        context,
                        label: '应用升级',
                        icon: shadcn.LucideIcons.circleArrowUp,
                        onPressed: () => _pushRoute('/app-upgrade'),
                      ),
                    _navButton(
                      context,
                      label: '日志中心',
                      icon: shadcn.LucideIcons.scrollText,
                      onPressed: _openLogCenter,
                    ),
                    _navButton(
                      context,
                      label: '日志浮窗',
                      icon: shadcn.LucideIcons.terminal,
                      onPressed: _openLogs,
                    ),
                    _navGap(context, 8),
                    _navSectionLabel(context, '用户权限'),
                    _navButton(
                      context,
                      label: '用户中心',
                      icon: shadcn.LucideIcons.user,
                      onPressed: () => _push(const UserManagementPage()),
                    ),
                    if (showAdminUser)
                      _navButton(
                        context,
                        label: '授权管理',
                        icon: shadcn.LucideIcons.shieldCheck,
                        onPressed: () => _push(const AdminUserPage()),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Key? _selectedNavigationKey(String currentPath) {
    if (currentPath.startsWith('/dashboard')) {
      return const ValueKey<String>('dashboard');
    }
    if (currentPath.startsWith('/search')) {
      return const ValueKey<String>('search');
    }
    if (currentPath.startsWith('/home')) {
      return const ValueKey<String>('news');
    }
    if (currentPath.startsWith('/sites')) {
      return const ValueKey<String>('sites');
    }
    if (currentPath.startsWith('/downloads')) {
      return const ValueKey<String>('downloads');
    }
    if (currentPath.startsWith('/tasks')) {
      return const ValueKey<String>('tasks');
    }
    return null;
  }

  Widget _navSectionLabel(BuildContext context, String label) {
    final tokens = _GlobalDrawerTokens.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: tokens.edgeOnly(left: 6, top: 6, right: 6, bottom: 2),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tokens.theme.typography.small.copyWith(
            color: tokens.cs.mutedForeground,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _navGap(BuildContext context, num height) {
    final tokens = _GlobalDrawerTokens.of(context);
    return SliverToBoxAdapter(child: SizedBox(height: tokens.size(height)));
  }

  Widget _navItem(
    BuildContext context, {
    required String key,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final tokens = _GlobalDrawerTokens.of(context);
    return shadcn.NavigationItem(
      key: ValueKey<String>(key),
      label: Text(label, style: _navLabelStyle(tokens)),
      overflow: shadcn.NavigationOverflow.ellipsis,
      spacing: tokens.size(9),
      style: _navButtonStyle,
      selectedStyle: _selectedNavButtonStyle,
      onChanged: (selected) {
        if (selected) onTap();
      },
      child: Icon(icon, size: 19),
    );
  }

  Widget _navButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool destructive = false,
  }) {
    final tokens = _GlobalDrawerTokens.of(context);
    final color = destructive ? tokens.cs.destructive : null;
    final labelStyle = _navLabelStyle(tokens, color: color);
    return shadcn.NavigationButton(
      label: Text(label, style: labelStyle),
      overflow: shadcn.NavigationOverflow.ellipsis,
      spacing: tokens.size(9),
      style: _navButtonStyle,
      onPressed: onPressed,
      child: Icon(icon, size: 19, color: color),
    );
  }

  TextStyle _navLabelStyle(_GlobalDrawerTokens tokens, {Color? color}) {
    return tokens.theme.typography.small.copyWith(
      color: color ?? tokens.cs.foreground,
      fontWeight: FontWeight.w600,
      height: 1.15,
    );
  }
}

const _navButtonStyle = shadcn.ButtonStyle.ghost();
const _selectedNavButtonStyle = shadcn.ButtonStyle.secondary();

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
          0.72,
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

class _GlobalDrawerAccountHeader extends StatelessWidget {
  final dynamic user;
  final String server;
  final Object? authInfo;
  final Widget? trailing;

  const _GlobalDrawerAccountHeader({
    required this.user,
    required this.server,
    required this.authInfo,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final username = _userName(user);
    final authEmail = _authInfoEmail(authInfo, user);
    final authTime = _authInfoTime(authInfo);
    final initial = username.isNotEmpty
        ? username.characters.first.toUpperCase()
        : '?';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            shadcn.Avatar(
              initials: initial,
              size: tokens.size(40),
              backgroundColor: cs.primary,
            ),
            SizedBox(width: tokens.size(11)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isEmpty ? '未登录用户' : username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.base.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: tokens.size(3)),
                  Text(
                    server,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      color: cs.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: tokens.size(6)),
              trailing!,
            ],
          ],
        ),
        SizedBox(height: tokens.size(13)),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: tokens.edgeOnly(left: 10, top: 10, right: 10, bottom: 10),
            decoration: BoxDecoration(
              color: cs.muted.withValues(alpha: 0.22),
              border: Border.all(color: cs.border.withValues(alpha: 0.56)),
              borderRadius: BorderRadius.circular(theme.radiusMd),
            ),
            child: Column(
              children: [
                _GlobalDrawerAuthLine(
                  icon: shadcn.LucideIcons.mail,
                  label: '授权邮箱',
                  value: authEmail.isEmpty ? '--' : authEmail,
                ),
                SizedBox(height: tokens.size(7)),
                _GlobalDrawerAuthLine(
                  icon: shadcn.LucideIcons.calendarClock,
                  label: '授权时间',
                  value: authTime.isEmpty ? '--' : authTime,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlobalDrawerAuthLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GlobalDrawerAuthLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _GlobalDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;

    return Row(
      children: [
        Icon(icon, size: tokens.size(14), color: cs.primary),
        SizedBox(width: tokens.size(7)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.small.copyWith(
            color: cs.mutedForeground,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        SizedBox(width: tokens.size(8)),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  value,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.small.copyWith(
                    color: cs.foreground,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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

String _userName(dynamic user) {
  try {
    final v = user?.username;
    if (v != null) return v.toString();
  } catch (_) {}
  return '';
}

String _userEmail(dynamic user) {
  try {
    final v = user?.email;
    if (v != null) return v.toString().trim();
  } catch (_) {}
  return '';
}

String _authInfoEmail(Object? authInfo, dynamic user) {
  final email = _findAuthInfoValue(authInfo, const [
    'email',
    'mail',
    'user_email',
    'invite_email',
  ]);
  final emailText = _stringValue(email);
  if (emailText.isNotEmpty) return emailText;

  final username = _findAuthInfoValue(authInfo, const [
    'username',
    'user_name',
    'name',
  ]);
  final usernameText = _stringValue(username);
  if (_looksLikeEmail(usernameText)) return usernameText;

  return _userEmail(user);
}

String _authInfoTime(Object? authInfo) {
  final value = _findAuthInfoValue(authInfo, const [
    'time_expire',
    'time expire',
    'timeExpire',
    'expire_time',
    'expired_at',
    'expires_at',
    'authorized_at',
    'authorizedAt',
    'auth_time',
    'authTime',
    'updated_at',
    'updatedAt',
    'created_at',
    'createdAt',
    'expire',
  ]);
  return _formatAuthInfoTime(value);
}

dynamic _findAuthInfoValue(Object? data, Iterable<String> keys) {
  if (data is Map) {
    for (final key in keys) {
      if (data.containsKey(key)) return data[key];
    }

    final normalizedKeys = keys.map(_normalizeAuthKey).toSet();
    for (final entry in data.entries) {
      if (normalizedKeys.contains(_normalizeAuthKey(entry.key.toString()))) {
        return entry.value;
      }
    }

    for (final entry in data.entries) {
      final nested = _findAuthInfoValue(entry.value, keys);
      if (nested != null) return nested;
    }
  }
  if (data is List) {
    for (final item in data) {
      final nested = _findAuthInfoValue(item, keys);
      if (nested != null) return nested;
    }
  }
  return null;
}

String _normalizeAuthKey(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
}

String _formatAuthInfoTime(dynamic value) {
  if (value == null) return '';
  if (value is DateTime) return formatDateTimeMinute(value.toLocal());
  if (value is num) return _formatAuthTimestamp(value);

  final text = value.toString().trim();
  if (text.isEmpty) return '';
  final numeric = num.tryParse(text);
  if (numeric != null) return _formatAuthTimestamp(numeric);

  final parsed = parseFlexibleLocalDateTime(text);
  return parsed == null ? text : formatDateTimeMinute(parsed);
}

String _formatAuthTimestamp(num value) {
  final timestamp = value.toInt();
  if (timestamp <= 0) return '';
  if (timestamp > 100000000000) {
    return formatDateTimeMinute(
      DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal(),
    );
  }
  if (timestamp > 1000000000) {
    return formatDateTimeMinute(
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal(),
    );
  }
  return timestamp.toString();
}

String _stringValue(dynamic value) =>
    value == null ? '' : value.toString().trim();

bool _looksLikeEmail(String value) =>
    value.contains('@') && value.contains('.');
