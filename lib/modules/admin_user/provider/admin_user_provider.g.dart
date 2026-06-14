// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminUserList)
final adminUserListProvider = AdminUserListProvider._();

final class AdminUserListProvider
    extends $AsyncNotifierProvider<AdminUserList, List<AdminUser>> {
  AdminUserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminUserListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminUserListHash();

  @$internal
  @override
  AdminUserList create() => AdminUserList();
}

String _$adminUserListHash() => r'eb9bdbb6154cce17f7362170fbb419d31bb57f61';

abstract class _$AdminUserList extends $AsyncNotifier<List<AdminUser>> {
  FutureOr<List<AdminUser>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AdminUser>>, List<AdminUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AdminUser>>, List<AdminUser>>,
              AsyncValue<List<AdminUser>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
