// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdminUser {

 int get id; String? get username; String get email; int get pay; int get invite;@JsonKey(name: 'try_user') bool get tryUser; String? get marked; int get expire;@JsonKey(name: 'time_expire') String get timeExpire;@JsonKey(name: 'updated_at') String get updatedAt;
/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserCopyWith<AdminUser> get copyWith => _$AdminUserCopyWithImpl<AdminUser>(this as AdminUser, _$identity);

  /// Serializes this AdminUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser)&&(identical(other.marked, marked) || other.marked == marked)&&(identical(other.expire, expire) || other.expire == expire)&&(identical(other.timeExpire, timeExpire) || other.timeExpire == timeExpire)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email,pay,invite,tryUser,marked,expire,timeExpire,updatedAt);

@override
String toString() {
  return 'AdminUser(id: $id, username: $username, email: $email, pay: $pay, invite: $invite, tryUser: $tryUser, marked: $marked, expire: $expire, timeExpire: $timeExpire, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AdminUserCopyWith<$Res>  {
  factory $AdminUserCopyWith(AdminUser value, $Res Function(AdminUser) _then) = _$AdminUserCopyWithImpl;
@useResult
$Res call({
 int id, String? username, String email, int pay, int invite,@JsonKey(name: 'try_user') bool tryUser, String? marked, int expire,@JsonKey(name: 'time_expire') String timeExpire,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class _$AdminUserCopyWithImpl<$Res>
    implements $AdminUserCopyWith<$Res> {
  _$AdminUserCopyWithImpl(this._self, this._then);

  final AdminUser _self;
  final $Res Function(AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = freezed,Object? email = null,Object? pay = null,Object? invite = null,Object? tryUser = null,Object? marked = freezed,Object? expire = null,Object? timeExpire = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,pay: null == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int,invite: null == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as int,tryUser: null == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool,marked: freezed == marked ? _self.marked : marked // ignore: cast_nullable_to_non_nullable
as String?,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,timeExpire: null == timeExpire ? _self.timeExpire : timeExpire // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUser].
extension AdminUserPatterns on AdminUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUser value)  $default,){
final _that = this;
switch (_that) {
case _AdminUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUser value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? username,  String email,  int pay,  int invite, @JsonKey(name: 'try_user')  bool tryUser,  String? marked,  int expire, @JsonKey(name: 'time_expire')  String timeExpire, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire,_that.timeExpire,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? username,  String email,  int pay,  int invite, @JsonKey(name: 'try_user')  bool tryUser,  String? marked,  int expire, @JsonKey(name: 'time_expire')  String timeExpire, @JsonKey(name: 'updated_at')  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AdminUser():
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire,_that.timeExpire,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? username,  String email,  int pay,  int invite, @JsonKey(name: 'try_user')  bool tryUser,  String? marked,  int expire, @JsonKey(name: 'time_expire')  String timeExpire, @JsonKey(name: 'updated_at')  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdminUser() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire,_that.timeExpire,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUser implements AdminUser {
  const _AdminUser({this.id = 0, this.username, this.email = '', this.pay = 168, this.invite = 0, @JsonKey(name: 'try_user') this.tryUser = false, this.marked, this.expire = 36600, @JsonKey(name: 'time_expire') this.timeExpire = '', @JsonKey(name: 'updated_at') this.updatedAt = ''});
  factory _AdminUser.fromJson(Map<String, dynamic> json) => _$AdminUserFromJson(json);

@override@JsonKey() final  int id;
@override final  String? username;
@override@JsonKey() final  String email;
@override@JsonKey() final  int pay;
@override@JsonKey() final  int invite;
@override@JsonKey(name: 'try_user') final  bool tryUser;
@override final  String? marked;
@override@JsonKey() final  int expire;
@override@JsonKey(name: 'time_expire') final  String timeExpire;
@override@JsonKey(name: 'updated_at') final  String updatedAt;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserCopyWith<_AdminUser> get copyWith => __$AdminUserCopyWithImpl<_AdminUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser)&&(identical(other.marked, marked) || other.marked == marked)&&(identical(other.expire, expire) || other.expire == expire)&&(identical(other.timeExpire, timeExpire) || other.timeExpire == timeExpire)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email,pay,invite,tryUser,marked,expire,timeExpire,updatedAt);

@override
String toString() {
  return 'AdminUser(id: $id, username: $username, email: $email, pay: $pay, invite: $invite, tryUser: $tryUser, marked: $marked, expire: $expire, timeExpire: $timeExpire, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AdminUserCopyWith<$Res> implements $AdminUserCopyWith<$Res> {
  factory _$AdminUserCopyWith(_AdminUser value, $Res Function(_AdminUser) _then) = __$AdminUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String? username, String email, int pay, int invite,@JsonKey(name: 'try_user') bool tryUser, String? marked, int expire,@JsonKey(name: 'time_expire') String timeExpire,@JsonKey(name: 'updated_at') String updatedAt
});




}
/// @nodoc
class __$AdminUserCopyWithImpl<$Res>
    implements _$AdminUserCopyWith<$Res> {
  __$AdminUserCopyWithImpl(this._self, this._then);

  final _AdminUser _self;
  final $Res Function(_AdminUser) _then;

/// Create a copy of AdminUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = freezed,Object? email = null,Object? pay = null,Object? invite = null,Object? tryUser = null,Object? marked = freezed,Object? expire = null,Object? timeExpire = null,Object? updatedAt = null,}) {
  return _then(_AdminUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,pay: null == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int,invite: null == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as int,tryUser: null == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool,marked: freezed == marked ? _self.marked : marked // ignore: cast_nullable_to_non_nullable
as String?,expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,timeExpire: null == timeExpire ? _self.timeExpire : timeExpire // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AdminUserEditPayload {

 int? get id; String? get username; String get email; int? get pay; int? get invite;@JsonKey(name: 'try_user') bool? get tryUser; String? get marked; int? get expire;
/// Create a copy of AdminUserEditPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserEditPayloadCopyWith<AdminUserEditPayload> get copyWith => _$AdminUserEditPayloadCopyWithImpl<AdminUserEditPayload>(this as AdminUserEditPayload, _$identity);

  /// Serializes this AdminUserEditPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserEditPayload&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser)&&(identical(other.marked, marked) || other.marked == marked)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email,pay,invite,tryUser,marked,expire);

@override
String toString() {
  return 'AdminUserEditPayload(id: $id, username: $username, email: $email, pay: $pay, invite: $invite, tryUser: $tryUser, marked: $marked, expire: $expire)';
}


}

/// @nodoc
abstract mixin class $AdminUserEditPayloadCopyWith<$Res>  {
  factory $AdminUserEditPayloadCopyWith(AdminUserEditPayload value, $Res Function(AdminUserEditPayload) _then) = _$AdminUserEditPayloadCopyWithImpl;
@useResult
$Res call({
 int? id, String? username, String email, int? pay, int? invite,@JsonKey(name: 'try_user') bool? tryUser, String? marked, int? expire
});




}
/// @nodoc
class _$AdminUserEditPayloadCopyWithImpl<$Res>
    implements $AdminUserEditPayloadCopyWith<$Res> {
  _$AdminUserEditPayloadCopyWithImpl(this._self, this._then);

  final AdminUserEditPayload _self;
  final $Res Function(AdminUserEditPayload) _then;

/// Create a copy of AdminUserEditPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? username = freezed,Object? email = null,Object? pay = freezed,Object? invite = freezed,Object? tryUser = freezed,Object? marked = freezed,Object? expire = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,pay: freezed == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int?,invite: freezed == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as int?,tryUser: freezed == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool?,marked: freezed == marked ? _self.marked : marked // ignore: cast_nullable_to_non_nullable
as String?,expire: freezed == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserEditPayload].
extension AdminUserEditPayloadPatterns on AdminUserEditPayload {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserEditPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserEditPayload() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserEditPayload value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserEditPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserEditPayload value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserEditPayload() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? username,  String email,  int? pay,  int? invite, @JsonKey(name: 'try_user')  bool? tryUser,  String? marked,  int? expire)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserEditPayload() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? username,  String email,  int? pay,  int? invite, @JsonKey(name: 'try_user')  bool? tryUser,  String? marked,  int? expire)  $default,) {final _that = this;
switch (_that) {
case _AdminUserEditPayload():
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? username,  String email,  int? pay,  int? invite, @JsonKey(name: 'try_user')  bool? tryUser,  String? marked,  int? expire)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserEditPayload() when $default != null:
return $default(_that.id,_that.username,_that.email,_that.pay,_that.invite,_that.tryUser,_that.marked,_that.expire);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserEditPayload implements AdminUserEditPayload {
  const _AdminUserEditPayload({this.id, this.username, required this.email, this.pay, this.invite, @JsonKey(name: 'try_user') this.tryUser, this.marked, this.expire});
  factory _AdminUserEditPayload.fromJson(Map<String, dynamic> json) => _$AdminUserEditPayloadFromJson(json);

@override final  int? id;
@override final  String? username;
@override final  String email;
@override final  int? pay;
@override final  int? invite;
@override@JsonKey(name: 'try_user') final  bool? tryUser;
@override final  String? marked;
@override final  int? expire;

/// Create a copy of AdminUserEditPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserEditPayloadCopyWith<_AdminUserEditPayload> get copyWith => __$AdminUserEditPayloadCopyWithImpl<_AdminUserEditPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserEditPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserEditPayload&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.invite, invite) || other.invite == invite)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser)&&(identical(other.marked, marked) || other.marked == marked)&&(identical(other.expire, expire) || other.expire == expire));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email,pay,invite,tryUser,marked,expire);

@override
String toString() {
  return 'AdminUserEditPayload(id: $id, username: $username, email: $email, pay: $pay, invite: $invite, tryUser: $tryUser, marked: $marked, expire: $expire)';
}


}

/// @nodoc
abstract mixin class _$AdminUserEditPayloadCopyWith<$Res> implements $AdminUserEditPayloadCopyWith<$Res> {
  factory _$AdminUserEditPayloadCopyWith(_AdminUserEditPayload value, $Res Function(_AdminUserEditPayload) _then) = __$AdminUserEditPayloadCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? username, String email, int? pay, int? invite,@JsonKey(name: 'try_user') bool? tryUser, String? marked, int? expire
});




}
/// @nodoc
class __$AdminUserEditPayloadCopyWithImpl<$Res>
    implements _$AdminUserEditPayloadCopyWith<$Res> {
  __$AdminUserEditPayloadCopyWithImpl(this._self, this._then);

  final _AdminUserEditPayload _self;
  final $Res Function(_AdminUserEditPayload) _then;

/// Create a copy of AdminUserEditPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? username = freezed,Object? email = null,Object? pay = freezed,Object? invite = freezed,Object? tryUser = freezed,Object? marked = freezed,Object? expire = freezed,}) {
  return _then(_AdminUserEditPayload(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,pay: freezed == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int?,invite: freezed == invite ? _self.invite : invite // ignore: cast_nullable_to_non_nullable
as int?,tryUser: freezed == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool?,marked: freezed == marked ? _self.marked : marked // ignore: cast_nullable_to_non_nullable
as String?,expire: freezed == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$AdminUserResetTokenPayload {

 int get expire; int get pay;@JsonKey(name: 'try_user') bool get tryUser;
/// Create a copy of AdminUserResetTokenPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminUserResetTokenPayloadCopyWith<AdminUserResetTokenPayload> get copyWith => _$AdminUserResetTokenPayloadCopyWithImpl<AdminUserResetTokenPayload>(this as AdminUserResetTokenPayload, _$identity);

  /// Serializes this AdminUserResetTokenPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminUserResetTokenPayload&&(identical(other.expire, expire) || other.expire == expire)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expire,pay,tryUser);

@override
String toString() {
  return 'AdminUserResetTokenPayload(expire: $expire, pay: $pay, tryUser: $tryUser)';
}


}

/// @nodoc
abstract mixin class $AdminUserResetTokenPayloadCopyWith<$Res>  {
  factory $AdminUserResetTokenPayloadCopyWith(AdminUserResetTokenPayload value, $Res Function(AdminUserResetTokenPayload) _then) = _$AdminUserResetTokenPayloadCopyWithImpl;
@useResult
$Res call({
 int expire, int pay,@JsonKey(name: 'try_user') bool tryUser
});




}
/// @nodoc
class _$AdminUserResetTokenPayloadCopyWithImpl<$Res>
    implements $AdminUserResetTokenPayloadCopyWith<$Res> {
  _$AdminUserResetTokenPayloadCopyWithImpl(this._self, this._then);

  final AdminUserResetTokenPayload _self;
  final $Res Function(AdminUserResetTokenPayload) _then;

/// Create a copy of AdminUserResetTokenPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expire = null,Object? pay = null,Object? tryUser = null,}) {
  return _then(_self.copyWith(
expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,pay: null == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int,tryUser: null == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminUserResetTokenPayload].
extension AdminUserResetTokenPayloadPatterns on AdminUserResetTokenPayload {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminUserResetTokenPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminUserResetTokenPayload value)  $default,){
final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminUserResetTokenPayload value)?  $default,){
final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int expire,  int pay, @JsonKey(name: 'try_user')  bool tryUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload() when $default != null:
return $default(_that.expire,_that.pay,_that.tryUser);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int expire,  int pay, @JsonKey(name: 'try_user')  bool tryUser)  $default,) {final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload():
return $default(_that.expire,_that.pay,_that.tryUser);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int expire,  int pay, @JsonKey(name: 'try_user')  bool tryUser)?  $default,) {final _that = this;
switch (_that) {
case _AdminUserResetTokenPayload() when $default != null:
return $default(_that.expire,_that.pay,_that.tryUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminUserResetTokenPayload implements AdminUserResetTokenPayload {
  const _AdminUserResetTokenPayload({required this.expire, required this.pay, @JsonKey(name: 'try_user') this.tryUser = false});
  factory _AdminUserResetTokenPayload.fromJson(Map<String, dynamic> json) => _$AdminUserResetTokenPayloadFromJson(json);

@override final  int expire;
@override final  int pay;
@override@JsonKey(name: 'try_user') final  bool tryUser;

/// Create a copy of AdminUserResetTokenPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminUserResetTokenPayloadCopyWith<_AdminUserResetTokenPayload> get copyWith => __$AdminUserResetTokenPayloadCopyWithImpl<_AdminUserResetTokenPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminUserResetTokenPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminUserResetTokenPayload&&(identical(other.expire, expire) || other.expire == expire)&&(identical(other.pay, pay) || other.pay == pay)&&(identical(other.tryUser, tryUser) || other.tryUser == tryUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expire,pay,tryUser);

@override
String toString() {
  return 'AdminUserResetTokenPayload(expire: $expire, pay: $pay, tryUser: $tryUser)';
}


}

/// @nodoc
abstract mixin class _$AdminUserResetTokenPayloadCopyWith<$Res> implements $AdminUserResetTokenPayloadCopyWith<$Res> {
  factory _$AdminUserResetTokenPayloadCopyWith(_AdminUserResetTokenPayload value, $Res Function(_AdminUserResetTokenPayload) _then) = __$AdminUserResetTokenPayloadCopyWithImpl;
@override @useResult
$Res call({
 int expire, int pay,@JsonKey(name: 'try_user') bool tryUser
});




}
/// @nodoc
class __$AdminUserResetTokenPayloadCopyWithImpl<$Res>
    implements _$AdminUserResetTokenPayloadCopyWith<$Res> {
  __$AdminUserResetTokenPayloadCopyWithImpl(this._self, this._then);

  final _AdminUserResetTokenPayload _self;
  final $Res Function(_AdminUserResetTokenPayload) _then;

/// Create a copy of AdminUserResetTokenPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expire = null,Object? pay = null,Object? tryUser = null,}) {
  return _then(_AdminUserResetTokenPayload(
expire: null == expire ? _self.expire : expire // ignore: cast_nullable_to_non_nullable
as int,pay: null == pay ? _self.pay : pay // ignore: cast_nullable_to_non_nullable
as int,tryUser: null == tryUser ? _self.tryUser : tryUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
