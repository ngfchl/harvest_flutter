import 'package:get/get.dart';

import 'controller.dart';

class QBittorrentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QBittorrentController(Get.arguments));
  }
}
