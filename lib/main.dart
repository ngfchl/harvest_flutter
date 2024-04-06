import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/utils/dio_util.dart';
import 'package:harvest/utils/storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsFlutterBinding.ensureInitialized();

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
  runApp(
    GetMaterialApp(
      title: "Harvest",
      defaultTransition: Transition.cupertino,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      navigatorKey: Get.key,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // theme: lightTheme,
      // darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      getPages: AppPages.routes,
    ),
  );
}
