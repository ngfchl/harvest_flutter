import 'package:harvest/api/hooks.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';

import '../models/common_response.dart';
import '../models/download.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

///获取下载器列表
///
Future<CommonResponse> getDownloaderListApi({bool withStatus = false}) async {
  return await fetchDataList(
      Api.DOWNLOADER_LIST, (p0) => Downloader.fromJson(p0),
      queryParameters: {"with_status": withStatus});
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

Future<CommonResponse> repeatSingleDownloader(int downloaderId) async {
  final response =
      await DioUtil().get('${Api.DOWNLOADER_REAPEAT}/$downloaderId');
  Logger.instance.i(response.data);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
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

///  修改Tracker信息
replaceTorrentTrackerApi(int downloaderId, Map<String, dynamic> params) async {
  String apiUrl = '${Api.DOWNLOADER_TRACKER_REPLACE}/$downloaderId';
  return await editData(apiUrl, params);
}

//*///@title 获取下载器全量数据
///@description
///@updateTime
Future<CommonResponse> getMainData(int downloaderId) async {
  final response = await fetchBasicData('${Api.DOWNLOADER_MAIN}$downloaderId');
  return response;
}

//*///@title 获取下载器配置信息
///@description
///@updateTime
Future<CommonResponse> getPrefsApi(int downloaderId) async {
  final response =
      await fetchBasicData('${Api.DOWNLOADER_PREFERENCES}$downloaderId');
  return response;
}

//*///@title 更新下载器配置信息
///@description
///@updateTime
Future<CommonResponse> setPrefsApi(
    int downloaderId, Map<String, dynamic> prefs) async {
  final response =
      await editData('${Api.DOWNLOADER_PREFERENCES}$downloaderId', prefs);
  return response;
}

//*///@title 切换下载器限速模式
///@description
///@updateTime
Future<CommonResponse> toggleSpeedLimitApi(int downloaderId, bool state) async {
  final response = await fetchBasicData(
      '${Api.DOWNLOADER_TOGGLE_SPEED_LIMIT_ENABLE}$downloaderId',
      queryParameters: {"state": state});
  return response;
}

//*///@title 获取下载器种子详情
///@description
///@updateTime
Future<CommonResponse> getTorrentDetailInfo(
    int downloaderId, String torrentHash) async {
  final response = await fetchBasicData(
      '${Api.DOWNLOADER_TORRENT_DETAIL}$downloaderId',
      queryParameters: {'torrent_hash': torrentHash});
  return response;
}

//*///@title 获取下载器分类信息
///@description
///@updateTime
Future<CommonResponse> getDownloaderCategories(int downloaderId) async {
  final response =
      await fetchBasicList('${Api.DOWNLOADER_CATEGORY}$downloaderId');
  return response;
}

//*///@title 创建下载器分类
///@description
///@updateTime
Future<CommonResponse> createDownloaderCategory(
    int downloaderId, Category category) async {
  final response = await addData(
      '${Api.DOWNLOADER_CATEGORY}$downloaderId', category.toJson());
  return response;
}

//*///@title 修改下载器分类
///@description
///@updateTime
Future<CommonResponse> editDownloaderCategory(
    int downloaderId, Category category) async {
  final response = await editData(
      '${Api.DOWNLOADER_CATEGORY}$downloaderId', category.toJson());
  return response;
}

//*///@title 删除下载器分类
///@description
///@updateTime
Future<CommonResponse> deleteDownloaderCategory(
    int downloaderId, String category) async {
  final response = await removeData('${Api.DOWNLOADER_CATEGORY}$downloaderId',
      queryParameters: {'category': category});
  return response;
}

//*///@title 设置种子分类
///@description
///@updateTime
Future<CommonResponse> addTorrentCategory(
    int downloaderId, String tag, String torrentHashes) async {
  final response = await editData('${Api.DOWNLOADER_SET_CATEGORY}$downloaderId',
      {'tag': tag, 'torrent_hashes': torrentHashes});
  return response;
}

//*///@title 删除种子分类
///@description
///@updateTime
Future<CommonResponse> removeTorrentCategory(
    int downloaderId, String tag, dynamic torrentHashes) async {
  final response = await removeData(
      '${Api.DOWNLOADER_SET_CATEGORY}$downloaderId',
      queryParameters: {'tag': tag, 'torrent_hashes': torrentHashes});
  return response;
}

//*///@title 获取下载器标签信息
///@description
///@updateTime
Future<CommonResponse> getDownloaderTags(int downloaderId) async {
  final response = await fetchBasicData('${Api.DOWNLOADER_TAGS}$downloaderId');
  return response;
}

//*///@title 创建下载器标签
///@description
///@updateTime
Future<CommonResponse> createDownloaderTags(
    int downloaderId, String tag) async {
  final response =
      await addData('${Api.DOWNLOADER_TAGS}$downloaderId', {'tag': tag});
  return response;
}

//*///@title 删除下载器标签
///@description
///@updateTime
Future<CommonResponse> deleteDownloaderTags(
    int downloaderId, String tag) async {
  final response = await removeData('${Api.DOWNLOADER_TAGS}$downloaderId',
      queryParameters: {'tag': tag});
  return response;
}

//*///@title 设置种子标签
///@description
///@updateTime
Future<CommonResponse> addTorrentTags(
    int downloaderId, String tag, String torrentHashes) async {
  final response = await editData('${Api.DOWNLOADER_SET_TAGS}$downloaderId',
      {'tag': tag, 'torrent_hashes': torrentHashes});
  return response;
}

//*///@title 删除种子标签
///@description
///@updateTime
Future<CommonResponse> removeTorrentTags(
    int downloaderId, String tag, dynamic torrentHashes) async {
  final response = await removeData('${Api.DOWNLOADER_SET_TAGS}$downloaderId',
      queryParameters: {'tag': tag, 'torrent_hashes': torrentHashes});
  return response;
}

//*///@title 操作种子
///@description
///@updateTime
Future<CommonResponse> controlTorrent(
    {required int downloaderId, required Map<String, dynamic> command}) async {
  final response =
      await addData('${Api.DOWNLOADER_CONTROL}$downloaderId', command);
  return response;
}

Future<CommonResponse> pushTorrentToDownloader({
  required int downloaderId,
  required Map<String, dynamic> formData,
}) async {
  final response =
      await addData('${Api.PUSH_TORRENT_URL}$downloaderId', formData);
  return response;
}
