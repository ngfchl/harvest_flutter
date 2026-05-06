// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'top_movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TopMovie {

 String get rank;@JsonKey(name: 'douban_url') String get doubanUrl; String get poster; String get title; List<String> get subtitle; String get cast; List<String> get desc;@JsonKey(name: 'rating_num') String get ratingNum;@JsonKey(name: 'evaluate_num') String get evaluateNum; String get quote; String get cookie;
/// Create a copy of TopMovie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopMovieCopyWith<TopMovie> get copyWith => _$TopMovieCopyWithImpl<TopMovie>(this as TopMovie, _$identity);

  /// Serializes this TopMovie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopMovie&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.subtitle, subtitle)&&(identical(other.cast, cast) || other.cast == cast)&&const DeepCollectionEquality().equals(other.desc, desc)&&(identical(other.ratingNum, ratingNum) || other.ratingNum == ratingNum)&&(identical(other.evaluateNum, evaluateNum) || other.evaluateNum == evaluateNum)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.cookie, cookie) || other.cookie == cookie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,doubanUrl,poster,title,const DeepCollectionEquality().hash(subtitle),cast,const DeepCollectionEquality().hash(desc),ratingNum,evaluateNum,quote,cookie);

@override
String toString() {
  return 'TopMovie(rank: $rank, doubanUrl: $doubanUrl, poster: $poster, title: $title, subtitle: $subtitle, cast: $cast, desc: $desc, ratingNum: $ratingNum, evaluateNum: $evaluateNum, quote: $quote, cookie: $cookie)';
}


}

/// @nodoc
abstract mixin class $TopMovieCopyWith<$Res>  {
  factory $TopMovieCopyWith(TopMovie value, $Res Function(TopMovie) _then) = _$TopMovieCopyWithImpl;
@useResult
$Res call({
 String rank,@JsonKey(name: 'douban_url') String doubanUrl, String poster, String title, List<String> subtitle, String cast, List<String> desc,@JsonKey(name: 'rating_num') String ratingNum,@JsonKey(name: 'evaluate_num') String evaluateNum, String quote, String cookie
});




}
/// @nodoc
class _$TopMovieCopyWithImpl<$Res>
    implements $TopMovieCopyWith<$Res> {
  _$TopMovieCopyWithImpl(this._self, this._then);

  final TopMovie _self;
  final $Res Function(TopMovie) _then;

/// Create a copy of TopMovie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? doubanUrl = null,Object? poster = null,Object? title = null,Object? subtitle = null,Object? cast = null,Object? desc = null,Object? ratingNum = null,Object? evaluateNum = null,Object? quote = null,Object? cookie = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as List<String>,cast: null == cast ? _self.cast : cast // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self.desc : desc // ignore: cast_nullable_to_non_nullable
as List<String>,ratingNum: null == ratingNum ? _self.ratingNum : ratingNum // ignore: cast_nullable_to_non_nullable
as String,evaluateNum: null == evaluateNum ? _self.evaluateNum : evaluateNum // ignore: cast_nullable_to_non_nullable
as String,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,cookie: null == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TopMovie].
extension TopMoviePatterns on TopMovie {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopMovie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopMovie() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopMovie value)  $default,){
final _that = this;
switch (_that) {
case _TopMovie():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopMovie value)?  $default,){
final _that = this;
switch (_that) {
case _TopMovie() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rank, @JsonKey(name: 'douban_url')  String doubanUrl,  String poster,  String title,  List<String> subtitle,  String cast,  List<String> desc, @JsonKey(name: 'rating_num')  String ratingNum, @JsonKey(name: 'evaluate_num')  String evaluateNum,  String quote,  String cookie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopMovie() when $default != null:
return $default(_that.rank,_that.doubanUrl,_that.poster,_that.title,_that.subtitle,_that.cast,_that.desc,_that.ratingNum,_that.evaluateNum,_that.quote,_that.cookie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rank, @JsonKey(name: 'douban_url')  String doubanUrl,  String poster,  String title,  List<String> subtitle,  String cast,  List<String> desc, @JsonKey(name: 'rating_num')  String ratingNum, @JsonKey(name: 'evaluate_num')  String evaluateNum,  String quote,  String cookie)  $default,) {final _that = this;
switch (_that) {
case _TopMovie():
return $default(_that.rank,_that.doubanUrl,_that.poster,_that.title,_that.subtitle,_that.cast,_that.desc,_that.ratingNum,_that.evaluateNum,_that.quote,_that.cookie);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rank, @JsonKey(name: 'douban_url')  String doubanUrl,  String poster,  String title,  List<String> subtitle,  String cast,  List<String> desc, @JsonKey(name: 'rating_num')  String ratingNum, @JsonKey(name: 'evaluate_num')  String evaluateNum,  String quote,  String cookie)?  $default,) {final _that = this;
switch (_that) {
case _TopMovie() when $default != null:
return $default(_that.rank,_that.doubanUrl,_that.poster,_that.title,_that.subtitle,_that.cast,_that.desc,_that.ratingNum,_that.evaluateNum,_that.quote,_that.cookie);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopMovie implements TopMovie {
  const _TopMovie({this.rank = '', @JsonKey(name: 'douban_url') this.doubanUrl = '', this.poster = '', this.title = '', final  List<String> subtitle = const [], this.cast = '', final  List<String> desc = const [], @JsonKey(name: 'rating_num') this.ratingNum = '', @JsonKey(name: 'evaluate_num') this.evaluateNum = '', this.quote = '', this.cookie = ''}): _subtitle = subtitle,_desc = desc;
  factory _TopMovie.fromJson(Map<String, dynamic> json) => _$TopMovieFromJson(json);

@override@JsonKey() final  String rank;
@override@JsonKey(name: 'douban_url') final  String doubanUrl;
@override@JsonKey() final  String poster;
@override@JsonKey() final  String title;
 final  List<String> _subtitle;
@override@JsonKey() List<String> get subtitle {
  if (_subtitle is EqualUnmodifiableListView) return _subtitle;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subtitle);
}

@override@JsonKey() final  String cast;
 final  List<String> _desc;
@override@JsonKey() List<String> get desc {
  if (_desc is EqualUnmodifiableListView) return _desc;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_desc);
}

@override@JsonKey(name: 'rating_num') final  String ratingNum;
@override@JsonKey(name: 'evaluate_num') final  String evaluateNum;
@override@JsonKey() final  String quote;
@override@JsonKey() final  String cookie;

/// Create a copy of TopMovie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopMovieCopyWith<_TopMovie> get copyWith => __$TopMovieCopyWithImpl<_TopMovie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopMovieToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopMovie&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._subtitle, _subtitle)&&(identical(other.cast, cast) || other.cast == cast)&&const DeepCollectionEquality().equals(other._desc, _desc)&&(identical(other.ratingNum, ratingNum) || other.ratingNum == ratingNum)&&(identical(other.evaluateNum, evaluateNum) || other.evaluateNum == evaluateNum)&&(identical(other.quote, quote) || other.quote == quote)&&(identical(other.cookie, cookie) || other.cookie == cookie));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,doubanUrl,poster,title,const DeepCollectionEquality().hash(_subtitle),cast,const DeepCollectionEquality().hash(_desc),ratingNum,evaluateNum,quote,cookie);

@override
String toString() {
  return 'TopMovie(rank: $rank, doubanUrl: $doubanUrl, poster: $poster, title: $title, subtitle: $subtitle, cast: $cast, desc: $desc, ratingNum: $ratingNum, evaluateNum: $evaluateNum, quote: $quote, cookie: $cookie)';
}


}

/// @nodoc
abstract mixin class _$TopMovieCopyWith<$Res> implements $TopMovieCopyWith<$Res> {
  factory _$TopMovieCopyWith(_TopMovie value, $Res Function(_TopMovie) _then) = __$TopMovieCopyWithImpl;
@override @useResult
$Res call({
 String rank,@JsonKey(name: 'douban_url') String doubanUrl, String poster, String title, List<String> subtitle, String cast, List<String> desc,@JsonKey(name: 'rating_num') String ratingNum,@JsonKey(name: 'evaluate_num') String evaluateNum, String quote, String cookie
});




}
/// @nodoc
class __$TopMovieCopyWithImpl<$Res>
    implements _$TopMovieCopyWith<$Res> {
  __$TopMovieCopyWithImpl(this._self, this._then);

  final _TopMovie _self;
  final $Res Function(_TopMovie) _then;

/// Create a copy of TopMovie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? doubanUrl = null,Object? poster = null,Object? title = null,Object? subtitle = null,Object? cast = null,Object? desc = null,Object? ratingNum = null,Object? evaluateNum = null,Object? quote = null,Object? cookie = null,}) {
  return _then(_TopMovie(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self._subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as List<String>,cast: null == cast ? _self.cast : cast // ignore: cast_nullable_to_non_nullable
as String,desc: null == desc ? _self._desc : desc // ignore: cast_nullable_to_non_nullable
as List<String>,ratingNum: null == ratingNum ? _self.ratingNum : ratingNum // ignore: cast_nullable_to_non_nullable
as String,evaluateNum: null == evaluateNum ? _self.evaluateNum : evaluateNum // ignore: cast_nullable_to_non_nullable
as String,quote: null == quote ? _self.quote : quote // ignore: cast_nullable_to_non_nullable
as String,cookie: null == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
