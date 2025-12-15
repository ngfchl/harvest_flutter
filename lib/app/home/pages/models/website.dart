import '../../../../utils/logger_helper.dart';

class WebSite {
  List<String> url;
  String name;
  String nickname;
  String logo;
  String tracker;
  int spFull;
  int limitSpeed;
  String tags;
  int iyuu;
  bool alive;
  bool signIn;
  bool getInfo;
  bool repeatTorrents;
  bool brushFree;
  bool brushRss;
  bool hrDiscern;
  bool searchTorrents;
  String pageIndex;
  String pageTorrents;
  String pageSignIn;
  String pageControlPanel;
  String pageDetail;
  String pageDownload;
  String pageUser;
  List<String> pageSearch;
  String pageMessage;
  String pageHr;
  String pageLeeching;
  String pageUploaded;
  String pageSeeding;
  String pageCompleted;
  String pageMyBonus;
  String pageViewFileList;
  String myUidRule;
  String type;
  String nation;
  bool hr;
  int hrRate;
  int hrTime;
  Map<String, LevelInfo>? level;

  // New properties
  String myInvitationRule;
  String myTimeJoinRule;
  String myLatestActiveRule;
  String myUploadedRule;
  String myDownloadedRule;
  String myRatioRule;
  String myBonusRule;
  String myPerHourBonusRule;
  String myScoreRule;
  String myLevelRule;
  String myPasskeyRule;
  String myHrRule;
  String myLeechRule;
  String myPublishRule;
  String mySeedRule;
  String mySeedVolRule;
  String myMailboxRule;
  String myMessageTitle;
  String myNoticeRule;
  String myNoticeTitle;
  String myNoticeContent;
  String torrentsRule;
  String torrentTitleRule;
  String torrentSubtitleRule;
  String torrentDetailUrlRule;
  String torrentCategoryRule;
  String torrentPosterRule;
  String torrentMagnetUrlRule;
  String torrentSizeRule;
  String torrentProgressRule;
  String torrentHrRule;
  String torrentSaleRule;
  String torrentSaleExpireRule;
  String torrentReleaseRule;
  String torrentSeedersRule;
  String torrentLeechersRule;
  String torrentCompletersRule;
  String detailTitleRule;
  String detailSubtitleRule;
  String detailDownloadUrlRule;
  String detailSizeRule;
  String detailCategoryRule;
  String detailCountFilesRule;
  String detailHashRule;
  String detailFreeRule;
  String detailFreeExpireRule;
  String detailDoubanRule;
  String detailImdbRule;
  String detailPosterRule;
  String detailTagsRule;
  String torrentTagsRule;
  String detailHrRule;
  String pagePiecesHashApi;

  WebSite({
    required this.url,
    required this.name,
    required this.nickname,
    required this.logo,
    required this.tracker,
    required this.spFull,
    required this.limitSpeed,
    required this.tags,
    required this.iyuu,
    required this.alive,
    required this.signIn,
    required this.getInfo,
    required this.repeatTorrents,
    required this.brushFree,
    required this.brushRss,
    required this.hrDiscern,
    required this.searchTorrents,
    required this.pageIndex,
    required this.pageTorrents,
    required this.pageSignIn,
    required this.pageControlPanel,
    required this.pageDetail,
    required this.pageDownload,
    required this.pageUser,
    required this.pageSearch,
    required this.pageMessage,
    required this.pageHr,
    required this.pageLeeching,
    required this.pageUploaded,
    required this.pageSeeding,
    required this.pageCompleted,
    required this.pageMyBonus,
    required this.pageViewFileList,
    required this.myUidRule,
    required this.type,
    required this.nation,
    required this.hr,
    required this.hrRate,
    required this.hrTime,
    this.level,
    required this.myInvitationRule,
    required this.myTimeJoinRule,
    required this.myLatestActiveRule,
    required this.myUploadedRule,
    required this.myDownloadedRule,
    required this.myRatioRule,
    required this.myBonusRule,
    required this.myPerHourBonusRule,
    required this.myScoreRule,
    required this.myLevelRule,
    required this.myPasskeyRule,
    required this.myHrRule,
    required this.myLeechRule,
    required this.myPublishRule,
    required this.mySeedRule,
    required this.mySeedVolRule,
    required this.myMailboxRule,
    required this.myMessageTitle,
    required this.myNoticeRule,
    required this.myNoticeTitle,
    required this.myNoticeContent,
    required this.torrentsRule,
    required this.torrentTitleRule,
    required this.torrentSubtitleRule,
    required this.torrentDetailUrlRule,
    required this.torrentCategoryRule,
    required this.torrentPosterRule,
    required this.torrentMagnetUrlRule,
    required this.torrentSizeRule,
    required this.torrentProgressRule,
    required this.torrentHrRule,
    required this.torrentSaleRule,
    required this.torrentSaleExpireRule,
    required this.torrentReleaseRule,
    required this.torrentSeedersRule,
    required this.torrentLeechersRule,
    required this.torrentCompletersRule,
    required this.detailTitleRule,
    required this.detailSubtitleRule,
    required this.detailDownloadUrlRule,
    required this.detailSizeRule,
    required this.detailCategoryRule,
    required this.detailCountFilesRule,
    required this.detailHashRule,
    required this.detailFreeRule,
    required this.detailFreeExpireRule,
    required this.detailDoubanRule,
    required this.detailImdbRule,
    required this.detailPosterRule,
    required this.detailTagsRule,
    required this.torrentTagsRule,
    required this.detailHrRule,
    required this.pagePiecesHashApi,
  });

  factory WebSite.fromJson(Map<String, dynamic> json) {
    try {
      return WebSite(
        url: List<String>.from(json['url'] ?? []),
        name: json['name'] ?? '',
        nickname: json['nickname'] ?? '',
        logo: json['logo'] ?? '',
        tracker: json['tracker'] ?? '',
        spFull: (json['sp_full'] as num?)?.toInt() ?? 0,
        limitSpeed: (json['limit_speed'] as num?)?.toInt() ?? 0,
        tags: json['tags'] ?? '',
        iyuu: (json['iyuu'] as num?)?.toInt() ?? 0,
        alive: json['alive'] ?? false,
        signIn: json['sign_in'] ?? false,
        getInfo: json['get_info'] ?? false,
        repeatTorrents: json['repeat_torrents'] ?? false,
        brushFree: json['brush_free'] ?? false,
        brushRss: json['brush_rss'] ?? false,
        hrDiscern: json['hr_discern'] ?? false,
        searchTorrents: json['search_torrents'] ?? false,
        pageIndex: json['page_index'] ?? '',
        pageTorrents: json['page_torrents'] ?? '',
        pageSignIn: json['page_sign_in'] ?? '',
        pageControlPanel: json['page_control_panel'] ?? '',
        pageDetail: json['page_detail'] ?? '',
        pageDownload: json['page_download'] ?? '',
        pageUser: json['page_user'] ?? '',
        pageSearch: json['page_search'] != null
            ? json['page_search'] is String
                ? [json['page_search']]
                : List<String>.from(json['page_search'] as List<dynamic>)
            : [],
        pageMessage: json['page_message'] ?? '',
        pageHr: json['page_hr'] ?? '',
        pageLeeching: json['page_leeching'] ?? '',
        pageUploaded: json['page_uploaded'] ?? '',
        pageSeeding: json['page_seeding'] ?? '',
        pageCompleted: json['page_completed'] ?? '',
        pageMyBonus: json['page_mybonus'] ?? '',
        pageViewFileList: json['page_viewfilelist'] ?? '',
        myUidRule: json['my_uid_rule'] ?? '',
        type: json['type'] ?? '',
        nation: json['nation'] ?? '',
        hr: json['hr'] ?? false,
        hrRate: (json['hr_rate'] as num?)?.toInt() ?? 0,
        hrTime: (json['hr_time'] as num?)?.toInt() ?? 0,
        level: json.containsKey('level')
            ? (json['level'] as Map<String, dynamic>).map((key, value) => MapEntry(key, LevelInfo.fromJson(value)))
            : null,
        myInvitationRule: json['my_invitation_rule'] ?? '',
        myTimeJoinRule: json['my_time_join_rule'] ?? '',
        myLatestActiveRule: json['my_latest_active_rule'] ?? '',
        myUploadedRule: json['my_uploaded_rule'] ?? '',
        myDownloadedRule: json['my_downloaded_rule'] ?? '',
        myRatioRule: json['my_ratio_rule'] ?? '',
        myBonusRule: json['my_bonus_rule'] ?? '',
        myPerHourBonusRule: json['my_per_hour_bonus_rule'] ?? '',
        myScoreRule: json['my_score_rule'] ?? '',
        myLevelRule: json['my_level_rule'] ?? '',
        myPasskeyRule: json['my_passkey_rule'] ?? '',
        myHrRule: json['my_hr_rule'] ?? '',
        myLeechRule: json['my_leech_rule'] ?? '',
        myPublishRule: json['my_publish_rule'] ?? '',
        mySeedRule: json['my_seed_rule'] ?? '',
        mySeedVolRule: json['my_seed_vol_rule'] ?? '',
        myMailboxRule: json['my_mailbox_rule'] ?? '',
        myMessageTitle: json['my_message_title'] ?? '',
        myNoticeRule: json['my_notice_rule'] ?? '',
        myNoticeTitle: json['my_notice_title'] ?? '',
        myNoticeContent: json['my_notice_content'] ?? '',
        torrentsRule: json['torrents_rule'] ?? '',
        torrentTitleRule: json['torrent_title_rule'] ?? '',
        torrentSubtitleRule: json['torrent_subtitle_rule'] ?? '',
        torrentDetailUrlRule: json['torrent_detail_url_rule'] ?? '',
        torrentCategoryRule: json['torrent_category_rule'] ?? '',
        torrentPosterRule: json['torrent_poster_rule'] ?? '',
        torrentMagnetUrlRule: json['torrent_magnet_url_rule'] ?? '',
        torrentSizeRule: json['torrent_size_rule'] ?? '',
        torrentProgressRule: json['torrent_progress_rule'] ?? '',
        torrentHrRule: json['torrent_hr_rule'] ?? '',
        torrentSaleRule: json['torrent_sale_rule'] ?? '',
        torrentSaleExpireRule: json['torrent_sale_expire_rule'] ?? '',
        torrentReleaseRule: json['torrent_release_rule'] ?? '',
        torrentSeedersRule: json['torrent_seeders_rule'] ?? '',
        torrentLeechersRule: json['torrent_leechers_rule'] ?? '',
        torrentCompletersRule: json['torrent_completers_rule'] ?? '',
        detailTitleRule: json['detail_title_rule'] ?? '',
        detailSubtitleRule: json['detail_subtitle_rule'] ?? '',
        detailDownloadUrlRule: json['detail_download_url_rule'] ?? '',
        detailSizeRule: json['detail_size_rule'] ?? '',
        detailCategoryRule: json['detail_category_rule'] ?? '',
        detailCountFilesRule: json['detail_count_files_rule'] ?? '',
        detailHashRule: json['detail_hash_rule'] ?? '',
        detailFreeRule: json['detail_free_rule'] ?? '',
        detailFreeExpireRule: json['detail_free_expire_rule'] ?? '',
        detailDoubanRule: json['detail_douban_rule'] ?? '',
        detailImdbRule: json['detail_imdb_rule'] ?? '',
        detailPosterRule: json['detail_poster_rule'] ?? '',
        detailTagsRule: json['detail_tags_rule'] ?? '',
        torrentTagsRule: json['torrent_tags_rule'] ?? '',
        detailHrRule: json['detail_hr_rule'] ?? '',
        pagePiecesHashApi: json['page_pieces_hash_api'] ?? '',
      );
    } catch (e, trace) {
      Logger.instance.i(json);
      Logger.instance.w(e.toString());
      Logger.instance.e(trace.toString());
      rethrow; // 重新抛出异常以便上层处理
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WebSite && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => '站点信息：$name - $nickname';
}

class LevelInfo {
  int levelId;
  String level;
  int days;
  String uploaded;
  String downloaded;
  double ratio;
  int torrents;
  int leeches;
  num score;
  num bonus;
  num seedingDelta;
  bool keepAccount;
  bool graduation;
  String rights;

  // 默认构造函数
  LevelInfo({
    required this.levelId,
    required this.level,
    required this.days,
    required this.uploaded,
    required this.downloaded,
    required this.ratio,
    required this.torrents,
    required this.leeches,
    required this.score,
    required this.bonus,
    required this.seedingDelta,
    required this.keepAccount,
    required this.graduation,
    required this.rights,
  });

  // 从 JSON 构造函数
  LevelInfo.fromJson(Map<String, dynamic> json)
      : levelId = json['level_id']?.toInt() ?? -1,
        // 设置合理的默认值
        level = json['level'] ?? '未知',
        days = (json['days'] as num?)?.toInt() ?? 0,
        uploaded = json['uploaded'] ?? '未知',
        downloaded = json['downloaded'] ?? '未知',
        ratio = (json['ratio'] as num?)?.toDouble() ?? 0.0,
        torrents = (json['torrents'] as num?)?.toInt() ?? 0,
        score = json['score'] ?? 0,
        bonus = json['bonus'] ?? 0,
        leeches = (json['leeches'] as num?)?.toInt() ?? 0,
        seedingDelta = json['seeding_delta'] ?? 0,
        keepAccount = json['keep_account'] ?? false,
        graduation = json['graduation'] ?? false,
        rights = json['rights'] ?? '未知';

  @override
  String toString() {
    return '$level：$rights';
  }
}
