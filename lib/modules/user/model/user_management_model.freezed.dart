// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_management_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ManagedUser {

 int get id; String get username;@JsonKey(name: 'is_active') bool get isActive;@JsonKey(name: 'is_staff') bool get isStaff;@JsonKey(name: 'is_superuser') bool get isSuperuser; String get email;
/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagedUserCopyWith<ManagedUser> get copyWith => _$ManagedUserCopyWithImpl<ManagedUser>(this as ManagedUser, _$identity);

  /// Serializes this ManagedUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,isActive,isStaff,isSuperuser,email);

@override
String toString() {
  return 'ManagedUser(id: $id, username: $username, isActive: $isActive, isStaff: $isStaff, isSuperuser: $isSuperuser, email: $email)';
}


}

/// @nodoc
abstract mixin class $ManagedUserCopyWith<$Res>  {
  factory $ManagedUserCopyWith(ManagedUser value, $Res Function(ManagedUser) _then) = _$ManagedUserCopyWithImpl;
@useResult
$Res call({
 int id, String username,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_staff') bool isStaff,@JsonKey(name: 'is_superuser') bool isSuperuser, String email
});




}
/// @nodoc
class _$ManagedUserCopyWithImpl<$Res>
    implements $ManagedUserCopyWith<$Res> {
  _$ManagedUserCopyWithImpl(this._self, this._then);

  final ManagedUser _self;
  final $Res Function(ManagedUser) _then;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? isActive = null,Object? isStaff = null,Object? isSuperuser = null,Object? email = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isStaff: null == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagedUser].
extension ManagedUserPatterns on ManagedUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagedUser value)  $default,){
final _that = this;
switch (_that) {
case _ManagedUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagedUser value)?  $default,){
final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser,  String email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that.id,_that.username,_that.isActive,_that.isStaff,_that.isSuperuser,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String username, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser,  String email)  $default,) {final _that = this;
switch (_that) {
case _ManagedUser():
return $default(_that.id,_that.username,_that.isActive,_that.isStaff,_that.isSuperuser,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String username, @JsonKey(name: 'is_active')  bool isActive, @JsonKey(name: 'is_staff')  bool isStaff, @JsonKey(name: 'is_superuser')  bool isSuperuser,  String email)?  $default,) {final _that = this;
switch (_that) {
case _ManagedUser() when $default != null:
return $default(_that.id,_that.username,_that.isActive,_that.isStaff,_that.isSuperuser,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ManagedUser implements ManagedUser {
  const _ManagedUser({this.id = 0, this.username = '', @JsonKey(name: 'is_active') this.isActive = false, @JsonKey(name: 'is_staff') this.isStaff = false, @JsonKey(name: 'is_superuser') this.isSuperuser = false, this.email = ''});
  factory _ManagedUser.fromJson(Map<String, dynamic> json) => _$ManagedUserFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String username;
@override@JsonKey(name: 'is_active') final  bool isActive;
@override@JsonKey(name: 'is_staff') final  bool isStaff;
@override@JsonKey(name: 'is_superuser') final  bool isSuperuser;
@override@JsonKey() final  String email;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagedUserCopyWith<_ManagedUser> get copyWith => __$ManagedUserCopyWithImpl<_ManagedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isStaff, isStaff) || other.isStaff == isStaff)&&(identical(other.isSuperuser, isSuperuser) || other.isSuperuser == isSuperuser)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,isActive,isStaff,isSuperuser,email);

@override
String toString() {
  return 'ManagedUser(id: $id, username: $username, isActive: $isActive, isStaff: $isStaff, isSuperuser: $isSuperuser, email: $email)';
}


}

/// @nodoc
abstract mixin class _$ManagedUserCopyWith<$Res> implements $ManagedUserCopyWith<$Res> {
  factory _$ManagedUserCopyWith(_ManagedUser value, $Res Function(_ManagedUser) _then) = __$ManagedUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String username,@JsonKey(name: 'is_active') bool isActive,@JsonKey(name: 'is_staff') bool isStaff,@JsonKey(name: 'is_superuser') bool isSuperuser, String email
});




}
/// @nodoc
class __$ManagedUserCopyWithImpl<$Res>
    implements _$ManagedUserCopyWith<$Res> {
  __$ManagedUserCopyWithImpl(this._self, this._then);

  final _ManagedUser _self;
  final $Res Function(_ManagedUser) _then;

/// Create a copy of ManagedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? isActive = null,Object? isStaff = null,Object? isSuperuser = null,Object? email = null,}) {
  return _then(_ManagedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isStaff: null == isStaff ? _self.isStaff : isStaff // ignore: cast_nullable_to_non_nullable
as bool,isSuperuser: null == isSuperuser ? _self.isSuperuser : isSuperuser // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UserCredentials {

 String get username; String get password;
/// Create a copy of UserCredentials
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCredentialsCopyWith<UserCredentials> get copyWith => _$UserCredentialsCopyWithImpl<UserCredentials>(this as UserCredentials, _$identity);

  /// Serializes this UserCredentials to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserCredentials&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'UserCredentials(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class $UserCredentialsCopyWith<$Res>  {
  factory $UserCredentialsCopyWith(UserCredentials value, $Res Function(UserCredentials) _then) = _$UserCredentialsCopyWithImpl;
@useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class _$UserCredentialsCopyWithImpl<$Res>
    implements $UserCredentialsCopyWith<$Res> {
  _$UserCredentialsCopyWithImpl(this._self, this._then);

  final UserCredentials _self;
  final $Res Function(UserCredentials) _then;

/// Create a copy of UserCredentials
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? password = null,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserCredentials].
extension UserCredentialsPatterns on UserCredentials {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserCredentials value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserCredentials() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserCredentials value)  $default,){
final _that = this;
switch (_that) {
case _UserCredentials():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserCredentials value)?  $default,){
final _that = this;
switch (_that) {
case _UserCredentials() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String password)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserCredentials() when $default != null:
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String password)  $default,) {final _that = this;
switch (_that) {
case _UserCredentials():
return $default(_that.username,_that.password);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String password)?  $default,) {final _that = this;
switch (_that) {
case _UserCredentials() when $default != null:
return $default(_that.username,_that.password);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserCredentials implements UserCredentials {
  const _UserCredentials({required this.username, required this.password});
  factory _UserCredentials.fromJson(Map<String, dynamic> json) => _$UserCredentialsFromJson(json);

@override final  String username;
@override final  String password;

/// Create a copy of UserCredentials
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCredentialsCopyWith<_UserCredentials> get copyWith => __$UserCredentialsCopyWithImpl<_UserCredentials>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserCredentialsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserCredentials&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,password);

@override
String toString() {
  return 'UserCredentials(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class _$UserCredentialsCopyWith<$Res> implements $UserCredentialsCopyWith<$Res> {
  factory _$UserCredentialsCopyWith(_UserCredentials value, $Res Function(_UserCredentials) _then) = __$UserCredentialsCopyWithImpl;
@override @useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class __$UserCredentialsCopyWithImpl<$Res>
    implements _$UserCredentialsCopyWith<$Res> {
  __$UserCredentialsCopyWithImpl(this._self, this._then);

  final _UserCredentials _self;
  final $Res Function(_UserCredentials) _then;

/// Create a copy of UserCredentials
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,}) {
  return _then(_UserCredentials(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
