import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SubscribeHistoryPage extends StatefulWidget {
  const SubscribeHistoryPage({super.key});

  @override
  State<SubscribeHistoryPage> createState() => _SubscribeHistoryPageState();
}

class _SubscribeHistoryPageState extends State<SubscribeHistoryPage> {
  final controller = Get.put(SubscribeHistoryController());

  @override
  Widget build(BuildContext context) {
    return const Text("订阅历史");
  }

  @override
  void dispose() {
    Get.delete<SubscribeHistoryController>();
    super.dispose();
  }
}
