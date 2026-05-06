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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
