import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/admin_user_model.dart';
import '../service/admin_user_service.dart';

part 'admin_user_provider.g.dart';

@riverpod
class AdminUserList extends _$AdminUserList {
  @override
  Future<List<AdminUser>> build() => AdminUserService.fetchUsers();

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    try {
      state = AsyncValue.data(await AdminUserService.fetchUsers());
    } catch (error, stackTrace) {
      if (previous == null) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> createUser(String email) async {
    await AdminUserService.createUser(email);
    await refresh();
  }

  Future<void> updateUser(AdminUserEditPayload payload) async {
    await AdminUserService.updateUser(payload);
    await refresh();
  }

  Future<void> resetToken(int userId, AdminUserResetTokenPayload payload) async {
    await AdminUserService.resetToken(userId, payload);
    await refresh();
  }

  Future<void> sendTokenEmail(int userId) async {
    await AdminUserService.sendTokenEmail(userId);
  }

  Future<void> resetInvite(int count) async {
    await AdminUserService.resetInvite(count);
    await refresh();
  }

  Future<void> deleteUser(int userId) async {
    await AdminUserService.deleteUser(userId);
    await refresh();
  }
}
