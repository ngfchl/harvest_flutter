import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../utils/logger_helper.dart';
import '../utils/storage.dart';
import 'color_storage.dart';

class ThemeController extends GetxController {
// 当前的颜色配置
  var colorConfig = SiteColorConfig.load(ShadColorScheme.fromName("orange")).obs;

  // 主题相关
  var isDark = false.obs;
  var followSystem = true.obs;
  var colorSchemeName = "orange".obs;
  var replaceBackgroundImage = false;
  var siteCardView = false;

  // 背景相关
  var useBackground = false.obs;
  var useImageProxy = false.obs;
  var useLocalBackground = false.obs;
  var backgroundImage = ''.obs;
  var blur = 0.0.obs;
  var opacity = 0.7.obs;
  var tmdbCardWidth = 120.0.obs;
  var useImageCache = true.obs;

  final Map<String, String> shadThemeColorNames = {
    'blue': '蓝色',
    'green': '绿色',
    'orange': '橙色',
    'red': '红色',
    'rose': '玫瑰',
    'violet': '紫罗兰',
    'yellow': '黄色',
  };

  // 主题模式
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
    _loadThemeAndBackground();
  }

  Future<void> toggleDarkMode() async {
    if (followSystem.value) return; // 跟随系统时禁止手动切换
    isDark.value = !isDark.value;
    await saveSettings();
  }

  Future<void> changeColorScheme(String name) async {
    colorSchemeName.value = name;
    colorConfig.value = SiteColorConfig.load(ShadColorScheme.fromName(name));
    await saveSettings();
  }

  Future<void> toggleFollowSystem(bool value) async {
    followSystem.value = value;
    if (followSystem.value) {
      isDark.value = Get.isDarkMode;
    }
    await saveSettings();
  }

  // 背景相关设置
  Future<void> toggleUseBackground(bool value) async {
    useBackground.value = value;
    await saveSettings();
  }

  Future<void> changeBackgroundImage(String url) async {
    backgroundImage.value = url;
    await saveSettings();
  }

  Future<void> setBackgroundBlur(double value) async {
    blur.value = value;
    await saveSettings();
  }

  Future<void> setBackgroundOpacity(double value) async {
    opacity.value = value;
    await saveSettings();
  }

  Future<void> toggleImageCache(bool value) async {
    useImageCache.value = value;
    await saveSettings();
  }

  // 获取默认配置
  Map<String, dynamic> getDefaultConfig() {
    return {
      "isDark": false, // 默认暗黑模式为关闭
      "followSystem": true, // 默认跟随系统
      "colorSchemeName": "orange", // 默认使用橙色配色
      "useBackground": false, // 默认不使用背景
      "useImageProxy": false, // 默认不使用图片代理
      "useLocalBackground": false, // 默认不使用本地背景
      "backgroundImage": 'https://cci1.yiimii.com/uploads/2023/11/20231114005921427.jpg', // 默认背景图片
      "backgroundBlur": 0.0, // 默认背景模糊度为 0
      "cardOpacity": 0.7, // 默认透明度为 0.7
      "useImageCache": true, // 默认使用图片缓存
      "tmdbCardWidth": 120.0,
    };
  }

  // 导出当前配置为 Map
  Map<String, dynamic> exportConfig() {
    return {
      "isDark": isDark.value,
      "followSystem": followSystem.value,
      "colorSchemeName": colorSchemeName.value,
      "useBackground": useBackground.value,
      "useImageProxy": useImageProxy.value,
      "useLocalBackground": useLocalBackground.value,
      "backgroundImage": backgroundImage.value,
      "backgroundBlur": blur.value,
      "cardOpacity": opacity.value,
      "useImageCache": useImageCache.value,
      "tmdbCardWidth": tmdbCardWidth.value,
    };
  }

  /// 从剪贴板导入配色方案
  Future<CommonResponse> importFromClipboard() async {
    try {
      // 1️⃣ 读取剪贴板
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;

      if (text == null || text.trim().isEmpty) {
        return CommonResponse.error(msg: "剪贴板为空");
      }

      // 2️⃣ JSON 解析
      final decoded = jsonDecode(text);
      // 3️⃣ 类型校验
      if (decoded is! Map<String, dynamic>) {
        return CommonResponse.error(msg: "剪贴板内容不是标准的主题格式：${decoded.runtimeType}");
      }
      // 4️⃣ 写入（复用 save）
      fromMap(decoded);
      if (decoded.containsKey('color_config')) {
        Map<String, dynamic> theme = Map<String, dynamic>.from(decoded['color_config'] ?? {});
        return await SiteColorConfig.save(scheme: ShadColorScheme.fromName(colorSchemeName.value), theme: theme);
      } else {
        return await SiteColorConfig.save(scheme: ShadColorScheme.fromName(colorSchemeName.value), theme: decoded);
      }
    } catch (e, trace) {
      String error = '主题导入失败：${e.toString()}';
      Logger.instance.e(error);
      Logger.instance.e(trace);
      return CommonResponse.error(msg: error);
    }
  }

  /// 导出当前配色到剪贴板（JSON）
  Future<String> exportToClipboard(bool flag) async {
    // 1️⃣ load 当前完整配置
    final scheme = ShadColorScheme.fromName(colorSchemeName.value);
    final currentColorTheme = SiteColorConfig.load(scheme);
    Map<String, dynamic> theme = {};
    if (flag) {
      final currentTheme = exportConfig();
      // 2️⃣ 转 Map
      theme = {
        ...currentTheme,
        "color_config": currentColorTheme.toJson(),
      };
    } else {
      theme = currentColorTheme.toJson();
    }

    // 3️⃣ JSON 编码（可读格式，方便用户）
    final json = const JsonEncoder.withIndent('  ').convert(theme);

    // 4️⃣ 写入剪贴板
    await Clipboard.setData(ClipboardData(text: json));

    return json;
  }

  // 获取并应用默认配置
  Future<void> applyDefaultConfig() async {
    // 获取默认配置
    Map<String, dynamic> defaultConfig = getDefaultConfig();

    // 应用默认主题配置
    fromMap(defaultConfig);

    // 保存默认配置
    await saveSettings();
  }

  void _loadThemeAndBackground() {
    isDark.value = SPUtil.getBool("isDark", defaultValue: false);
    followSystem.value = SPUtil.getBool("followSystem", defaultValue: true);
    colorSchemeName.value = SPUtil.getString("colorSchemeName", defaultValue: "orange");
    siteCardView = SPUtil.getBool('mySite-siteCardView', defaultValue: false);
    useBackground.value = SPUtil.getBool('useBackground', defaultValue: false);
    useImageProxy.value = SPUtil.getBool('useImageProxy', defaultValue: false);
    useLocalBackground.value = SPUtil.getBool('useLocalBackground', defaultValue: false);
    blur.value = SPUtil.getDouble('backgroundBlur', defaultValue: 0);
    opacity.value = SPUtil.getDouble('cardOpacity', defaultValue: 0.7);
    useImageCache.value = SPUtil.getBool('useImageCache', defaultValue: true);
    tmdbCardWidth.value = SPUtil.getDouble('tmdb_media_item_width', defaultValue: 120.0);
    backgroundImage.value = SPUtil.getString(
      'backgroundImage',
      defaultValue: 'https://cci1.yiimii.com/uploads/2023/11/20231114005921427.jpg',
    );
  }

  // 从 Map 读取主题配置并更新
  Future<void> fromMap(Map<String, dynamic> configMap) async {
    // 更新主题设置
    if (configMap.containsKey("isDark")) {
      isDark.value = configMap["isDark"];
    }
    if (configMap.containsKey("followSystem")) {
      followSystem.value = configMap["followSystem"];
    }
    if (configMap.containsKey("colorSchemeName")) {
      colorSchemeName.value = configMap["colorSchemeName"];
      colorConfig.value = SiteColorConfig.load(ShadColorScheme.fromName(colorSchemeName.value));
    }

    // 更新背景设置
    if (configMap.containsKey('useBackground')) {
      useBackground.value = configMap['useBackground'];
    }
    if (configMap.containsKey('useImageProxy')) {
      useImageProxy.value = configMap['useImageProxy'];
    }
    if (configMap.containsKey('useLocalBackground')) {
      useLocalBackground.value = configMap['useLocalBackground'];
    }
    if (!useLocalBackground.value) {
      if (replaceBackgroundImage &&
          configMap.containsKey('backgroundImage') &&
          configMap['backgroundImage'].isNotEmpty) {
        backgroundImage.value = configMap['backgroundImage'];
      }
    }
    if (configMap.containsKey('backgroundBlur')) {
      blur.value = configMap['backgroundBlur'];
    }
    if (configMap.containsKey('cardOpacity')) {
      opacity.value = configMap['cardOpacity'];
    }
    if (configMap.containsKey('useImageCache')) {
      useImageCache.value = configMap['useImageCache'];
    }
    if (configMap.containsKey('tmdb_media_item_width')) {
      tmdbCardWidth.value = configMap['tmdb_media_item_width'];
    }

    // 保存更改
    await saveSettings();
  }

  Future<void> saveSettings() async {
    Logger.instance.d("Save暗黑模式：${isDark.value}");
    await SPUtil.setBool("isDark", isDark.value);
    await SPUtil.setBool("followSystem", followSystem.value);
    await SPUtil.setString("colorSchemeName", colorSchemeName.value);

    // 背景相关设置保存
    await SPUtil.setBool('useBackground', useBackground.value);
    await SPUtil.setBool('useLocalBackground', useLocalBackground.value);
    await SPUtil.setBool('useImageProxy', useImageProxy.value);
    await SPUtil.setBool('useImageCache', useImageCache.value);
    await SPUtil.setString('backgroundImage', backgroundImage.value);
    await SPUtil.setDouble('cardOpacity', opacity.value);
    await SPUtil.setDouble('backgroundBlur', blur.value);
    await SPUtil.setDouble('tmdb_media_item_width', tmdbCardWidth.value);
  }
}
