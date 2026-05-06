// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_management_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ManagedUser _$ManagedUserFromJson(Map<String, dynamic> json) => _ManagedUser(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? false,
  isStaff: json['is_staff'] as bool? ?? false,
  isSuperuser: json['is_superuser'] as bool? ?? false,
  email: json['email'] as String? ?? '',
);

Map<String, dynamic> _$ManagedUserToJson(_ManagedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'is_active': instance.isActive,
      'is_staff': instance.isStaff,
      'is_superuser': instance.isSuperuser,
      'email': instance.email,
    };

_UserCredentials _$UserCredentialsFromJson(Map<String, dynamic> json) =>
    _UserCredentials(
      username: json['username'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UserCredentialsToJson(_UserCredentials instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
    };
