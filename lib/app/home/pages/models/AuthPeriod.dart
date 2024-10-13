class AuthPeriod {
  late String username;
  late String timeExpire;

  AuthPeriod({
    required this.username,
    required this.timeExpire,
  });

  AuthPeriod.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    timeExpire = json['time_expire'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['username'] = username;
    map['time_expire'] = timeExpire;
    return map;
  }
}
