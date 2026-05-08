import 'package:hive/hive.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'app_theme.dart';
import 'theme_presets.dart';

class ThemeStorage {
  static const _boxName = 'settings';
  static const _themeKey = 'theme';
  static const _modeKey = 'mode';
  static const _themeStateKey = 'theme_state';

  static Future<void> init() async {
    if (Hive.isBoxOpen(_boxName)) return;
    await Hive.openBox(_boxName);
  }

  static Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    return await Hive.openBox(_boxName);
  }

  static Box? _boxSync() {
    if (!Hive.isBoxOpen(_boxName)) return null;
    return Hive.box(_boxName);
  }

  static Future<void> saveTheme(String name) async {
    final box = await _box();
    await box.put(_themeKey, name);
  }

  static Future<void> saveMode(String mode) async {
    final box = await _box();
    await box.put(_modeKey, mode);
  }

  static Future<void> saveState(ThemeState state) async {
    final box = await _box();
    await box.put(_themeStateKey, state.toJson());
    await box.put(_themeKey, state.theme.name);
    await box.put(_modeKey, state.mode.name);
  }

  static Future<String?> getTheme() async {
    final box = await _box();
    return box.get(_themeKey);
  }

  static String? getThemeSync() {
    final box = _boxSync();
    return box?.get(_themeKey);
  }

  static Future<String?> getMode() async {
    final box = await _box();
    return box.get(_modeKey);
  }

  static String? getModeSync() {
    final box = _boxSync();
    return box?.get(_modeKey);
  }

  static Future<ThemeState?> getState() async {
    final box = await _box();
    final raw = box.get(_themeStateKey);
    if (raw is Map) {
      return ThemeState.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static ThemeState? getStateSync() {
    final box = _boxSync();
    final raw = box?.get(_themeStateKey);
    if (raw is Map) {
      return ThemeState.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static ThemeState getPersistedStateSync() {
    final savedState = getStateSync();
    if (savedState != null) return savedState;

    final themeName = getThemeSync();
    final modeStr = getModeSync();
    if (themeName == null && modeStr == null) {
      return const ThemeState();
    }

    final theme = AppThemes.byName(themeName);
    final mode = switch (modeStr) {
      'light' => shadcn.ThemeMode.light,
      'dark' => shadcn.ThemeMode.dark,
      'system' => shadcn.ThemeMode.system,
      _ => shadcn.ThemeMode.system,
    };

    return ThemeState(
      baseScheme: theme.baseScheme,
      accent: theme.accent,
      mode: mode,
    );
  }
}
