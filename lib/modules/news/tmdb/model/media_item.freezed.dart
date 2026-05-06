// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaItem {

 int get id; String get title;@JsonKey(name: 'original_title') String get originalTitle; String get overview;@JsonKey(name: 'poster_path') String get posterPath;@JsonKey(name: 'backdrop_path') String get backdropPath;@JsonKey(name: 'media_type') String get mediaType;@JsonKey(name: 'original_language') String get originalLanguage; double get popularity;@JsonKey(name: 'vote_average') double? get voteAverage;@JsonKey(name: 'vote_count') int? get voteCount;@JsonKey(name: 'release_date') String get releaseDate;@JsonKey(name: 'genre_ids') List<int> get genreIds; bool get adult; bool? get video;@JsonKey(name: 'origin_country') List<String>? get originCountry;
/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaItemCopyWith<MediaItem> get copyWith => _$MediaItemCopyWithImpl<MediaItem>(this as MediaItem, _$identity);

  /// Serializes this MediaItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other.originCountry, originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalTitle,overview,posterPath,backdropPath,mediaType,originalLanguage,popularity,voteAverage,voteCount,releaseDate,const DeepCollectionEquality().hash(genreIds),adult,video,const DeepCollectionEquality().hash(originCountry));

@override
String toString() {
  return 'MediaItem(id: $id, title: $title, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, mediaType: $mediaType, originalLanguage: $originalLanguage, popularity: $popularity, voteAverage: $voteAverage, voteCount: $voteCount, releaseDate: $releaseDate, genreIds: $genreIds, adult: $adult, video: $video, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class $MediaItemCopyWith<$Res>  {
  factory $MediaItemCopyWith(MediaItem value, $Res Function(MediaItem) _then) = _$MediaItemCopyWithImpl;
@useResult
$Res call({
 int id, String title,@JsonKey(name: 'original_title') String originalTitle, String overview,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'backdrop_path') String backdropPath,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'original_language') String originalLanguage, double popularity,@JsonKey(name: 'vote_average') double? voteAverage,@JsonKey(name: 'vote_count') int? voteCount,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'genre_ids') List<int> genreIds, bool adult, bool? video,@JsonKey(name: 'origin_country') List<String>? originCountry
});




}
/// @nodoc
class _$MediaItemCopyWithImpl<$Res>
    implements $MediaItemCopyWith<$Res> {
  _$MediaItemCopyWithImpl(this._self, this._then);

  final MediaItem _self;
  final $Res Function(MediaItem) _then;

/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? overview = null,Object? posterPath = null,Object? backdropPath = null,Object? mediaType = null,Object? originalLanguage = null,Object? popularity = null,Object? voteAverage = freezed,Object? voteCount = freezed,Object? releaseDate = null,Object? genreIds = null,Object? adult = null,Object? video = freezed,Object? originCountry = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,genreIds: null == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool?,originCountry: freezed == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaItem].
extension MediaItemPatterns on MediaItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaItem value)  $default,){
final _that = this;
switch (_that) {
case _MediaItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaItem value)?  $default,){
final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'original_language')  String originalLanguage,  double popularity, @JsonKey(name: 'vote_average')  double? voteAverage, @JsonKey(name: 'vote_count')  int? voteCount, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'genre_ids')  List<int> genreIds,  bool adult,  bool? video, @JsonKey(name: 'origin_country')  List<String>? originCountry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.mediaType,_that.originalLanguage,_that.popularity,_that.voteAverage,_that.voteCount,_that.releaseDate,_that.genreIds,_that.adult,_that.video,_that.originCountry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'original_language')  String originalLanguage,  double popularity, @JsonKey(name: 'vote_average')  double? voteAverage, @JsonKey(name: 'vote_count')  int? voteCount, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'genre_ids')  List<int> genreIds,  bool adult,  bool? video, @JsonKey(name: 'origin_country')  List<String>? originCountry)  $default,) {final _that = this;
switch (_that) {
case _MediaItem():
return $default(_that.id,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.mediaType,_that.originalLanguage,_that.popularity,_that.voteAverage,_that.voteCount,_that.releaseDate,_that.genreIds,_that.adult,_that.video,_that.originCountry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title, @JsonKey(name: 'original_title')  String originalTitle,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'original_language')  String originalLanguage,  double popularity, @JsonKey(name: 'vote_average')  double? voteAverage, @JsonKey(name: 'vote_count')  int? voteCount, @JsonKey(name: 'release_date')  String releaseDate, @JsonKey(name: 'genre_ids')  List<int> genreIds,  bool adult,  bool? video, @JsonKey(name: 'origin_country')  List<String>? originCountry)?  $default,) {final _that = this;
switch (_that) {
case _MediaItem() when $default != null:
return $default(_that.id,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.mediaType,_that.originalLanguage,_that.popularity,_that.voteAverage,_that.voteCount,_that.releaseDate,_that.genreIds,_that.adult,_that.video,_that.originCountry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaItem implements MediaItem {
  const _MediaItem({this.id = 0, this.title = '', @JsonKey(name: 'original_title') this.originalTitle = '', this.overview = '', @JsonKey(name: 'poster_path') this.posterPath = '', @JsonKey(name: 'backdrop_path') this.backdropPath = '', @JsonKey(name: 'media_type') this.mediaType = '', @JsonKey(name: 'original_language') this.originalLanguage = '', this.popularity = 0.0, @JsonKey(name: 'vote_average') this.voteAverage = 0.0, @JsonKey(name: 'vote_count') this.voteCount = 0, @JsonKey(name: 'release_date') this.releaseDate = '', @JsonKey(name: 'genre_ids') final  List<int> genreIds = const [], this.adult = false, this.video, @JsonKey(name: 'origin_country') final  List<String>? originCountry = const []}): _genreIds = genreIds,_originCountry = originCountry;
  factory _MediaItem.fromJson(Map<String, dynamic> json) => _$MediaItemFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String title;
@override@JsonKey(name: 'original_title') final  String originalTitle;
@override@JsonKey() final  String overview;
@override@JsonKey(name: 'poster_path') final  String posterPath;
@override@JsonKey(name: 'backdrop_path') final  String backdropPath;
@override@JsonKey(name: 'media_type') final  String mediaType;
@override@JsonKey(name: 'original_language') final  String originalLanguage;
@override@JsonKey() final  double popularity;
@override@JsonKey(name: 'vote_average') final  double? voteAverage;
@override@JsonKey(name: 'vote_count') final  int? voteCount;
@override@JsonKey(name: 'release_date') final  String releaseDate;
 final  List<int> _genreIds;
@override@JsonKey(name: 'genre_ids') List<int> get genreIds {
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreIds);
}

@override@JsonKey() final  bool adult;
@override final  bool? video;
 final  List<String>? _originCountry;
@override@JsonKey(name: 'origin_country') List<String>? get originCountry {
  final value = _originCountry;
  if (value == null) return null;
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaItemCopyWith<_MediaItem> get copyWith => __$MediaItemCopyWithImpl<_MediaItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaItem&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.video, video) || other.video == video)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalTitle,overview,posterPath,backdropPath,mediaType,originalLanguage,popularity,voteAverage,voteCount,releaseDate,const DeepCollectionEquality().hash(_genreIds),adult,video,const DeepCollectionEquality().hash(_originCountry));

@override
String toString() {
  return 'MediaItem(id: $id, title: $title, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, mediaType: $mediaType, originalLanguage: $originalLanguage, popularity: $popularity, voteAverage: $voteAverage, voteCount: $voteCount, releaseDate: $releaseDate, genreIds: $genreIds, adult: $adult, video: $video, originCountry: $originCountry)';
}


}

/// @nodoc
abstract mixin class _$MediaItemCopyWith<$Res> implements $MediaItemCopyWith<$Res> {
  factory _$MediaItemCopyWith(_MediaItem value, $Res Function(_MediaItem) _then) = __$MediaItemCopyWithImpl;
@override @useResult
$Res call({
 int id, String title,@JsonKey(name: 'original_title') String originalTitle, String overview,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'backdrop_path') String backdropPath,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'original_language') String originalLanguage, double popularity,@JsonKey(name: 'vote_average') double? voteAverage,@JsonKey(name: 'vote_count') int? voteCount,@JsonKey(name: 'release_date') String releaseDate,@JsonKey(name: 'genre_ids') List<int> genreIds, bool adult, bool? video,@JsonKey(name: 'origin_country') List<String>? originCountry
});




}
/// @nodoc
class __$MediaItemCopyWithImpl<$Res>
    implements _$MediaItemCopyWith<$Res> {
  __$MediaItemCopyWithImpl(this._self, this._then);

  final _MediaItem _self;
  final $Res Function(_MediaItem) _then;

/// Create a copy of MediaItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? originalTitle = null,Object? overview = null,Object? posterPath = null,Object? backdropPath = null,Object? mediaType = null,Object? originalLanguage = null,Object? popularity = null,Object? voteAverage = freezed,Object? voteCount = freezed,Object? releaseDate = null,Object? genreIds = null,Object? adult = null,Object? video = freezed,Object? originCountry = freezed,}) {
  return _then(_MediaItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,genreIds: null == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,video: freezed == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool?,originCountry: freezed == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
