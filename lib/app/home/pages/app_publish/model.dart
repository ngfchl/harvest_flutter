class AdminUser {
  // final String uuid;
  final String? createdAt;
  final String? updatedAt;
  final String? username;
  final String email;
  final int? pay;
  final int? invite;
  final int? id;
  final String? invitedById;
  final bool? tryUser;

  // final String? token;
  final String? marked;
  final String? timeExpire;

  AdminUser({
    // required this.uuid,
    this.createdAt,
    this.updatedAt,
    required this.username,
    required this.email,
    this.pay,
    this.invite,
    this.id,
    this.invitedById,
    this.tryUser,
    // this.token,
    this.marked,
    this.timeExpire,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      // uuid: json['uuid'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String,
      pay: json['pay'] as int,
      invite: json['invite'] as int,
      id: json['id'] as int,
      invitedById: json['invited_by_id'] as String?,
      tryUser: json['try_user'] as bool,
      // token: json['token'] as String?,
      marked: json['marked'],
      timeExpire: json['time_expire'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'uuid': uuid,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'username': username,
      'email': email,
      'pay': pay,
      'invite': invite,
      'id': id,
      'invited_by_id': invitedById,
      'try_user': tryUser,
      // 'token': token,
      'marked': marked,
      'time_expire': timeExpire,
    };
  }

  // ✅ copyWith 方法
  AdminUser copyWith({
    String? uuid,
    String? createdAt,
    String? updatedAt,
    String? username,
    String? email,
    int? pay,
    int? invite,
    int? id,
    String? invitedById,
    bool? tryUser,
    String? token,
    String? marked,
    String? timeExpire,
  }) {
    return AdminUser(
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      email: email ?? this.email,
      pay: pay ?? this.pay,
      invite: invite ?? this.invite,
      id: id ?? this.id,
      invitedById: invitedById ?? this.invitedById,
      tryUser: tryUser ?? this.tryUser,
      marked: marked ?? this.marked,
      timeExpire: timeExpire ?? this.timeExpire,
    );
  }
}
