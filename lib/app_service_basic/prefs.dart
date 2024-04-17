import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences单例
Future<SharedPreferences> prefsInstance() async {
  return await SharedPreferences.getInstance();
}
