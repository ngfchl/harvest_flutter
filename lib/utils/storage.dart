import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  SPUtil._internal();

  factory SPUtil() => _instance;

  static final SPUtil _instance = SPUtil._internal();

  static late SharedPreferences _preferences;

  static Future<SPUtil> getInstance() async {
    _preferences = await SharedPreferences.getInstance();
    return _instance;
  }

  static setLocalStorage<T>(String key, T value) {
    String type = value.runtimeType.toString();

    switch (type) {
      case "String":
        setString(key, value as String);
        break;
      case "int":
        setInt(key, value as int);
        break;
      case "bool":
        setBool(key, value as bool);
        break;
      case "double":
        setDouble(key, value as double);
        break;
      case "List<String>":
        setStringList(key, value as List<String>);
        break;
      default:
        throw Exception("Unsupported type $type");
    }
  }

  /// 获取持久化数据
  static dynamic getLocalStorage<T>(String key) {
    dynamic value = _preferences.get(key);
    if (value.runtimeType.toString() == "String") {
      if (_isJson(value)) {
        return json.decode(value);
      }
    }
    return value;
  }

  /// 获取持久化数据中所有存入的key
  static Set<String> getKeys() {
    return _preferences.getKeys();
  }

  /// 获取持久化数据中是否包含某个key
  static bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  /// 删除持久化数据中某个key
  static Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// 清除所有持久化数据
  static Future<bool> clear() async {
    return await _preferences.clear();
  }

  /// 重新加载所有数据,仅重载运行时
  static Future<void> reload() async {
    return await _preferences.reload();
  }

  /// 根据key存储int类型
  static Future<bool> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  /// 根据key获取int类型
  static int getInt(String key, {int defaultValue = 0}) {
    return _preferences.getInt(key) ?? defaultValue;
  }

  /// 根据key存储double类型
  static Future<bool> setDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  /// 根据key获取double类型
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences.getDouble(key) ?? defaultValue;
  }

  /// 根据key存储字符串类型
  static Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  /// 根据key获取字符串类型
  static String getString(String key, {String defaultValue = ""}) {
    return _preferences.getString(key) ?? defaultValue;
  }

  /// 根据key存储布尔类型
  static Future<bool> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  /// 根据key获取布尔类型
  static bool getBool(String key, {bool defaultValue = false}) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  /// 根据key存储字符串类型数组
  static Future<bool> setStringList(String key, List<String> value) {
    return _preferences.setStringList(key, value);
  }

  /// 根据key获取字符串类型数组
  static List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    return _preferences.getStringList(key) ?? defaultValue;
  }

  /// 根据key存储Map类型
  static Future<bool> setMap(String key, Map value) {
    return _preferences.setString(key, json.encode(value));
  }

  /// 根据key获取Map类型
  static Map getMap(String key) {
    String jsonStr = _preferences.getString(key) ?? "";
    return jsonStr.isEmpty ? {} : json.decode(jsonStr);
  }

  ///@title 存入带过期时间的数据，缓存过期时间的实现
  ///@description
  ///@updateTime 2024-11-30 19:32
  static Future<void> setCache(
      String key, Map<String, dynamic> data, int expireDuration) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final cacheData = {
      'data': data,
      'expireAt': timestamp + expireDuration * 1000,
    };
    await _preferences.setString(key, jsonEncode(cacheData));
  }

  ///@title 获取缓存
  ///@description
  ///@updateTime  2024-11-30 19:32
  static Future<Map<String, dynamic>> getCache(String key) async {
    final jsonString = _preferences.getString(key);
    if (jsonString == null || jsonString.isEmpty) return {};

    final cacheData = jsonDecode(jsonString) as Map<String, dynamic>;

    final expireAt = cacheData['expireAt'];

    // Check if the data is expired
    if (DateTime.now().millisecondsSinceEpoch.compareTo(expireAt ?? 0) > 0 ||
        !cacheData.containsKey('data')) {
      // Remove expired data
      await _preferences.remove(key);
      return {};
    } else {
      final data = cacheData['data'] as Map<String, dynamic>;
      return data;
    }
  }

  /// 判断是否是json字符串
  static _isJson(String value) {
    try {
      const JsonDecoder().convert(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}
