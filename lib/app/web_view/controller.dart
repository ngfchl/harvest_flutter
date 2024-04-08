import 'package:get/get.dart';
import 'package:harvest/app/home/pages/agg_search/models/torrent_info.dart';

import '../../utils/logger_helper.dart';
import '../home/pages/models/my_site.dart';
import '../home/pages/models/website.dart';

class WebViewPageController extends GetxController {
  late String url;
  late SearchTorrentInfo? info;
  late MySite mySite;
  late WebSite website;
  RxString pageTitle = ''.obs;
  bool isLoading = false;
  bool canGoBack = false;
  bool canGoForward = false;
  int progress = 0;

  @override
  void onInit() {
    Logger.instance.d(Get.arguments);
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
