class UserModel {
  UserModel({
    required this.id,
    required this.username,
    this.password,
    required this.isActive,
    required this.isStaff,
  });

  UserModel.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    isActive = json['is_active'];
    isStaff = json['is_staff'];
  }

  late int id;
  late String username;
  late String? password;
  late bool isActive;
  bool isStaff = true;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['password'] = password;
    map['is_active'] = isActive;
    map['is_staff'] = isStaff;
    return map;
  }
}
