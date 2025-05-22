import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../app/home/pages/models/my_site.dart';
import '../app/home/pages/models/website.dart';
import '../models/common_response.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import '../utils/storage.dart';
import 'api.dart';
import 'hooks.dart';

String baseUrl = SPUtil.getLocalStorage('server');

/// 获取
Future<CommonResponse> getDashBoardDataApi(days) async {
  final response = await fetchBasicData(Api.DASHBOARD_DATA,queryParameters: {"days": days});
  if (response.code == 0) {
    SPUtil.setMap(
        '$baseUrl - DASHBOARD_DATA', {'DASHBOARD_DATA': response.data});
  }
  return response;
}

/// 获取
Future<CommonResponse> getMySiteList() async {
  final response = await fetchDataList(Api.MYSITE_LIST, (p0) => p0);
  if (response.code == 0) {
    SPUtil.setMap('$baseUrl - mySiteList', {'mySiteList': response.data});
    return CommonResponse.success(
        data: response.data?.map((p0) => MySite.fromJson(p0)).toList());
  }
  return response;
}

/// 清除缓存
Future<CommonResponse> clearMyCacheApi(String key) async {
  return await fetchBasicList(Api.CLEAR_CACHE, queryParameters: {"key": key});
}

/// 获取站点信息列表
///
Future<CommonResponse> getWebSiteList() async {
  final response = await fetchDataList(Api.WEBSITE_LIST, (p0) => p0);
  if (response.code == 0) {
    SPUtil.setMap('$baseUrl - webSiteList', {'webSiteList': response.data});
    Map<String, WebSite> dataList = response.data!
        .map((item) => WebSite.fromJson(item))
        .toList()
        .asMap()
        .entries
        .fold({}, (result, entry) {
      result[entry.value.name] = entry.value;
      return result;
    });
    String msg = '工具共支持${dataList.length}个站点';
    Logger.instance.i(msg);
    return CommonResponse.success(data: dataList, msg: msg);
  }
  return response;
}

/// 签到当前站点
signIn(int? mySiteId) async {
  final response = await DioUtil().get(
    '${Api.MYSITE_SIGNIN_OPERATE}/${mySiteId ?? ''}',
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '签到失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

/// 签到当前站点
repeatSite(int? mySiteId) async {
  final response = await DioUtil().get(
    '${Api.MYSITE_REPEAT_OPERATE}/${mySiteId ?? ''}',
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '辅种失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

/// PTPP 导入
importFromPTPPApi(PlatformFile file) async {
  final fileName = file.name;

  final response = await DioUtil().post(
    Api.IMPORT_COOKIE_PTPP,
    formData: FormData.fromMap({
      "file": MultipartFile.fromBytes(file.bytes!, filename: fileName),
    }),
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = 'PTPP 导入失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

/// CookieCloud 同步
importFromCookieCloudApi() async {
  final response = await DioUtil().get(
    Api.IMPORT_COOKIE_CLOUD,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = 'CookieCloud 同步失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

/// 更新当前站点数据
getNewestStatus(int? mySiteId) async {
  final response = await DioUtil().get(
    '${Api.MYSITE_STATUS_OPERATE}/${mySiteId ?? ''}',
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '站点刷新数据失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

///  修改站点信息
editMySite(MySite mySite) async {
  String apiUrl = '${Api.MYSITE_LIST}/${mySite.id}';
  return await editData(apiUrl, mySite.toJson());
}

/// 保存站点信息
saveMySite(MySite mySite) async {
  String apiUrl = Api.MYSITE_LIST;
  return await addData(apiUrl, mySite.toJson());
}

/// 删除站点
removeMySite(MySite mySite) async {
  String apiUrl = Api.MYSITE_LIST;
  return await removeData('$apiUrl/${mySite.id}');
}

/// 批量更新操作
bulkUpgrade(Map<String, dynamic> data) async {
  String apiUrl = Api.Bulk_UPGRADE_API;
  final response = await DioUtil().post(apiUrl, formData: data);
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '站点刷新数据失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

signInAll() async {
  final response = await DioUtil().get(
    Api.MYSITE_SIGNIN_OPERATE,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '签到失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

/// 更新当前站点数据
getNewestStatusAll() async {
  final response = await DioUtil().get(
    Api.MYSITE_STATUS_OPERATE,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '站点刷新数据失败！: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}
