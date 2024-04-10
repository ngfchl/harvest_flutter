class CumulativeStats {
  int downloadedBytes;
  int filesAdded;
  int secondsActive;
  int sessionCount;
  int uploadedBytes;

  CumulativeStats({
    required this.downloadedBytes,
    required this.filesAdded,
    required this.secondsActive,
    required this.sessionCount,
    required this.uploadedBytes,
  });

  factory CumulativeStats.fromJson(Map<String, dynamic> json) {
    return CumulativeStats(
      downloadedBytes: json['downloadedBytes'],
      filesAdded: json['filesAdded'],
      secondsActive: json['secondsActive'],
      sessionCount: json['sessionCount'],
      uploadedBytes: json['uploadedBytes'],
    );
  }
}

class CurrentStats {
  int downloadedBytes;
  int filesAdded;
  int secondsActive;
  int sessionCount;
  int uploadedBytes;

  CurrentStats({
    required this.downloadedBytes,
    required this.filesAdded,
    required this.secondsActive,
    required this.sessionCount,
    required this.uploadedBytes,
  });

  factory CurrentStats.fromJson(Map<String, dynamic> json) {
    return CurrentStats(
      downloadedBytes: json['downloadedBytes'],
      filesAdded: json['filesAdded'],
      secondsActive: json['secondsActive'],
      sessionCount: json['sessionCount'],
      uploadedBytes: json['uploadedBytes'],
    );
  }
}

class SpeedLimitSettings {
  int speedLimitDown;
  bool speedLimitDownEnabled;
  int speedLimitUp;
  bool speedLimitUpEnabled;

  SpeedLimitSettings({
    required this.speedLimitDown,
    required this.speedLimitDownEnabled,
    required this.speedLimitUp,
    required this.speedLimitUpEnabled,
  });

  factory SpeedLimitSettings.fromJson(Map<String, dynamic> json) {
    return SpeedLimitSettings(
      speedLimitDown: json['speed-limit-down'],
      speedLimitDownEnabled: json['speed-limit-down-enabled'],
      speedLimitUp: json['speed-limit-up'],
      speedLimitUpEnabled: json['speed-limit-up-enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed-limit-down': speedLimitDown,
      'speed-limit-down-enabled': speedLimitDownEnabled,
      'speed-limit-up': speedLimitUp,
      'speed-limit-up-enabled': speedLimitUpEnabled,
    };
  }
}

class TransmissionStats {
  int activeTorrentCount;
  CumulativeStats cumulativeStats;
  CurrentStats currentStats;
  SpeedLimitSettings? speedLimitSettings;
  int downloadSpeed;
  int pausedTorrentCount;
  int torrentCount;
  int uploadSpeed;

  TransmissionStats({
    required this.activeTorrentCount,
    required this.cumulativeStats,
    required this.currentStats,
    required this.downloadSpeed,
    required this.pausedTorrentCount,
    required this.torrentCount,
    required this.uploadSpeed,
  });

  factory TransmissionStats.fromJson(Map<String, dynamic> json) {
    return TransmissionStats(
      activeTorrentCount: json['activeTorrentCount'],
      cumulativeStats: CumulativeStats.fromJson(json['cumulative-stats']),
      currentStats: CurrentStats.fromJson(json['current-stats']),
      downloadSpeed: json['downloadSpeed'],
      pausedTorrentCount: json['pausedTorrentCount'],
      torrentCount: json['torrentCount'],
      uploadSpeed: json['uploadSpeed'],
    );
  }
}

class TrFreeSpace {
  String? path;
  int? sizeBytes;

  TrFreeSpace({this.path, this.sizeBytes});

  TrFreeSpace.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    sizeBytes = json['size-bytes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['size-bytes'] = sizeBytes;
    return data;
  }
}
