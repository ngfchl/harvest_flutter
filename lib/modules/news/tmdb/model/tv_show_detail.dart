import 'package:freezed_annotation/freezed_annotation.dart';

import 'genre.dart';
import 'production.dart';

part 'tv_show_detail.freezed.dart';
part 'tv_show_detail.g.dart';

@freezed
abstract class TvShowDetail with _$TvShowDetail {
  const TvShowDetail._();

  const factory TvShowDetail({
    @Default(false) bool adult,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @Default([]) @JsonKey(name: 'created_by') List<dynamic> createdBy,
    @Default([])
    @JsonKey(name: 'episode_run_time')
    List<dynamic> episodeRunTime,
    @Default('') @JsonKey(name: 'first_air_date') String? releaseDate,
    @Default([]) List<Genre> genres,
    String? homepage,
    @Default(0) int id,
    String? imdbId,
    @Default('tv')
    @JsonKey(includeFromJson: false, includeToJson: false)
    String mediaType,
    @Default(false) @JsonKey(name: 'in_production') bool inProduction,
    @Default([]) List<dynamic> languages,
    @JsonKey(name: 'last_air_date') String? lastAirDate,
    @JsonKey(name: 'last_episode_to_air') LastEpisodeToAir? lastEpisodeToAir,
    @Default('') @JsonKey(name: 'name') String title,
    @JsonKey(name: 'next_episode_to_air') dynamic nextEpisodeToAir,
    @Default([]) List<Network> networks,
    @Default(0) @JsonKey(name: 'number_of_episodes') int numberOfEpisodes,
    @Default(0) @JsonKey(name: 'number_of_seasons') int numberOfSeasons,
    @Default([]) @JsonKey(name: 'origin_country') List<String> originCountry,
    @Default('') @JsonKey(name: 'original_language') String originalLanguage,
    @Default('') @JsonKey(name: 'original_name') String originalTitle,
    @Default('') String overview,
    @Default(0.0) double popularity,
    @Default('') @JsonKey(name: 'poster_path') String? posterPath,
    @Default([])
    @JsonKey(name: 'production_companies')
    List<ProductionCompany> productionCompanies,
    @Default([])
    @JsonKey(name: 'production_countries')
    List<ProductionCountry> productionCountries,
    @Default([]) List<Season> seasons,
    @Default([])
    @JsonKey(name: 'spoken_languages')
    List<dynamic> spokenLanguages,
    @Default('') String status,
    @Default('') String tagline,
    @Default('') String type,
    @Default(0.0) @JsonKey(name: 'vote_average') double voteAverage,
    @Default(0) @JsonKey(name: 'vote_count') int voteCount,
  }) = _TvShowDetail;

  factory TvShowDetail.fromJson(Map<String, dynamic> json) =>
      _$TvShowDetailFromJson(json);

  /// seasonNumber 最大的一季
  Season? get latestSeason {
    if (seasons.isEmpty) return null;
    return seasons.reduce((a, b) => a.seasonNumber > b.seasonNumber ? a : b);
  }
}

@freezed
abstract class Season with _$Season {
  const factory Season({
    @Default('') @JsonKey(name: 'air_date') String airDate,
    @Default(0) @JsonKey(name: 'episode_count') int episodeCount,
    @Default(0) int id,
    @Default('') String name,
    @Default('') String overview,
    @Default('') @JsonKey(name: 'poster_path') String posterPath,
    @Default(0) @JsonKey(name: 'season_number') int seasonNumber,
    @Default(0.0) @JsonKey(name: 'vote_average') double voteAverage,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

@freezed
abstract class LastEpisodeToAir with _$LastEpisodeToAir {
  const factory LastEpisodeToAir({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String overview,
    @Default(0.0) @JsonKey(name: 'vote_average') double voteAverage,
    @Default(0) @JsonKey(name: 'vote_count') int voteCount,
    @Default('') @JsonKey(name: 'air_date') String airDate,
    @Default(0) @JsonKey(name: 'episode_number') int episodeNumber,
    @Default('') @JsonKey(name: 'episode_type') String episodeType,
    @Default('') @JsonKey(name: 'production_code') String productionCode,
    dynamic runtime,
    @Default(0) @JsonKey(name: 'season_number') int seasonNumber,
    @Default(0) @JsonKey(name: 'show_id') int showId,
    @JsonKey(name: 'still_path') dynamic stillPath,
  }) = _LastEpisodeToAir;

  factory LastEpisodeToAir.fromJson(Map<String, dynamic> json) =>
      _$LastEpisodeToAirFromJson(json);
}
