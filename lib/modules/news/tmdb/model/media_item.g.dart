// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => _MediaItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  originalTitle: json['original_title'] as String? ?? '',
  overview: json['overview'] as String? ?? '',
  posterPath: json['poster_path'] as String? ?? '',
  backdropPath: json['backdrop_path'] as String? ?? '',
  mediaType: json['media_type'] as String? ?? '',
  originalLanguage: json['original_language'] as String? ?? '',
  popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
  voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
  releaseDate: json['release_date'] as String? ?? '',
  genreIds:
      (json['genre_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  adult: json['adult'] as bool? ?? false,
  video: json['video'] as bool?,
  originCountry:
      (json['origin_country'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$MediaItemToJson(_MediaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'media_type': instance.mediaType,
      'original_language': instance.originalLanguage,
      'popularity': instance.popularity,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'release_date': instance.releaseDate,
      'genre_ids': instance.genreIds,
      'adult': instance.adult,
      'video': instance.video,
      'origin_country': instance.originCountry,
    };
