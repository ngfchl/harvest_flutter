// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_show_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TvShowDetail {

 bool get adult;@JsonKey(name: 'backdrop_path') String? get backdropPath;@JsonKey(name: 'created_by') List<dynamic> get createdBy;@JsonKey(name: 'episode_run_time') List<dynamic> get episodeRunTime;@JsonKey(name: 'first_air_date') String? get releaseDate; List<Genre> get genres; String? get homepage; int get id; String? get imdbId;@JsonKey(includeFromJson: false, includeToJson: false) String get mediaType;@JsonKey(name: 'in_production') bool get inProduction; List<dynamic> get languages;@JsonKey(name: 'last_air_date') String? get lastAirDate;@JsonKey(name: 'last_episode_to_air') LastEpisodeToAir? get lastEpisodeToAir;@JsonKey(name: 'name') String get title;@JsonKey(name: 'next_episode_to_air') dynamic get nextEpisodeToAir; List<Network> get networks;@JsonKey(name: 'number_of_episodes') int get numberOfEpisodes;@JsonKey(name: 'number_of_seasons') int get numberOfSeasons;@JsonKey(name: 'origin_country') List<String> get originCountry;@JsonKey(name: 'original_language') String get originalLanguage;@JsonKey(name: 'original_name') String get originalTitle; String get overview; double get popularity;@JsonKey(name: 'poster_path') String? get posterPath;@JsonKey(name: 'production_companies') List<ProductionCompany> get productionCompanies;@JsonKey(name: 'production_countries') List<ProductionCountry> get productionCountries; List<Season> get seasons;@JsonKey(name: 'spoken_languages') List<dynamic> get spokenLanguages; String get status; String get tagline; String get type;@JsonKey(name: 'vote_average') double get voteAverage;@JsonKey(name: 'vote_count') int get voteCount;
/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TvShowDetailCopyWith<TvShowDetail> get copyWith => _$TvShowDetailCopyWithImpl<TvShowDetail>(this as TvShowDetail, _$identity);

  /// Serializes this TvShowDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TvShowDetail&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&const DeepCollectionEquality().equals(other.createdBy, createdBy)&&const DeepCollectionEquality().equals(other.episodeRunTime, episodeRunTime)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.homepage, homepage) || other.homepage == homepage)&&(identical(other.id, id) || other.id == id)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.inProduction, inProduction) || other.inProduction == inProduction)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.lastAirDate, lastAirDate) || other.lastAirDate == lastAirDate)&&(identical(other.lastEpisodeToAir, lastEpisodeToAir) || other.lastEpisodeToAir == lastEpisodeToAir)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.nextEpisodeToAir, nextEpisodeToAir)&&const DeepCollectionEquality().equals(other.networks, networks)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&(identical(other.numberOfSeasons, numberOfSeasons) || other.numberOfSeasons == numberOfSeasons)&&const DeepCollectionEquality().equals(other.originCountry, originCountry)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&const DeepCollectionEquality().equals(other.productionCompanies, productionCompanies)&&const DeepCollectionEquality().equals(other.productionCountries, productionCountries)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&const DeepCollectionEquality().equals(other.spokenLanguages, spokenLanguages)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.type, type) || other.type == type)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,adult,backdropPath,const DeepCollectionEquality().hash(createdBy),const DeepCollectionEquality().hash(episodeRunTime),releaseDate,const DeepCollectionEquality().hash(genres),homepage,id,imdbId,mediaType,inProduction,const DeepCollectionEquality().hash(languages),lastAirDate,lastEpisodeToAir,title,const DeepCollectionEquality().hash(nextEpisodeToAir),const DeepCollectionEquality().hash(networks),numberOfEpisodes,numberOfSeasons,const DeepCollectionEquality().hash(originCountry),originalLanguage,originalTitle,overview,popularity,posterPath,const DeepCollectionEquality().hash(productionCompanies),const DeepCollectionEquality().hash(productionCountries),const DeepCollectionEquality().hash(seasons),const DeepCollectionEquality().hash(spokenLanguages),status,tagline,type,voteAverage,voteCount]);

@override
String toString() {
  return 'TvShowDetail(adult: $adult, backdropPath: $backdropPath, createdBy: $createdBy, episodeRunTime: $episodeRunTime, releaseDate: $releaseDate, genres: $genres, homepage: $homepage, id: $id, imdbId: $imdbId, mediaType: $mediaType, inProduction: $inProduction, languages: $languages, lastAirDate: $lastAirDate, lastEpisodeToAir: $lastEpisodeToAir, title: $title, nextEpisodeToAir: $nextEpisodeToAir, networks: $networks, numberOfEpisodes: $numberOfEpisodes, numberOfSeasons: $numberOfSeasons, originCountry: $originCountry, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, productionCompanies: $productionCompanies, productionCountries: $productionCountries, seasons: $seasons, spokenLanguages: $spokenLanguages, status: $status, tagline: $tagline, type: $type, voteAverage: $voteAverage, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class $TvShowDetailCopyWith<$Res>  {
  factory $TvShowDetailCopyWith(TvShowDetail value, $Res Function(TvShowDetail) _then) = _$TvShowDetailCopyWithImpl;
@useResult
$Res call({
 bool adult,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'created_by') List<dynamic> createdBy,@JsonKey(name: 'episode_run_time') List<dynamic> episodeRunTime,@JsonKey(name: 'first_air_date') String? releaseDate, List<Genre> genres, String? homepage, int id, String? imdbId,@JsonKey(includeFromJson: false, includeToJson: false) String mediaType,@JsonKey(name: 'in_production') bool inProduction, List<dynamic> languages,@JsonKey(name: 'last_air_date') String? lastAirDate,@JsonKey(name: 'last_episode_to_air') LastEpisodeToAir? lastEpisodeToAir,@JsonKey(name: 'name') String title,@JsonKey(name: 'next_episode_to_air') dynamic nextEpisodeToAir, List<Network> networks,@JsonKey(name: 'number_of_episodes') int numberOfEpisodes,@JsonKey(name: 'number_of_seasons') int numberOfSeasons,@JsonKey(name: 'origin_country') List<String> originCountry,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'original_name') String originalTitle, String overview, double popularity,@JsonKey(name: 'poster_path') String? posterPath,@JsonKey(name: 'production_companies') List<ProductionCompany> productionCompanies,@JsonKey(name: 'production_countries') List<ProductionCountry> productionCountries, List<Season> seasons,@JsonKey(name: 'spoken_languages') List<dynamic> spokenLanguages, String status, String tagline, String type,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount
});


$LastEpisodeToAirCopyWith<$Res>? get lastEpisodeToAir;

}
/// @nodoc
class _$TvShowDetailCopyWithImpl<$Res>
    implements $TvShowDetailCopyWith<$Res> {
  _$TvShowDetailCopyWithImpl(this._self, this._then);

  final TvShowDetail _self;
  final $Res Function(TvShowDetail) _then;

/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adult = null,Object? backdropPath = freezed,Object? createdBy = null,Object? episodeRunTime = null,Object? releaseDate = freezed,Object? genres = null,Object? homepage = freezed,Object? id = null,Object? imdbId = freezed,Object? mediaType = null,Object? inProduction = null,Object? languages = null,Object? lastAirDate = freezed,Object? lastEpisodeToAir = freezed,Object? title = null,Object? nextEpisodeToAir = freezed,Object? networks = null,Object? numberOfEpisodes = null,Object? numberOfSeasons = null,Object? originCountry = null,Object? originalLanguage = null,Object? originalTitle = null,Object? overview = null,Object? popularity = null,Object? posterPath = freezed,Object? productionCompanies = null,Object? productionCountries = null,Object? seasons = null,Object? spokenLanguages = null,Object? status = null,Object? tagline = null,Object? type = null,Object? voteAverage = null,Object? voteCount = null,}) {
  return _then(_self.copyWith(
adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as List<dynamic>,episodeRunTime: null == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as List<dynamic>,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,homepage: freezed == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,inProduction: null == inProduction ? _self.inProduction : inProduction // ignore: cast_nullable_to_non_nullable
as bool,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<dynamic>,lastAirDate: freezed == lastAirDate ? _self.lastAirDate : lastAirDate // ignore: cast_nullable_to_non_nullable
as String?,lastEpisodeToAir: freezed == lastEpisodeToAir ? _self.lastEpisodeToAir : lastEpisodeToAir // ignore: cast_nullable_to_non_nullable
as LastEpisodeToAir?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,nextEpisodeToAir: freezed == nextEpisodeToAir ? _self.nextEpisodeToAir : nextEpisodeToAir // ignore: cast_nullable_to_non_nullable
as dynamic,networks: null == networks ? _self.networks : networks // ignore: cast_nullable_to_non_nullable
as List<Network>,numberOfEpisodes: null == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int,numberOfSeasons: null == numberOfSeasons ? _self.numberOfSeasons : numberOfSeasons // ignore: cast_nullable_to_non_nullable
as int,originCountry: null == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,productionCompanies: null == productionCompanies ? _self.productionCompanies : productionCompanies // ignore: cast_nullable_to_non_nullable
as List<ProductionCompany>,productionCountries: null == productionCountries ? _self.productionCountries : productionCountries // ignore: cast_nullable_to_non_nullable
as List<ProductionCountry>,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,spokenLanguages: null == spokenLanguages ? _self.spokenLanguages : spokenLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastEpisodeToAirCopyWith<$Res>? get lastEpisodeToAir {
    if (_self.lastEpisodeToAir == null) {
    return null;
  }

  return $LastEpisodeToAirCopyWith<$Res>(_self.lastEpisodeToAir!, (value) {
    return _then(_self.copyWith(lastEpisodeToAir: value));
  });
}
}


/// Adds pattern-matching-related methods to [TvShowDetail].
extension TvShowDetailPatterns on TvShowDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TvShowDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TvShowDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TvShowDetail value)  $default,){
final _that = this;
switch (_that) {
case _TvShowDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TvShowDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TvShowDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool adult, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'created_by')  List<dynamic> createdBy, @JsonKey(name: 'episode_run_time')  List<dynamic> episodeRunTime, @JsonKey(name: 'first_air_date')  String? releaseDate,  List<Genre> genres,  String? homepage,  int id,  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'in_production')  bool inProduction,  List<dynamic> languages, @JsonKey(name: 'last_air_date')  String? lastAirDate, @JsonKey(name: 'last_episode_to_air')  LastEpisodeToAir? lastEpisodeToAir, @JsonKey(name: 'name')  String title, @JsonKey(name: 'next_episode_to_air')  dynamic nextEpisodeToAir,  List<Network> networks, @JsonKey(name: 'number_of_episodes')  int numberOfEpisodes, @JsonKey(name: 'number_of_seasons')  int numberOfSeasons, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_name')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String? posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries,  List<Season> seasons, @JsonKey(name: 'spoken_languages')  List<dynamic> spokenLanguages,  String status,  String tagline,  String type, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TvShowDetail() when $default != null:
return $default(_that.adult,_that.backdropPath,_that.createdBy,_that.episodeRunTime,_that.releaseDate,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.inProduction,_that.languages,_that.lastAirDate,_that.lastEpisodeToAir,_that.title,_that.nextEpisodeToAir,_that.networks,_that.numberOfEpisodes,_that.numberOfSeasons,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.seasons,_that.spokenLanguages,_that.status,_that.tagline,_that.type,_that.voteAverage,_that.voteCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool adult, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'created_by')  List<dynamic> createdBy, @JsonKey(name: 'episode_run_time')  List<dynamic> episodeRunTime, @JsonKey(name: 'first_air_date')  String? releaseDate,  List<Genre> genres,  String? homepage,  int id,  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'in_production')  bool inProduction,  List<dynamic> languages, @JsonKey(name: 'last_air_date')  String? lastAirDate, @JsonKey(name: 'last_episode_to_air')  LastEpisodeToAir? lastEpisodeToAir, @JsonKey(name: 'name')  String title, @JsonKey(name: 'next_episode_to_air')  dynamic nextEpisodeToAir,  List<Network> networks, @JsonKey(name: 'number_of_episodes')  int numberOfEpisodes, @JsonKey(name: 'number_of_seasons')  int numberOfSeasons, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_name')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String? posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries,  List<Season> seasons, @JsonKey(name: 'spoken_languages')  List<dynamic> spokenLanguages,  String status,  String tagline,  String type, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)  $default,) {final _that = this;
switch (_that) {
case _TvShowDetail():
return $default(_that.adult,_that.backdropPath,_that.createdBy,_that.episodeRunTime,_that.releaseDate,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.inProduction,_that.languages,_that.lastAirDate,_that.lastEpisodeToAir,_that.title,_that.nextEpisodeToAir,_that.networks,_that.numberOfEpisodes,_that.numberOfSeasons,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.seasons,_that.spokenLanguages,_that.status,_that.tagline,_that.type,_that.voteAverage,_that.voteCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool adult, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'created_by')  List<dynamic> createdBy, @JsonKey(name: 'episode_run_time')  List<dynamic> episodeRunTime, @JsonKey(name: 'first_air_date')  String? releaseDate,  List<Genre> genres,  String? homepage,  int id,  String? imdbId, @JsonKey(includeFromJson: false, includeToJson: false)  String mediaType, @JsonKey(name: 'in_production')  bool inProduction,  List<dynamic> languages, @JsonKey(name: 'last_air_date')  String? lastAirDate, @JsonKey(name: 'last_episode_to_air')  LastEpisodeToAir? lastEpisodeToAir, @JsonKey(name: 'name')  String title, @JsonKey(name: 'next_episode_to_air')  dynamic nextEpisodeToAir,  List<Network> networks, @JsonKey(name: 'number_of_episodes')  int numberOfEpisodes, @JsonKey(name: 'number_of_seasons')  int numberOfSeasons, @JsonKey(name: 'origin_country')  List<String> originCountry, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'original_name')  String originalTitle,  String overview,  double popularity, @JsonKey(name: 'poster_path')  String? posterPath, @JsonKey(name: 'production_companies')  List<ProductionCompany> productionCompanies, @JsonKey(name: 'production_countries')  List<ProductionCountry> productionCountries,  List<Season> seasons, @JsonKey(name: 'spoken_languages')  List<dynamic> spokenLanguages,  String status,  String tagline,  String type, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount)?  $default,) {final _that = this;
switch (_that) {
case _TvShowDetail() when $default != null:
return $default(_that.adult,_that.backdropPath,_that.createdBy,_that.episodeRunTime,_that.releaseDate,_that.genres,_that.homepage,_that.id,_that.imdbId,_that.mediaType,_that.inProduction,_that.languages,_that.lastAirDate,_that.lastEpisodeToAir,_that.title,_that.nextEpisodeToAir,_that.networks,_that.numberOfEpisodes,_that.numberOfSeasons,_that.originCountry,_that.originalLanguage,_that.originalTitle,_that.overview,_that.popularity,_that.posterPath,_that.productionCompanies,_that.productionCountries,_that.seasons,_that.spokenLanguages,_that.status,_that.tagline,_that.type,_that.voteAverage,_that.voteCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TvShowDetail extends TvShowDetail {
  const _TvShowDetail({this.adult = false, @JsonKey(name: 'backdrop_path') this.backdropPath, @JsonKey(name: 'created_by') final  List<dynamic> createdBy = const [], @JsonKey(name: 'episode_run_time') final  List<dynamic> episodeRunTime = const [], @JsonKey(name: 'first_air_date') this.releaseDate = '', final  List<Genre> genres = const [], this.homepage, this.id = 0, this.imdbId, @JsonKey(includeFromJson: false, includeToJson: false) this.mediaType = 'tv', @JsonKey(name: 'in_production') this.inProduction = false, final  List<dynamic> languages = const [], @JsonKey(name: 'last_air_date') this.lastAirDate, @JsonKey(name: 'last_episode_to_air') this.lastEpisodeToAir, @JsonKey(name: 'name') this.title = '', @JsonKey(name: 'next_episode_to_air') this.nextEpisodeToAir, final  List<Network> networks = const [], @JsonKey(name: 'number_of_episodes') this.numberOfEpisodes = 0, @JsonKey(name: 'number_of_seasons') this.numberOfSeasons = 0, @JsonKey(name: 'origin_country') final  List<String> originCountry = const [], @JsonKey(name: 'original_language') this.originalLanguage = '', @JsonKey(name: 'original_name') this.originalTitle = '', this.overview = '', this.popularity = 0.0, @JsonKey(name: 'poster_path') this.posterPath = '', @JsonKey(name: 'production_companies') final  List<ProductionCompany> productionCompanies = const [], @JsonKey(name: 'production_countries') final  List<ProductionCountry> productionCountries = const [], final  List<Season> seasons = const [], @JsonKey(name: 'spoken_languages') final  List<dynamic> spokenLanguages = const [], this.status = '', this.tagline = '', this.type = '', @JsonKey(name: 'vote_average') this.voteAverage = 0.0, @JsonKey(name: 'vote_count') this.voteCount = 0}): _createdBy = createdBy,_episodeRunTime = episodeRunTime,_genres = genres,_languages = languages,_networks = networks,_originCountry = originCountry,_productionCompanies = productionCompanies,_productionCountries = productionCountries,_seasons = seasons,_spokenLanguages = spokenLanguages,super._();
  factory _TvShowDetail.fromJson(Map<String, dynamic> json) => _$TvShowDetailFromJson(json);

@override@JsonKey() final  bool adult;
@override@JsonKey(name: 'backdrop_path') final  String? backdropPath;
 final  List<dynamic> _createdBy;
@override@JsonKey(name: 'created_by') List<dynamic> get createdBy {
  if (_createdBy is EqualUnmodifiableListView) return _createdBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_createdBy);
}

 final  List<dynamic> _episodeRunTime;
@override@JsonKey(name: 'episode_run_time') List<dynamic> get episodeRunTime {
  if (_episodeRunTime is EqualUnmodifiableListView) return _episodeRunTime;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_episodeRunTime);
}

@override@JsonKey(name: 'first_air_date') final  String? releaseDate;
 final  List<Genre> _genres;
@override@JsonKey() List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  String? homepage;
@override@JsonKey() final  int id;
@override final  String? imdbId;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  String mediaType;
@override@JsonKey(name: 'in_production') final  bool inProduction;
 final  List<dynamic> _languages;
@override@JsonKey() List<dynamic> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

@override@JsonKey(name: 'last_air_date') final  String? lastAirDate;
@override@JsonKey(name: 'last_episode_to_air') final  LastEpisodeToAir? lastEpisodeToAir;
@override@JsonKey(name: 'name') final  String title;
@override@JsonKey(name: 'next_episode_to_air') final  dynamic nextEpisodeToAir;
 final  List<Network> _networks;
@override@JsonKey() List<Network> get networks {
  if (_networks is EqualUnmodifiableListView) return _networks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_networks);
}

@override@JsonKey(name: 'number_of_episodes') final  int numberOfEpisodes;
@override@JsonKey(name: 'number_of_seasons') final  int numberOfSeasons;
 final  List<String> _originCountry;
@override@JsonKey(name: 'origin_country') List<String> get originCountry {
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_originCountry);
}

@override@JsonKey(name: 'original_language') final  String originalLanguage;
@override@JsonKey(name: 'original_name') final  String originalTitle;
@override@JsonKey() final  String overview;
@override@JsonKey() final  double popularity;
@override@JsonKey(name: 'poster_path') final  String? posterPath;
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

 final  List<Season> _seasons;
@override@JsonKey() List<Season> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

 final  List<dynamic> _spokenLanguages;
@override@JsonKey(name: 'spoken_languages') List<dynamic> get spokenLanguages {
  if (_spokenLanguages is EqualUnmodifiableListView) return _spokenLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spokenLanguages);
}

@override@JsonKey() final  String status;
@override@JsonKey() final  String tagline;
@override@JsonKey() final  String type;
@override@JsonKey(name: 'vote_average') final  double voteAverage;
@override@JsonKey(name: 'vote_count') final  int voteCount;

/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TvShowDetailCopyWith<_TvShowDetail> get copyWith => __$TvShowDetailCopyWithImpl<_TvShowDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TvShowDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TvShowDetail&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&const DeepCollectionEquality().equals(other._createdBy, _createdBy)&&const DeepCollectionEquality().equals(other._episodeRunTime, _episodeRunTime)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.homepage, homepage) || other.homepage == homepage)&&(identical(other.id, id) || other.id == id)&&(identical(other.imdbId, imdbId) || other.imdbId == imdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.inProduction, inProduction) || other.inProduction == inProduction)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.lastAirDate, lastAirDate) || other.lastAirDate == lastAirDate)&&(identical(other.lastEpisodeToAir, lastEpisodeToAir) || other.lastEpisodeToAir == lastEpisodeToAir)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.nextEpisodeToAir, nextEpisodeToAir)&&const DeepCollectionEquality().equals(other._networks, _networks)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&(identical(other.numberOfSeasons, numberOfSeasons) || other.numberOfSeasons == numberOfSeasons)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&const DeepCollectionEquality().equals(other._productionCompanies, _productionCompanies)&&const DeepCollectionEquality().equals(other._productionCountries, _productionCountries)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&const DeepCollectionEquality().equals(other._spokenLanguages, _spokenLanguages)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.type, type) || other.type == type)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,adult,backdropPath,const DeepCollectionEquality().hash(_createdBy),const DeepCollectionEquality().hash(_episodeRunTime),releaseDate,const DeepCollectionEquality().hash(_genres),homepage,id,imdbId,mediaType,inProduction,const DeepCollectionEquality().hash(_languages),lastAirDate,lastEpisodeToAir,title,const DeepCollectionEquality().hash(nextEpisodeToAir),const DeepCollectionEquality().hash(_networks),numberOfEpisodes,numberOfSeasons,const DeepCollectionEquality().hash(_originCountry),originalLanguage,originalTitle,overview,popularity,posterPath,const DeepCollectionEquality().hash(_productionCompanies),const DeepCollectionEquality().hash(_productionCountries),const DeepCollectionEquality().hash(_seasons),const DeepCollectionEquality().hash(_spokenLanguages),status,tagline,type,voteAverage,voteCount]);

@override
String toString() {
  return 'TvShowDetail(adult: $adult, backdropPath: $backdropPath, createdBy: $createdBy, episodeRunTime: $episodeRunTime, releaseDate: $releaseDate, genres: $genres, homepage: $homepage, id: $id, imdbId: $imdbId, mediaType: $mediaType, inProduction: $inProduction, languages: $languages, lastAirDate: $lastAirDate, lastEpisodeToAir: $lastEpisodeToAir, title: $title, nextEpisodeToAir: $nextEpisodeToAir, networks: $networks, numberOfEpisodes: $numberOfEpisodes, numberOfSeasons: $numberOfSeasons, originCountry: $originCountry, originalLanguage: $originalLanguage, originalTitle: $originalTitle, overview: $overview, popularity: $popularity, posterPath: $posterPath, productionCompanies: $productionCompanies, productionCountries: $productionCountries, seasons: $seasons, spokenLanguages: $spokenLanguages, status: $status, tagline: $tagline, type: $type, voteAverage: $voteAverage, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class _$TvShowDetailCopyWith<$Res> implements $TvShowDetailCopyWith<$Res> {
  factory _$TvShowDetailCopyWith(_TvShowDetail value, $Res Function(_TvShowDetail) _then) = __$TvShowDetailCopyWithImpl;
@override @useResult
$Res call({
 bool adult,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'created_by') List<dynamic> createdBy,@JsonKey(name: 'episode_run_time') List<dynamic> episodeRunTime,@JsonKey(name: 'first_air_date') String? releaseDate, List<Genre> genres, String? homepage, int id, String? imdbId,@JsonKey(includeFromJson: false, includeToJson: false) String mediaType,@JsonKey(name: 'in_production') bool inProduction, List<dynamic> languages,@JsonKey(name: 'last_air_date') String? lastAirDate,@JsonKey(name: 'last_episode_to_air') LastEpisodeToAir? lastEpisodeToAir,@JsonKey(name: 'name') String title,@JsonKey(name: 'next_episode_to_air') dynamic nextEpisodeToAir, List<Network> networks,@JsonKey(name: 'number_of_episodes') int numberOfEpisodes,@JsonKey(name: 'number_of_seasons') int numberOfSeasons,@JsonKey(name: 'origin_country') List<String> originCountry,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'original_name') String originalTitle, String overview, double popularity,@JsonKey(name: 'poster_path') String? posterPath,@JsonKey(name: 'production_companies') List<ProductionCompany> productionCompanies,@JsonKey(name: 'production_countries') List<ProductionCountry> productionCountries, List<Season> seasons,@JsonKey(name: 'spoken_languages') List<dynamic> spokenLanguages, String status, String tagline, String type,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount
});


@override $LastEpisodeToAirCopyWith<$Res>? get lastEpisodeToAir;

}
/// @nodoc
class __$TvShowDetailCopyWithImpl<$Res>
    implements _$TvShowDetailCopyWith<$Res> {
  __$TvShowDetailCopyWithImpl(this._self, this._then);

  final _TvShowDetail _self;
  final $Res Function(_TvShowDetail) _then;

/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adult = null,Object? backdropPath = freezed,Object? createdBy = null,Object? episodeRunTime = null,Object? releaseDate = freezed,Object? genres = null,Object? homepage = freezed,Object? id = null,Object? imdbId = freezed,Object? mediaType = null,Object? inProduction = null,Object? languages = null,Object? lastAirDate = freezed,Object? lastEpisodeToAir = freezed,Object? title = null,Object? nextEpisodeToAir = freezed,Object? networks = null,Object? numberOfEpisodes = null,Object? numberOfSeasons = null,Object? originCountry = null,Object? originalLanguage = null,Object? originalTitle = null,Object? overview = null,Object? popularity = null,Object? posterPath = freezed,Object? productionCompanies = null,Object? productionCountries = null,Object? seasons = null,Object? spokenLanguages = null,Object? status = null,Object? tagline = null,Object? type = null,Object? voteAverage = null,Object? voteCount = null,}) {
  return _then(_TvShowDetail(
adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,createdBy: null == createdBy ? _self._createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as List<dynamic>,episodeRunTime: null == episodeRunTime ? _self._episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as List<dynamic>,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,homepage: freezed == homepage ? _self.homepage : homepage // ignore: cast_nullable_to_non_nullable
as String?,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,imdbId: freezed == imdbId ? _self.imdbId : imdbId // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,inProduction: null == inProduction ? _self.inProduction : inProduction // ignore: cast_nullable_to_non_nullable
as bool,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<dynamic>,lastAirDate: freezed == lastAirDate ? _self.lastAirDate : lastAirDate // ignore: cast_nullable_to_non_nullable
as String?,lastEpisodeToAir: freezed == lastEpisodeToAir ? _self.lastEpisodeToAir : lastEpisodeToAir // ignore: cast_nullable_to_non_nullable
as LastEpisodeToAir?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,nextEpisodeToAir: freezed == nextEpisodeToAir ? _self.nextEpisodeToAir : nextEpisodeToAir // ignore: cast_nullable_to_non_nullable
as dynamic,networks: null == networks ? _self._networks : networks // ignore: cast_nullable_to_non_nullable
as List<Network>,numberOfEpisodes: null == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int,numberOfSeasons: null == numberOfSeasons ? _self.numberOfSeasons : numberOfSeasons // ignore: cast_nullable_to_non_nullable
as int,originCountry: null == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,originalTitle: null == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,productionCompanies: null == productionCompanies ? _self._productionCompanies : productionCompanies // ignore: cast_nullable_to_non_nullable
as List<ProductionCompany>,productionCountries: null == productionCountries ? _self._productionCountries : productionCountries // ignore: cast_nullable_to_non_nullable
as List<ProductionCountry>,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,spokenLanguages: null == spokenLanguages ? _self._spokenLanguages : spokenLanguages // ignore: cast_nullable_to_non_nullable
as List<dynamic>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,tagline: null == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of TvShowDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LastEpisodeToAirCopyWith<$Res>? get lastEpisodeToAir {
    if (_self.lastEpisodeToAir == null) {
    return null;
  }

  return $LastEpisodeToAirCopyWith<$Res>(_self.lastEpisodeToAir!, (value) {
    return _then(_self.copyWith(lastEpisodeToAir: value));
  });
}
}


/// @nodoc
mixin _$Season {

@JsonKey(name: 'air_date') String get airDate;@JsonKey(name: 'episode_count') int get episodeCount; int get id; String get name; String get overview;@JsonKey(name: 'poster_path') String get posterPath;@JsonKey(name: 'season_number') int get seasonNumber;@JsonKey(name: 'vote_average') double get voteAverage;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,airDate,episodeCount,id,name,overview,posterPath,seasonNumber,voteAverage);

@override
String toString() {
  return 'Season(airDate: $airDate, episodeCount: $episodeCount, id: $id, name: $name, overview: $overview, posterPath: $posterPath, seasonNumber: $seasonNumber, voteAverage: $voteAverage)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'air_date') String airDate,@JsonKey(name: 'episode_count') int episodeCount, int id, String name, String overview,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'season_number') int seasonNumber,@JsonKey(name: 'vote_average') double voteAverage
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? airDate = null,Object? episodeCount = null,Object? id = null,Object? name = null,Object? overview = null,Object? posterPath = null,Object? seasonNumber = null,Object? voteAverage = null,}) {
  return _then(_self.copyWith(
airDate: null == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_count')  int episodeCount,  int id,  String name,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'vote_average')  double voteAverage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.airDate,_that.episodeCount,_that.id,_that.name,_that.overview,_that.posterPath,_that.seasonNumber,_that.voteAverage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_count')  int episodeCount,  int id,  String name,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'vote_average')  double voteAverage)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.airDate,_that.episodeCount,_that.id,_that.name,_that.overview,_that.posterPath,_that.seasonNumber,_that.voteAverage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_count')  int episodeCount,  int id,  String name,  String overview, @JsonKey(name: 'poster_path')  String posterPath, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'vote_average')  double voteAverage)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.airDate,_that.episodeCount,_that.id,_that.name,_that.overview,_that.posterPath,_that.seasonNumber,_that.voteAverage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season implements Season {
  const _Season({@JsonKey(name: 'air_date') this.airDate = '', @JsonKey(name: 'episode_count') this.episodeCount = 0, this.id = 0, this.name = '', this.overview = '', @JsonKey(name: 'poster_path') this.posterPath = '', @JsonKey(name: 'season_number') this.seasonNumber = 0, @JsonKey(name: 'vote_average') this.voteAverage = 0.0});
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override@JsonKey(name: 'air_date') final  String airDate;
@override@JsonKey(name: 'episode_count') final  int episodeCount;
@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String overview;
@override@JsonKey(name: 'poster_path') final  String posterPath;
@override@JsonKey(name: 'season_number') final  int seasonNumber;
@override@JsonKey(name: 'vote_average') final  double voteAverage;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,airDate,episodeCount,id,name,overview,posterPath,seasonNumber,voteAverage);

@override
String toString() {
  return 'Season(airDate: $airDate, episodeCount: $episodeCount, id: $id, name: $name, overview: $overview, posterPath: $posterPath, seasonNumber: $seasonNumber, voteAverage: $voteAverage)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'air_date') String airDate,@JsonKey(name: 'episode_count') int episodeCount, int id, String name, String overview,@JsonKey(name: 'poster_path') String posterPath,@JsonKey(name: 'season_number') int seasonNumber,@JsonKey(name: 'vote_average') double voteAverage
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? airDate = null,Object? episodeCount = null,Object? id = null,Object? name = null,Object? overview = null,Object? posterPath = null,Object? seasonNumber = null,Object? voteAverage = null,}) {
  return _then(_Season(
airDate: null == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,posterPath: null == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$LastEpisodeToAir {

 int get id; String get name; String get overview;@JsonKey(name: 'vote_average') double get voteAverage;@JsonKey(name: 'vote_count') int get voteCount;@JsonKey(name: 'air_date') String get airDate;@JsonKey(name: 'episode_number') int get episodeNumber;@JsonKey(name: 'episode_type') String get episodeType;@JsonKey(name: 'production_code') String get productionCode; dynamic get runtime;@JsonKey(name: 'season_number') int get seasonNumber;@JsonKey(name: 'show_id') int get showId;@JsonKey(name: 'still_path') dynamic get stillPath;
/// Create a copy of LastEpisodeToAir
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LastEpisodeToAirCopyWith<LastEpisodeToAir> get copyWith => _$LastEpisodeToAirCopyWithImpl<LastEpisodeToAir>(this as LastEpisodeToAir, _$identity);

  /// Serializes this LastEpisodeToAir to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LastEpisodeToAir&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeNumber, episodeNumber) || other.episodeNumber == episodeNumber)&&(identical(other.episodeType, episodeType) || other.episodeType == episodeType)&&(identical(other.productionCode, productionCode) || other.productionCode == productionCode)&&const DeepCollectionEquality().equals(other.runtime, runtime)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.showId, showId) || other.showId == showId)&&const DeepCollectionEquality().equals(other.stillPath, stillPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,overview,voteAverage,voteCount,airDate,episodeNumber,episodeType,productionCode,const DeepCollectionEquality().hash(runtime),seasonNumber,showId,const DeepCollectionEquality().hash(stillPath));

@override
String toString() {
  return 'LastEpisodeToAir(id: $id, name: $name, overview: $overview, voteAverage: $voteAverage, voteCount: $voteCount, airDate: $airDate, episodeNumber: $episodeNumber, episodeType: $episodeType, productionCode: $productionCode, runtime: $runtime, seasonNumber: $seasonNumber, showId: $showId, stillPath: $stillPath)';
}


}

/// @nodoc
abstract mixin class $LastEpisodeToAirCopyWith<$Res>  {
  factory $LastEpisodeToAirCopyWith(LastEpisodeToAir value, $Res Function(LastEpisodeToAir) _then) = _$LastEpisodeToAirCopyWithImpl;
@useResult
$Res call({
 int id, String name, String overview,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount,@JsonKey(name: 'air_date') String airDate,@JsonKey(name: 'episode_number') int episodeNumber,@JsonKey(name: 'episode_type') String episodeType,@JsonKey(name: 'production_code') String productionCode, dynamic runtime,@JsonKey(name: 'season_number') int seasonNumber,@JsonKey(name: 'show_id') int showId,@JsonKey(name: 'still_path') dynamic stillPath
});




}
/// @nodoc
class _$LastEpisodeToAirCopyWithImpl<$Res>
    implements $LastEpisodeToAirCopyWith<$Res> {
  _$LastEpisodeToAirCopyWithImpl(this._self, this._then);

  final LastEpisodeToAir _self;
  final $Res Function(LastEpisodeToAir) _then;

/// Create a copy of LastEpisodeToAir
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? overview = null,Object? voteAverage = null,Object? voteCount = null,Object? airDate = null,Object? episodeNumber = null,Object? episodeType = null,Object? productionCode = null,Object? runtime = freezed,Object? seasonNumber = null,Object? showId = null,Object? stillPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,airDate: null == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String,episodeNumber: null == episodeNumber ? _self.episodeNumber : episodeNumber // ignore: cast_nullable_to_non_nullable
as int,episodeType: null == episodeType ? _self.episodeType : episodeType // ignore: cast_nullable_to_non_nullable
as String,productionCode: null == productionCode ? _self.productionCode : productionCode // ignore: cast_nullable_to_non_nullable
as String,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as dynamic,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,showId: null == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as int,stillPath: freezed == stillPath ? _self.stillPath : stillPath // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [LastEpisodeToAir].
extension LastEpisodeToAirPatterns on LastEpisodeToAir {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LastEpisodeToAir value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LastEpisodeToAir() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LastEpisodeToAir value)  $default,){
final _that = this;
switch (_that) {
case _LastEpisodeToAir():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LastEpisodeToAir value)?  $default,){
final _that = this;
switch (_that) {
case _LastEpisodeToAir() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String overview, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount, @JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_number')  int episodeNumber, @JsonKey(name: 'episode_type')  String episodeType, @JsonKey(name: 'production_code')  String productionCode,  dynamic runtime, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'show_id')  int showId, @JsonKey(name: 'still_path')  dynamic stillPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LastEpisodeToAir() when $default != null:
return $default(_that.id,_that.name,_that.overview,_that.voteAverage,_that.voteCount,_that.airDate,_that.episodeNumber,_that.episodeType,_that.productionCode,_that.runtime,_that.seasonNumber,_that.showId,_that.stillPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String overview, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount, @JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_number')  int episodeNumber, @JsonKey(name: 'episode_type')  String episodeType, @JsonKey(name: 'production_code')  String productionCode,  dynamic runtime, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'show_id')  int showId, @JsonKey(name: 'still_path')  dynamic stillPath)  $default,) {final _that = this;
switch (_that) {
case _LastEpisodeToAir():
return $default(_that.id,_that.name,_that.overview,_that.voteAverage,_that.voteCount,_that.airDate,_that.episodeNumber,_that.episodeType,_that.productionCode,_that.runtime,_that.seasonNumber,_that.showId,_that.stillPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String overview, @JsonKey(name: 'vote_average')  double voteAverage, @JsonKey(name: 'vote_count')  int voteCount, @JsonKey(name: 'air_date')  String airDate, @JsonKey(name: 'episode_number')  int episodeNumber, @JsonKey(name: 'episode_type')  String episodeType, @JsonKey(name: 'production_code')  String productionCode,  dynamic runtime, @JsonKey(name: 'season_number')  int seasonNumber, @JsonKey(name: 'show_id')  int showId, @JsonKey(name: 'still_path')  dynamic stillPath)?  $default,) {final _that = this;
switch (_that) {
case _LastEpisodeToAir() when $default != null:
return $default(_that.id,_that.name,_that.overview,_that.voteAverage,_that.voteCount,_that.airDate,_that.episodeNumber,_that.episodeType,_that.productionCode,_that.runtime,_that.seasonNumber,_that.showId,_that.stillPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LastEpisodeToAir implements LastEpisodeToAir {
  const _LastEpisodeToAir({this.id = 0, this.name = '', this.overview = '', @JsonKey(name: 'vote_average') this.voteAverage = 0.0, @JsonKey(name: 'vote_count') this.voteCount = 0, @JsonKey(name: 'air_date') this.airDate = '', @JsonKey(name: 'episode_number') this.episodeNumber = 0, @JsonKey(name: 'episode_type') this.episodeType = '', @JsonKey(name: 'production_code') this.productionCode = '', this.runtime, @JsonKey(name: 'season_number') this.seasonNumber = 0, @JsonKey(name: 'show_id') this.showId = 0, @JsonKey(name: 'still_path') this.stillPath});
  factory _LastEpisodeToAir.fromJson(Map<String, dynamic> json) => _$LastEpisodeToAirFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override@JsonKey() final  String overview;
@override@JsonKey(name: 'vote_average') final  double voteAverage;
@override@JsonKey(name: 'vote_count') final  int voteCount;
@override@JsonKey(name: 'air_date') final  String airDate;
@override@JsonKey(name: 'episode_number') final  int episodeNumber;
@override@JsonKey(name: 'episode_type') final  String episodeType;
@override@JsonKey(name: 'production_code') final  String productionCode;
@override final  dynamic runtime;
@override@JsonKey(name: 'season_number') final  int seasonNumber;
@override@JsonKey(name: 'show_id') final  int showId;
@override@JsonKey(name: 'still_path') final  dynamic stillPath;

/// Create a copy of LastEpisodeToAir
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LastEpisodeToAirCopyWith<_LastEpisodeToAir> get copyWith => __$LastEpisodeToAirCopyWithImpl<_LastEpisodeToAir>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LastEpisodeToAirToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LastEpisodeToAir&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.episodeNumber, episodeNumber) || other.episodeNumber == episodeNumber)&&(identical(other.episodeType, episodeType) || other.episodeType == episodeType)&&(identical(other.productionCode, productionCode) || other.productionCode == productionCode)&&const DeepCollectionEquality().equals(other.runtime, runtime)&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.showId, showId) || other.showId == showId)&&const DeepCollectionEquality().equals(other.stillPath, stillPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,overview,voteAverage,voteCount,airDate,episodeNumber,episodeType,productionCode,const DeepCollectionEquality().hash(runtime),seasonNumber,showId,const DeepCollectionEquality().hash(stillPath));

@override
String toString() {
  return 'LastEpisodeToAir(id: $id, name: $name, overview: $overview, voteAverage: $voteAverage, voteCount: $voteCount, airDate: $airDate, episodeNumber: $episodeNumber, episodeType: $episodeType, productionCode: $productionCode, runtime: $runtime, seasonNumber: $seasonNumber, showId: $showId, stillPath: $stillPath)';
}


}

/// @nodoc
abstract mixin class _$LastEpisodeToAirCopyWith<$Res> implements $LastEpisodeToAirCopyWith<$Res> {
  factory _$LastEpisodeToAirCopyWith(_LastEpisodeToAir value, $Res Function(_LastEpisodeToAir) _then) = __$LastEpisodeToAirCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String overview,@JsonKey(name: 'vote_average') double voteAverage,@JsonKey(name: 'vote_count') int voteCount,@JsonKey(name: 'air_date') String airDate,@JsonKey(name: 'episode_number') int episodeNumber,@JsonKey(name: 'episode_type') String episodeType,@JsonKey(name: 'production_code') String productionCode, dynamic runtime,@JsonKey(name: 'season_number') int seasonNumber,@JsonKey(name: 'show_id') int showId,@JsonKey(name: 'still_path') dynamic stillPath
});




}
/// @nodoc
class __$LastEpisodeToAirCopyWithImpl<$Res>
    implements _$LastEpisodeToAirCopyWith<$Res> {
  __$LastEpisodeToAirCopyWithImpl(this._self, this._then);

  final _LastEpisodeToAir _self;
  final $Res Function(_LastEpisodeToAir) _then;

/// Create a copy of LastEpisodeToAir
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? overview = null,Object? voteAverage = null,Object? voteCount = null,Object? airDate = null,Object? episodeNumber = null,Object? episodeType = null,Object? productionCode = null,Object? runtime = freezed,Object? seasonNumber = null,Object? showId = null,Object? stillPath = freezed,}) {
  return _then(_LastEpisodeToAir(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,airDate: null == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as String,episodeNumber: null == episodeNumber ? _self.episodeNumber : episodeNumber // ignore: cast_nullable_to_non_nullable
as int,episodeType: null == episodeType ? _self.episodeType : episodeType // ignore: cast_nullable_to_non_nullable
as String,productionCode: null == productionCode ? _self.productionCode : productionCode // ignore: cast_nullable_to_non_nullable
as String,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as dynamic,seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,showId: null == showId ? _self.showId : showId // ignore: cast_nullable_to_non_nullable
as int,stillPath: freezed == stillPath ? _self.stillPath : stillPath // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
