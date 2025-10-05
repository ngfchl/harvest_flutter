import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/card_view.dart';
import '../../../../common/form_widgets.dart';
import '../../../../common/utils.dart';
import '../../../../models/common_response.dart';
import '../../../../models/flower.dart';
import '../../../../utils/logger_helper.dart';
import '../models/task.dart';
import 'controller.dart';

class TaskPage extends StatelessWidget {
  TaskPage({super.key, param});

  final controller = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    ShadColorScheme shadColorScheme = ShadTheme.of(context).colorScheme;

    List<Tab> tabs = const [
      Tab(text: '计划任务'),
      Tab(text: '任务记录'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: TabBar(
          tabs: tabs,
          labelStyle: const TextStyle(fontSize: 13),
          indicatorColor: shadColorScheme.primary,
          labelColor: shadColorScheme.primary,
          unselectedLabelColor: shadColorScheme.foreground.withOpacity(0.8),
        ),
        body: GetBuilder<TaskController>(builder: (controller) {
          return TabBarView(
            physics: const BouncingScrollPhysics(),
            children: [
              Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: ShadIconButton.ghost(
                  icon: Icon(Icons.add, size: 28),
                  onPressed: () {
                    editTask(null, context);
                  },
                ),
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
                                  children: [
                                    Center(
                                        child: CircularProgressIndicator(
                                      color: shadColorScheme.primary,
                                    ))
                                  ],
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
              ),
              EasyRefresh(
                onRefresh: () => controller.getTaskInfo(),
                child: ListView.builder(
                  itemCount: controller.taskItemList.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    TaskItem item = controller.taskItemList[index];
                    var shadColorScheme = ShadTheme.of(context).colorScheme;
                    return CustomCard(
                      child: Slidable(
                        key: ValueKey(item.uuid),
                        endActionPane: item.state?.toLowerCase() == 'success' || item.state?.toLowerCase() == 'failed'
                            ? ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    flex: 1,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    onPressed: (context) async {
                                      Get.defaultDialog(
                                        title: '任务执行结果',
                                        content: item.state?.toLowerCase() == 'success'
                                            ? Text(item.result!)
                                            : Text(item.traceback.toString()),
                                      );
                                    },
                                    backgroundColor: const Color(0xFF0A9D96),
                                    foregroundColor: Colors.white,
                                    icon: Icons.copy_sharp,
                                    label: '结果',
                                  ),
                                ],
                              )
                            : ActionPane(
                                motion: const ScrollMotion(),
                                extentRatio: 0.5,
                                children: [
                                  SlidableAction(
                                    flex: 1,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    onPressed: (context) async {
                                      Get.defaultDialog(
                                        title: '确认',
                                        radius: 5,
                                        titleStyle: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                                        middleText: '确定要删除任务吗？',
                                        actions: [
                                          ShadButton(
                                            onPressed: () {
                                              Get.back(result: false);
                                            },
                                            child: const Text('取消'),
                                          ),
                                          ShadButton(
                                            onPressed: () async {
                                              Get.back(result: true);
                                              var res = await controller.abortTask(item);
                                              if (res.code == 0) {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.foreground);
                                              } else {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.destructive);
                                              }
                                            },
                                            child: const Text('确认'),
                                          ),
                                        ],
                                      );
                                    },
                                    backgroundColor: const Color(0xFFB11211),
                                    foregroundColor: Colors.white,
                                    // icon: Icons.delete,
                                    label: '取消',
                                  ),
                                  SlidableAction(
                                    flex: 1,
                                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                                    onPressed: (context) async {
                                      Get.defaultDialog(
                                        title: '确认',
                                        radius: 5,
                                        titleStyle: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w900, color: Colors.deepPurple),
                                        middleText: '确定要删除任务吗？',
                                        actions: [
                                          ShadButton(
                                            onPressed: () {
                                              Get.back(result: false);
                                            },
                                            child: const Text('取消'),
                                          ),
                                          ShadButton(
                                            onPressed: () async {
                                              Get.back(result: true);
                                              var res = await controller.revokeTask(item);
                                              if (res.code == 0) {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.foreground);
                                              } else {
                                                Get.snackbar('删除通知', res.msg.toString(),
                                                    colorText: shadColorScheme.destructive);
                                              }
                                            },
                                            child: const Text('确认'),
                                          ),
                                        ],
                                      );
                                    },
                                    backgroundColor: const Color(0xFFE30303),
                                    foregroundColor: Colors.white,
                                    // icon: Icons.delete,
                                    label: '中断',
                                  ),
                                ],
                              ),
                        child: ListTile(
                          dense: true,
                          title: Text(
                            item.name ?? 'unknown',
                            style: TextStyle(fontSize: 10, color: shadColorScheme.foreground),
                          ),
                          subtitle: item.succeeded != null
                              ? Text(
                                  "完成时间：${DateTime.fromMillisecondsSinceEpoch((item.succeeded! * 1000).toInt())}",
                                  style: TextStyle(fontSize: 8, color: Colors.green),
                                )
                              : item.started != null
                                  ? Text(
                                      "开始时间：${DateTime.fromMillisecondsSinceEpoch((item.started! * 1000).toInt())}",
                                      style: TextStyle(fontSize: 8, color: Colors.orange),
                                    )
                                  : item.received != null
                                      ? Text(
                                          "接收时间：${DateTime.fromMillisecondsSinceEpoch((item.received! * 1000).toInt())}",
                                          style: TextStyle(fontSize: 8, color: Colors.blue),
                                        )
                                      : null,
                          trailing: SizedBox(
                              width: 60,
                              child: CustomTextTag(
                                labelText: item.state?.toLowerCase() ?? 'unknown',
                              )),
                          onTap: () {
                            item.succeeded == null && item.failed == null
                                ? Get.defaultDialog(
                                    title: '任务详情',
                                    content: CustomCard(
                                      height: Get.height * 0.6,
                                      width: Get.width * 0.8,
                                      padding: const EdgeInsets.all(8),
                                      child: Text('任务尚未完成，请稍后查看结果！'),
                                    ),
                                  )
                                : Get.defaultDialog(
                                    title: '任务详情',
                                    content: Container(
                                      height: Get.height * 0.6,
                                      width: Get.width * 0.8,
                                      padding: const EdgeInsets.all(8),
                                      child: Markdown(
                                        data: item.result?.substring(1, item.result!.length - 2) ?? '',
                                        softLineBreak: true, // ⬅️ 每个 \n 都当作 <br> 处理
                                        styleSheet: MarkdownStyleSheet.fromTheme(ShadTheme.of(context) as ThemeData),
                                      ),
                                    ),
                                  );
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTaskView(Schedule item, context) {
    var shadColorScheme = ShadTheme.of(context).colorScheme;
    return GetBuilder<TaskController>(builder: (controller) {
      RxBool isRunning = false.obs;
      return CustomCard(
        child: Slidable(
          key: ValueKey('${item.id}_${item.name}'),
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.25,
            children: [
              SlidableAction(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                onPressed: (context) async {
                  editTask(item, context);
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
            extentRatio: 0.25,
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
                      ShadButton(
                        onPressed: () {
                          Get.back(result: false);
                        },
                        child: const Text('取消'),
                      ),
                      ShadButton(
                        onPressed: () async {
                          Get.back(result: true);
                          CommonResponse res = await controller.removeTask(item);

                          if (res.code == 0) {
                            Get.snackbar('任务删除通知', res.msg.toString(), colorText: shadColorScheme.foreground);
                          } else {
                            Get.snackbar('任务删除通知', res.msg.toString(), colorText: shadColorScheme.destructive);
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
                  style: TextStyle(
                    fontSize: 12,
                    color: shadColorScheme.foreground,
                  ),
                ),
                if (item.crontab is int)
                  Text(
                    controller.crontabList[item.crontab!]?.express ?? "",
                    style: TextStyle(
                      fontSize: 10,
                      color: shadColorScheme.foreground.withOpacity(0.8),
                    ),
                  )
              ],
            ),
            subtitle: Text(
              item.task!,
              style: TextStyle(
                fontSize: 10,
                color: shadColorScheme.foreground.withOpacity(0.8),
              ),
            ),
            leading: InkWell(
              onTap: () async {
                CommonResponse res = await controller.changeScheduleState(item);
                String title = item.enabled == true ? '任务启用通知' : '任务禁用通知';
                if (res.code == 0) {
                  Get.snackbar(title, res.msg.toString(),
                      snackStyle: SnackStyle.FLOATING, colorText: shadColorScheme.foreground);
                } else {
                  Get.snackbar(title, res.msg.toString(),
                      snackStyle: SnackStyle.FLOATING, colorText: shadColorScheme.destructive);
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
                          Get.snackbar('任务执行通知', res.msg.toString(), colorText: shadColorScheme.foreground);
                        } else {
                          Get.snackbar('任务执行通知', res.msg.toString(), colorText: shadColorScheme.destructive);
                        }
                        isRunning.value = false;
                        controller.update();
                      },
                      child: isRunning.value == false
                          ? const Icon(Icons.play_circle_outline, color: Colors.green)
                          : Center(
                              child: CircularProgressIndicator(
                              color: shadColorScheme.primary,
                            )),
                    );
                  })
                : const SizedBox.shrink(),
          ),
        ),
      );
    });
  }

  void editTask(Schedule? task, context) {
    Crontab? cron = controller.crontabList[task?.crontab];
    final taskController = TextEditingController(text: task != null ? task.task : controller.taskList.first);
    final nameController = TextEditingController(text: task != null ? task.name : '');
    final minuteController = TextEditingController(text: task != null ? cron?.minute : '1');
    final hourController = TextEditingController(text: task != null ? cron?.hour : '*');
    final dayOfWeekController = TextEditingController(text: task != null ? cron?.dayOfWeek : '*');
    final dayOfMonthController = TextEditingController(text: task != null ? cron?.dayOfMonth : '*');
    final monthOfYearController = TextEditingController(text: task != null ? cron?.monthOfYear : '*');
    final descriptionController = TextEditingController(text: task != null ? task.description : '');
    final argsController = TextEditingController(text: task != null ? task.args : '[]');
    final kwargsController = TextEditingController(text: task != null ? task.kwargs : '{}');
    Rx<bool?> enabled = (task != null ? task.enabled : true).obs;
    RxBool advance = false.obs;
    ShadColorScheme shadColorScheme = ShadTheme.of(context).colorScheme;
    Get.bottomSheet(
      backgroundColor: shadColorScheme.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    task != null ? '编辑任务' : '添加任务',
                    style: TextStyle(
                      color: shadColorScheme.foreground,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: Obx(() {
                      return SwitchListTile(
                        dense: true,
                        title: Text(
                          '高级',
                          style: TextStyle(
                            fontSize: 13,
                            color: shadColorScheme.foreground.withOpacity(0.8),
                          ),
                        ),
                        onChanged: (val) {
                          advance.value = val;
                        },
                        value: advance.value,
                        activeColor: shadColorScheme.primary,
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ShadSelect<String>(
                          placeholder: const Text('选择任务'),
                          initialValue: controller.taskList.first,
                          options: controller.taskList.map((key) => ShadOption(value: key, child: Text(key))).toList(),
                          selectedOptionBuilder: (context, value) {
                            return Text(value);
                          },
                          onChanged: (String? value) {
                            taskController.text = value!;
                          }),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '开启任务',
                          style: TextStyle(
                            fontSize: 13,
                            color: shadColorScheme.foreground.withOpacity(0.8),
                          ),
                        ),
                        onChanged: (val) {
                          enabled.value = val;
                        },
                        value: enabled.value!,
                        activeColor: shadColorScheme.primary,
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
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShadButton.destructive(
                    size: ShadButtonSize.sm,
                    onPressed: () {
                      Get.back();
                    },
                    leading: Icon(
                      Icons.cancel,
                      size: 18,
                      color: shadColorScheme.destructiveForeground,
                    ),
                    child: Text('取消', style: TextStyle(color: shadColorScheme.destructiveForeground)),
                  ),
                  ShadButton(
                    size: ShadButtonSize.sm,
                    onPressed: () async {
                      bool res1 = checkEditController(nameController, "任务名称", context);
                      bool res2 = checkEditController(taskController, "计划任务", context);
                      bool res3 = checkEditController(minuteController, "任务执行时间：分钟", context);
                      bool res4 = checkEditController(hourController, "任务执行时间：小时", context);
                      if (!res1 || !res2 || !res3 || !res4) {
                        return;
                      }
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
                    leading: Icon(
                      Icons.save,
                      size: 18,
                      color: shadColorScheme.primaryForeground,
                    ),
                    child: Text(
                      '保存',
                      style: TextStyle(color: shadColorScheme.primaryForeground),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
