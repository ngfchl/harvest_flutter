import 'package:get/get.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../api/downloader.dart';
import '../../../../api/sub.dart';
import '../../../../common/meta_item.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../download/download_controller.dart';
import '../models/SubTag.dart';
import '../models/Subscribe.dart';
import '../models/download.dart';
import '../my_rss/controller.dart';
import '../subscribe_tag/controller.dart';

class SubscribeController extends GetxController {
  SubscribeTagController subTagController = Get.put(SubscribeTagController());
  MyRssController rssController = Get.put(MyRssController());
  DownloadController downloadController = Get.find();

  List<Subscribe> subList = [];
  List<SubPlan> planList = [];
  List<MetaDataItem> tagCategoryList = [];

  ShadTabsController<String> tabsController = ShadTabsController<String>(value: 'subscribe');

  List<SubTag> tags = [];
  bool isDownloaderLoading = false;
  bool isAddFormLoading = false;
  bool loading = false;

  @override
  void onInit() async {
    await initData();
    super.onInit();
  }

  Future<void> initData() async {
    loading = true;
    update();
    await subTagController.initData();
    await rssController.initData();
    tagCategoryList = subTagController.tagCategoryList;
    tags = subTagController.tags.where((e) => e.available == true).toList();
    Logger.instance.i(tagCategoryList);
    await getSubscribeFromServer();
    await getSubPlanFromServer();
    loading = false;
    update();
  }

  Future<void> getDownloaderListFromServer() async {
    try {
      isDownloaderLoading = true;
      update();
      await downloadController.getDownloaderListFromServer();
      Logger.instance.i('下载器列表:${downloadController.dataList}');
    } catch (e) {
      Get.snackbar('下载器信息获取失败', e.toString());
    }
    isDownloaderLoading = false;
    update();
  }

  Future<void> getSubscribeFromServer() async {
    CommonResponse response = await getSubscribeListApi();
    if (response.code == 0) {
      subList = response.data;
    } else {
      Get.snackbar('订阅信息获取失败', response.msg.toString());
    }
    update();
  }

  Future<void> getSubPlanFromServer() async {
    CommonResponse response = await getSubPlanListApi();
    if (response.succeed) {
      planList = response.data;
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

  Future<CommonResponse> saveSubscribe(Subscribe sub) async {
    CommonResponse res;
    Logger.instance.i(sub.toJson());
    if (sub.id == 0) {
      res = await addSubscribeApi(sub);
    } else {
      res = await editSubscribeApi(sub);
    }
    if (res.succeed) {
      await getSubscribeFromServer();
    }
    return res;
  }

  Future<CommonResponse> removeSubscribe(Subscribe sub) async {
    CommonResponse res = await removeSubscribeApi(sub);
    if (res.succeed) {
      await getSubscribeFromServer();
    }
    return res;
  }

  Future<CommonResponse<Map<String, Category>>> getDownloaderCategoryList(Downloader downloader) async {
    try {
      CommonResponse response = await getDownloaderCategories(downloader.id!);
      if (!response.succeed) {
        return CommonResponse.error(msg: response.msg);
      }
      Map<String, Category> data = {
        for (var item in response.data) (item)['name']!: Category.fromJson(item as Map<String, dynamic>)
      };

      return CommonResponse.success(data: data);
    } catch (e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      return CommonResponse.error(msg: '获取分类出错啦：$e');
    }
  }

  Future<CommonResponse> removeSubPlan(SubPlan plan) async {
    CommonResponse res = await removeSubPlanApi(plan);
    if (res.succeed) {
      await getSubPlanFromServer();
    }
    return res;
  }

  Future<CommonResponse> saveSubPlan(SubPlan plan) async {
    CommonResponse res;
    Logger.instance.i(plan.toJson());
    if (plan.id == 0) {
      res = await addSubPlanApi(plan);
    } else {
      res = await editSubPlanApi(plan);
    }
    if (res.succeed) {
      await getSubPlanFromServer();
    }
    return res;
  }
}
