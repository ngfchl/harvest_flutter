import 'package:hive/hive.dart';
import 'login_record.dart';

class LoginStorage {
  static const _boxName = 'login_records';
  static const _key = 'records';

  static Future<Box> _box() async {
    return await Hive.openBox(_boxName);
  }

  /// 获取列表
  static Future<List<LoginRecord>> getRecords() async {
    final box = await _box();
    final list = box.get(_key, defaultValue: []) as List;

    return list.map((e) => LoginRecord.fromJson(Map.from(e))).toList();
  }

  /// 保存（核心：LRU + 去重）
  static Future<void> save(LoginRecord record) async {
    final box = await _box();
    final list = await getRecords();

    /// 去重（同 server + username）
    list.removeWhere((e) =>
    e.server == record.server && e.username == record.username);

    /// 插入到最前（最近使用）
    list.insert(0, record);

    /// 可限制最大数量（比如 10 条）
    final newList = list.take(10).toList();

    await box.put(
      _key,
      newList.map((e) => e.toJson()).toList(),
    );
  }
  // ====================== 新增：删除单条记录 ======================
  static Future<void> remove(LoginRecord record) async {
    final box = await _box();
    final list = await getRecords();

    // 根据 server + username 匹配删除
    list.removeWhere((e) =>
    e.server == record.server && e.username == record.username);

    await box.put(
      _key,
      list.map((e) => e.toJson()).toList(),
    );
  }

  // ====================== 新增：清空所有记录 ======================
  static Future<void> clearAll() async {
    final box = await _box();
    await box.put(_key, []);
  }
}