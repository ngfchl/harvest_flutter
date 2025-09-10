import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../utils/storage.dart';

class ThemeController extends GetxController {
  /// 是否暗黑模式（仅当 followSystem == false 时生效）
  var isDark = false.obs;

  /// 是否跟随系统
  var followSystem = true.obs;

  /// 当前颜色方案名称
  var colorSchemeName = "slate".obs;

  final Map<String, String> shadThemeColorNames = {
    'blue': '蓝色',
    'gray': '灰色',
    'green': '绿色',
    'neutral': '中性',
    'orange': '橙色',
    'red': '红色',
    'rose': '玫瑰',
    'slate': '石板',
    'stone': '石头',
    'violet': '紫罗兰',
    'yellow': '黄色',
    'zinc': '锌色',
  };

  /// 主题模式
  ThemeMode get themeMode {
    if (followSystem.value) return ThemeMode.system;
    return isDark.value ? ThemeMode.dark : ThemeMode.light;
  }

  ShadThemeData get lightTheme => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadColorScheme.fromName(colorSchemeName.value),
      );

  ShadThemeData get darkTheme => ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadColorScheme.fromName(
          colorSchemeName.value,
          brightness: Brightness.dark,
        ),
      );

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void toggleDarkMode() {
    if (followSystem.value) return; // 跟随系统时禁止手动切换
    isDark.value = !isDark.value;
    _saveTheme();
  }

  void changeColorScheme(String name) {
    colorSchemeName.value = name;
    _saveTheme();
  }

  void toggleFollowSystem(bool value) {
    followSystem.value = value;
    if (followSystem.value) {
      isDark.value = Get.isDarkMode;
      toggleDarkMode();
    }
    _saveTheme();
  }

  void _loadTheme() {
    isDark.value = SPUtil.getBool("isDark", defaultValue: false);
    followSystem.value = SPUtil.getBool("followSystem", defaultValue: true);
    colorSchemeName.value =
        SPUtil.getString("colorSchemeName", defaultValue: "slate");
  }

  void _saveTheme() {
    SPUtil.setBool("isDark", isDark.value);
    SPUtil.setBool("followSystem", followSystem.value);
    SPUtil.setString("colorSchemeName", colorSchemeName.value);
  }
}
