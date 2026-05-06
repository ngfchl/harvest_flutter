import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_model.freezed.dart';
part 'admin_user_model.g.dart';

@freezed
abstract class AdminUser with _$AdminUser {
  const factory AdminUser({
    @Default(0) int id,
    String? username,
    @Default('') String email,
    @Default(168) int pay,
    @Default(0) int invite,
    @Default(false) @JsonKey(name: 'try_user') bool tryUser,
    String? marked,
    @Default(36600) int expire,
    @Default('') @JsonKey(name: 'time_expire') String timeExpire,
    @Default('') @JsonKey(name: 'updated_at') String updatedAt,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(_normalizeAdminUserJson(json));
}

@freezed
abstract class AdminUserEditPayload with _$AdminUserEditPayload {
  const factory AdminUserEditPayload({
    int? id,
    String? username,
    required String email,
    int? pay,
    int? invite,
    @JsonKey(name: 'try_user') bool? tryUser,
    String? marked,
    int? expire,
  }) = _AdminUserEditPayload;

  factory AdminUserEditPayload.fromJson(Map<String, dynamic> json) => _$AdminUserEditPayloadFromJson(json);
}

@freezed
abstract class AdminUserResetTokenPayload with _$AdminUserResetTokenPayload {
  const factory AdminUserResetTokenPayload({
    required int expire,
    required int pay,
    @Default(false) @JsonKey(name: 'try_user') bool tryUser,
  }) = _AdminUserResetTokenPayload;

  factory AdminUserResetTokenPayload.fromJson(Map<String, dynamic> json) => _$AdminUserResetTokenPayloadFromJson(json);
}

Map<String, dynamic> _normalizeAdminUserJson(Map<String, dynamic> json) {
  return {
    ...json,
    if (json.containsKey('tryUser') && !json.containsKey('try_user')) 'try_user': json['tryUser'],
    if (json.containsKey('expire_days') && !json.containsKey('expire')) 'expire': json['expire_days'],
    if (json.containsKey('updatedAt') && !json.containsKey('updated_at')) 'updated_at': json['updatedAt'],
    if (json.containsKey('update_time') && !json.containsKey('updated_at')) 'updated_at': json['update_time'],
    if (json.containsKey('time_update') && !json.containsKey('updated_at')) 'updated_at': json['time_update'],
    if (json.containsKey('last_update') && !json.containsKey('updated_at')) 'updated_at': json['last_update'],
  };
}
