import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/dio_util.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:harvest/utils/storage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:window_manager/window_manager.dart';

import 'app/routes/app_pages.dart';
import 'theme/theme_controller.dart';

void main() async {
  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsFlutterBinding.ensureInitialized();
  Logger.instance.i("============初始化项目依赖===========");
  await initDependencies();
  Logger.instance.i("============项目依赖初始化完成===========");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.put<ThemeController>(ThemeController());
    Logger.instance.d("暗黑模式：${themeController.isDark.value}");
    Logger.instance.d("暗黑模式：${Get.isDarkMode}");
    Logger.instance.d("暗黑模式：${SPUtil.getBool('isDark')}");

    return Obx(() {
      return ShadApp.custom(
          darkTheme: themeController.darkTheme,
          theme: themeController.lightTheme,
          themeMode: themeController.themeMode,
          appBuilder: (context) {
            return GetMaterialApp(
              title: "Harvest",
              defaultTransition: Transition.cupertino,
              debugShowCheckedModeBanner: Get.testMode,
              initialRoute: AppPages.INITIAL,
              navigatorKey: Get.key,
              getPages: AppPages.routes,
              builder: (context, child) {
                // 处理 MediaQuery 异常问题，特别是小米澎湃系统
                MediaQueryData mediaQuery = MediaQuery.of(context);
                double safeTop = mediaQuery.padding.top;

                // 如果出现异常值，使用默认值替代
                if (safeTop > 80 || safeTop < 0) {
                  print('Detected abnormal top padding: $safeTop, using fallback.');
                  safeTop = 24.0; // 合理默认值
                }

                return MediaQuery(
                  data: mediaQuery.copyWith(
                    padding: mediaQuery.padding.copyWith(top: safeTop),
                  ),
                  child: ShadToaster(child: child ?? const SizedBox.shrink()),
                );
              },
              locale: const Locale('zh', 'CN'),
              fallbackLocale: const Locale('en', 'US'),
              onReady: () async {
                await Future.delayed(const Duration(seconds: 3));
                FlutterNativeSplash.remove();
              },
            );
          });
    });
  }
}

Future<void> initDependencies() async {
  /// 必须调用这行！

  Logger.instance.i("============初始化MediaKit===========");
  MediaKit.ensureInitialized();
  Logger.instance.i("============MediaKit初始化完成===========");
  // 初始化 持久化数据信息
  Logger.instance.i("============初始化SharedPreferences===========");
  await SPUtil.getInstance();
  Logger.instance.i("============SharedPreferences初始化完成===========");

  Get.testMode = false;

  Logger.instance.i("============初始化DioUtil===========");
  String? server = SPUtil.getLocalStorage('server');
  if (server == null || server.length <= 10) {
    SPUtil.setBool('isLogin', false);
  } else {
    await DioUtil().initialize(server);
  }
  Logger.instance.i("============DioUtil初始化完成===========");
  // 强制竖屏
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // 固定写法，处理状态栏背景颜色透明问题
  Logger.instance.i("============处理状态栏背景颜色透明问题===========");
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  Logger.instance.i("============处理状态栏背景颜色透明问题完成===========");
  // 必须加上这一行。
  Logger.instance.i("============初始化窗口管理器===========");
  if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
    await windowManager.ensureInitialized();
    double height = SPUtil.getDouble('ScreenSizeHeight', defaultValue: 900).toDouble();
    double width = SPUtil.getDouble('ScreenSizeWidth', defaultValue: 1200).toDouble();
    Logger.instance.d('已缓存的窗口大小: $width, $height');
    WindowOptions windowOptions = WindowOptions(
      size: Size(width, height),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
  Logger.instance.i("============窗口管理器初始化完成===========");
  // await Future.delayed(Duration(milliseconds: 3000), () {
  // FlutterNativeSplash.remove();
  // });
  Logger.instance.i("============设置SystemUiMode为edgeToEdge===========");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  Logger.instance.i("============设置SystemUiMode为edgeToEdge完成===========");
}
