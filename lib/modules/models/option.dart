class OptionValue {
  String? token;
  String? refreshToken;
  String? server;
  String? key;
  String? password;
  String? apiKey;
  String? secretKey;
  String? appId;
  String? uids;
  String? pushKey;
  String? deviceKey;
  bool? repeat;
  bool? welfare;
  String? proxy;
  String? telegramToken;
  String? telegramChatId;
  String? template;
  String? corpId;
  String? corpSecret;
  String? agentId;
  String? toUid;
  String? username;
  String? cookie;
  String? userAgent;
  String? todaySay;
  bool? aliyundriveNotice;
  bool? siteData;
  bool? siteDataSuccess;
  bool? todayData;
  bool? packageTorrent;
  bool? deleteTorrent;
  bool? rssTorrent;
  bool? pushTorrent;
  bool? programUpgrade;
  bool? ptppImport;
  bool? announcement;
  bool? message;
  bool? signInSuccess;
  bool? cookieSync;
  bool? level;
  bool? bonus;
  bool? perBonus;
  bool? score;
  bool? ratio;
  bool? seedingVol;
  bool? uploaded;
  bool? downloaded;
  bool? seeding;
  bool? leeching;
  bool? invite;
  bool? hr;
  int? count;
  int? maxCount;
  int? limit;

  OptionValue({
    this.token,
    this.refreshToken,
    this.server,
    this.key,
    this.password,
    this.apiKey,
    this.secretKey,
    this.appId,
    this.uids,
    this.pushKey,
    this.deviceKey,
    this.repeat,
    this.proxy,
    this.telegramToken,
    this.telegramChatId,
    this.template,
    this.corpId,
    this.corpSecret,
    this.agentId,
    this.toUid,
    this.welfare,
    this.username,
    this.cookie,
    this.userAgent,
    this.todaySay,
    this.aliyundriveNotice,
    this.siteData,
    this.siteDataSuccess,
    this.todayData,
    this.packageTorrent,
    this.deleteTorrent,
    this.rssTorrent,
    this.pushTorrent,
    this.programUpgrade,
    this.ptppImport,
    this.announcement,
    this.message,
    this.signInSuccess,
    this.cookieSync,
    this.level,
    this.bonus,
    this.perBonus,
    this.score,
    this.ratio,
    this.seedingVol,
    this.uploaded,
    this.downloaded,
    this.seeding,
    this.leeching,
    this.invite,
    this.hr,
    this.count,
    this.maxCount,
    this.limit,
  });

  factory OptionValue.fromJson(Map<String, dynamic>? json) => OptionValue(
        token: json?['token'],
        refreshToken: json?['refresh_token'].toString(),
        server: json?['server'],
        key: json?['key'],
        password: json?['password'],
        apiKey: json?['api_key'],
        secretKey: json?['secret_key'],
        appId: json?['app_id'],
        uids: json?['uids'],
        pushKey: json?['pushkey'],
        deviceKey: json?['device_key'],
        repeat: json?['repeat'],
        welfare: json?['welfare'],
        proxy: json?['proxy'],
        telegramToken: json?['telegram_token'],
        telegramChatId: json?['telegram_chat_id'],
        template: json?['template'],
        corpId: json?['corp_id'],
        corpSecret: json?['corpsecret'],
        agentId: json?['agent_id'],
        toUid: json?['to_uid'],
        username: json?['username'],
        cookie: json?['cookie'],
        userAgent: json?['user_agent'],
        todaySay: json?['todaysay'].toString(),
        aliyundriveNotice: json?['aliyundrive_notice'],
        siteData: json?['site_data'],
        siteDataSuccess: json?['site_data_success'],
        todayData: json?['today_data'],
        packageTorrent: json?['package_torrent'],
        deleteTorrent: json?['delete_torrent'],
        rssTorrent: json?['rss_torrent'],
        pushTorrent: json?['push_torrent'],
        programUpgrade: json?['program_upgrade'],
        ptppImport: json?['ptpp_import'],
        announcement: json?['announcement'],
        message: json?['message'],
        signInSuccess: json?['sign_in_success'],
        cookieSync: json?['cookie_sync'],
        level: json?['level'],
        bonus: json?['bonus'],
        perBonus: json?['per_bonus'],
        score: json?['score'],
        ratio: json?['ratio'],
        seedingVol: json?['seeding_vol'],
        uploaded: json?['uploaded'],
        downloaded: json?['downloaded'],
        seeding: json?['seeding'],
        leeching: json?['leeching'],
        invite: json?['invite'],
        hr: json?['hr'],
        count: json?['count'],
        maxCount: json?['max_count'],
        limit: json?['limit'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (token != null) data['token'] = token!;
    if (refreshToken != null) data['refresh_token'] = refreshToken!;
    if (server != null) data['server'] = server!;
    if (key != null) data['key'] = key!;
    if (password != null) data['password'] = password!;
    if (apiKey != null) data['api_key'] = apiKey!;
    if (secretKey != null) data['secret_key'] = secretKey!;
    if (appId != null) data['app_id'] = appId!;
    if (uids != null) data['uids'] = uids!;
    if (pushKey != null) data['pushkey'] = pushKey!;
    if (deviceKey != null) data['device_key'] = deviceKey!;
    if (repeat != null) data['repeat'] = repeat!;
    if (welfare != null) data['repeat'] = welfare!;
    if (proxy != null) data['proxy'] = proxy!;
    if (telegramToken != null) data['telegram_token'] = telegramToken!;
    if (telegramChatId != null) data['telegram_chat_id'] = telegramChatId!;
    if (template != null) data['template'] = template!;
    if (corpId != null) data['corp_id'] = corpId!;
    if (corpSecret != null) data['corpsecret'] = corpSecret!;
    if (agentId != null) data['agent_id'] = agentId!;
    if (toUid != null) data['to_uid'] = toUid!;
    if (username != null) data['username'] = username!;
    if (cookie != null) data['cookie'] = cookie!;
    if (userAgent != null) data['user_agent'] = userAgent!;
    if (todaySay != null) data['todaysay'] = todaySay!;
    if (aliyundriveNotice != null) {
      data['aliyundrive_notice'] = aliyundriveNotice!;
    }
    if (siteData != null) data['site_data'] = siteData!;
    if (todayData != null) data['today_data'] = todayData!;
    if (packageTorrent != null) data['package_torrent'] = packageTorrent!;
    if (deleteTorrent != null) data['delete_torrent'] = deleteTorrent!;
    if (rssTorrent != null) data['rss_torrent'] = rssTorrent!;
    if (pushTorrent != null) data['push_torrent'] = pushTorrent!;
    if (programUpgrade != null) data['program_upgrade'] = programUpgrade!;
    if (ptppImport != null) data['ptpp_import'] = ptppImport!;
    if (announcement != null) data['announcement'] = announcement!;
    if (message != null) data['message'] = message!;
    if (signInSuccess != null) data['sign_in_success'] = signInSuccess!;
    if (siteDataSuccess != null) data['site_data_success'] = siteDataSuccess!;
    if (cookieSync != null) data['cookie_sync'] = cookieSync!;
    if (level != null) data['level'] = level!;
    if (bonus != null) data['bonus'] = bonus!;
    if (perBonus != null) data['per_bonus'] = perBonus!;
    if (score != null) data['score'] = score!;
    if (ratio != null) data['ratio'] = ratio!;
    if (seedingVol != null) data['seeding_vol'] = seedingVol!;
    if (uploaded != null) data['uploaded'] = uploaded!;
    if (downloaded != null) data['downloaded'] = downloaded!;
    if (seeding != null) data['seeding'] = seeding!;
    if (leeching != null) data['leeching'] = leeching!;
    if (invite != null) data['invite'] = invite!;
    if (hr != null) data['hr'] = hr!;
    if (count != null) data['count'] = count!;
    if (maxCount != null) data['max_count'] = maxCount!;
    if (limit != null) data['limit'] = limit!;
    return data;
  }
}

class Option {
  int id;
  String name;
  OptionValue value;
  bool isActive;

  Option({
    required this.id,
    required this.name,
    required this.value,
    required this.isActive,
  });

  @override
  String toString() {
    return '配置项：$name';
  }

  // 从JSON构造Option对象
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      name: json['name'] as String,
      value: OptionValue.fromJson(json['value']),
      isActive: json['is_active'] as bool,
      id: json['id'] as int,
    );
  }

  // 将Option对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value.toJson(),
      'is_active': isActive,
    };
  }
}

class SelectOption {
  String name;
  String value;

  SelectOption({
    required this.name,
    required this.value,
  });

  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      name: json['name'] as String,
      value: json['value'] as String,
    );
  }

  @override
  String toString() {
    return 'SelectOption：$name';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
