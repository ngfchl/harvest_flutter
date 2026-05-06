// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Person {

 int get id;@JsonKey(name: 'poster_path') String? get posterPath; bool get adult; double get popularity;@JsonKey(name: 'backdrop_path') String? get backdropPath;@JsonKey(name: 'vote_average') double? get voteAverage; String? get overview;@JsonKey(name: 'first_air_date') String? get firstAirDate;@JsonKey(name: 'origin_country') List<String>? get originCountry;@JsonKey(name: 'genre_ids') List<int>? get genreIds;@JsonKey(name: 'original_language') String? get originalLanguage;@JsonKey(name: 'vote_count') int? get voteCount; String get name;@JsonKey(name: 'original_name') String get originalName;@JsonKey(name: 'media_type') String get mediaType;@JsonKey(name: 'profile_path') String get profilePath;@JsonKey(name: 'known_for') List<KnownFor> get knownFor;@JsonKey(name: 'known_for_department') String get knownForDepartment; int get gender;
/// Create a copy of Person
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonCopyWith<Person> get copyWith => _$PersonCopyWithImpl<Person>(this as Person, _$identity);

  /// Serializes this Person to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Person&&(identical(other.id, id) || other.id == id)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other.originCountry, originCountry)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&const DeepCollectionEquality().equals(other.knownFor, knownFor)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,posterPath,adult,popularity,backdropPath,voteAverage,overview,firstAirDate,const DeepCollectionEquality().hash(originCountry),const DeepCollectionEquality().hash(genreIds),originalLanguage,voteCount,name,originalName,mediaType,profilePath,const DeepCollectionEquality().hash(knownFor),knownForDepartment,gender]);

@override
String toString() {
  return 'Person(id: $id, posterPath: $posterPath, adult: $adult, popularity: $popularity, backdropPath: $backdropPath, voteAverage: $voteAverage, overview: $overview, firstAirDate: $firstAirDate, originCountry: $originCountry, genreIds: $genreIds, originalLanguage: $originalLanguage, voteCount: $voteCount, name: $name, originalName: $originalName, mediaType: $mediaType, profilePath: $profilePath, knownFor: $knownFor, knownForDepartment: $knownForDepartment, gender: $gender)';
}


}

/// @nodoc
abstract mixin class $PersonCopyWith<$Res>  {
  factory $PersonCopyWith(Person value, $Res Function(Person) _then) = _$PersonCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'poster_path') String? posterPath, bool adult, double popularity,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'vote_average') double? voteAverage, String? overview,@JsonKey(name: 'first_air_date') String? firstAirDate,@JsonKey(name: 'origin_country') List<String>? originCountry,@JsonKey(name: 'genre_ids') List<int>? genreIds,@JsonKey(name: 'original_language') String? originalLanguage,@JsonKey(name: 'vote_count') int? voteCount, String name,@JsonKey(name: 'original_name') String originalName,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'profile_path') String profilePath,@JsonKey(name: 'known_for') List<KnownFor> knownFor,@JsonKey(name: 'known_for_department') String knownForDepartment, int gender
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? posterPath = freezed,Object? adult = null,Object? popularity = null,Object? backdropPath = freezed,Object? voteAverage = freezed,Object? overview = freezed,Object? firstAirDate = freezed,Object? originCountry = freezed,Object? genreIds = freezed,Object? originalLanguage = freezed,Object? voteCount = freezed,Object? name = null,Object? originalName = null,Object? mediaType = null,Object? profilePath = null,Object? knownFor = null,Object? knownForDepartment = null,Object? gender = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,originCountry: freezed == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,genreIds: freezed == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>?,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,profilePath: null == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String,knownFor: null == knownFor ? _self.knownFor : knownFor // ignore: cast_nullable_to_non_nullable
as List<KnownFor>,knownForDepartment: null == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double? voteAverage,  String? overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int>? genreIds, @JsonKey(name: 'original_language')  String? originalLanguage, @JsonKey(name: 'vote_count')  int? voteCount,  String name, @JsonKey(name: 'original_name')  String originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'profile_path')  String profilePath, @JsonKey(name: 'known_for')  List<KnownFor> knownFor, @JsonKey(name: 'known_for_department')  String knownForDepartment,  int gender)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.profilePath,_that.knownFor,_that.knownForDepartment,_that.gender);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double? voteAverage,  String? overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int>? genreIds, @JsonKey(name: 'original_language')  String? originalLanguage, @JsonKey(name: 'vote_count')  int? voteCount,  String name, @JsonKey(name: 'original_name')  String originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'profile_path')  String profilePath, @JsonKey(name: 'known_for')  List<KnownFor> knownFor, @JsonKey(name: 'known_for_department')  String knownForDepartment,  int gender)  $default,) {final _that = this;
switch (_that) {
case _Person():
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.profilePath,_that.knownFor,_that.knownForDepartment,_that.gender);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double? voteAverage,  String? overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int>? genreIds, @JsonKey(name: 'original_language')  String? originalLanguage, @JsonKey(name: 'vote_count')  int? voteCount,  String name, @JsonKey(name: 'original_name')  String originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'profile_path')  String profilePath, @JsonKey(name: 'known_for')  List<KnownFor> knownFor, @JsonKey(name: 'known_for_department')  String knownForDepartment,  int gender)?  $default,) {final _that = this;
switch (_that) {
case _Person() when $default != null:
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.profilePath,_that.knownFor,_that.knownForDepartment,_that.gender);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Person implements Person {
  const _Person({this.id = 0, @JsonKey(name: 'poster_path') this.posterPath, this.adult = false, this.popularity = 0.0, @JsonKey(name: 'backdrop_path') this.backdropPath, @JsonKey(name: 'vote_average') this.voteAverage = 0.0, this.overview, @JsonKey(name: 'first_air_date') this.firstAirDate, @JsonKey(name: 'origin_country') final  List<String>? originCountry = const [], @JsonKey(name: 'genre_ids') final  List<int>? genreIds = const [], @JsonKey(name: 'original_language') this.originalLanguage, @JsonKey(name: 'vote_count') this.voteCount, this.name = '', @JsonKey(name: 'original_name') this.originalName = '', @JsonKey(name: 'media_type') this.mediaType = '', @JsonKey(name: 'profile_path') this.profilePath = '', @JsonKey(name: 'known_for') final  List<KnownFor> knownFor = const [], @JsonKey(name: 'known_for_department') this.knownForDepartment = '', this.gender = 0}): _originCountry = originCountry,_genreIds = genreIds,_knownFor = knownFor;
  factory _Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey(name: 'poster_path') final  String? posterPath;
@override@JsonKey() final  bool adult;
@override@JsonKey() final  double popularity;
@override@JsonKey(name: 'backdrop_path') final  String? backdropPath;
@override@JsonKey(name: 'vote_average') final  double? voteAverage;
@override final  String? overview;
@override@JsonKey(name: 'first_air_date') final  String? firstAirDate;
 final  List<String>? _originCountry;
@override@JsonKey(name: 'origin_country') List<String>? get originCountry {
  final value = _originCountry;
  if (value == null) return null;
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int>? _genreIds;
@override@JsonKey(name: 'genre_ids') List<int>? get genreIds {
  final value = _genreIds;
  if (value == null) return null;
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'original_language') final  String? originalLanguage;
@override@JsonKey(name: 'vote_count') final  int? voteCount;
@override@JsonKey() final  String name;
@override@JsonKey(name: 'original_name') final  String originalName;
@override@JsonKey(name: 'media_type') final  String mediaType;
@override@JsonKey(name: 'profile_path') final  String profilePath;
 final  List<KnownFor> _knownFor;
@override@JsonKey(name: 'known_for') List<KnownFor> get knownFor {
  if (_knownFor is EqualUnmodifiableListView) return _knownFor;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_knownFor);
}

@override@JsonKey(name: 'known_for_department') final  String knownForDepartment;
@override@JsonKey() final  int gender;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Person&&(identical(other.id, id) || other.id == id)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&const DeepCollectionEquality().equals(other._knownFor, _knownFor)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment)&&(identical(other.gender, gender) || other.gender == gender));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,posterPath,adult,popularity,backdropPath,voteAverage,overview,firstAirDate,const DeepCollectionEquality().hash(_originCountry),const DeepCollectionEquality().hash(_genreIds),originalLanguage,voteCount,name,originalName,mediaType,profilePath,const DeepCollectionEquality().hash(_knownFor),knownForDepartment,gender]);

@override
String toString() {
  return 'Person(id: $id, posterPath: $posterPath, adult: $adult, popularity: $popularity, backdropPath: $backdropPath, voteAverage: $voteAverage, overview: $overview, firstAirDate: $firstAirDate, originCountry: $originCountry, genreIds: $genreIds, originalLanguage: $originalLanguage, voteCount: $voteCount, name: $name, originalName: $originalName, mediaType: $mediaType, profilePath: $profilePath, knownFor: $knownFor, knownForDepartment: $knownForDepartment, gender: $gender)';
}


}

/// @nodoc
abstract mixin class _$PersonCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$PersonCopyWith(_Person value, $Res Function(_Person) _then) = __$PersonCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'poster_path') String? posterPath, bool adult, double popularity,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'vote_average') double? voteAverage, String? overview,@JsonKey(name: 'first_air_date') String? firstAirDate,@JsonKey(name: 'origin_country') List<String>? originCountry,@JsonKey(name: 'genre_ids') List<int>? genreIds,@JsonKey(name: 'original_language') String? originalLanguage,@JsonKey(name: 'vote_count') int? voteCount, String name,@JsonKey(name: 'original_name') String originalName,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'profile_path') String profilePath,@JsonKey(name: 'known_for') List<KnownFor> knownFor,@JsonKey(name: 'known_for_department') String knownForDepartment, int gender
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? posterPath = freezed,Object? adult = null,Object? popularity = null,Object? backdropPath = freezed,Object? voteAverage = freezed,Object? overview = freezed,Object? firstAirDate = freezed,Object? originCountry = freezed,Object? genreIds = freezed,Object? originalLanguage = freezed,Object? voteCount = freezed,Object? name = null,Object? originalName = null,Object? mediaType = null,Object? profilePath = null,Object? knownFor = null,Object? knownForDepartment = null,Object? gender = null,}) {
  return _then(_Person(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,originCountry: freezed == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,genreIds: freezed == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>?,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,originalName: null == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,profilePath: null == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String,knownFor: null == knownFor ? _self._knownFor : knownFor // ignore: cast_nullable_to_non_nullable
as List<KnownFor>,knownForDepartment: null == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$KnownFor {

 int get id;@JsonKey(name: 'poster_path') String? get posterPath; bool get adult; double get popularity;@JsonKey(name: 'backdrop_path') String? get backdropPath;@JsonKey(name: 'vote_average') double get voteAverage; String get overview;@JsonKey(name: 'first_air_date') String? get firstAirDate;@JsonKey(name: 'origin_country') List<String>? get originCountry;@JsonKey(name: 'genre_ids') List<int> get genreIds;@JsonKey(name: 'original_language') String get originalLanguage;@JsonKey(name: 'vote_count') int get voteCount; String? get name;@JsonKey(name: 'original_name') String? get originalName;@JsonKey(name: 'media_type') String get mediaType;@JsonKey(name: 'release_date') String? get releaseDate;@JsonKey(name: 'original_title') String? get originalTitle; String? get title; bool get video;
/// Create a copy of KnownFor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KnownForCopyWith<KnownFor> get copyWith => _$KnownForCopyWithImpl<KnownFor>(this as KnownFor, _$identity);

  /// Serializes this KnownFor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KnownFor&&(identical(other.id, id) || other.id == id)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other.originCountry, originCountry)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.title, title) || other.title == title)&&(identical(other.video, video) || other.video == video));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,posterPath,adult,popularity,backdropPath,voteAverage,overview,firstAirDate,const DeepCollectionEquality().hash(originCountry),const DeepCollectionEquality().hash(genreIds),originalLanguage,voteCount,name,originalName,mediaType,releaseDate,originalTitle,title,video]);

@override
String toString() {
  return 'KnownFor(id: $id, posterPath: $posterPath, adult: $adult, popularity: $popularity, backdropPath: $backdropPath, voteAverage: $voteAverage, overview: $overview, firstAirDate: $firstAirDate, originCountry: $originCountry, genreIds: $genreIds, originalLanguage: $originalLanguage, voteCount: $voteCount, name: $name, originalName: $originalName, mediaType: $mediaType, releaseDate: $releaseDate, originalTitle: $originalTitle, title: $title, video: $video)';
}


}

/// @nodoc
abstract mixin class $KnownForCopyWith<$Res>  {
  factory $KnownForCopyWith(KnownFor value, $Res Function(KnownFor) _then) = _$KnownForCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'poster_path') String? posterPath, bool adult, double popularity,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'vote_average') double voteAverage, String overview,@JsonKey(name: 'first_air_date') String? firstAirDate,@JsonKey(name: 'origin_country') List<String>? originCountry,@JsonKey(name: 'genre_ids') List<int> genreIds,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'vote_count') int voteCount, String? name,@JsonKey(name: 'original_name') String? originalName,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'release_date') String? releaseDate,@JsonKey(name: 'original_title') String? originalTitle, String? title, bool video
});




}
/// @nodoc
class _$KnownForCopyWithImpl<$Res>
    implements $KnownForCopyWith<$Res> {
  _$KnownForCopyWithImpl(this._self, this._then);

  final KnownFor _self;
  final $Res Function(KnownFor) _then;

/// Create a copy of KnownFor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? posterPath = freezed,Object? adult = null,Object? popularity = null,Object? backdropPath = freezed,Object? voteAverage = null,Object? overview = null,Object? firstAirDate = freezed,Object? originCountry = freezed,Object? genreIds = null,Object? originalLanguage = null,Object? voteCount = null,Object? name = freezed,Object? originalName = freezed,Object? mediaType = null,Object? releaseDate = freezed,Object? originalTitle = freezed,Object? title = freezed,Object? video = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,originCountry: freezed == originCountry ? _self.originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,genreIds: null == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,originalName: freezed == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,video: null == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KnownFor].
extension KnownForPatterns on KnownFor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KnownFor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KnownFor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KnownFor value)  $default,){
final _that = this;
switch (_that) {
case _KnownFor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KnownFor value)?  $default,){
final _that = this;
switch (_that) {
case _KnownFor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double voteAverage,  String overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int> genreIds, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'vote_count')  int voteCount,  String? name, @JsonKey(name: 'original_name')  String? originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'original_title')  String? originalTitle,  String? title,  bool video)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KnownFor() when $default != null:
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.releaseDate,_that.originalTitle,_that.title,_that.video);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double voteAverage,  String overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int> genreIds, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'vote_count')  int voteCount,  String? name, @JsonKey(name: 'original_name')  String? originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'original_title')  String? originalTitle,  String? title,  bool video)  $default,) {final _that = this;
switch (_that) {
case _KnownFor():
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.releaseDate,_that.originalTitle,_that.title,_that.video);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'poster_path')  String? posterPath,  bool adult,  double popularity, @JsonKey(name: 'backdrop_path')  String? backdropPath, @JsonKey(name: 'vote_average')  double voteAverage,  String overview, @JsonKey(name: 'first_air_date')  String? firstAirDate, @JsonKey(name: 'origin_country')  List<String>? originCountry, @JsonKey(name: 'genre_ids')  List<int> genreIds, @JsonKey(name: 'original_language')  String originalLanguage, @JsonKey(name: 'vote_count')  int voteCount,  String? name, @JsonKey(name: 'original_name')  String? originalName, @JsonKey(name: 'media_type')  String mediaType, @JsonKey(name: 'release_date')  String? releaseDate, @JsonKey(name: 'original_title')  String? originalTitle,  String? title,  bool video)?  $default,) {final _that = this;
switch (_that) {
case _KnownFor() when $default != null:
return $default(_that.id,_that.posterPath,_that.adult,_that.popularity,_that.backdropPath,_that.voteAverage,_that.overview,_that.firstAirDate,_that.originCountry,_that.genreIds,_that.originalLanguage,_that.voteCount,_that.name,_that.originalName,_that.mediaType,_that.releaseDate,_that.originalTitle,_that.title,_that.video);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KnownFor implements KnownFor {
  const _KnownFor({this.id = 0, @JsonKey(name: 'poster_path') this.posterPath, this.adult = false, this.popularity = 0.0, @JsonKey(name: 'backdrop_path') this.backdropPath, @JsonKey(name: 'vote_average') this.voteAverage = 0.0, this.overview = '', @JsonKey(name: 'first_air_date') this.firstAirDate, @JsonKey(name: 'origin_country') final  List<String>? originCountry = const [], @JsonKey(name: 'genre_ids') final  List<int> genreIds = const [], @JsonKey(name: 'original_language') this.originalLanguage = '', @JsonKey(name: 'vote_count') this.voteCount = 0, this.name, @JsonKey(name: 'original_name') this.originalName, @JsonKey(name: 'media_type') this.mediaType = '', @JsonKey(name: 'release_date') this.releaseDate, @JsonKey(name: 'original_title') this.originalTitle, this.title, this.video = false}): _originCountry = originCountry,_genreIds = genreIds;
  factory _KnownFor.fromJson(Map<String, dynamic> json) => _$KnownForFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey(name: 'poster_path') final  String? posterPath;
@override@JsonKey() final  bool adult;
@override@JsonKey() final  double popularity;
@override@JsonKey(name: 'backdrop_path') final  String? backdropPath;
@override@JsonKey(name: 'vote_average') final  double voteAverage;
@override@JsonKey() final  String overview;
@override@JsonKey(name: 'first_air_date') final  String? firstAirDate;
 final  List<String>? _originCountry;
@override@JsonKey(name: 'origin_country') List<String>? get originCountry {
  final value = _originCountry;
  if (value == null) return null;
  if (_originCountry is EqualUnmodifiableListView) return _originCountry;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int> _genreIds;
@override@JsonKey(name: 'genre_ids') List<int> get genreIds {
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreIds);
}

@override@JsonKey(name: 'original_language') final  String originalLanguage;
@override@JsonKey(name: 'vote_count') final  int voteCount;
@override final  String? name;
@override@JsonKey(name: 'original_name') final  String? originalName;
@override@JsonKey(name: 'media_type') final  String mediaType;
@override@JsonKey(name: 'release_date') final  String? releaseDate;
@override@JsonKey(name: 'original_title') final  String? originalTitle;
@override final  String? title;
@override@JsonKey() final  bool video;

/// Create a copy of KnownFor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KnownForCopyWith<_KnownFor> get copyWith => __$KnownForCopyWithImpl<_KnownFor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KnownForToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KnownFor&&(identical(other.id, id) || other.id == id)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.firstAirDate, firstAirDate) || other.firstAirDate == firstAirDate)&&const DeepCollectionEquality().equals(other._originCountry, _originCountry)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.title, title) || other.title == title)&&(identical(other.video, video) || other.video == video));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,posterPath,adult,popularity,backdropPath,voteAverage,overview,firstAirDate,const DeepCollectionEquality().hash(_originCountry),const DeepCollectionEquality().hash(_genreIds),originalLanguage,voteCount,name,originalName,mediaType,releaseDate,originalTitle,title,video]);

@override
String toString() {
  return 'KnownFor(id: $id, posterPath: $posterPath, adult: $adult, popularity: $popularity, backdropPath: $backdropPath, voteAverage: $voteAverage, overview: $overview, firstAirDate: $firstAirDate, originCountry: $originCountry, genreIds: $genreIds, originalLanguage: $originalLanguage, voteCount: $voteCount, name: $name, originalName: $originalName, mediaType: $mediaType, releaseDate: $releaseDate, originalTitle: $originalTitle, title: $title, video: $video)';
}


}

/// @nodoc
abstract mixin class _$KnownForCopyWith<$Res> implements $KnownForCopyWith<$Res> {
  factory _$KnownForCopyWith(_KnownFor value, $Res Function(_KnownFor) _then) = __$KnownForCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'poster_path') String? posterPath, bool adult, double popularity,@JsonKey(name: 'backdrop_path') String? backdropPath,@JsonKey(name: 'vote_average') double voteAverage, String overview,@JsonKey(name: 'first_air_date') String? firstAirDate,@JsonKey(name: 'origin_country') List<String>? originCountry,@JsonKey(name: 'genre_ids') List<int> genreIds,@JsonKey(name: 'original_language') String originalLanguage,@JsonKey(name: 'vote_count') int voteCount, String? name,@JsonKey(name: 'original_name') String? originalName,@JsonKey(name: 'media_type') String mediaType,@JsonKey(name: 'release_date') String? releaseDate,@JsonKey(name: 'original_title') String? originalTitle, String? title, bool video
});




}
/// @nodoc
class __$KnownForCopyWithImpl<$Res>
    implements _$KnownForCopyWith<$Res> {
  __$KnownForCopyWithImpl(this._self, this._then);

  final _KnownFor _self;
  final $Res Function(_KnownFor) _then;

/// Create a copy of KnownFor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? posterPath = freezed,Object? adult = null,Object? popularity = null,Object? backdropPath = freezed,Object? voteAverage = null,Object? overview = null,Object? firstAirDate = freezed,Object? originCountry = freezed,Object? genreIds = null,Object? originalLanguage = null,Object? voteCount = null,Object? name = freezed,Object? originalName = freezed,Object? mediaType = null,Object? releaseDate = freezed,Object? originalTitle = freezed,Object? title = freezed,Object? video = null,}) {
  return _then(_KnownFor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,adult: null == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool,popularity: null == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: null == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double,overview: null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String,firstAirDate: freezed == firstAirDate ? _self.firstAirDate : firstAirDate // ignore: cast_nullable_to_non_nullable
as String?,originCountry: freezed == originCountry ? _self._originCountry : originCountry // ignore: cast_nullable_to_non_nullable
as List<String>?,genreIds: null == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalLanguage: null == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,originalName: freezed == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,video: null == video ? _self.video : video // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
