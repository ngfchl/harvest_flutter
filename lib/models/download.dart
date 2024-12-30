import 'package:harvest/app/home/pages/models/transmission.dart';
import 'package:qbittorrent_api/qbittorrent_api.dart';

class Downloader {
  int? id;
  String name;
  String username;
  String password;
  String protocol; // 请注意：使用String来模拟'http'或'https'
  String host;
  int port;
  String category;
  String torrentPath;
  bool isActive;
  bool brush;
  List<dynamic> status;
  dynamic prefs;

  Downloader({
    this.id,
    required this.name,
    required this.username,
    required this.password,
    required this.protocol,
    required this.host,
    required this.port,
    required this.category,
    required this.torrentPath,
    required this.isActive,
    required this.brush,
    required this.status,
    this.prefs = const {},
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
      isActive: json['is_active'],
      brush: json['brush'],
      status: json['status'] != null && json['status'].isNotEmpty
          ? (json['category'] == 'Qb'
              ? json['status']
                  .map<TransferInfo>(
                      (e) => TransferInfo.fromJson(e as Map<String, dynamic>))
                  .toList()
              : json['status']
                  .map<TransmissionStats>((e) =>
                      TransmissionStats.fromJson(e as Map<String, dynamic>))
                  .toList())
          : [],
      prefs: json['prefs'] != null && json['prefs'].isNotEmpty
          ? (json['category'] == 'Qb'
              ? Preferences.fromJson(json['prefs'] as Map<String, dynamic>)
              : TransmissionConfig.fromJson(
                  json['prefs'] as Map<String, dynamic>))
          : {},
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
      'is_active': isActive,
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
