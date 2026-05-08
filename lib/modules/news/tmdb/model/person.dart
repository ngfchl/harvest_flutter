import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
abstract class Person with _$Person {
  const factory Person({
    @Default(0) int id,
    @JsonKey(name: 'poster_path') String? posterPath,
    @Default(false) bool adult,
    @Default(0.0) double popularity,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @Default(0.0) @JsonKey(name: 'vote_average') double? voteAverage,
    String? overview,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    @Default([]) @JsonKey(name: 'origin_country') List<String>? originCountry,
    @Default([]) @JsonKey(name: 'genre_ids') List<int>? genreIds,
    @JsonKey(name: 'original_language') String? originalLanguage,
    @JsonKey(name: 'vote_count') int? voteCount,
    @Default('') String name,
    @Default('') @JsonKey(name: 'original_name') String originalName,
    @Default('') @JsonKey(name: 'media_type') String mediaType,
    @Default('') @JsonKey(name: 'profile_path') String profilePath,
    @Default([]) @JsonKey(name: 'known_for') List<KnownFor> knownFor,
    @Default('')
    @JsonKey(name: 'known_for_department')
    String knownForDepartment,
    @Default(0) int gender,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

@freezed
abstract class KnownFor with _$KnownFor {
  const factory KnownFor({
    @Default(0) int id,
    @JsonKey(name: 'poster_path') String? posterPath,
    @Default(false) bool adult,
    @Default(0.0) double popularity,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @Default(0.0) @JsonKey(name: 'vote_average') double voteAverage,
    @Default('') String overview,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    @Default([]) @JsonKey(name: 'origin_country') List<String>? originCountry,
    @Default([]) @JsonKey(name: 'genre_ids') List<int> genreIds,
    @Default('') @JsonKey(name: 'original_language') String originalLanguage,
    @Default(0) @JsonKey(name: 'vote_count') int voteCount,
    String? name,
    @JsonKey(name: 'original_name') String? originalName,
    @Default('') @JsonKey(name: 'media_type') String mediaType,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'original_title') String? originalTitle,
    String? title,
    @Default(false) bool video,
  }) = _KnownFor;

  factory KnownFor.fromJson(Map<String, dynamic> json) =>
      _$KnownForFromJson(json);
}
