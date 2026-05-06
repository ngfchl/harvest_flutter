// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'production.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProductionCompany {

 int get id; String? get logoPath; String get name;@JsonKey(name: 'origin_country') String get originCountry;
/// Create a copy of ProductionCompany
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionCompanyCopyWith<ProductionCompany> get copyWith => _$ProductionCompanyCopyWithImpl<ProductionCompany>(this as ProductionCompany, _$identity);

  /// Serializes this ProductionCompany to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionCompany&&(identical(other.id, id) || other.id == id)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.name, name) || other.name == name)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,logoPath,name,originCountry);

@override
String toString() {
  return 'ProductionCompany(id: $id, logoPath: $logoPath, name: $name, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class $ProductionCompanyCopyWith<$Res>  {
  factory $ProductionCompanyCopyWith(ProductionCompany value, $Res Function(ProductionCompany) _then) = _$ProductionCompanyCopyWithImpl;
@useResult
$Res call({
 int id, String? logoPath, String name,@JsonKey(name: 'origin_country') String originCountry
});




}
/// @nodoc
class _$ProductionCompanyCopyWithImpl<$Res>
    implements $ProductionCompanyCopyWith<$Res> {
  _$ProductionCompanyCopyWithImpl(this._self, this._then);

  final ProductionCompany _self;
  final $Res Function(ProductionCompany) _then;

/// Create a copy of ProductionCompany
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? logoPath = freezed,Object? name = null,Object? originCountry = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionCompany].
extension ProductionCompanyPatterns on ProductionCompany {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionCompany value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionCompany() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionCompany value)  $default,){
final _that = this;
switch (_that) {
case _ProductionCompany():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionCompany value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionCompany() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionCompany() when $default != null:
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)  $default,) {final _that = this;
switch (_that) {
case _ProductionCompany():
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)?  $default,) {final _that = this;
switch (_that) {
case _ProductionCompany() when $default != null:
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductionCompany implements ProductionCompany {
  const _ProductionCompany({this.id = 0, this.logoPath, this.name = '', @JsonKey(name: 'origin_country') this.originCountry = ''});
  factory _ProductionCompany.fromJson(Map<String, dynamic> json) => _$ProductionCompanyFromJson(json);

@override@JsonKey() final  int id;
@override final  String? logoPath;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'origin_country') final  String originCountry;

/// Create a copy of ProductionCompany
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionCompanyCopyWith<_ProductionCompany> get copyWith => __$ProductionCompanyCopyWithImpl<_ProductionCompany>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductionCompanyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionCompany&&(identical(other.id, id) || other.id == id)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.name, name) || other.name == name)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,logoPath,name,originCountry);

@override
String toString() {
  return 'ProductionCompany(id: $id, logoPath: $logoPath, name: $name, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class _$ProductionCompanyCopyWith<$Res> implements $ProductionCompanyCopyWith<$Res> {
  factory _$ProductionCompanyCopyWith(_ProductionCompany value, $Res Function(_ProductionCompany) _then) = __$ProductionCompanyCopyWithImpl;
@override @useResult
$Res call({
 int id, String? logoPath, String name,@JsonKey(name: 'origin_country') String originCountry
});




}
/// @nodoc
class __$ProductionCompanyCopyWithImpl<$Res>
    implements _$ProductionCompanyCopyWith<$Res> {
  __$ProductionCompanyCopyWithImpl(this._self, this._then);

  final _ProductionCompany _self;
  final $Res Function(_ProductionCompany) _then;

/// Create a copy of ProductionCompany
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? logoPath = freezed,Object? name = null,Object? originCountry = null,}) {
  return _then(_ProductionCompany(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ProductionCountry {

@JsonKey(name: 'iso_3166_1') String get iso31661; String get name;
/// Create a copy of ProductionCountry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductionCountryCopyWith<ProductionCountry> get copyWith => _$ProductionCountryCopyWithImpl<ProductionCountry>(this as ProductionCountry, _$identity);

  /// Serializes this ProductionCountry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductionCountry&&(identical(other.iso31661, iso31661) || other.iso31661 == iso31661)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iso31661,name);

@override
String toString() {
  return 'ProductionCountry(iso31661: $iso31661, name: $name)';
}


}

/// @nodoc
abstract mixin class $ProductionCountryCopyWith<$Res>  {
  factory $ProductionCountryCopyWith(ProductionCountry value, $Res Function(ProductionCountry) _then) = _$ProductionCountryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'iso_3166_1') String iso31661, String name
});




}
/// @nodoc
class _$ProductionCountryCopyWithImpl<$Res>
    implements $ProductionCountryCopyWith<$Res> {
  _$ProductionCountryCopyWithImpl(this._self, this._then);

  final ProductionCountry _self;
  final $Res Function(ProductionCountry) _then;

/// Create a copy of ProductionCountry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? iso31661 = null,Object? name = null,}) {
  return _then(_self.copyWith(
iso31661: null == iso31661 ? _self.iso31661 : iso31661 // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductionCountry].
extension ProductionCountryPatterns on ProductionCountry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductionCountry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductionCountry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductionCountry value)  $default,){
final _that = this;
switch (_that) {
case _ProductionCountry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductionCountry value)?  $default,){
final _that = this;
switch (_that) {
case _ProductionCountry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'iso_3166_1')  String iso31661,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductionCountry() when $default != null:
return $default(_that.iso31661,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'iso_3166_1')  String iso31661,  String name)  $default,) {final _that = this;
switch (_that) {
case _ProductionCountry():
return $default(_that.iso31661,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'iso_3166_1')  String iso31661,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ProductionCountry() when $default != null:
return $default(_that.iso31661,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProductionCountry implements ProductionCountry {
  const _ProductionCountry({@JsonKey(name: 'iso_3166_1') this.iso31661 = '', this.name = ''});
  factory _ProductionCountry.fromJson(Map<String, dynamic> json) => _$ProductionCountryFromJson(json);

@override@JsonKey(name: 'iso_3166_1') final  String iso31661;
@override@JsonKey() final  String name;

/// Create a copy of ProductionCountry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductionCountryCopyWith<_ProductionCountry> get copyWith => __$ProductionCountryCopyWithImpl<_ProductionCountry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductionCountryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductionCountry&&(identical(other.iso31661, iso31661) || other.iso31661 == iso31661)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,iso31661,name);

@override
String toString() {
  return 'ProductionCountry(iso31661: $iso31661, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ProductionCountryCopyWith<$Res> implements $ProductionCountryCopyWith<$Res> {
  factory _$ProductionCountryCopyWith(_ProductionCountry value, $Res Function(_ProductionCountry) _then) = __$ProductionCountryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'iso_3166_1') String iso31661, String name
});




}
/// @nodoc
class __$ProductionCountryCopyWithImpl<$Res>
    implements _$ProductionCountryCopyWith<$Res> {
  __$ProductionCountryCopyWithImpl(this._self, this._then);

  final _ProductionCountry _self;
  final $Res Function(_ProductionCountry) _then;

/// Create a copy of ProductionCountry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? iso31661 = null,Object? name = null,}) {
  return _then(_ProductionCountry(
iso31661: null == iso31661 ? _self.iso31661 : iso31661 // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SpokenLanguage {

@JsonKey(name: 'english_name') String get englishName;@JsonKey(name: 'iso_639_1') String get iso6391; String get name;
/// Create a copy of SpokenLanguage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SpokenLanguageCopyWith<SpokenLanguage> get copyWith => _$SpokenLanguageCopyWithImpl<SpokenLanguage>(this as SpokenLanguage, _$identity);

  /// Serializes this SpokenLanguage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SpokenLanguage&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.iso6391, iso6391) || other.iso6391 == iso6391)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,englishName,iso6391,name);

@override
String toString() {
  return 'SpokenLanguage(englishName: $englishName, iso6391: $iso6391, name: $name)';
}


}

/// @nodoc
abstract mixin class $SpokenLanguageCopyWith<$Res>  {
  factory $SpokenLanguageCopyWith(SpokenLanguage value, $Res Function(SpokenLanguage) _then) = _$SpokenLanguageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'english_name') String englishName,@JsonKey(name: 'iso_639_1') String iso6391, String name
});




}
/// @nodoc
class _$SpokenLanguageCopyWithImpl<$Res>
    implements $SpokenLanguageCopyWith<$Res> {
  _$SpokenLanguageCopyWithImpl(this._self, this._then);

  final SpokenLanguage _self;
  final $Res Function(SpokenLanguage) _then;

/// Create a copy of SpokenLanguage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? englishName = null,Object? iso6391 = null,Object? name = null,}) {
  return _then(_self.copyWith(
englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,iso6391: null == iso6391 ? _self.iso6391 : iso6391 // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SpokenLanguage].
extension SpokenLanguagePatterns on SpokenLanguage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SpokenLanguage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SpokenLanguage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SpokenLanguage value)  $default,){
final _that = this;
switch (_that) {
case _SpokenLanguage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SpokenLanguage value)?  $default,){
final _that = this;
switch (_that) {
case _SpokenLanguage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'iso_639_1')  String iso6391,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SpokenLanguage() when $default != null:
return $default(_that.englishName,_that.iso6391,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'iso_639_1')  String iso6391,  String name)  $default,) {final _that = this;
switch (_that) {
case _SpokenLanguage():
return $default(_that.englishName,_that.iso6391,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'english_name')  String englishName, @JsonKey(name: 'iso_639_1')  String iso6391,  String name)?  $default,) {final _that = this;
switch (_that) {
case _SpokenLanguage() when $default != null:
return $default(_that.englishName,_that.iso6391,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SpokenLanguage implements SpokenLanguage {
  const _SpokenLanguage({@JsonKey(name: 'english_name') this.englishName = '', @JsonKey(name: 'iso_639_1') this.iso6391 = '', this.name = ''});
  factory _SpokenLanguage.fromJson(Map<String, dynamic> json) => _$SpokenLanguageFromJson(json);

@override@JsonKey(name: 'english_name') final  String englishName;
@override@JsonKey(name: 'iso_639_1') final  String iso6391;
@override@JsonKey() final  String name;

/// Create a copy of SpokenLanguage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SpokenLanguageCopyWith<_SpokenLanguage> get copyWith => __$SpokenLanguageCopyWithImpl<_SpokenLanguage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SpokenLanguageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SpokenLanguage&&(identical(other.englishName, englishName) || other.englishName == englishName)&&(identical(other.iso6391, iso6391) || other.iso6391 == iso6391)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,englishName,iso6391,name);

@override
String toString() {
  return 'SpokenLanguage(englishName: $englishName, iso6391: $iso6391, name: $name)';
}


}

/// @nodoc
abstract mixin class _$SpokenLanguageCopyWith<$Res> implements $SpokenLanguageCopyWith<$Res> {
  factory _$SpokenLanguageCopyWith(_SpokenLanguage value, $Res Function(_SpokenLanguage) _then) = __$SpokenLanguageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'english_name') String englishName,@JsonKey(name: 'iso_639_1') String iso6391, String name
});




}
/// @nodoc
class __$SpokenLanguageCopyWithImpl<$Res>
    implements _$SpokenLanguageCopyWith<$Res> {
  __$SpokenLanguageCopyWithImpl(this._self, this._then);

  final _SpokenLanguage _self;
  final $Res Function(_SpokenLanguage) _then;

/// Create a copy of SpokenLanguage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? englishName = null,Object? iso6391 = null,Object? name = null,}) {
  return _then(_SpokenLanguage(
englishName: null == englishName ? _self.englishName : englishName // ignore: cast_nullable_to_non_nullable
as String,iso6391: null == iso6391 ? _self.iso6391 : iso6391 // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Network {

 int get id;@JsonKey(name: 'logo_path') String get logoPath; String get name;@JsonKey(name: 'origin_country') String get originCountry;
/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkCopyWith<Network> get copyWith => _$NetworkCopyWithImpl<Network>(this as Network, _$identity);

  /// Serializes this Network to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Network&&(identical(other.id, id) || other.id == id)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.name, name) || other.name == name)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,logoPath,name,originCountry);

@override
String toString() {
  return 'Network(id: $id, logoPath: $logoPath, name: $name, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class $NetworkCopyWith<$Res>  {
  factory $NetworkCopyWith(Network value, $Res Function(Network) _then) = _$NetworkCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'logo_path') String logoPath, String name,@JsonKey(name: 'origin_country') String originCountry
});




}
/// @nodoc
class _$NetworkCopyWithImpl<$Res>
    implements $NetworkCopyWith<$Res> {
  _$NetworkCopyWithImpl(this._self, this._then);

  final Network _self;
  final $Res Function(Network) _then;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? logoPath = null,Object? name = null,Object? originCountry = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,logoPath: null == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Network].
extension NetworkPatterns on Network {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Network value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Network() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Network value)  $default,){
final _that = this;
switch (_that) {
case _Network():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Network value)?  $default,){
final _that = this;
switch (_that) {
case _Network() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'logo_path')  String logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Network() when $default != null:
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'logo_path')  String logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)  $default,) {final _that = this;
switch (_that) {
case _Network():
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'logo_path')  String logoPath,  String name, @JsonKey(name: 'origin_country')  String originCountry)?  $default,) {final _that = this;
switch (_that) {
case _Network() when $default != null:
return $default(_that.id,_that.logoPath,_that.name,_that.originCountry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Network implements Network {
  const _Network({this.id = 0, @JsonKey(name: 'logo_path') this.logoPath = '', this.name = '', @JsonKey(name: 'origin_country') this.originCountry = ''});
  factory _Network.fromJson(Map<String, dynamic> json) => _$NetworkFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey(name: 'logo_path') final  String logoPath;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'origin_country') final  String originCountry;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkCopyWith<_Network> get copyWith => __$NetworkCopyWithImpl<_Network>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Network&&(identical(other.id, id) || other.id == id)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.name, name) || other.name == name)&&(identical(other.originCountry, originCountry) || other.originCountry == originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,logoPath,name,originCountry);

@override
String toString() {
  return 'Network(id: $id, logoPath: $logoPath, name: $name, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class _$NetworkCopyWith<$Res> implements $NetworkCopyWith<$Res> {
  factory _$NetworkCopyWith(_Network value, $Res Function(_Network) _then) = __$NetworkCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'logo_path') String logoPath, String name,@JsonKey(name: 'origin_country') String originCountry
});




}
/// @nodoc
class __$NetworkCopyWithImpl<$Res>
    implements _$NetworkCopyWith<$Res> {
  __$NetworkCopyWithImpl(this._self, this._then);

  final _Network _self;
  final $Res Function(_Network) _then;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? logoPath = null,Object? name = null,Object? originCountry = null,}) {
  return _then(_Network(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,logoPath: null == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
