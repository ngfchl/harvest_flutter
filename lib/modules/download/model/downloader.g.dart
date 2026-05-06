// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloader.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Downloader _$DownloaderFromJson(Map<String, dynamic> json) => _Downloader(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  category: json['category'] as String? ?? '',
  protocol: json['protocol'] as String? ?? 'http',
  username: json['username'] as String? ?? '',
  password: json['password'] as String? ?? '',
  isActive: json['is_active'] as bool? ?? true,
  host: json['host'] as String? ?? '',
  port: (json['port'] as num?)?.toInt() ?? 0,
  externalHost: json['external_host'] as String? ?? '',
  sortId: (json['sort_id'] as num?)?.toInt() ?? 0,
  brush: json['brush'] as bool? ?? false,
  torrentPath: json['torrent_path'] as String? ?? '',
  prefs: json['prefs'] as Map<String, dynamic>?,
  status: json['status'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DownloaderToJson(_Downloader instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'protocol': instance.protocol,
      'username': instance.username,
      'password': instance.password,
      'is_active': instance.isActive,
      'host': instance.host,
      'port': instance.port,
      'external_host': instance.externalHost,
      'sort_id': instance.sortId,
      'brush': instance.brush,
      'torrent_path': instance.torrentPath,
      'prefs': instance.prefs,
      'status': instance.status,
    };
