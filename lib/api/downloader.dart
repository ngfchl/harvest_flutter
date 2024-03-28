import '../models/common_response.dart';
import '../models/download.dart';
import '../utils/http.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

///获取下载器列表
///
Future<CommonResponse> getDownloaderList() async {
  final response = await DioClient().get(Api.DOWNLOADER_LIST);
  if (response.statusCode == 200) {
    final dataList = (response.data['data'] as List)
        .map<Downloader>((item) => Downloader.fromJson(item))
        .toList();
    String msg = '共有${dataList.length}个下载器';
    print(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> getDownloaderCategories(int downloaderId) async {
  final response = await DioClient().get(Api.DOWNLOADER_CATEGORIES,
      queryParameters: {"downloader_id": downloaderId});
  if (response.statusCode == 200) {
    Logger.instance.w(response.data['data']);
    final dataList = (response.data['data'] as List)
        .map<DownloaderCategory>((item) => DownloaderCategory.fromJson(item))
        .toList();
    Logger.instance.w(dataList);
    String msg = '共有${dataList.length}个分类';
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> getDownloaderConnectTest(int downloaderId) async {
  final response = await DioClient().get(Api.DOWNLOADER_CONNECT_TEST,
      queryParameters: {"downloader_id": downloaderId});
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '测试下载链接失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> pushTorrentToDownloader({
  required int site,
  required int downloaderId,
  required String url,
  required String category,
}) async {
  final response =
      await DioClient().get(Api.PUSH_TORRENT_URL, queryParameters: {
    "downloader_id": downloaderId,
    "site": site,
    "url": url,
    "category": category,
  });
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
