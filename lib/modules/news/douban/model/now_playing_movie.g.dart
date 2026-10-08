// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'now_playing_movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoubanCover _$DoubanCoverFromJson(Map<String, dynamic> json) => _DoubanCover(
  url: json['url'] as String? ?? '',
  width: (json['width'] as num?)?.toInt() ?? 0,
  height: (json['height'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DoubanCoverToJson(_DoubanCover instance) =>
    <String, dynamic>{
      'url': instance.url,
      'width': instance.width,
      'height': instance.height,
    };

_DoubanRating _$DoubanRatingFromJson(Map<String, dynamic> json) =>
    _DoubanRating(
      count: (json['count'] as num?)?.toInt() ?? 0,
      value: json['value'] as num? ?? 0,
      starCount: json['starCount'] as num? ?? 0,
    );

Map<String, dynamic> _$DoubanRatingToJson(_DoubanRating instance) =>
    <String, dynamic>{
      'count': instance.count,
      'value': instance.value,
      'starCount': instance.starCount,
    };

_NowPlayingMovie _$NowPlayingMovieFromJson(
  Map<String, dynamic> json,
) => _NowPlayingMovie(
  id: json['id'] as String? ?? '',
  title: json['title'] as String? ?? '',
  originalTitle: json['original_title'] as String? ?? '',
  year: json['year'] as String? ?? '',
  cover: json['cover'] == null
      ? const DoubanCover()
      : DoubanCover.fromJson(json['cover'] as Map<String, dynamic>),
  rating: json['rating'] == null
      ? null
      : DoubanRating.fromJson(json['rating'] as Map<String, dynamic>),
  cardSubtitle: json['card_subtitle'] as String? ?? '',
  directors:
      (json['directors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  actors:
      (json['actors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  releaseDate: json['release_date'] as String? ?? '',
  hasLinewatch: json['has_linewatch'] as bool? ?? false,
  uri: json['uri'] as String? ?? '',
  url: json['url'] as String? ?? '',
);

Map<String, dynamic> _$NowPlayingMovieToJson(_NowPlayingMovie instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'year': instance.year,
      'cover': instance.cover,
      'rating': instance.rating,
      'card_subtitle': instance.cardSubtitle,
      'directors': instance.directors,
      'actors': instance.actors,
      'release_date': instance.releaseDate,
      'has_linewatch': instance.hasLinewatch,
      'uri': instance.uri,
      'url': instance.url,
    };
