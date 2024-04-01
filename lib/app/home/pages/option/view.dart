import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class OptionPage extends StatefulWidget {
  const OptionPage({super.key});

  @override
  State<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends State<OptionPage> {
  final controller = Get.put(OptionController());

  @override
  Widget build(BuildContext context) {
    return const Text("系统配置");
  }

  @override
  void dispose() {
    Get.delete<OptionController>();
    super.dispose();
  }
}
