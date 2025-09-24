import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../utils/logger_helper.dart';
import '../home/pages/agg_search/controller.dart';
import '../home/pages/models/my_site.dart';
import '../home/pages/models/torrent_info.dart';
import '../home/pages/models/website.dart';

class WebViewPageController extends GetxController {
  late String url;
  late SearchTorrentInfo? info;
  late MySite? mySite;
  late WebSite? website;
  RxString pageTitle = ''.obs;
  bool isLoading = false;
  bool isTorrentPath = false;
  bool canGoBack = false;
  bool canGoForward = false;
  int progress = 0;

  @override
  void onInit() {
    Get.put(AggSearchController());

    Logger.instance.d(Get.arguments);
    url = Get.arguments['url'];
    info = Get.arguments['info'];
    mySite = Get.arguments['mySite'];
    website = Get.arguments['website'];
    isTorrentPath = checkTorrentPath(url);
    Logger.instance.d("种子页面：$isTorrentPath");
    super.onInit();
  }

  bool checkTorrentPath(String url) {
    // 获取当前页面的路径
    String pathName = WebUri(url).path;

    // 创建正则表达式
    RegExp regExp = RegExp(r'/torrents\D*\d+');
    // 检查路径是否符合正则表达式
    return pathName.startsWith('/details.php') ||
        pathName.contains('/torrent.php') ||
        pathName.contains('/views.php') ||
        pathName.contains('/Torrents/details') ||
        pathName.contains('/plugin_details.php') ||
        regExp.hasMatch(pathName);
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
