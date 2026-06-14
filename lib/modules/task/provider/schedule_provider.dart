import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/schedule.dart';
import '../model/task_result.dart';
import '../service/schedule_service.dart';
import 'crontab_provider.dart';

final scheduleProvider =
    AsyncNotifierProvider<ScheduleNotifier, List<Schedule>>(
      ScheduleNotifier.new,
    );

const _scheduleCacheKey = 'task.schedule.list';

final scheduleCacheInfoProvider = StateProvider<DataCacheInfo>(
  (_) => const DataCacheInfo.none(),
);

class ScheduleNotifier extends AsyncNotifier<List<Schedule>> {
  @override
  Future<List<Schedule>> build() async {
    if (!HiveManager.hasAccessToken) return const <Schedule>[];

    final cached = SessionCache.read<List<Schedule>>(
      _scheduleCacheKey,
      (data) => (data as List)
          .map(
            (item) => Schedule.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
    if (cached != null) {
      Future<void>.delayed(Duration.zero, () {
        ref.read(scheduleCacheInfoProvider.notifier).state =
            DataCacheInfo.cached(cached.cachedAt);
        if (HiveManager.hasAccessToken) refresh();
      });
      return cached.data;
    }

    return _fetchAndCache(updateCacheInfo: false);
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.value ?? const <Schedule>[]);
      return;
    }

    final previous = state.value;
    final next = await AsyncValue.guard(_fetchAndCache);
    state = next.hasError && previous != null
        ? AsyncValue.data(previous)
        : next;
  }

  Future<List<Schedule>> _fetchAndCache({bool updateCacheInfo = true}) async {
    if (!HiveManager.hasAccessToken) return const <Schedule>[];

    final list = await ScheduleService.fetchScheduleList();
    final info = await SessionCache.write(
      _scheduleCacheKey,
      list.map((e) => e.toJson()).toList(),
    );
    if (updateCacheInfo) {
      ref.read(scheduleCacheInfoProvider.notifier).state = info;
    }
    return list;
  }

  Future<void> save(Schedule schedule) async {
    await ScheduleService.save(schedule);
    ref.invalidate(crontabListProvider);
    await refresh();
  }

  Future<void> toggle(int id, bool enabled) async {
    await ScheduleService.toggle(id, enabled);
    await refresh();
  }

  Future<void> delete(int id) async {
    await ScheduleService.delete(id);
    await refresh();
  }

  Future<void> runOnce(int id) {
    return ScheduleService.runOnce(id);
  }
}

final taskTypeListProvider = FutureProvider<List<String>>((ref) {
  if (!HiveManager.hasAccessToken) return Future.value(const <String>[]);
  return ScheduleService.fetchTaskList();
});

final taskResultsProvider = FutureProvider<List<TaskResult>>((ref) {
  if (!HiveManager.hasAccessToken) return Future.value(const <TaskResult>[]);
  return ScheduleService.fetchTaskResults();
});

final taskResultDetailProvider = FutureProvider.family<TaskResult?, String>((
  ref,
  taskId,
) {
  if (!HiveManager.hasAccessToken || taskId.trim().isEmpty) {
    return Future.value(null);
  }
  return ScheduleService.fetchTaskResult(taskId.trim());
});
