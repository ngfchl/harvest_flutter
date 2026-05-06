import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'core/theme/theme_provider.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late Brightness _platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  @override
  void dispose() {
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
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      routerConfig: ref.watch(routerProvider),
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      supportedLocales: const [
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
        Locale('zh', 'CN'),
        Locale('zh'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      theme: themeState.theme.light.toApproximateMaterialTheme(),

      darkTheme: themeState.theme.dark.toApproximateMaterialTheme(),
      themeMode: themeState.mode,
      builder: (context, child) {
        final s = themeState;

        final brightness = switch (s.mode) {
          ThemeMode.dark => Brightness.dark,
          ThemeMode.light => Brightness.light,
          ThemeMode.system => _platformBrightness,
        };

        final fTheme = brightness == Brightness.dark
            ? s.theme.dark
            : s.theme.light;

        return FTheme(data: fTheme, child: child!);
      },
    );
  }
}
