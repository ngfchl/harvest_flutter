class SubTag {
  SubTag({
    num? id,
    String? name,
    String? category,
    bool? available,
  }) {
    _id = id;
    _name = name;
    _category = category;
    _available = available;
  }

  SubTag.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _category = json['category'];
    _available = json['available'];
  }

  num? _id;
  String? _name;
  String? _category;
  bool? _available;

  SubTag copyWith({
    num? id,
    String? name,
    String? category,
    bool? available,
  }) =>
      SubTag(
        id: id ?? _id,
        name: name ?? _name,
        category: category ?? _category,
        available: available ?? _available,
      );

  num? get id => _id;

  String? get name => _name;

  String? get category => _category;

  bool? get available => _available;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['category'] = _category;
    map['available'] = _available;
    return map;
  }
}
