// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TopMovie _$TopMovieFromJson(Map<String, dynamic> json) => _TopMovie(
  rank: json['rank'] as String? ?? '',
  doubanUrl: json['douban_url'] as String? ?? '',
  poster: json['poster'] as String? ?? '',
  title: json['title'] as String? ?? '',
  subtitle:
      (json['subtitle'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  cast: json['cast'] as String? ?? '',
  desc:
      (json['desc'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  ratingNum: json['rating_num'] as String? ?? '',
  evaluateNum: json['evaluate_num'] as String? ?? '',
  quote: json['quote'] as String? ?? '',
  cookie: json['cookie'] as String? ?? '',
);

Map<String, dynamic> _$TopMovieToJson(_TopMovie instance) => <String, dynamic>{
  'rank': instance.rank,
  'douban_url': instance.doubanUrl,
  'poster': instance.poster,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'cast': instance.cast,
  'desc': instance.desc,
  'rating_num': instance.ratingNum,
  'evaluate_num': instance.evaluateNum,
  'quote': instance.quote,
  'cookie': instance.cookie,
};
