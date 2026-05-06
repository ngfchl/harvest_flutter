// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  isActive: json['isActive'] as bool? ?? false,
  isStaff: json['isStaff'] as bool? ?? false,
  isSuperuser: json['isSuperuser'] as bool? ?? false,
  email: json['email'] as String? ?? '',
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'isActive': instance.isActive,
  'isStaff': instance.isStaff,
  'isSuperuser': instance.isSuperuser,
  'email': instance.email,
};
