import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/my_site.dart';

import '../../../../api/sub.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../models/my_rss.dart';
import '../my_site/controller.dart';

class MyRssController extends GetxController {
  List<MyRss> rssList = [];
  Map<String, MySite> mySiteMap = {};
  MySiteController mySiteController = Get.find();

  @override
  void onInit() async {
    await initData();
    mySiteMap = {
      for (var mysite in mySiteController.mySiteList) mysite.site: mysite
    };
    super.onInit();
  }

  Future<void> initData() async {
    await getMyRssFromServer();
  }

  Future<void> getMyRssFromServer() async {
    CommonResponse response = await getMyRssListApi();
    if (response.code == 0) {
      rssList = response.data;
    } else {
      Get.snackbar('订阅标签获取失败', "订阅标签获取失败");
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

  Future<CommonResponse> saveMyRss(MyRss rss) async {
    CommonResponse res;
    Logger.instance.i(rss.toJson());
    if (rss.id == 0) {
      res = await addMyRssApi(rss);
    } else {
      res = await editMyRssApi(rss);
    }
    if (res.code == 0) {
      await getMyRssFromServer();
    }
    return res;
  }

  Future<CommonResponse> removeMyRss(MyRss rss) async {
    CommonResponse res = await removeMyRssApi(rss);
    if (res.code == 0) {
      await getMyRssFromServer();
    }
    return res;
  }
}
