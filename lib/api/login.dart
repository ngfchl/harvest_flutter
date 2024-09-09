import '../models/authinfo.dart';
import '../models/common_response.dart';
import '../models/login_user.dart';
import '../utils/dio_util.dart';
import 'api.dart';

/// 用户
class UserAPI {
  /// 登录
  static Future<CommonResponse> login(LoginUser loginUser) async {
    var response = await DioUtil().post(
      Api.LOGIN_URL,
      formData: loginUser.toJson(),
    );
    if (response.data['code'] == 0) {
      return CommonResponse.fromJson(
          response.data, (p0) => AuthInfo.fromJson(p0));
    }
    return CommonResponse.error(msg: response.data['msg']);
  }

  /// Logout
  static Future logout() async {
    return await DioUtil().post(
      Api.LOGIN_URL,
    );
  }
}

Future<CommonResponse> getGitUpdateLog() async {
  final response = await DioUtil().get(Api.UPDATE_LOG);
  if (response.statusCode == 200) {
    final updateLogState = UpdateLogState.fromJson(response.data['data']);
    return CommonResponse(data: updateLogState, code: 0);
  } else {
    String msg = '获取Docker更新日志失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> doDockerUpdateApi() async {
  final response = await DioUtil().get(Api.DOCKER_UPDATE);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '获取Docker更新日志失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
