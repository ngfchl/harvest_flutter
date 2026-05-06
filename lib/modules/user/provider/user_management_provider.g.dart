// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authInfoHash() => r'0ff3d388a9b9835bf62d1cd70a67f5622e177e63';

/// See also [authInfo].
@ProviderFor(authInfo)
final authInfoProvider = AutoDisposeFutureProvider<dynamic>.internal(
  authInfo,
  name: r'authInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthInfoRef = AutoDisposeFutureProviderRef<dynamic>;
String _$managedUserListHash() => r'4909d6d3313a71dac41cb0c3d2911865a5ddf06b';

/// See also [ManagedUserList].
@ProviderFor(ManagedUserList)
final managedUserListProvider =
    AutoDisposeAsyncNotifierProvider<
      ManagedUserList,
      List<ManagedUser>
    >.internal(
      ManagedUserList.new,
      name: r'managedUserListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$managedUserListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManagedUserList = AutoDisposeAsyncNotifier<List<ManagedUser>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
