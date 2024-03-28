import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../app/routes/app_pages.dart';
import '../utils/storage.dart';

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    print(route);
    if (SPUtil.getBool('isLogin') == false) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
