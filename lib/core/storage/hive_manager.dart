import 'package:hive_flutter/hive_flutter.dart';

import 'storage_keys.dart';

class HiveManager {
  static const String _boxName = 'app_box';
  static const String _scopedNamespace = '__scoped__';
  static const Set<String> _globalKeys = {
    StorageKeys.accessToken,
    StorageKeys.refreshToken,
    StorageKeys.baseUrl,
    StorageKeys.authState,
    StorageKeys.loggerLevel,
    'canConnectInternet',
  };
  static const Set<String> _authSessionKeys = {
    StorageKeys.accessToken,
    StorageKeys.refreshToken,
    StorageKeys.authState,
  };

  static late Box _box;
  static String? _scopeServer;
  static String? _scopeUsername;
  static bool _authSessionCleared = false;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static void setScope({required String server, required String username}) {
    _scopeServer = server.trim();
    _scopeUsername = username.trim();
  }

  static void clearScope() {
    _scopeServer = null;
    _scopeUsername = null;
  }

  /// 写入（自动序列化对象）
  static Future<void> set(String key, dynamic value) async {
    if (_authSessionKeys.contains(key) && value != null) {
      _authSessionCleared = false;
    }
    await _box.put(_resolveKey(key), _serialize(value));
  }

  /// 读取（自动反序列化 Map/List）
  static T? get<T>(String key) {
    if (_authSessionCleared && _authSessionKeys.contains(key)) return null;

    final value = _box.get(_resolveKey(key));
    if (value == null) return null;

    if (value is Map) {
      return _convertMap(value) as T;
    }

    if (value is List) {
      return _convertList(value) as T;
    }

    return value as T?;
  }

  static Future<void> delete(String key) async {
    if (_authSessionKeys.contains(key)) {
      _authSessionCleared = true;
    }
    await _box.delete(_resolveKey(key));
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static bool contains(String key) {
    return _box.containsKey(_resolveKey(key));
  }

  static bool get hasAccessToken {
    if (_authSessionCleared) return false;

    final token = _box.get(StorageKeys.accessToken);
    return token != null && token.toString().isNotEmpty;
  }

  static String scopedKey(String key) => _resolveKey(key);

  static String _resolveKey(String key) {
    if (_globalKeys.contains(key) || key.startsWith('$_scopedNamespace::')) {
      return key;
    }
    return '$_scopedNamespace::${_scopePrefix()}::$key';
  }

  static String _scopePrefix() {
    final server =
        (_scopeServer?.isNotEmpty == true
            ? _scopeServer
            : _globalString(StorageKeys.baseUrl)) ??
        'default_server';
    final username =
        (_scopeUsername?.isNotEmpty == true
            ? _scopeUsername
            : _authUsername()) ??
        'anonymous';
    return '$server-$username';
  }

  static String? _globalString(String key) {
    final value = _box.get(key);
    return value?.toString();
  }

  static String? _authUsername() {
    if (_authSessionCleared) return null;

    final raw = _box.get(StorageKeys.authState);
    if (raw is! Map) return null;
    final auth = _convertMap(raw);
    final user = auth['user'];
    if (user is! Map) return null;
    final username = user['username'] ?? user['email'];
    final text = username?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  // ———————————————— 序列化（写入时）————————————————

  static dynamic _serialize(dynamic value) {
    if (value == null) return null;
    if (value is String || value is int || value is double || value is bool) {
      return value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _serialize(v)));
    }
    if (value is List) {
      return value.map((item) => _serialize(item)).toList();
    }
    // 其他对象，调用 toJson
    try {
      final json = (value as dynamic).toJson();
      return _serialize(json);
    } catch (_) {
      return value;
    }
  }

  // ———————————————— 反序列化（读取时）————————————————

  static Map<String, dynamic> _convertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map<dynamic, dynamic>) {
        return MapEntry(key.toString(), _convertMap(value));
      }
      if (value is List) {
        return MapEntry(key.toString(), _convertList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  static List _convertList(List list) {
    return list.map((item) {
      if (item is Map<dynamic, dynamic>) {
        return _convertMap(item);
      }
      if (item is List) {
        return _convertList(item);
      }
      return item;
    }).toList();
  }
}
