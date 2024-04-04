import 'package:get/get.dart';
import 'package:harvest/app/home/pages/agg_search/models/torrent_info.dart';

import '../home/pages/models/my_site.dart';
import '../home/pages/models/website.dart';

class WebViewPageController extends GetxController {
  late String url;
  late TorrentInfo? info;
  late MySite mySite;
  late WebSite website;
  RxString pageTitle = ''.obs;

  @override
  void onInit() {
    print(Get.arguments);
    url = Get.arguments['url'];
    info = Get.arguments['info'];
    mySite = Get.arguments['mySite'];
    website = Get.arguments['website'];
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}