// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Person _$PersonFromJson(Map<String, dynamic> json) => _Person(
  id: (json['id'] as num?)?.toInt() ?? 0,
  posterPath: json['poster_path'] as String?,
  adult: json['adult'] as bool? ?? false,
  popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
  backdropPath: json['backdrop_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  overview: json['overview'] as String?,
  firstAirDate: json['first_air_date'] as String?,
  originCountry:
      (json['origin_country'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  genreIds:
      (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  originalLanguage: json['original_language'] as String?,
  voteCount: (json['vote_count'] as num?)?.toInt(),
  name: json['name'] as String? ?? '',
  originalName: json['original_name'] as String? ?? '',
  mediaType: json['media_type'] as String? ?? '',
  profilePath: json['profile_path'] as String? ?? '',
  knownFor:
      (json['known_for'] as List<dynamic>?)
          ?.map((e) => KnownFor.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  knownForDepartment: json['known_for_department'] as String? ?? '',
  gender: (json['gender'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PersonToJson(_Person instance) => <String, dynamic>{
  'id': instance.id,
  'poster_path': instance.posterPath,
  'adult': instance.adult,
  'popularity': instance.popularity,
  'backdrop_path': instance.backdropPath,
  'vote_average': instance.voteAverage,
  'overview': instance.overview,
  'first_air_date': instance.firstAirDate,
  'origin_country': instance.originCountry,
  'genre_ids': instance.genreIds,
  'original_language': instance.originalLanguage,
  'vote_count': instance.voteCount,
  'name': instance.name,
  'original_name': instance.originalName,
  'media_type': instance.mediaType,
  'profile_path': instance.profilePath,
  'known_for': instance.knownFor.map((e) => e.toJson()).toList(),
  'known_for_department': instance.knownForDepartment,
  'gender': instance.gender,
};

_KnownFor _$KnownForFromJson(Map<String, dynamic> json) => _KnownFor(
  id: (json['id'] as num?)?.toInt() ?? 0,
  posterPath: json['poster_path'] as String?,
  adult: json['adult'] as bool? ?? false,
  popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
  backdropPath: json['backdrop_path'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  overview: json['overview'] as String? ?? '',
  firstAirDate: json['first_air_date'] as String?,
  originCountry:
      (json['origin_country'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  genreIds:
      (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  originalLanguage: json['original_language'] as String? ?? '',
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
  name: json['name'] as String?,
  originalName: json['original_name'] as String?,
  mediaType: json['media_type'] as String? ?? '',
  releaseDate: json['release_date'] as String?,
  originalTitle: json['original_title'] as String?,
  title: json['title'] as String?,
  video: json['video'] as bool? ?? false,
);

Map<String, dynamic> _$KnownForToJson(_KnownFor instance) => <String, dynamic>{
  'id': instance.id,
  'poster_path': instance.posterPath,
  'adult': instance.adult,
  'popularity': instance.popularity,
  'backdrop_path': instance.backdropPath,
  'vote_average': instance.voteAverage,
  'overview': instance.overview,
  'first_air_date': instance.firstAirDate,
  'origin_country': instance.originCountry,
  'genre_ids': instance.genreIds,
  'original_language': instance.originalLanguage,
  'vote_count': instance.voteCount,
  'name': instance.name,
  'original_name': instance.originalName,
  'media_type': instance.mediaType,
  'release_date': instance.releaseDate,
  'original_title': instance.originalTitle,
  'title': instance.title,
  'video': instance.video,
};
