import 'package:dio/dio.dart';

import '../models/authinfo.dart';
import '../models/common_response.dart';
import '../models/login_user.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import '../utils/storage.dart';
import 'api.dart';

/// 用户
class UserAPI {
  /// 登录
  static Future<CommonResponse> login(LoginUser loginUser, {CancelToken? cancelToken}) async {
    var response = await DioUtil().post(
      Api.LOGIN_URL,
      formData: loginUser.toJson(),
      cancelToken: cancelToken,
    );
    if (response.statusCode != 200) {
      return CommonResponse.error(msg: '网站访问失败！错误码：${response.statusCode}');
    }
    if (response.data['code'] == 0) {
      return CommonResponse.fromJson(response.data, (p0) => AuthInfo.fromJson(p0));
    }
    return CommonResponse.error(msg: response.data['msg']);
  }

  /// Logout
  static Future logout() async {
    await SPUtil.remove('userinfo');
    await SPUtil.remove('isLogin');
    DioUtil.instance.clearAuthToken();
    return await DioUtil().post(
      Api.LOGIN_URL,
    );
  }
}

Future<CommonResponse> getGitUpdateLog() async {
  final response = await DioUtil().get(Api.UPDATE_LOG);
  if (response.statusCode == 200) {
    Logger.instance.d(response.data);
    return CommonResponse.fromJson(response.data, (p0) {
      if (p0 == null) {
        return null;
      }
      return UpdateLogState.fromJson(p0);
    });
  } else {
    String msg = '获取Docker更新日志失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> getGitUpdateSites() async {
  final response = await DioUtil().get(Api.UPDATE_SITES);
  if (response.statusCode == 200) {
    Logger.instance.d(response.data);
    return CommonResponse.fromJson(response.data, (p0) {
      if (p0 == null) {
        return null;
      }
      return UpdateLogState.fromJson(p0);
    });
  } else {
    String msg = '获取Docker更新日志失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> doDockerUpdateApi({String upgradeTag = "upgrade_all"}) async {
  final response = await DioUtil().get("${Api.DOCKER_UPDATE}?upgrade_tag=$upgradeTag");
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '获取Docker更新日志失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}
