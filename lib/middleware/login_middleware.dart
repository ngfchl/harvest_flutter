import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../app/routes/app_pages.dart';

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    GetStorage box = GetStorage();
    if (box.read('isLogin') != true && route != Routes.LOGIN) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}
