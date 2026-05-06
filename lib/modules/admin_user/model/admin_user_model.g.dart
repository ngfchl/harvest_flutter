// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdminUser _$AdminUserFromJson(Map<String, dynamic> json) => _AdminUser(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String?,
  email: json['email'] as String? ?? '',
  pay: (json['pay'] as num?)?.toInt() ?? 168,
  invite: (json['invite'] as num?)?.toInt() ?? 0,
  tryUser: json['try_user'] as bool? ?? false,
  marked: json['marked'] as String?,
  expire: (json['expire'] as num?)?.toInt() ?? 36600,
  timeExpire: json['time_expire'] as String? ?? '',
  updatedAt: json['updated_at'] as String? ?? '',
);

Map<String, dynamic> _$AdminUserToJson(_AdminUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'pay': instance.pay,
      'invite': instance.invite,
      'try_user': instance.tryUser,
      'marked': instance.marked,
      'expire': instance.expire,
      'time_expire': instance.timeExpire,
      'updated_at': instance.updatedAt,
    };

_AdminUserEditPayload _$AdminUserEditPayloadFromJson(
  Map<String, dynamic> json,
) => _AdminUserEditPayload(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  email: json['email'] as String,
  pay: (json['pay'] as num?)?.toInt(),
  invite: (json['invite'] as num?)?.toInt(),
  tryUser: json['try_user'] as bool?,
  marked: json['marked'] as String?,
  expire: (json['expire'] as num?)?.toInt(),
);

Map<String, dynamic> _$AdminUserEditPayloadToJson(
  _AdminUserEditPayload instance,
) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'pay': instance.pay,
  'invite': instance.invite,
  'try_user': instance.tryUser,
  'marked': instance.marked,
  'expire': instance.expire,
};

_AdminUserResetTokenPayload _$AdminUserResetTokenPayloadFromJson(
  Map<String, dynamic> json,
) => _AdminUserResetTokenPayload(
  expire: (json['expire'] as num).toInt(),
  pay: (json['pay'] as num).toInt(),
  tryUser: json['try_user'] as bool? ?? false,
);

Map<String, dynamic> _$AdminUserResetTokenPayloadToJson(
  _AdminUserResetTokenPayload instance,
) => <String, dynamic>{
  'expire': instance.expire,
  'pay': instance.pay,
  'try_user': instance.tryUser,
};
