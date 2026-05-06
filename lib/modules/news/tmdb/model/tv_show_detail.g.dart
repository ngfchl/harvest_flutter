// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_show_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TvShowDetail _$TvShowDetailFromJson(
  Map<String, dynamic> json,
) => _TvShowDetail(
  adult: json['adult'] as bool? ?? false,
  backdropPath: json['backdrop_path'] as String?,
  createdBy: json['created_by'] as List<dynamic>? ?? const [],
  episodeRunTime: json['episode_run_time'] as List<dynamic>? ?? const [],
  releaseDate: json['first_air_date'] as String? ?? '',
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  homepage: json['homepage'] as String?,
  id: (json['id'] as num?)?.toInt() ?? 0,
  imdbId: json['imdbId'] as String?,
  inProduction: json['in_production'] as bool? ?? false,
  languages: json['languages'] as List<dynamic>? ?? const [],
  lastAirDate: json['last_air_date'] as String?,
  lastEpisodeToAir: json['last_episode_to_air'] == null
      ? null
      : LastEpisodeToAir.fromJson(
          json['last_episode_to_air'] as Map<String, dynamic>,
        ),
  title: json['name'] as String? ?? '',
  nextEpisodeToAir: json['next_episode_to_air'],
  networks:
      (json['networks'] as List<dynamic>?)
          ?.map((e) => Network.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt() ?? 0,
  numberOfSeasons: (json['number_of_seasons'] as num?)?.toInt() ?? 0,
  originCountry:
      (json['origin_country'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  originalLanguage: json['original_language'] as String? ?? '',
  originalTitle: json['original_name'] as String? ?? '',
  overview: json['overview'] as String? ?? '',
  popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
  posterPath: json['poster_path'] as String? ?? '',
  productionCompanies:
      (json['production_companies'] as List<dynamic>?)
          ?.map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  productionCountries:
      (json['production_countries'] as List<dynamic>?)
          ?.map((e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  seasons:
      (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  spokenLanguages: json['spoken_languages'] as List<dynamic>? ?? const [],
  status: json['status'] as String? ?? '',
  tagline: json['tagline'] as String? ?? '',
  type: json['type'] as String? ?? '',
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TvShowDetailToJson(_TvShowDetail instance) =>
    <String, dynamic>{
      'adult': instance.adult,
      'backdrop_path': instance.backdropPath,
      'created_by': instance.createdBy,
      'episode_run_time': instance.episodeRunTime,
      'first_air_date': instance.releaseDate,
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'homepage': instance.homepage,
      'id': instance.id,
      'imdbId': instance.imdbId,
      'in_production': instance.inProduction,
      'languages': instance.languages,
      'last_air_date': instance.lastAirDate,
      'last_episode_to_air': instance.lastEpisodeToAir?.toJson(),
      'name': instance.title,
      'next_episode_to_air': instance.nextEpisodeToAir,
      'networks': instance.networks.map((e) => e.toJson()).toList(),
      'number_of_episodes': instance.numberOfEpisodes,
      'number_of_seasons': instance.numberOfSeasons,
      'origin_country': instance.originCountry,
      'original_language': instance.originalLanguage,
      'original_name': instance.originalTitle,
      'overview': instance.overview,
      'popularity': instance.popularity,
      'poster_path': instance.posterPath,
      'production_companies': instance.productionCompanies
          .map((e) => e.toJson())
          .toList(),
      'production_countries': instance.productionCountries
          .map((e) => e.toJson())
          .toList(),
      'seasons': instance.seasons.map((e) => e.toJson()).toList(),
      'spoken_languages': instance.spokenLanguages,
      'status': instance.status,
      'tagline': instance.tagline,
      'type': instance.type,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
    };

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  airDate: json['air_date'] as String? ?? '',
  episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  overview: json['overview'] as String? ?? '',
  posterPath: json['poster_path'] as String? ?? '',
  seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'air_date': instance.airDate,
  'episode_count': instance.episodeCount,
  'id': instance.id,
  'name': instance.name,
  'overview': instance.overview,
  'poster_path': instance.posterPath,
  'season_number': instance.seasonNumber,
  'vote_average': instance.voteAverage,
};

_LastEpisodeToAir _$LastEpisodeToAirFromJson(Map<String, dynamic> json) =>
    _LastEpisodeToAir(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      airDate: json['air_date'] as String? ?? '',
      episodeNumber: (json['episode_number'] as num?)?.toInt() ?? 0,
      episodeType: json['episode_type'] as String? ?? '',
      productionCode: json['production_code'] as String? ?? '',
      runtime: json['runtime'],
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      showId: (json['show_id'] as num?)?.toInt() ?? 0,
      stillPath: json['still_path'],
    );

Map<String, dynamic> _$LastEpisodeToAirToJson(_LastEpisodeToAir instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'overview': instance.overview,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'air_date': instance.airDate,
      'episode_number': instance.episodeNumber,
      'episode_type': instance.episodeType,
      'production_code': instance.productionCode,
      'runtime': instance.runtime,
      'season_number': instance.seasonNumber,
      'show_id': instance.showId,
      'still_path': instance.stillPath,
    };
