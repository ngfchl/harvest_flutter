import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/utils/dio_util.dart';
import 'package:harvest/utils/storage.dart';

import 'app/home/home_controller.dart';
import 'app/home/pages/controller/download_controller.dart';
import 'app/home/pages/my_site/controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsFlutterBinding.ensureInitialized();
  // 注册 HomeController 控制器
  await DioUtil().initialize(GetStorage().read('server'));
  Get.put(HomeController());

  // 注册 MySiteController 控制器
  Get.put(MySiteController());
  Get.put(DownloadController());
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // theme: lightTheme,
      // darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      getPages: AppPages.routes,
    ),
  );
}
