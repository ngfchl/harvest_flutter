class TransmissionBaseTorrent {
  int? activityDate;
  int? doneDate;
  num? downloadedEver;
  int? error;
  String? errorString;
  int? id;
  num? leftUntilDone;
  String? name;
  String? hashString;
  String? magnetLink;
  String? downloadDir;

  int? addedDate;
  int? sizeWhenDone;
  int? startDate;

  num? peersGettingFromUs;
  num? peersSendingToUs;
  num? percentDone;
  int? queuePosition;
  num? rateDownload;
  num? rateUpload;
  num? recheckProgress;
  int? status;
  num? totalSize;
  List<TrackerStats>? trackerStats;
  num? uploadRatio;
  num? uploadedEver;

  TransmissionBaseTorrent(
      {this.activityDate,
      this.doneDate,
      this.downloadedEver,
      this.error,
      this.errorString,
      this.id,
      this.leftUntilDone,
      this.name,
      this.downloadDir,
      this.magnetLink,
      this.addedDate,
      this.sizeWhenDone,
      this.startDate,
      this.hashString,
      this.peersGettingFromUs,
      this.peersSendingToUs,
      this.percentDone,
      this.queuePosition,
      this.rateDownload,
      this.rateUpload,
      this.recheckProgress,
      this.status,
      this.totalSize,
      this.trackerStats,
      this.uploadRatio,
      this.uploadedEver});

  TransmissionBaseTorrent.fromJson(Map<String, dynamic> json) {
    activityDate = json['activityDate'];
    doneDate = json['doneDate'];
    downloadedEver = json['downloadedEver'];
    error = json['error'];
    errorString = json['errorString'];
    id = json['id'];
    leftUntilDone = json['leftUntilDone'];
    name = json['name'];
    downloadDir = json['downloadDir'];
    magnetLink = json['magnetLink'];
    hashString = json['hashString'];
    addedDate = json['addedDate'];
    sizeWhenDone = json['sizeWhenDone'];
    startDate = json['startDate'];
    peersGettingFromUs = json['peersGettingFromUs'];
    peersSendingToUs = json['peersSendingToUs'];
    percentDone = json['percentDone'];
    queuePosition = json['queuePosition'];
    rateDownload = json['rateDownload'];
    rateUpload = json['rateUpload'];
    recheckProgress = json['recheckProgress'];
    status = json['status'];
    totalSize = json['totalSize'];
    if (json['trackerStats'] != null) {
      trackerStats = <TrackerStats>[];
      json['trackerStats'].forEach((v) {
        trackerStats!.add(TrackerStats.fromJson(v));
      });
    }
    uploadRatio = json['uploadRatio'];
    uploadedEver = json['uploadedEver'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activityDate'] = activityDate;
    data['doneDate'] = doneDate;
    data['downloadedEver'] = downloadedEver;
    data['error'] = error;
    data['errorString'] = errorString;
    data['id'] = id;
    data['leftUntilDone'] = leftUntilDone;
    data['name'] = name;
    data['downloadDir'] = downloadDir;
    data['magnetLink'] = magnetLink;
    data['hashString'] = hashString;
    data['addedDate'] = addedDate;
    data['sizeWhenDone'] = sizeWhenDone;
    data['startDate'] = startDate;
    data['peersGettingFromUs'] = peersGettingFromUs;
    data['peersSendingToUs'] = peersSendingToUs;
    data['percentDone'] = percentDone;
    data['queuePosition'] = queuePosition;
    data['rateDownload'] = rateDownload;
    data['rateUpload'] = rateUpload;
    data['recheckProgress'] = recheckProgress;
    data['status'] = status;
    data['totalSize'] = totalSize;
    if (trackerStats != null) {
      data['trackerStats'] = trackerStats!.map((v) => v.toJson()).toList();
    }
    data['uploadRatio'] = uploadRatio;
    data['uploadedEver'] = uploadedEver;
    return data;
  }
}

class TrackerStats {
  String? announce;
  int? announceState;
  int? downloadCount;
  bool? hasAnnounced;
  bool? hasScraped;
  String? host;
  int? id;
  bool? isBackup;
  int? lastAnnouncePeerCount;
  String? lastAnnounceResult;
  int? lastAnnounceStartTime;
  bool? lastAnnounceSucceeded;
  int? lastAnnounceTime;
  bool? lastAnnounceTimedOut;
  String? lastScrapeResult;
  int? lastScrapeStartTime;
  bool? lastScrapeSucceeded;
  int? lastScrapeTime;
  bool? lastScrapeTimedOut;
  int? leecherCount;
  int? nextAnnounceTime;
  int? nextScrapeTime;
  String? scrape;
  int? scrapeState;
  int? seederCount;
  int? tier;

  TrackerStats(
      {this.announce,
      this.announceState,
      this.downloadCount,
      this.hasAnnounced,
      this.hasScraped,
      this.host,
      this.id,
      this.isBackup,
      this.lastAnnouncePeerCount,
      this.lastAnnounceResult,
      this.lastAnnounceStartTime,
      this.lastAnnounceSucceeded,
      this.lastAnnounceTime,
      this.lastAnnounceTimedOut,
      this.lastScrapeResult,
      this.lastScrapeStartTime,
      this.lastScrapeSucceeded,
      this.lastScrapeTime,
      this.lastScrapeTimedOut,
      this.leecherCount,
      this.nextAnnounceTime,
      this.nextScrapeTime,
      this.scrape,
      this.scrapeState,
      this.seederCount,
      this.tier});

  TrackerStats.fromJson(Map<String, dynamic> json) {
    announce = json['announce'];
    announceState = json['announceState'];
    downloadCount = json['downloadCount'];
    hasAnnounced = json['hasAnnounced'];
    hasScraped = json['hasScraped'];
    host = json['host'];
    id = json['id'];
    isBackup = json['isBackup'];
    lastAnnouncePeerCount = json['lastAnnouncePeerCount'];
    lastAnnounceResult = json['lastAnnounceResult'];
    lastAnnounceStartTime = json['lastAnnounceStartTime'];
    lastAnnounceSucceeded = json['lastAnnounceSucceeded'];
    lastAnnounceTime = json['lastAnnounceTime'];
    lastAnnounceTimedOut = json['lastAnnounceTimedOut'];
    lastScrapeResult = json['lastScrapeResult'];
    lastScrapeStartTime = json['lastScrapeStartTime'];
    lastScrapeSucceeded = json['lastScrapeSucceeded'];
    lastScrapeTime = json['lastScrapeTime'];
    lastScrapeTimedOut = json['lastScrapeTimedOut'];
    leecherCount = json['leecherCount'];
    nextAnnounceTime = json['nextAnnounceTime'];
    nextScrapeTime = json['nextScrapeTime'];
    scrape = json['scrape'];
    scrapeState = json['scrapeState'];
    seederCount = json['seederCount'];
    tier = json['tier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['announce'] = announce;
    data['announceState'] = announceState;
    data['downloadCount'] = downloadCount;
    data['hasAnnounced'] = hasAnnounced;
    data['hasScraped'] = hasScraped;
    data['host'] = host;
    data['id'] = id;
    data['isBackup'] = isBackup;
    data['lastAnnouncePeerCount'] = lastAnnouncePeerCount;
    data['lastAnnounceResult'] = lastAnnounceResult;
    data['lastAnnounceStartTime'] = lastAnnounceStartTime;
    data['lastAnnounceSucceeded'] = lastAnnounceSucceeded;
    data['lastAnnounceTime'] = lastAnnounceTime;
    data['lastAnnounceTimedOut'] = lastAnnounceTimedOut;
    data['lastScrapeResult'] = lastScrapeResult;
    data['lastScrapeStartTime'] = lastScrapeStartTime;
    data['lastScrapeSucceeded'] = lastScrapeSucceeded;
    data['lastScrapeTime'] = lastScrapeTime;
    data['lastScrapeTimedOut'] = lastScrapeTimedOut;
    data['leecherCount'] = leecherCount;
    data['nextAnnounceTime'] = nextAnnounceTime;
    data['nextScrapeTime'] = nextScrapeTime;
    data['scrape'] = scrape;
    data['scrapeState'] = scrapeState;
    data['seederCount'] = seederCount;
    data['tier'] = tier;
    return data;
  }
}
