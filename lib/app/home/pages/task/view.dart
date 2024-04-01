import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return const Text("Task Page");
  }

  @override
  void dispose() {
    Get.delete<TaskController>();
    super.dispose();
  }
}
