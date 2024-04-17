import 'package:app_service/app_service.dart';
import 'package:get_it/get_it.dart';
import 'package:harvest/app_service_basic/prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_service.dart';

/// 基于 Get it 库的依赖注入
class GetItInjection {
  static void init() {
    final GetIt i = GetIt.instance;

    i.registerSingletonAsync<SharedPreferences>(() => prefsInstance());

    i.registerLazySingleton<AppService>(() => appService(i)); // 应用基础服务
  }
}
