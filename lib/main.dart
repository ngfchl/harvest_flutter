import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/storage/hive_manager.dart';
import 'core/storage/storage_keys.dart';
import 'core/theme/theme_storage.dart';
import 'modules/auth/auth_provider.dart';
import 'modules/notice/service/local_notice_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init();
  await ThemeStorage.init();
  // 初始化日志
  await AppLogger.init();
  // await AppLogger.init();
  // 固定写法，处理状态栏背景颜色透明问题
  AppLogger.debug("============尝试访问网络===========");
  var canConnectInternet = await HiveManager.get('canConnectInternet');
  if (!kIsWeb && (canConnectInternet == null || !canConnectInternet)) {
    try {
      final res = await Dio().get('https://www.baidu.com').timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) {
        AppLogger.debug("============尝试访问网络失败: ${res.statusCode}===========");
      } else {
        HiveManager.set('canConnectInternet', true);
        AppLogger.debug("============网络访问成功！${res.statusCode}===========");
      }
    } catch (e) {
      AppLogger.debug("============网络访问异常: $e===========");
    }
  } else {
    AppLogger.debug("============已有网络标记，跳过检测===========");
  }

  AppLogger.debug("============处理状态栏背景颜色透明问题===========");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  AppLogger.debug("============处理状态栏背景颜色透明问题完成===========");
  AppLogger.debug("============设置SystemUiMode为edgeToEdge===========");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  AppLogger.debug("============设置SystemUiMode为edgeToEdge完成===========");

  // 必须加上这一行。
  AppLogger.debug("============初始化窗口管理器===========");
  if (PlatformTool.isDesktopOS()) {
    await windowManager.ensureInitialized();

    double height = HiveManager.get('ScreenSizeHeight')?.toDouble() ?? 900;
    double width = HiveManager.get('ScreenSizeWidth')?.toDouble() ?? 1440;

    WindowOptions windowOptions = WindowOptions(
      size: Size(width, height),
      center: true,
      backgroundColor: Colors.transparent,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  AppLogger.debug("============窗口管理器初始化完成===========");
  final container = ProviderContainer();

  /// 🔥 恢复登录
  // 触发 auth 初始化（build 自动恢复）
  final authState = container.read(authNotifierProvider);

  // 如果已登录，先写入 token 再获取最新用户信息
  if (authState.loggedIn && authState.accessToken != null) {
    await HiveManager.set(StorageKeys.accessToken, authState.accessToken!);
    if (authState.refreshToken != null) {
      await HiveManager.set(StorageKeys.refreshToken, authState.refreshToken!);
    }
  }

  // ✅ 确认状态
  AppLogger.debug("启动 auth: ${container.read(authNotifierProvider).loggedIn}");
  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
  await LocalNoticeNotificationService.instance.handleLaunchNotificationTap();
  await Future.delayed(const Duration(seconds: 2), () {
    FlutterNativeSplash.remove();
  });
}
