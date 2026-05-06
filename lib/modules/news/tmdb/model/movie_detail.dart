import 'package:freezed_annotation/freezed_annotation.dart';

import 'genre.dart';
import 'production.dart';

part 'movie_detail.freezed.dart';
part 'movie_detail.g.dart';

@freezed
abstract class MovieDetail with _$MovieDetail {
  const factory MovieDetail({
    @Default(false) bool adult,
    @Default('') @JsonKey(name: 'backdrop_path') String backdropPath,
    @JsonKey(name: 'belongs_to_collection') BelongsToCollection? belongsToCollection,
    @Default(0) int budget,
    @Default([]) List<Genre> genres,
    @Default('') String homepage,
    @Default(0) int id,
    @Default('') @JsonKey(name: 'imdb_id') String? imdbId,
    @Default('movie') @JsonKey(includeFromJson: false, includeToJson: false) String mediaType,
    @Default([]) @JsonKey(name: 'origin_country') List<String> originCountry,
    @Default('') @JsonKey(name: 'original_language') String originalLanguage,
    @Default('') @JsonKey(name: 'original_title') String originalTitle,
    @Default('') String overview,
    @Default(0.0) double popularity,
    @Default('') @JsonKey(name: 'poster_path') String posterPath,
    @Default([]) @JsonKey(name: 'production_companies') List<ProductionCompany> productionCompanies,
    @Default([]) @JsonKey(name: 'production_countries') List<ProductionCountry> productionCountries,
    @Default('') @JsonKey(name: 'release_date') String releaseDate,
    @Default(0) int revenue,
    @Default(0) int runtime,
    @Default([]) @JsonKey(name: 'spoken_languages') List<SpokenLanguage> spokenLanguages,
    @Default('') String status,
    @Default('') String tagline,
    @Default('') String title,
    @Default(false) bool video,
    @Default(0.0) @JsonKey(name: 'vote_average') double voteAverage,
    @Default(0) @JsonKey(name: 'vote_count') int voteCount,
  }) = _MovieDetail;

  factory MovieDetail.fromJson(Map<String, dynamic> json) => _$MovieDetailFromJson(json);
}

@freezed
abstract class BelongsToCollection with _$BelongsToCollection {
  const factory BelongsToCollection({
    @Default(0) int id,
    @Default('') String name,
    @Default('') @JsonKey(name: 'poster_path') String posterPath,
    @Default('') @JsonKey(name: 'backdrop_path') String backdropPath,
  }) = _BelongsToCollection;

  factory BelongsToCollection.fromJson(Map<String, dynamic> json) => _$BelongsToCollectionFromJson(json);
}
