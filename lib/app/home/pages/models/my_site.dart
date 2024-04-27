class SignInInfo {
  String updatedAt;
  String info;

  SignInInfo({required this.updatedAt, required this.info});

  factory SignInInfo.fromJson(Map<String, dynamic> json) {
    return SignInInfo(
      updatedAt: json['updated_at'] != null
          ? json['updated_at'] as String
          : json['time'] as String,
      info: json['info'] as String,
    );
  }
}

class StatusInfo {
  double ratio;
  int downloaded;
  int uploaded;
  double myBonus;
  double myScore;
  double bonusHour;
  int seed;
  int leech;
  int invitation;
  int publish;
  int seedDays;
  String myHr;
  String myLevel;
  int seedVolume;
  DateTime updatedAt;
  DateTime createdAt;

  StatusInfo({
    required this.ratio,
    required this.downloaded,
    required this.uploaded,
    required this.myBonus,
    required this.myScore,
    required this.bonusHour,
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
      downloaded: json['downloaded'] as int,
      uploaded: json['uploaded'] as int,
      myBonus: double.parse(json['my_bonus'].toString()),
      myScore: double.parse(json['my_score'].toString()),
      bonusHour: json['bonus_hour'] != null
          ? double.parse(json['bonus_hour'].toString())
          : 0.0,
      seed: json['seed'] as int,
      leech: json['leech'] as int,
      invitation: json['invitation'] ?? 0,
      publish: json['publish'] ?? 0,
      seedDays: json['seed_days'] != null
          ? double.parse(json['seed_days'].toString()).toInt()
          : 0,
      myHr: json['my_hr'] ?? '',
      myLevel: json['my_level'] as String,
      seedVolume: json['seed_volume'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.parse(json['updated_at'] as String),
    );
  }
}

class MySite {
  final int id;
  final String site;
  final String nickname;
  final int sortId;
  final String? userId;
  final String? passkey;
  final String? authKey;
  final String? cookie;
  final String? userAgent;
  final String? proxy;
  final String? mirror;
  final String? rss;
  final String? torrents;
  final bool available;
  final bool signIn;
  final bool getInfo;
  final bool repeatTorrents;
  final bool brushFree;
  final bool brushRss;
  final bool packageFile;
  final bool hrDiscern;
  final bool searchTorrents;
  final Map<String, dynamic>? removeTorrentRules;
  final String timeJoin;
  final int? mail;
  final int? notice;
  final Map<String, SignInInfo> signInInfo;
  final Map<String, StatusInfo> statusInfo;
  final DateTime? updatedAt;

  MySite({
    required this.id,
    required this.site,
    required this.nickname,
    required this.sortId,
    this.userId,
    this.passkey,
    this.authKey,
    this.cookie,
    this.userAgent,
    this.proxy,
    this.mirror,
    this.rss,
    this.torrents,
    this.updatedAt,
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
    Map<String, SignInInfo> signInInfo =
        (json['sign_info'] as Map<String, dynamic>? ?? {}).map((key, value) =>
            MapEntry(key, SignInInfo.fromJson(value as Map<String, dynamic>)));

    Map<String, StatusInfo> statusInfo =
        (json['status'] as Map<String, dynamic>? ?? {}).map((key, value) =>
            MapEntry(key, StatusInfo.fromJson(value as Map<String, dynamic>)));

    return MySite(
      id: json['id'] as int,
      site: json['site'] as String,
      nickname: json['nickname'] as String,
      sortId: json['sort_id'] as int,
      userId: json['user_id'] as String?,
      passkey: json['passkey'] as String?,
      authKey: json['authkey'] as String?,
      cookie: json['cookie'] as String?,
      userAgent: json['user_agent'] as String?,
      proxy: json['proxy'] as String?,
      mirror: json['mirror'] as String?,
      rss: json['rss'] as String?,
      torrents: json['torrents'] as String?,
      available: json['available'] as bool? ?? false,
      signIn: json['sign_in'] as bool? ?? false,
      getInfo: json['get_info'] as bool? ?? false,
      repeatTorrents: json['repeat_torrents'] as bool? ?? false,
      brushFree: json['brush_free'] as bool? ?? false,
      brushRss: json['brush_rss'] as bool? ?? false,
      packageFile: json['package_file'] as bool? ?? false,
      hrDiscern: json['hr_discern'] as bool? ?? false,
      searchTorrents: json['search_torrents'] as bool? ?? false,
      removeTorrentRules: json['remove_torrent_rules'] as Map<String, dynamic>?,
      timeJoin: json['time_join'] as String,
      mail: json['mail'] as int?,
      notice: json['notice'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      signInInfo: signInInfo,
      statusInfo: statusInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'site': site,
      'sort_id': sortId,
      'available': available,
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
      'updated_at': updatedAt,
    };
  }

  StatusInfo? getLatestStatusInfo() {
    if (statusInfo.isEmpty) {
      return null;
    }
    return statusInfo[getStatusMaxKey()];
  }

  StatusInfo? get latestStatusInfo {
    return getLatestStatusInfo();
  }

  String getStatusMaxKey() {
    if (statusInfo.isEmpty) {
      return '';
    }
    if (statusInfo.length == 1) {
      return statusInfo.keys.first;
    }
    return statusInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  String getSignMaxKey() {
    if (signInInfo.isEmpty) {
      return '';
    }
    if (signInInfo.length == 1) {
      return signInInfo.keys.first;
    }
    return signInInfo.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
  }

  MySite copyWith({
    int? id,
    String? site,
    String? nickname,
    int? sortId,
    String? userId,
    String? passkey,
    String? authKey,
    String? cookie,
    String? userAgent,
    String? proxy,
    String? mirror,
    String? rss,
    String? torrents,
    bool? available,
    bool? signIn,
    bool? getInfo,
    bool? repeatTorrents,
    bool? brushFree,
    bool? brushRss,
    bool? packageFile,
    bool? hrDiscern,
    bool? searchTorrents,
    Map<String, dynamic>? removeTorrentRules,
    String? timeJoin,
    int? mail,
    int? notice,
    Map<String, SignInInfo>? signInInfo,
    Map<String, StatusInfo>? statusInfo,
  }) {
    return MySite(
      id: id ?? this.id,
      site: site ?? this.site,
      nickname: nickname ?? this.nickname,
      sortId: sortId ?? this.sortId,
      userId: userId ?? this.userId,
      passkey: passkey ?? this.passkey,
      authKey: authKey ?? this.authKey,
      cookie: cookie ?? this.cookie,
      userAgent: userAgent ?? this.userAgent,
      proxy: proxy ?? this.proxy,
      mirror: mirror ?? this.mirror,
      rss: rss ?? this.rss,
      torrents: torrents ?? this.torrents,
      available: available ?? this.available,
      signIn: signIn ?? this.signIn,
      getInfo: getInfo ?? this.getInfo,
      repeatTorrents: repeatTorrents ?? this.repeatTorrents,
      brushFree: brushFree ?? this.brushFree,
      brushRss: brushRss ?? this.brushRss,
      packageFile: packageFile ?? this.packageFile,
      hrDiscern: hrDiscern ?? this.hrDiscern,
      searchTorrents: searchTorrents ?? this.searchTorrents,
      removeTorrentRules: removeTorrentRules ?? this.removeTorrentRules,
      timeJoin: timeJoin ?? this.timeJoin,
      mail: mail ?? this.mail,
      notice: notice ?? this.notice,
      signInInfo: signInInfo ?? this.signInInfo,
      statusInfo: statusInfo ?? this.statusInfo,
    );
  }
}
