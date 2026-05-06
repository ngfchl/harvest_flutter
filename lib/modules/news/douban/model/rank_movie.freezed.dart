// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rank_movie.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankMovie {

 int get rank;@JsonKey(name: 'cover_url') String get poster; String get title;@JsonKey(name: 'url') String get doubanUrl; List<String> get rating;@JsonKey(name: 'is_playable') bool get isPlayable; String get id; List<String> get types; List<String> get regions;@JsonKey(name: 'release_date') String get releaseDate;@JsonKey(name: 'actor_count') int get actorCount;@JsonKey(name: 'vote_count') int get voteCount; String get score; String? get cookie; List<String> get actors;@JsonKey(name: 'is_watched') bool get isWatched;
/// Create a copy of RankMovie
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankMovieCopyWith<RankMovie> get copyWith => _$RankMovieCopyWithImpl<RankMovie>(this as RankMovie, _$identity);

  /// Serializes this RankMovie to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankMovie&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.title, title) || other.title == title)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&const DeepCollectionEquality().equals(other.rating, rating)&&(identical(other.isPlayable, isPlayable) || other.isPlayable == isPlayable)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.regions, regions)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.actorCount, actorCount) || other.actorCount == actorCount)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.score, score) || other.score == score)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&const DeepCollectionEquality().equals(other.actors, actors)&&(identical(other.isWatched, isWatched) || other.isWatched == isWatched));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,poster,title,doubanUrl,const DeepCollectionEquality().hash(rating),isPlayable,id,const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(regions),releaseDate,actorCount,voteCount,score,cookie,const DeepCollectionEquality().hash(actors),isWatched);

@override
String toString() {
  return 'RankMovie(rank: $rank, poster: $poster, title: $title, doubanUrl: $doubanUrl, rating: $rating, isPlayable: $isPlayable, id: $id, types: $types, regions: $regions, releaseDate: $releaseDate, actorCount: $actorCount, voteCount: $voteCount, score: $score, cookie: $cookie, actors: $actors, isWatched: $isWatched)';
}


}

/// @nodoc
abstract mixin class $RankMovieCopyWith<$Res>  {
  factory $RankMovieCopyWith(RankMovie value, $Res Function(RankMovie) _then) = _$RankMovieCopyWithImpl;
@useResult
$Res call({
 int rank,@JsonKey(name: 'cover_url') String poster, String title,@JsonKey(name: 'url') String doubanUrl, List<String> rating,@JsonKey(name: 'is_playable') bool isPlayable, String id, List<String> types, List<String> regions,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'actor_count') int actorCount,@JsonKey(name: 'vote_count') int voteCount, String score, String? cookie, List<String> actors,@JsonKey(name: 'is_watched') bool isWatched
});




}
/// @nodoc
class _$RankMovieCopyWithImpl<$Res>
    implements $RankMovieCopyWith<$Res> {
  _$RankMovieCopyWithImpl(this._self, this._then);

  final RankMovie _self;
  final $Res Function(RankMovie) _then;

/// Create a copy of RankMovie
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? poster = null,Object? title = null,Object? doubanUrl = null,Object? rating = null,Object? isPlayable = null,Object? id = null,Object? types = null,Object? regions = null,Object? releaseDate = null,Object? actorCount = null,Object? voteCount = null,Object? score = null,Object? cookie = freezed,Object? actors = null,Object? isWatched = null,}) {
  return _then(_self.copyWith(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as List<String>,isPlayable: null == isPlayable ? _self.isPlayable : isPlayable // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as List<String>,regions: null == regions ? _self.regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,actorCount: null == actorCount ? _self.actorCount : actorCount // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,actors: null == actors ? _self.actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,isWatched: null == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RankMovie].
extension RankMoviePatterns on RankMovie {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankMovie value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankMovie() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankMovie value)  $default,){
final _that = this;
switch (_that) {
case _RankMovie():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankMovie value)?  $default,){
final _that = this;
switch (_that) {
case _RankMovie() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'cover_url')  String poster,  String title, @JsonKey(name: 'url')  String doubanUrl,  List<String> rating, @JsonKey(name: 'is_playable')  bool isPlayable,  String id,  List<String> types,  List<String> regions, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'actor_count')  int actorCount, @JsonKey(name: 'vote_count')  int voteCount,  String score,  String? cookie,  List<String> actors, @JsonKey(name: 'is_watched')  bool isWatched)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankMovie() when $default != null:
return $default(_that.rank,_that.poster,_that.title,_that.doubanUrl,_that.rating,_that.isPlayable,_that.id,_that.types,_that.regions,_that.releaseDate,_that.actorCount,_that.voteCount,_that.score,_that.cookie,_that.actors,_that.isWatched);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank, @JsonKey(name: 'cover_url')  String poster,  String title, @JsonKey(name: 'url')  String doubanUrl,  List<String> rating, @JsonKey(name: 'is_playable')  bool isPlayable,  String id,  List<String> types,  List<String> regions, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'actor_count')  int actorCount, @JsonKey(name: 'vote_count')  int voteCount,  String score,  String? cookie,  List<String> actors, @JsonKey(name: 'is_watched')  bool isWatched)  $default,) {final _that = this;
switch (_that) {
case _RankMovie():
return $default(_that.rank,_that.poster,_that.title,_that.doubanUrl,_that.rating,_that.isPlayable,_that.id,_that.types,_that.regions,_that.releaseDate,_that.actorCount,_that.voteCount,_that.score,_that.cookie,_that.actors,_that.isWatched);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank, @JsonKey(name: 'cover_url')  String poster,  String title, @JsonKey(name: 'url')  String doubanUrl,  List<String> rating, @JsonKey(name: 'is_playable')  bool isPlayable,  String id,  List<String> types,  List<String> regions, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'actor_count')  int actorCount, @JsonKey(name: 'vote_count')  int voteCount,  String score,  String? cookie,  List<String> actors, @JsonKey(name: 'is_watched')  bool isWatched)?  $default,) {final _that = this;
switch (_that) {
case _RankMovie() when $default != null:
return $default(_that.rank,_that.poster,_that.title,_that.doubanUrl,_that.rating,_that.isPlayable,_that.id,_that.types,_that.regions,_that.releaseDate,_that.actorCount,_that.voteCount,_that.score,_that.cookie,_that.actors,_that.isWatched);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankMovie implements RankMovie {
  const _RankMovie({this.rank = 0, @JsonKey(name: 'cover_url') this.poster = '', this.title = '', @JsonKey(name: 'url') this.doubanUrl = '', final  List<String> rating = const [], @JsonKey(name: 'is_playable') this.isPlayable = false, this.id = '', final  List<String> types = const [], final  List<String> regions = const [], @JsonKey(name: 'release_date') this.releaseDate = '', @JsonKey(name: 'actor_count') this.actorCount = 0, @JsonKey(name: 'vote_count') this.voteCount = 0, this.score = '', this.cookie, final  List<String> actors = const [], @JsonKey(name: 'is_watched') this.isWatched = false}): _rating = rating,_types = types,_regions = regions,_actors = actors;
  factory _RankMovie.fromJson(Map<String, dynamic> json) => _$RankMovieFromJson(json);

@override@JsonKey() final  int rank;
@override@JsonKey(name: 'cover_url') final  String poster;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'url') final  String doubanUrl;
 final  List<String> _rating;
@override@JsonKey() List<String> get rating {
  if (_rating is EqualUnmodifiableListView) return _rating;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rating);
}

@override@JsonKey(name: 'is_playable') final  bool isPlayable;
@override@JsonKey() final  String id;
 final  List<String> _types;
@override@JsonKey() List<String> get types {
  if (_types is EqualUnmodifiableListView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_types);
}

 final  List<String> _regions;
@override@JsonKey() List<String> get regions {
  if (_regions is EqualUnmodifiableListView) return _regions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_regions);
}

@override@JsonKey(name: 'release_date') final  String releaseDate;
@override@JsonKey(name: 'actor_count') final  int actorCount;
@override@JsonKey(name: 'vote_count') final  int voteCount;
@override@JsonKey() final  String score;
@override final  String? cookie;
 final  List<String> _actors;
@override@JsonKey() List<String> get actors {
  if (_actors is EqualUnmodifiableListView) return _actors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actors);
}

@override@JsonKey(name: 'is_watched') final  bool isWatched;

/// Create a copy of RankMovie
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankMovieCopyWith<_RankMovie> get copyWith => __$RankMovieCopyWithImpl<_RankMovie>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankMovieToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankMovie&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.poster, poster) || other.poster == poster)&&(identical(other.title, title) || other.title == title)&&(identical(other.doubanUrl, doubanUrl) || other.doubanUrl == doubanUrl)&&const DeepCollectionEquality().equals(other._rating, _rating)&&(identical(other.isPlayable, isPlayable) || other.isPlayable == isPlayable)&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._regions, _regions)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.actorCount, actorCount) || other.actorCount == actorCount)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.score, score) || other.score == score)&&(identical(other.cookie, cookie) || other.cookie == cookie)&&const DeepCollectionEquality().equals(other._actors, _actors)&&(identical(other.isWatched, isWatched) || other.isWatched == isWatched));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rank,poster,title,doubanUrl,const DeepCollectionEquality().hash(_rating),isPlayable,id,const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_regions),releaseDate,actorCount,voteCount,score,cookie,const DeepCollectionEquality().hash(_actors),isWatched);

@override
String toString() {
  return 'RankMovie(rank: $rank, poster: $poster, title: $title, doubanUrl: $doubanUrl, rating: $rating, isPlayable: $isPlayable, id: $id, types: $types, regions: $regions, releaseDate: $releaseDate, actorCount: $actorCount, voteCount: $voteCount, score: $score, cookie: $cookie, actors: $actors, isWatched: $isWatched)';
}


}

/// @nodoc
abstract mixin class _$RankMovieCopyWith<$Res> implements $RankMovieCopyWith<$Res> {
  factory _$RankMovieCopyWith(_RankMovie value, $Res Function(_RankMovie) _then) = __$RankMovieCopyWithImpl;
@override @useResult
$Res call({
 int rank,@JsonKey(name: 'cover_url') String poster, String title,@JsonKey(name: 'url') String doubanUrl, List<String> rating,@JsonKey(name: 'is_playable') bool isPlayable, String id, List<String> types, List<String> regions,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'actor_count') int actorCount,@JsonKey(name: 'vote_count') int voteCount, String score, String? cookie, List<String> actors,@JsonKey(name: 'is_watched') bool isWatched
});




}
/// @nodoc
class __$RankMovieCopyWithImpl<$Res>
    implements _$RankMovieCopyWith<$Res> {
  __$RankMovieCopyWithImpl(this._self, this._then);

  final _RankMovie _self;
  final $Res Function(_RankMovie) _then;

/// Create a copy of RankMovie
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? poster = null,Object? title = null,Object? doubanUrl = null,Object? rating = null,Object? isPlayable = null,Object? id = null,Object? types = null,Object? regions = null,Object? releaseDate = null,Object? actorCount = null,Object? voteCount = null,Object? score = null,Object? cookie = freezed,Object? actors = null,Object? isWatched = null,}) {
  return _then(_RankMovie(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,poster: null == poster ? _self.poster : poster // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,doubanUrl: null == doubanUrl ? _self.doubanUrl : doubanUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self._rating : rating // ignore: cast_nullable_to_non_nullable
as List<String>,isPlayable: null == isPlayable ? _self.isPlayable : isPlayable // ignore: cast_nullable_to_non_nullable
as bool,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as List<String>,regions: null == regions ? _self._regions : regions // ignore: cast_nullable_to_non_nullable
as List<String>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,actorCount: null == actorCount ? _self.actorCount : actorCount // ignore: cast_nullable_to_non_nullable
as int,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as String,cookie: freezed == cookie ? _self.cookie : cookie // ignore: cast_nullable_to_non_nullable
as String?,actors: null == actors ? _self._actors : actors // ignore: cast_nullable_to_non_nullable
as List<String>,isWatched: null == isWatched ? _self.isWatched : isWatched // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
