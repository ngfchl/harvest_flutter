class MapHelper {
  /// 递归转换 Map<dynamic, dynamic> → Map<String, dynamic>
  /// 解决 Hive 读取嵌套 Map 类型不匹配的问题
  static Map<String, dynamic> convertMap(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map<dynamic, dynamic>) {
        return MapEntry(key.toString(), convertMap(value));
      }
      if (value is List) {
        return MapEntry(key.toString(), convertList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  static List convertList(List list) {
    return list.map((item) {
      if (item is Map<dynamic, dynamic>) {
        return convertMap(item);
      }
      if (item is List) {
        return convertList(item);
      }
      return item;
    }).toList();
  }
}
