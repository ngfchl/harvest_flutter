import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';

import '../model/notice_history.dart';

class NoticeService {
  NoticeService._();

  static Future<List<NoticeHistory>> fetchNoticeHistory() async {
    final response = await Http.get<dynamic>(API.NOTICE_HISTORY);
    final list = _extractList(response);

    return list
        .whereType<Map>()
        .map((e) => NoticeHistory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> markRead(int id) async {
    if (id <= 0) return;
    await Http.put<dynamic>(API.noticeRead(id));
  }

  static Future<void> markAllRead() async {
    await Http.post<dynamic>(API.NOTICE_READ_ALL);
  }

  static Future<void> deleteNotice(int id) async {
    if (id <= 0) return;
    await Http.delete<dynamic>(API.noticeDetail(id));
  }

  static Future<void> deleteAll() async {
    await Http.delete<dynamic>(API.NOTICE_HISTORY);
  }

  static List<dynamic> _extractList(dynamic value) {
    if (value is List) return value;
    if (value is Map) {
      for (final key in ['results', 'list', 'items', 'records', 'data']) {
        final nested = value[key];
        if (nested is List) return nested;
        if (nested is Map) {
          final deep = _extractList(nested);
          if (deep.isNotEmpty) return deep;
        }
      }
    }
    return const [];
  }
}
