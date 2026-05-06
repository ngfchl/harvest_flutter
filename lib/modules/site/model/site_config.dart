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
    @Default('') @JsonKey(name: 'my_email_rule') String myEmailRule,
    @Default('') @JsonKey(name: 'my_username_rule') String myUsernameRule,
    @Default('') @JsonKey(name: 'buy_page') String buyPage,
    @Default({}) @JsonKey(name: 'buy_action') Map<String, String> buyAction,
    @Default({}) Map<String, SiteLevel> level,
  }) = _WebSite;

  factory WebSite.fromJson(Map<String, dynamic> json) =>
      _$WebSiteFromJson(json);

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

@freezed
abstract class SiteLevel with _$SiteLevel {
  const factory SiteLevel({
    @Default(0) @JsonKey(name: 'level_id') int levelId,
    @Default('') String level,
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
      _$SiteLevelFromJson(json);
}
