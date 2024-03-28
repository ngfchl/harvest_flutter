import '../../utils/http.dart';
import '../models/login_user.dart';

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
