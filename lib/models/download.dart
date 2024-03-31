class Downloader {
  int id;
  String name;
  String? username;
  String? password;
  String? protocol; // 请注意：使用String来模拟'http'或'https'
  String? host;
  int? port;
  String category;
  String torrentPath;
  bool? isActive;
  bool? brush;
  List<dynamic> status;

  Downloader({
    required this.id,
    required this.name,
    this.username,
    this.password,
    this.protocol,
    this.host,
    this.port,
    required this.category,
    required this.torrentPath,
    this.isActive,
    this.brush,
    required this.status,
  });

  factory Downloader.fromJson(Map<String, dynamic> json) {
    return Downloader(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      protocol: json['protocol'],
      host: json['host'],
      port: json['port'],
      category: json['category'],
      torrentPath: json['torrent_path'],
      isActive: json['enable'],
      brush: json['brush'],
      status: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'protocol': protocol,
      'host': host,
      'port': port,
      'category': category,
      'torrent_path': torrentPath,
      'enable': isActive,
      'brush': brush,
    };
  }
}

class DownloaderCategory {
  String? name;
  String? savePath;

  DownloaderCategory({this.name, this.savePath});

  DownloaderCategory.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    savePath = json['savePath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['savePath'] = savePath;
    return data;
  }
}
