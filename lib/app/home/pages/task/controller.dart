import 'package:get/get.dart';
import 'package:harvest/models/common_response.dart';

import '../../../../api/task.dart';
import '../../../../utils/logger_helper.dart';
import '../models/task.dart';

class TaskController extends GetxController {
  bool isLoading = false;
  List<Schedule> dataList = <Schedule>[];
  Schedule? selectedTask;
  Map<int, Crontab> crontabList = <int, Crontab>{};
  List<String> taskList = [];

  @override
  void onInit() {
    getTaskInfo();
    update();
    super.onInit();
  }

  void getTaskInfo() {
    isLoading = true;
    update();
    getTaskList().then((value) {
      if (value.code == 0) {
        taskList = value.data.cast<String>();
        update();
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e, trace) {
      Logger.instance.e(e);
      Logger.instance.e(trace);
      Get.snackbar('', e.toString());
    });
    getCrontabList().then((value) {
      if (value.code == 0) {
        crontabList = value.data;
        update();
      } else {
        Get.snackbar('', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('', e.toString());
    });
    getScheduleList().then((value) {
      if (value.code == 0) {
        dataList = value.data;
      } else {
        Get.snackbar('解析出错啦！', value.msg.toString());
      }
    }).catchError((e) {
      Get.snackbar('网络访问出错啦', e.toString());
    });
    isLoading = false;
    update();
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
}
