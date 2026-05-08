import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return shadcn.ShadcnApp.router(
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
        _AppShadcnLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],

      scaling: themeState.adaptiveScaling,
      materialTheme: themeState.materialTheme(
        switch (themeState.mode) {
          shadcn.ThemeMode.dark => Brightness.dark,
          shadcn.ThemeMode.light => Brightness.light,
          shadcn.ThemeMode.system => _platformBrightness,
        },
      ),
      theme: themeState.shadcnLight,
      darkTheme: themeState.shadcnDark,
      themeMode: switch (themeState.mode) {
        shadcn.ThemeMode.dark => shadcn.ThemeMode.dark,
        shadcn.ThemeMode.light => shadcn.ThemeMode.light,
        shadcn.ThemeMode.system => shadcn.ThemeMode.system,
      },
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
      ShadcnLocalizationsEn(locale.toString()),
    );
  }

  @override
  bool shouldReload(_AppShadcnLocalizationsDelegate old) => false;
}
