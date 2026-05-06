import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 全局登出回调，用于拦截器中触发登录态失效。
Future<void> Function()? globalLogout;
