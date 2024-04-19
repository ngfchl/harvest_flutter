class SubHistory {
  SubHistory({
    num? id,
    num? subscribeId,
    String? siteId,
    String? magnet,
    String? message,
    bool? pushed,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _subscribeId = subscribeId;
    _siteId = siteId;
    _magnet = magnet;
    _message = message;
    _pushed = pushed;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  SubHistory.fromJson(dynamic json) {
    _id = json['id'];
    _subscribeId = json['subscribe_id'];
    _siteId = json['site_id'];
    _magnet = json['magnet'];
    _message = json['message'];
    _pushed = json['pushed'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  num? _id;
  num? _subscribeId;
  String? _siteId;
  String? _magnet;
  String? _message;
  bool? _pushed;
  String? _createdAt;
  String? _updatedAt;

  SubHistory copyWith({
    num? id,
    num? subscribeId,
    String? siteId,
    String? magnet,
    String? message,
    bool? pushed,
    String? createdAt,
    String? updatedAt,
  }) =>
      SubHistory(
        id: id ?? _id,
        subscribeId: subscribeId ?? _subscribeId,
        siteId: siteId ?? _siteId,
        magnet: magnet ?? _magnet,
        message: message ?? _message,
        pushed: pushed ?? _pushed,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  num? get id => _id;

  num? get subscribeId => _subscribeId;

  String? get siteId => _siteId;

  String? get magnet => _magnet;

  String? get message => _message;

  bool? get pushed => _pushed;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['subscribe_id'] = _subscribeId;
    map['site_id'] = _siteId;
    map['magnet'] = _magnet;
    map['message'] = _message;
    map['pushed'] = _pushed;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
