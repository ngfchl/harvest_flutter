import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/core/utils/utils.dart';

part 'search_torrent_info.freezed.dart';
part 'search_torrent_info.g.dart';

String _toString(dynamic v) => parseString(v);

int _toInt(dynamic v) => parseInt(v);

double? _toDoubleOrNull(dynamic v) => parseDoubleOrNull(v);

@freezed
abstract class SearchTorrentInfo with _$SearchTorrentInfo {
  const factory SearchTorrentInfo({
    @Default('') @JsonKey(name: 'site_id', fromJson: _toString) String siteId,
    @Default('') @JsonKey(fromJson: _toString) String tid,
    @Default('') @JsonKey(fromJson: _toString) String poster,
    @Default('') String category,
    @Default('') @JsonKey(name: 'magnet_url', fromJson: _toString) String magnetUrl,
    @Default('') @JsonKey(name: 'detail_url', fromJson: _toString) String detailUrl,
    @Default('') @JsonKey(fromJson: _toString) String title,
    @Default('') @JsonKey(fromJson: _toString) String subtitle,
    @JsonKey(fromJson: _toString) String? cookie,
    @JsonKey(fromJson: _toDoubleOrNull) double? progress,
    @Default('无优惠') @JsonKey(name: 'sale_status') String saleStatus,
    @JsonKey(name: 'sale_expire') String? saleExpire,
    @Default([]) List<String> tags,
    @Default(false) bool hr,
    @Default('') @JsonKey(fromJson: _toString) String published,
    @Default(0) @JsonKey(fromJson: _toInt) int size,
    @Default(0) @JsonKey(fromJson: _toInt) int seeders,
    @Default(0) @JsonKey(fromJson: _toInt) int leechers,
    @Default(0) @JsonKey(fromJson: _toInt) int completers,
  }) = _SearchTorrentInfo;

  factory SearchTorrentInfo.fromJson(Map<String, dynamic> json) => _$SearchTorrentInfoFromJson(json);
}
