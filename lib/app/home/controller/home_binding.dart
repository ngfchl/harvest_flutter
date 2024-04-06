import 'package:get/get.dart';
import 'package:harvest/app/home/pages/download/download_controller.dart';
import 'package:harvest/app/home/pages/my_site/controller.dart';
import 'package:harvest/app/home/pages/task/controller.dart';

import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // 注册 MySiteController 控制器
    Get.put(MySiteController());
    Get.lazyPut(() => TaskController());
    Get.lazyPut(() => DownloadController());
  }
}
