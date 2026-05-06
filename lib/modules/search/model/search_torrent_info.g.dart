// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_torrent_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SearchTorrentInfo _$SearchTorrentInfoFromJson(
  Map<String, dynamic> json,
) => _SearchTorrentInfo(
  siteId: json['site_id'] == null ? '' : _toString(json['site_id']),
  tid: json['tid'] == null ? '' : _toString(json['tid']),
  poster: json['poster'] == null ? '' : _toString(json['poster']),
  category: json['category'] as String? ?? '',
  magnetUrl: json['magnet_url'] == null ? '' : _toString(json['magnet_url']),
  detailUrl: json['detail_url'] == null ? '' : _toString(json['detail_url']),
  title: json['title'] == null ? '' : _toString(json['title']),
  subtitle: json['subtitle'] == null ? '' : _toString(json['subtitle']),
  cookie: _toString(json['cookie']),
  progress: _toDoubleOrNull(json['progress']),
  saleStatus: json['sale_status'] as String? ?? '无优惠',
  saleExpire: json['sale_expire'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  hr: json['hr'] as bool? ?? false,
  published: json['published'] == null ? '' : _toString(json['published']),
  size: json['size'] == null ? 0 : _toInt(json['size']),
  seeders: json['seeders'] == null ? 0 : _toInt(json['seeders']),
  leechers: json['leechers'] == null ? 0 : _toInt(json['leechers']),
  completers: json['completers'] == null ? 0 : _toInt(json['completers']),
);

Map<String, dynamic> _$SearchTorrentInfoToJson(_SearchTorrentInfo instance) =>
    <String, dynamic>{
      'site_id': instance.siteId,
      'tid': instance.tid,
      'poster': instance.poster,
      'category': instance.category,
      'magnet_url': instance.magnetUrl,
      'detail_url': instance.detailUrl,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'cookie': instance.cookie,
      'progress': instance.progress,
      'sale_status': instance.saleStatus,
      'sale_expire': instance.saleExpire,
      'tags': instance.tags,
      'hr': instance.hr,
      'published': instance.published,
      'size': instance.size,
      'seeders': instance.seeders,
      'leechers': instance.leechers,
      'completers': instance.completers,
    };
