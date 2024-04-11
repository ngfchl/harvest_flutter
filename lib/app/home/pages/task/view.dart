import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/glass_widget.dart';
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
        backgroundColor: Colors.transparent,
        body: GlassWidget(
          child: GetBuilder<TaskController>(builder: (controller) {
            return EasyRefresh(
              onRefresh: () {
                controller.getTaskInfo();
              },
              child: controller.isLoading
                  ? const GFLoader()
                  : GetBuilder<TaskController>(builder: (controller) {
                      return ListView.builder(
                        itemCount: controller.dataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          Schedule task = controller.dataList[index];
                          return _buildTaskView(task);
                        },
                      );
                    }),
            );
          }),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GFIconButton(
              icon: const Icon(Icons.add),
              shape: GFIconButtonShape.standard,
              color: GFColors.PRIMARY.withOpacity(0.6),
              onPressed: () {
                editTask(null);
              },
            ),
            const SizedBox(height: 72)
          ],
        ),
      );
    });
  }

  Widget _buildTaskView(Schedule item) {
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
                  CommonResponse res = await editTask(item);
                  if (res.code == 0) {
                    Logger.instance.i('更新任务列表！');
                    controller.getTaskInfo();
                    controller.update();
                    Get.back();
                  }
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
                    backgroundColor: Colors.white,
                    radius: 5,
                    titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.deepPurple),
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
                                backgroundColor: Colors.green.shade500,
                                colorText: Colors.white70);
                          } else {
                            Get.snackbar('任务删除通知', res.msg.toString(),
                                backgroundColor: Colors.red.shade500,
                                colorText: Colors.white70);
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

          // The end action pane is the one at the right or the bottom side.
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
              style: const TextStyle(fontSize: 10, color: Colors.black38),
            ),
            trailing: SizedBox(
              width: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.enabled == true)
                    Obx(() {
                      return InkWell(
                        onTap: () async {
                          isRunning.value = true;
                          // await Future.delayed(Duration(seconds: 2));
                          CommonResponse res = await controller.execTask(item);
                          if (res.code == 0) {
                            Get.snackbar('任务执行通知', res.msg.toString(),
                                backgroundColor: Colors.green.shade500,
                                colorText: Colors.white70);
                          } else {
                            Get.snackbar('任务执行通知', res.msg.toString(),
                                backgroundColor: Colors.red.shade500,
                                colorText: Colors.white70);
                          }
                          isRunning.value = false;
                          controller.update();
                        },
                        child: isRunning.value == false
                            ? const Icon(Icons.play_circle_outline,
                                color: Colors.green)
                            : const GFLoader(size: 20),
                      );
                    }),
                  InkWell(
                    onTap: () async {
                      CommonResponse res =
                          await controller.changeScheduleState(item);
                      String title = item.enabled == true ? '任务启用通知' : '任务禁用通知';
                      if (res.code == 0) {
                        Get.snackbar(title, res.msg.toString(),
                            snackStyle: SnackStyle.FLOATING,
                            backgroundColor: Colors.green.shade500,
                            colorText: Colors.white70);
                      } else {
                        Get.snackbar(title, res.msg.toString(),
                            snackStyle: SnackStyle.FLOATING,
                            backgroundColor: Colors.red.shade500,
                            colorText: Colors.white70);
                      }
                      controller.update();
                    },
                    child: item.enabled == true
                        ? const Icon(Icons.check_circle_outline,
                            color: Colors.green)
                        : const Icon(Icons.pause_circle_outline,
                            color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  editTask(Schedule? task) {
    Crontab? cron = controller.crontabList[task?.crontab];
    final taskController =
        TextEditingController(text: task != null ? task.task : '');
    final nameController =
        TextEditingController(text: task != null ? task.name : '');
    final minuteController =
        TextEditingController(text: task != null ? cron?.minute : '');
    final hourController =
        TextEditingController(text: task != null ? cron?.hour : '');
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
      // backgroundColor: Colors.blueGrey.shade100,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      SingleChildScrollView(
        child: Obx(() {
          return CustomCard(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('编辑任务'),
                    SizedBox(
                      width: 100,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '高级',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
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
                CustomPickerField(
                    controller: taskController,
                    labelText: '选择任务',
                    data: controller.taskList,
                    onConfirm: (p, position) {}),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '开启任务',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  onChanged: (val) {
                    enabled.value = val;
                  },
                  value: enabled.value!,
                  activeColor: Colors.green,
                ),
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
                if (advance.value)
                  Column(
                    children: [
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
                  ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GFButton(
                        onPressed: () {
                          Get.back();
                        },
                        color: GFColors.SUCCESS,
                        text: '取消',
                        size: GFSize.SMALL,
                      ),
                      GFButton(
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
                          CommonResponse res = await controller.saveTask(task);
                          if (res.code == 0) {
                            Logger.instance.i('更新任务列表！');
                            Get.back();
                          }
                          controller.update();
                        },
                        text: '保存',
                        color: GFColors.DANGER,
                        size: GFSize.SMALL,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
