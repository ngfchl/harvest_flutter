// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MovieDetail _$MovieDetailFromJson(Map<String, dynamic> json) => _MovieDetail(
  adult: json['adult'] as bool? ?? false,
  backdropPath: json['backdrop_path'] as String? ?? '',
  belongsToCollection: json['belongs_to_collection'] == null
      ? null
      : BelongsToCollection.fromJson(
          json['belongs_to_collection'] as Map<String, dynamic>,
        ),
  budget: (json['budget'] as num?)?.toInt() ?? 0,
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  homepage: json['homepage'] as String? ?? '',
  id: (json['id'] as num?)?.toInt() ?? 0,
  imdbId: json['imdb_id'] as String? ?? '',
  originCountry:
      (json['origin_country'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  originalLanguage: json['original_language'] as String? ?? '',
  originalTitle: json['original_title'] as String? ?? '',
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
  releaseDate: json['release_date'] as String? ?? '',
  revenue: (json['revenue'] as num?)?.toInt() ?? 0,
  runtime: (json['runtime'] as num?)?.toInt() ?? 0,
  spokenLanguages:
      (json['spoken_languages'] as List<dynamic>?)
          ?.map((e) => SpokenLanguage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status: json['status'] as String? ?? '',
  tagline: json['tagline'] as String? ?? '',
  title: json['title'] as String? ?? '',
  video: json['video'] as bool? ?? false,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$MovieDetailToJson(
  _MovieDetail instance,
) => <String, dynamic>{
  'adult': instance.adult,
  'backdrop_path': instance.backdropPath,
  'belongs_to_collection': instance.belongsToCollection?.toJson(),
  'budget': instance.budget,
  'genres': instance.genres.map((e) => e.toJson()).toList(),
  'homepage': instance.homepage,
  'id': instance.id,
  'imdb_id': instance.imdbId,
  'origin_country': instance.originCountry,
  'original_language': instance.originalLanguage,
  'original_title': instance.originalTitle,
  'overview': instance.overview,
  'popularity': instance.popularity,
  'poster_path': instance.posterPath,
  'production_companies': instance.productionCompanies
      .map((e) => e.toJson())
      .toList(),
  'production_countries': instance.productionCountries
      .map((e) => e.toJson())
      .toList(),
  'release_date': instance.releaseDate,
  'revenue': instance.revenue,
  'runtime': instance.runtime,
  'spoken_languages': instance.spokenLanguages.map((e) => e.toJson()).toList(),
  'status': instance.status,
  'tagline': instance.tagline,
  'title': instance.title,
  'video': instance.video,
  'vote_average': instance.voteAverage,
  'vote_count': instance.voteCount,
};

_BelongsToCollection _$BelongsToCollectionFromJson(Map<String, dynamic> json) =>
    _BelongsToCollection(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      backdropPath: json['backdrop_path'] as String? ?? '',
    );

Map<String, dynamic> _$BelongsToCollectionToJson(
  _BelongsToCollection instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'poster_path': instance.posterPath,
  'backdrop_path': instance.backdropPath,
};
