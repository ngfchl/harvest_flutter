import 'package:app_service/app_service.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppService appService(GetIt i) {
  return AppService(
    i.get<SharedPreferences>(),
    supportedLanguages: const [
      LanguageEnum.zh,
      LanguageEnum.zhHk,
      LanguageEnum.zhMO,
      LanguageEnum.zhTW,
      LanguageEnum.en,
      LanguageEnum.enUK,
      LanguageEnum.enUS,
      LanguageEnum.de,
      LanguageEnum.ru,
      LanguageEnum.uk,
      LanguageEnum.be,
      LanguageEnum.kk,
      LanguageEnum.sr,
      LanguageEnum.fr,
      LanguageEnum.ja,
      LanguageEnum.ko,
      LanguageEnum.ar,
    ],
    defaultLang: LanguageEnum.zh,
  );
}
