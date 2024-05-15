class MyRss {
  MyRss({
    num? id,
    String? siteId,
    String? name,
    num? sort,
    String? rss,
    bool? available,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _siteId = siteId;
    _name = name;
    _sort = sort;
    _rss = rss;
    _available = available;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  MyRss.fromJson(dynamic json) {
    _id = json['id'];
    _siteId = json['site_id'];
    _name = json['name'];
    _sort = json['sort'];
    _rss = json['rss'];
    _available = json['available'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  num? _id;
  String? _siteId;
  String? _name;
  num? _sort;
  String? _rss;
  bool? _available;
  String? _createdAt;
  String? _updatedAt;

  MyRss copyWith({
    num? id,
    String? siteId,
    String? name,
    num? sort,
    String? rss,
    bool? available,
    String? createdAt,
    String? updatedAt,
  }) =>
      MyRss(
        id: id ?? _id,
        siteId: siteId ?? _siteId,
        name: name ?? _name,
        sort: sort ?? _sort,
        rss: rss ?? _rss,
        available: available ?? _available,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );

  num? get id => _id;

  String? get siteId => _siteId;

  String? get name => _name;

  num? get sort => _sort;

  String? get rss => _rss;

  bool? get available => _available;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['site_id'] = _siteId;
    map['name'] = _name;
    map['sort'] = _sort;
    map['rss'] = _rss;
    map['available'] = _available;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
