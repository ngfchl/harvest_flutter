import 'package:harvest/utils/logger_helper.dart';

class SignInInfo {
  late String updatedAt;
  late String info;

  SignInInfo({
    required this.updatedAt,
    required this.info,
  });

  factory SignInInfo.fromJson(Map<String, dynamic> json) {
    return SignInInfo(
      updatedAt: json['updated_at'] ?? '',
      info: json['info'],
    );
  }
}

class StatusInfo {
  late double ratio;
  late int downloaded;
  late int uploaded;
  late double myBonus;
  late double myScore;
  late double bonusHour;
  late int seed;
  late int leech;
  late int invitation;
  late int publish;
  late int seedDays;
  late String myHr;
  late String myLevel;
  late int seedVolume;
  late String updatedAt;
  late String createdAt;

  StatusInfo({
    required this.ratio,
    required this.downloaded,
    required this.uploaded,
    required this.myBonus,
    required this.bonusHour,
    required this.myScore,
    required this.seed,
    required this.leech,
    required this.invitation,
    required this.publish,
    required this.seedDays,
    required this.myHr,
    required this.myLevel,
    required this.seedVolume,
    required this.updatedAt,
    required this.createdAt,
  });

  factory StatusInfo.fromJson(Map<String, dynamic> json) {
    return StatusInfo(
      ratio: json['downloaded'] > 0 ? json['uploaded'] / json['downloaded'] : 0,
      downloaded: json['downloaded'],
      uploaded: json['uploaded'],
      myBonus: json['my_bonus'].toDouble(),
      myScore: json['my_score'].toDouble(),
      bonusHour: json['bonus_hour'] != null
          ? double.parse(json['bonus_hour'].toString())
          : 0,
      seed: json['seed'],
      leech: json['leech'],
      invitation: json['invitation'] ?? 0,
      publish: json['publish'] ?? 0,
      seedDays: json['seed_days'] != null ? json['seed_days'].toInt() : 0,
      myHr: json['my_hr'] ?? '',
      myLevel: json['my_level'],
      seedVolume: json['seed_volume'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class MySite {
  late int id;
  late String updatedAt;
  late String site;
  late String nickname;
  late int sortId;
  late String? userId;
  late String? passkey;
  late String? authKey;
  late String? cookie;
  late String? userAgent;
  late String? proxy;
  late String? mirror;
  late String? rss;
  late String? torrents;
  late bool available;
  late bool signIn;
  late bool getInfo;
  late bool repeatTorrents;
  late bool brushFree;
  late bool brushRss;
  late bool packageFile;
  late bool hrDiscern;
  late bool searchTorrents;
  late Map<String, dynamic> removeTorrentRules;
  late String timeJoin;
  late int mail;
  late int notice;
  late Map<String, SignInInfo> signInInfo;
  late Map<String, StatusInfo> statusInfo;

  MySite({
    required this.id,
    required this.updatedAt,
    required this.site,
    required this.nickname,
    required this.sortId,
    required this.userId,
    required this.passkey,
    required this.authKey,
    required this.cookie,
    required this.userAgent,
    required this.proxy,
    required this.mirror,
    required this.rss,
    required this.torrents,
    required this.available,
    required this.signIn,
    required this.getInfo,
    required this.repeatTorrents,
    required this.brushFree,
    required this.brushRss,
    required this.packageFile,
    required this.hrDiscern,
    required this.searchTorrents,
    required this.removeTorrentRules,
    required this.timeJoin,
    required this.mail,
    required this.notice,
    required this.signInInfo,
    required this.statusInfo,
  });

  factory MySite.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> signInInfoJson = json['sign_info'] ?? {};
    Map<String, dynamic> statusInfoJson = json['status'] ?? {};
    Map<String, SignInInfo> signInInfo = {};
    Map<String, StatusInfo> statusInfo = {};
    try {
      signInInfo = signInInfoJson.map((key, value) =>
          MapEntry(key, SignInInfo.fromJson(value as Map<String, dynamic>)));

      statusInfo = statusInfoJson.map((key, value) =>
          MapEntry(key, StatusInfo.fromJson(value as Map<String, dynamic>)));
    } catch (e, trace) {
      Logger.instance.e(json['nickname']);
      Logger.instance.w(e.toString());
      Logger.instance.e(trace.toString());
    }

    return MySite(
      id: json['id'],
      updatedAt: json['updated_at'],
      site: json['site'],
      nickname: json['nickname'],
      sortId: json['sort_id'],
      userId: json['user_id'],
      passkey: json['passkey'] ?? '',
      authKey: json['authkey'] ?? '',
      cookie: json['cookie'],
      userAgent: json['user_agent'],
      proxy: json['proxy'],
      mirror: json['mirror'],
      rss: json['rss'],
      torrents: json['torrents'],
      available: json['available'] ?? false,
      signIn: json['sign_in'] ?? false,
      getInfo: json['get_info'] ?? false,
      repeatTorrents: json['repeat_torrents'] ?? false,
      brushFree: json['brush_free'] ?? false,
      brushRss: json['brush_rss'] ?? false,
      packageFile: json['package_file'] ?? false,
      hrDiscern: json['hr_discern'] ?? false,
      searchTorrents: json['search_torrents'] ?? false,
      removeTorrentRules: json['remove_torrent_rules'] ?? {},
      timeJoin: json['time_join'],
      mail: json['mail'] ?? 0,
      notice: json['notice'] ?? 0,
      signInInfo: signInInfo,
      statusInfo: statusInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site': site,
      'sort_id': sortId,
      'nickname': nickname,
      'passkey': passkey,
      'user_id': userId,
      'user_agent': userAgent,
      'rss': rss,
      'torrents': torrents,
      'cookie': cookie,
      'mirror': mirror,
      'authkey': authKey,
      'proxy': proxy,
      'get_info': getInfo,
      'sign_in': signIn,
      'brush_rss': brushRss,
      'brush_free': brushFree,
      'package_file': packageFile,
      'repeat_torrents': repeatTorrents,
      'hr_discern': hrDiscern,
      'search_torrents': searchTorrents,
      'remove_torrent_rules': removeTorrentRules,
    };
  }

  String getStatusMaxKey() {
    if (statusInfo.isEmpty) {
      return '';
    }

    return statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  String getSignMaxKey() {
    if (statusInfo.isEmpty) {
      return '';
    }
    return signInInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }
}
