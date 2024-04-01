import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class MyRssPage extends StatefulWidget {
  const MyRssPage({super.key});

  @override
  State<MyRssPage> createState() => _MyRssPageState();
}

class _MyRssPageState extends State<MyRssPage> {
  final controller = Get.put(MyRssController());

  @override
  Widget build(BuildContext context) {
    return const Text("RSS 信息");
  }

  @override
  void dispose() {
    Get.delete<MyRssController>();
    super.dispose();
  }
}
