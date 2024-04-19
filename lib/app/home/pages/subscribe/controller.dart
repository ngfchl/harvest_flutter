import 'package:get/get.dart';

import '../../../../api/sub.dart';
import '../../../../common/meta_item.dart';
import '../../../../models/common_response.dart';
import '../../../../models/download.dart';
import '../../../../utils/logger_helper.dart';
import '../../../torrent/torrent_controller.dart';
import '../download/download_controller.dart';
import '../models/SubTag.dart';
import '../models/Subscribe.dart';
import '../my_rss/controller.dart';
import '../subscribe_tag/controller.dart';

class SubscribeController extends GetxController {
  SubscribeTagController subTagController = Get.put(SubscribeTagController());
  MyRssController rssController = Get.put(MyRssController());
  DownloadController downloadController = Get.find();

  List<Subscribe> subList = [];
  List<MetaDataItem> tagCategoryList = [];
  List<SubTag> tags = [];
  List<Downloader> downloaderList = <Downloader>[];
  bool isDownloaderLoading = false;

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await subTagController.initData();
    await rssController.initData();
    await downloadController.getDownloaderListFromServer();
    tagCategoryList = subTagController.tagCategoryList;
    tags = subTagController.tags.where((e) => e.available == true).toList();
    downloaderList = downloadController.dataList;
    Logger.instance.i(tags
        .where((element) =>
            element.available == true && element.category == 'discount')
        .map((e) => e.name!)
        .toList());
    Logger.instance.i(downloaderList);
    Logger.instance.i(tagCategoryList);
    await getSubscribeFromServer();
  }

  getSubscribeFromServer() async {
    CommonResponse response = await getSubscribeListApi();
    if (response.code == 0) {
      subList = response.data;
    } else {
      Get.snackbar('订阅信息获取失败', response.msg.toString());
    }
    update();
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

  saveSubscribe(Subscribe sub) async {
    CommonResponse res;
    Logger.instance.i(sub.toJson());
    if (sub.id == 0) {
      res = await addSubscribeApi(sub);
    } else {
      res = await editSubscribeApi(sub);
    }
    if (res.code == 0) {
      await getSubscribeFromServer();
    }
    return res;
  }

  removeSubscribe(Subscribe sub) async {
    CommonResponse res = await removeSubscribeApi(sub);
    if (res.code == 0) {
      await getSubscribeFromServer();
    }
    return res;
  }

  Future<Map<String, String>> getDownloaderCategories(
      Downloader downloader) async {
    try {
      Get.put(TorrentController(downloader, false),
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
      TorrentController torrentController = Get.find(
          tag:
              '${downloader.protocol}://${downloader.host}:${downloader.port}');
      if (downloader.category.toLowerCase() == 'tr') {
        torrentController.getAllTorrents();
      }
      update(['${downloader.id} - ${downloader.name}']);
      await torrentController.getAllCategory();
      update(['${downloader.id} - ${downloader.name}']);
      update();
      torrentController.update();

      return torrentController.categoryList;
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      return {};
    }
  }
}
