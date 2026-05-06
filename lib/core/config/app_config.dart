import '../storage/hive_manager.dart';
import '../storage/storage_keys.dart';

class AppConfig {
  /// 默认地址（第一次启动用）
  static const String _defaultBaseUrl = 'http://127.0.0.1:8000';

  /// 获取 baseUrl（动态）
  static String get baseUrl {
    return HiveManager.get<String>(StorageKeys.baseUrl) ?? _defaultBaseUrl;
  }

  /// 设置 baseUrl
  static Future<void> setBaseUrl(String url) async {
    await HiveManager.set(StorageKeys.baseUrl, normalizeBaseUrl(url));
  }

  static String normalizeBaseUrl(String url) {
    var value = url.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  /// 清除（切换账号用）
  static Future<void> clear() async {
    await HiveManager.delete(StorageKeys.baseUrl);
  }
}
