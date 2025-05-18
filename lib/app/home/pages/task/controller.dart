import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/task.dart';
import '../../../../models/flower.dart';
import '../../../../utils/logger_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  bool isLoading = false;
  List<Schedule> dataList = <Schedule>[];
  Schedule? selectedTask;
  Map<int, Crontab> crontabList = <int, Crontab>{};
  List<String> taskList = [];
  List<TaskItem> taskItemList = [];

  @override
  void onInit() {
    super.onInit();
    getTaskInfo();
    update();
  }

  getTaskInfo() async {
    isLoading = true;
    update();

    try {
      final taskRes = await getTaskList();
      if (taskRes.code == 0) {
        taskList = taskRes.data.cast<String>();
      } else {
        Get.snackbar('', taskRes.msg.toString());
      }

      final crontabRes = await getCrontabList();
      if (crontabRes.code == 0) {
        crontabList = crontabRes.data;
      } else {
        Get.snackbar('', crontabRes.msg.toString());
      }

      final scheduleRes = await getScheduleList();
      if (scheduleRes.code == 0) {
        dataList = scheduleRes.data;
      } else {
        Get.snackbar('解析出错啦！', scheduleRes.msg.toString());
      }

      final taskItemListRes = await getTaskItemList();
      Logger.instance.d(taskItemListRes);
      if (taskItemListRes.succeed) {
        taskItemList = taskItemListRes.data.values
            .map<TaskItem>((e) => TaskItem.fromJson(e))
            .toList();
        update();
      }
    } catch (e, stack) {
      Logger.instance.e(e);
      Logger.instance.e(stack);
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<CommonResponse> changeScheduleState(Schedule task) async {
    task.enabled = !task.enabled!;
    return await saveTask(task);
  }

  Future<CommonResponse> execTask(Schedule task) async {
    return await execRemoteTask(task);
  }

  Future<CommonResponse> removeTask(Schedule task) async {
    CommonResponse res = await removeRemoteTask(task);
    getTaskInfo();
    update();
    return res;
  }

  Future<CommonResponse> saveTask(Schedule? task) async {
    CommonResponse res;
    if (task?.id == 0) {
      res = await addRemoteTask(task!);
    } else {
      Logger.instance.i('修改任务！');
      res = await editRemoteTask(task!);
    }
    if (res.code == 0) {
      Logger.instance.i('更新任务列表！');
      getTaskInfo();
    }
    update();
    return res;
  }

  getTaskItemInfo(TaskItem item) async {
    return await getTaskItemInfo(item);
  }

  getTaskResult(TaskItem item) async {
    return await getTaskItemResult(item);
  }

  abortTask(TaskItem item) async {
    return await abortTaskItem(item);
  }

  revokeTask(TaskItem item) async {
    return await revokeTaskItem(item);
  }
}
