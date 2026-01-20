import 'package:get/get.dart';
import 'package:harvest/app/home/pages/agg_search/models.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/source.dart';
import '../../../../api/tmdb.dart';
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

  Future<CommonResponse> initSourceData({bool noCache = false}) async {
    final stopwatch = Stopwatch()..start(); // 开始计时
    CommonResponse res = await getSourceListApi(path: currentPath, noCache: noCache);
    if (res.succeed) {
      currentPath = res.data["current_path"];
      items = (res.data["items"] as List).map((e) => SourceItemView.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      items = [];
      Logger.instance.e('获取文件列表失败: ${res.msg}');
    }
    isLoading = false;
    Logger.instance.d('当前路径: $currentPath，当前路径下文件数量: ${items.length}');
    update(['file_manage']);
    stopwatch.stop(); // 停止计算处理耗时
    Logger.instance.d('initSourceData 页面刷新耗时: ${stopwatch.elapsedMilliseconds} ms');
    return res;
  }

  Future<CommonResponse> getFileSourceUrl(String path) async {
    return await getSourceUrlApi(path: path);
  }

  Future<CommonResponse> removeSource(String path) async {
    return await removeSourceApi(path);
  }

  Future<CommonResponse> edisSource(String path, String newName) async {
    return await editSourceApi(path, newName);
  }

  Future<bool> onBackPressed() async {
    if (currentPath != '/downloads') {
      isLoading = true;
      update(['file_manage']);
      var pathList = currentPath.split('/');
      pathList.removeLast();
      currentPath = pathList.join("/");
      await initSourceData();
      return true; // 已处理
    }
    return false; // 未处理
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

  Future<CommonResponse> writeScrapeInfoApi(String path, MediaItem mediaItem) async {
    return await saveTMDBMatchApi(path, mediaItem.toJson());
  }

  Future<CommonResponse> hardLinkSource(String path) async {
    return await hardLinkSourceApi(path);
  }
}
