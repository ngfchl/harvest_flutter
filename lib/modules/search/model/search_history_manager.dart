import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';

class SearchHistoryManager {
  static const _maxHistory = 20;
  static const _key = StorageKeys.searchHistory;

  static List<String> getHistory() {
    final raw = HiveManager.get<List>(_key);
    if (raw == null) return [];
    return raw.map((e) => e.toString()).toList();
  }

  static void addHistory(String keyword) {
    final k = keyword.trim();
    if (k.isEmpty) return;
    final list = getHistory();
    list.remove(k);
    list.insert(0, k);
    if (list.length > _maxHistory) list.removeRange(_maxHistory, list.length);
    HiveManager.set(_key, list);
  }

  static void removeHistory(String keyword) {
    final list = getHistory();
    list.remove(keyword);
    HiveManager.set(_key, list);
  }

  static void clearHistory() {
    HiveManager.set(_key, <String>[]);
  }
}
