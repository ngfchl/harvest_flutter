import 'package:get/get.dart';

import 'torrent_controller.dart';

class TorrentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TorrentController>(
      () => TorrentController(),
    );
  }
}
