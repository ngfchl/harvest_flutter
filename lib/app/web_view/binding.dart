import 'package:get/get.dart';

import 'controller.dart';

class WebViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WebViewPageController());
  }
}
