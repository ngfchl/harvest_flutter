// ═══════════════════════════════════════════════════════════════
// 下载器实时速度数据
// ═══════════════════════════════════════════════════════════════

class DownloaderSpeedData {
  final String downloaderId;
  final DownloaderInfo info;
  final Map<String, dynamic> prefs;

  DownloaderSpeedData({required this.downloaderId, required this.info, required this.prefs});

  factory DownloaderSpeedData.fromJson(String id, Map<String, dynamic> json) {
    final prefsJson = _asStringMap(_pick(json, const ['prefs', 'preferences'])) ?? {};
    final infoJson =
        _asStringMap(_pick(json, const ['info', 'status', 'server_state'])) ??
        (Map<String, dynamic>.from(json)..remove('prefs'));

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
    // QB: 有 dl_info_speed 字段。
    if (json.containsKey('dl_info_speed') ||
        json.containsKey('up_info_speed') ||
        json.containsKey('free_space_on_disk')) {
      final version = prefs['version']?.toString() ?? '';
      return DownloaderInfo(
        downloadSpeed: _safeInt(_pick(json, const ['dl_info_speed', 'downloadSpeed', 'download_speed'])),
        uploadSpeed: _safeInt(_pick(json, const ['up_info_speed', 'uploadSpeed', 'upload_speed'])),
        activeTorrentCount: _safeInt(_pick(json, const ['activeTorrentCount'])),
        pausedTorrentCount: _safeInt(_pick(json, const ['pausedTorrentCount'])),
        totalTorrentCount: _safeInt(_pick(json, const ['torrentCount', 'torrent_count'])),
        freeSpace: _safeInt(_pick(json, const ['free_space_on_disk', 'freeSpaceOnDisk', 'free_space'])),
        ratio: _safeDouble(_pick(json, const ['global_ratio', 'globalRatio', 'ratio'])),
        downloadedSession: _safeInt(_pick(json, const ['dl_info_data', 'downloadedSession', 'downloadedBytes'])),
        uploadedSession: _safeInt(_pick(json, const ['up_info_data', 'uploadedSession', 'uploadedBytes'])),
        connectionStatus: json['connection_status']?.toString() ?? '',
        version: version,
        uploadLimit: _safeInt(_pick(json, const ['up_rate_limit', 'uploadLimit'])),
        downloadLimit: _safeInt(_pick(json, const ['dl_rate_limit', 'downloadLimit'])),
        totalPeerConnections: _safeInt(_pick(json, const ['total_peer_connections', 'totalPeerConnections'])),
      );
    }

    // TR: 有 downloadSpeed + torrentCount
    final currentStats = _asStringMap(_pick(json, const ['current-stats', 'currentStats'])) ?? {};
    final rawVersion = prefs['version']?.toString() ?? '';
    String version = '';
    if (rawVersion.isNotEmpty) {
      final ver = rawVersion.contains(' ') ? rawVersion.substring(0, rawVersion.indexOf(' ')) : rawVersion;
      version = ver.startsWith('v') ? ver : 'v$ver';
    }

    return DownloaderInfo(
      downloadSpeed: _safeInt(_pick(json, const ['downloadSpeed', 'download_speed', 'dl_info_speed'])),
      uploadSpeed: _safeInt(_pick(json, const ['uploadSpeed', 'upload_speed', 'up_info_speed'])),
      activeTorrentCount: _safeInt(_pick(json, const ['activeTorrentCount'])),
      pausedTorrentCount: _safeInt(_pick(json, const ['pausedTorrentCount'])),
      totalTorrentCount: _safeInt(_pick(json, const ['torrentCount', 'torrent_count'])),
      // 从 prefs 取剩余空间
      freeSpace: _safeInt(prefs['download-dir-free-space']),
      downloadedSession: _safeInt(currentStats['downloadedBytes']),
      uploadedSession: _safeInt(currentStats['uploadedBytes']),
      version: version,
      totalPeerConnections: _safeInt(_pick(json, const ['total_peer_connections', 'totalPeerConnections'])),
    );
  }

  bool get hasSpeed => downloadSpeed > 0 || uploadSpeed > 0;

  bool get hasLimit => uploadLimit > 0 || downloadLimit > 0;
}

Map<String, dynamic>? _asStringMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) return json[key];
  }
  return null;
}

int _safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
  }
  return 0;
}

double _safeDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
