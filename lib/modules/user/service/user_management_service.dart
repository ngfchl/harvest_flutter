import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/http.dart';

import '../model/user_management_model.dart';

class UserManagementService {
  UserManagementService._();

  static Future<List<ManagedUser>> fetchUsers() async {
    final data = await Http.get<dynamic>(API.AUTH_USER);
    final list = _extractList(data);
    return list
        .whereType<Map>()
        .map((item) => ManagedUser.fromJson(Map<String, dynamic>.from(item)))
        .where((user) => user.id > 0 || user.username.isNotEmpty)
        .toList();
  }

  static Future<dynamic> fetchAuthInfo() {
    return Http.get<dynamic>(API.AUTH_INFO);
  }

  static Future<void> createUser(UserCredentials credentials) async {
    await Http.post(API.AUTH_USER, data: credentials.toJson());
  }

  static Future<void> updateUser(int id, UserCredentials credentials) async {
    await Http.put('${API.AUTH_USER}/$id', data: credentials.toJson());
  }

  static Future<void> updateUserStatus(ManagedUser user, bool isActive) async {
    await Http.put('${API.AUTH_USER}/${user.id}', data: user.copyWith(isActive: isActive).toJson());
  }

  static Future<void> deleteUser(int id) async {
    await Http.delete('${API.AUTH_USER}/$id');
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
