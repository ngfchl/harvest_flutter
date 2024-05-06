import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../app/routes/app_pages.dart';
import '../utils/storage.dart';

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (SPUtil.getLocalStorage('server') == null ||
        SPUtil.getLocalStorage('userinfo') == null ||
        SPUtil.getLocalStorage('isLogin') != true && route != Routes.LOGIN) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
