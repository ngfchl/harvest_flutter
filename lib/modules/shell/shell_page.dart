import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/admin_user/admin_user_access.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/notice/model/notice_history.dart';
import 'package:harvest/modules/notice/notice_history_page.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/option/widgets/app_upgrade_page.dart';
import 'package:harvest/modules/shell/widgets/invite_user.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
import '../search/unified_search_page.dart';
import '../site/site_page.dart';
import '../task/task_page.dart';
import '../user/provider/user_management_provider.dart';
import '../user/user_management_page.dart';
import 'provider/screenshot_provider.dart';
import 'widgets/global_drawer_swipe_area.dart';
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

  static const _routes = [
    '/home',
    '/sites',
    '/dashboard',
    '/downloads',
    '/tasks',
    '/search',
  ];
  static const _primaryPageCount = 5;
  static const _defaultPrimaryPageIndex = 2;
  static const _searchPageIndex = 5;
  static const _pageTitles = ['资讯', '站点', '仪表盘', '下载器', '任务中心', '搜索'];
  static const _pageSubtitles = [
    '跟踪最新动态与公告',
    '维护站点配置与状态',
    '查看关键运行指标',
    '管理下载器与传输任务',
    '处理自动化与后台任务',
    '检索影视信息与站点资源',
  ];

  final _screenshotKey = GlobalKey();
  bool _capturing = false;
  bool _drawerOpening = false;
  bool _exitDialogOpen = false;
  int _lastPrimaryIndex = _defaultPrimaryPageIndex;

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
    _jumpToPage(target);
    context.go(_routes[target]);
  }

  void _openSearchPage() {
    _onTap(_searchPageIndex);
  }

  void _closeSearchPage() {
    final target = _lastPrimaryIndex.clamp(0, _primaryPageCount - 1).toInt();
    _onTap(target);
  }

  List<Widget> _buildPages() {
    return [
      const _KeepAlivePage(child: NewsPage()),
      const _KeepAlivePage(child: SitePage()),
      const _KeepAlivePage(child: DashboardPage()),
      const _KeepAlivePage(child: DownloaderPage()),
      const _KeepAlivePage(child: TaskPage()),
      _KeepAlivePage(child: UnifiedSearchPage(onClose: _closeSearchPage)),
    ];
  }

  void _jumpToPage(int index) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    controller.jumpToPage(index);
  }

  void _syncPageController(int index) {
    final controller = _pageController;
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;
      final currentPage = controller.page?.round();
      if (currentPage == index) return;
      controller.jumpToPage(index);
    });
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
      final bytes =
          (sc != null && sc.hasClients && sc.position.maxScrollExtent > 0)
          ? await ScreenshotSaver.captureLong(
              scrollKey: _screenshotKey,
              scrollController: sc,
            )
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
          shadcn.Button.outline(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('退出'),
          ),
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

  void _handleBack(int currentIndex) {
    if (currentIndex == _searchPageIndex) {
      _closeSearchPage();
      return;
    }
    unawaited(_confirmExitApp());
  }

  // ── 抽屉 ──

  void _openDrawer() {
    if (context.isDesktop) {
      final notifier = ref.read(
        desktopNavigationSidebarVisibleProvider.notifier,
      );
      notifier.state = !notifier.state;
      return;
    }
    if (!mounted || _drawerOpening) return;
    _drawerOpening = true;
    unawaited(
      showGlobalDrawer(context, ref).whenComplete(() {
        _drawerOpening = false;
      }),
    );
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
    final showAdminUser = canOpenAdminUsers(authInfo);
    final updateState = ref.watch(updateProvider);
    final appUpgradeStatus = kIsWeb
        ? null
        : ref.watch(appUpgradeStatusProvider);
    final hasAppUpgrade = appUpgradeStatus?.valueOrNull?.hasNewVersion == true;
    final showNews = ref.watch(mediaInfoSettingsProvider).enabled;
    final unreadCount = ref.watch(noticeUnreadCountProvider);
    final notices =
        ref.watch(noticeHistoryProvider).valueOrNull ?? const <NoticeHistory>[];
    final unread = [
      for (final n in notices)
        if (!n.isRead) n,
    ];
    final colors = shadcn.Theme.of(context).colorScheme;
    if (context.isDesktop) {
      ref.watch(desktopNavigationSidebarVisibleProvider);
    }
    if (currentIndex < _primaryPageCount) {
      _lastPrimaryIndex = currentIndex;
    }
    final navigationIndex = currentIndex < _primaryPageCount
        ? currentIndex
        : _lastPrimaryIndex.clamp(0, _primaryPageCount - 1).toInt();
    final isSearchPage = currentIndex == _searchPageIndex;
    _syncPageController(currentIndex);

    if (!showNews && currentIndex == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go('/dashboard');
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(currentIndex);
      },
      child: EscapeBackScope(
        onBack: () => _handleBack(currentIndex),
        child: ShellScaffold(
          index: navigationIndex,
          onChange: _onTap,
          onSearchPress: _openSearchPage,
          dashboardChrome: false,
          showBottomControls: !isSearchPage,
          showNews: showNews,
          header: isSearchPage
              ? const SizedBox.shrink()
              : _ShellHeader(
                  title: _pageTitles[currentIndex],
                  subtitle: _pageSubtitles[currentIndex],
                  unreadCount: unreadCount,
                  unreadNotices: unread,
                  onOpenNotices: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const NoticeHistoryPage(),
                    ),
                  ),
                  onOpenDrawer: _openDrawer,
                  hasAppUpgrade: hasAppUpgrade,
                  onAppUpgrade: _openAppUpgradeFromHeader,
                  updateState: updateState,
                  avatar: _AccountMenuButton(
                    user: user,
                    showAdminUser: showAdminUser,
                    showAccountSwitcher:
                        ref.watch(loginHistoryProvider).length >= 2,
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
                  physics: const NeverScrollableScrollPhysics(),
                  children: _buildPages(),
                ),
              ),
              if (!kIsWeb)
                IgnorePointer(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AppUpgradePage(
                      controller: _appUpgradeController,
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
              if (_capturing)
                Positioned.fill(
                  child: ColoredBox(
                    color: colors.foreground.withValues(alpha: 0.08),
                    child: const Center(
                      child: shadcn.CircularProgressIndicator(strokeWidth: 2),
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

class _KeepAlivePage extends StatefulWidget {
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();

  const _KeepAlivePage({required this.child});
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
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
  final int unreadCount;
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
    required this.unreadCount,
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
    final hasUnread = unreadCount > 0;
    final canShowTicker = hasUnread && unreadNotices.isNotEmpty;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: cs.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
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
                    child: Icon(
                      shadcn.LucideIcons.panelLeft,
                      size: _headerActionIconSize,
                    ),
                  ),
                ),
              ],
              title: canShowTicker
                  ? _NoticeTicker(
                      notices: unreadNotices,
                      unreadCount: unreadCount,
                      onTap: onOpenNotices,
                    )
                  : Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.lead.copyWith(
                        color: cs.foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
              trailing: [
                if (!canShowTicker)
                  _HeaderNoticeButton(
                    unreadCount: unreadCount,
                    hasUnread: hasUnread,
                    onTap: onOpenNotices,
                  ),
                if (hasAppUpgrade)
                  _HeaderDotButton(
                    icon: shadcn.LucideIcons.circleArrowUp,
                    color: cs.destructive,
                    tooltip: '发现 APP 新版本',
                    onTap: onAppUpgrade,
                  ),
                if (updateState.hasAnyUpdate)
                  _HeaderBadgeButton(
                    icon: shadcn.LucideIcons.download,
                    count: updateState.updateCount,
                    tooltip: '发现程序更新',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpdatePage()),
                    ),
                  ),
                avatar,
                SizedBox(width: context.isMobile ? 0 : 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeTicker extends ConsumerStatefulWidget {
  final List<NoticeHistory> notices;
  final int unreadCount;
  final VoidCallback onTap;

  const _NoticeTicker({
    required this.notices,
    required this.unreadCount,
    required this.onTap,
  });

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
    final count = widget.unreadCount;
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
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: cs.destructive,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: cs.background, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        height: 1,
                        fontWeight: FontWeight.w700,
                      ),
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
                  final offset =
                      Tween<Offset>(
                        begin: const Offset(0.2, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      );
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
                              style: theme.typography.small.copyWith(
                                color: cs.foreground,
                                fontWeight: FontWeight.w700,
                              ),
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
                          style: theme.typography.xSmall.copyWith(
                            color: cs.mutedForeground,
                          ),
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
                    await ref
                        .read(noticeHistoryProvider.notifier)
                        .markRead(notice);
                  } catch (_) {
                    Toast.error('标记已读失败');
                  }
                },
                icon: Icon(
                  shadcn.LucideIcons.check,
                  size: 15,
                  color: cs.mutedForeground,
                ),
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

  const _HeaderNoticeButton({
    required this.unreadCount,
    required this.hasUnread,
    required this.onTap,
  });

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
              Icon(
                shadcn.LucideIcons.bell,
                size: _headerActionIconSize,
                color: cs.foreground,
              ),
              if (hasUnread)
                Positioned(
                  top: -2,
                  right: -8,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: cs.destructive,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: cs.background, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      display,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        height: 1,
                        fontWeight: FontWeight.w800,
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  顶栏小按钮（带角标 / 带圆点）
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// 带数字角标的按钮（程序更新）
class _HeaderBadgeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderBadgeButton({
    required this.icon,
    required this.count,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final display = count > 99 ? '99+' : '$count';
    final accent = cs.primary;

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
              _HeaderUpdateIconFrame(
                foreground: accent,
                background: accent.withValues(alpha: 0.14),
                borderColor: accent.withValues(alpha: 0.26),
                child: Icon(icon, size: 15, color: accent),
              ),
              Positioned(
                top: -3,
                right: -9,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: cs.chart4,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.background, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: cs.chart4.withValues(alpha: 0.22),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    display,
                    style: TextStyle(
                      color: cs.primaryForeground,
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

/// 带红圆点的按钮（APP 升级）
class _HeaderDotButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderDotButton({
    required this.icon,
    this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final accent = color ?? cs.destructive;

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
              _HeaderUpdateIconFrame(
                foreground: accent,
                background: accent.withValues(alpha: 0.12),
                borderColor: accent.withValues(alpha: 0.24),
                child: Icon(icon, size: 15, color: accent),
              ),
              Positioned(
                top: -1,
                right: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.background, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
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

class _HeaderUpdateIconFrame extends StatelessWidget {
  final Widget child;
  final Color foreground;
  final Color background;
  final Color borderColor;

  const _HeaderUpdateIconFrame({
    required this.child,
    required this.foreground,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(color: foreground, size: 15),
        child: child,
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
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: BorderRadius.circular(shadcn.Theme.of(context).radiusMd),
      ),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserManagementPage()),
                ),
              ),
              if (showAdminUser)
                _item(
                  context,
                  icon: shadcn.LucideIcons.shieldCheck,
                  title: '授权管理',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUserPage()),
                  ),
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
                  onTap: () => ref
                      .read(authNotifierProvider.notifier)
                      .logout(redirectTo: '/login-history'),
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
              _item(
                context,
                icon: shadcn.LucideIcons.palette,
                title: '主题设置',
                onTap: () => showThemeDialog(context),
              ),
              if (!kIsWeb)
                _item(
                  context,
                  icon: shadcn.LucideIcons.camera,
                  title: '截图分享',
                  onTap: onScreenshot,
                ),
              _item(
                context,
                icon: shadcn.LucideIcons.download,
                title: '程序更新',
                highlighted: updateState.hasAnyUpdate,
                trailing: updateState.hasAnyUpdate
                    ? _UpdateBadge(count: updateState.updateCount)
                    : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdatePage()),
                ),
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OptionPage()),
                ),
              ),
              _item(
                context,
                icon: shadcn.LucideIcons.scrollText,
                title: '日志中心',
                onTap: () => context.push('/log-center'),
              ),
              _item(
                context,
                icon: shadcn.LucideIcons.terminal,
                title: '日志浮窗',
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
    final style = c == null
        ? null
        : TextStyle(color: c, fontWeight: FontWeight.w700);
    return shadcn.MenuButton(
      onPressed: (_) => unawaited(Future<void>.sync(onTap)),
      child: SizedBox(
        width: 148,
        child: Row(
          children: [
            Icon(icon, size: 16, color: c),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
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
        style: TextStyle(
          color: color,
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
