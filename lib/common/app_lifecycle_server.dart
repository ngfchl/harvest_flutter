import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

import '../utils/logger_helper.dart';

class AppLifecycleService extends GetxService {
  final lifecycle = Rx<AppLifecycleState?>(null);

  @override
  void onInit() {
    super.onInit();
    Logger.instance.i("==== 注册 SystemChannels.lifecycle 监听器 ====");

    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg != null && msg.startsWith("AppLifecycleState")) {
        final state = AppLifecycleState.values.firstWhere(
          (e) => e.toString() == msg,
          orElse: () => AppLifecycleState.resumed,
        );

        lifecycle.value = state;
        Logger.instance.i("AppLifecycleService 收到状态: $state");
      }
      return msg;
    });

    Logger.instance.i("==== 注册完成 ====");
  }
}
