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

class TransmissionConfig {
  int altSpeedDown;
  bool altSpeedEnabled;
  int altSpeedTimeBegin;
  int altSpeedTimeDay;
  bool altSpeedTimeEnabled;
  int altSpeedTimeEnd;
  int altSpeedUp;
  bool? antiBruteForceEnabled;
  int? antiBruteForceThreshold;
  bool blocklistEnabled;
  int blocklistSize;
  String blocklistUrl;
  int cacheSizeMb;
  String configDir;
  String? defaultTrackers;
  bool dhtEnabled;
  String downloadDir;
  int downloadDirFreeSpace;
  bool downloadQueueEnabled;
  int downloadQueueSize;
  String encryption;
  int idleSeedingLimit;
  bool idleSeedingLimitEnabled;
  String incompleteDir;
  bool incompleteDirEnabled;
  bool lpdEnabled;
  int peerLimitGlobal;
  int peerLimitPerTorrent;
  int peerPort;
  bool peerPortRandomOnStart;
  bool pexEnabled;
  bool portForwardingEnabled;
  bool queueStalledEnabled;
  int queueStalledMinutes;
  bool renamePartialFiles;
  int rpcVersion;
  int rpcVersionMinimum;
  String? rpcVersionSemver;
  bool? scriptTorrentAddedEnabled;
  String? scriptTorrentAddedFilename;
  bool? scriptTorrentDoneEnabled;
  String? scriptTorrentDoneFilename;
  bool? scriptTorrentDoneSeedingEnabled;
  String? scriptTorrentDoneSeedingFilename;
  bool seedQueueEnabled;
  int seedQueueSize;
  double seedRatioLimit;
  bool seedRatioLimited;
  String sessionId;
  int speedLimitDown;
  bool speedLimitDownEnabled;
  int speedLimitUp;
  bool speedLimitUpEnabled;
  bool startAddedTorrents;
  bool? tcpEnabled;
  bool trashOriginalTorrentFiles;
  Map<String, dynamic> units;
  bool utpEnabled;
  String version;

  TransmissionConfig({
    required this.altSpeedDown,
    required this.altSpeedEnabled,
    required this.altSpeedTimeBegin,
    required this.altSpeedTimeDay,
    required this.altSpeedTimeEnabled,
    required this.altSpeedTimeEnd,
    required this.altSpeedUp,
    required this.antiBruteForceEnabled,
    required this.antiBruteForceThreshold,
    required this.blocklistEnabled,
    required this.blocklistSize,
    required this.blocklistUrl,
    required this.cacheSizeMb,
    required this.configDir,
    required this.defaultTrackers,
    required this.dhtEnabled,
    required this.downloadDir,
    required this.downloadDirFreeSpace,
    required this.downloadQueueEnabled,
    required this.downloadQueueSize,
    required this.encryption,
    required this.idleSeedingLimit,
    required this.idleSeedingLimitEnabled,
    required this.incompleteDir,
    required this.incompleteDirEnabled,
    required this.lpdEnabled,
    required this.peerLimitGlobal,
    required this.peerLimitPerTorrent,
    required this.peerPort,
    required this.peerPortRandomOnStart,
    required this.pexEnabled,
    required this.portForwardingEnabled,
    required this.queueStalledEnabled,
    required this.queueStalledMinutes,
    required this.renamePartialFiles,
    required this.rpcVersion,
    required this.rpcVersionMinimum,
    required this.rpcVersionSemver,
    required this.scriptTorrentAddedEnabled,
    required this.scriptTorrentAddedFilename,
    required this.scriptTorrentDoneEnabled,
    required this.scriptTorrentDoneFilename,
    required this.scriptTorrentDoneSeedingEnabled,
    required this.scriptTorrentDoneSeedingFilename,
    required this.seedQueueEnabled,
    required this.seedQueueSize,
    required this.seedRatioLimit,
    required this.seedRatioLimited,
    required this.sessionId,
    required this.speedLimitDown,
    required this.speedLimitDownEnabled,
    required this.speedLimitUp,
    required this.speedLimitUpEnabled,
    required this.startAddedTorrents,
    required this.tcpEnabled,
    required this.trashOriginalTorrentFiles,
    required this.units,
    required this.utpEnabled,
    required this.version,
  });

  factory TransmissionConfig.fromJson(Map<String, dynamic> json) {
    return TransmissionConfig(
      altSpeedDown: json['alt-speed-down'],
      altSpeedEnabled: json['alt-speed-enabled'],
      altSpeedTimeBegin: json['alt-speed-time-begin'],
      altSpeedTimeDay: json['alt-speed-time-day'],
      altSpeedTimeEnabled: json['alt-speed-time-enabled'],
      altSpeedTimeEnd: json['alt-speed-time-end'],
      altSpeedUp: json['alt-speed-up'],
      antiBruteForceEnabled: json['anti-brute-force-enabled'],
      antiBruteForceThreshold: json['anti-brute-force-threshold'],
      blocklistEnabled: json['blocklist-enabled'],
      blocklistSize: json['blocklist-size'],
      blocklistUrl: json['blocklist-url'],
      cacheSizeMb: json['cache-size-mb'],
      configDir: json['config-dir'],
      defaultTrackers: json['default-trackers'],
      dhtEnabled: json['dht-enabled'],
      downloadDir: json['download-dir'],
      downloadDirFreeSpace: json['download-dir-free-space'],
      downloadQueueEnabled: json['download-queue-enabled'],
      downloadQueueSize: json['download-queue-size'],
      encryption: json['encryption'],
      idleSeedingLimit: json['idle-seeding-limit'],
      idleSeedingLimitEnabled: json['idle-seeding-limit-enabled'],
      incompleteDir: json['incomplete-dir'],
      incompleteDirEnabled: json['incomplete-dir-enabled'],
      lpdEnabled: json['lpd-enabled'],
      peerLimitGlobal: json['peer-limit-global'],
      peerLimitPerTorrent: json['peer-limit-per-torrent'],
      peerPort: json['peer-port'],
      peerPortRandomOnStart: json['peer-port-random-on-start'],
      pexEnabled: json['pex-enabled'],
      portForwardingEnabled: json['port-forwarding-enabled'],
      queueStalledEnabled: json['queue-stalled-enabled'],
      queueStalledMinutes: json['queue-stalled-minutes'],
      renamePartialFiles: json['rename-partial-files'],
      rpcVersion: json['rpc-version'],
      rpcVersionMinimum: json['rpc-version-minimum'],
      rpcVersionSemver: json['rpc-version-semver'],
      scriptTorrentAddedEnabled: json['script-torrent-added-enabled'],
      scriptTorrentAddedFilename: json['script-torrent-added-filename'],
      scriptTorrentDoneEnabled: json['script-torrent-done-enabled'],
      scriptTorrentDoneFilename: json['script-torrent-done-filename'],
      scriptTorrentDoneSeedingEnabled:
          json['script-torrent-done-seeding-enabled'],
      scriptTorrentDoneSeedingFilename:
          json['script-torrent-done-seeding-filename'],
      seedQueueEnabled: json['seed-queue-enabled'],
      seedQueueSize: json['seed-queue-size'],
      seedRatioLimit: json['seedRatioLimit']?.toDouble(),
      seedRatioLimited: json['seedRatioLimited'],
      sessionId: json['session-id'],
      speedLimitDown: json['speed-limit-down'],
      speedLimitDownEnabled: json['speed-limit-down-enabled'],
      speedLimitUp: json['speed-limit-up'],
      speedLimitUpEnabled: json['speed-limit-up-enabled'],
      startAddedTorrents: json['start-added-torrents'],
      tcpEnabled: json['tcp-enabled'],
      trashOriginalTorrentFiles: json['trash-original-torrent-files'],
      units: json['units'],
      utpEnabled: json['utp-enabled'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alt-speed-down': altSpeedDown,
      'alt-speed-enabled': altSpeedEnabled,
      'alt-speed-time-begin': altSpeedTimeBegin,
      'alt-speed-time-day': altSpeedTimeDay,
      'alt-speed-time-enabled': altSpeedTimeEnabled,
      'alt-speed-time-end': altSpeedTimeEnd,
      'alt-speed-up': altSpeedUp,
      'anti-brute-force-enabled': antiBruteForceEnabled,
      'anti-brute-force-threshold': antiBruteForceThreshold,
      'blocklist-enabled': blocklistEnabled,
      'blocklist-size': blocklistSize,
      'blocklist-url': blocklistUrl,
      'cache-size-mb': cacheSizeMb,
      'config-dir': configDir,
      'default-trackers': defaultTrackers,
      'dht-enabled': dhtEnabled,
      'download-dir': downloadDir,
      'download-dir-free-space': downloadDirFreeSpace,
      'download-queue-enabled': downloadQueueEnabled,
      'download-queue-size': downloadQueueSize,
      'encryption': encryption,
      'idle-seeding-limit': idleSeedingLimit,
      'idle-seeding-limit-enabled': idleSeedingLimitEnabled,
      'incomplete-dir': incompleteDir,
      'incomplete-dir-enabled': incompleteDirEnabled,
      'lpd-enabled': lpdEnabled,
      'peer-limit-global': peerLimitGlobal,
      'peer-limit-per-torrent': peerLimitPerTorrent,
      'peer-port': peerPort,
      'peer-port-random-on-start': peerPortRandomOnStart,
      'pex-enabled': pexEnabled,
      'port-forwarding-enabled': portForwardingEnabled,
      'queue-stalled-enabled': queueStalledEnabled,
      'queue-stalled-minutes': queueStalledMinutes,
      'rename-partial-files': renamePartialFiles,
      'rpc-version': rpcVersion,
      'rpc-version-minimum': rpcVersionMinimum,
      'rpc-version-semver': rpcVersionSemver,
      'script-torrent-added-enabled': scriptTorrentAddedEnabled,
      'script-torrent-added-filename': scriptTorrentAddedFilename,
      'script-torrent-done-enabled': scriptTorrentDoneEnabled,
      'script-torrent-done-filename': scriptTorrentDoneFilename,
      'script-torrent-done-seeding-enabled': scriptTorrentDoneSeedingEnabled,
      'script-torrent-done-seeding-filename': scriptTorrentDoneSeedingFilename,
      'seed-queue-enabled': seedQueueEnabled,
      'seed-queue-size': seedQueueSize,
      'seedRatioLimit': seedRatioLimit,
      'seedRatioLimited': seedRatioLimited,
      'session-id': sessionId,
      'speed-limit-down': speedLimitDown,
      'speed-limit-down-enabled': speedLimitDownEnabled,
      'speed-limit-up': speedLimitUp,
      'speed-limit-up-enabled': speedLimitUpEnabled,
      'start-added-torrents': startAddedTorrents,
      'tcp-enabled': tcpEnabled,
      'trash-original-torrent-files': trashOriginalTorrentFiles,
      'units': units,
      'utp-enabled': utpEnabled,
      'version': version,
    };
  }

  TransmissionConfig copyWith({
    int? altSpeedDown,
    bool? altSpeedEnabled,
    int? altSpeedTimeBegin,
    int? altSpeedTimeDay,
    bool? altSpeedTimeEnabled,
    int? altSpeedTimeEnd,
    int? altSpeedUp,
    bool? antiBruteForceEnabled,
    int? antiBruteForceThreshold,
    bool? blocklistEnabled,
    int? blocklistSize,
    String? blocklistUrl,
    int? cacheSizeMb,
    String? configDir,
    String? defaultTrackers,
    bool? dhtEnabled,
    String? downloadDir,
    int? downloadDirFreeSpace,
    bool? downloadQueueEnabled,
    int? downloadQueueSize,
    String? encryption,
    int? idleSeedingLimit,
    bool? idleSeedingLimitEnabled,
    String? incompleteDir,
    bool? incompleteDirEnabled,
    bool? lpdEnabled,
    int? peerLimitGlobal,
    int? peerLimitPerTorrent,
    int? peerPort,
    bool? peerPortRandomOnStart,
    bool? pexEnabled,
    bool? portForwardingEnabled,
    bool? queueStalledEnabled,
    int? queueStalledMinutes,
    bool? renamePartialFiles,
    int? rpcVersion,
    int? rpcVersionMinimum,
    String? rpcVersionSemver,
    bool? scriptTorrentAddedEnabled,
    String? scriptTorrentAddedFilename,
    bool? scriptTorrentDoneEnabled,
    String? scriptTorrentDoneFilename,
    bool? scriptTorrentDoneSeedingEnabled,
    String? scriptTorrentDoneSeedingFilename,
    bool? seedQueueEnabled,
    int? seedQueueSize,
    double? seedRatioLimit,
    bool? seedRatioLimited,
    String? sessionId,
    int? speedLimitDown,
    bool? speedLimitDownEnabled,
    int? speedLimitUp,
    bool? speedLimitUpEnabled,
    bool? startAddedTorrents,
    bool? tcpEnabled,
    bool? trashOriginalTorrentFiles,
    Map<String, dynamic>? units,
    bool? utpEnabled,
    String? version,
  }) {
    return TransmissionConfig(
      altSpeedDown: altSpeedDown ?? this.altSpeedDown,
      altSpeedEnabled: altSpeedEnabled ?? this.altSpeedEnabled,
      altSpeedTimeBegin: altSpeedTimeBegin ?? this.altSpeedTimeBegin,
      altSpeedTimeDay: altSpeedTimeDay ?? this.altSpeedTimeDay,
      altSpeedTimeEnabled: altSpeedTimeEnabled ?? this.altSpeedTimeEnabled,
      altSpeedTimeEnd: altSpeedTimeEnd ?? this.altSpeedTimeEnd,
      altSpeedUp: altSpeedUp ?? this.altSpeedUp,
      antiBruteForceEnabled:
          antiBruteForceEnabled ?? this.antiBruteForceEnabled,
      antiBruteForceThreshold:
          antiBruteForceThreshold ?? this.antiBruteForceThreshold,
      blocklistEnabled: blocklistEnabled ?? this.blocklistEnabled,
      blocklistSize: blocklistSize ?? this.blocklistSize,
      blocklistUrl: blocklistUrl ?? this.blocklistUrl,
      cacheSizeMb: cacheSizeMb ?? this.cacheSizeMb,
      configDir: configDir ?? this.configDir,
      defaultTrackers: defaultTrackers ?? this.defaultTrackers,
      dhtEnabled: dhtEnabled ?? this.dhtEnabled,
      downloadDir: downloadDir ?? this.downloadDir,
      downloadDirFreeSpace: downloadDirFreeSpace ?? this.downloadDirFreeSpace,
      downloadQueueEnabled: downloadQueueEnabled ?? this.downloadQueueEnabled,
      downloadQueueSize: downloadQueueSize ?? this.downloadQueueSize,
      encryption: encryption ?? this.encryption,
      idleSeedingLimit: idleSeedingLimit ?? this.idleSeedingLimit,
      idleSeedingLimitEnabled:
          idleSeedingLimitEnabled ?? this.idleSeedingLimitEnabled,
      incompleteDir: incompleteDir ?? this.incompleteDir,
      incompleteDirEnabled: incompleteDirEnabled ?? this.incompleteDirEnabled,
      lpdEnabled: lpdEnabled ?? this.lpdEnabled,
      peerLimitGlobal: peerLimitGlobal ?? this.peerLimitGlobal,
      peerLimitPerTorrent: peerLimitPerTorrent ?? this.peerLimitPerTorrent,
      peerPort: peerPort ?? this.peerPort,
      peerPortRandomOnStart:
          peerPortRandomOnStart ?? this.peerPortRandomOnStart,
      pexEnabled: pexEnabled ?? this.pexEnabled,
      portForwardingEnabled:
          portForwardingEnabled ?? this.portForwardingEnabled,
      queueStalledEnabled: queueStalledEnabled ?? this.queueStalledEnabled,
      queueStalledMinutes: queueStalledMinutes ?? this.queueStalledMinutes,
      renamePartialFiles: renamePartialFiles ?? this.renamePartialFiles,
      rpcVersion: rpcVersion ?? this.rpcVersion,
      rpcVersionMinimum: rpcVersionMinimum ?? this.rpcVersionMinimum,
      rpcVersionSemver: rpcVersionSemver ?? this.rpcVersionSemver,
      scriptTorrentAddedEnabled:
          scriptTorrentAddedEnabled ?? this.scriptTorrentAddedEnabled,
      scriptTorrentAddedFilename:
          scriptTorrentAddedFilename ?? this.scriptTorrentAddedFilename,
      scriptTorrentDoneEnabled:
          scriptTorrentDoneEnabled ?? this.scriptTorrentDoneEnabled,
      scriptTorrentDoneFilename:
          scriptTorrentDoneFilename ?? this.scriptTorrentDoneFilename,
      scriptTorrentDoneSeedingEnabled: scriptTorrentDoneSeedingEnabled ??
          this.scriptTorrentDoneSeedingEnabled,
      scriptTorrentDoneSeedingFilename: scriptTorrentDoneSeedingFilename ??
          this.scriptTorrentDoneSeedingFilename,
      seedQueueEnabled: seedQueueEnabled ?? this.seedQueueEnabled,
      seedQueueSize: seedQueueSize ?? this.seedQueueSize,
      seedRatioLimit: seedRatioLimit ?? this.seedRatioLimit,
      seedRatioLimited: seedRatioLimited ?? this.seedRatioLimited,
      sessionId: sessionId ?? this.sessionId,
      speedLimitDown: speedLimitDown ?? this.speedLimitDown,
      speedLimitDownEnabled:
          speedLimitDownEnabled ?? this.speedLimitDownEnabled,
      speedLimitUp: speedLimitUp ?? this.speedLimitUp,
      speedLimitUpEnabled: speedLimitUpEnabled ?? this.speedLimitUpEnabled,
      startAddedTorrents: startAddedTorrents ?? this.startAddedTorrents,
      tcpEnabled: tcpEnabled ?? this.tcpEnabled,
      trashOriginalTorrentFiles:
          trashOriginalTorrentFiles ?? this.trashOriginalTorrentFiles,
      units: units ?? this.units,
      utpEnabled: utpEnabled ?? this.utpEnabled,
      version: version ?? this.version,
    );
  }
}

class TransmissionStats {
  int activeTorrentCount;
  CumulativeStats cumulativeStats;
  CurrentStats currentStats;
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

class TransmissionUtils {
  /// 给定一个整数（altSpeedTimeDay），返回一个包含启用限时限速的星期列表
  static List<int> getEnabledDaysFromAltSpeedTimeDay(int altSpeedTimeDay) {
    List<int> daysOfWeekMask = [1, 2, 4, 8, 16, 32, 64];
    List<int> enabledDays = [];
    for (int i = 0; i < daysOfWeekMask.length; i++) {
      int mask = 1 << i;
      if ((altSpeedTimeDay & mask) != 0) {
        enabledDays.add(daysOfWeekMask[i]);
      }
    }
    return enabledDays;
  }

  /// 给定一个星期列表，返回对应的 altSpeedTimeDay 整数值
  static int getAltSpeedTimeDayFromEnabledDays(List<int> enabledDays) {
    return enabledDays.reduce((a, b) => a + b);
  }
}
