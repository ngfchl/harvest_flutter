import 'package:get/get.dart';
import 'package:harvest/app/home/pages/models/SubTag.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/sub.dart';
import '../../../../common/meta_item.dart';

class SubscribeTagController extends GetxController {
  List<SubTag> tags = [];

  List<MetaDataItem> tagCategoryList = [
    {'name': '排除选项', 'value': 'exclude'},
    {'name': '剧集', 'value': 'season'},
    {'name': '发布年份', 'value': 'publish_year'},
    {'name': '优惠折扣', 'value': 'discount'},
    {'name': '视频质量', 'value': 'video_quality'},
    {'name': '分辨率', 'value': 'resolution'},
    {'name': '视频编码', 'value': 'video_codec'},
    {'name': '音频编码', 'value': 'audio_codec'},
    {'name': '发行方', 'value': 'publisher'},
    {'name': '种子标签', 'value': 'tags'},
    {'name': '资源来源', 'value': 'source'},
    {'name': '资源分类', 'value': 'category'},
  ].map((e) => MetaDataItem.fromJson(e)).toList();

  initData() async {
    await getTagsFromServer();
  }

  getTagsFromServer() async {
    CommonResponse response = await getTagListApi();
    if (response.code == 0) {
      tags = response.data;
    } else {
      Get.snackbar('订阅标签获取失败', "订阅标签获取失败");
    }
    update();
  }

  @override
  void onInit() async {
    await initData();
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

  saveSubTag(SubTag tag) async {
    CommonResponse res;
    if (tag.id == 0) {
      res = await addSubTagApi(tag);
    } else {
      res = await editSubTagApi(tag);
    }
    if (res.code == 0) {
      await getTagsFromServer();
    }
    return res;
  }

  removeSubTag(SubTag tag) async {
    CommonResponse res = await removeSubTagApi(tag);
    if (res.code == 0) {
      await getTagsFromServer();
    }
    return res;
  }
}
