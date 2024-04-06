import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';

import '../../../../api/task.dart';
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
      return Card(
        margin: const EdgeInsets.only(top: 8, left: 5, right: 5),
        child: ListTile(
          onTap: () async {
            CommonResponse res = await editTask(item);
            if (res.code == 0) {
              Logger.instance.i('更新任务列表！');
              controller.getTaskInfo();
              controller.update();
              Get.back();
            }
          },
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
          trailing: IconButton(
            onPressed: () async {
              CommonResponse res = await controller.changeScheduleState(item);
              if (res.code == 0) {
                Logger.instance.i('更新任务列表！');
              }

              controller.update();
            },
            icon: item.enabled == true
                ? const Icon(Icons.check_circle_outline, color: Colors.green)
                : const Icon(Icons.info_outline, color: Colors.red),
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
    Rx<bool?> enabled = (task != null ? task.enabled : false).obs;
    RxBool advance = false.obs;
    Get.bottomSheet(
      backgroundColor: Colors.blueGrey.shade100,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(3))),
      SingleChildScrollView(
        child: Obx(() {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // const GFTypography(
                    //   text: '编辑任务',
                    //   type: GFTypographyType.typo4,
                    //   textColor: Colors.white38,
                    //   dividerColor: Colors.white38,
                    // ),
                    const Text('编辑任务'),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '高级',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          advance.value
                              ? IconButton(
                                  onPressed: () {
                                    advance.value = false;
                                  },
                                  icon: const Icon(
                                    Icons.expand_more,
                                    color: Colors.white70,
                                  ))
                              : IconButton(
                                  onPressed: () {
                                    advance.value = true;
                                  },
                                  icon: const Icon(
                                    Icons.navigate_next,
                                    color: Colors.white70,
                                  )),
                        ],
                      ),
                    ),
                  ],
                ),
                CustomPickerField(
                    controller: taskController,
                    labelText: '选择任务',
                    data: controller.taskList,
                    onConfirm: (p, position) {}),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '开启任务',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    CupertinoSwitch(
                      onChanged: (val) {
                        enabled.value = val;
                      },
                      value: enabled.value!,
                      activeColor: Colors.green,
                    ),
                  ],
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
                // Container(
                //   padding: const EdgeInsets.all(10),
                //   child: TransferList(
                //     leftList: const [
                //       'Dog',
                //       'Cat',
                //       'Mouse',
                //       'Rabbit',
                //       'Lion',
                //       'Tiger',
                //       'Fox',
                //       'Wolf'
                //     ],
                //     rightList: json.decode(task.args!),
                //     onChange: (leftList, rightList) {
                //       // your logic
                //     },
                //     listBackgroundColor: Colors.grey.withOpacity(0.6),
                //     textStyle: const TextStyle(color: Colors.black38),
                //     tileSplashColor: Colors.white,
                //     checkboxFillColor: Colors.transparent,
                //   ),
                // ),
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

  List<Widget> _buildTaskList() {
    return controller.dataList
        .map((item) => GFCard(
              color: Colors.white54,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              border: Border.all(
                color: Colors.teal.shade300,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              title: GFListTile(
                icon: Card(
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      controller.crontabList[item.crontab!]!.express!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                onLongPress: () {
                  Get.snackbar('title', '删除任务？');
                },
                onTap: () {
                  Get.defaultDialog(
                    title: '运行任务',
                    middleText: '确定要运行？',
                    textCancel: '取消',
                    textConfirm: '确定',
                    backgroundColor: Colors.teal.withOpacity(0.7),
                    titleStyle: const TextStyle(color: Colors.white),
                    middleTextStyle: const TextStyle(color: Colors.white),
                    onCancel: () {
                      Get.back();
                    },
                    onConfirm: () {
                      execRemoteTask(item.id!).then((res) {
                        Get.back();
                        if (res.code == 0) {
                          Get.snackbar(
                            '执行任务',
                            '${item.name!} 任务ID：${res.msg}',
                            colorText: Colors.black38,
                            backgroundColor: Colors.teal.withOpacity(0.7),
                          );
                        } else {
                          Get.snackbar(
                            '执行任务',
                            '${item.name!} 任务执行出错啦：${res.msg}',
                            colorText: Colors.red,
                            backgroundColor: Colors.teal.withOpacity(0.7),
                          );
                        }
                      });
                    },
                  );
                },
                padding: const EdgeInsets.all(0),
                title: Text(
                  item.name!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
                // subTitle: Text(
                //   controller.taskList[item.task!]!.desc!,
                //   style: const TextStyle(
                //     fontSize: 12,
                //     color: Colors.black38,
                //   ),
                // ),

                // description: Text(
                //   controller.taskList[item.task!]!.desc!,
                //   style: TextStyle(
                //     fontSize: 12,
                //     color: Colors.lightBlue,
                //   ),
                // ),
              ),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  SizedBox(
                    width: 58,
                    height: 26,
                    child: GFButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: item.enabled! ? '关闭任务' : '开启任务',
                          middleText: item.enabled! ? '确定要？' : '确定要开启？',
                          onCancel: () {
                            Get.back();
                          },
                          onConfirm: () {
                            item.enabled!
                                ? item.enabled = false
                                : item.enabled = true;
                            editRemoteTask(item).then((res) {
                              Get.back();
                              if (res.code == 0) {
                                controller.getTaskInfo();
                                Get.snackbar(
                                  item.enabled! ? '关闭任务' : '开启任务',
                                  '${res.msg}',
                                  colorText: Colors.black38,
                                  backgroundColor: Colors.teal.withOpacity(0.7),
                                );
                              } else {
                                Get.snackbar(
                                  item.enabled! ? '关闭任务' : '开启任务',
                                  '${res.msg}',
                                  colorText: Colors.red,
                                  backgroundColor: Colors.teal.withOpacity(0.7),
                                );
                              }
                            });
                          },
                          textCancel: '取消',
                          textConfirm: '确定',
                        );
                      },
                      color:
                          item.enabled! ? GFColors.WARNING : GFColors.SUCCESS,
                      text: item.enabled! ? '禁用' : '启用',
                      size: GFSize.SMALL,
                    ),
                  ),
                  SizedBox(
                    width: 58,
                    height: 26,
                    child: GFButton(
                      onPressed: () {
                        editTask(item);
                      },
                      text: '编辑',
                      size: GFSize.SMALL,
                      color: GFColors.SECONDARY,
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }
}
