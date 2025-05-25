class Server {
  final int id;
  final String name;
  final String entry;
  final String username;
  final String password;
  bool selected;

  Server({
    required this.id,
    required this.name,
    required this.entry,
    required this.username,
    required this.password,
    required this.selected,
  });

  Server copyWith({
    int? id,
    String? name,
    String? entry,
    String? username,
    String? password,
    bool? selected,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      entry: entry ?? this.entry,
      username: username ?? this.username,
      password: password ?? this.password,
      selected: selected ?? this.selected,
    );
  }

  // 序列化方法，用于将对象转换为Map以便存入数据库
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'entry': entry,
      'username': username,
      'password': password,
      'selected': selected ? 1 : 0,
    };
  }

  // 反序列化方法，从数据库获取数据后转换回对象
  factory Server.fromJson(Map<String, dynamic> map) {
    return Server(
      id: map['id'],
      name: map['name'],
      entry: map['entry'],
      username: map['username'],
      password: map['password'] ?? '',
      selected: map['selected'] == 1,
    );
  }

  @override
  String toString() {
    return 'Harvest服务器：$id - $name [$entry]';
  }
}
