import 'package:get/get.dart';

import '../../../../api/sub.dart';
import '../../../../models/common_response.dart';
import '../models/SubHistory.dart';

class SubscribeHistoryController extends GetxController {
  List<SubHistory> subHistory = [];

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  initData() async {
    await getSubHistoryFromServer();
  }

  getSubHistoryFromServer() async {
    CommonResponse response = await getSubHistoryListApi();
    if (response.succeed) {
      subHistory = response.data;
    } else {
      Get.snackbar('订阅历史获取失败', "订阅历史获取失败");
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

  removeHistory(SubHistory history) async {
    return await deleteSubHistoryListApi(history);
  }

  pushTorrent(SubHistory history) async {
    return await pushTorrentApi(history);
  }
}
