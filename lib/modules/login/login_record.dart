class LoginRecord {
  final String server;
  final String username;
  final String password;
  final int timestamp;

  LoginRecord({
    required this.server,
    required this.username,
    required this.password,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'server': server,
    'username': username,
    'password': password,
    'timestamp': timestamp,
  };

  factory LoginRecord.fromJson(Map data) {
    return LoginRecord(
      server: data['server'],
      username: data['username'],
      password: data['password'],
      timestamp: data['timestamp'],
    );
  }
}