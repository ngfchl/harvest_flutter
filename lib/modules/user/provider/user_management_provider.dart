import 'package:harvest/core/storage/hive_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/user_management_model.dart';
import '../service/user_management_service.dart';

part 'user_management_provider.g.dart';

@riverpod
Future<dynamic> authInfo(ref) async {
  if (!HiveManager.hasAccessToken) return null;
  return UserManagementService.fetchAuthInfo();
}

@riverpod
class ManagedUserList extends _$ManagedUserList {
  @override
  Future<List<ManagedUser>> build() {
    if (!HiveManager.hasAccessToken) {
      return Future.value(const <ManagedUser>[]);
    }
    return UserManagementService.fetchUsers();
  }

  Future<void> refresh() async {
    if (!HiveManager.hasAccessToken) {
      state = const AsyncValue.data(<ManagedUser>[]);
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(UserManagementService.fetchUsers);
  }

  Future<void> createUser(UserCredentials credentials) async {
    await UserManagementService.createUser(credentials);
    await refresh();
  }

  Future<void> updateUser(int id, UserCredentials credentials) async {
    await UserManagementService.updateUser(id, credentials);
    await refresh();
  }

  Future<void> updateUserStatus(ManagedUser user, bool isActive) async {
    await UserManagementService.updateUserStatus(user, isActive);
    await refresh();
  }

  Future<void> deleteUser(int id) async {
    await UserManagementService.deleteUser(id);
    await refresh();
  }
}
