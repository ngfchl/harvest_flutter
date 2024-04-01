import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  final controller = Get.put(SubscribeController());

  @override
  Widget build(BuildContext context) {
    return const Text("订阅信息");
  }

  @override
  void dispose() {
    Get.delete<SubscribeController>();
    super.dispose();
  }
}
