import '../../../../utils/logger_helper.dart';

class WebSite {
  late List<String> url;
  late String name;
  late String nickname;
  late String logo;
  late String tracker;
  late int spFull;
  late int limitSpeed;
  late String tags;
  late int iyuu;
  late bool alive;
  late bool signIn;
  late bool getInfo;
  late bool repeatTorrents;
  late bool brushFree;
  late bool brushRss;
  late bool hrDiscern;
  late bool searchTorrents;
  late String pageIndex;
  late String pageTorrents;
  late String pageSignIn;
  late String pageControlPanel;
  late String pageDetail;
  late String pageDownload;
  late String pageUser;
  late String pageSearch;
  late String pageMessage;
  late String pageHr;
  late String pageLeeching;
  late String pageUploaded;
  late String pageSeeding;
  late String pageCompleted;
  late String pageMyBonus;
  late String pageViewFileList;
  late String myUidRule;
  late bool hr;
  late int hrRate;
  late int hrTime;
  late Map<String, LevelInfo>? level;

// New properties
  late String myInvitationRule;
  late String myTimeJoinRule;
  late String myLatestActiveRule;
  late String myUploadedRule;
  late String myDownloadedRule;
  late String myRatioRule;
  late String myBonusRule;
  late String myPerHourBonusRule;
  late String myScoreRule;
  late String myLevelRule;
  late String myPasskeyRule;
  late String myHrRule;
  late String myLeechRule;
  late String myPublishRule;
  late String mySeedRule;
  late String mySeedVolRule;
  late String myMailboxRule;
  late String myMessageTitle;
  late String myNoticeRule;
  late String myNoticeTitle;
  late String myNoticeContent;
  late String torrentsRule;
  late String torrentTitleRule;
  late String torrentSubtitleRule;
  late String torrentDetailUrlRule;
  late String torrentCategoryRule;
  late String torrentPosterRule;
  late String torrentMagnetUrlRule;
  late String torrentSizeRule;
  late String torrentProgressRule;
  late String torrentHrRule;
  late String torrentSaleRule;
  late String torrentSaleExpireRule;
  late String torrentReleaseRule;
  late String torrentSeedersRule;
  late String torrentLeechersRule;
  late String torrentCompletersRule;
  late String detailTitleRule;
  late String detailSubtitleRule;
  late String detailDownloadUrlRule;
  late String detailSizeRule;
  late String detailCategoryRule;
  late String detailCountFilesRule;
  late String detailHashRule;
  late String detailFreeRule;
  late String detailFreeExpireRule;
  late String detailDoubanRule;
  late String detailImdbRule;
  late String detailPosterRule;
  late String detailTagsRule;
  late String torrentTagsRule;
  late String detailHrRule;
  late String pagePiecesHashApi;

  WebSite.fromJson(Map<String, dynamic> json) {
    try {
      url = List<String>.from(json['url']);
      name = json['name'];
      nickname = json['nickname'];
      logo = json['logo'];
      alive = json['alive'];
      tracker = json['tracker'];
      spFull = json['sp_full'];
      limitSpeed = json['limit_speed'];
      tags = json['tags'];
      iyuu = json['iyuu'];
      signIn = json['sign_in'];
      getInfo = json['get_info'];
      repeatTorrents = json['repeat_torrents'];
      brushFree = json['brush_free'];
      brushRss = json['brush_rss'];
      hrDiscern = json['hr_discern'];
      searchTorrents = json['search_torrents'];
      pageIndex = json['page_index'];
      pageTorrents = json['page_torrents'];
      pageSignIn = json['page_sign_in'];
      pageControlPanel = json['page_control_panel'];
      pageDetail = json['page_detail'];
      pageDownload = json['page_download'];
      pageUser = json['page_user'];
      pageSearch = json['page_search'];
      pageMessage = json['page_message'];
      pageHr = json['page_hr'];
      pageLeeching = json['page_leeching'];
      pageUploaded = json['page_uploaded'];
      pageSeeding = json['page_seeding'];
      pageCompleted = json['page_completed'];
      pageMyBonus = json['page_mybonus'];
      pageViewFileList = json['page_viewfilelist'];
      myUidRule = json['my_uid_rule'];
      hr = json['hr'];
      hrRate = json['hr_rate'];
      hrTime = json['hr_time'];
      level = null;

      level = json.containsKey('level')
          ? (json['level'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, LevelInfo.fromJson(value)))
          : null;

      // Parsing new attributes
      myInvitationRule = json['my_invitation_rule'];
      myTimeJoinRule = json['my_time_join_rule'];
      myLatestActiveRule = json['my_latest_active_rule'];
      myUploadedRule = json['my_uploaded_rule'];
      myDownloadedRule = json['my_downloaded_rule'];
      myRatioRule = json['my_ratio_rule'];
      myBonusRule = json['my_bonus_rule'];
      myPerHourBonusRule = json['my_per_hour_bonus_rule'];
      myScoreRule = json['my_score_rule'];
      myLevelRule = json['my_level_rule'];
      myPasskeyRule = json['my_passkey_rule'];
      myHrRule = json['my_hr_rule'];
      myLeechRule = json['my_leech_rule'];
      myPublishRule = json['my_publish_rule'];
      mySeedRule = json['my_seed_rule'];
      mySeedVolRule = json['my_seed_vol_rule'];
      myMailboxRule = json['my_mailbox_rule'];
      myMessageTitle = json['my_message_title'];
      myNoticeRule = json['my_notice_rule'];
      myNoticeTitle = json['my_notice_title'];
      myNoticeContent = json['my_notice_content'];
      torrentsRule = json['torrents_rule'];
      torrentTitleRule = json['torrent_title_rule'];
      torrentSubtitleRule = json['torrent_subtitle_rule'];
      torrentDetailUrlRule = json['torrent_detail_url_rule'];
      torrentCategoryRule = json['torrent_category_rule'];
      torrentPosterRule = json['torrent_poster_rule'];
      torrentMagnetUrlRule = json['torrent_magnet_url_rule'];
      torrentSizeRule = json['torrent_size_rule'];
      torrentProgressRule = json['torrent_progress_rule'];
      torrentHrRule = json['torrent_hr_rule'];
      torrentSaleRule = json['torrent_sale_rule'];
      torrentSaleExpireRule = json['torrent_sale_expire_rule'];
      torrentReleaseRule = json['torrent_release_rule'];
      torrentSeedersRule = json['torrent_seeders_rule'];
      torrentLeechersRule = json['torrent_leechers_rule'];
      torrentCompletersRule = json['torrent_completers_rule'];
      detailTitleRule = json['detail_title_rule'];
      detailSubtitleRule = json['detail_subtitle_rule'];
      detailDownloadUrlRule = json['detail_download_url_rule'];
      detailSizeRule = json['detail_size_rule'];
      detailCategoryRule = json['detail_category_rule'];
      detailCountFilesRule = json['detail_count_files_rule'];
      detailHashRule = json['detail_hash_rule'];
      detailFreeRule = json['detail_free_rule'];
      detailFreeExpireRule = json['detail_free_expire_rule'];
      detailDoubanRule = json['detail_douban_rule'];
      detailImdbRule = json['detail_imdb_rule'];
      detailPosterRule = json['detail_poster_rule'];
      detailTagsRule = json['detail_tags_rule'];
      torrentTagsRule = json['torrent_tags_rule'];
      detailHrRule = json['detail_hr_rule'];
      pagePiecesHashApi = json['page_pieces_hash_api'];
    } catch (e, trace) {
      Logger.instance.i(json);
      Logger.instance.w(e.toString());
      Logger.instance.e(trace.toString());
    }
  }

  @override
  String toString() => '站点信息：$name - $nickname';
}

class LevelInfo {
  late int levelId;
  late String level;
  late int days;
  late String uploaded;
  late String downloaded;
  late double ratio;
  late int torrents;
  late int leeches;
  late num score;
  late num bonus;
  late num seedingDelta;
  late bool keepAccount;
  late bool graduation;
  late String rights;

  LevelInfo.fromJson(Map<String, dynamic> json) {
    levelId = json['level_id'] ?? 0;
    level = json['level'];
    days = json['days'];
    uploaded = json['uploaded'];
    downloaded = json['downloaded'];
    ratio = json['ratio'];
    torrents = json['torrents'];
    score = json['score'];
    bonus = json['bonus'];
    leeches = json['leeches'];
    seedingDelta = json['seeding_delta'];
    keepAccount = json['keep_account'];
    graduation = json['graduation'];
    rights = json['rights'];
  }

  @override
  String toString() {
    return '$level：$rights';
  }
}
