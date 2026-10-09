import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 全局登出回调，用于拦截器中触发登录态失效。
Future<void> Function({
  String? redirectTo,
  bool openSetupAfterLogout,
  String? setupBaseUrl,
})?
globalLogout;
