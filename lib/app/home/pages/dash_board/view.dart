import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final controller = Get.put(DashBoardController());

  @override
  Widget build(BuildContext context) {
    return const Text("主页");
  }

  @override
  void dispose() {
    Get.delete<DashBoardController>();
    super.dispose();
  }
}
