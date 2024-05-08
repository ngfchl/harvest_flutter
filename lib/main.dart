import 'package:app_service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:harvest/utils/dio_util.dart';
import 'package:harvest/utils/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';

void main() async {
  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  await initDependencies();
  Get.testMode = false;

  // 注册 HomeController 控制器
  String? server = SPUtil.getLocalStorage('server');
  if (server == null || server.length <= 10) {
    SPUtil.setBool('isLogin', false);
  } else {
    await DioUtil().initialize(server);
  }
  // 强制竖屏
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // 固定写法，处理状态栏背景颜色
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> onInit(BuildContext context) async {
    //延迟3秒
    await Future.delayed(const Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final appService = Get.find<AppService>();
    return GetMaterialApp(
      title: "Harvest",
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: Get.testMode,
      initialRoute: AppPages.INITIAL,
      navigatorKey: Get.key,
      theme: appService.currentTheme,
      getPages: AppPages.routes,
      translations: Messages([
        AppServiceMessages().keys,
      ]),
      locale: const Locale('zh', 'CN'),
      fallbackLocale: const Locale('en', 'US'),
      onInit: () async {
        await onInit(context);
      },
    );
  }
}

Future<void> initDependencies() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  Get.put<SharedPreferences>(prefs);

  // 应用管理
  Get.lazyPut<AppService>(
    () => AppService(
      Get.find<SharedPreferences>(),
      supportedLanguages: const [
        LanguageEnum.zh,
        LanguageEnum.zhHk,
        LanguageEnum.zhMO,
        LanguageEnum.zhTW,
        LanguageEnum.en,
        LanguageEnum.enUK,
        LanguageEnum.enUS,
        LanguageEnum.de,
        LanguageEnum.ru,
        LanguageEnum.uk,
        LanguageEnum.be,
        LanguageEnum.kk,
        LanguageEnum.sr,
        LanguageEnum.fr,
        LanguageEnum.ja,
        LanguageEnum.ko,
        LanguageEnum.ar,
      ],
    ),
    fenix: true,
  );
}
