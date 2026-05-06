import '../../../core/http/api.dart';
import '../../../core/http/hooks.dart';
import '../model/schedule.dart';

class ScheduleService {
  ScheduleService._();

  static const _base = API.TASK_OPERATE;

  /// 获取可选任务类型列表
  static Future<List<String>> fetchTaskList() async {
    return List<String>.from(await fetchBasicList(API.TASK_LIST));
  }

  /// 获取计划任务列表
  static Future<List<Schedule>> fetchScheduleList() {
    return fetchModelList(_base, Schedule.fromJson);
  }

  /// 获取单个任务
  static Future<Schedule?> fetchOne(int id) {
    return fetchModel('$_base/$id', Schedule.fromJson);
  }

  /// 新增任务
  static Future<void> create(Schedule schedule) {
    return addData(_base, schedule.toJson());
  }

  /// 编辑任务 — 不带 ID，ID 在 body 里
  static Future<void> update(Schedule schedule) {
    return editData(_base, schedule.toJson());
  }

  /// 保存（新增 or 编辑）
  static Future<void> save(Schedule schedule) {
    return schedule.id == 0 ? create(schedule) : update(schedule);
  }

  /// 切换启用状态
  static Future<void> toggle(int id, bool enabled) {
    // AppLogger.info("任务切换状态失败！");
    return editData(_base, {"id": id, 'enabled': enabled});
  }

  /// 删除任务
  static Future<void> delete(int id) {
    return removeData('$_base/$id');
  }

  /// 立即执行
  static Future<void> runOnce(int id) {
    return fetchBasic(API.TASK_EXEC_URL, queryParameters: {'task_id': id});
  }
}
