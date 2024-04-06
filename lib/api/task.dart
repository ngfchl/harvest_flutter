import '../app/home/pages/models/task.dart';
import '../models/common_response.dart';
import '../utils/dio_util.dart';
import '../utils/logger_helper.dart';
import 'api.dart';

Future<CommonResponse> getScheduleList() async {
  final response = await DioUtil().get(Api.TASK_OPERATE);
  if (response.statusCode == 200) {
    try {
      final dataList = (response.data['data'] as List)
          .map<Schedule>((item) => Schedule.fromJson(item))
          .toList();
      String msg = '共有${dataList.length}个任务';
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> getTaskList() async {
  final response = await DioUtil().get(Api.TASK_RESULTS);
  if (response.statusCode == 200) {
    try {
      return CommonResponse.fromJson(response.data, (p0) => p0);
    } catch (e, trace) {
      Logger.instance.e(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
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
      return CommonResponse(data: dataList, code: 0, msg: msg);
    } catch (e, trace) {
      Logger.instance.w(trace);
      String msg = 'Model解析出错啦！';
      return CommonResponse(data: null, code: -1, msg: msg);
    }
  } else {
    String msg = '获取主页状态失败: ${response.statusCode}';
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> execRemoteTask(int taskId) async {
  final response = await DioUtil()
      .get(Api.TASK_EXEC_URL, queryParameters: {"task_id": taskId});
  if (response.statusCode == 200) {
    Logger.instance.w(response.data);
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '计划任务手动执行失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}

Future<CommonResponse> editRemoteTask(Schedule schedule) async {
  Map<String, dynamic> data = schedule.toJson();
  final response = await DioUtil().put(Api.TASK_OPERATE, formData: data);
  if (response.statusCode == 200) {
    return CommonResponse.fromJson(response.data, (p0) => null);
  } else {
    String msg = '计划任务修改失败: ${response.statusCode}';
    // GFToast.showToast(msg, context);
    return CommonResponse(data: null, code: -1, msg: msg);
  }
}
