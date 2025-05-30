import 'package:harvest/api/hooks.dart';

import '../app/home/pages/models/task.dart';
import '../models/common_response.dart';
import '../models/flower.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

Future<CommonResponse> getScheduleList() async {
  return await fetchDataList(Api.TASK_OPERATE, (p0) => Schedule.fromJson(p0));
}

Future<CommonResponse> getTaskList() async {
  final response = await DioUtil().get(Api.TASK_RESULTS);
  if (response.statusCode == 200) {
    try {
      return CommonResponse.fromJson(response.data, (p0) => p0);
    } catch (e, trace) {
      Logger.instance.e(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse.error(msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> getCrontabList() async {
  final response = await DioUtil().get(Api.CRONTAB_LIST);
  if (response.statusCode == 200) {
    try {
      Map<int, Crontab> dataList = (response.data['data'] as List)
          .map<Crontab>((item) => Crontab.fromJson(item))
          .toList()
          .asMap()
          .entries
          .fold({}, (result, entry) {
        result[entry.value.id!.toInt()] = entry.value;
        return result;
      });
      String msg = '共有${dataList.length}个Crontab';
      return CommonResponse.success(data: dataList, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse.error(msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> execRemoteTask(Schedule schedule) async {
  final response = await DioUtil()
      .get(Api.TASK_EXEC_URL, queryParameters: {"task_id": schedule.id});
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '计划任务手动执行失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> editRemoteTask(Schedule schedule) async {
  // Map<String, dynamic> data = schedule.toJson();
  // final response = await DioUtil().put(Api.TASK_OPERATE, formData: data);
  // if (response.statusCode == 200) {
  //   return CommonResponse.fromJson(response.data, (p0) => null);
  // } else {
  //   String msg = '计划任务修改失败: ${response.statusCode}';
  //   // GFToast.showToast(msg, context);
  //   return CommonResponse(data: null, code: -1, msg: msg);
  // }
  return await editData(Api.TASK_OPERATE, schedule.toJson());
}

Future<CommonResponse> addRemoteTask(Schedule schedule) async {
  return await addData(Api.TASK_OPERATE, schedule.toJson());
}

Future<CommonResponse> removeRemoteTask(Schedule schedule) async {
  String apiUrl = '${Api.TASK_OPERATE}/${schedule.id}';
  return await removeData(apiUrl);
}

Future<CommonResponse> getTaskItemList() async {
  String apiUrl = Api.FLOWER_TASKS;
  try {
    var response = await DioUtil().get(apiUrl);
    if (response.statusCode == 200) {
      return CommonResponse.success(
          data: response.data as Map<String, dynamic>);
    } else {
      String msg = '获取数据列表失败: ${response.statusCode}';
      // GFToast.showToast(msg, context);
      return CommonResponse.error(msg: msg);
    }
  } catch (e, trace) {
    Logger.instance.e(e);
    Logger.instance.e(trace);
    String msg = '获取数据列表失败: ${e.toString()}';
    return CommonResponse.error(msg: msg);
  }
}

Future<CommonResponse> getTaskItemInfo(TaskItem item) async {
  String apiUrl = '${Api.FLOWER_TASKS_INFO}/${item.uuid}';
  return await fetchBasicData(apiUrl);
}

Future<CommonResponse> getTaskItemResult(TaskItem item) async {
  String apiUrl = '${Api.FLOWER_TASKS_RESULT}/${item.uuid}';
  return await fetchBasicData(apiUrl);
}

Future<CommonResponse> abortTaskItem(TaskItem item) async {
  String apiUrl = '${Api.FLOWER_TASKS_ABORT}/${item.uuid}';
  return await fetchBasicData(apiUrl);
}

Future<CommonResponse> revokeTaskItem(TaskItem item) async {
  String apiUrl = '${Api.FLOWER_TASKS_REVOKE}/${item.uuid}';
  return await fetchBasicData(apiUrl);
}
