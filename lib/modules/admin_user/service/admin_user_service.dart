import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';

import '../model/admin_user_model.dart';

class AdminUserService {
  AdminUserService._();

  static Future<List<AdminUser>> fetchUsers() async {
    final data = await Http.get<dynamic>(API.ADMIN_USER);
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => AdminUser.fromJson(Map<String, dynamic>.from(item)))
        .where((user) => user.id > 0 || user.email.isNotEmpty || (user.username?.isNotEmpty ?? false))
        .toList();
  }

  static Future<void> createUser(String email) async {
    await Http.post(API.ADMIN_USER, queryParameters: {'invite_email': email, 'notify': true});
  }

  static Future<void> updateUser(AdminUserEditPayload payload) async {
    await Http.put(API.ADMIN_USER, data: payload.toJson());
  }

  static Future<void> resetToken(int userId, AdminUserResetTokenPayload payload) async {
    await Http.post(API.ADMIN_RESET_TOKEN, queryParameters: {'user_id': userId}, data: payload.toJson());
  }

  static Future<void> sendTokenEmail(int userId) async {
    await Http.get(API.ADMIN_SEND_TOKEN, queryParameters: {'user_id': userId});
  }

  static Future<void> resetInvite(int count) async {
    await Http.get(API.ADMIN_RESET_INVITE, queryParameters: {'count': count});
  }

  static Future<void> deleteUser(int userId) async {
    await Http.delete('${API.ADMIN_USER}/$userId');
  }

  static List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      for (final key in const ['users', 'list', 'results', 'items', 'data']) {
        final value = data[key];
        if (value is List) return value;
      }
    }
    return const [];
  }
}
