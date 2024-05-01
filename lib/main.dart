import 'package:app_service/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/utils/dio_util.dart';
import 'package:harvest/utils/storage.dart';

import 'app/routes/app_pages.dart';
import 'app_service_basic/get_it_injections.dart';

void main() async {
  await GetStorage.init();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  GetItInjection.init();

  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  initialization(null);
  // 注册 HomeController 控制器
  String? server = GetStorage().read('server');
  if (server == null || server.length <= 10) {
    GetStorage().write('isLogin', false);
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
  runApp(
    GetMaterialApp(
      title: "Harvest",
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      navigatorKey: Get.key,
      themeMode: ThemeMode.light,
      getPages: AppPages.routes,
      onInit: () async {
        await onInit();
      },
    ),
  );
}

//启动图延时移除方法
void initialization(BuildContext? context) async {
  //延迟3秒
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();
}

Future<void> onInit() async {
  final appService = GetIt.instance.get<AppService>();
  await appService.init();
}
