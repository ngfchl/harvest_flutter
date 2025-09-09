import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/source.dart';
import '../../../../utils/logger_helper.dart';
import '../models/source.dart';

class FileManageController extends GetxController {
  String currentPath = '/downloads';
  List<SourceItemView> items = [];

  bool isLoading = false;

  @override
  void onInit() async {
    super.onInit();
    await initSourceData();
  }

  initSourceData() async {
    CommonResponse res = await getSourceListApi(path: currentPath);
    if (res.succeed) {
      currentPath = res.data["current_path"];
      items = (res.data["items"] as List)
          .map((e) => SourceItemView.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    isLoading = false;
    Logger.instance.d('当前路径: $currentPath，当前路径下文件数量: ${items.length}');
    update(['file_manage']);
  }

  getFileSourceUrl(String path) async {
    return await getSourceUrlApi(path: path);
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
