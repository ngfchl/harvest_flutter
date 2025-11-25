import 'package:dio/dio.dart';

import '../models/authinfo.dart';
import '../models/common_response.dart';
import '../models/login_user.dart';
import '../utils/dio_util.dart';
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
