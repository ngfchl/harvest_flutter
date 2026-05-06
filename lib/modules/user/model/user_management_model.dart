import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_management_model.freezed.dart';
part 'user_management_model.g.dart';

@freezed
abstract class ManagedUser with _$ManagedUser {
  const factory ManagedUser({
    @Default(0) int id,
    @Default('') String username,
    @Default(false) @JsonKey(name: 'is_active') bool isActive,
    @Default(false) @JsonKey(name: 'is_staff') bool isStaff,
    @Default(false) @JsonKey(name: 'is_superuser') bool isSuperuser,
    @Default('') String email,
  }) = _ManagedUser;

  factory ManagedUser.fromJson(Map<String, dynamic> json) => _$ManagedUserFromJson(_normalizeUserJson(json));
}

@freezed
abstract class UserCredentials with _$UserCredentials {
  const factory UserCredentials({
    required String username,
    required String password,
  }) = _UserCredentials;

  factory UserCredentials.fromJson(Map<String, dynamic> json) => _$UserCredentialsFromJson(json);
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  return {
    ...json,
    if (json.containsKey('isActive') && !json.containsKey('is_active')) 'is_active': json['isActive'],
    if (json.containsKey('isStaff') && !json.containsKey('is_staff')) 'is_staff': json['isStaff'],
    if (json.containsKey('isSuperuser') && !json.containsKey('is_superuser')) 'is_superuser': json['isSuperuser'],
  };
}
