import 'dart:convert';
import 'dart:math';

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

class FileSizeConvert {
  /// 将文件大小字符串解析为字节
  static int parseToByte(String? fileSize) {
    if (fileSize == null || fileSize.isEmpty) {
      return 0;
    }

    // 正则表达式来匹配文件大小和单位
    RegExp regex =
        RegExp(r'(\d+(?:\.\d+)?)\s*([kmgtp]?b)', caseSensitive: false);

    List<String> order = ['b', 'kb', 'mb', 'gb', 'tb', 'pb', 'eb'];
    fileSize = fileSize.replaceAll("i", ""); // 移除 "i" 标志 (例如GiB -> GB)

    for (final match in regex.allMatches(fileSize)) {
      double value = double.parse(match.group(1)!);
      String unit = match.group(2)!.toLowerCase();
      return (value * pow(1024, order.indexOf(unit))).toInt();
    }
    return 0;
  }

  /// 将字节数转换为文件大小字符串
  static String parseToFileSize(num? byte, [int fixed = 2]) {
    if (byte == null || byte == 0) {
      return '0B';
    }

    List<String> units = ["B", "KB", "MB", "GB", "TB", "PB", 'EB'];
    double size = 1024.0;
    byte = byte.toDouble();

    for (int i = 0; i < units.length; i++) {
      if (byte! / size < 1) {
        return "${byte.toStringAsFixed(fixed)} ${units[i]}";
      }
      byte = byte / size;
    }
    return "${byte?.toStringAsFixed(fixed)} EB";
  }
}

void main() {
  print(FileSizeConvert.parseToByte("1024B"));
  print(FileSizeConvert.parseToFileSize(4575067883175));
}
