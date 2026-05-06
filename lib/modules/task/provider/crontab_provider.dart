import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/storage/hive_manager.dart';

import '../model/crontab.dart';
import '../service/crontab.dart';

final crontabListProvider =
    AsyncNotifierProvider<CrontabListNotifier, List<CrontabItem>>(
      CrontabListNotifier.new,
    );

class CrontabListNotifier extends AsyncNotifier<List<CrontabItem>> {
  @override
  Future<List<CrontabItem>> build() {
    if (!HiveManager.hasAccessToken) {
      return Future.value(const <CrontabItem>[]);
    }
    return CrontabService.fetchList();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = AsyncValue.data(state.valueOrNull ?? const <CrontabItem>[]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CrontabService.fetchList());
  }
}
