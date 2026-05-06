import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'login_record.dart';
import 'login_storage.dart';

part 'login_history_provider.g.dart';

@riverpod
class LoginHistory extends _$LoginHistory {
  @override
  List<LoginRecord> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final list = await LoginStorage.getRecords();
    state = list;
  }

  Future<void> add(LoginRecord record) async {
    await LoginStorage.save(record);
    state = await LoginStorage.getRecords();
  }

  Future<void> remove(LoginRecord record) async {
    await LoginStorage.remove(record); // 你需要加这个方法
    state = await LoginStorage.getRecords();
  }

  Future<void> clearAll() async {
    await LoginStorage.clearAll(); // 你需要加这个方法
    state = await LoginStorage.getRecords();
  }
}
