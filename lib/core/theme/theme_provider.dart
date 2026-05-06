import 'package:flutter/material.dart';
import 'package:harvest/core/theme/theme_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_theme.dart';
import 'theme_presets.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeState build() {
    _load();
    return  ThemeState(
      theme: AppThemes.blue,
      mode: ThemeMode.system,
    );
  }

  Future<void> _load() async {
    final themeName = await ThemeStorage.getTheme();
    final modeStr = await ThemeStorage.getMode();

    final theme = AppThemes.list.firstWhere(
          (t) => t.name == themeName,
      orElse: () => AppThemes.blue,
    );

    final mode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };

    state = ThemeState(theme: theme, mode: mode);
  }

  void setTheme(AppTheme theme) {
    state = ThemeState(
      theme: theme,
      mode: state.mode,
    );

    /// 💾 persist
    ThemeStorage.saveTheme(theme.name);
  }

  void setMode(ThemeMode mode) {
    state = ThemeState(
      theme: state.theme,
      mode: mode,
    );

    /// 💾 persist
    ThemeStorage.saveMode(mode.name);
  }
}