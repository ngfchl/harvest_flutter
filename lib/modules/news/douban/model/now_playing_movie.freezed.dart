// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'now_playing_movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoubanCover {

 String get url; int get width; int get height;
/// Create a copy of DoubanCover
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoubanCoverCopyWith<DoubanCover> get copyWith => _$DoubanCoverCopyWithImpl<DoubanCover>(this as DoubanCover, _$identity);

  /// Serializes this DoubanCover to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoubanCover;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoubanCover&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoubanCover;
  return Object.hash(runtimeType,_this.url,_this.width,_this.height);
}

@override
String toString() {
  final _this = this as DoubanCover;
  return 'DoubanCover(url: ${_this.url}, width: ${_this.width}, height: ${_this.height})';
}


}

/// @nodoc
abstract mixin class $DoubanCoverCopyWith<$Res>  {
  factory $DoubanCoverCopyWith(DoubanCover value, $Res Function(DoubanCover) _then) = _$DoubanCoverCopyWithImpl;
@useResult
$Res call({
 String url, int width, int height
});




}
/// @nodoc
class _$DoubanCoverCopyWithImpl<$Res>
    implements $DoubanCoverCopyWith<$Res> {
  _$DoubanCoverCopyWithImpl(this._self, this._then);

  final DoubanCover _self;
  final $Res Function(DoubanCover) _then;

/// Create a copy of DoubanCover
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = null,Object? height = null,}) {
  return _then(DoubanCover(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DoubanCover].
extension DoubanCoverPatterns on DoubanCover {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoubanCover value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoubanCover() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoubanCover value)  $default,){
final _that = this;
switch (_that) {
case _DoubanCover():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoubanCover value)?  $default,){
final _that = this;
switch (_that) {
case _DoubanCover() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int width,  int height)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoubanCover() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int width,  int height)  $default,) {final _that = this;
switch (_that) {
case _DoubanCover():
return $default(_that.url,_that.width,_that.height);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int width,  int height)?  $default,) {final _that = this;
switch (_that) {
case _DoubanCover() when $default != null:
return $default(_that.url,_that.width,_that.height);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoubanCover implements DoubanCover {
  const _DoubanCover({this.url = '', this.width = 0, this.height = 0});
  factory _DoubanCover.fromJson(Map<String, dynamic> json) => _$DoubanCoverFromJson(json);

@override@JsonKey() final  String url;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;

/// Create a copy of DoubanCover
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoubanCoverCopyWith<_DoubanCover> get copyWith => __$DoubanCoverCopyWithImpl<_DoubanCover>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoubanCoverToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoubanCover&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,url,width,height);
}

@override
String toString() {
    return 'DoubanCover(url: $url, width: $width, height: $height)';
}


}

/// @nodoc
abstract mixin class _$DoubanCoverCopyWith<$Res> implements $DoubanCoverCopyWith<$Res> {
  factory _$DoubanCoverCopyWith(_DoubanCover value, $Res Function(_DoubanCover) _then) = __$DoubanCoverCopyWithImpl;
@override @useResult
$Res call({
 String url, int width, int height
});




}
/// @nodoc
class __$DoubanCoverCopyWithImpl<$Res>
    implements _$DoubanCoverCopyWith<$Res> {
  __$DoubanCoverCopyWithImpl(this._self, this._then);

  final _DoubanCover _self;
  final $Res Function(_DoubanCover) _then;

/// Create a copy of DoubanCover
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = null,Object? height = null,}) {
  return _then(_DoubanCover(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$DoubanRating {

 int get count; num get value; num get starCount;
/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<DoubanRating> get copyWith => _$DoubanRatingCopyWithImpl<DoubanRating>(this as DoubanRating, _$identity);

  /// Serializes this DoubanRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DoubanRating;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoubanRating&&(identical(other.count, _this.count) || other.count == _this.count)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.starCount, _this.starCount) || other.starCount == _this.starCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DoubanRating;
  return Object.hash(runtimeType,_this.count,_this.value,_this.starCount);
}

@override
String toString() {
  final _this = this as DoubanRating;
  return 'DoubanRating(count: ${_this.count}, value: ${_this.value}, starCount: ${_this.starCount})';
}


}

/// @nodoc
abstract mixin class $DoubanRatingCopyWith<$Res>  {
  factory $DoubanRatingCopyWith(DoubanRating value, $Res Function(DoubanRating) _then) = _$DoubanRatingCopyWithImpl;
@useResult
$Res call({
 int count, num value, num starCount
});




}
/// @nodoc
class _$DoubanRatingCopyWithImpl<$Res>
    implements $DoubanRatingCopyWith<$Res> {
  _$DoubanRatingCopyWithImpl(this._self, this._then);

  final DoubanRating _self;
  final $Res Function(DoubanRating) _then;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? count = null,Object? value = null,Object? starCount = null,}) {
  return _then(DoubanRating(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [DoubanRating].
extension DoubanRatingPatterns on DoubanRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoubanRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoubanRating value)  $default,){
final _that = this;
switch (_that) {
case _DoubanRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoubanRating value)?  $default,){
final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int count,  num value,  num starCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
return $default(_that.count,_that.value,_that.starCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int count,  num value,  num starCount)  $default,) {final _that = this;
switch (_that) {
case _DoubanRating():
return $default(_that.count,_that.value,_that.starCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int count,  num value,  num starCount)?  $default,) {final _that = this;
switch (_that) {
case _DoubanRating() when $default != null:
return $default(_that.count,_that.value,_that.starCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoubanRating implements DoubanRating {
  const _DoubanRating({this.count = 0, this.value = 0, this.starCount = 0});
  factory _DoubanRating.fromJson(Map<String, dynamic> json) => _$DoubanRatingFromJson(json);

@override@JsonKey() final  int count;
@override@JsonKey() final  num value;
@override@JsonKey() final  num starCount;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoubanRatingCopyWith<_DoubanRating> get copyWith => __$DoubanRatingCopyWithImpl<_DoubanRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoubanRatingToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoubanRating&&(identical(other.count, count) || other.count == count)&&(identical(other.value, value) || other.value == value)&&(identical(other.starCount, starCount) || other.starCount == starCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,count,value,starCount);
}

@override
String toString() {
    return 'DoubanRating(count: $count, value: $value, starCount: $starCount)';
}


}

/// @nodoc
abstract mixin class _$DoubanRatingCopyWith<$Res> implements $DoubanRatingCopyWith<$Res> {
  factory _$DoubanRatingCopyWith(_DoubanRating value, $Res Function(_DoubanRating) _then) = __$DoubanRatingCopyWithImpl;
@override @useResult
$Res call({
 int count, num value, num starCount
});




}
/// @nodoc
class __$DoubanRatingCopyWithImpl<$Res>
    implements _$DoubanRatingCopyWith<$Res> {
  __$DoubanRatingCopyWithImpl(this._self, this._then);

  final _DoubanRating _self;
  final $Res Function(_DoubanRating) _then;

/// Create a copy of DoubanRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? count = null,Object? value = null,Object? starCount = null,}) {
  return _then(_DoubanRating(
count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$NowPlayingMovie {

 String get id; String get title;@JsonKey(name: 'original_title') String get originalTitle; String get year; DoubanCover get cover; DoubanRating? get rating;@JsonKey(name: 'card_subtitle') String get cardSubtitle; List<String> get directors; List<String> get actors;@JsonKey(name: 'release_date') String get releaseDate;@JsonKey(name: 'has_linewatch') bool get hasLinewatch; String get uri; String get url;
/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowPlayingMovieCopyWith<NowPlayingMovie> get copyWith => _$NowPlayingMovieCopyWithImpl<NowPlayingMovie>(this as NowPlayingMovie, _$identity);

  /// Serializes this NowPlayingMovie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as NowPlayingMovie;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingMovie&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.originalTitle, _this.originalTitle) || other.originalTitle == _this.originalTitle)&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.cover, _this.cover) || other.cover == _this.cover)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.cardSubtitle, _this.cardSubtitle) || other.cardSubtitle == _this.cardSubtitle)&&const DeepCollectionEquality().equals(other.directors, _this.directors)&&const DeepCollectionEquality().equals(other.actors, _this.actors)&&(identical(other.releaseDate, _this.releaseDate) || other.releaseDate == _this.releaseDate)&&(identical(other.hasLinewatch, _this.hasLinewatch) || other.hasLinewatch == _this.hasLinewatch)&&(identical(other.uri, _this.uri) || other.uri == _this.uri)&&(identical(other.url, _this.url) || other.url == _this.url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as NowPlayingMovie;
  return Object.hash(runtimeType,_this.id,_this.title,_this.originalTitle,_this.year,_this.cover,_this.rating,_this.cardSubtitle,const DeepCollectionEquality().hash(_this.directors),const DeepCollectionEquality().hash(_this.actors),_this.releaseDate,_this.hasLinewatch,_this.uri,_this.url);
}

@override
String toString() {
  final _this = this as NowPlayingMovie;
  return 'NowPlayingMovie(id: ${_this.id}, title: ${_this.title}, originalTitle: ${_this.originalTitle}, year: ${_this.year}, cover: ${_this.cover}, rating: ${_this.rating}, cardSubtitle: ${_this.cardSubtitle}, directors: ${_this.directors}, actors: ${_this.actors}, releaseDate: ${_this.releaseDate}, hasLinewatch: ${_this.hasLinewatch}, uri: ${_this.uri}, url: ${_this.url})';
}


}

/// @nodoc
abstract mixin class $NowPlayingMovieCopyWith<$Res>  {
  factory $NowPlayingMovieCopyWith(NowPlayingMovie value, $Res Function(NowPlayingMovie) _then) = _$NowPlayingMovieCopyWithImpl;
@useResult
$Res call({
 String id, String title,@JsonKey(name: 'original_title') String originalTitle, String year, DoubanCover cover, DoubanRating? rating,@JsonKey(name: 'card_subtitle') String cardSubtitle, List<String> directors, List<String> actors,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'has_linewatch') bool hasLinewatch, String uri, String url
});


$DoubanCoverCopyWith<$Res> get cover;$DoubanRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$NowPlayingMovieCopyWithImpl<$Res>
    implements $NowPlayingMovieCopyWith<$Res> {
  _$NowPlayingMovieCopyWithImpl(this._self, this._then);

  final NowPlayingMovie _self;
  final $Res Function(NowPlayingMovie) _then;

/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? year = null,Object? cover = null,Object? rating = freezed,Object? cardSubtitle = null,Object? directors = null,Object? actors = null,Object? releaseDate = null,Object? hasLinewatch = null,Object? uri = null,Object? url = null,}) {
  return _then(NowPlayingMovie(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as DoubanCover,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DoubanRating?,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,directors: null == directors ? _self.directors : directors // ignore: cast_nullable_to_non_nullable
as List<String>,actors: null == actors ? _self.actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanCoverCopyWith<$Res> get cover {
  
  return $DoubanCoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $DoubanRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [NowPlayingMovie].
extension NowPlayingMoviePatterns on NowPlayingMovie {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NowPlayingMovie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NowPlayingMovie() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NowPlayingMovie value)  $default,){
final _that = this;
switch (_that) {
case _NowPlayingMovie():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NowPlayingMovie value)?  $default,){
final _that = this;
switch (_that) {
case _NowPlayingMovie() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year,  DoubanCover cover,  DoubanRating? rating, @JsonKey(name: 'card_subtitle')  String cardSubtitle,  List<String> directors,  List<String> actors, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String uri,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NowPlayingMovie() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.cover,_that.rating,_that.cardSubtitle,_that.directors,_that.actors,_that.releaseDate,_that.hasLinewatch,_that.uri,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year,  DoubanCover cover,  DoubanRating? rating, @JsonKey(name: 'card_subtitle')  String cardSubtitle,  List<String> directors,  List<String> actors, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String uri,  String url)  $default,) {final _that = this;
switch (_that) {
case _NowPlayingMovie():
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.cover,_that.rating,_that.cardSubtitle,_that.directors,_that.actors,_that.releaseDate,_that.hasLinewatch,_that.uri,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String year,  DoubanCover cover,  DoubanRating? rating, @JsonKey(name: 'card_subtitle')  String cardSubtitle,  List<String> directors,  List<String> actors, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'has_linewatch')  bool hasLinewatch,  String uri,  String url)?  $default,) {final _that = this;
switch (_that) {
case _NowPlayingMovie() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.year,_that.cover,_that.rating,_that.cardSubtitle,_that.directors,_that.actors,_that.releaseDate,_that.hasLinewatch,_that.uri,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NowPlayingMovie implements NowPlayingMovie {
  const _NowPlayingMovie({this.id = '', this.title = '', @JsonKey(name: 'original_title') this.originalTitle = '', this.year = '', this.cover = const DoubanCover(), this.rating, @JsonKey(name: 'card_subtitle') this.cardSubtitle = '',  List<String> directors = const [],  List<String> actors = const [], @JsonKey(name: 'release_date') this.releaseDate = '', @JsonKey(name: 'has_linewatch') this.hasLinewatch = false, this.uri = '', this.url = ''}): _directors = directors,_actors = actors;
  factory _NowPlayingMovie.fromJson(Map<String, dynamic> json) => _$NowPlayingMovieFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'original_title') final  String originalTitle;
@override@JsonKey() final  String year;
@override@JsonKey() final  DoubanCover cover;
@override final  DoubanRating? rating;
@override@JsonKey(name: 'card_subtitle') final  String cardSubtitle;
 final  List<String> _directors;
@override@JsonKey() List<String> get directors {
  if (_directors is EqualUnmodifiableListView) return _directors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_directors);
}

 final  List<String> _actors;
@override@JsonKey() List<String> get actors {
  if (_actors is EqualUnmodifiableListView) return _actors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actors);
}

@override@JsonKey(name: 'release_date') final  String releaseDate;
@override@JsonKey(name: 'has_linewatch') final  bool hasLinewatch;
@override@JsonKey() final  String uri;
@override@JsonKey() final  String url;

/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NowPlayingMovieCopyWith<_NowPlayingMovie> get copyWith => __$NowPlayingMovieCopyWithImpl<_NowPlayingMovie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NowPlayingMovieToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _NowPlayingMovie&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.year, year) || other.year == year)&&(identical(other.cover, cover) || other.cover == cover)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.cardSubtitle, cardSubtitle) || other.cardSubtitle == cardSubtitle)&&const DeepCollectionEquality().equals(other.directors, _directors)&&const DeepCollectionEquality().equals(other.actors, _actors)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.hasLinewatch, hasLinewatch) || other.hasLinewatch == hasLinewatch)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,originalTitle,year,cover,rating,cardSubtitle,const DeepCollectionEquality().hash(_directors),const DeepCollectionEquality().hash(_actors),releaseDate,hasLinewatch,uri,url);
}

@override
String toString() {
    return 'NowPlayingMovie(id: $id, title: $title, originalTitle: $originalTitle, year: $year, cover: $cover, rating: $rating, cardSubtitle: $cardSubtitle, directors: $directors, actors: $actors, releaseDate: $releaseDate, hasLinewatch: $hasLinewatch, uri: $uri, url: $url)';
}


}

/// @nodoc
abstract mixin class _$NowPlayingMovieCopyWith<$Res> implements $NowPlayingMovieCopyWith<$Res> {
  factory _$NowPlayingMovieCopyWith(_NowPlayingMovie value, $Res Function(_NowPlayingMovie) _then) = __$NowPlayingMovieCopyWithImpl;
@override @useResult
$Res call({
 String id, String title,@JsonKey(name: 'original_title') String originalTitle, String year, DoubanCover cover, DoubanRating? rating,@JsonKey(name: 'card_subtitle') String cardSubtitle, List<String> directors, List<String> actors,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'has_linewatch') bool hasLinewatch, String uri, String url
});


@override $DoubanCoverCopyWith<$Res> get cover;@override $DoubanRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$NowPlayingMovieCopyWithImpl<$Res>
    implements _$NowPlayingMovieCopyWith<$Res> {
  __$NowPlayingMovieCopyWithImpl(this._self, this._then);

  final _NowPlayingMovie _self;
  final $Res Function(_NowPlayingMovie) _then;

/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? year = null,Object? cover = null,Object? rating = freezed,Object? cardSubtitle = null,Object? directors = null,Object? actors = null,Object? releaseDate = null,Object? hasLinewatch = null,Object? uri = null,Object? url = null,}) {
  return _then(_NowPlayingMovie(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String,cover: null == cover ? _self.cover : cover // ignore: cast_nullable_to_non_nullable
as DoubanCover,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as DoubanRating?,cardSubtitle: null == cardSubtitle ? _self.cardSubtitle : cardSubtitle // ignore: cast_nullable_to_non_nullable
as String,directors: null == directors ? _self._directors : directors // ignore: cast_nullable_to_non_nullable
as List<String>,actors: null == actors ? _self._actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,hasLinewatch: null == hasLinewatch ? _self.hasLinewatch : hasLinewatch // ignore: cast_nullable_to_non_nullable
as bool,uri: null == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanCoverCopyWith<$Res> get cover {
  
  return $DoubanCoverCopyWith<$Res>(_self.cover, (value) {
    return _then(_self.copyWith(cover: value));
  });
}/// Create a copy of NowPlayingMovie
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DoubanRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $DoubanRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}

// dart format on
