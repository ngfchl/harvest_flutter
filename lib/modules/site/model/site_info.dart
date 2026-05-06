import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/core/utils/utils.dart';

part 'site_info.freezed.dart';
part 'site_info.g.dart';

// 文件顶部，SiteInfo class 外面加：
Map<String, SiteDailyStatus>? _statusFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return json.map((k, v) => MapEntry(k, SiteDailyStatus.fromJson(Map<String, dynamic>.from(v as Map))));
}

@freezed
abstract class SiteInfo with _$SiteInfo {
  const SiteInfo._();

  const factory SiteInfo({
    @Default(0) int id,
    @Default('') String site,
    @Default('') String nickname,
    @Default(0) @JsonKey(name: 'sort_id') int sortId,
    @Default([]) List<String> tags,
    @JsonKey(name: 'user_id') String? userId,
    String? username,
    String? email,
    String? passkey,
    String? authkey,
    String? cookie,
    @JsonKey(name: 'user_agent') String? userAgent,
    String? rss,
    String? torrents,
    @Default(false) bool available,
    @Default(false) @JsonKey(name: 'sign_in') bool signIn,
    @Default(false) @JsonKey(name: 'get_info') bool getInfo,
    @Default(false) @JsonKey(name: 'repeat_torrents') bool repeatTorrents,
    @Default(false) @JsonKey(name: 'brush_free') bool brushFree,
    @Default(false) @JsonKey(name: 'brush_rss') bool brushRss,
    @Default(false) @JsonKey(name: 'package_file') bool packageFile,
    @Default(false) @JsonKey(name: 'hr_discern') bool hrDiscern,
    @Default(false) @JsonKey(name: 'search_torrents') bool searchTorrents,
    @Default(true) @JsonKey(name: 'show_in_dash') bool showInDash,
    String? proxy,
    @Default({}) Map<String, dynamic> removeTorrentRules,
    String? mirror,
    @JsonKey(name: 'time_join') String? timeJoin,
    @JsonKey(name: 'latest_active') String? latestActive,
    @Default(0) int mail,
    @Default(0) int notice,
    @JsonKey(name: 'sign_info') Map<String, dynamic>? signInfo,
    @JsonKey(fromJson: _statusFromJson) Map<String, SiteDailyStatus>? status,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _SiteInfo;

  factory SiteInfo.fromJson(Map<String, dynamic> json) => _$SiteInfoFromJson(json);

  SiteDailyStatus? get latestStatus {
    if (status == null || status!.isEmpty) return null;
    final sorted = status!.keys.toList()..sort();
    final latest = sorted.last;
    return status![latest]!.copyWith(date: latest); // date 从 key 补上
  }

  String? get latestStatusUpdatedAt {
    final statusUpdatedAt = latestStatus?.updated_at.trim();
    if (statusUpdatedAt != null && statusUpdatedAt.isNotEmpty) {
      return statusUpdatedAt;
    }
    final siteUpdatedAt = updatedAt?.trim();
    return siteUpdatedAt == null || siteUpdatedAt.isEmpty ? null : siteUpdatedAt;
  }

  String? get signInText {
    if (signInfo == null || signInfo!.isEmpty) return null;

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 有今天的记录 → 已签到
    if (signInfo!.containsKey(todayKey)) return '已签到';
    return null;
  }

  String get latestActiveText {
    return formatDateStringAgo(latestActive);
  }

  String get latestStatusUpdatedText {
    return formatDateStringAgo(latestStatusUpdatedAt);
  }

  String get durationText {
    return formatDateStringWeeksDays(timeJoin, today: '0周0天');
  }
}

@freezed
abstract class SiteDailyStatus with _$SiteDailyStatus {
  const SiteDailyStatus._();

  const factory SiteDailyStatus({
    @Default('') String date,
    @Default(0) int seed,
    @Default(0) int leech,
    @Default('0') @JsonKey(name: 'my_hr') String myHr,
    @Default(0.0) double ratio,
    @Default(0) int publish,
    @Default(0.0) @JsonKey(name: 'my_bonus') double myBonus,
    @Default('') @JsonKey(name: 'my_level') String myLevel,
    @Default(0.0) @JsonKey(name: 'my_score') double myScore,
    @Default(0) int uploaded,
    @Default(0) @JsonKey(name: 'seed_days') int seedDays,
    @Default(0.0) @JsonKey(name: 'bonus_hour') double bonusHour,
    @Default('') String created_at,
    @Default(0) int downloaded,
    @Default(0) int invitation,
    @Default('') String updated_at,
    @Default(0) @JsonKey(name: 'seed_volume') int seedVolume,
  }) = _SiteDailyStatus;

  factory SiteDailyStatus.fromJson(Map<String, dynamic> json) => SiteDailyStatus(
    seed: _toInt(json['seed']),
    leech: _toInt(json['leech']),
    myHr: json['my_hr']?.toString() ?? '0',
    ratio: _toDouble(json['ratio']),
    publish: _toInt(json['publish']),
    myBonus: _toDouble(json['my_bonus']),
    myLevel: json['my_level']?.toString() ?? '',
    myScore: _toDouble(json['my_score']),
    uploaded: _toInt(json['uploaded']),
    seedDays: _toInt(json['seed_days']),
    bonusHour: _toDouble(json['bonus_hour']),
    created_at: json['created_at']?.toString() ?? '',
    downloaded: _toInt(json['downloaded']),
    invitation: _toInt(json['invitation']),
    updated_at: json['updated_at']?.toString() ?? '',
    seedVolume: _toInt(json['seed_volume']),
  );

  Map<String, dynamic> toJson() => {
    'seed': seed,
    'leech': leech,
    'my_hr': myHr,
    'ratio': ratio,
    'publish': publish,
    'my_bonus': myBonus,
    'my_level': myLevel,
    'my_score': myScore,
    'uploaded': uploaded,
    'seed_days': seedDays,
    'bonus_hour': bonusHour,
    'created_at': created_at,
    'downloaded': downloaded,
    'invitation': invitation,
    'updated_at': updated_at,
    'seed_volume': seedVolume,
  };

  static double _toDouble(dynamic v) => parseDouble(v);

  static int _toInt(dynamic v) => parseInt(v);
}
