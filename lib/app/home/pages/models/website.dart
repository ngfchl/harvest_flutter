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
    } catch (e, trace) {
      Logger.instance.i(json);
      Logger.instance.w(e.toString());
      Logger.instance.e(trace.toString());
    }
  }
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
    leeches = json['leeches'];
    seedingDelta = json['seeding_delta'];
    keepAccount = json['keep_account'];
    graduation = json['graduation'];
    rights = json['rights'];
  }
}
