class Downloader {
  int id;
  String name;
  String? username;
  String? password;
  String? http; // 请注意：使用String来模拟'http'或'https'
  String? host;
  int? port;
  String category;
  bool? enable;
  bool? brush;
  bool? repeat;
  bool? packageFiles;
  bool? deleteOneFile;
  int? countTorrents;
  int? packageSize;
  double? packagePercent;
  int? reservedSpace;
  List<dynamic> status;

  Downloader({
    required this.id,
    required this.name,
    this.username,
    this.password,
    this.http,
    this.host,
    this.port,
    required this.category,
    this.enable,
    this.brush,
    this.repeat,
    this.packageFiles,
    this.deleteOneFile,
    this.countTorrents,
    this.packageSize,
    this.packagePercent,
    this.reservedSpace,
    required this.status,
  });

  factory Downloader.fromJson(Map<String, dynamic> json) {
    return Downloader(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      password: json['password'],
      http: json['http'],
      host: json['host'],
      port: json['port'],
      category: json['category'],
      enable: json['enable'],
      brush: json['brush'],
      repeat: json['repeat'],
      packageFiles: json['package_files'],
      deleteOneFile: json['delete_one_file'],
      countTorrents: json['count_torrents'],
      packageSize: json['package_size'],
      packagePercent: json['package_percent'],
      reservedSpace: json['reserved_space'],
      status: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'http': http,
      'host': host,
      'port': port,
      'category': category,
      'enable': enable,
      'brush': brush,
      'repeat': repeat,
      'package_files': packageFiles,
      'delete_one_file': deleteOneFile,
      'count_torrents': countTorrents,
      'package_size': packageSize,
      'package_percent': packagePercent,
      'reserved_space': reservedSpace,
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
