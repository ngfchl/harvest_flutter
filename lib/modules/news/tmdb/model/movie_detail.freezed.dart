// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovieDetail {

 bool get adult;@JsonKey(name: 'backdrop_path') String get backdropPath;@JsonKey(name: 'belongs_to_collection') BelongsToCollection? get belongsToCollection; int get budget; List<Genre> get genres; String get homepage; int get id;@JsonKey(name: 'imdb_id') String? get imdbId;@JsonKey(includeFromJson: false, includeToJson: false) String get mediaType;@JsonKey(name: 'origin_country') List<String> get originCountry;@JsonKey(name: 'original_language') String get originalLanguage;@JsonKey(name: 'original_title') String get originalTitle; String get overview; double get popularity;@JsonKey(name: 'poster_path') String get posterPath;@JsonKey(name: 'production_companies') List<ProductionCompany> get productionCompanies;@JsonKey(name: 'production_countries') List<ProductionCountry> get productionCountries;@JsonKey(name: 'release_date') String get releaseDate; int get revenue; int get runtime;@JsonKey(name: 'spoken_languages') List<SpokenLanguage> get spokenLanguages; String get status; String get tagline; String get title; bool get video;@JsonKey(name: 'vote_average') double get voteAverage;@JsonKey(name: 'vote_count') int get voteCount;
/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieDetailCopyWith<MovieDetail> get copyWith => _$MovieDetailCopyWithImpl<MovieDetail>(this as MovieDetail, _$identity);

  /// Serializes this MovieDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetail&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.belongsToCollection, belongsToCollection) || other.belongsToCollection == belongsToCollection)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.homepage, homepage) || other.homepage == homepage)&&(identical(other.id, id) || other.id == id)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&const DeepCollectionEquality().equals(other.originCountry, originCountry)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&const DeepCollectionEquality().equals(other.productionCompanies, productionCompanies)&&const DeepCollectionEquality().equals(other.productionCountries, productionCountries)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&const DeepCollectionEquality().equals(other.spokenLanguages, spokenLanguages)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.title, title) || other.title == title)&&(identical(other.video, video) || other.video == video)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,adult,backdropPath,belongsToCollection,budget,const DeepCollectionEquality().hash(genres),homepage,id,imdbId,mediaType,const DeepCollectionEquality().hash(originCountry),originalLanguage,originalTitle,overview,popularity,posterPath,const DeepCollectionEquality().hash(productionCompanies),const DeepCollectionEquality().hash(productionCountries),releaseDate,revenue,runtime,const DeepCollectionEquality().hash(spokenLanguages),status,tagline,title,video,voteAverage,voteCount]);

@override
String toString() {
  return 'MovieDetail(adult: $adult, backdropPath: $backdropPath, belongsToCollection: $belongsToCollection, budget: $budget, genres: $genres, homepage: $homepage, id: $id, imdbId: $imdbId, mediaType: $mediaType, originCountry: $originCountry, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, productionCompanies: $productionCompanies, productionCountries: $productionCountries, releaseDate: $releaseDate, revenue: $revenue, runtime: $runtime, spokenLanguages: $spokenLanguages, status: $status, tagline: $tagline, title: $title, video: $video, voteAverage: $voteAverage, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class $MovieDetailCopyWith<$Res>  {
  factory $MovieDetailCopyWith(MovieDetail value, $Res Function(MovieDetail) _then) = _$MovieDetailCopyWithImpl;
@useResult
$Res call({
 bool adult,@JsonKey(name: 'backdrop_path') String backdropPath,@JsonKey(name: 'belongs_to_collection') BelongsToCollection? belongsToCollection, int budget, List<Genre> genres, String homepage, int id,@JsonKey(name: 'imdb_id') String? imdbId,@JsonKey(includeFromJson: false, includeToJson: false) String mediaType,@JsonKey(name: 'origin_country') List<String> originCountry,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'original_title') String originalTitle, String overview, double popularity,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'production_companies') List<ProductionCompany> productionCompanies,@JsonKey(name: 'production_countries') List<ProductionCountry> productionCountries,@JsonKey(name: 'release_date') String releaseDate, int revenue, int runtime,@JsonKey(name: 'spoken_languages') List<SpokenLanguage> spokenLanguages, String status, String tagline, String title, bool video,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount
});


$BelongsToCollectionCopyWith<$Res>? get belongsToCollection;

}
/// @nodoc
class _$MovieDetailCopyWithImpl<$Res>
    implements $MovieDetailCopyWith<$Res> {
  _$MovieDetailCopyWithImpl(this._self, this._then);

  final MovieDetail _self;
  final $Res Function(MovieDetail) _then;

/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adult = null,Object? backdropPath = null,Object? belongsToCollection = freezed,Object? budget = null,Object? genres = null,Object? homepage = null,Object? id = null,Object? imdbId = freezed,Object? mediaType = null,Object? originCountry = null,Object? originalLanguage = null,Object? originalTitle = null,Object? overview = null,Object? popularity = null,Object? posterPath = null,Object? productionCompanies = null,Object? productionCountries = null,Object? releaseDate = null,Object? revenue = null,Object? runtime = null,Object? spokenLanguages = null,Object? status = null,Object? tagline = null,Object? title = null,Object? video = null,Object? voteAverage = null,Object? voteCount = null,}) {
  return _then(_self.copyWith(
adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,belongsToCollection: freezed == belongsToCollection ? _self.belongsToCollection : belongsToCollection // ignore: cast_nullable_to_non_nullable
as BelongsToCollection?,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,homepage: null == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,productionCompanies: null == productionCompanies ? _self.productionCompanies : productionCompanies // ignore: cast_nullable_to_non_nullable
as List<ProductionCompany>,productionCountries: null == productionCountries ? _self.productionCountries : productionCountries // ignore: cast_nullable_to_non_nullable
as List<ProductionCountry>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int,spokenLanguages: null == spokenLanguages ? _self.spokenLanguages : spokenLanguages // ignore: cast_nullable_to_non_nullable
as List<SpokenLanguage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,video: null == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BelongsToCollectionCopyWith<$Res>? get belongsToCollection {
    if (_self.belongsToCollection == null) {
    return null;
  }

  return $BelongsToCollectionCopyWith<$Res>(_self.belongsToCollection!, (value) {
    return _then(_self.copyWith(belongsToCollection: value));
  });
}
}


/// Adds pattern-matching-related methods to [MovieDetail].
extension MovieDetailPatterns on MovieDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieDetail value)  $default,){
final _that = this;
switch (_that) {
case _MovieDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieDetail value)?  $default,){
final _that = this;
switch (_that) {
case _MovieDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool adult, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'belongs_to_collection')  BelongsToCollection? belongsToCollection,  int budget,  List<Genre> genres,  String homepage,  int id, @JsonKey(name: 'imdb_id')  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_title')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries, @JsonKey(name: 'release_date')  String releaseDate,  int revenue,  int runtime, @JsonKey(name: 'spoken_languages')  List<SpokenLanguage> spokenLanguages,  String status,  String tagline,  String title,  bool video, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieDetail() when $default != null:
return $default(_that.adult,_that.backdropPath,_that.belongsToCollection,_that.budget,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.releaseDate,_that.revenue,_that.runtime,_that.spokenLanguages,_that.status,_that.tagline,_that.title,_that.video,_that.voteAverage,_that.voteCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool adult, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'belongs_to_collection')  BelongsToCollection? belongsToCollection,  int budget,  List<Genre> genres,  String homepage,  int id, @JsonKey(name: 'imdb_id')  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_title')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries, @JsonKey(name: 'release_date')  String releaseDate,  int revenue,  int runtime, @JsonKey(name: 'spoken_languages')  List<SpokenLanguage> spokenLanguages,  String status,  String tagline,  String title,  bool video, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)  $default,) {final _that = this;
switch (_that) {
case _MovieDetail():
return $default(_that.adult,_that.backdropPath,_that.belongsToCollection,_that.budget,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.releaseDate,_that.revenue,_that.runtime,_that.spokenLanguages,_that.status,_that.tagline,_that.title,_that.video,_that.voteAverage,_that.voteCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool adult, @JsonKey(name: 'backdrop_path')  String backdropPath, @JsonKey(name: 'belongs_to_collection')  BelongsToCollection? belongsToCollection,  int budget,  List<Genre> genres,  String homepage,  int id, @JsonKey(name: 'imdb_id')  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_title')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries, @JsonKey(name: 'release_date')  String releaseDate,  int revenue,  int runtime, @JsonKey(name: 'spoken_languages')  List<SpokenLanguage> spokenLanguages,  String status,  String tagline,  String title,  bool video, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)?  $default,) {final _that = this;
switch (_that) {
case _MovieDetail() when $default != null:
return $default(_that.adult,_that.backdropPath,_that.belongsToCollection,_that.budget,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.releaseDate,_that.revenue,_that.runtime,_that.spokenLanguages,_that.status,_that.tagline,_that.title,_that.video,_that.voteAverage,_that.voteCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovieDetail implements MovieDetail {
  const _MovieDetail({this.adult = false, @JsonKey(name: 'backdrop_path') this.backdropPath = '', @JsonKey(name: 'belongs_to_collection') this.belongsToCollection, this.budget = 0, final  List<Genre> genres = const [], this.homepage = '', this.id = 0, @JsonKey(name: 'imdb_id') this.imdbId = '', @JsonKey(includeFromJson: false, includeToJson: false) this.mediaType = 'movie', @JsonKey(name: 'origin_country') final  List<String> originCountry = const [], @JsonKey(name: 'original_language') this.originalLanguage = '', @JsonKey(name: 'original_title') this.originalTitle = '', this.overview = '', this.popularity = 0.0, @JsonKey(name: 'poster_path') this.posterPath = '', @JsonKey(name: 'production_companies') final  List<ProductionCompany> productionCompanies = const [], @JsonKey(name: 'production_countries') final  List<ProductionCountry> productionCountries = const [], @JsonKey(name: 'release_date') this.releaseDate = '', this.revenue = 0, this.runtime = 0, @JsonKey(name: 'spoken_languages') final  List<SpokenLanguage> spokenLanguages = const [], this.status = '', this.tagline = '', this.title = '', this.video = false, @JsonKey(name: 'vote_average') this.voteAverage = 0.0, @JsonKey(name: 'vote_count') this.voteCount = 0}): _genres = genres,_originCountry = originCountry,_productionCompanies = productionCompanies,_productionCountries = productionCountries,_spokenLanguages = spokenLanguages;
  factory _MovieDetail.fromJson(Map<String, dynamic> json) => _$MovieDetailFromJson(json);

@override@JsonKey() final  bool adult;
@override@JsonKey(name: 'backdrop_path') final  String backdropPath;
@override@JsonKey(name: 'belongs_to_collection') final  BelongsToCollection? belongsToCollection;
@override@JsonKey() final  int budget;
 final  List<Genre> _genres;
@override@JsonKey() List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey() final  String homepage;
@override@JsonKey() final  int id;
@override@JsonKey(name: 'imdb_id') final  String? imdbId;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  String mediaType;
 final  List<String> _originCountry;
@override@JsonKey(name: 'origin_country') List<String> get originCountry {
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originCountry);
}

@override@JsonKey(name: 'original_language') final  String originalLanguage;
@override@JsonKey(name: 'original_title') final  String originalTitle;
@override@JsonKey() final  String overview;
@override@JsonKey() final  double popularity;
@override@JsonKey(name: 'poster_path') final  String posterPath;
 final  List<ProductionCompany> _productionCompanies;
@override@JsonKey(name: 'production_companies') List<ProductionCompany> get productionCompanies {
  if (_productionCompanies is EqualUnmodifiableListView) return _productionCompanies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productionCompanies);
}

 final  List<ProductionCountry> _productionCountries;
@override@JsonKey(name: 'production_countries') List<ProductionCountry> get productionCountries {
  if (_productionCountries is EqualUnmodifiableListView) return _productionCountries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_productionCountries);
}

@override@JsonKey(name: 'release_date') final  String releaseDate;
@override@JsonKey() final  int revenue;
@override@JsonKey() final  int runtime;
 final  List<SpokenLanguage> _spokenLanguages;
@override@JsonKey(name: 'spoken_languages') List<SpokenLanguage> get spokenLanguages {
  if (_spokenLanguages is EqualUnmodifiableListView) return _spokenLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spokenLanguages);
}

@override@JsonKey() final  String status;
@override@JsonKey() final  String tagline;
@override@JsonKey() final  String title;
@override@JsonKey() final  bool video;
@override@JsonKey(name: 'vote_average') final  double voteAverage;
@override@JsonKey(name: 'vote_count') final  int voteCount;

/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieDetailCopyWith<_MovieDetail> get copyWith => __$MovieDetailCopyWithImpl<_MovieDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieDetail&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.belongsToCollection, belongsToCollection) || other.belongsToCollection == belongsToCollection)&&(identical(other.budget, budget) || other.budget == budget)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.homepage, homepage) || other.homepage == homepage)&&(identical(other.id, id) || other.id == id)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&const DeepCollectionEquality().equals(other._productionCompanies, _productionCompanies)&&const DeepCollectionEquality().equals(other._productionCountries, _productionCountries)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&const DeepCollectionEquality().equals(other._spokenLanguages, _spokenLanguages)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.title, title) || other.title == title)&&(identical(other.video, video) || other.video == video)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,adult,backdropPath,belongsToCollection,budget,const DeepCollectionEquality().hash(_genres),homepage,id,imdbId,mediaType,const DeepCollectionEquality().hash(_originCountry),originalLanguage,originalTitle,overview,popularity,posterPath,const DeepCollectionEquality().hash(_productionCompanies),const DeepCollectionEquality().hash(_productionCountries),releaseDate,revenue,runtime,const DeepCollectionEquality().hash(_spokenLanguages),status,tagline,title,video,voteAverage,voteCount]);

@override
String toString() {
  return 'MovieDetail(adult: $adult, backdropPath: $backdropPath, belongsToCollection: $belongsToCollection, budget: $budget, genres: $genres, homepage: $homepage, id: $id, imdbId: $imdbId, mediaType: $mediaType, originCountry: $originCountry, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, productionCompanies: $productionCompanies, productionCountries: $productionCountries, releaseDate: $releaseDate, revenue: $revenue, runtime: $runtime, spokenLanguages: $spokenLanguages, status: $status, tagline: $tagline, title: $title, video: $video, voteAverage: $voteAverage, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class _$MovieDetailCopyWith<$Res> implements $MovieDetailCopyWith<$Res> {
  factory _$MovieDetailCopyWith(_MovieDetail value, $Res Function(_MovieDetail) _then) = __$MovieDetailCopyWithImpl;
@override @useResult
$Res call({
 bool adult,@JsonKey(name: 'backdrop_path') String backdropPath,@JsonKey(name: 'belongs_to_collection') BelongsToCollection? belongsToCollection, int budget, List<Genre> genres, String homepage, int id,@JsonKey(name: 'imdb_id') String? imdbId,@JsonKey(includeFromJson: false, includeToJson: false) String mediaType,@JsonKey(name: 'origin_country') List<String> originCountry,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'original_title') String originalTitle, String overview, double popularity,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'production_companies') List<ProductionCompany> productionCompanies,@JsonKey(name: 'production_countries') List<ProductionCountry> productionCountries,@JsonKey(name: 'release_date') String releaseDate, int revenue, int runtime,@JsonKey(name: 'spoken_languages') List<SpokenLanguage> spokenLanguages, String status, String tagline, String title, bool video,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount
});


@override $BelongsToCollectionCopyWith<$Res>? get belongsToCollection;

}
/// @nodoc
class __$MovieDetailCopyWithImpl<$Res>
    implements _$MovieDetailCopyWith<$Res> {
  __$MovieDetailCopyWithImpl(this._self, this._then);

  final _MovieDetail _self;
  final $Res Function(_MovieDetail) _then;

/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adult = null,Object? backdropPath = null,Object? belongsToCollection = freezed,Object? budget = null,Object? genres = null,Object? homepage = null,Object? id = null,Object? imdbId = freezed,Object? mediaType = null,Object? originCountry = null,Object? originalLanguage = null,Object? originalTitle = null,Object? overview = null,Object? popularity = null,Object? posterPath = null,Object? productionCompanies = null,Object? productionCountries = null,Object? releaseDate = null,Object? revenue = null,Object? runtime = null,Object? spokenLanguages = null,Object? status = null,Object? tagline = null,Object? title = null,Object? video = null,Object? voteAverage = null,Object? voteCount = null,}) {
  return _then(_MovieDetail(
adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,belongsToCollection: freezed == belongsToCollection ? _self.belongsToCollection : belongsToCollection // ignore: cast_nullable_to_non_nullable
as BelongsToCollection?,budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as int,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,homepage: null == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,originCountry: null == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,productionCompanies: null == productionCompanies ? _self._productionCompanies : productionCompanies // ignore: cast_nullable_to_non_nullable
as List<ProductionCompany>,productionCountries: null == productionCountries ? _self._productionCountries : productionCountries // ignore: cast_nullable_to_non_nullable
as List<ProductionCountry>,releaseDate: null == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,runtime: null == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int,spokenLanguages: null == spokenLanguages ? _self._spokenLanguages : spokenLanguages // ignore: cast_nullable_to_non_nullable
as List<SpokenLanguage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,video: null == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of MovieDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BelongsToCollectionCopyWith<$Res>? get belongsToCollection {
    if (_self.belongsToCollection == null) {
    return null;
  }

  return $BelongsToCollectionCopyWith<$Res>(_self.belongsToCollection!, (value) {
    return _then(_self.copyWith(belongsToCollection: value));
  });
}
}


/// @nodoc
mixin _$BelongsToCollection {

 int get id; String get name;@JsonKey(name: 'poster_path') String get posterPath;@JsonKey(name: 'backdrop_path') String get backdropPath;
/// Create a copy of BelongsToCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BelongsToCollectionCopyWith<BelongsToCollection> get copyWith => _$BelongsToCollectionCopyWithImpl<BelongsToCollection>(this as BelongsToCollection, _$identity);

  /// Serializes this BelongsToCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BelongsToCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,posterPath,backdropPath);

@override
String toString() {
  return 'BelongsToCollection(id: $id, name: $name, posterPath: $posterPath, backdropPath: $backdropPath)';
}


}

/// @nodoc
abstract mixin class $BelongsToCollectionCopyWith<$Res>  {
  factory $BelongsToCollectionCopyWith(BelongsToCollection value, $Res Function(BelongsToCollection) _then) = _$BelongsToCollectionCopyWithImpl;
@useResult
$Res call({
 int id, String name,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'backdrop_path') String backdropPath
});




}
/// @nodoc
class _$BelongsToCollectionCopyWithImpl<$Res>
    implements $BelongsToCollectionCopyWith<$Res> {
  _$BelongsToCollectionCopyWithImpl(this._self, this._then);

  final BelongsToCollection _self;
  final $Res Function(BelongsToCollection) _then;

/// Create a copy of BelongsToCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? posterPath = null,Object? backdropPath = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BelongsToCollection].
extension BelongsToCollectionPatterns on BelongsToCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BelongsToCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BelongsToCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BelongsToCollection value)  $default,){
final _that = this;
switch (_that) {
case _BelongsToCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BelongsToCollection value)?  $default,){
final _that = this;
switch (_that) {
case _BelongsToCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BelongsToCollection() when $default != null:
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath)  $default,) {final _that = this;
switch (_that) {
case _BelongsToCollection():
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'backdrop_path')  String backdropPath)?  $default,) {final _that = this;
switch (_that) {
case _BelongsToCollection() when $default != null:
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BelongsToCollection implements BelongsToCollection {
  const _BelongsToCollection({this.id = 0, this.name = '', @JsonKey(name: 'poster_path') this.posterPath = '', @JsonKey(name: 'backdrop_path') this.backdropPath = ''});
  factory _BelongsToCollection.fromJson(Map<String, dynamic> json) => _$BelongsToCollectionFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'poster_path') final  String posterPath;
@override@JsonKey(name: 'backdrop_path') final  String backdropPath;

/// Create a copy of BelongsToCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BelongsToCollectionCopyWith<_BelongsToCollection> get copyWith => __$BelongsToCollectionCopyWithImpl<_BelongsToCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BelongsToCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BelongsToCollection&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,posterPath,backdropPath);

@override
String toString() {
  return 'BelongsToCollection(id: $id, name: $name, posterPath: $posterPath, backdropPath: $backdropPath)';
}


}

/// @nodoc
abstract mixin class _$BelongsToCollectionCopyWith<$Res> implements $BelongsToCollectionCopyWith<$Res> {
  factory _$BelongsToCollectionCopyWith(_BelongsToCollection value, $Res Function(_BelongsToCollection) _then) = __$BelongsToCollectionCopyWithImpl;
@override @useResult
$Res call({
 int id, String name,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'backdrop_path') String backdropPath
});




}
/// @nodoc
class __$BelongsToCollectionCopyWithImpl<$Res>
    implements _$BelongsToCollectionCopyWith<$Res> {
  __$BelongsToCollectionCopyWithImpl(this._self, this._then);

  final _BelongsToCollection _self;
  final $Res Function(_BelongsToCollection) _then;

/// Create a copy of BelongsToCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? posterPath = null,Object? backdropPath = null,}) {
  return _then(_BelongsToCollection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,backdropPath: null == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
