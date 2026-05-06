import '../../../core/http/api.dart';
import '../../../core/http/hooks.dart';
import '../model/crontab.dart';

class CrontabService {
  CrontabService._();

  static Future<List<CrontabItem>> fetchList() {
    return fetchModelList(API.CRONTAB_LIST, CrontabItem.fromJson);
  }
}
