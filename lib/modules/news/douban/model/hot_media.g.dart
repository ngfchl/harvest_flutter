// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_media.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HotMedia _$HotMediaFromJson(Map<String, dynamic> json) => _HotMedia(
  title: json['title'] as String? ?? '',
  doubanUrl: json['url'] as String? ?? '',
  poster: json['cover'] as String? ?? '',
  playable: json['playable'] as bool? ?? false,
  id: json['id'] as String? ?? '',
  rate: json['rate'] as String? ?? '',
  coverX: (json['cover_x'] as num?)?.toInt() ?? 0,
  coverY: (json['cover_y'] as num?)?.toInt() ?? 0,
  isNew: json['is_new'] as bool? ?? false,
  episodesInfo: json['episodes_info'] as String? ?? '',
  cookie: json['cookie'] as String? ?? '',
);

Map<String, dynamic> _$HotMediaToJson(_HotMedia instance) => <String, dynamic>{
  'title': instance.title,
  'url': instance.doubanUrl,
  'cover': instance.poster,
  'playable': instance.playable,
  'id': instance.id,
  'rate': instance.rate,
  'cover_x': instance.coverX,
  'cover_y': instance.coverY,
  'is_new': instance.isNew,
  'episodes_info': instance.episodesInfo,
  'cookie': instance.cookie,
};
