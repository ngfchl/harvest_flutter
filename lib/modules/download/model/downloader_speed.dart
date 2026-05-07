// ═══════════════════════════════════════════════════════════════
// 下载器实时速度数据
// ═══════════════════════════════════════════════════════════════

class DownloaderSpeedData {
  final String downloaderId;
  final DownloaderInfo info;
  final Map<String, dynamic> prefs;

  DownloaderSpeedData({
    required this.downloaderId,
    required this.info,
    required this.prefs,
  });

  DownloaderSpeedData copyWith({
    String? downloaderId,
    DownloaderInfo? info,
    Map<String, dynamic>? prefs,
  }) {
    return DownloaderSpeedData(
      downloaderId: downloaderId ?? this.downloaderId,
      info: info ?? this.info,
      prefs: prefs ?? this.prefs,
    );
  }

  factory DownloaderSpeedData.fromJson(String id, Map<String, dynamic> json) {
    final prefsJson =
        _asStringMap(_pick(json, const ['prefs', 'preferences'])) ?? {};
    final infoJson =
        _asStringMap(_pick(json, const ['info', 'status', 'server_state'])) ??
        (Map<String, dynamic>.from(json)..remove('prefs'));

    return DownloaderSpeedData(
      downloaderId: id,
      info: DownloaderInfo.fromJson(infoJson, prefsJson),
      prefs: prefsJson,
    );
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
  final bool speedLimitEnabled;
  final bool alternativeSpeedEnabled;
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
    this.speedLimitEnabled = false,
    this.alternativeSpeedEnabled = false,
    this.totalPeerConnections = 0,
  });

  DownloaderInfo copyWith({
    int? downloadSpeed,
    int? uploadSpeed,
    int? activeTorrentCount,
    int? pausedTorrentCount,
    int? totalTorrentCount,
    int? freeSpace,
    double? ratio,
    int? downloadedSession,
    int? uploadedSession,
    String? connectionStatus,
    String? version,
    int? uploadLimit,
    int? downloadLimit,
    bool? speedLimitEnabled,
    bool? alternativeSpeedEnabled,
    int? totalPeerConnections,
  }) {
    return DownloaderInfo(
      downloadSpeed: downloadSpeed ?? this.downloadSpeed,
      uploadSpeed: uploadSpeed ?? this.uploadSpeed,
      activeTorrentCount: activeTorrentCount ?? this.activeTorrentCount,
      pausedTorrentCount: pausedTorrentCount ?? this.pausedTorrentCount,
      totalTorrentCount: totalTorrentCount ?? this.totalTorrentCount,
      freeSpace: freeSpace ?? this.freeSpace,
      ratio: ratio ?? this.ratio,
      downloadedSession: downloadedSession ?? this.downloadedSession,
      uploadedSession: uploadedSession ?? this.uploadedSession,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      version: version ?? this.version,
      uploadLimit: uploadLimit ?? this.uploadLimit,
      downloadLimit: downloadLimit ?? this.downloadLimit,
      speedLimitEnabled: speedLimitEnabled ?? this.speedLimitEnabled,
      alternativeSpeedEnabled:
          alternativeSpeedEnabled ?? this.alternativeSpeedEnabled,
      totalPeerConnections: totalPeerConnections ?? this.totalPeerConnections,
    );
  }

  factory DownloaderInfo.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic> prefs,
  ) {
    // QB: 有 dl_info_speed 字段。
    if (json.containsKey('dl_info_speed') ||
        json.containsKey('up_info_speed') ||
        json.containsKey('free_space_on_disk')) {
      final version = prefs['version']?.toString() ?? '';
      final rawUploadLimit = _safeInt(
        _pick(json, const ['up_rate_limit', 'uploadLimit']),
      );
      final rawDownloadLimit = _safeInt(
        _pick(json, const ['dl_rate_limit', 'downloadLimit']),
      );
      final uploadLimit = rawUploadLimit > 0
          ? rawUploadLimit
          : _safeInt(_pick(prefs, const ['up_limit', 'uploadLimit']));
      final downloadLimit = rawDownloadLimit > 0
          ? rawDownloadLimit
          : _safeInt(_pick(prefs, const ['dl_limit', 'downloadLimit']));
      final alternativeSpeedEnabled = _safeBool(
        _pick(json, const [
              'use_alt_speed_limits',
              'useAlternativeSpeedLimits',
              'alternative_speed_enabled',
              'alternativeSpeedEnabled',
              'alt-speed-enabled',
              'altSpeedEnabled',
              'slow_mode',
              'slowMode',
            ]) ??
            _pick(prefs, const [
              'use_alt_speed_limits',
              'alternative_speed_enabled',
              'alternativeSpeedEnabled',
              'alt-speed-enabled',
              'altSpeedEnabled',
            ]),
      );
      return DownloaderInfo(
        downloadSpeed: _safeInt(
          _pick(json, const [
            'dl_info_speed',
            'downloadSpeed',
            'download_speed',
          ]),
        ),
        uploadSpeed: _safeInt(
          _pick(json, const ['up_info_speed', 'uploadSpeed', 'upload_speed']),
        ),
        activeTorrentCount: _safeInt(_pick(json, const ['activeTorrentCount'])),
        pausedTorrentCount: _safeInt(_pick(json, const ['pausedTorrentCount'])),
        totalTorrentCount: _safeInt(
          _pick(json, const ['torrentCount', 'torrent_count']),
        ),
        freeSpace: _safeInt(
          _pick(json, const [
            'free_space_on_disk',
            'freeSpaceOnDisk',
            'free_space',
          ]),
        ),
        ratio: _safeDouble(
          _pick(json, const ['global_ratio', 'globalRatio', 'ratio']),
        ),
        downloadedSession: _safeInt(
          _pick(json, const [
            'dl_info_data',
            'downloadedSession',
            'downloadedBytes',
          ]),
        ),
        uploadedSession: _safeInt(
          _pick(json, const [
            'up_info_data',
            'uploadedSession',
            'uploadedBytes',
          ]),
        ),
        connectionStatus: json['connection_status']?.toString() ?? '',
        version: version,
        uploadLimit: uploadLimit,
        downloadLimit: downloadLimit,
        speedLimitEnabled:
            alternativeSpeedEnabled || uploadLimit > 0 || downloadLimit > 0,
        alternativeSpeedEnabled: alternativeSpeedEnabled,
        totalPeerConnections: _safeInt(
          _pick(json, const ['total_peer_connections', 'totalPeerConnections']),
        ),
      );
    }

    // TR: 有 downloadSpeed + torrentCount
    final currentStats =
        _asStringMap(_pick(json, const ['current-stats', 'currentStats'])) ??
        {};
    final rawVersion = prefs['version']?.toString() ?? '';
    String version = '';
    if (rawVersion.isNotEmpty) {
      final ver = rawVersion.contains(' ')
          ? rawVersion.substring(0, rawVersion.indexOf(' '))
          : rawVersion;
      version = ver.startsWith('v') ? ver : 'v$ver';
    }

    final alternativeSpeedEnabled = _safeBool(prefs['alt-speed-enabled']);
    final uploadLimitEnabled = _safeBool(prefs['speed-limit-up-enabled']);
    final downloadLimitEnabled = _safeBool(prefs['speed-limit-down-enabled']);
    final uploadLimit = alternativeSpeedEnabled
        ? _safeInt(prefs['alt-speed-up']) * 1024
        : uploadLimitEnabled
        ? _safeInt(prefs['speed-limit-up']) * 1024
        : 0;
    final downloadLimit = alternativeSpeedEnabled
        ? _safeInt(prefs['alt-speed-down']) * 1024
        : downloadLimitEnabled
        ? _safeInt(prefs['speed-limit-down']) * 1024
        : 0;

    return DownloaderInfo(
      downloadSpeed: _safeInt(
        _pick(json, const ['downloadSpeed', 'download_speed', 'dl_info_speed']),
      ),
      uploadSpeed: _safeInt(
        _pick(json, const ['uploadSpeed', 'upload_speed', 'up_info_speed']),
      ),
      activeTorrentCount: _safeInt(_pick(json, const ['activeTorrentCount'])),
      pausedTorrentCount: _safeInt(_pick(json, const ['pausedTorrentCount'])),
      totalTorrentCount: _safeInt(
        _pick(json, const ['torrentCount', 'torrent_count']),
      ),
      // 从 prefs 取剩余空间
      freeSpace: _safeInt(prefs['download-dir-free-space']),
      downloadedSession: _safeInt(currentStats['downloadedBytes']),
      uploadedSession: _safeInt(currentStats['uploadedBytes']),
      version: version,
      uploadLimit: uploadLimit,
      downloadLimit: downloadLimit,
      speedLimitEnabled:
          alternativeSpeedEnabled || uploadLimitEnabled || downloadLimitEnabled,
      alternativeSpeedEnabled: alternativeSpeedEnabled,
      totalPeerConnections: _safeInt(
        _pick(json, const ['total_peer_connections', 'totalPeerConnections']),
      ),
    );
  }

  bool get hasSpeed => downloadSpeed > 0 || uploadSpeed > 0;

  bool get hasLimit =>
      speedLimitEnabled || uploadLimit > 0 || downloadLimit > 0;
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

bool _safeBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}
