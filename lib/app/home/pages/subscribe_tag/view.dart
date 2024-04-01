import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class SubscribeTagPage extends StatefulWidget {
  const SubscribeTagPage({super.key});

  @override
  State<SubscribeTagPage> createState() => _SubscribeTagPageState();
}

class _SubscribeTagPageState extends State<SubscribeTagPage> {
  final controller = Get.put(SubscribeTagController());

  @override
  Widget build(BuildContext context) {
    return const Text("订阅标签");
  }

  @override
  void dispose() {
    Get.delete<SubscribeTagController>();
    super.dispose();
  }
}
