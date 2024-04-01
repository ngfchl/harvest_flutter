import '../app/home/pages/models/my_site.dart';
import '../app/home/pages/models/website.dart';
import '../models/common_response.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';
import 'hooks.dart';

/// 获取
Future<CommonResponse> getMySiteList() async {
  final response = await DioUtil().get(Api.MYSITE_LIST);
  if (response.statusCode == 200) {
    final dataList = (response.data['data'] as List)
        .map<MySite>((item) => MySite.fromJson(item))
        .toList();
    String msg = '拥有${dataList.length}个站点';
    // Logger.instance.i(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 获取站点信息列表
///
Future<CommonResponse> getWebSiteList() async {
  final response = await DioUtil().get(Api.WEBSITE_LIST);
  if (response.statusCode == 200) {
    Map<String, WebSite> dataList = (response.data['data'] as List)
        .map<WebSite>((item) => WebSite.fromJson(item))
        .toList()
        .asMap()
        .entries
        .fold({}, (result, entry) {
      result[entry.value.name] = entry.value;
      return result;
    });
    String msg = '工具共支持${dataList.length}个站点';
    Logger.instance.i(msg);
    return CommonResponse(data: dataList, code: 0, msg: msg);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 签到当前站点
signIn(int mySiteId) async {
  final response = await DioUtil().get(
    '${Api.MYSITE_SIGNIN_OPERATE}/$mySiteId',
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
getNewestStatus(int mySiteId) async {
  final response = await DioUtil().get(
    '${Api.MYSITE_STATUS_OPERATE}/$mySiteId',
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
  return await saveData(apiUrl, mySite.toJson());
}

/// 获取图表接口
Future<CommonResponse> getMySiteChart({
  int siteId = 0,
  int days = 7,
}) async {
  final response = await DioUtil().get(
    Api.MYSITE_STATUS_CHART_V2,
    queryParameters: {
      "site_id": siteId,
      "days": days,
    },
  );

  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
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
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

/// 更新当前站点数据
getNewestStatusAll() async {
  final response = await DioUtil().post(
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

/// 获取图表接口
Future<CommonResponse> getMySiteChartV2({
  int siteId = 0,
  int days = 7,
}) async {
  final response = await DioUtil().get(
    Api.MYSITE_STATUS_CHART_V2,
    queryParameters: {
      "site_id": siteId,
      "days": days,
    },
  );

  if (response.statusCode == 200) {
    return CommonResponse(data: response.data['data'], code: 0, msg: '');
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
