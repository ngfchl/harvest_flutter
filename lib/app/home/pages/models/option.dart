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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
