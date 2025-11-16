class AppUpdateInfo {
  final String version;
  final String changelog;
  final Map<String, String> downloadLinks;

  AppUpdateInfo({
    required this.version,
    required this.changelog,
    required this.downloadLinks,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      version: json['version'] as String,
      changelog: json['changelog'] as String,
      downloadLinks: Map<String, String>.from(json['download_links'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'changelog': changelog,
      'download_links': downloadLinks,
    };
  }
}
