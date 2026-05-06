import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/theme/theme_presets.dart';

class ThemeState {
  final AppTheme theme;
  final ThemeMode mode;

  const ThemeState({required this.theme, required this.mode});

  // 转 JSON
  Map<String, dynamic> toJson() {
    return {
      'theme': theme.toJson(),
      'mode': mode.index, // 存索引
    };
  }

  // 从 JSON 解析
  factory ThemeState.fromJson(Map<String, dynamic> json) {
    return ThemeState(theme: AppTheme.fromJson(json['theme']), mode: ThemeMode.values[json['mode']]);
  }
}

class AppTheme {
  final String name;
  final Color seedColor;
  final FThemeData light;
  final FThemeData dark;

  const AppTheme({required this.name, required this.seedColor, required this.light, required this.dark});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'seedColor': seedColor.value, // 存 int 色值
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    // 从 AppThemes.list 里匹配 name 取出对应主题
    return AppThemes.list.firstWhere((e) => e.name == json['name'], orElse: () => AppThemes.blue);
  }
}
