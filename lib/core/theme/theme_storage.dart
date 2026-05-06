import 'package:hive/hive.dart';

class ThemeStorage {
  static const _boxName = 'settings';
  static const _themeKey = 'theme';
  static const _modeKey = 'mode';

  static Future<Box> _box() async {
    return await Hive.openBox(_boxName);
  }

  static Future<void> saveTheme(String name) async {
    final box = await _box();
    await box.put(_themeKey, name);
  }

  static Future<void> saveMode(String mode) async {
    final box = await _box();
    await box.put(_modeKey, mode);
  }

  static Future<String?> getTheme() async {
    final box = await _box();
    return box.get(_themeKey);
  }

  static Future<String?> getMode() async {
    final box = await _box();
    return box.get(_modeKey);
  }
}