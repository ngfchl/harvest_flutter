import 'package:get/get.dart';

import 'controller.dart';

class TorrentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TorrentController>(
      () => TorrentController(Get.arguments, true),
    );
  }
}
