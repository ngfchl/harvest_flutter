// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'site_config.freezed.dart';
part 'site_config.g.dart';

@freezed
abstract class WebSite with _$WebSite {
  const WebSite._();

  const factory WebSite({
    @Default([]) List<String> url,
    @Default('') String name,
    @Default('') String nickname,
    @Default('') String logo,
    @Default('') String tracker,
    @Default(0) @JsonKey(name: 'sp_full') int spFull,
    @Default(0) @JsonKey(name: 'limit_speed') int limitSpeed,
    @Default('') String tags,
    @Default(0) int iyuu,
    @Default(false) @JsonKey(name: 'sign_in') bool signIn,
    @Default(false) @JsonKey(name: 'get_info') bool getInfo,
    @Default(false) @JsonKey(name: 'repeat_torrents') bool repeatTorrents,
    @Default(false) @JsonKey(name: 'brush_free') bool brushFree,
    @Default(false) @JsonKey(name: 'brush_rss') bool brushRss,
    @Default(false) @JsonKey(name: 'hr_discern') bool hrDiscern,
    @Default(false) @JsonKey(name: 'search_torrents') bool searchTorrents,
    @Default('') @JsonKey(name: 'page_index') String pageIndex,
    @Default('') @JsonKey(name: 'page_torrents') String pageTorrents,
    @Default('') @JsonKey(name: 'page_sign_in') String pageSignIn,
    @Default('') @JsonKey(name: 'page_control_panel') String pageControlPanel,
    @Default('') @JsonKey(name: 'page_detail') String pageDetail,
    @Default('') @JsonKey(name: 'page_download') String pageDownload,
    @Default('') @JsonKey(name: 'page_user') String pageUser,
    @Default([])
    @JsonKey(name: 'page_search', fromJson: _stringListFromJson)
    List<String> pageSearch,
    @Default('') @JsonKey(name: 'page_message') String pageMessage,
    @Default('') @JsonKey(name: 'page_hr') String pageHr,
    @Default('') @JsonKey(name: 'page_leeching') String pageLeeching,
    @Default('') @JsonKey(name: 'page_uploaded') String pageUploaded,
    @Default('') @JsonKey(name: 'page_seeding') String pageSeeding,
    @Default('') @JsonKey(name: 'page_completed') String pageCompleted,
    @Default('') @JsonKey(name: 'page_mybonus') String pageMybonus,
    @Default('') @JsonKey(name: 'page_viewfilelist') String pageViewfilelist,
    @Default('') @JsonKey(name: 'sign_info_title') String signInfoTitle,
    @Default('') @JsonKey(name: 'sign_info_content') String signInfoContent,
    @Default(false) bool hr,
    @Default(0) @JsonKey(name: 'hr_rate') int hrRate,
    @Default(0) @JsonKey(name: 'hr_time') int hrTime,
    @Default('') @JsonKey(name: 'my_invitation_rule') String myInvitationRule,
    @Default('') @JsonKey(name: 'my_time_join_rule') String myTimeJoinRule,
    @Default('')
    @JsonKey(name: 'my_latest_active_rule')
    String myLatestActiveRule,
    @Default('') @JsonKey(name: 'my_uploaded_rule') String myUploadedRule,
    @Default('') @JsonKey(name: 'my_downloaded_rule') String myDownloadedRule,
    @Default('') @JsonKey(name: 'my_ratio_rule') String myRatioRule,
    @Default('') @JsonKey(name: 'my_bonus_rule') String myBonusRule,
    @Default('')
    @JsonKey(name: 'my_per_hour_bonus_rule')
    String myPerHourBonusRule,
    @Default('') @JsonKey(name: 'my_score_rule') String myScoreRule,
    @Default('') @JsonKey(name: 'my_level_rule') String myLevelRule,
    @Default('') @JsonKey(name: 'my_passkey_rule') String myPasskeyRule,
    @Default('') @JsonKey(name: 'my_uid_rule') String myUidRule,
    @Default('') @JsonKey(name: 'my_hr_rule') String myHrRule,
    @Default('') @JsonKey(name: 'my_leech_rule') String myLeechRule,
    @Default('') @JsonKey(name: 'my_publish_rule') String myPublishRule,
    @Default('') @JsonKey(name: 'my_seed_rule') String mySeedRule,
    @Default('') @JsonKey(name: 'my_seed_vol_rule') String mySeedVolRule,
    @Default('') @JsonKey(name: 'my_mailbox_rule') String myMailboxRule,
    @Default('') @JsonKey(name: 'my_message_title') String myMessageTitle,
    @Default('') @JsonKey(name: 'my_notice_rule') String myNoticeRule,
    @Default('') @JsonKey(name: 'my_notice_title') String myNoticeTitle,
    @Default('') @JsonKey(name: 'my_notice_content') String myNoticeContent,
    @Default('') @JsonKey(name: 'torrents_rule') String torrentsRule,
    @Default('') @JsonKey(name: 'torrent_title_rule') String torrentTitleRule,
    @Default('')
    @JsonKey(name: 'torrent_subtitle_rule')
    String torrentSubtitleRule,
    @Default('')
    @JsonKey(name: 'torrent_detail_url_rule')
    String torrentDetailUrlRule,
    @Default('')
    @JsonKey(name: 'torrent_category_rule')
    String torrentCategoryRule,
    @Default('') @JsonKey(name: 'torrent_poster_rule') String torrentPosterRule,
    @Default('')
    @JsonKey(name: 'torrent_magnet_url_rule')
    String torrentMagnetUrlRule,
    @Default('') @JsonKey(name: 'torrent_size_rule') String torrentSizeRule,
    @Default('')
    @JsonKey(name: 'torrent_progress_rule')
    String torrentProgressRule,
    @Default('') @JsonKey(name: 'torrent_hr_rule') String torrentHrRule,
    @Default('') @JsonKey(name: 'torrent_sale_rule') String torrentSaleRule,
    @Default('')
    @JsonKey(name: 'torrent_sale_expire_rule')
    String torrentSaleExpireRule,
    @Default('')
    @JsonKey(name: 'torrent_release_rule')
    String torrentReleaseRule,
    @Default('')
    @JsonKey(name: 'torrent_seeders_rule')
    String torrentSeedersRule,
    @Default('')
    @JsonKey(name: 'torrent_leechers_rule')
    String torrentLeechersRule,
    @Default('')
    @JsonKey(name: 'torrent_completers_rule')
    String torrentCompletersRule,
    @Default('') @JsonKey(name: 'torrent_tags_rule') String torrentTagsRule,
    @Default('') @JsonKey(name: 'detail_title_rule') String detailTitleRule,
    @Default('')
    @JsonKey(name: 'detail_subtitle_rule')
    String detailSubtitleRule,
    @Default('')
    @JsonKey(name: 'detail_download_url_rule')
    String detailDownloadUrlRule,
    @Default('') @JsonKey(name: 'detail_size_rule') String detailSizeRule,
    @Default('')
    @JsonKey(name: 'detail_category_rule')
    String detailCategoryRule,
    @Default('')
    @JsonKey(name: 'detail_count_files_rule')
    String detailCountFilesRule,
    @Default('') @JsonKey(name: 'detail_hash_rule') String detailHashRule,
    @Default('') @JsonKey(name: 'detail_free_rule') String detailFreeRule,
    @Default('')
    @JsonKey(name: 'detail_free_expire_rule')
    String detailFreeExpireRule,
    @Default('') @JsonKey(name: 'detail_douban_rule') String detailDoubanRule,
    @Default('') @JsonKey(name: 'detail_imdb_rule') String detailImdbRule,
    @Default('') @JsonKey(name: 'detail_poster_rule') String detailPosterRule,
    @Default('') @JsonKey(name: 'detail_tags_rule') String detailTagsRule,
    @Default('') @JsonKey(name: 'detail_hr_rule') String detailHrRule,
    @Default(false) bool alive,
    @Default('')
    @JsonKey(name: 'page_pieces_hash_api')
    String pagePiecesHashApi,
    @Default(false) @JsonKey(name: 'pieces_repeat') bool piecesRepeat,
    @Default(false) bool proxy,
    @Default('') String structure,
    @Default('') String type,
    @Default('') String nation,
    @Default('') @JsonKey(name: 'sign_type') String signType,
    @Default('') @JsonKey(name: 'my_email_rule') String myEmailRule,
    @Default('') @JsonKey(name: 'my_username_rule') String myUsernameRule,
    @Default('') @JsonKey(name: 'buy_page') String buyPage,
    @Default({})
    @JsonKey(
      name: 'buy_action',
      toJson: _stringMapToNullableJson,
      includeIfNull: false,
    )
    Map<String, String> buyAction,
    @Default({}) Map<String, SiteLevel> level,
  }) = _WebSite;

  factory WebSite.fromJson(Map<String, dynamic> json) =>
      _$WebSiteFromJson(_normalizeWebSiteJson(json));

  List<String> get tagList =>
      tags.isEmpty ? [] : tags.split(',').map((e) => e.trim()).toList();
}

List<String> _stringListFromJson(Object? value) {
  if (value == null) return const [];
  if (value is String) return value.isEmpty ? const [] : [value];
  if (value is Iterable) {
    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .toList();
  }
  return [value.toString()];
}

String _stringFromJson(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Iterable) {
    return value
        .where((item) => item != null)
        .map((item) => item.toString())
        .join(',');
  }
  return value.toString();
}

Map<String, String> _stringMapFromJson(Object? value) {
  if (value is! Map) return const {};
  return value.map(
    (key, item) => MapEntry(key.toString(), _stringFromJson(item)),
  );
}

Map<String, String>? _stringMapToNullableJson(Map<String, String> value) {
  if (value.isEmpty) return null;
  return value;
}

@freezed
abstract class SiteLevel with _$SiteLevel {
  const factory SiteLevel({
    @Default(0) @JsonKey(name: 'level_id') int levelId,
    @Default('') String level,
    @Default('') String name,
    @Default(0) int days,
    @Default('0') String uploaded,
    @Default('0') String downloaded,
    @Default(0.0) double bonus,
    @Default(0) int score,
    @Default(0.0) double ratio,
    @Default(0) int torrents,
    @Default(0) int leeches,
    @Default(0.0) @JsonKey(name: 'seeding_delta') double seedingDelta,
    @Default(false) @JsonKey(name: 'keep_account') bool keepAccount,
    @Default(false) bool graduation,
    @Default('') String rights,
  }) = _SiteLevel;

  factory SiteLevel.fromJson(Map<String, dynamic> json) =>
      _$SiteLevelFromJson(_normalizeSiteLevelJson(json));

  const SiteLevel._();

  String get displayName {
    final display = name.trim();
    if (display.isNotEmpty) return display;
    final fallback = level.trim();
    if (fallback.isNotEmpty) return fallback;
    return '';
  }
}

Map<String, dynamic> _normalizeWebSiteJson(Map<String, dynamic> json) {
  final next = Map<String, dynamic>.from(json);
  next['url'] = _stringListFromJson(next['url']);
  next['page_search'] = _stringListFromJson(next['page_search']);
  next['buy_action'] = _stringMapFromJson(next['buy_action']);
  next['level'] = _siteLevelJsonMapFromJson(next['level']);

  for (final key in const [
    'page_index',
    'page_torrents',
    'page_sign_in',
    'page_control_panel',
    'page_detail',
    'page_download',
    'page_user',
    'page_message',
    'page_hr',
    'page_leeching',
    'page_uploaded',
    'page_seeding',
    'page_completed',
    'page_mybonus',
    'page_viewfilelist',
    'page_pieces_hash_api',
    'buy_page',
  ]) {
    if (next.containsKey(key)) next[key] = _firstStringFromJson(next[key]);
  }

  for (final key in const [
    'name',
    'nickname',
    'logo',
    'tracker',
    'tags',
    'sign_info_title',
    'sign_info_content',
    'my_invitation_rule',
    'my_time_join_rule',
    'my_latest_active_rule',
    'my_uploaded_rule',
    'my_downloaded_rule',
    'my_ratio_rule',
    'my_bonus_rule',
    'my_per_hour_bonus_rule',
    'my_score_rule',
    'my_level_rule',
    'my_passkey_rule',
    'my_uid_rule',
    'my_hr_rule',
    'my_leech_rule',
    'my_publish_rule',
    'my_seed_rule',
    'my_seed_vol_rule',
    'my_mailbox_rule',
    'my_message_title',
    'my_notice_rule',
    'my_notice_title',
    'my_notice_content',
    'torrents_rule',
    'torrent_title_rule',
    'torrent_subtitle_rule',
    'torrent_detail_url_rule',
    'torrent_category_rule',
    'torrent_poster_rule',
    'torrent_magnet_url_rule',
    'torrent_size_rule',
    'torrent_progress_rule',
    'torrent_hr_rule',
    'torrent_sale_rule',
    'torrent_sale_expire_rule',
    'torrent_release_rule',
    'torrent_seeders_rule',
    'torrent_leechers_rule',
    'torrent_completers_rule',
    'torrent_tags_rule',
    'detail_title_rule',
    'detail_subtitle_rule',
    'detail_download_url_rule',
    'detail_size_rule',
    'detail_category_rule',
    'detail_count_files_rule',
    'detail_hash_rule',
    'detail_free_rule',
    'detail_free_expire_rule',
    'detail_douban_rule',
    'detail_imdb_rule',
    'detail_poster_rule',
    'detail_tags_rule',
    'detail_hr_rule',
    'structure',
    'type',
    'nation',
    'my_email_rule',
    'my_username_rule',
  ]) {
    if (next.containsKey(key)) next[key] = _stringFromJson(next[key]);
  }

  return next;
}

String _firstStringFromJson(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is Iterable) {
    for (final item in value) {
      final text = _stringFromJson(item).trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
  return value.toString();
}

Map<String, dynamic> _normalizeSiteLevelJson(Map<String, dynamic> json) {
  final next = Map<String, dynamic>.from(json);
  for (final key in const [
    'level',
    'name',
    'uploaded',
    'downloaded',
    'rights',
  ]) {
    if (next.containsKey(key)) {
      next[key] = _stringFromJson(next[key]);
    }
  }
  if ((next['uploaded'] as String?)?.isEmpty ?? true) {
    next['uploaded'] = '0';
  }
  if ((next['downloaded'] as String?)?.isEmpty ?? true) {
    next['downloaded'] = '0';
  }
  return next;
}

Map<String, dynamic> _siteLevelJsonMapFromJson(Object? value) {
  if (value is Map) {
    return value.map((key, item) {
      if (item is Map) {
        return MapEntry(
          key.toString(),
          _normalizeSiteLevelJson(Map<String, dynamic>.from(item)),
        );
      }
      return MapEntry(key.toString(), _normalizeSiteLevelJson({'level': item}));
    });
  }
  if (value is Iterable) {
    final result = <String, dynamic>{};
    var index = 0;
    for (final item in value) {
      index++;
      if (item is! Map) {
        continue;
      }
      final level = _normalizeSiteLevelJson(Map<String, dynamic>.from(item));
      final name = _stringFromJson(level['name']);
      final levelName = _stringFromJson(level['level']);
      final key = name.isNotEmpty ? name : levelName;
      result[key.isEmpty ? 'Level$index' : key] = level;
    }
    return result;
  }
  return const {};
}
