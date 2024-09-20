import 'dart:convert';

class StringUtils {
  static String getLottieByName(String lotterName) {
    return "assets/lotties/$lotterName.json";
  }

  static dynamic parseJsonOrReturnString(String str) {
    try {
      // 尝试解析字符串为 JSON
      return jsonDecode(str);
    } on FormatException {
      // 如果解析失败，返回原始字符串
      return str;
    }
  }
}

String capitalize(String str) {
  return str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : str;
}
