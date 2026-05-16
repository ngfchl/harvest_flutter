import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/notice/model/notice_history.dart';
import 'package:harvest/modules/notice/notice_history_page.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/invite_user.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:window_manager/window_manager.dart';

import '../admin_user/admin_user_page.dart';
import '../dashboard/dashboard_page.dart';
import '../dashboard/provider/privacy_provider.dart';
import '../download/download_page.dart';
import '../download/provider/downloader_speed_provider.dart';
import '../login/login_history_provider.dart';
import '../news/news_page.dart';
import '../news/provider/media_info_settings_provider.dart';
import '../option/provider/update_provider.dart';
import '../option/widgets/option_page.dart';
import '../option/widgets/update_page.dart';
import '../site/site_page.dart';
import '../site/site_timeline_page.dart';
import '../task/task_page.dart';
import '../user/provider/user_management_provider.dart';
import '../user/user_management_page.dart';
import 'provider/screenshot_provider.dart';
import 'widgets/log_floating_overlay.dart';
import 'widgets/shell_scaffold.dart';
import 'widgets/theme_dialog.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ShellPage
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  final _appUpgradeController = AppUpgradeController();
  PageController? _pageController;

  static const _routes = ['/home', '/sites', '/dashboard', '/downloads', '/tasks'];
  static final _pages = [NewsPage(), SitePage(), const DashboardPage(), DownloaderPage(), TaskPage()];
  static const _pageTitles = ['资讯', '站点', '仪表盘', '下载器', '任务中心'];
  static const _pageSubtitles = ['跟踪最新动态与公告', '维护站点配置与状态', '查看关键运行指标', '管理下载器与传输任务', '处理自动化与后台任务'];

  final _screenshotKey = GlobalKey();
  bool _capturing = false;
  bool _drawerOpen = false;
  bool _exitDialogOpen = false;
  double _drawerEdgeDragDistance = 0;
  int? _suppressedPageChangedIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageController ??= PageController(initialPage: _getCurrentIndex());
  }

  int _getCurrentIndex() {
    final location = GoRouterState.of(context).uri.toString();
    final idx = _routes.indexWhere((r) => location.startsWith(r));
    return idx >= 0 ? idx : 0;
  }

  void _onTap(int index) {
    final target = index.clamp(0, _routes.length - 1).toInt();
    _suppressedPageChangedIndex = target;
    _pageController?.jumpToPage(target);
    context.go(_routes[target]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _suppressedPageChangedIndex == target) {
        _suppressedPageChangedIndex = null;
      }
    });
  }

  void _onPageChanged(int index) {
    final target = index.clamp(0, _routes.length - 1).toInt();
    if (_suppressedPageChangedIndex == target) {
      _suppressedPageChangedIndex = null;
      return;
    }
    context.go(_routes[target]);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  // ── 截图 ──

  Future<void> _takeScreenshot() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    final wasPrivacyMode = ref.read(privacyModeProvider);
    final wasPaused = ref.read(speedPausedProvider);
    final wasScreenshotMode = ref.read(screenshotModeProvider);
    var privacyRestored = wasPrivacyMode;
    var screenshotModeRestored = wasScreenshotMode;
    try {
      if (!wasPaused) ref.read(speedPausedProvider.notifier).state = true;
      if (!wasScreenshotMode) {
        ref.read(screenshotModeProvider.notifier).state = true;
      }
      if (!wasPrivacyMode) {
        ref.read(privacyModeProvider.notifier).toggle();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;

      final sc = ref.read(activeScrollControllerProvider);
      final bytes = (sc != null && sc.hasClients && sc.position.maxScrollExtent > 0)
          ? await ScreenshotSaver.captureLong(scrollKey: _screenshotKey, scrollController: sc)
          : await ScreenshotSaver.capture(_screenshotKey);

      if (!wasPrivacyMode && mounted && ref.read(privacyModeProvider)) {
        ref.read(privacyModeProvider.notifier).toggle();
      }
      privacyRestored = true;
      if (!wasScreenshotMode && mounted) {
        ref.read(screenshotModeProvider.notifier).state = false;
      }
      screenshotModeRestored = true;

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
      if (!privacyRestored && mounted && ref.read(privacyModeProvider)) {
        ref.read(privacyModeProvider.notifier).toggle();
      }
      if (!screenshotModeRestored && mounted) {
        ref.read(screenshotModeProvider.notifier).state = wasScreenshotMode;
      }
      if (!wasPaused && mounted) {
        ref.read(speedPausedProvider.notifier).state = false;
      }
      if (mounted) setState(() => _capturing = false);
    }
  }

  // ── 退出 ──

  Future<void> _confirmExitApp() async {
    if (_exitDialogOpen || !mounted) return;
    _exitDialogOpen = true;
    final ok = await shadcn.showDialog<bool>(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('退出应用'),
        content: const Text('确定要退出应用吗？'),
        actions: [
          shadcn.Button.outline(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          shadcn.Button.destructive(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('退出')),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (ok == true) {
      await _exitApp();
    }
  }

  Future<void> _exitApp() async {
    try {
      await ServicesBinding.instance.exitApplication(ui.AppExitType.required);
    } catch (_) {
      // Continue with the platform fallbacks below.
    }

    if (PlatformTool.isIOS()) {
      PlatformTool.exitProcess();
    }

    await SystemNavigator.pop(animated: true);
  }

  // ── 抽屉 ──

  void _openDrawer() {
    if (mounted && !_drawerOpen) setState(() => _drawerOpen = true);
  }

  void _closeDrawer() {
    if (mounted && _drawerOpen) setState(() => _drawerOpen = false);
  }

  void _startDrawerEdgeDrag(DragStartDetails d) {
    _drawerEdgeDragDistance = 0;
  }

  void _handleDrawerEdgeDrag(DragUpdateDetails d) {
    if (_drawerOpen) return;
    final delta = d.primaryDelta ?? 0;
    if (delta <= 0) {
      _drawerEdgeDragDistance = 0;
      return;
    }
    _drawerEdgeDragDistance += delta;
    if (_drawerEdgeDragDistance > 24) {
      _drawerEdgeDragDistance = 0;
      _openDrawer();
    }
  }

  void _endDrawerEdgeDrag(DragEndDetails d) {
    _drawerEdgeDragDistance = 0;
  }

  Future<void> _openDrawerPage(Widget page) async {
    _closeDrawer();
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openDrawerTab(int index) {
    _closeDrawer();
    _onTap(index);
  }

  void _openAppUpgradeFromHeader() {
    if (context.isMobile) {
      context.push('/app-upgrade');
      return;
    }
    unawaited(_appUpgradeController.openDialog());
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final currentIndex = _getCurrentIndex();
    final authInfo = ref.watch(authInfoProvider).valueOrNull;
    final showAdminUser = _authInfoEmail(authInfo) == 'ngfchl@126.com';
    final updateState = ref.watch(updateProvider);
    final appUpgradeStatus = kIsWeb ? null : ref.watch(appUpgradeStatusProvider);
    final hasAppUpgrade = appUpgradeStatus?.valueOrNull?.hasNewVersion == true;
    final showNews = ref.watch(mediaInfoSettingsProvider).enabled;
    final notices = ref.watch(noticeHistoryProvider).valueOrNull ?? const <NoticeHistory>[];
    final unread = [
      for (final n in notices)
        if (!n.isRead) n,
    ];
    final colors = shadcn.Theme.of(context).colorScheme;
    final drawerWidth = (MediaQuery.sizeOf(context).width * 0.72).clamp(248.0, 288.0).toDouble();

    if (!showNews && currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _suppressedPageChangedIndex = 2;
        _pageController?.jumpToPage(2);
        context.go('/dashboard');
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_confirmExitApp());
      },
      child: EscapeBackScope(
        onBack: () => unawaited(_confirmExitApp()),
        child: shadcn.DrawerOverlay(
          child: Stack(
            children: [
              // ── 主体 ──
              ShellScaffold(
                index: currentIndex,
                onChange: _onTap,
                dashboardChrome: false,
                showNews: showNews,
                header: _ShellHeader(
                  title: _pageTitles[currentIndex],
                  subtitle: _pageSubtitles[currentIndex],
                  unreadNotices: unread,
                  onOpenNotices: () =>
                      Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const NoticeHistoryPage())),
                  onOpenDrawer: _openDrawer,
                  hasAppUpgrade: hasAppUpgrade,
                  onAppUpgrade: _openAppUpgradeFromHeader,
                  updateState: updateState,
                  avatar: _AccountMenuButton(
                    user: user,
                    showAdminUser: showAdminUser,
                    showAccountSwitcher: ref.watch(loginHistoryProvider).length >= 2,
                    hasAppUpgrade: hasAppUpgrade,
                    updateState: updateState,
                    onScreenshot: _takeScreenshot,
                    appUpgradeController: _appUpgradeController,
                  ),
                ),
                child: Stack(
                  children: [
                    RepaintBoundary(
                      key: _screenshotKey,
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _pages,
                      ),
                    ),
                    if (!kIsWeb)
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: AppUpgradePage(controller: _appUpgradeController, child: const SizedBox.shrink()),
                        ),
                      ),
                    if (_capturing)
                      Positioned.fill(
                        child: ColoredBox(
                          color: colors.foreground.withValues(alpha: 0.08),
                          child: const Center(child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
                        ),
                      ),
                  ],
                ),
              ),

              // ── 边缘滑动热区 ──
              if (!_drawerOpen)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 32,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: _startDrawerEdgeDrag,
                    onHorizontalDragUpdate: _handleDrawerEdgeDrag,
                    onHorizontalDragEnd: _endDrawerEdgeDrag,
                    onHorizontalDragCancel: () => _drawerEdgeDragDistance = 0,
                  ),
                ),

              // ── 抽屉遮罩 + 面板 ──
              if (_drawerOpen) ...[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _closeDrawer,
                    child: ColoredBox(color: colors.foreground.withValues(alpha: 0.12)),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: _ShellDrawerPanel(
                    currentIndex: currentIndex,
                    showAdminUser: showAdminUser,
                    showNews: showNews,
                    onClose: _closeDrawer,
                    onDashboard: () => _openDrawerTab(2),
                    onNews: () => _openDrawerTab(0),
                    onSites: () => _openDrawerTab(1),
                    onSiteTimeline: () => _openDrawerPage(const SiteTimelinePage()),
                    onDownloads: () => _openDrawerTab(3),
                    onTasks: () => _openDrawerTab(4),
                    onOptions: () => _openDrawerPage(const OptionPage()),
                    onUsers: () => _openDrawerPage(const UserManagementPage()),
                    onAdminUsers: () {
                      if (!showAdminUser) {
                        _closeDrawer();
                        Toast.warning('当前账号无授权管理权限');
                        return;
                      }
                      _openDrawerPage(const AdminUserPage());
                    },
                    onUpdate: () => _openDrawerPage(const UpdatePage()),
                    onAppUpgrade: () {
                      _closeDrawer();
                      context.push('/app-upgrade');
                    },
                    onLogs: () {
                      _closeDrawer();
                      LogOverlayManager.toggle(context);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  顶栏 Header
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const double _headerActionBoxSize = 28;
const double _headerActionIconSize = 18;

class _ShellHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<NoticeHistory> unreadNotices;
  final VoidCallback onOpenNotices;
  final VoidCallback onOpenDrawer;
  final bool hasAppUpgrade;
  final VoidCallback onAppUpgrade;
  final UpdateState updateState;
  final Widget avatar;

  const _ShellHeader({
    required this.title,
    required this.subtitle,
    required this.unreadNotices,
    required this.onOpenNotices,
    required this.onOpenDrawer,
    required this.hasAppUpgrade,
    required this.onAppUpgrade,
    required this.updateState,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final hasUnread = unreadNotices.isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: cs.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Material(
        color: cs.background,
        child: SafeArea(
          bottom: false,
          child: shadcn.AnimatedContainer(
            duration: Duration(milliseconds: 100),
            child: shadcn.AppBar(
              height: kAppHeaderHeight - 12,
              padding: appHeaderPadding(context),
              leading: [
                shadcn.IconButton.ghost(
                  size: shadcn.ButtonSize.small,
                  density: shadcn.ButtonDensity.iconDense,
                  onPressed: onOpenDrawer,
                  icon: const SizedBox(
                    width: _headerActionBoxSize,
                    height: _headerActionBoxSize,
                    child: Icon(shadcn.LucideIcons.panelLeft, size: _headerActionIconSize),
                  ),
                ),
              ],
              title: hasUnread
                  ? _NoticeTicker(notices: unreadNotices, onTap: onOpenNotices)
                  : Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.lead.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                    ),
              trailing: [
                if (!hasUnread)
                  _HeaderNoticeButton(unreadCount: unreadNotices.length, hasUnread: hasUnread, onTap: onOpenNotices),
                if (hasAppUpgrade)
                  _HeaderDotButton(
                    icon: shadcn.LucideIcons.circleArrowUp,
                    color: cs.destructive,
                    tooltip: '发现 APP 新版本',
                    onTap: onAppUpgrade,
                  ),
                if (updateState.hasAnyUpdate)
                  _HeaderBadgeButton(
                    icon: shadcn.LucideIcons.arrowUpFromLine,
                    count: updateState.updateCount,
                    tooltip: '发现程序更新',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatePage())),
                  ),
                avatar,
                if (PlatformTool.isWindows() && !context.isMobile) const _WindowsWindowControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WindowsWindowControls extends StatefulWidget {
  const _WindowsWindowControls();

  @override
  State<_WindowsWindowControls> createState() => _WindowsWindowControlsState();
}

class _WindowsWindowControlsState extends State<_WindowsWindowControls> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _syncMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _syncMaximized() async {
    final maximized = await windowManager.isMaximized();
    if (!mounted) return;
    setState(() => _isMaximized = maximized);
  }

  @override
  void onWindowMaximize() {
    if (mounted) setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) setState(() => _isMaximized = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrafficLightWindowButton(
            color: const Color(0xFFFFBD2E),
            icon: shadcn.LucideIcons.minus,
            tooltip: '最小化',
            onPressed: () async {
              final minimized = await windowManager.isMinimized();
              if (minimized) {
                await windowManager.restore();
              } else {
                await windowManager.minimize();
              }
            },
          ),
          _TrafficLightWindowButton(
            color: const Color(0xFF28C840),
            icon: _isMaximized ? shadcn.LucideIcons.minimize2 : shadcn.LucideIcons.maximize2,
            tooltip: _isMaximized ? '还原' : '最大化',
            onPressed: () async {
              if (_isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
              await _syncMaximized();
            },
          ),
          _TrafficLightWindowButton(
            color: const Color(0xFFFF5F57),
            icon: shadcn.LucideIcons.x,
            tooltip: '关闭',
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
}

class _TrafficLightWindowButton extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _TrafficLightWindowButton({
    required this.color,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_TrafficLightWindowButton> createState() => _TrafficLightWindowButtonState();
}

class _TrafficLightWindowButtonState extends State<_TrafficLightWindowButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final foreground = Color.lerp(Colors.black, widget.color, 0.18)!.withValues(alpha: 0.72);
    final circleColor = _pressed
        ? Color.lerp(widget.color, Colors.black, 0.10)!
        : _hovered
            ? Color.lerp(widget.color, Colors.white, 0.12)!
            : widget.color;

    return shadcn.Tooltip(
      tooltip: (_) => Text(widget.tooltip),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: SizedBox(
            width: 24,
            height: 32,
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 100),
                scale: _pressed ? 0.92 : (_hovered ? 1.08 : 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.border.withValues(alpha: _hovered ? 0.24 : 0.14), width: 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: _hovered ? 0.32 : 0.18),
                        blurRadius: _hovered ? 8 : 3,
                        spreadRadius: _hovered ? 0.5 : 0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, size: 8, color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeTicker extends ConsumerStatefulWidget {
  final List<NoticeHistory> notices;
  final VoidCallback onTap;

  const _NoticeTicker({required this.notices, required this.onTap});

  @override
  ConsumerState<_NoticeTicker> createState() => _NoticeTickerState();
}

class _NoticeTickerState extends ConsumerState<_NoticeTicker> {
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _NoticeTicker old) {
    super.didUpdateWidget(old);
    if (_ids(old.notices) != _ids(widget.notices)) {
      _index = 0;
      _syncTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _ids(List<NoticeHistory> list) => list.map((e) => e.id).join(',');

  void _syncTimer() {
    _timer?.cancel();
    if (widget.notices.length <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.notices.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final notice = widget.notices[_index.clamp(0, widget.notices.length - 1)];
    final count = widget.notices.length;
    final isDesktop = !context.isMobile;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: shadcn.OutlinedContainer(
        borderColor: cs.primary.withValues(alpha: 0.72),
        backgroundColor: cs.primary.withValues(alpha: 0.055),
        borderRadius: theme.borderRadiusLg,
        borderWidth: 1,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            // ── 铃铛 + 角标 ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(shadcn.LucideIcons.bell, size: 16, color: cs.foreground),
                Positioned(
                  top: -4,
                  right: -6,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: cs.destructive,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: cs.background, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(color: Colors.white, fontSize: 8, height: 1, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // ── 标题 + 桌面端摘要 ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, anim) {
                  final offset = Tween<Offset>(
                    begin: const Offset(0.2, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: Row(
                  key: ValueKey(notice.id),
                  children: [
                    Flexible(
                      flex: isDesktop ? 0 : 1,
                      child: isDesktop
                          ? Text(
                              _cleanTitle(notice.title),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                            )
                          : shadcn.OverflowMarquee(
                              child: Text(
                                _cleanTitle(notice.title),
                                style: theme.typography.small.copyWith(
                                  color: cs.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _cleanContent(notice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // ── 已读按钮 ──
            shadcn.Tooltip(
              tooltip: (_) => const Text('标记已读'),
              child: shadcn.IconButton.ghost(
                density: shadcn.ButtonDensity.compact,
                onPressed: () async {
                  try {
                    await ref.read(noticeHistoryProvider.notifier).markRead(notice);
                  } catch (_) {
                    Toast.error('标记已读失败');
                  }
                },
                icon: Icon(shadcn.LucideIcons.check, size: 15, color: cs.mutedForeground),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanTitle(String t) {
    final s = t.trim().replaceAll(RegExp(r'\s+'), ' ');
    return s.isEmpty ? '未命名通知' : s;
  }

  String _cleanContent(NoticeHistory n) {
    return n.content
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'[*_~`#>\[\]()!]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _HeaderNoticeButton extends StatelessWidget {
  final int unreadCount;
  final bool hasUnread;
  final VoidCallback onTap;

  const _HeaderNoticeButton({required this.unreadCount, required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final display = unreadCount > 99 ? '99+' : '$unreadCount';

    return shadcn.Tooltip(
      tooltip: (_) => Text(hasUnread ? '$display 条未读通知' : '通知列表'),
      child: shadcn.IconButton.ghost(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.iconDense,
        onPressed: onTap,
        icon: SizedBox(
          width: _headerActionBoxSize,
          height: _headerActionBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(shadcn.LucideIcons.bell, size: _headerActionIconSize, color: cs.foreground),
              if (hasUnread)
                Positioned(
                  top: -2,
                  right: -8,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: cs.destructive,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: cs.background, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      display,
                      style: TextStyle(color: Colors.white, fontSize: 8, height: 1, fontWeight: FontWeight.w800),
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  顶栏小按钮（带角标 / 带圆点）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// 带数字角标的按钮（程序更新）
class _HeaderBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderBadgeButton({required this.icon, required this.count, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final display = count > 99 ? '99+' : '$count';

    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip),
      child: shadcn.IconButton.ghost(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.iconDense,
        onPressed: onTap,
        icon: SizedBox(
          width: _headerActionBoxSize,
          height: _headerActionBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: _headerActionIconSize, color: cs.foreground),
              Positioned(
                top: -2,
                right: -10,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: cs.chart4,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.background, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    display,
                    style: TextStyle(color: cs.primaryForeground, fontSize: 9, height: 1, fontWeight: FontWeight.w700),
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

/// 带红圆点的按钮（APP 升级）
class _HeaderDotButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderDotButton({required this.icon, this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip),
      child: shadcn.IconButton.ghost(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.iconDense,
        onPressed: onTap,
        icon: SizedBox(
          width: _headerActionBoxSize,
          height: _headerActionBoxSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: _headerActionIconSize, color: color ?? cs.foreground),
              Positioned(
                top: -2,
                right: -6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: cs.destructive,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.background, width: 1),
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  账户菜单（头像 + 下拉）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _AccountMenuButton extends ConsumerWidget {
  final dynamic user;
  final bool showAdminUser;
  final bool showAccountSwitcher;
  final bool hasAppUpgrade;
  final UpdateState updateState;
  final VoidCallback onScreenshot;
  final AppUpgradeController appUpgradeController;

  const _AccountMenuButton({
    required this.user,
    required this.showAdminUser,
    required this.showAccountSwitcher,
    required this.hasAppUpgrade,
    required this.updateState,
    required this.onScreenshot,
    required this.appUpgradeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showMenu(context, ref),
      child: shadcn.Avatar(
        initials: user?.username?.substring(0, 1).toUpperCase() ?? '?',
        size: 32,
        backgroundColor: cs.primary,
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    final colors = shadcn.Theme.of(context).colorScheme;
    final menuKey = GlobalKey();

    shadcn.showPopover<void>(
      context: context,
      alignment: Alignment.topRight,
      anchorAlignment: Alignment.bottomRight,
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      offset: const Offset(0, 8),
      consumeOutsideTaps: false,
      regionGroupId: menuKey,
      handler: const shadcn.PopoverOverlayHandler(),
      overlayBarrier: shadcn.OverlayBarrier(borderRadius: BorderRadius.circular(shadcn.Theme.of(context).radiusMd)),
      builder: (_) => shadcn.Data.inherit(
        data: shadcn.DropdownMenuData(menuKey),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: shadcn.DropdownMenu(
            children: [
              shadcn.MenuLabel(child: const Text('账号')),
              _item(
                context,
                icon: shadcn.LucideIcons.user,
                title: '用户中心',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementPage())),
              ),
              if (showAdminUser)
                _item(
                  context,
                  icon: shadcn.LucideIcons.shieldCheck,
                  title: '授权管理',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUserPage())),
                ),
              _item(
                context,
                icon: shadcn.LucideIcons.userPlus,
                title: '邀请用户',
                onTap: () => showInviteUserDialog(context),
              ),
              if (showAccountSwitcher)
                _item(
                  context,
                  icon: shadcn.LucideIcons.users,
                  title: '切换账号',
                  onTap: () => ref.read(authNotifierProvider.notifier).logout(redirectTo: '/login-history'),
                ),
              _item(
                context,
                icon: shadcn.LucideIcons.logOut,
                title: '退出登录',
                color: colors.destructive,
                onTap: () => ref.read(authNotifierProvider.notifier).logout(),
              ),
              const shadcn.MenuDivider(),
              shadcn.MenuLabel(child: const Text('设置')),
              _item(context, icon: shadcn.LucideIcons.palette, title: '主题设置', onTap: () => showThemeDialog(context)),
              if (!kIsWeb) _item(context, icon: shadcn.LucideIcons.camera, title: '截图分享', onTap: onScreenshot),
              _item(
                context,
                icon: shadcn.LucideIcons.download,
                title: '程序更新',
                highlighted: updateState.hasAnyUpdate,
                trailing: updateState.hasAnyUpdate ? _UpdateBadge(count: updateState.updateCount) : null,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdatePage())),
              ),
              if (!kIsWeb)
                _item(
                  context,
                  icon: shadcn.LucideIcons.circleArrowUp,
                  title: 'APP升级',
                  highlighted: hasAppUpgrade,
                  onTap: () => context.push('/app-upgrade'),
                ),
              _item(
                context,
                icon: shadcn.LucideIcons.settings,
                title: '设置中心',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OptionPage())),
              ),
              _item(
                context,
                icon: shadcn.LucideIcons.terminal,
                title: '日志中心',
                onTap: () => LogOverlayManager.toggle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  shadcn.MenuButton _item(
    BuildContext context, {
    required IconData icon,
    required String title,
    required FutureOr<void> Function() onTap,
    Widget? trailing,
    Color? color,
    bool highlighted = false,
  }) {
    const hl = Color(0xFFF59E0B);
    final c = highlighted ? hl : color;
    final style = c == null ? null : TextStyle(color: c, fontWeight: FontWeight.w700);
    return shadcn.MenuButton(
      onPressed: (_) => unawaited(Future<void>.sync(onTap)),
      child: SizedBox(
        width: 148,
        child: Row(
          children: [
            Icon(icon, size: 16, color: c),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  final int count;

  const _UpdateBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = shadcn.Theme.of(context).colorScheme.chart4;
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
        count > 99 ? '99+' : '$count',
        style: TextStyle(color: color, fontSize: 10, height: 1, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  抽屉面板
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ShellDrawerPanel extends StatelessWidget {
  final int currentIndex;
  final bool showAdminUser;
  final bool showNews;
  final VoidCallback onClose;
  final VoidCallback onDashboard, onNews, onSites, onDownloads, onTasks;
  final VoidCallback onSiteTimeline;
  final VoidCallback onOptions, onUsers, onAdminUsers, onUpdate, onAppUpgrade, onLogs;

  const _ShellDrawerPanel({
    required this.currentIndex,
    required this.showAdminUser,
    required this.showNews,
    required this.onClose,
    required this.onDashboard,
    required this.onNews,
    required this.onSites,
    required this.onSiteTimeline,
    required this.onDownloads,
    required this.onTasks,
    required this.onOptions,
    required this.onUsers,
    required this.onAdminUsers,
    required this.onUpdate,
    required this.onAppUpgrade,
    required this.onLogs,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = _ShellDrawerTokens.of(context);
    final theme = tokens.theme;
    final cs = tokens.cs;
    final typo = theme.typography;

    return Material(
      color: cs.background,
      child: SafeArea(
        right: false,
        child: Container(
          margin: tokens.edgeOnly(top: 6, right: 6, bottom: 6),
          decoration: BoxDecoration(
            color: cs.background,
            border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.8),
            borderRadius: BorderRadius.circular(theme.radiusLg),
            boxShadow: [
              BoxShadow(color: cs.foreground.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(8, 0)),
            ],
          ),
          child: Column(
            children: [
              // 标题栏
              Padding(
                padding: tokens.edgeOnly(left: 14, top: PlatformTool.isDesktopOS() ? 33 : 10, right: 8, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '导航菜单',
                            style: typo.base.copyWith(color: cs.foreground, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: tokens.size(1)),
                          Text('左侧快速访问应用页面与工具', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                        ],
                      ),
                    ),
                    shadcn.IconButton.ghost(
                      size: shadcn.ButtonSize.small,
                      density: shadcn.ButtonDensity.iconDense,
                      onPressed: onClose,
                      icon: const SizedBox(
                        width: _headerActionBoxSize,
                        height: _headerActionBoxSize,
                        child: Icon(shadcn.LucideIcons.x, size: _headerActionIconSize),
                      ),
                    ),
                  ],
                ),
              ),
              ColoredBox(color: cs.border.withValues(alpha: 0.72), child: const SizedBox(height: 1)),
              Expanded(
                child: ListView(
                  padding: tokens.edgeOnly(left: 8, top: 8, right: 8, bottom: 12),
                  children: [
                    _DrawerGroup(
                      title: '主要页面',
                      children: [
                        _DrawerTile(
                          label: '仪表',
                          icon: shadcn.LucideIcons.layoutDashboard,
                          selected: currentIndex == 2,
                          onTap: onDashboard,
                        ),
                        if (showNews)
                          _DrawerTile(
                            label: '资讯',
                            icon: shadcn.LucideIcons.newspaper,
                            selected: currentIndex == 0,
                            onTap: onNews,
                          ),
                        _DrawerTile(
                          label: '站点数据',
                          icon: shadcn.LucideIcons.globe,
                          selected: currentIndex == 1,
                          onTap: onSites,
                        ),
                        _DrawerTile(label: '站点时间轴', icon: shadcn.LucideIcons.gitBranchPlus, onTap: onSiteTimeline),
                        _DrawerTile(
                          label: '下载器',
                          icon: shadcn.LucideIcons.download,
                          selected: currentIndex == 3,
                          onTap: onDownloads,
                        ),
                        _DrawerTile(
                          label: '任务列表',
                          icon: shadcn.LucideIcons.listTodo,
                          selected: currentIndex == 4,
                          onTap: onTasks,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.size(8)),
                    _DrawerGroup(
                      title: '管理与工具',
                      children: [
                        _DrawerTile(label: '设置中心', icon: shadcn.LucideIcons.settings, onTap: onOptions),
                        _DrawerTile(label: '用户中心', icon: shadcn.LucideIcons.user, onTap: onUsers),
                        _DrawerTile(
                          label: '授权管理',
                          icon: shadcn.LucideIcons.shieldCheck,
                          enabled: showAdminUser,
                          onTap: onAdminUsers,
                        ),
                        _DrawerTile(label: '程序更新', icon: shadcn.LucideIcons.arrowUpFromLine, onTap: onUpdate),
                        if (!kIsWeb)
                          _DrawerTile(label: 'APP升级', icon: shadcn.LucideIcons.circleArrowUp, onTap: onAppUpgrade),
                        _DrawerTile(label: '日志中心', icon: shadcn.LucideIcons.terminal, onTap: onLogs),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShellDrawerTokens {
  final shadcn.ThemeData theme;
  final shadcn.ColorScheme cs;
  final double densityScale;
  final double textScale;

  const _ShellDrawerTokens._({
    required this.theme,
    required this.cs,
    required this.densityScale,
    required this.textScale,
  });

  factory _ShellDrawerTokens.of(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling).clamp(0.58, 1.18);
    final textScale = theme.scaling.clamp(0.86, 1.22);
    return _ShellDrawerTokens._(
      theme: theme,
      cs: theme.colorScheme,
      densityScale: densityScale.toDouble(),
      textScale: textScale.toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double font(num value) => value * textScale;

  EdgeInsets edgeOnly({num left = 0, num top = 0, num right = 0, num bottom = 0}) =>
      EdgeInsets.only(left: size(left), top: size(top), right: size(right), bottom: size(bottom));

  EdgeInsets symmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: size(horizontal), vertical: size(vertical));
}

class _DrawerGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DrawerGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final tokens = _ShellDrawerTokens.of(context);
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
    final tokens = _ShellDrawerTokens.of(context);
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
              color: selected ? cs.primary.withValues(alpha: 0.1) : cs.background.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(
                color: selected ? cs.primary.withValues(alpha: 0.26) : cs.background.withValues(alpha: 0),
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
                if (selected) Icon(shadcn.LucideIcons.chevronRight, size: tokens.font(14), color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  工具函数
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

String? _authInfoEmail(dynamic data) {
  if (data is Map) {
    final v = data['username'] ?? data['mail'] ?? data['user_email'];
    if (v != null) return v.toString();
    for (final entry in data.entries) {
      final nested = _authInfoEmail(entry.value);
      if (nested != null && nested.isNotEmpty) return nested;
    }
  }
  return null;
}
