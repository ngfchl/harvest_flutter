import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String username,
    @Default(false) bool isActive,
    @Default(false) bool isStaff,
    @Default(false) bool isSuperuser,
    @Default('') String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(_normalizeUserJson(json));
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  final normalized = Map<String, dynamic>.from(json);
  normalized.putIfAbsent('isActive', () => json['is_active']);
  normalized.putIfAbsent('isStaff', () => json['is_staff']);
  normalized.putIfAbsent('isSuperuser', () => json['is_superuser']);
  return normalized;
}
