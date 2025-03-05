class TrTorrent {
  int activityDate;
  int addedDate;
  int bandwidthPriority;
  String comment;
  int doneDate;
  String downloadDir;
  int downloadLimit;
  bool downloadLimited;
  num downloadedEver;
  int error;
  String errorString;
  List<String> labels;
  List<FileStats> fileStats;
  List<TorrentFile> files;
  String hashString;
  int id;
  bool isFinished;
  bool isStalled;
  num leftUntilDone;
  String magnetLink;
  String name;
  String pieces;
  num peersGettingFromUs;
  num peersSendingToUs;
  num percentDone;
  int queuePosition;
  num rateDownload;
  num rateUpload;
  num recheckProgress;
  int secondsDownloading;
  int secondsSeeding;
  double seedRatioLimit;
  int seedRatioLimited;
  int seedRatioMode;
  int sizeWhenDone;
  int startDate;
  int status;
  int totalSize;
  List<TrackerStats> trackerStats;
  int uploadLimit;
  bool uploadLimited;
  num uploadRatio;
  num uploadedEver;

  // 新添加的字段
  int? eta;
  int? etaIdle;
  int? fileCount;
  String? group;
  bool? honorsSessionLimits;
  bool? isPrivate;
  int? maxConnectedPeers;
  int? metadataPercentComplete;
  int? pieceCount;
  int? pieceSize;
  String? primaryMimeType;
  String? torrentFile;
  String? trackerList;

  TrTorrent({
    required this.activityDate,
    required this.addedDate,
    required this.bandwidthPriority,
    required this.comment,
    required this.doneDate,
    required this.downloadDir,
    required this.downloadLimit,
    required this.downloadLimited,
    required this.downloadedEver,
    required this.error,
    required this.errorString,
    required this.fileStats,
    required this.files,
    required this.hashString,
    required this.id,
    required this.isFinished,
    required this.isStalled,
    required this.leftUntilDone,
    required this.magnetLink,
    required this.name,
    required this.pieces,
    required this.peersGettingFromUs,
    required this.peersSendingToUs,
    required this.percentDone,
    required this.queuePosition,
    required this.rateDownload,
    required this.rateUpload,
    required this.recheckProgress,
    required this.secondsDownloading,
    required this.secondsSeeding,
    required this.seedRatioLimit,
    required this.seedRatioLimited,
    required this.seedRatioMode,
    required this.sizeWhenDone,
    required this.startDate,
    required this.status,
    required this.totalSize,
    required this.trackerStats,
    required this.uploadLimit,
    required this.uploadLimited,
    required this.uploadRatio,
    required this.uploadedEver,
    required this.labels,
    this.eta,
    this.etaIdle,
    this.fileCount,
    this.group,
    this.honorsSessionLimits,
    this.isPrivate,
    this.maxConnectedPeers,
    this.metadataPercentComplete,
    this.pieceCount,
    this.pieceSize,
    this.primaryMimeType,
    this.torrentFile,
    this.trackerList,
  });

  factory TrTorrent.fromJson(Map<String, dynamic> json) {
    return TrTorrent(
      activityDate: json['activityDate'] ?? 0,
      addedDate: json['addedDate'] ?? 0,
      bandwidthPriority: json['bandwidthPriority'] ?? 0,
      comment: json['comment'] ?? '',
      doneDate: json['doneDate'] ?? 0,
      downloadDir: json['downloadDir'] ?? '',
      downloadLimit: json['downloadLimit'] ?? 0,
      downloadLimited: json['downloadLimited'] ?? false,
      downloadedEver: json['downloadedEver'] ?? 0,
      error: json['error'] ?? 0,
      errorString: json['errorString'] ?? '',
      fileStats: (json['fileStats'] as List?)
              ?.map((v) => FileStats.fromJson(v))
              .toList() ??
          [],
      files: (json['files'] as List?)
              ?.map((v) => TorrentFile.fromJson(v))
              .toList() ??
          [],
      hashString: json['hashString'] ?? '',
      id: json['id'] ?? 0,
      isFinished: json['isFinished'] ?? false,
      isStalled: json['isStalled'] ?? false,
      leftUntilDone: json['leftUntilDone'] ?? 0,
      magnetLink: json['magnetLink'] ?? '',
      name: json['name'] ?? '',
      pieces: json['pieces'] ?? '',
      peersGettingFromUs: json['peersGettingFromUs'] ?? 0,
      peersSendingToUs: json['peersSendingToUs'] ?? 0,
      percentDone: json['percentDone'] ?? 0,
      queuePosition: json['queuePosition'] ?? 0,
      rateDownload: json['rateDownload'] ?? 0,
      rateUpload: json['rateUpload'] ?? 0,
      recheckProgress: json['recheckProgress'] ?? 0,
      secondsDownloading: json['secondsDownloading'] ?? 0,
      secondsSeeding: json['secondsSeeding'] ?? 0,
      seedRatioLimit: json['seedRatioLimit'] ?? 0.0,
      seedRatioLimited: json['seedRatioLimited'] ?? 0,
      seedRatioMode: json['seedRatioMode'] ?? 0,
      sizeWhenDone: json['sizeWhenDone'] ?? 0,
      startDate: json['startDate'] ?? 0,
      status: json['status'] ?? 0,
      totalSize: json['totalSize'] ?? 0,
      trackerStats: (json['trackerStats'] as List?)
              ?.map((v) => TrackerStats.fromJson(v))
              .toList() ??
          [],
      labels: (json['labels'] as List<dynamic>?) != null
          ? List<String>.from(json['labels'].map((v) => v.toString()))
          : [],
      uploadLimit: json['uploadLimit'] ?? 0,
      uploadLimited: json['uploadLimited'] ?? false,
      uploadRatio: json['uploadRatio'] ?? 0,
      uploadedEver: json['uploadedEver'] ?? 0,
      eta: json['eta'] as int?,
      etaIdle: json['etaIdle'] as int?,
      fileCount: json['file-count'] as int?,
      group: json['group'] as String?,
      honorsSessionLimits: json['honorsSessionLimits'] as bool?,
      isPrivate: json['isPrivate'] as bool?,
      maxConnectedPeers: json['maxConnectedPeers'] as int?,
      metadataPercentComplete: json['metadataPercentComplete'] as int?,
      pieceCount: json['pieceCount'] as int?,
      pieceSize: json['pieceSize'] as int?,
      primaryMimeType: json['primary-mime-type'] as String?,
      torrentFile: json['torrentFile'] as String?,
      trackerList: json['trackerList'] as String?,
    );
  }
}

class FileStats {
  int bytesCompleted;
  int priority;
  bool wanted;

  FileStats({
    required this.bytesCompleted,
    required this.priority,
    required this.wanted,
  });

  factory FileStats.fromJson(Map<String, dynamic> json) {
    return FileStats(
      bytesCompleted: json['bytesCompleted'] ?? 0,
      priority: json['priority'] ?? 0,
      wanted: json['wanted'] ?? false,
    );
  }
}

class TorrentFile {
  int bytesCompleted;
  int length;
  String name;

  TorrentFile({
    required this.bytesCompleted,
    required this.length,
    required this.name,
  });

  factory TorrentFile.fromJson(Map<String, dynamic> json) {
    return TorrentFile(
      bytesCompleted: json['bytesCompleted'] ?? 0,
      length: json['length'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class TrackerStats {
  String announce;
  int announceState;
  int downloadCount;
  bool hasAnnounced;
  bool hasScraped;
  String host;
  int id;
  bool isBackup;
  int lastAnnouncePeerCount;
  String lastAnnounceResult;
  int lastAnnounceStartTime;
  bool lastAnnounceSucceeded;
  int lastAnnounceTime;
  bool lastAnnounceTimedOut;
  String lastScrapeResult;
  int lastScrapeStartTime;
  bool lastScrapeSucceeded;
  int lastScrapeTime;
  bool lastScrapeTimedOut;
  int leecherCount;
  int nextAnnounceTime;
  int nextScrapeTime;
  String scrape;
  int scrapeState;
  int seederCount;
  int tier;

  TrackerStats({
    required this.announce,
    required this.announceState,
    required this.downloadCount,
    required this.hasAnnounced,
    required this.hasScraped,
    required this.host,
    required this.id,
    required this.isBackup,
    required this.lastAnnouncePeerCount,
    required this.lastAnnounceResult,
    required this.lastAnnounceStartTime,
    required this.lastAnnounceSucceeded,
    required this.lastAnnounceTime,
    required this.lastAnnounceTimedOut,
    required this.lastScrapeResult,
    required this.lastScrapeStartTime,
    required this.lastScrapeSucceeded,
    required this.lastScrapeTime,
    required this.lastScrapeTimedOut,
    required this.leecherCount,
    required this.nextAnnounceTime,
    required this.nextScrapeTime,
    required this.scrape,
    required this.scrapeState,
    required this.seederCount,
    required this.tier,
  });

  factory TrackerStats.fromJson(Map<String, dynamic> json) {
    return TrackerStats(
      announce: json['announce'] ?? '',
      announceState: json['announceState'] ?? 0,
      downloadCount: json['downloadCount'] ?? 0,
      hasAnnounced: json['hasAnnounced'] ?? false,
      hasScraped: json['hasScraped'] ?? false,
      host: json['host'] ?? '',
      id: json['id'] ?? 0,
      isBackup: json['isBackup'] ?? false,
      lastAnnouncePeerCount: json['lastAnnouncePeerCount'] ?? 0,
      lastAnnounceResult: json['lastAnnounceResult'] ?? '',
      lastAnnounceStartTime: json['lastAnnounceStartTime'] ?? 0,
      lastAnnounceSucceeded: json['lastAnnounceSucceeded'] ?? false,
      lastAnnounceTime: json['lastAnnounceTime'] ?? 0,
      lastAnnounceTimedOut: json['lastAnnounceTimedOut'] ?? false,
      lastScrapeResult: json['lastScrapeResult'] ?? '',
      lastScrapeStartTime: json['lastScrapeStartTime'] ?? 0,
      lastScrapeSucceeded: json['lastScrapeSucceeded'] ?? false,
      lastScrapeTime: json['lastScrapeTime'] ?? 0,
      lastScrapeTimedOut: json['lastScrapeTimedOut'] ?? false,
      leecherCount: json['leecherCount'] ?? 0,
      nextAnnounceTime: json['nextAnnounceTime'] ?? 0,
      nextScrapeTime: json['nextScrapeTime'] ?? 0,
      scrape: json['scrape'] ?? '',
      scrapeState: json['scrapeState'] ?? 0,
      seederCount: json['seederCount'] ?? 0,
      tier: json['tier'] ?? 0,
    );
  }
}

class TorrentAddResponse {
  final String hashString;
  final int id;
  final String name;

  TorrentAddResponse({
    required this.hashString,
    required this.id,
    required this.name,
  });

  factory TorrentAddResponse.fromJson(Map<String, dynamic> json) {
    return TorrentAddResponse(
      hashString: json['hashString'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hashString': hashString,
      'id': id,
      'name': name,
    };
  }
}
