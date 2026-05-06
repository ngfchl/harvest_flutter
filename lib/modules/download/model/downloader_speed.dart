

// ═══════════════════════════════════════════════════════════════
// 下载器实时速度数据
// ═══════════════════════════════════════════════════════════════

class DownloaderSpeedData {
  final String downloaderId;
  final DownloaderInfo info;
  final Map<String, dynamic> prefs;

  DownloaderSpeedData({required this.downloaderId, required this.info, required this.prefs});

  factory DownloaderSpeedData.fromJson(String id, Map<String, dynamic> json) {
    final infoJson = json['info'] as Map<String, dynamic>? ?? {};
    final prefsJson = json['prefs'] as Map<String, dynamic>? ?? {};

    return DownloaderSpeedData(downloaderId: id, info: DownloaderInfo.fromJson(infoJson, prefsJson), prefs: prefsJson);
  }
}

// ═══════════════════════════════════════════════════════════════
// 下载器实时信息（统一模型）
// ═══════════════════════════════════════════════════════════════

class DownloaderInfo {
  final int downloadSpeed;
  final int uploadSpeed;
  final int activeTorrentCount;
  final int pausedTorrentCount;
  final int totalTorrentCount;
  final int freeSpace;
  final double ratio;
  final int downloadedSession;
  final int uploadedSession;
  final String connectionStatus;
  final String version;
  final int uploadLimit;
  final int downloadLimit;
  final int totalPeerConnections;

  const DownloaderInfo({
    this.downloadSpeed = 0,
    this.uploadSpeed = 0,
    this.activeTorrentCount = 0,
    this.pausedTorrentCount = 0,
    this.totalTorrentCount = 0,
    this.freeSpace = 0,
    this.ratio = 0,
    this.downloadedSession = 0,
    this.uploadedSession = 0,
    this.connectionStatus = '',
    this.version = '',
    this.uploadLimit = 0,
    this.downloadLimit = 0,
    this.totalPeerConnections = 0,
  });

  factory DownloaderInfo.fromJson(Map<String, dynamic> json, Map<String, dynamic> prefs) {
    // QB: 有 dl_info_speed 字段
    if (json.containsKey('dl_info_speed')) {
      final version = prefs['version']?.toString() ?? '';
      return DownloaderInfo(
        downloadSpeed: json['dl_info_speed'] as int? ?? 0,
        uploadSpeed: json['up_info_speed'] as int? ?? 0,
        freeSpace: json['free_space_on_disk'] as int? ?? 0,
        ratio: double.tryParse(json['global_ratio']?.toString() ?? '0') ?? 0,
        downloadedSession: json['dl_info_data'] as int? ?? 0,
        uploadedSession: json['up_info_data'] as int? ?? 0,
        connectionStatus: json['connection_status']?.toString() ?? '',
        version: version,
        uploadLimit: json['up_rate_limit'] as int? ?? 0,
        downloadLimit: json['dl_rate_limit'] as int? ?? 0,
        totalPeerConnections: json['total_peer_connections'] as int? ?? 0,
      );
    }

    // TR: 有 downloadSpeed + torrentCount
    final currentStats = json['current-stats'] as Map<String, dynamic>? ?? {};
    final rawVersion = prefs['version']?.toString() ?? '';
    String version = '';
    if (rawVersion.isNotEmpty) {
      final ver = rawVersion.contains(' ') ? rawVersion.substring(0, rawVersion.indexOf(' ')) : rawVersion;
      version = ver.startsWith('v') ? ver : 'v$ver';
    }

    return DownloaderInfo(
      downloadSpeed: json['downloadSpeed'] as int? ?? 0,
      uploadSpeed: json['uploadSpeed'] as int? ?? 0,
      activeTorrentCount: json['activeTorrentCount'] as int? ?? 0,
      pausedTorrentCount: json['pausedTorrentCount'] as int? ?? 0,
      totalTorrentCount: json['torrentCount'] as int? ?? 0,
      // 从 prefs 取剩余空间
      freeSpace: prefs['download-dir-free-space'] as int? ?? 0,
      downloadedSession: currentStats['downloadedBytes'] as int? ?? 0,
      uploadedSession: currentStats['uploadedBytes'] as int? ?? 0,
      version: version,
      totalPeerConnections: json['total_peer_connections'] as int? ?? 0,
    );
  }

  bool get hasSpeed => downloadSpeed > 0 || uploadSpeed > 0;

  bool get hasLimit => uploadLimit > 0 || downloadLimit > 0;
}
