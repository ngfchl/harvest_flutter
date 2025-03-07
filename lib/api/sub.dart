import 'package:harvest/app/home/pages/models/SubHistory.dart';
import 'package:harvest/app/home/pages/models/SubTag.dart';
import 'package:harvest/app/home/pages/models/Subscribe.dart';

import '../app/home/pages/models/my_rss.dart';
import '../models/common_response.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getTagListApi() async {
  return await fetchDataList(Api.SUB_TAG, (p0) => SubTag.fromJson(p0));
}

///  修改下载器信息
editSubTagApi(SubTag tag) async {
  String apiUrl = '${Api.SUB_TAG}/${tag.id}';
  return await editData(apiUrl, tag.toJson());
}

/// 保存下载器信息
addSubTagApi(SubTag tag) async {
  String apiUrl = Api.SUB_TAG;
  return await addData(apiUrl, tag.toJson());
}

///  修改下载器信息
removeSubTagApi(SubTag tag) async {
  String apiUrl = '${Api.SUB_TAG}/${tag.id}';
  return await removeData(apiUrl);
}

/// 获取
Future<CommonResponse> getMyRssListApi() async {
  return await fetchDataList(Api.SUB_RSS, (p0) => MyRss.fromJson(p0));
}

///  修改下载器信息
editMyRssApi(MyRss rss) async {
  String apiUrl = '${Api.SUB_RSS}/${rss.id}';
  return await editData(apiUrl, rss.toJson());
}

/// 保存下载器信息
addMyRssApi(MyRss rss) async {
  String apiUrl = Api.SUB_RSS;
  return await addData(apiUrl, rss.toJson());
}

///  删除信息
removeMyRssApi(MyRss rss) async {
  String apiUrl = '${Api.SUB_RSS}/${rss.id}';
  return await removeData(apiUrl);
}

/// 获取
Future<CommonResponse> getSubscribeListApi() async {
  return await fetchDataList(Api.SUB_SUB, (p0) => Subscribe.fromJson(p0));
}

///  修改信息
editSubscribeApi(Subscribe sub) async {
  String apiUrl = '${Api.SUB_SUB}/${sub.id}';
  return await editData(apiUrl, sub.toJson());
}

/// 保存信息
addSubscribeApi(Subscribe sub) async {
  String apiUrl = Api.SUB_SUB;
  return await addData(apiUrl, sub.toJson());
}

///  删除信息
removeSubscribeApi(Subscribe sub) async {
  String apiUrl = '${Api.SUB_SUB}/${sub.id}';
  return await removeData(apiUrl);
}

/// 获取
Future<CommonResponse> getSubHistoryListApi() async {
  return await fetchDataList(Api.SUB_HISTORY, (p0) => SubHistory.fromJson(p0));
}

Future<CommonResponse> deleteSubHistoryListApi(SubHistory history) async {
  String apiUrl = '${Api.SUB_HISTORY}/${history.id}';
  return await removeData(apiUrl);
}

Future<CommonResponse> pushTorrentApi(SubHistory history) async {
  String apiUrl = '${Api.SUB_HISTORY}/${history.id}';
  return await editData(apiUrl, {});
}
