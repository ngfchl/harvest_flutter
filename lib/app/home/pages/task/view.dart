import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../models/common_response.dart';
import '../../../../utils/logger_helper.dart';
import '../models/task.dart';
import 'controller.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key, param});

  final controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(builder: (controller) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: GetBuilder<TaskController>(builder: (controller) {
                return EasyRefresh(
                  onRefresh: () {
                    controller.getTaskInfo();
                  },
                  child: controller.isLoading
                      ? ListView(
                          children: const [Center(child: GFLoader())],
                        )
                      : GetBuilder<TaskController>(builder: (controller) {
                          return ListView.builder(
                            itemCount: controller.dataList.length,
                            itemBuilder: (BuildContext context, int index) {
                              Schedule task = controller.dataList[index];
                              return _buildTaskView(task, context);
                            },
                          );
                        }),
                );
              }),
            ),
            const SizedBox(height: 50),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildBottomButtonBar(context),
      );
    });
  }

  _buildBottomButtonBar(context) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () {
              controller.getTaskInfo();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () {
              editTask(null, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskView(Schedule item, context) {
    return GetBuilder<TaskController>(builder: (controller) {
      RxBool isRunning = false.obs;
      return CustomCard(
        margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
        child: Slidable(
          key: ValueKey('${item.id}_${item.name}'),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) async {
                  await editTask(item, context);
                },
                flex: 1,
                backgroundColor: const Color(0xFF0392CF),
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: '编辑',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: '确认',
                    radius: 5,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                    middleText: '确定要删除任务吗？',
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Get.back(result: true);
                          CommonResponse res =
                              await controller.removeTask(item);
                          if (res.code == 0) {
                            Get.snackbar('任务删除通知', res.msg.toString(),
                                colorText:
                                    Theme.of(context).colorScheme.primary);
                          } else {
                            Get.snackbar('任务删除通知', res.msg.toString(),
                                colorText: Theme.of(context).colorScheme.error);
                          }
                        },
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
                flex: 1,
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: '删除',
              ),
            ],
          ),
          child: ListTile(
            onTap: () async {},
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name!,
                  style: const TextStyle(fontSize: 12),
                ),
                if (item.crontab is int)
                  Text(
                    controller.crontabList[item.crontab!]!.express!,
                    style: const TextStyle(fontSize: 10, color: Colors.amber),
                  )
              ],
            ),
            subtitle: Text(
              item.task!,
              style: const TextStyle(fontSize: 10),
            ),
            leading: InkWell(
              onTap: () async {
                CommonResponse res = await controller.changeScheduleState(item);
                String title = item.enabled == true ? '任务启用通知' : '任务禁用通知';
                if (res.code == 0) {
                  Get.snackbar(title, res.msg.toString(),
                      snackStyle: SnackStyle.FLOATING,
                      colorText: Theme.of(context).colorScheme.primary);
                } else {
                  Get.snackbar(title, res.msg.toString(),
                      snackStyle: SnackStyle.FLOATING,
                      colorText: Theme.of(context).colorScheme.error);
                }
                controller.update();
              },
              child: item.enabled == true
                  ? const Icon(Icons.check_circle_outline, color: Colors.green)
                  : const Icon(Icons.pause_circle_outline, color: Colors.red),
            ),
            trailing: item.enabled == true
                ? Obx(() {
                    return InkWell(
                      onTap: () async {
                        isRunning.value = true;
                        // await Future.delayed(Duration(seconds: 2));
                        CommonResponse res = await controller.execTask(item);
                        if (res.code == 0) {
                          Get.snackbar('任务执行通知', res.msg.toString(),
                              colorText: Theme.of(context).colorScheme.primary);
                        } else {
                          Get.snackbar('任务执行通知', res.msg.toString(),
                              colorText: Theme.of(context).colorScheme.error);
                        }
                        isRunning.value = false;
                        controller.update();
                      },
                      child: isRunning.value == false
                          ? const Icon(Icons.play_circle_outline,
                              color: Colors.green)
                          : const GFLoader(size: 20),
                    );
                  })
                : const SizedBox.shrink(),
          ),
        ),
      );
    });
  }

  editTask(Schedule? task, context) {
    Crontab? cron = controller.crontabList[task?.crontab];
    final taskController =
        TextEditingController(text: task != null ? task.task : '');
    final nameController =
        TextEditingController(text: task != null ? task.name : '');
    final minuteController =
        TextEditingController(text: task != null ? cron?.minute : '1');
    final hourController =
        TextEditingController(text: task != null ? cron?.hour : '*');
    final dayOfWeekController =
        TextEditingController(text: task != null ? cron?.dayOfMonth : '*');
    final dayOfMonthController =
        TextEditingController(text: task != null ? cron?.dayOfMonth : '*');
    final monthOfYearController =
        TextEditingController(text: task != null ? cron?.monthOfYear : '*');
    final descriptionController =
        TextEditingController(text: task != null ? task.description : '');
    final argsController =
        TextEditingController(text: task != null ? task.args : '[]');
    final kwargsController =
        TextEditingController(text: task != null ? task.kwargs : '{}');
    Rx<bool?> enabled = (task != null ? task.enabled : true).obs;
    RxBool advance = false.obs;
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      Obx(() {
        return CustomCard(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      task != null ? '编辑任务' : '添加任务',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: SwitchListTile(
                        dense: true,
                        title: const Text(
                          '高级',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (val) {
                          advance.value = val;
                        },
                        value: advance.value,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CustomPickerField(
                        controller: taskController,
                        labelText: '选择任务',
                        data: controller.taskList,
                        onConfirm: (p, position) {}),
                    CustomTextField(
                      controller: nameController,
                      labelText: '任务名称',
                    ),
                    CustomTextField(
                      controller: minuteController,
                      labelText: '分钟',
                    ),
                    CustomTextField(
                      controller: hourController,
                      labelText: '小时',
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '开启任务',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        onChanged: (val) {
                          enabled.value = val;
                        },
                        value: enabled.value!,
                        activeColor: Colors.green,
                      ),
                    ),
                    if (advance.value) ...[
                      CustomTextField(
                        controller: dayOfWeekController,
                        labelText: '周几',
                      ),
                      CustomTextField(
                        controller: dayOfMonthController,
                        labelText: '几号',
                      ),
                      CustomTextField(
                        controller: monthOfYearController,
                        labelText: '几月',
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.cancel,
                        size: 18,
                      ),
                      label: const Text('取消'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (task == null) {
                          task = Schedule(
                            id: 0,
                            name: nameController.text,
                            task: taskController.text,
                            description: descriptionController.text,
                            crontab: Crontab(
                              minute: minuteController.text,
                              hour: hourController.text,
                              dayOfWeek: dayOfWeekController.text,
                              dayOfMonth: dayOfMonthController.text,
                              monthOfYear: monthOfYearController.text,
                            ),
                            args: argsController.text,
                            kwargs: kwargsController.text,
                          );
                        } else {
                          task?.enabled = enabled.value;
                          task?.name = nameController.text;
                          task?.task = taskController.text;
                          task?.description = descriptionController.text;
                          task?.args = argsController.text;
                          task?.kwargs = kwargsController.text;
                          cron?.minute = minuteController.text;
                          cron?.hour = hourController.text;
                          cron?.dayOfWeek = dayOfWeekController.text;
                          cron?.dayOfMonth = dayOfMonthController.text;
                          cron?.monthOfYear = monthOfYearController.text;
                          task?.crontab = cron;
                        }
                        Logger.instance.i(task?.toJson());
                        CommonResponse res = await controller.saveTask(task);
                        if (res.code == 0) {
                          Logger.instance.i('更新任务列表！');
                          Get.back();
                        }
                        controller.update();
                      },
                      label: const Text('保存'),
                      icon: const Icon(Icons.save, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
