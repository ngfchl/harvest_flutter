import '../app/home/pages/models/my_site.dart';
import '../app/home/pages/models/website.dart';
import '../models/common_response.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getMySiteList() async {
  return await fetchDataList(Api.MYSITE_LIST, (p0) => MySite.fromJson(p0));
}

/// 获取站点信息列表
///
Future<CommonResponse> getWebSiteList() async {
  final response =
      await fetchDataList(Api.WEBSITE_LIST, (p0) => WebSite.fromJson(p0));
  if (response.code == 0) {
    Map<String, WebSite> dataList =
        response.data!.asMap().entries.fold({}, (result, entry) {
      result[entry.value.name] = entry.value;
      return result;
    });
    String msg = '工具共支持${dataList.length}个站点';
    Logger.instance.i(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
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
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// PTPP 导入
importFromPTPPApi() async {
  final response = await DioUtil().get(
    Api.IMPORT_COOKIE_PTPP,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = 'PTPP 导入失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
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
    return CommonResponse(data: null, code: -1, msg: msg);
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
    return CommonResponse(data: null, code: -1, msg: msg);
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

signInAll() async {
  final response = await DioUtil().get(
    Api.MYSITE_SIGNIN_OPERATE,
  );
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '签到失败！: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
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
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
