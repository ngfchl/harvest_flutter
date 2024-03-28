class AuthInfo {
  String? authToken;
  String? user;

  AuthInfo({this.authToken, this.user});

  AuthInfo.fromJson(Map<String, dynamic> json) {
    authToken = json['auth_token'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['auth_token'] = this.authToken;
    data['user'] = this.user;
    return data;
  }
}
