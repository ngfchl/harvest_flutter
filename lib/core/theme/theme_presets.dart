import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'app_theme.dart';

class AppThemes {
  // 蓝色主题
  static final blue = AppTheme(
    name: 'blue',
    seedColor: const Color(0xFF2196F3),
    light: FThemes.blue.light,
    dark: FThemes.blue.dark,
  );

  // 黄色主题
  static final yellow = AppTheme(
    name: 'yellow',
    seedColor: const Color(0xFFFFC107),
    light: FThemes.yellow.light,
    dark: FThemes.yellow.dark,
  );

  // 玫瑰粉主题
  static final rose = AppTheme(
    name: 'rose',
    seedColor: const Color(0xFFE91E63),
    light: FThemes.rose.light,
    dark: FThemes.rose.dark,
  );

  // 绿色主题
  static final green = AppTheme(
    name: 'green',
    seedColor: const Color(0xFF4CAF50),
    light: FThemes.green.light,
    dark: FThemes.green.dark,
  );

  // 橙色主题
  static final orange = AppTheme(
    name: 'orange',
    seedColor: const Color(0xFFFF9800),
    light: FThemes.orange.light,
    dark: FThemes.orange.dark,
  );

  // 紫罗兰主题
  static final violet = AppTheme(
    name: 'violet',
    seedColor: const Color(0xFF673AB7),
    light: FThemes.violet.light,
    dark: FThemes.violet.dark,
  );

  // 红色主题
  static final red = AppTheme(
    name: 'red',
    seedColor: const Color(0xFFF44336),
    light: FThemes.red.light,
    dark: FThemes.red.dark,
  );

  // 锌灰（中性灰）主题
  static final zinc = AppTheme(
    name: 'zinc',
    seedColor: const Color(0xFF607D8B),
    light: FThemes.zinc.light,
    dark: FThemes.zinc.dark,
  );

  // 所有主题列表
  static final list = [blue, yellow, rose, green, orange, violet, red, zinc];
}
