import 'package:get/get.dart';

import 'controller.dart';

class TrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TrController(Get.arguments));
  }
}
