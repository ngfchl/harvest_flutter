// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthState _$AuthStateFromJson(Map<String, dynamic> json) => _AuthState(
  loading: json['loading'] as bool? ?? false,
  loggedIn: json['loggedIn'] as bool? ?? false,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthStateToJson(_AuthState instance) =>
    <String, dynamic>{
      'loading': instance.loading,
      'loggedIn': instance.loggedIn,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'user': instance.user?.toJson(),
    };

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authNotifierHash() => r'6092b814aa8d2aeda9421565036e62df6e7fda08';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = Notifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
