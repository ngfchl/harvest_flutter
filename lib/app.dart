import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/provider/app_auto_refresh_provider.dart';
import 'package:harvest/modules/notice/provider/notice_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
// ignore: implementation_imports
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations_en.dart';

import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late Brightness _platformBrightness;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  Timer? _foregroundRefreshTimer;
  Timer? _backgroundNoticeRefreshTimer;
  Future<void>? _runningBackgroundNoticeRefresh;
  DateTime _lastBackgroundNoticeRefreshAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    _scheduleCurrentRefreshTimer();
  }

  @override
  void dispose() {
    _foregroundRefreshTimer?.cancel();
    _backgroundNoticeRefreshTimer?.cancel();
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

    return shadcn.ShadcnApp.router(
      debugShowCheckedModeBanner: false,

      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => _GlobalKeyboardDismiss(
        child: shadcn.DrawerOverlay(child: child ?? const SizedBox.shrink()),
      ),
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

class _GlobalKeyboardDismiss extends StatelessWidget {
  final Widget child;

  const _GlobalKeyboardDismiss({required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final focus = FocusManager.instance.primaryFocus;
        if (focus == null) return;
        final focusedContext = focus.context;
        if (focusedContext == null) {
          focus.unfocus();
          return;
        }
        final render = focusedContext.findRenderObject();
        if (render is! RenderBox) {
          focus.unfocus();
          return;
        }
        final local = render.globalToLocal(event.position);
        if (!render.size.contains(local)) {
          focus.unfocus();
        }
      },
      child: child,
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
