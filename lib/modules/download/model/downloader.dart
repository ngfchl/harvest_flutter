// models/download/downloader.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/modules/download/model/transmission_preferences.dart';

import '../../models/qbittorrent.dart';

part 'downloader.freezed.dart';
part 'downloader.g.dart';

@freezed
abstract class Downloader with _$Downloader {
  const Downloader._();

  const factory Downloader({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String category,
    @Default('http') String protocol,
    @Default('') String username,
    @Default('') String password,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @Default('') String host,
    @Default(0) int port,
    @JsonKey(name: 'external_host') @Default('') String externalHost,
    @JsonKey(name: 'sort_id') @Default(0) int sortId,
    @Default(false) bool brush,
    @JsonKey(name: 'torrent_path') @Default('') String torrentPath,
    Map<String, dynamic>? prefs,
    Map<String, dynamic>? status,
  }) = _Downloader;

  factory Downloader.fromJson(Map<String, dynamic> json) => _$DownloaderFromJson(json);

  bool get isQb => category == 'Qb';

  bool get isTr => category == 'Tr';
  /// WS 推送用的 key，格式: name-id-category
  String get wsKey => '$name-$id-$category';

  QbittorrentPreferences? get qbPrefs {
    if (!isQb || prefs == null) return null;
    try {
      return QbittorrentPreferences.fromJson(prefs!);
    } catch (_) {
      return null;
    }
  }

  TransmissionPreferences? get trPrefs {
    if (!isTr || prefs == null) return null;
    try {
      return TransmissionPreferences.fromJson(prefs!);
    } catch (_) {
      return null;
    }
  }
}
