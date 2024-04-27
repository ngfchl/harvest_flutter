class Server {
  final int id;
  final String name;
  final String protocol;
  final String domain;
  final String username;
  final String password;
  final int port;
  bool selected;

  Server({
    required this.id,
    required this.name,
    required this.protocol,
    required this.domain,
    required this.username,
    required this.password,
    required this.port,
    required this.selected,
  });

  Server copyWith({
    int? id,
    String? name,
    String? protocol,
    String? domain,
    String? username,
    String? password,
    int? port,
    bool? selected,
  }) {
    return Server(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      domain: domain ?? this.domain,
      username: username ?? this.username,
      password: password ?? this.password,
      port: port ?? this.port,
      selected: selected ?? this.selected,
    );
  }

  // 序列化方法，用于将对象转换为Map以便存入数据库
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'protocol': protocol,
      'domain': domain,
      'username': username,
      'password': password,
      'port': port,
      'selected': selected ? 1 : 0,
    };
  }

  // 反序列化方法，从数据库获取数据后转换回对象
  factory Server.fromJson(Map<String, dynamic> map) {
    return Server(
      id: map['id'],
      name: map['name'],
      protocol: map['protocol'],
      domain: map['domain'],
      username: map['username'],
      password: map['password'] ?? '',
      port: map['port'],
      selected: map['selected'] == 1,
    );
  }
}
