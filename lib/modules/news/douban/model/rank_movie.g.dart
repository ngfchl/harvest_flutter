// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank_movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RankMovie _$RankMovieFromJson(Map<String, dynamic> json) => _RankMovie(
  rank: (json['rank'] as num?)?.toInt() ?? 0,
  poster: json['cover_url'] as String? ?? '',
  title: json['title'] as String? ?? '',
  doubanUrl: json['url'] as String? ?? '',
  rating:
      (json['rating'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isPlayable: json['is_playable'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  types:
      (json['types'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  regions:
      (json['regions'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  releaseDate: json['release_date'] as String? ?? '',
  actorCount: (json['actor_count'] as num?)?.toInt() ?? 0,
  voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
  score: json['score'] as String? ?? '',
  cookie: json['cookie'] as String?,
  actors:
      (json['actors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  isWatched: json['is_watched'] as bool? ?? false,
);

Map<String, dynamic> _$RankMovieToJson(_RankMovie instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'cover_url': instance.poster,
      'title': instance.title,
      'url': instance.doubanUrl,
      'rating': instance.rating,
      'is_playable': instance.isPlayable,
      'id': instance.id,
      'types': instance.types,
      'regions': instance.regions,
      'release_date': instance.releaseDate,
      'actor_count': instance.actorCount,
      'vote_count': instance.voteCount,
      'score': instance.score,
      'cookie': instance.cookie,
      'actors': instance.actors,
      'is_watched': instance.isWatched,
    };
