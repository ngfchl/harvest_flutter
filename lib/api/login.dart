import '../../utils/http.dart';
import '../models/authinfo.dart';
import '../models/common_response.dart';
import '../models/login_user.dart';
import '../utils/dio_util.dart';
import 'api.dart';

/// 用户
class UserAPI {
  /// 登录
  static Future login({
    LoginUser? params,
  }) async {
    var response = await DioClient().post(
      '/user/login',
      formData: params?.toJson(),
    );
    return response;
  }

  /// Logout
  static Future logout() async {
    return await DioClient().post(
      '/user/logout',
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
