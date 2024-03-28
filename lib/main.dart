import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:harvest/theme/theme.dart';
import 'package:harvest/utils/logger_helper.dart';
import 'package:harvest/utils/storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();
  // 初始化 持久化数据信息
  await SPUtil.getInstance();
  // 初始化插件前需要在runApp之前调用初始化代码
  WidgetsFlutterBinding.ensureInitialized();

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
        theme:  ThemeData.light(),
        darkTheme: ThemeData.dark(),
        // theme:  lightTheme,
        // darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        // navigatorKey: Get.key,
        getPages: AppPages.routes,
        routingCallback: (routing) {
          print('当前路由：${routing!.current.toString()}');
          // todo 先向服务器请求登录状态
          // 登录状态返回后，再判断是否需要跳转到登录页
          if (routing.current.toString() == Routes.HOME) {
            final isLogin = SPUtil.getBool('isLogin');
            Logger.instance.w(isLogin);
            Logger.instance.w(Routes.HOME);
            if (!isLogin!) {
              String msg = "用户未登录，跳转到登录页！";
              Logger.instance.w(msg);
              // Get.snackbar('提示', msg);
              // Get.toNamed(Routes.LOGIN);
            }
          }
        }),
  );
}
