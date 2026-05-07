import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/notice/notice_history_page.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/invite_user.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

import '../../common/style.dart';
import '../admin_user/admin_user_page.dart';
import '../dashboard/dashboard_page.dart';
// 各个子页面，按需调整路径
import '../download/download_page.dart';
import '../download/provider/downloader_speed_provider.dart';
import '../news/news_page.dart';
import '../option/provider/update_provider.dart';
import '../option/widgets/option_page.dart';
import '../option/widgets/update_page.dart';
import '../site/site_page.dart';
import '../task/task_page.dart';
import '../user/provider/user_management_provider.dart';
import '../user/user_management_page.dart';
import 'provider/screenshot_provider.dart';
import 'widgets/log_floating_overlay.dart';
import 'widgets/shell_scaffold.dart';
import 'widgets/theme_dialog.dart';

const _dashboardShellBg = Color(0xFF07111F);
const _dashboardShellPanel = Color(0xFF0D1B2E);
const _dashboardShellPanelSoft = Color(0xFF10243B);
const _dashboardShellLine = Color(0xFF1D3757);
const _dashboardShellText = Color(0xFFEAF2FF);
const _dashboardShellMuted = Color(0xFF88A4C4);
const _dashboardShellCyan = Color(0xFF22D3EE);

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> with SingleTickerProviderStateMixin {
  late FPopoverController controller;
  final _appUpgradeController = AppUpgradeController();
  PageController? _pageController;

  static const _routes = ['/home', '/sites', '/dashboard', '/downloads', '/tasks'];

  static final _pages = [NewsPage(), SitePage(), const DashboardPage(), DownloaderPage(), TaskPage()];

  // ── 截图 ──
  final _screenshotKey = GlobalKey();
  bool _capturing = false;
  bool _exitDialogOpen = false;
  int? _suppressedPageChangedIndex;

  @override
  void initState() {
    super.initState();
    controller = FPopoverController(vsync: this);

    // _pageController = PageController(initialPage: _getCurrentIndex());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ 在这里初始化 PageController，此时 context 已可用
    _pageController ??= PageController(initialPage: _getCurrentIndex());
  }

  int _getCurrentIndex() {
    final location = GoRouterState.of(context).uri.toString();
    final index = _routes.indexWhere((r) => location.startsWith(r));
    return index >= 0 ? index : 0;
  }

  int _normalizeRouteIndex(int index) {
    return index.clamp(0, _routes.length - 1).toInt();
  }

  void _onTap(int index) {
    final target = _normalizeRouteIndex(index);
    _suppressedPageChangedIndex = target;
    _pageController?.jumpToPage(target);
    context.go(_routes[target]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_suppressedPageChangedIndex == target) {
        _suppressedPageChangedIndex = null;
      }
    });
  }

  void _onPageChanged(int index) {
    final target = _normalizeRouteIndex(index);
    if (_suppressedPageChangedIndex == target) {
      _suppressedPageChangedIndex = null;
      return;
    }
    context.go(_routes[target]);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _takeScreenshot() async {
    if (_capturing) return;
    setState(() => _capturing = true);

    try {
      final wasPaused = ref.read(speedPausedProvider);
      if (!wasPaused) {
        ref.read(speedPausedProvider.notifier).state = true;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final scrollController = ref.read(activeScrollControllerProvider);

      debugPrint('[Screenshot] scrollController=$scrollController');
      debugPrint('[Screenshot] hasClients=${scrollController?.hasClients}');
      debugPrint('[Screenshot] maxScrollExtent=${scrollController?.position.maxScrollExtent}');

      Uint8List? bytes;

      if (scrollController != null && scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
        debugPrint('[Screenshot] → 长截图模式');
        bytes = await ScreenshotSaver.captureLong(scrollKey: _screenshotKey, scrollController: scrollController);
      } else {
        debugPrint('[Screenshot] → 普通截图模式');
        bytes = await ScreenshotSaver.capture(_screenshotKey);
      }

      if (bytes == null) {
        Toast.error('截图失败');
        return;
      }

      await ScreenshotSaver.saveAndShare(bytes);
      Toast.success('截图已保存');
    } catch (e) {
      debugPrint('截图失败: $e');
      Toast.error('截图失败');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _handleShellEscape() async {
    if (controller.status != AnimationStatus.dismissed) {
      await controller.hide();
      return;
    }

    await _confirmExitApp();
  }

  Future<void> _confirmExitApp() async {
    if (_exitDialogOpen || !mounted) return;

    _exitDialogOpen = true;
    final confirmed = await showFDialog<bool>(
      context: context,
      builder: (ctx, style, animation) => FDialog.adaptive(
        style: (_) => style,
        animation: animation,
        title: const Text('退出应用'),
        body: const Text('确定要退出应用吗？'),
        actions: [
          FButton(style: FButtonStyle.outline(), onPress: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () => Navigator.of(ctx).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;

    if (confirmed == true) {
      await _exitApp();
    }
  }

  Future<void> _exitApp() async {
    try {
      await ServicesBinding.instance.exitApplication(ui.AppExitType.required);
    } catch (_) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final currentIndex = _getCurrentIndex();
    final authInfo = ref.watch(authInfoProvider).valueOrNull;
    final showAdminUser = _authInfoEmail(authInfo) == 'ngfchl@126.com';
    final updateState = ref.watch(updateProvider);
    final appUpgradeStatus = ref.watch(appUpgradeStatusProvider);
    final hasAppUpgrade = appUpgradeStatus.valueOrNull?.hasNewVersion == true;
    final colors = FTheme.of(context).colors;
    final dashboardShellChrome = currentIndex == 2 && !context.isMobile;

    return EscapeBackScope(
      onBack: _handleShellEscape,
      child: ShellScaffold(
        index: currentIndex,
        onChange: _onTap,
        scaffoldStyle: dashboardShellChrome ? _dashboardShellScaffoldStyle() : null,
        dashboardChrome: dashboardShellChrome,
        header: FHeader(
          style: dashboardShellChrome ? _dashboardShellHeaderStyle(context) : fHeaderStyle(context),
          suffixes: [
            // FButton.icon(
            //   onPress: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (_) => const UnifiedSearchPage()),
            //   ),
            //   style: FButtonStyle.ghost(),
            //   child: FTooltip(
            //     tipBuilder: (BuildContext p1, FTooltipController p2) {
            //       return Text('搜索电影、剧集...');
            //     },
            //     child: Icon(FIcons.search),
            //   ),
            // ),
            _UpdateHeaderButton(state: updateState, dashboardChrome: dashboardShellChrome),
            _AppUpgradeHeaderButton(dashboardChrome: dashboardShellChrome, onOpen: _appUpgradeController.openDialog),
            _NoticeHeaderButton(
              unreadCount: ref.watch(noticeUnreadCountProvider),
              dashboardChrome: dashboardShellChrome,
            ),

            FPopoverMenu.tiles(
              popoverController: controller,
              style: fPopoverMenuStyle(context).call,
              menu: [
                // 账号
                FTileGroup(
                  label: const Text('账号'),
                  style: fTileGroupStyle(context).call,
                  children: [
                    FTile(
                      prefix: const Icon(FIcons.user),
                      title: const Text('用户中心'),
                      onPress: () async {
                        await controller.hide();
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementPage()));
                        }
                      },
                    ),
                    if (showAdminUser)
                      FTile(
                        prefix: const Icon(FIcons.shieldCheck),
                        title: const Text('授权管理'),
                        onPress: () async {
                          await controller.hide();
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminUserPage()));
                          }
                        },
                      ),
                    inviteUserTile(context),
                    FTile(
                      prefix: const Icon(FIcons.users),
                      title: const Text('切换账号'),
                      onPress: () async {
                        await controller.hide();
                        await ref.read(authNotifierProvider.notifier).logout(redirectTo: '/login-history');
                      },
                    ),
                    FTile(
                      prefix: const Icon(FIcons.logOut),
                      title: const Text('退出登录'),
                      onPress: () async {
                        await controller.hide();
                        await ref.read(authNotifierProvider.notifier).logout();
                      },
                    ),
                  ],
                ),
                // 设置
                FTileGroup(
                  label: const Text('设置'),
                  children: [
                    FTile(
                      prefix: const Icon(FIcons.palette),
                      title: const Text('主题设置'),
                      onPress: () => showDialog(context: context, builder: (_) => const ThemeDialog()),
                    ),
                    FTile(
                      prefix: const Icon(FIcons.camera),
                      title: const Text('截图分享'),
                      onPress: () async {
                        await controller.hide();
                        await _takeScreenshot();
                      },
                    ),
                    FTile(
                      prefix: Icon(FIcons.download, color: updateState.hasAnyUpdate ? colors.foreground : null),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '程序更新',
                              style: updateState.hasAnyUpdate
                                  ? const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w700)
                                  : null,
                            ),
                          ),
                          if (updateState.hasAnyUpdate) _UpdateCountBadge(count: updateState.updateCount),
                        ],
                      ),
                      onPress: () async {
                        await controller.hide();
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UpdatePage()));
                        }
                      },
                    ),
                    FTile(
                      prefix: Icon(FIcons.circleArrowUp, color: hasAppUpgrade ? colors.foreground : null),
                      title: Text(
                        'APP升级',
                        style: hasAppUpgrade
                            ? const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.w700)
                            : null,
                      ),
                      onPress: () async {
                        await controller.hide();
                        await _appUpgradeController.openDialog();
                      },
                    ),
                    FTile(
                      prefix: const Icon(FIcons.settings),
                      title: const Text('设置中心'),
                      onPress: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OptionPage())),
                    ),
                    FTile(
                      prefix: const Icon(FIcons.terminal),
                      title: const Text('日志中心'),
                      onPress: () => LogOverlayManager.toggle(context),
                    ),
                  ],
                ),
              ],
              child: GestureDetector(
                onTap: () => controller.toggle(),
                child: FAvatar.raw(
                  size: 32.0,
                  style: FAvatarStyle(
                    backgroundColor: dashboardShellChrome
                        ? _dashboardShellPanelSoft.withValues(alpha: 0.88)
                        : FTheme.of(context).colors.primary,
                    foregroundColor: dashboardShellChrome
                        ? _dashboardShellText
                        : FTheme.of(context).colors.primaryForeground,
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ).call,
                  child: Text(user?.username.substring(0, 1).toUpperCase() ?? "未登录"),
                ),
              ),
            ),
          ],
        ),

        child: Stack(
          children: [
            RepaintBoundary(
              key: _screenshotKey,
              child: PageView(controller: _pageController, onPageChanged: _onPageChanged, children: _pages),
            ),
            IgnorePointer(
              child: Align(
                alignment: Alignment.topLeft,
                child: AppUpgradePage(controller: _appUpgradeController, child: SizedBox.shrink()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

FHeaderStyle Function(FHeaderStyle) _dashboardShellHeaderStyle(BuildContext context) {
  final typography = FTheme.of(context).typography;

  return (style) => style.copyWith(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    titleTextStyle: typography.xl.copyWith(
      color: _dashboardShellText,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      height: 1,
    ),
    actionSpacing: 8,
    actionStyle: (actionStyle) => actionStyle.copyWith(
      iconStyle: FWidgetStateMap({
        WidgetState.disabled: IconThemeData(color: _dashboardShellMuted.withValues(alpha: 0.38), size: 24),
        WidgetState.hovered: const IconThemeData(color: _dashboardShellCyan, size: 24),
        WidgetState.pressed: const IconThemeData(color: _dashboardShellCyan, size: 24),
        WidgetState.any: const IconThemeData(color: _dashboardShellText, size: 24),
      }),
    ),
  );
}

_dashboardShellGhostButtonStyle() => FButtonStyle.ghost(
  (style) => style.copyWith(
    decoration: FWidgetStateMap({
      WidgetState.disabled: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      WidgetState.hovered | WidgetState.pressed: BoxDecoration(
        color: _dashboardShellPanelSoft.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _dashboardShellCyan.withValues(alpha: 0.26), width: 0.7),
      ),
      WidgetState.any: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0x00000000)),
    }),
    contentStyle: (contentStyle) => contentStyle.copyWith(
      textStyle: FWidgetStateMap({
        WidgetState.disabled: TextStyle(color: _dashboardShellMuted.withValues(alpha: 0.42)),
        WidgetState.hovered: const TextStyle(color: _dashboardShellCyan, fontWeight: FontWeight.w700),
        WidgetState.pressed: const TextStyle(color: _dashboardShellCyan, fontWeight: FontWeight.w700),
        WidgetState.any: const TextStyle(color: _dashboardShellText, fontWeight: FontWeight.w700),
      }),
      iconStyle: FWidgetStateMap({
        WidgetState.disabled: IconThemeData(color: _dashboardShellMuted.withValues(alpha: 0.42), size: 20),
        WidgetState.hovered: const IconThemeData(color: _dashboardShellCyan, size: 20),
        WidgetState.pressed: const IconThemeData(color: _dashboardShellCyan, size: 20),
        WidgetState.any: const IconThemeData(color: _dashboardShellText, size: 20),
      }),
    ),
    iconContentStyle: (iconStyle) => iconStyle.copyWith(
      iconStyle: FWidgetStateMap({
        WidgetState.disabled: IconThemeData(color: _dashboardShellMuted.withValues(alpha: 0.42), size: 20),
        WidgetState.hovered: const IconThemeData(color: _dashboardShellCyan, size: 20),
        WidgetState.pressed: const IconThemeData(color: _dashboardShellCyan, size: 20),
        WidgetState.any: const IconThemeData(color: _dashboardShellText, size: 20),
      }),
    ),
  ),
);

FScaffoldStyle Function(FScaffoldStyle) _dashboardShellScaffoldStyle() {
  return (style) => style.copyWith(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    backgroundColor: _dashboardShellBg,
    headerDecoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_dashboardShellBg, _dashboardShellPanel.withValues(alpha: 0.98), _dashboardShellBg],
      ),
      border: Border(bottom: BorderSide(color: _dashboardShellLine.withValues(alpha: 0.95), width: 0.8)),
      boxShadow: [
        BoxShadow(color: _dashboardShellCyan.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 8)),
      ],
    ),
  );
}

class _UpdateHeaderButton extends StatelessWidget {
  final UpdateState state;
  final bool dashboardChrome;

  const _UpdateHeaderButton({required this.state, this.dashboardChrome = false});

  @override
  Widget build(BuildContext context) {
    if (!state.hasAnyUpdate) return const SizedBox.shrink();

    final cs = FTheme.of(context).colors;
    final displayCount = state.updateCount > 99 ? '99+' : '${state.updateCount}';
    final iconColor = dashboardChrome ? _dashboardShellText : cs.foreground;
    final borderColor = dashboardChrome ? _dashboardShellBg : cs.background;
    const badgeColor = Color(0xFFF59E0B);

    return FButton.icon(
      onPress: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatePage())),
      style: dashboardChrome ? _dashboardShellGhostButtonStyle() : FButtonStyle.ghost(),
      child: FTooltip(
        tipBuilder: (BuildContext p1, FTooltipController p2) => const Text('发现程序更新'),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(FIcons.arrowUpFromLine, size: 18, color: iconColor),
              Positioned(
                top: -2,
                right: -10,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    displayCount,
                    style: const TextStyle(color: Colors.white, fontSize: 9, height: 1, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateCountBadge extends StatelessWidget {
  final int count;

  const _UpdateCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : '$count';
    const color = Color(0xFFF59E0B);

    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.32), width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        displayCount,
        style: const TextStyle(color: color, fontSize: 10, height: 1, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _AppUpgradeHeaderButton extends ConsumerWidget {
  final bool dashboardChrome;
  final Future<void> Function() onOpen;

  const _AppUpgradeHeaderButton({required this.onOpen, this.dashboardChrome = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appUpgradeStatusProvider);
    final data = status.valueOrNull;
    if (data == null || !data.hasNewVersion) {
      return const SizedBox.shrink();
    }

    final cs = FTheme.of(context).colors;
    final iconColor = dashboardChrome ? _dashboardShellText : cs.destructive;
    final badgeBorderColor = dashboardChrome ? _dashboardShellBg : cs.background;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onOpen,
      child: FTooltip(
        tipBuilder: (_, _) =>
            Text(data.ignored ? '已忽略 APP 新版本 v${data.latest.version}，点击查看' : '发现 APP 新版本 v${data.latest.version}'),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(FIcons.circleArrowUp, size: 19, color: iconColor),
              Positioned(
                top: -2,
                right: -8,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: cs.destructive,
                    shape: BoxShape.circle,
                    border: Border.all(color: badgeBorderColor, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeHeaderButton extends StatelessWidget {
  final int unreadCount;
  final bool dashboardChrome;

  const _NoticeHeaderButton({required this.unreadCount, this.dashboardChrome = false});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final displayCount = unreadCount > 99 ? '99+' : '$unreadCount';
    final iconColor = dashboardChrome ? _dashboardShellText : null;
    final badgeBorderColor = dashboardChrome ? _dashboardShellBg : cs.background;

    return FButton.icon(
      onPress: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const NoticeHistoryPage())),
      style: dashboardChrome ? _dashboardShellGhostButtonStyle() : FButtonStyle.ghost(),
      child: FTooltip(
        tipBuilder: (BuildContext p1, FTooltipController p2) => const Text('通知历史'),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(unreadCount > 0 ? FIcons.bellRing : FIcons.bell, size: 18, color: iconColor),
              if (unreadCount > 0)
                Positioned(
                  top: -2,
                  right: -10,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: cs.destructive,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeBorderColor, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      displayCount,
                      style: TextStyle(
                        color: cs.destructiveForeground,
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _authInfoEmail(dynamic data) {
  if (data is Map) {
    final value = data['username'] ?? data['mail'] ?? data['user_email'];
    if (value != null) return value.toString();
    for (final entry in data.entries) {
      final nested = _authInfoEmail(entry.value);
      if (nested != null && nested.isNotEmpty) return nested;
    }
  }
  return null;
}
