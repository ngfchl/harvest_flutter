import 'package:harvest/api/hooks.dart';

import '../models/common_response.dart';
import '../models/download.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

///获取下载器列表
///
Future<CommonResponse> getDownloaderListApi() async {
  return await fetchDataList(
      Api.DOWNLOADER_LIST, (p0) => Downloader.fromJson(p0));
}

Future<CommonResponse> getDownloaderPaths() async {
  final response = await DioUtil().get(Api.DOWNLOADER_PATHS);
  Logger.instance.i(response.data);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => p0);
  } else {
    String msg = '获取数据失败: ${response.statusCode}';
    Logger.instance.w(msg);
    return CommonResponse.fromJson(response.data, (p0) => null);
  }
}

///  修改下载器信息
editDownloaderApi(Downloader downloader) async {
  String apiUrl = '${Api.DOWNLOADER_LIST}/${downloader.id}';
  return await editData(apiUrl, downloader.toJson());
}

/// 保存下载器信息
saveDownloaderApi(Downloader downloader) async {
  String apiUrl = Api.DOWNLOADER_LIST;
  return await addData(apiUrl, downloader.toJson());
}

///  修改下载器信息
removeDownloaderApi(Downloader downloader) async {
  String apiUrl = '${Api.DOWNLOADER_LIST}/${downloader.id}';
  return await removeData(apiUrl);
}

Future<CommonResponse> getDownloaderCategories(int downloaderId) async {
  final response = await DioUtil().get(Api.DOWNLOADER_CATEGORIES,
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

Future<CommonResponse> pushTorrentToDownloader({
  required int site,
  required int downloaderId,
  required String url,
  required String category,
}) async {
  final response = await DioUtil().get(Api.PUSH_TORRENT_URL, queryParameters: {
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
