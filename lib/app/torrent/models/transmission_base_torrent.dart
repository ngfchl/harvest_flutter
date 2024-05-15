class TransmissionBaseTorrent {
  int activityDate;
  int doneDate;
  num downloadedEver;
  int error;
  String errorString;
  int id;
  num leftUntilDone;
  String name;
  String hashString;
  String magnetLink;
  String downloadDir;

  int addedDate;
  int sizeWhenDone;
  int startDate;

  num peersGettingFromUs;
  num peersSendingToUs;
  num percentDone;
  int queuePosition;
  num rateDownload;
  num rateUpload;
  num recheckProgress;
  int status;
  num totalSize;
  List<TrackerStats?> trackerStats;
  num uploadRatio;
  num uploadedEver;

  TransmissionBaseTorrent({
    required this.activityDate,
    required this.doneDate,
    required this.downloadedEver,
    required this.error,
    required this.errorString,
    required this.id,
    required this.leftUntilDone,
    required this.name,
    required this.downloadDir,
    required this.magnetLink,
    required this.addedDate,
    required this.sizeWhenDone,
    required this.startDate,
    required this.hashString,
    required this.peersGettingFromUs,
    required this.peersSendingToUs,
    required this.percentDone,
    required this.queuePosition,
    required this.rateDownload,
    required this.rateUpload,
    required this.recheckProgress,
    required this.status,
    required this.totalSize,
    required this.trackerStats,
    required this.uploadRatio,
    required this.uploadedEver,
  });

  factory TransmissionBaseTorrent.fromJson(Map<String, dynamic>? json) {
    if (json == null) throw ArgumentError.notNull('json');
    return TransmissionBaseTorrent(
      activityDate: json['activityDate'] ?? 0,
      doneDate: json['doneDate'] ?? 0,
      downloadedEver: json['downloadedEver'] ?? 0,
      error: json['error'] ?? 0,
      errorString: json['errorString'] ?? '',
      id: json['id'] ?? 0,
      leftUntilDone: json['leftUntilDone'] ?? 0,
      name: json['name'] ?? '',
      downloadDir: json['downloadDir'] ?? '',
      magnetLink: json['magnetLink'] ?? '',
      hashString: json['hashString'] ?? '',
      addedDate: json['addedDate'] ?? 0,
      sizeWhenDone: json['sizeWhenDone'] ?? 0,
      startDate: json['startDate'] ?? 0,
      peersGettingFromUs: json['peersGettingFromUs'] ?? 0,
      peersSendingToUs: json['peersSendingToUs'] ?? 0,
      percentDone: json['percentDone'] ?? 0,
      queuePosition: json['queuePosition'] ?? 0,
      rateDownload: json['rateDownload'] ?? 0,
      rateUpload: json['rateUpload'] ?? 0,
      recheckProgress: json['recheckProgress'] ?? 0,
      status: json['status'] ?? 0,
      totalSize: json['totalSize'] ?? 0,
      trackerStats: (json['trackerStats'] as List?)!
          .map((v) => v == null ? null : TrackerStats.fromJson(v))
          .toList(),
      uploadRatio: json['uploadRatio'] ?? 0,
      uploadedEver: json['uploadedEver'] ?? 0,
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
