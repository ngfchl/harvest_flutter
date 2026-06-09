import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/platform/platform_tool.dart';
import 'package:harvest/core/utils/ui/responsive.dart';
import 'package:harvest/core/provider/app_auto_refresh_provider.dart';
import 'package:harvest/modules/auth/auth_provider.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:harvest/modules/shell/widgets/global_drawer_swipe_area.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:window_manager/window_manager.dart';
// ignore: implementation_imports
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations_en.dart';

import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'widgets/desktop_window_controls.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp>
    with WidgetsBindingObserver, WindowListener {
  late Brightness _platformBrightness;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  Timer? _foregroundRefreshTimer;
  Timer? _backgroundNoticeRefreshTimer;
  Timer? _windowSizeSaveTimer;
  Future<void>? _runningBackgroundNoticeRefresh;
  DateTime _lastBackgroundNoticeRefreshAt = DateTime.now();
  Size? _lastSavedWindowSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    if (PlatformTool.isDesktopOS()) {
      windowManager.addListener(this);
    }
    _scheduleCurrentRefreshTimer();
  }

  @override
  void dispose() {
    _foregroundRefreshTimer?.cancel();
    _backgroundNoticeRefreshTimer?.cancel();
    _windowSizeSaveTimer?.cancel();
    if (PlatformTool.isDesktopOS()) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_platformBrightness == brightness) return;
    setState(() => _platformBrightness = brightness);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      _backgroundNoticeRefreshTimer?.cancel();
      _backgroundNoticeRefreshTimer = null;
      _refreshForegroundDataIfDue();
      return;
    }

    _foregroundRefreshTimer?.cancel();
    _foregroundRefreshTimer = null;
    _scheduleBackgroundNoticeRefreshTimer();
  }

  @override
  void onWindowResize() {
    _scheduleWindowSizeSave();
  }

  @override
  void onWindowResized() {
    _windowSizeSaveTimer?.cancel();
    unawaited(_saveWindowSize());
  }

  @override
  void onWindowUnmaximize() {
    _scheduleWindowSizeSave();
  }

  @override
  void onWindowRestore() {
    _scheduleWindowSizeSave();
  }

  void _scheduleWindowSizeSave() {
    if (!PlatformTool.isDesktopOS()) return;
    _windowSizeSaveTimer?.cancel();
    _windowSizeSaveTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(_saveWindowSize());
    });
  }

  Future<void> _saveWindowSize() async {
    if (!PlatformTool.isDesktopOS()) return;

    try {
      // Windows 下增加额外的检查，避免在无效状态下读取尺寸
      if (await windowManager.isMinimized() ||
          await windowManager.isMaximized() ||
          await windowManager.isFullScreen()) {
        return;
      }

      final size = await windowManager.getSize();

      // 验证尺寸有效性
      if (size.width <= 0 || size.height <= 0) {
        debugPrint('窗口尺寸无效: ${size.width}x${size.height}');
        return;
      }

      // Windows 下检查尺寸是否合理
      if (PlatformTool.isWindows()) {
        if (size.width < 400 || size.height < 300) {
          debugPrint('窗口尺寸过小，跳过保存: ${size.width}x${size.height}');
          return;
        }
        if (size.width > 7680 || size.height > 4320) {
          debugPrint('窗口尺寸过大，跳过保存: ${size.width}x${size.height}');
          return;
        }
      }

      final normalized = Size(
        size.width.roundToDouble(),
        size.height.roundToDouble(),
      );
      if (_lastSavedWindowSize == normalized) return;

      _lastSavedWindowSize = normalized;
      await Future.wait([
        HiveManager.set(StorageKeys.windowSizeWidth, normalized.width.toInt()),
        HiveManager.set(
          StorageKeys.windowSizeHeight,
          normalized.height.toInt(),
        ),
      ]);
    } catch (error, stackTrace) {
      debugPrint('保存窗口尺寸失败: $error\n$stackTrace');
    }
  }

  void _refreshForegroundDataIfDue() {
    unawaited(ref.read(appAutoRefreshControllerProvider).refreshIfDue());
    _scheduleForegroundRefreshTimer();
  }

  void _scheduleForegroundRefreshTimer() {
    _foregroundRefreshTimer?.cancel();
    _backgroundNoticeRefreshTimer?.cancel();
    _backgroundNoticeRefreshTimer = null;
    if (_lifecycleState != AppLifecycleState.resumed) return;

    final delay = ref
        .read(appAutoRefreshControllerProvider)
        .timeUntilNextRefresh;

    _foregroundRefreshTimer = Timer(delay, () {
      if (!mounted || _lifecycleState != AppLifecycleState.resumed) return;
      unawaited(ref.read(appAutoRefreshControllerProvider).refreshIfDue());
      _scheduleForegroundRefreshTimer();
    });
  }

  Duration get _backgroundNoticeRefreshInterval {
    return Duration(minutes: ref.read(appAutoRefreshIntervalProvider));
  }

  Duration get _timeUntilBackgroundNoticeRefresh {
    final elapsed = DateTime.now().difference(_lastBackgroundNoticeRefreshAt);
    if (elapsed >= _backgroundNoticeRefreshInterval) return Duration.zero;
    return _backgroundNoticeRefreshInterval - elapsed;
  }

  void _scheduleBackgroundNoticeRefreshTimer() {
    _backgroundNoticeRefreshTimer?.cancel();
    if (_lifecycleState == AppLifecycleState.resumed) return;

    final delay = _timeUntilBackgroundNoticeRefresh;
    _backgroundNoticeRefreshTimer = Timer(delay, () {
      if (!mounted || _lifecycleState == AppLifecycleState.resumed) return;
      _markBackgroundNoticeRefreshStarted();
      unawaited(
        _refreshBackgroundNotices().whenComplete(() {
          if (!mounted || _lifecycleState == AppLifecycleState.resumed) return;
          _scheduleBackgroundNoticeRefreshTimer();
        }),
      );
    });
  }

  Future<void> _refreshBackgroundNotices() {
    final running = _runningBackgroundNoticeRefresh;
    if (running != null) return running;

    final next = ref.read(noticeHistoryProvider.notifier).refresh();
    _runningBackgroundNoticeRefresh = next.whenComplete(
      () => _runningBackgroundNoticeRefresh = null,
    );
    return _runningBackgroundNoticeRefresh!;
  }

  void _markBackgroundNoticeRefreshStarted() {
    _lastBackgroundNoticeRefreshAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appAutoRefreshIntervalProvider, (previous, next) {
      if (previous == next) return;
      _scheduleCurrentRefreshTimer();
    });
    ref.listen<int>(appAutoRefreshRevisionProvider, (previous, next) {
      if (previous == next) return;
      _scheduleCurrentRefreshTimer();
    });

    final themeState = ref.watch(themeNotifierProvider);
    final loggedIn = ref.watch(authNotifierProvider).loggedIn;

    return shadcn.ShadcnApp.router(
      debugShowCheckedModeBanner: false,

      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        return _GlobalKeyboardDismiss(
          child: DesktopWindowControlsOverlay(
            child: shadcn.DrawerOverlay(
              child: loggedIn ? _LoggedInAppChrome(child: content) : content,
            ),
          ),
        );
      },
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      supportedLocales: const [
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale('zh', 'CN'),
        Locale('zh'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        _AppShadcnLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      scaling: themeState.adaptiveScaling,
      materialTheme: themeState.materialTheme(switch (themeState.mode) {
        shadcn.ThemeMode.dark => Brightness.dark,
        shadcn.ThemeMode.light => Brightness.light,
        shadcn.ThemeMode.system => _platformBrightness,
      }),
      theme: themeState.shadcnLight,
      darkTheme: themeState.shadcnDark,
      themeMode: switch (themeState.mode) {
        shadcn.ThemeMode.dark => shadcn.ThemeMode.dark,
        shadcn.ThemeMode.light => shadcn.ThemeMode.light,
        shadcn.ThemeMode.system => shadcn.ThemeMode.system,
      },
    );
  }

  void _scheduleCurrentRefreshTimer() {
    if (_lifecycleState == AppLifecycleState.resumed) {
      _scheduleForegroundRefreshTimer();
      return;
    }
    _scheduleBackgroundNoticeRefreshTimer();
  }
}

class _LoggedInAppChrome extends ConsumerWidget {
  final Widget child;

  const _LoggedInAppChrome({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!context.isDesktop) {
      return GlobalDrawerSwipeArea(child: child);
    }
    final sidebarVisible = ref.watch(desktopNavigationSidebarVisibleProvider);

    return Row(
      children: [
        if (sidebarVisible)
          SizedBox(
            width: 260,
            child: GlobalNavigationSidebar(ref: ref, persistent: true),
          ),
        Expanded(child: child),
      ],
    );
  }
}

class _GlobalKeyboardDismiss extends StatefulWidget {
  final Widget child;

  const _GlobalKeyboardDismiss({required this.child});

  @override
  State<_GlobalKeyboardDismiss> createState() => _GlobalKeyboardDismissState();
}

class _GlobalKeyboardDismissState extends State<_GlobalKeyboardDismiss> {
  static const _tapSlop = 18.0;
  static const _longPressGuard = Duration(milliseconds: 420);

  int? _tapPointer;
  Offset? _tapDownPosition;
  DateTime? _tapDownAt;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _tapPointer = event.pointer;
        _tapDownPosition = event.position;
        _tapDownAt = DateTime.now();
      },
      onPointerMove: (event) {
        if (_tapPointer != event.pointer) return;
        final down = _tapDownPosition;
        if (down != null && (event.position - down).distance > _tapSlop) {
          _clearTapCandidate();
        }
      },
      onPointerCancel: (_) => _clearTapCandidate(),
      onPointerUp: (event) {
        if (_tapPointer != event.pointer) return;
        final down = _tapDownPosition;
        final downAt = _tapDownAt;
        _clearTapCandidate();
        if (down == null || downAt == null) return;
        if ((event.position - down).distance > _tapSlop) return;
        if (DateTime.now().difference(downAt) >= _longPressGuard) return;
        _dismissForTap(event.position);
      },
      child: widget.child,
    );
  }

  void _clearTapCandidate() {
    _tapPointer = null;
    _tapDownPosition = null;
    _tapDownAt = null;
  }

  void _dismissForTap(Offset position) {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return;
    final focusedContext = focus.context;
    if (focusedContext == null) {
      _unfocusAfterGesture(focus);
      return;
    }
    final render = focusedContext.findRenderObject();
    if (render is! RenderBox) {
      _unfocusAfterGesture(focus);
      return;
    }
    final local = render.globalToLocal(position);
    if (!render.size.contains(local)) {
      _unfocusAfterGesture(focus);
    }
  }

  void _unfocusAfterGesture(FocusNode focus) {
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (FocusManager.instance.primaryFocus == focus && focus.hasFocus) {
          focus.unfocus();
        }
      }),
    );
  }
}

class _AppShadcnLocalizationsDelegate
    extends LocalizationsDelegate<shadcn.ShadcnLocalizations> {
  const _AppShadcnLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'zh' || locale.languageCode == 'en';

  @override
  Future<shadcn.ShadcnLocalizations> load(Locale locale) {
    return SynchronousFuture<shadcn.ShadcnLocalizations>(
      locale.languageCode == 'zh'
          ? _AppShadcnLocalizationsZh(locale.toString())
          : ShadcnLocalizationsEn(locale.toString()),
    );
  }

  @override
  bool shouldReload(_AppShadcnLocalizationsDelegate old) => false;
}

class _AppShadcnLocalizationsZh extends ShadcnLocalizationsEn {
  _AppShadcnLocalizationsZh(super.locale);

  @override
  String get menuCut => '剪切';

  @override
  String get menuCopy => '复制';

  @override
  String get menuPaste => '粘贴';

  @override
  String get menuSelectAll => '全选';

  @override
  String get menuUndo => '撤销';

  @override
  String get menuRedo => '重做';

  @override
  String get menuDelete => '删除';

  @override
  String get menuShare => '分享';

  @override
  String get menuSearchWeb => '网页搜索';

  @override
  String get menuLiveTextInput => '扫描文本';
}
