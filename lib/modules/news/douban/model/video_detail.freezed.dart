// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DetailRating {

 int get count; int get max;@JsonKey(name: 'star_count') double get starCount; double get value;
/// Create a copy of DetailRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DetailRatingCopyWith<DetailRating> get copyWith => _$DetailRatingCopyWithImpl<DetailRating>(this as DetailRating, _$identity);

  /// Serializes this DetailRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DetailRating&&(identical(other.count, count) || other.count == count)&&(identical(other.max, max) || other.max == max)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,max,starCount,value);

@override
String toString() {
  return 'DetailRating(count: $count, max: $max, starCount: $starCount, value: $value)';
}


}

/// @nodoc
abstract mixin class $DetailRatingCopyWith<$Res>  {
  factory $DetailRatingCopyWith(DetailRating value, $Res Function(DetailRating) _then) = _$DetailRatingCopyWithImpl;
@useResult
$Res call({
 int count, int max,@JsonKey(name: 'star_count') double starCount, double value
});




}
/// @nodoc
class _$DetailRatingCopyWithImpl<$Res>
    implements $DetailRatingCopyWith<$Res> {
  _$DetailRatingCopyWithImpl(this._self, this._then);

  final DetailRating _self;
  final $Res Function(DetailRating) _then;

/// Create a copy of DetailRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? max = null,Object? starCount = null,Object? value = null,}) {
  return _then(_self.copyWith(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as double,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [DetailRating].
extension DetailRatingPatterns on DetailRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DetailRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DetailRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DetailRating value)  $default,){
final _that = this;
switch (_that) {
case _DetailRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DetailRating value)?  $default,){
final _that = this;
switch (_that) {
case _DetailRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DetailRating() when $default != null:
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)  $default,) {final _that = this;
switch (_that) {
case _DetailRating():
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  int max, @JsonKey(name: 'star_count')  double starCount,  double value)?  $default,) {final _that = this;
switch (_that) {
case _DetailRating() when $default != null:
return $default(_that.count,_that.max,_that.starCount,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DetailRating implements DetailRating {
  const _DetailRating({this.count = 0, this.max = 0, @JsonKey(name: 'star_count') this.starCount = 0.0, this.value = 0.0});
  factory _DetailRating.fromJson(Map<String, dynamic> json) => _$DetailRatingFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey() final  int max;
@override@JsonKey(name: 'star_count') final  double starCount;
@override@JsonKey() final  double value;

/// Create a copy of DetailRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DetailRatingCopyWith<_DetailRating> get copyWith => __$DetailRatingCopyWithImpl<_DetailRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DetailRatingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DetailRating&&(identical(other.count, count) || other.count == count)&&(identical(other.max, max) || other.max == max)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,count,max,starCount,value);

@override
String toString() {
  return 'DetailRating(count: $count, max: $max, starCount: $starCount, value: $value)';
}


}

/// @nodoc
abstract mixin class _$DetailRatingCopyWith<$Res> implements $DetailRatingCopyWith<$Res> {
  factory _$DetailRatingCopyWith(_DetailRating value, $Res Function(_DetailRating) _then) = __$DetailRatingCopyWithImpl;
@override @useResult
$Res call({
 int count, int max,@JsonKey(name: 'star_count') double starCount, double value
});




}
/// @nodoc
class __$DetailRatingCopyWithImpl<$Res>
    implements _$DetailRatingCopyWith<$Res> {
  __$DetailRatingCopyWithImpl(this._self, this._then);

  final _DetailRating _self;
  final $Res Function(_DetailRating) _then;

/// Create a copy of DetailRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? max = null,Object? starCount = null,Object? value = null,}) {
  return _then(_DetailRating(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as double,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$Person {

 String get name;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'Person(name: $name)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 String name
});




}
/// @nodoc
class _$PersonCopyWithImpl<$Res>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._self, this._then);

  final Person _self;
  final $Res Function(Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Person].
extension PersonPatterns on Person {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Person value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Person value)  $default,){
final _that = this;
switch (_that) {
case _Person():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Person value)?  $default,){
final _that = this;
switch (_that) {
case _Person() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Person implements Person {
  const _Person({this.name = ''});
  factory _Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

@override@JsonKey() final  String name;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonCopyWith<_Person> get copyWith => __$PersonCopyWithImpl<_Person>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name);

@override
String toString() {
  return 'Person(name: $name)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 String name
});




}
/// @nodoc
class __$PersonCopyWithImpl<$Res>
    implements _$PersonCopyWith<$Res> {
  __$PersonCopyWithImpl(this._self, this._then);

  final _Person _self;
  final $Res Function(_Person) _then;

/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,}) {
  return _then(_Person(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Pic {

 String get large; String get normal;
/// Create a copy of Pic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PicCopyWith<Pic> get copyWith => _$PicCopyWithImpl<Pic>(this as Pic, _$identity);

  /// Serializes this Pic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pic&&(identical(other.large, large) || other.large == large)&&(identical(other.normal, normal) || other.normal == normal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,large,normal);

@override
String toString() {
  return 'Pic(large: $large, normal: $normal)';
}


}

/// @nodoc
abstract mixin class $PicCopyWith<$Res>  {
  factory $PicCopyWith(Pic value, $Res Function(Pic) _then) = _$PicCopyWithImpl;
@useResult
$Res call({
 String large, String normal
});




}
/// @nodoc
class _$PicCopyWithImpl<$Res>
    implements $PicCopyWith<$Res> {
  _$PicCopyWithImpl(this._self, this._then);

  final Pic _self;
  final $Res Function(Pic) _then;

/// Create a copy of Pic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? large = null,Object? normal = null,}) {
  return _then(_self.copyWith(
large: null == large ? _self.large : large // ignore: cast_nullable_to_non_nullable
as String,normal: null == normal ? _self.normal : normal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Pic].
extension PicPatterns on Pic {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pic value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pic() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pic value)  $default,){
final _that = this;
switch (_that) {
case _Pic():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pic value)?  $default,){
final _that = this;
switch (_that) {
case _Pic() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String large,  String normal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pic() when $default != null:
return $default(_that.large,_that.normal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String large,  String normal)  $default,) {final _that = this;
switch (_that) {
case _Pic():
return $default(_that.large,_that.normal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String large,  String normal)?  $default,) {final _that = this;
switch (_that) {
case _Pic() when $default != null:
return $default(_that.large,_that.normal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pic implements Pic {
  const _Pic({this.large = '', this.normal = ''});
  factory _Pic.fromJson(Map<String, dynamic> json) => _$PicFromJson(json);

@override@JsonKey() final  String large;
@override@JsonKey() final  String normal;

/// Create a copy of Pic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PicCopyWith<_Pic> get copyWith => __$PicCopyWithImpl<_Pic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pic&&(identical(other.large, large) || other.large == large)&&(identical(other.normal, normal) || other.normal == normal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,large,normal);

@override
String toString() {
  return 'Pic(large: $large, normal: $normal)';
}


}

/// @nodoc
abstract mixin class _$PicCopyWith<$Res> implements $PicCopyWith<$Res> {
  factory _$PicCopyWith(_Pic value, $Res Function(_Pic) _then) = __$PicCopyWithImpl;
@override @useResult
$Res call({
 String large, String normal
});




}
/// @nodoc
class __$PicCopyWithImpl<$Res>
    implements _$PicCopyWith<$Res> {
  __$PicCopyWithImpl(this._self, this._then);

  final _Pic _self;
  final $Res Function(_Pic) _then;

/// Create a copy of Pic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? large = null,Object? normal = null,}) {
  return _then(_Pic(
large: null == large ? _self.large : large // ignore: cast_nullable_to_non_nullable
as String,normal: null == normal ? _self.normal : normal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Trailer {

@JsonKey(name: 'cover_url') String get coverUrl; String get title;@JsonKey(name: 'type_name') String get typeName;@JsonKey(name: 'video_url') String get videoUrl; String get runtime;
/// Create a copy of Trailer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrailerCopyWith<Trailer> get copyWith => _$TrailerCopyWithImpl<Trailer>(this as Trailer, _$identity);

  /// Serializes this Trailer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trailer&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.typeName, typeName) || other.typeName == typeName)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.runtime, runtime) || other.runtime == runtime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coverUrl,title,typeName,videoUrl,runtime);

@override
String toString() {
  return 'Trailer(coverUrl: $coverUrl, title: $title, typeName: $typeName, videoUrl: $videoUrl, runtime: $runtime)';
}


}

/// @nodoc
abstract mixin class $TrailerCopyWith<$Res>  {
  factory $TrailerCopyWith(Trailer value, $Res Function(Trailer) _then) = _$TrailerCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'cover_url') String coverUrl, String title,@JsonKey(name: 'type_name') String typeName,@JsonKey(name: 'video_url') String videoUrl, String runtime
});




}
/// @nodoc
class _$TrailerCopyWithImpl<$Res>
    implements $TrailerCopyWith<$Res> {
  _$TrailerCopyWithImpl(this._self, this._then);

  final Trailer _self;
  final $Res Function(Trailer) _then;

/// Create a copy of Trailer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coverUrl = null,Object? title = null,Object? typeName = null,Object? videoUrl = null,Object? runtime = null,}) {
  return _then(_self.copyWith(
coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Trailer].
extension TrailerPatterns on Trailer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trailer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trailer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trailer value)  $default,){
final _that = this;
switch (_that) {
case _Trailer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trailer value)?  $default,){
final _that = this;
switch (_that) {
case _Trailer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'cover_url')  String coverUrl,  String title, @JsonKey(name: 'type_name')  String typeName, @JsonKey(name: 'video_url')  String videoUrl,  String runtime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trailer() when $default != null:
return $default(_that.coverUrl,_that.title,_that.typeName,_that.videoUrl,_that.runtime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'cover_url')  String coverUrl,  String title, @JsonKey(name: 'type_name')  String typeName, @JsonKey(name: 'video_url')  String videoUrl,  String runtime)  $default,) {final _that = this;
switch (_that) {
case _Trailer():
return $default(_that.coverUrl,_that.title,_that.typeName,_that.videoUrl,_that.runtime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'cover_url')  String coverUrl,  String title, @JsonKey(name: 'type_name')  String typeName, @JsonKey(name: 'video_url')  String videoUrl,  String runtime)?  $default,) {final _that = this;
switch (_that) {
case _Trailer() when $default != null:
return $default(_that.coverUrl,_that.title,_that.typeName,_that.videoUrl,_that.runtime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Trailer implements Trailer {
  const _Trailer({@JsonKey(name: 'cover_url') this.coverUrl = '', this.title = '', @JsonKey(name: 'type_name') this.typeName = '', @JsonKey(name: 'video_url') this.videoUrl = '', this.runtime = ''});
  factory _Trailer.fromJson(Map<String, dynamic> json) => _$TrailerFromJson(json);

@override@JsonKey(name: 'cover_url') final  String coverUrl;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'type_name') final  String typeName;
@override@JsonKey(name: 'video_url') final  String videoUrl;
@override@JsonKey() final  String runtime;

/// Create a copy of Trailer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrailerCopyWith<_Trailer> get copyWith => __$TrailerCopyWithImpl<_Trailer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrailerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trailer&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.typeName, typeName) || other.typeName == typeName)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.runtime, runtime) || other.runtime == runtime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coverUrl,title,typeName,videoUrl,runtime);

@override
String toString() {
  return 'Trailer(coverUrl: $coverUrl, title: $title, typeName: $typeName, videoUrl: $videoUrl, runtime: $runtime)';
}


}

/// @nodoc
abstract mixin class _$TrailerCopyWith<$Res> implements $TrailerCopyWith<$Res> {
  factory _$TrailerCopyWith(_Trailer value, $Res Function(_Trailer) _then) = __$TrailerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'cover_url') String coverUrl, String title,@JsonKey(name: 'type_name') String typeName,@JsonKey(name: 'video_url') String videoUrl, String runtime
});




}
/// @nodoc
class __$TrailerCopyWithImpl<$Res>
    implements _$TrailerCopyWith<$Res> {
  __$TrailerCopyWithImpl(this._self, this._then);

  final _Trailer _self;
  final $Res Function(_Trailer) _then;

/// Create a copy of Trailer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coverUrl = null,Object? title = null,Object? typeName = null,Object? videoUrl = null,Object? runtime = null,}) {
  return _then(_Trailer(
coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,typeName: null == typeName ? _self.typeName : typeName // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Vendor {

 String get id; String get title; String get icon;@JsonKey(name: 'grey_icon') String get greyIcon; String get url;@JsonKey(name: 'episodes_info') String get episodesInfo;@JsonKey(name: 'payment_desc') String get paymentDesc; bool get accessible;@JsonKey(name: 'is_paid') bool get isPaid;
/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorCopyWith<Vendor> get copyWith => _$VendorCopyWithImpl<Vendor>(this as Vendor, _$identity);

  /// Serializes this Vendor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Vendor&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.greyIcon, greyIcon) || other.greyIcon == greyIcon)&&(identical(other.url, url) || other.url == url)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&(identical(other.paymentDesc, paymentDesc) || other.paymentDesc == paymentDesc)&&(identical(other.accessible, accessible) || other.accessible == accessible)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,icon,greyIcon,url,episodesInfo,paymentDesc,accessible,isPaid);

@override
String toString() {
  return 'Vendor(id: $id, title: $title, icon: $icon, greyIcon: $greyIcon, url: $url, episodesInfo: $episodesInfo, paymentDesc: $paymentDesc, accessible: $accessible, isPaid: $isPaid)';
}


}

/// @nodoc
abstract mixin class $VendorCopyWith<$Res>  {
  factory $VendorCopyWith(Vendor value, $Res Function(Vendor) _then) = _$VendorCopyWithImpl;
@useResult
$Res call({
 String id, String title, String icon,@JsonKey(name: 'grey_icon') String greyIcon, String url,@JsonKey(name: 'episodes_info') String episodesInfo,@JsonKey(name: 'payment_desc') String paymentDesc, bool accessible,@JsonKey(name: 'is_paid') bool isPaid
});




}
/// @nodoc
class _$VendorCopyWithImpl<$Res>
    implements $VendorCopyWith<$Res> {
  _$VendorCopyWithImpl(this._self, this._then);

  final Vendor _self;
  final $Res Function(Vendor) _then;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? greyIcon = null,Object? url = null,Object? episodesInfo = null,Object? paymentDesc = null,Object? accessible = null,Object? isPaid = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,greyIcon: null == greyIcon ? _self.greyIcon : greyIcon // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,paymentDesc: null == paymentDesc ? _self.paymentDesc : paymentDesc // ignore: cast_nullable_to_non_nullable
as String,accessible: null == accessible ? _self.accessible : accessible // ignore: cast_nullable_to_non_nullable
as bool,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Vendor].
extension VendorPatterns on Vendor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Vendor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Vendor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Vendor value)  $default,){
final _that = this;
switch (_that) {
case _Vendor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Vendor value)?  $default,){
final _that = this;
switch (_that) {
case _Vendor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String icon, @JsonKey(name: 'grey_icon')  String greyIcon,  String url, @JsonKey(name: 'episodes_info')  String episodesInfo, @JsonKey(name: 'payment_desc')  String paymentDesc,  bool accessible, @JsonKey(name: 'is_paid')  bool isPaid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Vendor() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.greyIcon,_that.url,_that.episodesInfo,_that.paymentDesc,_that.accessible,_that.isPaid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String icon, @JsonKey(name: 'grey_icon')  String greyIcon,  String url, @JsonKey(name: 'episodes_info')  String episodesInfo, @JsonKey(name: 'payment_desc')  String paymentDesc,  bool accessible, @JsonKey(name: 'is_paid')  bool isPaid)  $default,) {final _that = this;
switch (_that) {
case _Vendor():
return $default(_that.id,_that.title,_that.icon,_that.greyIcon,_that.url,_that.episodesInfo,_that.paymentDesc,_that.accessible,_that.isPaid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String icon, @JsonKey(name: 'grey_icon')  String greyIcon,  String url, @JsonKey(name: 'episodes_info')  String episodesInfo, @JsonKey(name: 'payment_desc')  String paymentDesc,  bool accessible, @JsonKey(name: 'is_paid')  bool isPaid)?  $default,) {final _that = this;
switch (_that) {
case _Vendor() when $default != null:
return $default(_that.id,_that.title,_that.icon,_that.greyIcon,_that.url,_that.episodesInfo,_that.paymentDesc,_that.accessible,_that.isPaid);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Vendor implements Vendor {
  const _Vendor({this.id = '', this.title = '', this.icon = '', @JsonKey(name: 'grey_icon') this.greyIcon = '', this.url = '', @JsonKey(name: 'episodes_info') this.episodesInfo = '', @JsonKey(name: 'payment_desc') this.paymentDesc = '', this.accessible = false, @JsonKey(name: 'is_paid') this.isPaid = false});
  factory _Vendor.fromJson(Map<String, dynamic> json) => _$VendorFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String icon;
@override@JsonKey(name: 'grey_icon') final  String greyIcon;
@override@JsonKey() final  String url;
@override@JsonKey(name: 'episodes_info') final  String episodesInfo;
@override@JsonKey(name: 'payment_desc') final  String paymentDesc;
@override@JsonKey() final  bool accessible;
@override@JsonKey(name: 'is_paid') final  bool isPaid;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorCopyWith<_Vendor> get copyWith => __$VendorCopyWithImpl<_Vendor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Vendor&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.greyIcon, greyIcon) || other.greyIcon == greyIcon)&&(identical(other.url, url) || other.url == url)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&(identical(other.paymentDesc, paymentDesc) || other.paymentDesc == paymentDesc)&&(identical(other.accessible, accessible) || other.accessible == accessible)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,icon,greyIcon,url,episodesInfo,paymentDesc,accessible,isPaid);

@override
String toString() {
  return 'Vendor(id: $id, title: $title, icon: $icon, greyIcon: $greyIcon, url: $url, episodesInfo: $episodesInfo, paymentDesc: $paymentDesc, accessible: $accessible, isPaid: $isPaid)';
}


}

/// @nodoc
abstract mixin class _$VendorCopyWith<$Res> implements $VendorCopyWith<$Res> {
  factory _$VendorCopyWith(_Vendor value, $Res Function(_Vendor) _then) = __$VendorCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String icon,@JsonKey(name: 'grey_icon') String greyIcon, String url,@JsonKey(name: 'episodes_info') String episodesInfo,@JsonKey(name: 'payment_desc') String paymentDesc, bool accessible,@JsonKey(name: 'is_paid') bool isPaid
});




}
/// @nodoc
class __$VendorCopyWithImpl<$Res>
    implements _$VendorCopyWith<$Res> {
  __$VendorCopyWithImpl(this._self, this._then);

  final _Vendor _self;
  final $Res Function(_Vendor) _then;

/// Create a copy of Vendor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? icon = null,Object? greyIcon = null,Object? url = null,Object? episodesInfo = null,Object? paymentDesc = null,Object? accessible = null,Object? isPaid = null,}) {
  return _then(_Vendor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,greyIcon: null == greyIcon ? _self.greyIcon : greyIcon // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,paymentDesc: null == paymentDesc ? _self.paymentDesc : paymentDesc // ignore: cast_nullable_to_non_nullable
as String,accessible: null == accessible ? _self.accessible : accessible // ignore: cast_nullable_to_non_nullable
as bool,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$LinewatchSource {

 String get literal; String get name; String get pic;
/// Create a copy of LinewatchSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinewatchSourceCopyWith<LinewatchSource> get copyWith => _$LinewatchSourceCopyWithImpl<LinewatchSource>(this as LinewatchSource, _$identity);

  /// Serializes this LinewatchSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinewatchSource&&(identical(other.literal, literal) || other.literal == literal)&&(identical(other.name, name) || other.name == name)&&(identical(other.pic, pic) || other.pic == pic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,literal,name,pic);

@override
String toString() {
  return 'LinewatchSource(literal: $literal, name: $name, pic: $pic)';
}


}

/// @nodoc
abstract mixin class $LinewatchSourceCopyWith<$Res>  {
  factory $LinewatchSourceCopyWith(LinewatchSource value, $Res Function(LinewatchSource) _then) = _$LinewatchSourceCopyWithImpl;
@useResult
$Res call({
 String literal, String name, String pic
});




}
/// @nodoc
class _$LinewatchSourceCopyWithImpl<$Res>
    implements $LinewatchSourceCopyWith<$Res> {
  _$LinewatchSourceCopyWithImpl(this._self, this._then);

  final LinewatchSource _self;
  final $Res Function(LinewatchSource) _then;

/// Create a copy of LinewatchSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? literal = null,Object? name = null,Object? pic = null,}) {
  return _then(_self.copyWith(
literal: null == literal ? _self.literal : literal // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LinewatchSource].
extension LinewatchSourcePatterns on LinewatchSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinewatchSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinewatchSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinewatchSource value)  $default,){
final _that = this;
switch (_that) {
case _LinewatchSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinewatchSource value)?  $default,){
final _that = this;
switch (_that) {
case _LinewatchSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String literal,  String name,  String pic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinewatchSource() when $default != null:
return $default(_that.literal,_that.name,_that.pic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String literal,  String name,  String pic)  $default,) {final _that = this;
switch (_that) {
case _LinewatchSource():
return $default(_that.literal,_that.name,_that.pic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String literal,  String name,  String pic)?  $default,) {final _that = this;
switch (_that) {
case _LinewatchSource() when $default != null:
return $default(_that.literal,_that.name,_that.pic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinewatchSource implements LinewatchSource {
  const _LinewatchSource({this.literal = '', this.name = '', this.pic = ''});
  factory _LinewatchSource.fromJson(Map<String, dynamic> json) => _$LinewatchSourceFromJson(json);

@override@JsonKey() final  String literal;
@override@JsonKey() final  String name;
@override@JsonKey() final  String pic;

/// Create a copy of LinewatchSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinewatchSourceCopyWith<_LinewatchSource> get copyWith => __$LinewatchSourceCopyWithImpl<_LinewatchSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinewatchSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinewatchSource&&(identical(other.literal, literal) || other.literal == literal)&&(identical(other.name, name) || other.name == name)&&(identical(other.pic, pic) || other.pic == pic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,literal,name,pic);

@override
String toString() {
  return 'LinewatchSource(literal: $literal, name: $name, pic: $pic)';
}


}

/// @nodoc
abstract mixin class _$LinewatchSourceCopyWith<$Res> implements $LinewatchSourceCopyWith<$Res> {
  factory _$LinewatchSourceCopyWith(_LinewatchSource value, $Res Function(_LinewatchSource) _then) = __$LinewatchSourceCopyWithImpl;
@override @useResult
$Res call({
 String literal, String name, String pic
});




}
/// @nodoc
class __$LinewatchSourceCopyWithImpl<$Res>
    implements _$LinewatchSourceCopyWith<$Res> {
  __$LinewatchSourceCopyWithImpl(this._self, this._then);

  final _LinewatchSource _self;
  final $Res Function(_LinewatchSource) _then;

/// Create a copy of LinewatchSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? literal = null,Object? name = null,Object? pic = null,}) {
  return _then(_LinewatchSource(
literal: null == literal ? _self.literal : literal // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Linewatch {

 bool get free; LinewatchSource get source; String get url;
/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinewatchCopyWith<Linewatch> get copyWith => _$LinewatchCopyWithImpl<Linewatch>(this as Linewatch, _$identity);

  /// Serializes this Linewatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Linewatch&&(identical(other.free, free) || other.free == free)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,free,source,url);

@override
String toString() {
  return 'Linewatch(free: $free, source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class $LinewatchCopyWith<$Res>  {
  factory $LinewatchCopyWith(Linewatch value, $Res Function(Linewatch) _then) = _$LinewatchCopyWithImpl;
@useResult
$Res call({
 bool free, LinewatchSource source, String url
});


$LinewatchSourceCopyWith<$Res> get source;

}
/// @nodoc
class _$LinewatchCopyWithImpl<$Res>
    implements $LinewatchCopyWith<$Res> {
  _$LinewatchCopyWithImpl(this._self, this._then);

  final Linewatch _self;
  final $Res Function(Linewatch) _then;

/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? free = null,Object? source = null,Object? url = null,}) {
  return _then(_self.copyWith(
free: null == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LinewatchSource,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinewatchSourceCopyWith<$Res> get source {
  
  return $LinewatchSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// Adds pattern-matching-related methods to [Linewatch].
extension LinewatchPatterns on Linewatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Linewatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Linewatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Linewatch value)  $default,){
final _that = this;
switch (_that) {
case _Linewatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Linewatch value)?  $default,){
final _that = this;
switch (_that) {
case _Linewatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool free,  LinewatchSource source,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Linewatch() when $default != null:
return $default(_that.free,_that.source,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool free,  LinewatchSource source,  String url)  $default,) {final _that = this;
switch (_that) {
case _Linewatch():
return $default(_that.free,_that.source,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool free,  LinewatchSource source,  String url)?  $default,) {final _that = this;
switch (_that) {
case _Linewatch() when $default != null:
return $default(_that.free,_that.source,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Linewatch implements Linewatch {
  const _Linewatch({this.free = false, this.source = const LinewatchSource(), this.url = ''});
  factory _Linewatch.fromJson(Map<String, dynamic> json) => _$LinewatchFromJson(json);

@override@JsonKey() final  bool free;
@override@JsonKey() final  LinewatchSource source;
@override@JsonKey() final  String url;

/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinewatchCopyWith<_Linewatch> get copyWith => __$LinewatchCopyWithImpl<_Linewatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinewatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Linewatch&&(identical(other.free, free) || other.free == free)&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,free,source,url);

@override
String toString() {
  return 'Linewatch(free: $free, source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class _$LinewatchCopyWith<$Res> implements $LinewatchCopyWith<$Res> {
  factory _$LinewatchCopyWith(_Linewatch value, $Res Function(_Linewatch) _then) = __$LinewatchCopyWithImpl;
@override @useResult
$Res call({
 bool free, LinewatchSource source, String url
});


@override $LinewatchSourceCopyWith<$Res> get source;

}
/// @nodoc
class __$LinewatchCopyWithImpl<$Res>
    implements _$LinewatchCopyWith<$Res> {
  __$LinewatchCopyWithImpl(this._self, this._then);

  final _Linewatch _self;
  final $Res Function(_Linewatch) _then;

/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? free = null,Object? source = null,Object? url = null,}) {
  return _then(_Linewatch(
free: null == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as LinewatchSource,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of Linewatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinewatchSourceCopyWith<$Res> get source {
  
  return $LinewatchSourceCopyWith<$Res>(_self.source, (value) {
    return _then(_self.copyWith(source: value));
  });
}
}


/// @nodoc
mixin _$RealtimeHonor {

 String get kind; int get rank; int get score; String get title; String get uri;
/// Create a copy of RealtimeHonor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RealtimeHonorCopyWith<RealtimeHonor> get copyWith => _$RealtimeHonorCopyWithImpl<RealtimeHonor>(this as RealtimeHonor, _$identity);

  /// Serializes this RealtimeHonor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RealtimeHonor&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.score, score) || other.score == score)&&(identical(other.title, title) || other.title == title)&&(identical(other.uri, uri) || other.uri == uri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,rank,score,title,uri);

@override
String toString() {
  return 'RealtimeHonor(kind: $kind, rank: $rank, score: $score, title: $title, uri: $uri)';
}


}

/// @nodoc
abstract mixin class $RealtimeHonorCopyWith<$Res>  {
  factory $RealtimeHonorCopyWith(RealtimeHonor value, $Res Function(RealtimeHonor) _then) = _$RealtimeHonorCopyWithImpl;
@useResult
$Res call({
 String kind, int rank, int score, String title, String uri
});




}
/// @nodoc
class _$RealtimeHonorCopyWithImpl<$Res>
    implements $RealtimeHonorCopyWith<$Res> {
  _$RealtimeHonorCopyWithImpl(this._self, this._then);

  final RealtimeHonor _self;
  final $Res Function(RealtimeHonor) _then;

/// Create a copy of RealtimeHonor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? rank = null,Object? score = null,Object? title = null,Object? uri = null,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RealtimeHonor].
extension RealtimeHonorPatterns on RealtimeHonor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RealtimeHonor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RealtimeHonor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RealtimeHonor value)  $default,){
final _that = this;
switch (_that) {
case _RealtimeHonor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RealtimeHonor value)?  $default,){
final _that = this;
switch (_that) {
case _RealtimeHonor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  int rank,  int score,  String title,  String uri)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RealtimeHonor() when $default != null:
return $default(_that.kind,_that.rank,_that.score,_that.title,_that.uri);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  int rank,  int score,  String title,  String uri)  $default,) {final _that = this;
switch (_that) {
case _RealtimeHonor():
return $default(_that.kind,_that.rank,_that.score,_that.title,_that.uri);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  int rank,  int score,  String title,  String uri)?  $default,) {final _that = this;
switch (_that) {
case _RealtimeHonor() when $default != null:
return $default(_that.kind,_that.rank,_that.score,_that.title,_that.uri);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RealtimeHonor implements RealtimeHonor {
  const _RealtimeHonor({this.kind = '', this.rank = 0, this.score = 0, this.title = '', this.uri = ''});
  factory _RealtimeHonor.fromJson(Map<String, dynamic> json) => _$RealtimeHonorFromJson(json);

@override@JsonKey() final  String kind;
@override@JsonKey() final  int rank;
@override@JsonKey() final  int score;
@override@JsonKey() final  String title;
@override@JsonKey() final  String uri;

/// Create a copy of RealtimeHonor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RealtimeHonorCopyWith<_RealtimeHonor> get copyWith => __$RealtimeHonorCopyWithImpl<_RealtimeHonor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RealtimeHonorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RealtimeHonor&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.score, score) || other.score == score)&&(identical(other.title, title) || other.title == title)&&(identical(other.uri, uri) || other.uri == uri));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,rank,score,title,uri);

@override
String toString() {
  return 'RealtimeHonor(kind: $kind, rank: $rank, score: $score, title: $title, uri: $uri)';
}


}

/// @nodoc
abstract mixin class _$RealtimeHonorCopyWith<$Res> implements $RealtimeHonorCopyWith<$Res> {
  factory _$RealtimeHonorCopyWith(_RealtimeHonor value, $Res Function(_RealtimeHonor) _then) = __$RealtimeHonorCopyWithImpl;
@override @useResult
$Res call({
 String kind, int rank, int score, String title, String uri
});




}
/// @nodoc
class __$RealtimeHonorCopyWithImpl<$Res>
    implements _$RealtimeHonorCopyWith<$Res> {
  __$RealtimeHonorCopyWithImpl(this._self, this._then);

  final _RealtimeHonor _self;
  final $Res Function(_RealtimeHonor) _then;

/// Create a copy of RealtimeHonor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? rank = null,Object? score = null,Object? title = null,Object? uri = null,}) {
  return _then(_RealtimeHonor(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$VideoDetail {

 String get id; String get title;@JsonKey(name: 'original_title') String get originalTitle; String get year;@JsonKey(name: 'cover_url') String get coverUrl; Pic get pic; DetailRating get rating;@JsonKey(name: 'null_rating_reason') String get nullRatingReason; List<Person> get actors; List<Person> get directors; List<String> get aka; List<String> get countries; List<String> get languages; List<String> get genres; List<String> get durations; List<String> get pubdate; String get intro;@JsonKey(name: 'card_subtitle') String get cardSubtitle;@JsonKey(name: 'is_tv') bool get isTv;@JsonKey(name: 'is_released') bool get isReleased;@JsonKey(name: 'has_linewatch') bool get hasLinewatch;@JsonKey(name: 'episodes_count') int get episodesCount;@JsonKey(name: 'episodes_info') String get episodesInfo; List<Trailer> get trailers; List<Vendor> get vendors; List<Linewatch> get linewatches;@JsonKey(name: 'realtime_hot_honor_infos') List<RealtimeHonor> get realtimeHonorInfos;@JsonKey(name: 'comment_count') int get commentCount;@JsonKey(name: 'review_count') int get reviewCount;@JsonKey(name: 'forum_topic_count') int get forumTopicCount; String get url;@JsonKey(name: 'sharing_url') String get sharingUrl; String get type; String get subtype;
/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoDetailCopyWith<VideoDetail> get copyWith => _$VideoDetailCopyWithImpl<VideoDetail>(this as VideoDetail, _$identity);

  /// Serializes this VideoDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.year, year) || other.year == year)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.pic, pic) || other.pic == pic)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.nullRatingReason, nullRatingReason) || other.nullRatingReason == nullRatingReason)&&const DeepCollectionEquality().equals(other.actors, actors)&&const DeepCollectionEquality().equals(other.directors, directors)&&const DeepCollectionEquality().equals(other.aka, aka)&&const DeepCollectionEquality().equals(other.countries, countries)&&const DeepCollectionEquality().equals(other.languages, languages)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.durations, durations)&&const DeepCollectionEquality().equals(other.pubdate, pubdate)&&(identical(other.intro, intro) || other.intro == intro)&&(identical(other.cardSubtitle, cardSubtitle) || other.cardSubtitle == cardSubtitle)&&(identical(other.isTv, isTv) || other.isTv == isTv)&&(identical(other.isReleased, isReleased) || other.isReleased == isReleased)&&(identical(other.hasLinewatch, hasLinewatch) || other.hasLinewatch == hasLinewatch)&&(identical(other.episodesCount, episodesCount) || other.episodesCount == episodesCount)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&const DeepCollectionEquality().equals(other.trailers, trailers)&&const DeepCollectionEquality().equals(other.vendors, vendors)&&const DeepCollectionEquality().equals(other.linewatches, linewatches)&&const DeepCollectionEquality().equals(other.realtimeHonorInfos, realtimeHonorInfos)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.forumTopicCount, forumTopicCount) || other.forumTopicCount == forumTopicCount)&&(identical(other.url, url) || other.url == url)&&(identical(other.sharingUrl, sharingUrl) || other.sharingUrl == sharingUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.subtype, subtype) || other.subtype == subtype));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,originalTitle,year,coverUrl,pic,rating,nullRatingReason,const DeepCollectionEquality().hash(actors),const DeepCollectionEquality().hash(directors),const DeepCollectionEquality().hash(aka),const DeepCollectionEquality().hash(countries),const DeepCollectionEquality().hash(languages),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(durations),const DeepCollectionEquality().hash(pubdate),intro,cardSubtitle,isTv,isReleased,hasLinewatch,episodesCount,episodesInfo,const DeepCollectionEquality().hash(trailers),const DeepCollectionEquality().hash(vendors),const DeepCollectionEquality().hash(linewatches),const DeepCollectionEquality().hash(realtimeHonorInfos),commentCount,reviewCount,forumTopicCount,url,sharingUrl,type,subtype]);

@override
String toString() {
  return 'VideoDetail(id: $id, title: $title, originalTitle: $originalTitle, year: $year, coverUrl: $coverUrl, pic: $pic, rating: $rating, nullRatingReason: $nullRatingReason, actors: $actors, directors: $directors, aka: $aka, countries: $countries, languages: $languages, genres: $genres, durations: $durations, pubdate: $pubdate, intro: $intro, cardSubtitle: $cardSubtitle, isTv: $isTv, isReleased: $isReleased, hasLinewatch: $hasLinewatch, episodesCount: $episodesCount, episodesInfo: $episodesInfo, trailers: $trailers, vendors: $vendors, linewatches: $linewatches, realtimeHonorInfos: $realtimeHonorInfos, commentCount: $commentCount, reviewCount: $reviewCount, forumTopicCount: $forumTopicCount, url: $url, sharingUrl: $sharingUrl, type: $type, subtype: $subtype)';
}


}

/// @nodoc
abstract mixin class $VideoDetailCopyWith<$Res>  {
  factory $VideoDetailCopyWith(VideoDetail value, $Res Function(VideoDetail) _then) = _$VideoDetailCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'original_title') String originalTitle, String year,@JsonKey(name: 'cover_url') String coverUrl, Pic pic, DetailRating rating,@JsonKey(name: 'null_rating_reason') String nullRatingReason, List<Person> actors, List<Person> directors, List<String> aka, List<String> countries, List<String> languages, List<String> genres, List<String> durations, List<String> pubdate, String intro,@JsonKey(name: 'card_subtitle') String cardSubtitle,@JsonKey(name: 'is_tv') bool isTv,@JsonKey(name: 'is_released') bool isReleased,@JsonKey(name: 'has_linewatch') bool hasLinewatch,@JsonKey(name: 'episodes_count') int episodesCount,@JsonKey(name: 'episodes_info') String episodesInfo, List<Trailer> trailers, List<Vendor> vendors, List<Linewatch> linewatches,@JsonKey(name: 'realtime_hot_honor_infos') List<RealtimeHonor> realtimeHonorInfos,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'forum_topic_count') int forumTopicCount, String url,@JsonKey(name: 'sharing_url') String sharingUrl, String type, String subtype
});


$PicCopyWith<$Res> get pic;$DetailRatingCopyWith<$Res> get rating;

}
/// @nodoc
class _$VideoDetailCopyWithImpl<$Res>
    implements $VideoDetailCopyWith<$Res> {
  _$VideoDetailCopyWithImpl(this._self, this._then);

  final VideoDetail _self;
  final $Res Function(VideoDetail) _then;

/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? year = null,Object? coverUrl = null,Object? pic = null,Object? rating = null,Object? nullRatingReason = null,Object? actors = null,Object? directors = null,Object? aka = null,Object? countries = null,Object? languages = null,Object? genres = null,Object? durations = null,Object? pubdate = null,Object? intro = null,Object? cardSubtitle = null,Object? isTv = null,Object? isReleased = null,Object? hasLinewatch = null,Object? episodesCount = null,Object? episodesInfo = null,Object? trailers = null,Object? vendors = null,Object? linewatches = null,Object? realtimeHonorInfos = null,Object? commentCount = null,Object? reviewCount = null,Object? forumTopicCount = null,Object? url = null,Object? sharingUrl = null,Object? type = null,Object? subtype = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as Pic,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DetailRating,nullRatingReason: null == nullRatingReason ? _self.nullRatingReason : nullRatingReason // ignore: cast_nullable_to_non_nullable
as String,actors: null == actors ? _self.actors : actors // ignore: cast_nullable_to_non_nullable
as List<Person>,directors: null == directors ? _self.directors : directors // ignore: cast_nullable_to_non_nullable
as List<Person>,aka: null == aka ? _self.aka : aka // ignore: cast_nullable_to_non_nullable
as List<String>,countries: null == countries ? _self.countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,durations: null == durations ? _self.durations : durations // ignore: cast_nullable_to_non_nullable
as List<String>,pubdate: null == pubdate ? _self.pubdate : pubdate // ignore: cast_nullable_to_non_nullable
as List<String>,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,isTv: null == isTv ? _self.isTv : isTv // ignore: cast_nullable_to_non_nullable
as bool,isReleased: null == isReleased ? _self.isReleased : isReleased // ignore: cast_nullable_to_non_nullable
as bool,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,episodesCount: null == episodesCount ? _self.episodesCount : episodesCount // ignore: cast_nullable_to_non_nullable
as int,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,trailers: null == trailers ? _self.trailers : trailers // ignore: cast_nullable_to_non_nullable
as List<Trailer>,vendors: null == vendors ? _self.vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<Vendor>,linewatches: null == linewatches ? _self.linewatches : linewatches // ignore: cast_nullable_to_non_nullable
as List<Linewatch>,realtimeHonorInfos: null == realtimeHonorInfos ? _self.realtimeHonorInfos : realtimeHonorInfos // ignore: cast_nullable_to_non_nullable
as List<RealtimeHonor>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,forumTopicCount: null == forumTopicCount ? _self.forumTopicCount : forumTopicCount // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sharingUrl: null == sharingUrl ? _self.sharingUrl : sharingUrl // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PicCopyWith<$Res> get pic {
  
  return $PicCopyWith<$Res>(_self.pic, (value) {
    return _then(_self.copyWith(pic: value));
  });
}/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DetailRatingCopyWith<$Res> get rating {
  
  return $DetailRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [VideoDetail].
extension VideoDetailPatterns on VideoDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoDetail value)  $default,){
final _that = this;
switch (_that) {
case _VideoDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoDetail value)?  $default,){
final _that = this;
switch (_that) {
case _VideoDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year, @JsonKey(name: 'cover_url')  String coverUrl,  Pic pic,  DetailRating rating, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  List<Person> actors,  List<Person> directors,  List<String> aka,  List<String> countries,  List<String> languages,  List<String> genres,  List<String> durations,  List<String> pubdate,  String intro, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'is_tv')  bool isTv, @JsonKey(name: 'is_released')  bool isReleased, @JsonKey(name: 'has_linewatch')  bool hasLinewatch, @JsonKey(name: 'episodes_count')  int episodesCount, @JsonKey(name: 'episodes_info')  String episodesInfo,  List<Trailer> trailers,  List<Vendor> vendors,  List<Linewatch> linewatches, @JsonKey(name: 'realtime_hot_honor_infos')  List<RealtimeHonor> realtimeHonorInfos, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'forum_topic_count')  int forumTopicCount,  String url, @JsonKey(name: 'sharing_url')  String sharingUrl,  String type,  String subtype)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoDetail() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.coverUrl,_that.pic,_that.rating,_that.nullRatingReason,_that.actors,_that.directors,_that.aka,_that.countries,_that.languages,_that.genres,_that.durations,_that.pubdate,_that.intro,_that.cardSubtitle,_that.isTv,_that.isReleased,_that.hasLinewatch,_that.episodesCount,_that.episodesInfo,_that.trailers,_that.vendors,_that.linewatches,_that.realtimeHonorInfos,_that.commentCount,_that.reviewCount,_that.forumTopicCount,_that.url,_that.sharingUrl,_that.type,_that.subtype);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year, @JsonKey(name: 'cover_url')  String coverUrl,  Pic pic,  DetailRating rating, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  List<Person> actors,  List<Person> directors,  List<String> aka,  List<String> countries,  List<String> languages,  List<String> genres,  List<String> durations,  List<String> pubdate,  String intro, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'is_tv')  bool isTv, @JsonKey(name: 'is_released')  bool isReleased, @JsonKey(name: 'has_linewatch')  bool hasLinewatch, @JsonKey(name: 'episodes_count')  int episodesCount, @JsonKey(name: 'episodes_info')  String episodesInfo,  List<Trailer> trailers,  List<Vendor> vendors,  List<Linewatch> linewatches, @JsonKey(name: 'realtime_hot_honor_infos')  List<RealtimeHonor> realtimeHonorInfos, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'forum_topic_count')  int forumTopicCount,  String url, @JsonKey(name: 'sharing_url')  String sharingUrl,  String type,  String subtype)  $default,) {final _that = this;
switch (_that) {
case _VideoDetail():
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.coverUrl,_that.pic,_that.rating,_that.nullRatingReason,_that.actors,_that.directors,_that.aka,_that.countries,_that.languages,_that.genres,_that.durations,_that.pubdate,_that.intro,_that.cardSubtitle,_that.isTv,_that.isReleased,_that.hasLinewatch,_that.episodesCount,_that.episodesInfo,_that.trailers,_that.vendors,_that.linewatches,_that.realtimeHonorInfos,_that.commentCount,_that.reviewCount,_that.forumTopicCount,_that.url,_that.sharingUrl,_that.type,_that.subtype);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year, @JsonKey(name: 'cover_url')  String coverUrl,  Pic pic,  DetailRating rating, @JsonKey(name: 'null_rating_reason')  String nullRatingReason,  List<Person> actors,  List<Person> directors,  List<String> aka,  List<String> countries,  List<String> languages,  List<String> genres,  List<String> durations,  List<String> pubdate,  String intro, @JsonKey(name: 'card_subtitle')  String cardSubtitle, @JsonKey(name: 'is_tv')  bool isTv, @JsonKey(name: 'is_released')  bool isReleased, @JsonKey(name: 'has_linewatch')  bool hasLinewatch, @JsonKey(name: 'episodes_count')  int episodesCount, @JsonKey(name: 'episodes_info')  String episodesInfo,  List<Trailer> trailers,  List<Vendor> vendors,  List<Linewatch> linewatches, @JsonKey(name: 'realtime_hot_honor_infos')  List<RealtimeHonor> realtimeHonorInfos, @JsonKey(name: 'comment_count')  int commentCount, @JsonKey(name: 'review_count')  int reviewCount, @JsonKey(name: 'forum_topic_count')  int forumTopicCount,  String url, @JsonKey(name: 'sharing_url')  String sharingUrl,  String type,  String subtype)?  $default,) {final _that = this;
switch (_that) {
case _VideoDetail() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.coverUrl,_that.pic,_that.rating,_that.nullRatingReason,_that.actors,_that.directors,_that.aka,_that.countries,_that.languages,_that.genres,_that.durations,_that.pubdate,_that.intro,_that.cardSubtitle,_that.isTv,_that.isReleased,_that.hasLinewatch,_that.episodesCount,_that.episodesInfo,_that.trailers,_that.vendors,_that.linewatches,_that.realtimeHonorInfos,_that.commentCount,_that.reviewCount,_that.forumTopicCount,_that.url,_that.sharingUrl,_that.type,_that.subtype);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoDetail implements VideoDetail {
  const _VideoDetail({this.id = '', this.title = '', @JsonKey(name: 'original_title') this.originalTitle = '', this.year = '', @JsonKey(name: 'cover_url') this.coverUrl = '', this.pic = const Pic(), this.rating = const DetailRating(), @JsonKey(name: 'null_rating_reason') this.nullRatingReason = '', final  List<Person> actors = const <Person>[], final  List<Person> directors = const <Person>[], final  List<String> aka = const <String>[], final  List<String> countries = const <String>[], final  List<String> languages = const <String>[], final  List<String> genres = const <String>[], final  List<String> durations = const <String>[], final  List<String> pubdate = const <String>[], this.intro = '', @JsonKey(name: 'card_subtitle') this.cardSubtitle = '', @JsonKey(name: 'is_tv') this.isTv = false, @JsonKey(name: 'is_released') this.isReleased = false, @JsonKey(name: 'has_linewatch') this.hasLinewatch = false, @JsonKey(name: 'episodes_count') this.episodesCount = 0, @JsonKey(name: 'episodes_info') this.episodesInfo = '', final  List<Trailer> trailers = const <Trailer>[], final  List<Vendor> vendors = const <Vendor>[], final  List<Linewatch> linewatches = const <Linewatch>[], @JsonKey(name: 'realtime_hot_honor_infos') final  List<RealtimeHonor> realtimeHonorInfos = const <RealtimeHonor>[], @JsonKey(name: 'comment_count') this.commentCount = 0, @JsonKey(name: 'review_count') this.reviewCount = 0, @JsonKey(name: 'forum_topic_count') this.forumTopicCount = 0, this.url = '', @JsonKey(name: 'sharing_url') this.sharingUrl = '', this.type = '', this.subtype = ''}): _actors = actors,_directors = directors,_aka = aka,_countries = countries,_languages = languages,_genres = genres,_durations = durations,_pubdate = pubdate,_trailers = trailers,_vendors = vendors,_linewatches = linewatches,_realtimeHonorInfos = realtimeHonorInfos;
  factory _VideoDetail.fromJson(Map<String, dynamic> json) => _$VideoDetailFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'original_title') final  String originalTitle;
@override@JsonKey() final  String year;
@override@JsonKey(name: 'cover_url') final  String coverUrl;
@override@JsonKey() final  Pic pic;
@override@JsonKey() final  DetailRating rating;
@override@JsonKey(name: 'null_rating_reason') final  String nullRatingReason;
 final  List<Person> _actors;
@override@JsonKey() List<Person> get actors {
  if (_actors is EqualUnmodifiableListView) return _actors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actors);
}

 final  List<Person> _directors;
@override@JsonKey() List<Person> get directors {
  if (_directors is EqualUnmodifiableListView) return _directors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directors);
}

 final  List<String> _aka;
@override@JsonKey() List<String> get aka {
  if (_aka is EqualUnmodifiableListView) return _aka;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aka);
}

 final  List<String> _countries;
@override@JsonKey() List<String> get countries {
  if (_countries is EqualUnmodifiableListView) return _countries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_countries);
}

 final  List<String> _languages;
@override@JsonKey() List<String> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<String> _durations;
@override@JsonKey() List<String> get durations {
  if (_durations is EqualUnmodifiableListView) return _durations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_durations);
}

 final  List<String> _pubdate;
@override@JsonKey() List<String> get pubdate {
  if (_pubdate is EqualUnmodifiableListView) return _pubdate;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pubdate);
}

@override@JsonKey() final  String intro;
@override@JsonKey(name: 'card_subtitle') final  String cardSubtitle;
@override@JsonKey(name: 'is_tv') final  bool isTv;
@override@JsonKey(name: 'is_released') final  bool isReleased;
@override@JsonKey(name: 'has_linewatch') final  bool hasLinewatch;
@override@JsonKey(name: 'episodes_count') final  int episodesCount;
@override@JsonKey(name: 'episodes_info') final  String episodesInfo;
 final  List<Trailer> _trailers;
@override@JsonKey() List<Trailer> get trailers {
  if (_trailers is EqualUnmodifiableListView) return _trailers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trailers);
}

 final  List<Vendor> _vendors;
@override@JsonKey() List<Vendor> get vendors {
  if (_vendors is EqualUnmodifiableListView) return _vendors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_vendors);
}

 final  List<Linewatch> _linewatches;
@override@JsonKey() List<Linewatch> get linewatches {
  if (_linewatches is EqualUnmodifiableListView) return _linewatches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_linewatches);
}

 final  List<RealtimeHonor> _realtimeHonorInfos;
@override@JsonKey(name: 'realtime_hot_honor_infos') List<RealtimeHonor> get realtimeHonorInfos {
  if (_realtimeHonorInfos is EqualUnmodifiableListView) return _realtimeHonorInfos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_realtimeHonorInfos);
}

@override@JsonKey(name: 'comment_count') final  int commentCount;
@override@JsonKey(name: 'review_count') final  int reviewCount;
@override@JsonKey(name: 'forum_topic_count') final  int forumTopicCount;
@override@JsonKey() final  String url;
@override@JsonKey(name: 'sharing_url') final  String sharingUrl;
@override@JsonKey() final  String type;
@override@JsonKey() final  String subtype;

/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoDetailCopyWith<_VideoDetail> get copyWith => __$VideoDetailCopyWithImpl<_VideoDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.year, year) || other.year == year)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.pic, pic) || other.pic == pic)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.nullRatingReason, nullRatingReason) || other.nullRatingReason == nullRatingReason)&&const DeepCollectionEquality().equals(other._actors, _actors)&&const DeepCollectionEquality().equals(other._directors, _directors)&&const DeepCollectionEquality().equals(other._aka, _aka)&&const DeepCollectionEquality().equals(other._countries, _countries)&&const DeepCollectionEquality().equals(other._languages, _languages)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._durations, _durations)&&const DeepCollectionEquality().equals(other._pubdate, _pubdate)&&(identical(other.intro, intro) || other.intro == intro)&&(identical(other.cardSubtitle, cardSubtitle) || other.cardSubtitle == cardSubtitle)&&(identical(other.isTv, isTv) || other.isTv == isTv)&&(identical(other.isReleased, isReleased) || other.isReleased == isReleased)&&(identical(other.hasLinewatch, hasLinewatch) || other.hasLinewatch == hasLinewatch)&&(identical(other.episodesCount, episodesCount) || other.episodesCount == episodesCount)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&const DeepCollectionEquality().equals(other._trailers, _trailers)&&const DeepCollectionEquality().equals(other._vendors, _vendors)&&const DeepCollectionEquality().equals(other._linewatches, _linewatches)&&const DeepCollectionEquality().equals(other._realtimeHonorInfos, _realtimeHonorInfos)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.forumTopicCount, forumTopicCount) || other.forumTopicCount == forumTopicCount)&&(identical(other.url, url) || other.url == url)&&(identical(other.sharingUrl, sharingUrl) || other.sharingUrl == sharingUrl)&&(identical(other.type, type) || other.type == type)&&(identical(other.subtype, subtype) || other.subtype == subtype));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,originalTitle,year,coverUrl,pic,rating,nullRatingReason,const DeepCollectionEquality().hash(_actors),const DeepCollectionEquality().hash(_directors),const DeepCollectionEquality().hash(_aka),const DeepCollectionEquality().hash(_countries),const DeepCollectionEquality().hash(_languages),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_durations),const DeepCollectionEquality().hash(_pubdate),intro,cardSubtitle,isTv,isReleased,hasLinewatch,episodesCount,episodesInfo,const DeepCollectionEquality().hash(_trailers),const DeepCollectionEquality().hash(_vendors),const DeepCollectionEquality().hash(_linewatches),const DeepCollectionEquality().hash(_realtimeHonorInfos),commentCount,reviewCount,forumTopicCount,url,sharingUrl,type,subtype]);

@override
String toString() {
  return 'VideoDetail(id: $id, title: $title, originalTitle: $originalTitle, year: $year, coverUrl: $coverUrl, pic: $pic, rating: $rating, nullRatingReason: $nullRatingReason, actors: $actors, directors: $directors, aka: $aka, countries: $countries, languages: $languages, genres: $genres, durations: $durations, pubdate: $pubdate, intro: $intro, cardSubtitle: $cardSubtitle, isTv: $isTv, isReleased: $isReleased, hasLinewatch: $hasLinewatch, episodesCount: $episodesCount, episodesInfo: $episodesInfo, trailers: $trailers, vendors: $vendors, linewatches: $linewatches, realtimeHonorInfos: $realtimeHonorInfos, commentCount: $commentCount, reviewCount: $reviewCount, forumTopicCount: $forumTopicCount, url: $url, sharingUrl: $sharingUrl, type: $type, subtype: $subtype)';
}


}

/// @nodoc
abstract mixin class _$VideoDetailCopyWith<$Res> implements $VideoDetailCopyWith<$Res> {
  factory _$VideoDetailCopyWith(_VideoDetail value, $Res Function(_VideoDetail) _then) = __$VideoDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'original_title') String originalTitle, String year,@JsonKey(name: 'cover_url') String coverUrl, Pic pic, DetailRating rating,@JsonKey(name: 'null_rating_reason') String nullRatingReason, List<Person> actors, List<Person> directors, List<String> aka, List<String> countries, List<String> languages, List<String> genres, List<String> durations, List<String> pubdate, String intro,@JsonKey(name: 'card_subtitle') String cardSubtitle,@JsonKey(name: 'is_tv') bool isTv,@JsonKey(name: 'is_released') bool isReleased,@JsonKey(name: 'has_linewatch') bool hasLinewatch,@JsonKey(name: 'episodes_count') int episodesCount,@JsonKey(name: 'episodes_info') String episodesInfo, List<Trailer> trailers, List<Vendor> vendors, List<Linewatch> linewatches,@JsonKey(name: 'realtime_hot_honor_infos') List<RealtimeHonor> realtimeHonorInfos,@JsonKey(name: 'comment_count') int commentCount,@JsonKey(name: 'review_count') int reviewCount,@JsonKey(name: 'forum_topic_count') int forumTopicCount, String url,@JsonKey(name: 'sharing_url') String sharingUrl, String type, String subtype
});


@override $PicCopyWith<$Res> get pic;@override $DetailRatingCopyWith<$Res> get rating;

}
/// @nodoc
class __$VideoDetailCopyWithImpl<$Res>
    implements _$VideoDetailCopyWith<$Res> {
  __$VideoDetailCopyWithImpl(this._self, this._then);

  final _VideoDetail _self;
  final $Res Function(_VideoDetail) _then;

/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? year = null,Object? coverUrl = null,Object? pic = null,Object? rating = null,Object? nullRatingReason = null,Object? actors = null,Object? directors = null,Object? aka = null,Object? countries = null,Object? languages = null,Object? genres = null,Object? durations = null,Object? pubdate = null,Object? intro = null,Object? cardSubtitle = null,Object? isTv = null,Object? isReleased = null,Object? hasLinewatch = null,Object? episodesCount = null,Object? episodesInfo = null,Object? trailers = null,Object? vendors = null,Object? linewatches = null,Object? realtimeHonorInfos = null,Object? commentCount = null,Object? reviewCount = null,Object? forumTopicCount = null,Object? url = null,Object? sharingUrl = null,Object? type = null,Object? subtype = null,}) {
  return _then(_VideoDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,pic: null == pic ? _self.pic : pic // ignore: cast_nullable_to_non_nullable
as Pic,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DetailRating,nullRatingReason: null == nullRatingReason ? _self.nullRatingReason : nullRatingReason // ignore: cast_nullable_to_non_nullable
as String,actors: null == actors ? _self._actors : actors // ignore: cast_nullable_to_non_nullable
as List<Person>,directors: null == directors ? _self._directors : directors // ignore: cast_nullable_to_non_nullable
as List<Person>,aka: null == aka ? _self._aka : aka // ignore: cast_nullable_to_non_nullable
as List<String>,countries: null == countries ? _self._countries : countries // ignore: cast_nullable_to_non_nullable
as List<String>,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<String>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,durations: null == durations ? _self._durations : durations // ignore: cast_nullable_to_non_nullable
as List<String>,pubdate: null == pubdate ? _self._pubdate : pubdate // ignore: cast_nullable_to_non_nullable
as List<String>,intro: null == intro ? _self.intro : intro // ignore: cast_nullable_to_non_nullable
as String,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,isTv: null == isTv ? _self.isTv : isTv // ignore: cast_nullable_to_non_nullable
as bool,isReleased: null == isReleased ? _self.isReleased : isReleased // ignore: cast_nullable_to_non_nullable
as bool,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,episodesCount: null == episodesCount ? _self.episodesCount : episodesCount // ignore: cast_nullable_to_non_nullable
as int,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,trailers: null == trailers ? _self._trailers : trailers // ignore: cast_nullable_to_non_nullable
as List<Trailer>,vendors: null == vendors ? _self._vendors : vendors // ignore: cast_nullable_to_non_nullable
as List<Vendor>,linewatches: null == linewatches ? _self._linewatches : linewatches // ignore: cast_nullable_to_non_nullable
as List<Linewatch>,realtimeHonorInfos: null == realtimeHonorInfos ? _self._realtimeHonorInfos : realtimeHonorInfos // ignore: cast_nullable_to_non_nullable
as List<RealtimeHonor>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,forumTopicCount: null == forumTopicCount ? _self.forumTopicCount : forumTopicCount // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sharingUrl: null == sharingUrl ? _self.sharingUrl : sharingUrl // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,subtype: null == subtype ? _self.subtype : subtype // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PicCopyWith<$Res> get pic {
  
  return $PicCopyWith<$Res>(_self.pic, (value) {
    return _then(_self.copyWith(pic: value));
  });
}/// Create a copy of VideoDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DetailRatingCopyWith<$Res> get rating {
  
  return $DetailRatingCopyWith<$Res>(_self.rating, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

// dart format on
