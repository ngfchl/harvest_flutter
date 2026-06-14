// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authInfo)
final authInfoProvider = AuthInfoProvider._();

final class AuthInfoProvider
    extends $FunctionalProvider<AsyncValue<dynamic>, dynamic, FutureOr<dynamic>>
    with $FutureModifier<dynamic>, $FutureProvider<dynamic> {
  AuthInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authInfoHash();

  @$internal
  @override
  $FutureProviderElement<dynamic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<dynamic> create(Ref ref) {
    return authInfo(ref);
  }
}

String _$authInfoHash() => r'0ff3d388a9b9835bf62d1cd70a67f5622e177e63';

@ProviderFor(ManagedUserList)
final managedUserListProvider = ManagedUserListProvider._();

final class ManagedUserListProvider
    extends $AsyncNotifierProvider<ManagedUserList, List<ManagedUser>> {
  ManagedUserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'managedUserListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$managedUserListHash();

  @$internal
  @override
  ManagedUserList create() => ManagedUserList();
}

String _$managedUserListHash() => r'4909d6d3313a71dac41cb0c3d2911865a5ddf06b';

abstract class _$ManagedUserList extends $AsyncNotifier<List<ManagedUser>> {
  FutureOr<List<ManagedUser>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ManagedUser>>, List<ManagedUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ManagedUser>>, List<ManagedUser>>,
              AsyncValue<List<ManagedUser>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
