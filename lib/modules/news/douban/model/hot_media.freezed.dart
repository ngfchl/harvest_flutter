// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hot_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HotMedia {

 String get title;@JsonKey(name: 'url') String get doubanUrl;@JsonKey(name: 'cover') String get poster; bool get playable; String get id; String get rate;@JsonKey(name: 'cover_x') int get coverX;@JsonKey(name: 'cover_y') int get coverY;@JsonKey(name: 'is_new') bool get isNew;@JsonKey(name: 'episodes_info') String get episodesInfo; String get cookie;
/// Create a copy of HotMedia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HotMediaCopyWith<HotMedia> get copyWith => _$HotMediaCopyWithImpl<HotMedia>(this as HotMedia, _$identity);

  /// Serializes this HotMedia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HotMedia&&(identical(other.title, title) || other.title == title)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.playable, playable) || other.playable == playable)&&(identical(other.id, id) || other.id == id)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.coverX, coverX) || other.coverX == coverX)&&(identical(other.coverY, coverY) || other.coverY == coverY)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&(identical(other.cookie, cookie) || other.cookie == cookie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,doubanUrl,poster,playable,id,rate,coverX,coverY,isNew,episodesInfo,cookie);

@override
String toString() {
  return 'HotMedia(title: $title, doubanUrl: $doubanUrl, poster: $poster, playable: $playable, id: $id, rate: $rate, coverX: $coverX, coverY: $coverY, isNew: $isNew, episodesInfo: $episodesInfo, cookie: $cookie)';
}


}

/// @nodoc
abstract mixin class $HotMediaCopyWith<$Res>  {
  factory $HotMediaCopyWith(HotMedia value, $Res Function(HotMedia) _then) = _$HotMediaCopyWithImpl;
@useResult
$Res call({
 String title,@JsonKey(name: 'url') String doubanUrl,@JsonKey(name: 'cover') String poster, bool playable, String id, String rate,@JsonKey(name: 'cover_x') int coverX,@JsonKey(name: 'cover_y') int coverY,@JsonKey(name: 'is_new') bool isNew,@JsonKey(name: 'episodes_info') String episodesInfo, String cookie
});




}
/// @nodoc
class _$HotMediaCopyWithImpl<$Res>
    implements $HotMediaCopyWith<$Res> {
  _$HotMediaCopyWithImpl(this._self, this._then);

  final HotMedia _self;
  final $Res Function(HotMedia) _then;

/// Create a copy of HotMedia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? doubanUrl = null,Object? poster = null,Object? playable = null,Object? id = null,Object? rate = null,Object? coverX = null,Object? coverY = null,Object? isNew = null,Object? episodesInfo = null,Object? cookie = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,playable: null == playable ? _self.playable : playable // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,coverX: null == coverX ? _self.coverX : coverX // ignore: cast_nullable_to_non_nullable
as int,coverY: null == coverY ? _self.coverY : coverY // ignore: cast_nullable_to_non_nullable
as int,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,cookie: null == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HotMedia].
extension HotMediaPatterns on HotMedia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HotMedia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HotMedia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HotMedia value)  $default,){
final _that = this;
switch (_that) {
case _HotMedia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HotMedia value)?  $default,){
final _that = this;
switch (_that) {
case _HotMedia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'url')  String doubanUrl, @JsonKey(name: 'cover')  String poster,  bool playable,  String id,  String rate, @JsonKey(name: 'cover_x')  int coverX, @JsonKey(name: 'cover_y')  int coverY, @JsonKey(name: 'is_new')  bool isNew, @JsonKey(name: 'episodes_info')  String episodesInfo,  String cookie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HotMedia() when $default != null:
return $default(_that.title,_that.doubanUrl,_that.poster,_that.playable,_that.id,_that.rate,_that.coverX,_that.coverY,_that.isNew,_that.episodesInfo,_that.cookie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title, @JsonKey(name: 'url')  String doubanUrl, @JsonKey(name: 'cover')  String poster,  bool playable,  String id,  String rate, @JsonKey(name: 'cover_x')  int coverX, @JsonKey(name: 'cover_y')  int coverY, @JsonKey(name: 'is_new')  bool isNew, @JsonKey(name: 'episodes_info')  String episodesInfo,  String cookie)  $default,) {final _that = this;
switch (_that) {
case _HotMedia():
return $default(_that.title,_that.doubanUrl,_that.poster,_that.playable,_that.id,_that.rate,_that.coverX,_that.coverY,_that.isNew,_that.episodesInfo,_that.cookie);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title, @JsonKey(name: 'url')  String doubanUrl, @JsonKey(name: 'cover')  String poster,  bool playable,  String id,  String rate, @JsonKey(name: 'cover_x')  int coverX, @JsonKey(name: 'cover_y')  int coverY, @JsonKey(name: 'is_new')  bool isNew, @JsonKey(name: 'episodes_info')  String episodesInfo,  String cookie)?  $default,) {final _that = this;
switch (_that) {
case _HotMedia() when $default != null:
return $default(_that.title,_that.doubanUrl,_that.poster,_that.playable,_that.id,_that.rate,_that.coverX,_that.coverY,_that.isNew,_that.episodesInfo,_that.cookie);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HotMedia implements HotMedia {
  const _HotMedia({this.title = '', @JsonKey(name: 'url') this.doubanUrl = '', @JsonKey(name: 'cover') this.poster = '', this.playable = false, this.id = '', this.rate = '', @JsonKey(name: 'cover_x') this.coverX = 0, @JsonKey(name: 'cover_y') this.coverY = 0, @JsonKey(name: 'is_new') this.isNew = false, @JsonKey(name: 'episodes_info') this.episodesInfo = '', this.cookie = ''});
  factory _HotMedia.fromJson(Map<String, dynamic> json) => _$HotMediaFromJson(json);

@override@JsonKey() final  String title;
@override@JsonKey(name: 'url') final  String doubanUrl;
@override@JsonKey(name: 'cover') final  String poster;
@override@JsonKey() final  bool playable;
@override@JsonKey() final  String id;
@override@JsonKey() final  String rate;
@override@JsonKey(name: 'cover_x') final  int coverX;
@override@JsonKey(name: 'cover_y') final  int coverY;
@override@JsonKey(name: 'is_new') final  bool isNew;
@override@JsonKey(name: 'episodes_info') final  String episodesInfo;
@override@JsonKey() final  String cookie;

/// Create a copy of HotMedia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HotMediaCopyWith<_HotMedia> get copyWith => __$HotMediaCopyWithImpl<_HotMedia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HotMediaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HotMedia&&(identical(other.title, title) || other.title == title)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.playable, playable) || other.playable == playable)&&(identical(other.id, id) || other.id == id)&&(identical(other.rate, rate) || other.rate == rate)&&(identical(other.coverX, coverX) || other.coverX == coverX)&&(identical(other.coverY, coverY) || other.coverY == coverY)&&(identical(other.isNew, isNew) || other.isNew == isNew)&&(identical(other.episodesInfo, episodesInfo) || other.episodesInfo == episodesInfo)&&(identical(other.cookie, cookie) || other.cookie == cookie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,doubanUrl,poster,playable,id,rate,coverX,coverY,isNew,episodesInfo,cookie);

@override
String toString() {
  return 'HotMedia(title: $title, doubanUrl: $doubanUrl, poster: $poster, playable: $playable, id: $id, rate: $rate, coverX: $coverX, coverY: $coverY, isNew: $isNew, episodesInfo: $episodesInfo, cookie: $cookie)';
}


}

/// @nodoc
abstract mixin class _$HotMediaCopyWith<$Res> implements $HotMediaCopyWith<$Res> {
  factory _$HotMediaCopyWith(_HotMedia value, $Res Function(_HotMedia) _then) = __$HotMediaCopyWithImpl;
@override @useResult
$Res call({
 String title,@JsonKey(name: 'url') String doubanUrl,@JsonKey(name: 'cover') String poster, bool playable, String id, String rate,@JsonKey(name: 'cover_x') int coverX,@JsonKey(name: 'cover_y') int coverY,@JsonKey(name: 'is_new') bool isNew,@JsonKey(name: 'episodes_info') String episodesInfo, String cookie
});




}
/// @nodoc
class __$HotMediaCopyWithImpl<$Res>
    implements _$HotMediaCopyWith<$Res> {
  __$HotMediaCopyWithImpl(this._self, this._then);

  final _HotMedia _self;
  final $Res Function(_HotMedia) _then;

/// Create a copy of HotMedia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? doubanUrl = null,Object? poster = null,Object? playable = null,Object? id = null,Object? rate = null,Object? coverX = null,Object? coverY = null,Object? isNew = null,Object? episodesInfo = null,Object? cookie = null,}) {
  return _then(_HotMedia(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,playable: null == playable ? _self.playable : playable // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rate: null == rate ? _self.rate : rate // ignore: cast_nullable_to_non_nullable
as String,coverX: null == coverX ? _self.coverX : coverX // ignore: cast_nullable_to_non_nullable
as int,coverY: null == coverY ? _self.coverY : coverY // ignore: cast_nullable_to_non_nullable
as int,isNew: null == isNew ? _self.isNew : isNew // ignore: cast_nullable_to_non_nullable
as bool,episodesInfo: null == episodesInfo ? _self.episodesInfo : episodesInfo // ignore: cast_nullable_to_non_nullable
as String,cookie: null == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
