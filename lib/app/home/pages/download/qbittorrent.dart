class QbittorrentTorrentInfo {
  final int addedOn;
  final int amountLeft;
  final bool autoTmm;
  final int availability;
  final String category;
  final int completed;
  final int completionOn;
  final String contentPath;
  final int dlLimit;
  final int dlSpeed;
  final String downloadPath;
  final int downloaded;
  final int downloadedSession;
  final int eta;
  final bool firstLastPiecePriority;
  final bool forceStart;
  final String hash;
  final String infohashV1;
  final String infohashV2;
  final int lastActivity;
  final String magnetUri;
  final double maxRatio;
  final int maxSeedingTime;
  final String name;
  final int numComplete;
  final int numIncomplete;
  final int numLeechs;
  final int numSeeds;
  final int priority;
  final double progress;
  final double ratio;
  final double ratioLimit;
  final String savePath;
  final int seedingTime;
  final int seedingTimeLimit;
  final int seenComplete;
  final bool sequentialDownload;
  final int size;
  final String state;
  final bool superSeeding;
  final String tags;
  final int timeActive;
  final int totalSize;
  final String tracker;
  final int trackersCount;
  final int upLimit;
  final int uploaded;
  final int uploadedSession;
  final int upSpeed;

  QbittorrentTorrentInfo({
    required this.addedOn,
    required this.amountLeft,
    required this.autoTmm,
    required this.availability,
    required this.category,
    required this.completed,
    required this.completionOn,
    required this.contentPath,
    required this.dlLimit,
    required this.dlSpeed,
    required this.downloadPath,
    required this.downloaded,
    required this.downloadedSession,
    required this.eta,
    required this.firstLastPiecePriority,
    required this.forceStart,
    required this.hash,
    required this.infohashV1,
    required this.infohashV2,
    required this.lastActivity,
    required this.magnetUri,
    required this.maxRatio,
    required this.maxSeedingTime,
    required this.name,
    required this.numComplete,
    required this.numIncomplete,
    required this.numLeechs,
    required this.numSeeds,
    required this.priority,
    required this.progress,
    required this.ratio,
    required this.ratioLimit,
    required this.savePath,
    required this.seedingTime,
    required this.seedingTimeLimit,
    required this.seenComplete,
    required this.sequentialDownload,
    required this.size,
    required this.state,
    required this.superSeeding,
    required this.tags,
    required this.timeActive,
    required this.totalSize,
    required this.tracker,
    required this.trackersCount,
    required this.upLimit,
    required this.uploaded,
    required this.uploadedSession,
    required this.upSpeed,
  });

  factory QbittorrentTorrentInfo.fromJson(Map<String, dynamic> json) {
    return QbittorrentTorrentInfo(
      addedOn: json['added_on'] ?? 0,
      amountLeft: json['amount_left'] ?? 0,
      autoTmm: json['auto_tmm'] ?? false,
      availability: (json['availability'] as num?)?.toInt() ?? -1,
      category: json['category'] ?? '',
      completed: json['completed'] ?? 0,
      completionOn: json['completion_on'] ?? 0,
      contentPath: json['content_path'] ?? '',
      dlLimit: json['dl_limit'] ?? 0,
      dlSpeed: json['dlspeed'] ?? 0,
      downloadPath: json['download_path'] ?? '',
      downloaded: json['downloaded'] ?? 0,
      downloadedSession: json['downloaded_session'] ?? 0,
      eta: json['eta'] ?? 0,
      firstLastPiecePriority: json['f_l_piece_prio'] ?? false,
      forceStart: json['force_start'] ?? false,
      hash: json['hash'] ?? '',
      infohashV1: json['hash'] ?? json['infohash_v1'],
      infohashV2: json['infohash_v2'] ?? '',
      lastActivity: json['last_activity'] ?? 0,
      magnetUri: json['magnet_uri'] ?? '',
      maxRatio: (json['max_ratio'] as num?)?.toDouble() ?? -1.0,
      maxSeedingTime: json['max_seeding_time'] ?? -1,
      name: json['name'] ?? '',
      numComplete: json['num_complete'] ?? 0,
      numIncomplete: json['num_incomplete'] ?? 0,
      numLeechs: json['num_leechs'] ?? 0,
      numSeeds: json['num_seeds'] ?? 0,
      priority: json['priority'] ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      ratio: (json['ratio'] as num?)?.toDouble() ?? 0.0,
      ratioLimit: (json['ratio_limit'] as num?)?.toDouble() ?? -2.0,
      savePath: json['save_path'] ?? '',
      seedingTime: json['seeding_time'] ?? 0,
      seedingTimeLimit: json['seeding_time_limit'] ?? -2,
      seenComplete: json['seen_complete'] ?? 0,
      sequentialDownload: json['seq_dl'] ?? false,
      size: json['size'] ?? 0,
      state: json['state'] ?? '',
      superSeeding: json['super_seeding'] ?? false,
      tags: json['tags'] ?? '',
      timeActive: json['time_active'] ?? 0,
      totalSize: json['total_size'] ?? 0,
      tracker: json['tracker'] ?? '',
      trackersCount: json['trackers_count'] ?? 0,
      upLimit: json['up_limit'] ?? 0,
      uploaded: json['uploaded'] ?? 0,
      uploadedSession: json['uploaded_session'] ?? 0,
      upSpeed: json['upspeed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'added_on': addedOn,
      'amount_left': amountLeft,
      'auto_tmm': autoTmm,
      'availability': availability,
      'category': category,
      'completed': completed,
      'completion_on': completionOn,
      'content_path': contentPath,
      'dl_limit': dlLimit,
      'dlspeed': dlSpeed,
      'download_path': downloadPath,
      'downloaded': downloaded,
      'downloaded_session': downloadedSession,
      'eta': eta,
      'f_l_piece_prio': firstLastPiecePriority,
      'force_start': forceStart,
      'hash': hash,
      'infohash_v1': infohashV1,
      'infohash_v2': infohashV2,
      'last_activity': lastActivity,
      'magnet_uri': magnetUri,
      'max_ratio': maxRatio,
      'max_seeding_time': maxSeedingTime,
      'name': name,
      'num_complete': numComplete,
      'num_incomplete': numIncomplete,
      'num_leechs': numLeechs,
      'num_seeds': numSeeds,
      'priority': priority,
      'progress': progress,
      'ratio': ratio,
      'ratio_limit': ratioLimit,
      'save_path': savePath,
      'seeding_time': seedingTime,
      'seeding_time_limit': seedingTimeLimit,
      'seen_complete': seenComplete,
      'seq_dl': sequentialDownload,
      'size': size,
      'state': state,
      'super_seeding': superSeeding,
      'tags': tags,
      'time_active': timeActive,
      'total_size': totalSize,
      'tracker': tracker,
      'trackers_count': trackersCount,
      'up_limit': upLimit,
      'uploaded': uploaded,
      'uploaded_session': uploadedSession,
      'upspeed': upSpeed,
    };
  }
}

class QbittorrentPreferences {
  String addTrackers;
  bool addTrackersEnabled;
  int altDlLimit;
  int altUpLimit;
  bool alternativeWebuiEnabled;
  String alternativeWebuiPath;
  String announceIp;
  bool announceToAllTiers;
  bool announceToAllTrackers;
  bool anonymousMode;
  int asyncIoThreads;
  int autoDeleteMode;
  bool autoTmmEnabled;
  bool autorunEnabled;
  bool autorunOnTorrentAddedEnabled;
  String autorunOnTorrentAddedProgram;
  String autorunProgram;
  String bannedIps;
  int bittorrentProtocol;
  bool blockPeersOnPrivilegedPorts;
  String bypassAuthSubnetWhitelist;
  bool bypassAuthSubnetWhitelistEnabled;
  bool bypassLocalAuth;
  bool categoryChangedTmmEnabled;
  int checkingMemoryUse;
  int connectionSpeed;
  String currentInterfaceAddress;
  String currentNetworkInterface;
  bool dht;
  int diskCache;
  int diskCacheTtl;
  int diskIoReadMode;
  int diskIoType;
  int diskIoWriteMode;
  int diskQueueSize;
  int dlLimit;
  bool dontCountSlowTorrents;
  String dyndnsDomain;
  bool dyndnsEnabled;
  String dyndnsPassword;
  int dyndnsService;
  String dyndnsUsername;
  int embeddedTrackerPort;
  bool embeddedTrackerPortForwarding;
  bool enableCoalesceReadWrite;
  bool enableEmbeddedTracker;
  bool enableMultiConnectionsFromSameIp;
  bool enablePieceExtentAffinity;
  bool enableUploadSuggestions;
  int encryption;
  String excludedFileNames;
  bool excludedFileNamesEnabled;
  String exportDir;
  String exportDirFin;
  int filePoolSize;
  int hashingThreads;
  bool idnSupportEnabled;
  bool incompleteFilesExt;
  bool ipFilterEnabled;
  String ipFilterPath;
  bool ipFilterTrackers;
  bool limitLanPeers;
  bool limitTcpOverhead;
  bool limitUtpRate;
  int listenPort;
  String locale;
  bool lsd;
  bool mailNotificationAuthEnabled;
  String mailNotificationEmail;
  bool mailNotificationEnabled;
  String mailNotificationPassword;
  String mailNotificationSender;
  String mailNotificationSmtp;
  bool mailNotificationSslEnabled;
  String mailNotificationUsername;
  int maxActiveCheckingTorrents;
  int maxActiveDownloads;
  int maxActiveTorrents;
  int maxActiveUploads;
  int maxConcurrentHttpAnnounces;
  int maxConnec;
  int maxConnecPerTorrent;
  double maxRatio;
  int maxRatioAct;
  bool maxRatioEnabled;
  int maxSeedingTime;
  bool maxSeedingTimeEnabled;
  int maxUploads;
  int maxUploadsPerTorrent;
  int memoryWorkingSetLimit;
  int outgoingPortsMax;
  int outgoingPortsMin;
  int peerTos;
  int peerTurnover;
  int peerTurnoverCutoff;
  int peerTurnoverInterval;
  bool performanceWarning;
  bool pex;
  bool preallocateAll;
  bool proxyAuthEnabled;
  bool proxyHostnameLookup;
  String proxyIp;
  String proxyPassword;
  bool proxyPeerConnections;
  int proxyPort;
  bool proxyTorrentsOnly;
  String proxyType;
  String proxyUsername;
  bool queueingEnabled;
  bool randomPort;
  bool reannounceWhenAddressChanged;
  bool recheckCompletedTorrents;
  int refreshInterval;
  int requestQueueSize;
  bool resolvePeerCountries;
  String resumeDataStorageType;
  bool rssAutoDownloadingEnabled;
  bool rssDownloadRepackProperEpisodes;
  int rssMaxArticlesPerFeed;
  bool rssProcessingEnabled;
  int rssRefreshInterval;
  String rssSmartEpisodeFilters;
  String savePath;
  bool savePathChangedTmmEnabled;
  int saveResumeDataInterval;
  Map<String, int> scanDirs;
  int scheduleFromHour;
  int scheduleFromMin;
  int scheduleToHour;
  int scheduleToMin;
  int schedulerDays;
  bool schedulerEnabled;
  int sendBufferLowWatermark;
  int sendBufferWatermark;
  int sendBufferWatermarkFactor;
  int slowTorrentDlRateThreshold;
  int slowTorrentInactiveTimer;
  int slowTorrentUlRateThreshold;
  int socketBacklogSize;
  bool ssrfMitigation;
  bool startPausedEnabled;
  int stopTrackerTimeout;
  String tempPath;
  bool tempPathEnabled;
  bool torrentChangedTmmEnabled;
  String torrentContentLayout;
  String torrentStopCondition;
  int upLimit;
  int uploadChokingAlgorithm;
  int uploadSlotsBehavior;
  bool upnp;
  int upnpLeaseDuration;
  bool useCategoryPathsInManualMode;
  bool useHttps;
  int utpTcpMixedMode;
  bool validateHttpsTrackerCertificate;
  String webUiAddress;
  int webUiBanDuration;
  bool webUiClickjackingProtectionEnabled;
  bool webUiCsrfProtectionEnabled;
  String webUiCustomHttpHeaders;
  String webUiDomainList;
  bool webUiHostHeaderValidationEnabled;
  String webUiHttpsCertPath;
  String webUiHttpsKeyPath;
  int webUiMaxAuthFailCount;
  int webUiPort;
  String webUiReverseProxiesList;
  bool webUiReverseProxyEnabled;
  bool webUiSecureCookieEnabled;
  int webUiSessionTimeout;
  bool webUiUpnp;
  bool webUiUseCustomHttpHeadersEnabled;
  String webUiUsername;

  QbittorrentPreferences({
    required this.addTrackers,
    required this.addTrackersEnabled,
    required this.altDlLimit,
    required this.altUpLimit,
    required this.alternativeWebuiEnabled,
    required this.alternativeWebuiPath,
    required this.announceIp,
    required this.announceToAllTiers,
    required this.announceToAllTrackers,
    required this.anonymousMode,
    required this.asyncIoThreads,
    required this.autoDeleteMode,
    required this.autoTmmEnabled,
    required this.autorunEnabled,
    required this.autorunOnTorrentAddedEnabled,
    required this.autorunOnTorrentAddedProgram,
    required this.autorunProgram,
    required this.bannedIps,
    required this.bittorrentProtocol,
    required this.blockPeersOnPrivilegedPorts,
    required this.bypassAuthSubnetWhitelist,
    required this.bypassAuthSubnetWhitelistEnabled,
    required this.bypassLocalAuth,
    required this.categoryChangedTmmEnabled,
    required this.checkingMemoryUse,
    required this.connectionSpeed,
    required this.currentInterfaceAddress,
    required this.currentNetworkInterface,
    required this.dht,
    required this.diskCache,
    required this.diskCacheTtl,
    required this.diskIoReadMode,
    required this.diskIoType,
    required this.diskIoWriteMode,
    required this.diskQueueSize,
    required this.dlLimit,
    required this.dontCountSlowTorrents,
    required this.dyndnsDomain,
    required this.dyndnsEnabled,
    required this.dyndnsPassword,
    required this.dyndnsService,
    required this.dyndnsUsername,
    required this.embeddedTrackerPort,
    required this.embeddedTrackerPortForwarding,
    required this.enableCoalesceReadWrite,
    required this.enableEmbeddedTracker,
    required this.enableMultiConnectionsFromSameIp,
    required this.enablePieceExtentAffinity,
    required this.enableUploadSuggestions,
    required this.encryption,
    required this.excludedFileNames,
    required this.excludedFileNamesEnabled,
    required this.exportDir,
    required this.exportDirFin,
    required this.filePoolSize,
    required this.hashingThreads,
    required this.idnSupportEnabled,
    required this.incompleteFilesExt,
    required this.ipFilterEnabled,
    required this.ipFilterPath,
    required this.ipFilterTrackers,
    required this.limitLanPeers,
    required this.limitTcpOverhead,
    required this.limitUtpRate,
    required this.listenPort,
    required this.locale,
    required this.lsd,
    required this.mailNotificationAuthEnabled,
    required this.mailNotificationEmail,
    required this.mailNotificationEnabled,
    required this.mailNotificationPassword,
    required this.mailNotificationSender,
    required this.mailNotificationSmtp,
    required this.mailNotificationSslEnabled,
    required this.mailNotificationUsername,
    required this.maxActiveCheckingTorrents,
    required this.maxActiveDownloads,
    required this.maxActiveTorrents,
    required this.maxActiveUploads,
    required this.maxConcurrentHttpAnnounces,
    required this.maxConnec,
    required this.maxConnecPerTorrent,
    required this.maxRatio,
    required this.maxRatioAct,
    required this.maxRatioEnabled,
    required this.maxSeedingTime,
    required this.maxSeedingTimeEnabled,
    required this.maxUploads,
    required this.maxUploadsPerTorrent,
    required this.memoryWorkingSetLimit,
    required this.outgoingPortsMax,
    required this.outgoingPortsMin,
    required this.peerTos,
    required this.peerTurnover,
    required this.peerTurnoverCutoff,
    required this.peerTurnoverInterval,
    required this.performanceWarning,
    required this.pex,
    required this.preallocateAll,
    required this.proxyAuthEnabled,
    required this.proxyHostnameLookup,
    required this.proxyIp,
    required this.proxyPassword,
    required this.proxyPeerConnections,
    required this.proxyPort,
    required this.proxyTorrentsOnly,
    required this.proxyType,
    required this.proxyUsername,
    required this.queueingEnabled,
    required this.randomPort,
    required this.reannounceWhenAddressChanged,
    required this.recheckCompletedTorrents,
    required this.refreshInterval,
    required this.requestQueueSize,
    required this.resolvePeerCountries,
    required this.resumeDataStorageType,
    required this.rssAutoDownloadingEnabled,
    required this.rssDownloadRepackProperEpisodes,
    required this.rssMaxArticlesPerFeed,
    required this.rssProcessingEnabled,
    required this.rssRefreshInterval,
    required this.rssSmartEpisodeFilters,
    required this.savePath,
    required this.savePathChangedTmmEnabled,
    required this.saveResumeDataInterval,
    required this.scanDirs,
    required this.scheduleFromHour,
    required this.scheduleFromMin,
    required this.scheduleToHour,
    required this.scheduleToMin,
    required this.schedulerDays,
    required this.schedulerEnabled,
    required this.sendBufferLowWatermark,
    required this.sendBufferWatermark,
    required this.sendBufferWatermarkFactor,
    required this.slowTorrentDlRateThreshold,
    required this.slowTorrentInactiveTimer,
    required this.slowTorrentUlRateThreshold,
    required this.socketBacklogSize,
    required this.ssrfMitigation,
    required this.startPausedEnabled,
    required this.stopTrackerTimeout,
    required this.tempPath,
    required this.tempPathEnabled,
    required this.torrentChangedTmmEnabled,
    required this.torrentContentLayout,
    required this.torrentStopCondition,
    required this.upLimit,
    required this.uploadChokingAlgorithm,
    required this.uploadSlotsBehavior,
    required this.upnp,
    required this.upnpLeaseDuration,
    required this.useCategoryPathsInManualMode,
    required this.useHttps,
    required this.utpTcpMixedMode,
    required this.validateHttpsTrackerCertificate,
    required this.webUiAddress,
    required this.webUiBanDuration,
    required this.webUiClickjackingProtectionEnabled,
    required this.webUiCsrfProtectionEnabled,
    required this.webUiCustomHttpHeaders,
    required this.webUiDomainList,
    required this.webUiHostHeaderValidationEnabled,
    required this.webUiHttpsCertPath,
    required this.webUiHttpsKeyPath,
    required this.webUiMaxAuthFailCount,
    required this.webUiPort,
    required this.webUiReverseProxiesList,
    required this.webUiReverseProxyEnabled,
    required this.webUiSecureCookieEnabled,
    required this.webUiSessionTimeout,
    required this.webUiUpnp,
    required this.webUiUseCustomHttpHeadersEnabled,
    required this.webUiUsername,
  });

  factory QbittorrentPreferences.fromJson(Map<String, dynamic> json) {
    return QbittorrentPreferences(
      addTrackers: json['add_trackers'] ?? '',
      addTrackersEnabled: json['add_trackers_enabled'] ?? false,
      altDlLimit: json['alt_dl_limit'] ?? 0,
      altUpLimit: json['alt_up_limit'] ?? 0,
      alternativeWebuiEnabled: json['alternative_webui_enabled'] ?? false,
      alternativeWebuiPath: json['alternative_webui_path'] ?? '',
      announceIp: json['announce_ip'] ?? '',
      announceToAllTiers: json['announce_to_all_tiers'] ?? false,
      announceToAllTrackers: json['announce_to_all_trackers'] ?? false,
      anonymousMode: json['anonymous_mode'] ?? false,
      asyncIoThreads: json['async_io_threads'] ?? 0,
      autoDeleteMode: json['auto_delete_mode'] ?? 0,
      autoTmmEnabled: json['auto_tmm_enabled'] ?? false,
      autorunEnabled: json['autorun_enabled'] ?? false,
      autorunOnTorrentAddedEnabled:
          json['autorun_on_torrent_added_enabled'] ?? false,
      autorunOnTorrentAddedProgram:
          json['autorun_on_torrent_added_program'] ?? '',
      autorunProgram: json['autorun_program'] ?? '',
      bannedIps: json['banned_IPs'] ?? '',
      bittorrentProtocol: json['bittorrent_protocol'] ?? 0,
      blockPeersOnPrivilegedPorts:
          json['block_peers_on_privileged_ports'] ?? false,
      bypassAuthSubnetWhitelist: json['bypass_auth_subnet_whitelist'] ?? '',
      bypassAuthSubnetWhitelistEnabled:
          json['bypass_auth_subnet_whitelist_enabled'] ?? false,
      bypassLocalAuth: json['bypass_local_auth'] ?? false,
      categoryChangedTmmEnabled: json['category_changed_tmm_enabled'] ?? false,
      checkingMemoryUse: json['checking_memory_use'] ?? 0,
      connectionSpeed: json['connection_speed'] ?? 0,
      currentInterfaceAddress: json['current_interface_address'] ?? '',
      currentNetworkInterface: json['current_network_interface'] ?? '',
      dht: json['dht'] ?? false,
      diskCache: json['disk_cache'] ?? 0,
      diskCacheTtl: json['disk_cache_ttl'] ?? 0,
      diskIoReadMode: json['disk_io_read_mode'] ?? 0,
      diskIoType: json['disk_io_type'] ?? 0,
      diskIoWriteMode: json['disk_io_write_mode'] ?? 0,
      diskQueueSize: json['disk_queue_size'] ?? 0,
      dlLimit: json['dl_limit'] ?? 0,
      dontCountSlowTorrents: json['dont_count_slow_torrents'] ?? false,
      dyndnsDomain: json['dyndns_domain'] ?? '',
      dyndnsEnabled: json['dyndns_enabled'] ?? false,
      dyndnsPassword: json['dyndns_password'] ?? '',
      dyndnsService: json['dyndns_service'] ?? 0,
      dyndnsUsername: json['dyndns_username'] ?? '',
      embeddedTrackerPort: json['embedded_tracker_port'] ?? 0,
      embeddedTrackerPortForwarding:
          json['embedded_tracker_port_forwarding'] ?? false,
      enableCoalesceReadWrite: json['enable_coalesce_read_write'] ?? false,
      enableEmbeddedTracker: json['enable_embedded_tracker'] ?? false,
      enableMultiConnectionsFromSameIp:
          json['enable_multi_connections_from_same_ip'] ?? false,
      enablePieceExtentAffinity: json['enable_piece_extent_affinity'] ?? false,
      enableUploadSuggestions: json['enable_upload_suggestions'] ?? false,
      encryption: json['encryption'] ?? 0,
      excludedFileNames: json['excluded_file_names'] ?? '',
      excludedFileNamesEnabled: json['excluded_file_names_enabled'] ?? false,
      exportDir: json['export_dir'] ?? '',
      exportDirFin: json['export_dir_fin'] ?? '',
      filePoolSize: json['file_pool_size'] ?? 0,
      hashingThreads: json['hashing_threads'] ?? 0,
      idnSupportEnabled: json['idn_support_enabled'] ?? false,
      incompleteFilesExt: json['incomplete_files_ext'] ?? false,
      ipFilterEnabled: json['ip_filter_enabled'] ?? false,
      ipFilterPath: json['ip_filter_path'] ?? '',
      ipFilterTrackers: json['ip_filter_trackers'] ?? false,
      limitLanPeers: json['limit_lan_peers'] ?? false,
      limitTcpOverhead: json['limit_tcp_overhead'] ?? false,
      limitUtpRate: json['limit_utp_rate'] ?? false,
      listenPort: json['listen_port'] ?? 0,
      locale: json['locale'] ?? '',
      lsd: json['lsd'] ?? false,
      mailNotificationAuthEnabled:
          json['mail_notification_auth_enabled'] ?? false,
      mailNotificationEmail: json['mail_notification_email'] ?? '',
      mailNotificationEnabled: json['mail_notification_enabled'] ?? false,
      mailNotificationPassword: json['mail_notification_password'] ?? '',
      mailNotificationSender: json['mail_notification_sender'] ?? '',
      mailNotificationSmtp: json['mail_notification_smtp'] ?? '',
      mailNotificationSslEnabled:
          json['mail_notification_ssl_enabled'] ?? false,
      mailNotificationUsername: json['mail_notification_username'] ?? '',
      maxActiveCheckingTorrents: json['max_active_checking_torrents'] ?? 0,
      maxActiveDownloads: json['max_active_downloads'] ?? 0,
      maxActiveTorrents: json['max_active_torrents'] ?? 0,
      maxActiveUploads: json['max_active_uploads'] ?? 0,
      maxConcurrentHttpAnnounces: json['max_concurrent_http_announces'] ?? 0,
      maxConnec: json['max_connec'] ?? 0,
      maxConnecPerTorrent: json['max_connec_per_torrent'] ?? 0,
      maxRatio: json['max_ratio'].toDouble() ?? 0.0,
      maxRatioAct: json['max_ratio_act'] ?? 0,
      maxRatioEnabled: json['max_ratio_enabled'] ?? false,
      maxSeedingTime: json['max_seeding_time'] ?? 0,
      maxSeedingTimeEnabled: json['max_seeding_time_enabled'] ?? false,
      maxUploads: json['max_uploads'] ?? 0,
      maxUploadsPerTorrent: json['max_uploads_per_torrent'] ?? 0,
      memoryWorkingSetLimit: json['memory_working_set_limit'] ?? 0,
      outgoingPortsMax: json['outgoing_ports_max'] ?? 0,
      outgoingPortsMin: json['outgoing_ports_min'] ?? 0,
      peerTos: json['peer_tos'] ?? 0,
      peerTurnover: json['peer_turnover'] ?? 0,
      peerTurnoverCutoff: json['peer_turnover_cutoff'] ?? 0,
      peerTurnoverInterval: json['peer_turnover_interval'] ?? 0,
      performanceWarning: json['performance_warning'] ?? false,
      pex: json['pex'] ?? false,
      preallocateAll: json['preallocate_all'] ?? false,
      proxyAuthEnabled: json['proxy_auth_enabled'] ?? false,
      proxyHostnameLookup: json['proxy_hostname_lookup'] ?? false,
      proxyIp: json['proxy_ip'] ?? '',
      proxyPassword: json['proxy_password'] ?? '',
      proxyPeerConnections: json['proxy_peer_connections'] ?? false,
      proxyPort: json['proxy_port'] ?? 0,
      proxyTorrentsOnly: json['proxy_torrents_only'] ?? false,
      proxyType: json['proxy_type'],
      proxyUsername: json['proxy_username'] ?? '',
      queueingEnabled: json['queueing_enabled'] ?? false,
      randomPort: json['random_port'] ?? false,
      reannounceWhenAddressChanged:
          json['reannounce_when_address_changed'] ?? false,
      recheckCompletedTorrents: json['recheck_completed_torrents'] ?? false,
      refreshInterval: json['refresh_interval'] ?? 0,
      requestQueueSize: json['request_queue_size'] ?? 0,
      resolvePeerCountries: json['resolve_peer_countries'] ?? false,
      resumeDataStorageType: json['resume_data_storage_type'] ?? '',
      rssAutoDownloadingEnabled: json['rss_auto_downloading_enabled'] ?? false,
      rssDownloadRepackProperEpisodes:
          json['rss_download_repack_proper_episodes'] ?? false,
      rssMaxArticlesPerFeed: json['rss_max_articles_per_feed'] ?? 0,
      rssProcessingEnabled: json['rss_processing_enabled'] ?? false,
      rssRefreshInterval: json['rss_refresh_interval'] ?? 0,
      rssSmartEpisodeFilters: json['rss_smart_episode_filters'] ?? '',
      savePath: json['save_path'] ?? '',
      savePathChangedTmmEnabled: json['save_path_changed_tmm_enabled'] ?? false,
      saveResumeDataInterval: json['save_resume_data_interval'] ?? 0,
      scanDirs: Map<String, int>.from(json['scan_dirs'] ?? {}),
      scheduleFromHour: json['schedule_from_hour'] ?? 0,
      scheduleFromMin: json['schedule_from_min'] ?? 0,
      scheduleToHour: json['schedule_to_hour'] ?? 0,
      scheduleToMin: json['schedule_to_min'] ?? 0,
      schedulerDays: json['scheduler_days'] ?? 0,
      schedulerEnabled: json['scheduler_enabled'] ?? false,
      sendBufferLowWatermark: json['send_buffer_low_watermark'] ?? 0,
      sendBufferWatermark: json['send_buffer_watermark'] ?? 0,
      sendBufferWatermarkFactor: json['send_buffer_watermark_factor'] ?? 0,
      slowTorrentDlRateThreshold: json['slow_torrent_dl_rate_threshold'] ?? 0,
      slowTorrentInactiveTimer: json['slow_torrent_inactive_timer'] ?? 0,
      slowTorrentUlRateThreshold: json['slow_torrent_ul_rate_threshold'] ?? 0,
      socketBacklogSize: json['socket_backlog_size'] ?? 0,
      ssrfMitigation: json['ssrf_mitigation'] ?? false,
      startPausedEnabled: json['start_paused_enabled'] ?? false,
      stopTrackerTimeout: json['stop_tracker_timeout'] ?? 0,
      tempPath: json['temp_path'] ?? '',
      tempPathEnabled: json['temp_path_enabled'] ?? false,
      torrentChangedTmmEnabled: json['torrent_changed_tmm_enabled'] ?? false,
      torrentContentLayout: json['torrent_content_layout'] ?? '',
      torrentStopCondition: json['torrent_stop_condition'] ?? 'None',
      upLimit: json['up_limit'] ?? 0,
      uploadChokingAlgorithm: json['upload_choking_algorithm'] ?? 0,
      uploadSlotsBehavior: json['upload_slots_behavior'] ?? 0,
      upnp: json['upnp'] ?? false,
      upnpLeaseDuration: json['upnp_lease_duration'] ?? 0,
      useCategoryPathsInManualMode:
          json['use_category_paths_in_manual_mode'] ?? false,
      useHttps: json['use_https'] ?? false,
      utpTcpMixedMode: json['utp_tcp_mixed_mode'] ?? 0,
      validateHttpsTrackerCertificate:
          json['validate_https_tracker_certificate'] ?? false,
      webUiAddress: json['web_ui_address'] ?? '',
      webUiBanDuration: json['web_ui_ban_duration'] ?? 0,
      webUiClickjackingProtectionEnabled:
          json['web_ui_clickjacking_protection_enabled'] ?? false,
      webUiCsrfProtectionEnabled:
          json['web_ui_csrf_protection_enabled'] ?? false,
      webUiCustomHttpHeaders: json['web_ui_custom_http_headers'] ?? '',
      webUiDomainList: json['web_ui_domain_list'] ?? '',
      webUiHostHeaderValidationEnabled:
          json['web_ui_host_header_validation_enabled'] ?? false,
      webUiHttpsCertPath: json['web_ui_https_cert_path'] ?? '',
      webUiHttpsKeyPath: json['web_ui_https_key_path'] ?? '',
      webUiMaxAuthFailCount: json['web_ui_max_auth_fail_count'] ?? 0,
      webUiPort: json['web_ui_port'] ?? 0,
      webUiReverseProxiesList: json['web_ui_reverse_proxies_list'] ?? '',
      webUiReverseProxyEnabled: json['web_ui_reverse_proxy_enabled'] ?? false,
      webUiSecureCookieEnabled: json['web_ui_secure_cookie_enabled'] ?? false,
      webUiSessionTimeout: json['web_ui_session_timeout'] ?? 0,
      webUiUpnp: json['web_ui_upnp'] ?? false,
      webUiUseCustomHttpHeadersEnabled:
          json['web_ui_use_custom_http_headers_enabled'] ?? false,
      webUiUsername: json['web_ui_username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'add_trackers': addTrackers,
      'add_trackers_enabled': addTrackersEnabled,
      'alt_dl_limit': altDlLimit,
      'alt_up_limit': altUpLimit,
      'alternative_webui_enabled': alternativeWebuiEnabled,
      'alternative_webui_path': alternativeWebuiPath,
      'announce_ip': announceIp,
      'announce_to_all_tiers': announceToAllTiers,
      'announce_to_all_trackers': announceToAllTrackers,
      'anonymous_mode': anonymousMode,
      'async_io_threads': asyncIoThreads,
      'auto_delete_mode': autoDeleteMode,
      'auto_tmm_enabled': autoTmmEnabled,
      'autorun_enabled': autorunEnabled,
      'autorun_on_torrent_added_enabled': autorunOnTorrentAddedEnabled,
      'autorun_on_torrent_added_program': autorunOnTorrentAddedProgram,
      'autorun_program': autorunProgram,
      'banned_IPs': bannedIps,
      'bittorrent_protocol': bittorrentProtocol,
      'block_peers_on_privileged_ports': blockPeersOnPrivilegedPorts,
      'bypass_auth_subnet_whitelist': bypassAuthSubnetWhitelist,
      'bypass_auth_subnet_whitelist_enabled': bypassAuthSubnetWhitelistEnabled,
      'bypass_local_auth': bypassLocalAuth,
      'category_changed_tmm_enabled': categoryChangedTmmEnabled,
      'checking_memory_use': checkingMemoryUse,
      'connection_speed': connectionSpeed,
      'current_interface_address': currentInterfaceAddress,
      'current_network_interface': currentNetworkInterface,
      'dht': dht,
      'disk_cache': diskCache,
      'disk_cache_ttl': diskCacheTtl,
      'disk_io_read_mode': diskIoReadMode,
      'disk_io_type': diskIoType,
      'disk_io_write_mode': diskIoWriteMode,
      'disk_queue_size': diskQueueSize,
      'dl_limit': dlLimit,
      'dont_count_slow_torrents': dontCountSlowTorrents,
      'dyndns_domain': dyndnsDomain,
      'dyndns_enabled': dyndnsEnabled,
      'dyndns_password': dyndnsPassword,
      'dyndns_service': dyndnsService,
      'dyndns_username': dyndnsUsername,
      'embedded_tracker_port': embeddedTrackerPort,
      'embedded_tracker_port_forwarding': embeddedTrackerPortForwarding,
      'enable_coalesce_read_write': enableCoalesceReadWrite,
      'enable_embedded_tracker': enableEmbeddedTracker,
      'enable_multi_connections_from_same_ip': enableMultiConnectionsFromSameIp,
      'enable_piece_extent_affinity': enablePieceExtentAffinity,
      'enable_upload_suggestions': enableUploadSuggestions,
      'encryption': encryption,
      'excluded_file_names': excludedFileNames,
      'excluded_file_names_enabled': excludedFileNamesEnabled,
      'export_dir': exportDir,
      'export_dir_fin': exportDirFin,
      'file_pool_size': filePoolSize,
      'hashing_threads': hashingThreads,
      'idn_support_enabled': idnSupportEnabled,
      'incomplete_files_ext': incompleteFilesExt,
      'ip_filter_enabled': ipFilterEnabled,
      'ip_filter_path': ipFilterPath,
      'ip_filter_trackers': ipFilterTrackers,
      'limit_lan_peers': limitLanPeers,
      'limit_tcp_overhead': limitTcpOverhead,
      'limit_utp_rate': limitUtpRate,
      'listen_port': listenPort,
      'locale': locale,
      'lsd': lsd,
      'mail_notification_auth_enabled': mailNotificationAuthEnabled,
      'mail_notification_email': mailNotificationEmail,
      'mail_notification_enabled': mailNotificationEnabled,
      'mail_notification_password': mailNotificationPassword,
      'mail_notification_sender': mailNotificationSender,
      'mail_notification_smtp': mailNotificationSmtp,
      'mail_notification_ssl_enabled': mailNotificationSslEnabled,
      'mail_notification_username': mailNotificationUsername,
      'max_active_checking_torrents': maxActiveCheckingTorrents,
      'max_active_downloads': maxActiveDownloads,
      'max_active_torrents': maxActiveTorrents,
      'max_active_uploads': maxActiveUploads,
      'max_concurrent_http_announces': maxConcurrentHttpAnnounces,
      'max_connec': maxConnec,
      'max_connec_per_torrent': maxConnecPerTorrent,
      'max_ratio': maxRatio,
      'max_ratio_act': maxRatioAct,
      'max_ratio_enabled': maxRatioEnabled,
      'max_seeding_time': maxSeedingTime,
      'max_seeding_time_enabled': maxSeedingTimeEnabled,
      'max_uploads': maxUploads,
      'max_uploads_per_torrent': maxUploadsPerTorrent,
      'memory_working_set_limit': memoryWorkingSetLimit,
      'outgoing_ports_max': outgoingPortsMax,
      'outgoing_ports_min': outgoingPortsMin,
      'peer_tos': peerTos,
      'peer_turnover': peerTurnover,
      'peer_turnover_cutoff': peerTurnoverCutoff,
      'peer_turnover_interval': peerTurnoverInterval,
      'performance_warning': performanceWarning,
      'pex': pex,
      'preallocate_all': preallocateAll,
      'proxy_auth_enabled': proxyAuthEnabled,
      'proxy_hostname_lookup': proxyHostnameLookup,
      'proxy_ip': proxyIp,
      'proxy_password': proxyPassword,
      'proxy_peer_connections': proxyPeerConnections,
      'proxy_port': proxyPort,
      'proxy_torrents_only': proxyTorrentsOnly,
      'proxy_type': proxyType,
      'proxy_username': proxyUsername,
      'queueing_enabled': queueingEnabled,
      'random_port': randomPort,
      'reannounce_when_address_changed': reannounceWhenAddressChanged,
      'recheck_completed_torrents': recheckCompletedTorrents,
      'refresh_interval': refreshInterval,
      'request_queue_size': requestQueueSize,
      'resolve_peer_countries': resolvePeerCountries,
      'resume_data_storage_type': resumeDataStorageType,
      'rss_auto_downloading_enabled': rssAutoDownloadingEnabled,
      'rss_download_repack_proper_episodes': rssDownloadRepackProperEpisodes,
      'rss_max_articles_per_feed': rssMaxArticlesPerFeed,
      'rss_processing_enabled': rssProcessingEnabled,
      'rss_refresh_interval': rssRefreshInterval,
      'rss_smart_episode_filters': rssSmartEpisodeFilters,
      'save_path': savePath,
      'save_path_changed_tmm_enabled': savePathChangedTmmEnabled,
      'save_resume_data_interval': saveResumeDataInterval,
      'scan_dirs': scanDirs,
      'schedule_from_hour': scheduleFromHour,
      'schedule_from_min': scheduleFromMin,
      'schedule_to_hour': scheduleToHour,
      'schedule_to_min': scheduleToMin,
      'scheduler_days': schedulerDays,
      'scheduler_enabled': schedulerEnabled,
      'send_buffer_low_watermark': sendBufferLowWatermark,
      'send_buffer_watermark': sendBufferWatermark,
      'send_buffer_watermark_factor': sendBufferWatermarkFactor,
      'slow_torrent_dl_rate_threshold': slowTorrentDlRateThreshold,
      'slow_torrent_inactive_timer': slowTorrentInactiveTimer,
      'slow_torrent_ul_rate_threshold': slowTorrentUlRateThreshold,
      'socket_backlog_size': socketBacklogSize,
      'ssrf_mitigation': ssrfMitigation,
      'start_paused_enabled': startPausedEnabled,
      'stop_tracker_timeout': stopTrackerTimeout,
      'temp_path': tempPath,
      'temp_path_enabled': tempPathEnabled,
      'torrent_changed_tmm_enabled': torrentChangedTmmEnabled,
      'torrent_content_layout': torrentContentLayout,
      'torrent_stop_condition': torrentStopCondition,
      'up_limit': upLimit,
      'upload_choking_algorithm': uploadChokingAlgorithm,
      'upload_slots_behavior': uploadSlotsBehavior,
      'upnp': upnp,
      'upnp_lease_duration': upnpLeaseDuration,
      'use_category_paths_in_manual_mode': useCategoryPathsInManualMode,
      'use_https': useHttps,
      'utp_tcp_mixed_mode': utpTcpMixedMode,
      'validate_https_tracker_certificate': validateHttpsTrackerCertificate,
      'web_ui_address': webUiAddress,
      'web_ui_ban_duration': webUiBanDuration,
      'web_ui_clickjacking_protection_enabled':
          webUiClickjackingProtectionEnabled,
      'web_ui_csrf_protection_enabled': webUiCsrfProtectionEnabled,
      'web_ui_custom_http_headers': webUiCustomHttpHeaders,
      'web_ui_domain_list': webUiDomainList,
      'web_ui_host_header_validation_enabled': webUiHostHeaderValidationEnabled,
      'web_ui_https_cert_path': webUiHttpsCertPath,
      'web_ui_https_key_path': webUiHttpsKeyPath,
      'web_ui_max_auth_fail_count': webUiMaxAuthFailCount,
      'web_ui_port': webUiPort,
      'web_ui_reverse_proxies_list': webUiReverseProxiesList,
      'web_ui_reverse_proxy_enabled': webUiReverseProxyEnabled,
      'web_ui_secure_cookie_enabled': webUiSecureCookieEnabled,
      'web_ui_session_timeout': webUiSessionTimeout,
      'web_ui_upnp': webUiUpnp,
      'web_ui_use_custom_http_headers_enabled':
          webUiUseCustomHttpHeadersEnabled,
      'web_ui_username': webUiUsername,
    };
  }

  QbittorrentPreferences copyWith({
    String? addTrackers,
    bool? addTrackersEnabled,
    int? altDlLimit,
    int? altUpLimit,
    bool? alternativeWebuiEnabled,
    String? alternativeWebuiPath,
    String? announceIp,
    bool? announceToAllTiers,
    bool? announceToAllTrackers,
    bool? anonymousMode,
    int? asyncIoThreads,
    int? autoDeleteMode,
    bool? autoTmmEnabled,
    bool? autorunEnabled,
    bool? autorunOnTorrentAddedEnabled,
    String? autorunOnTorrentAddedProgram,
    String? autorunProgram,
    String? bannedIps,
    int? bittorrentProtocol,
    bool? blockPeersOnPrivilegedPorts,
    String? bypassAuthSubnetWhitelist,
    bool? bypassAuthSubnetWhitelistEnabled,
    bool? bypassLocalAuth,
    bool? categoryChangedTmmEnabled,
    int? checkingMemoryUse,
    int? connectionSpeed,
    String? currentInterfaceAddress,
    String? currentNetworkInterface,
    bool? dht,
    int? diskCache,
    int? diskCacheTtl,
    int? diskIoReadMode,
    int? diskIoType,
    int? diskIoWriteMode,
    int? diskQueueSize,
    int? dlLimit,
    bool? dontCountSlowTorrents,
    String? dyndnsDomain,
    bool? dyndnsEnabled,
    String? dyndnsPassword,
    int? dyndnsService,
    String? dyndnsUsername,
    int? embeddedTrackerPort,
    bool? embeddedTrackerPortForwarding,
    bool? enableCoalesceReadWrite,
    bool? enableEmbeddedTracker,
    bool? enableMultiConnectionsFromSameIp,
    bool? enablePieceExtentAffinity,
    bool? enableUploadSuggestions,
    int? encryption,
    String? excludedFileNames,
    bool? excludedFileNamesEnabled,
    String? exportDir,
    String? exportDirFin,
    int? filePoolSize,
    int? hashingThreads,
    bool? idnSupportEnabled,
    bool? incompleteFilesExt,
    bool? ipFilterEnabled,
    String? ipFilterPath,
    bool? ipFilterTrackers,
    bool? limitLanPeers,
    bool? limitTcpOverhead,
    bool? limitUtpRate,
    int? listenPort,
    String? locale,
    bool? lsd,
    bool? mailNotificationAuthEnabled,
    String? mailNotificationEmail,
    bool? mailNotificationEnabled,
    String? mailNotificationPassword,
    String? mailNotificationSender,
    String? mailNotificationSmtp,
    bool? mailNotificationSslEnabled,
    String? mailNotificationUsername,
    int? maxActiveCheckingTorrents,
    int? maxActiveDownloads,
    int? maxActiveTorrents,
    int? maxActiveUploads,
    int? maxConcurrentHttpAnnounces,
    int? maxConnec,
    int? maxConnecPerTorrent,
    double? maxRatio,
    int? maxRatioAct,
    bool? maxRatioEnabled,
    int? maxSeedingTime,
    bool? maxSeedingTimeEnabled,
    int? maxUploads,
    int? maxUploadsPerTorrent,
    int? memoryWorkingSetLimit,
    int? outgoingPortsMax,
    int? outgoingPortsMin,
    int? peerTos,
    int? peerTurnover,
    int? peerTurnoverCutoff,
    int? peerTurnoverInterval,
    bool? performanceWarning,
    bool? pex,
    bool? preallocateAll,
    bool? proxyAuthEnabled,
    bool? proxyHostnameLookup,
    String? proxyIp,
    String? proxyPassword,
    bool? proxyPeerConnections,
    int? proxyPort,
    bool? proxyTorrentsOnly,
    String? proxyType,
    String? proxyUsername,
    bool? queueingEnabled,
    bool? randomPort,
    bool? reannounceWhenAddressChanged,
    bool? recheckCompletedTorrents,
    int? refreshInterval,
    int? requestQueueSize,
    bool? resolvePeerCountries,
    String? resumeDataStorageType,
    bool? rssAutoDownloadingEnabled,
    bool? rssDownloadRepackProperEpisodes,
    int? rssMaxArticlesPerFeed,
    bool? rssProcessingEnabled,
    int? rssRefreshInterval,
    String? rssSmartEpisodeFilters,
    String? savePath,
    bool? savePathChangedTmmEnabled,
    int? saveResumeDataInterval,
    Map<String, int>? scanDirs,
    int? scheduleFromHour,
    int? scheduleFromMin,
    int? scheduleToHour,
    int? scheduleToMin,
    int? schedulerDays,
    bool? schedulerEnabled,
    int? sendBufferLowWatermark,
    int? sendBufferWatermark,
    int? sendBufferWatermarkFactor,
    int? slowTorrentDlRateThreshold,
    int? slowTorrentInactiveTimer,
    int? slowTorrentUlRateThreshold,
    int? socketBacklogSize,
    bool? ssrfMitigation,
    bool? startPausedEnabled,
    int? stopTrackerTimeout,
    String? tempPath,
    bool? tempPathEnabled,
    bool? torrentChangedTmmEnabled,
    String? torrentContentLayout,
    String? torrentStopCondition,
    int? upLimit,
    int? uploadChokingAlgorithm,
    int? uploadSlotsBehavior,
    bool? upnp,
    int? upnpLeaseDuration,
    bool? useCategoryPathsInManualMode,
    bool? useHttps,
    int? utpTcpMixedMode,
    bool? validateHttpsTrackerCertificate,
    String? webUiAddress,
    int? webUiBanDuration,
    bool? webUiClickjackingProtectionEnabled,
    bool? webUiCsrfProtectionEnabled,
    String? webUiCustomHttpHeaders,
    String? webUiDomainList,
    bool? webUiHostHeaderValidationEnabled,
    String? webUiHttpsCertPath,
    String? webUiHttpsKeyPath,
    int? webUiMaxAuthFailCount,
    int? webUiPort,
    String? webUiReverseProxiesList,
    bool? webUiReverseProxyEnabled,
    bool? webUiSecureCookieEnabled,
    int? webUiSessionTimeout,
    bool? webUiUpnp,
    bool? webUiUseCustomHttpHeadersEnabled,
    String? webUiUsername,
  }) {
    return QbittorrentPreferences(
      addTrackers: addTrackers ?? this.addTrackers,
      addTrackersEnabled: addTrackersEnabled ?? this.addTrackersEnabled,
      altDlLimit: altDlLimit ?? this.altDlLimit,
      altUpLimit: altUpLimit ?? this.altUpLimit,
      alternativeWebuiEnabled:
          alternativeWebuiEnabled ?? this.alternativeWebuiEnabled,
      alternativeWebuiPath: alternativeWebuiPath ?? this.alternativeWebuiPath,
      announceIp: announceIp ?? this.announceIp,
      announceToAllTiers: announceToAllTiers ?? this.announceToAllTiers,
      announceToAllTrackers:
          announceToAllTrackers ?? this.announceToAllTrackers,
      anonymousMode: anonymousMode ?? this.anonymousMode,
      asyncIoThreads: asyncIoThreads ?? this.asyncIoThreads,
      autoDeleteMode: autoDeleteMode ?? this.autoDeleteMode,
      autoTmmEnabled: autoTmmEnabled ?? this.autoTmmEnabled,
      autorunEnabled: autorunEnabled ?? this.autorunEnabled,
      autorunOnTorrentAddedEnabled:
          autorunOnTorrentAddedEnabled ?? this.autorunOnTorrentAddedEnabled,
      autorunOnTorrentAddedProgram:
          autorunOnTorrentAddedProgram ?? this.autorunOnTorrentAddedProgram,
      autorunProgram: autorunProgram ?? this.autorunProgram,
      bannedIps: bannedIps ?? this.bannedIps,
      bittorrentProtocol: bittorrentProtocol ?? this.bittorrentProtocol,
      blockPeersOnPrivilegedPorts:
          blockPeersOnPrivilegedPorts ?? this.blockPeersOnPrivilegedPorts,
      bypassAuthSubnetWhitelist:
          bypassAuthSubnetWhitelist ?? this.bypassAuthSubnetWhitelist,
      bypassAuthSubnetWhitelistEnabled: bypassAuthSubnetWhitelistEnabled ??
          this.bypassAuthSubnetWhitelistEnabled,
      bypassLocalAuth: bypassLocalAuth ?? this.bypassLocalAuth,
      categoryChangedTmmEnabled:
          categoryChangedTmmEnabled ?? this.categoryChangedTmmEnabled,
      checkingMemoryUse: checkingMemoryUse ?? this.checkingMemoryUse,
      connectionSpeed: connectionSpeed ?? this.connectionSpeed,
      currentInterfaceAddress:
          currentInterfaceAddress ?? this.currentInterfaceAddress,
      currentNetworkInterface:
          currentNetworkInterface ?? this.currentNetworkInterface,
      dht: dht ?? this.dht,
      diskCache: diskCache ?? this.diskCache,
      diskCacheTtl: diskCacheTtl ?? this.diskCacheTtl,
      diskIoReadMode: diskIoReadMode ?? this.diskIoReadMode,
      diskIoType: diskIoType ?? this.diskIoType,
      diskIoWriteMode: diskIoWriteMode ?? this.diskIoWriteMode,
      diskQueueSize: diskQueueSize ?? this.diskQueueSize,
      dlLimit: dlLimit ?? this.dlLimit,
      dontCountSlowTorrents:
          dontCountSlowTorrents ?? this.dontCountSlowTorrents,
      dyndnsDomain: dyndnsDomain ?? this.dyndnsDomain,
      dyndnsEnabled: dyndnsEnabled ?? this.dyndnsEnabled,
      dyndnsPassword: dyndnsPassword ?? this.dyndnsPassword,
      dyndnsService: dyndnsService ?? this.dyndnsService,
      dyndnsUsername: dyndnsUsername ?? this.dyndnsUsername,
      embeddedTrackerPort: embeddedTrackerPort ?? this.embeddedTrackerPort,
      embeddedTrackerPortForwarding:
          embeddedTrackerPortForwarding ?? this.embeddedTrackerPortForwarding,
      enableCoalesceReadWrite:
          enableCoalesceReadWrite ?? this.enableCoalesceReadWrite,
      enableEmbeddedTracker:
          enableEmbeddedTracker ?? this.enableEmbeddedTracker,
      enableMultiConnectionsFromSameIp: enableMultiConnectionsFromSameIp ??
          this.enableMultiConnectionsFromSameIp,
      enablePieceExtentAffinity:
          enablePieceExtentAffinity ?? this.enablePieceExtentAffinity,
      enableUploadSuggestions:
          enableUploadSuggestions ?? this.enableUploadSuggestions,
      encryption: encryption ?? this.encryption,
      excludedFileNames: excludedFileNames ?? this.excludedFileNames,
      excludedFileNamesEnabled:
          excludedFileNamesEnabled ?? this.excludedFileNamesEnabled,
      exportDir: exportDir ?? this.exportDir,
      exportDirFin: exportDirFin ?? this.exportDirFin,
      filePoolSize: filePoolSize ?? this.filePoolSize,
      hashingThreads: hashingThreads ?? this.hashingThreads,
      idnSupportEnabled: idnSupportEnabled ?? this.idnSupportEnabled,
      incompleteFilesExt: incompleteFilesExt ?? this.incompleteFilesExt,
      ipFilterEnabled: ipFilterEnabled ?? this.ipFilterEnabled,
      ipFilterPath: ipFilterPath ?? this.ipFilterPath,
      ipFilterTrackers: ipFilterTrackers ?? this.ipFilterTrackers,
      limitLanPeers: limitLanPeers ?? this.limitLanPeers,
      limitTcpOverhead: limitTcpOverhead ?? this.limitTcpOverhead,
      limitUtpRate: limitUtpRate ?? this.limitUtpRate,
      listenPort: listenPort ?? this.listenPort,
      locale: locale ?? this.locale,
      lsd: lsd ?? this.lsd,
      mailNotificationAuthEnabled:
          mailNotificationAuthEnabled ?? this.mailNotificationAuthEnabled,
      mailNotificationEmail:
          mailNotificationEmail ?? this.mailNotificationEmail,
      mailNotificationEnabled:
          mailNotificationEnabled ?? this.mailNotificationEnabled,
      mailNotificationPassword:
          mailNotificationPassword ?? this.mailNotificationPassword,
      mailNotificationSender:
          mailNotificationSender ?? this.mailNotificationSender,
      mailNotificationSmtp: mailNotificationSmtp ?? this.mailNotificationSmtp,
      mailNotificationSslEnabled:
          mailNotificationSslEnabled ?? this.mailNotificationSslEnabled,
      mailNotificationUsername:
          mailNotificationUsername ?? this.mailNotificationUsername,
      maxActiveCheckingTorrents:
          maxActiveCheckingTorrents ?? this.maxActiveCheckingTorrents,
      maxActiveDownloads: maxActiveDownloads ?? this.maxActiveDownloads,
      maxActiveTorrents: maxActiveTorrents ?? this.maxActiveTorrents,
      maxActiveUploads: maxActiveUploads ?? this.maxActiveUploads,
      maxConcurrentHttpAnnounces:
          maxConcurrentHttpAnnounces ?? this.maxConcurrentHttpAnnounces,
      maxConnec: maxConnec ?? this.maxConnec,
      maxConnecPerTorrent: maxConnecPerTorrent ?? this.maxConnecPerTorrent,
      maxRatio: maxRatio ?? this.maxRatio,
      maxRatioAct: maxRatioAct ?? this.maxRatioAct,
      maxRatioEnabled: maxRatioEnabled ?? this.maxRatioEnabled,
      maxSeedingTime: maxSeedingTime ?? this.maxSeedingTime,
      maxSeedingTimeEnabled:
          maxSeedingTimeEnabled ?? this.maxSeedingTimeEnabled,
      maxUploads: maxUploads ?? this.maxUploads,
      maxUploadsPerTorrent: maxUploadsPerTorrent ?? this.maxUploadsPerTorrent,
      memoryWorkingSetLimit:
          memoryWorkingSetLimit ?? this.memoryWorkingSetLimit,
      outgoingPortsMax: outgoingPortsMax ?? this.outgoingPortsMax,
      outgoingPortsMin: outgoingPortsMin ?? this.outgoingPortsMin,
      peerTos: peerTos ?? this.peerTos,
      peerTurnover: peerTurnover ?? this.peerTurnover,
      peerTurnoverCutoff: peerTurnoverCutoff ?? this.peerTurnoverCutoff,
      peerTurnoverInterval: peerTurnoverInterval ?? this.peerTurnoverInterval,
      performanceWarning: performanceWarning ?? this.performanceWarning,
      pex: pex ?? this.pex,
      preallocateAll: preallocateAll ?? this.preallocateAll,
      proxyAuthEnabled: proxyAuthEnabled ?? this.proxyAuthEnabled,
      proxyHostnameLookup: proxyHostnameLookup ?? this.proxyHostnameLookup,
      proxyIp: proxyIp ?? this.proxyIp,
      proxyPassword: proxyPassword ?? this.proxyPassword,
      proxyPeerConnections: proxyPeerConnections ?? this.proxyPeerConnections,
      proxyPort: proxyPort ?? this.proxyPort,
      proxyTorrentsOnly: proxyTorrentsOnly ?? this.proxyTorrentsOnly,
      proxyType: proxyType ?? this.proxyType,
      proxyUsername: proxyUsername ?? this.proxyUsername,
      queueingEnabled: queueingEnabled ?? this.queueingEnabled,
      randomPort: randomPort ?? this.randomPort,
      reannounceWhenAddressChanged:
          reannounceWhenAddressChanged ?? this.reannounceWhenAddressChanged,
      recheckCompletedTorrents:
          recheckCompletedTorrents ?? this.recheckCompletedTorrents,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      requestQueueSize: requestQueueSize ?? this.requestQueueSize,
      resolvePeerCountries: resolvePeerCountries ?? this.resolvePeerCountries,
      resumeDataStorageType:
          resumeDataStorageType ?? this.resumeDataStorageType,
      rssAutoDownloadingEnabled:
          rssAutoDownloadingEnabled ?? this.rssAutoDownloadingEnabled,
      rssDownloadRepackProperEpisodes: rssDownloadRepackProperEpisodes ??
          this.rssDownloadRepackProperEpisodes,
      rssMaxArticlesPerFeed:
          rssMaxArticlesPerFeed ?? this.rssMaxArticlesPerFeed,
      rssProcessingEnabled: rssProcessingEnabled ?? this.rssProcessingEnabled,
      rssRefreshInterval: rssRefreshInterval ?? this.rssRefreshInterval,
      rssSmartEpisodeFilters:
          rssSmartEpisodeFilters ?? this.rssSmartEpisodeFilters,
      savePath: savePath ?? this.savePath,
      savePathChangedTmmEnabled:
          savePathChangedTmmEnabled ?? this.savePathChangedTmmEnabled,
      saveResumeDataInterval:
          saveResumeDataInterval ?? this.saveResumeDataInterval,
      scanDirs: scanDirs ?? this.scanDirs,
      scheduleFromHour: scheduleFromHour ?? this.scheduleFromHour,
      scheduleFromMin: scheduleFromMin ?? this.scheduleFromMin,
      scheduleToHour: scheduleToHour ?? this.scheduleToHour,
      scheduleToMin: scheduleToMin ?? this.scheduleToMin,
      schedulerDays: schedulerDays ?? this.schedulerDays,
      schedulerEnabled: schedulerEnabled ?? this.schedulerEnabled,
      sendBufferLowWatermark:
          sendBufferLowWatermark ?? this.sendBufferLowWatermark,
      sendBufferWatermark: sendBufferWatermark ?? this.sendBufferWatermark,
      sendBufferWatermarkFactor:
          sendBufferWatermarkFactor ?? this.sendBufferWatermarkFactor,
      slowTorrentDlRateThreshold:
          slowTorrentDlRateThreshold ?? this.slowTorrentDlRateThreshold,
      slowTorrentInactiveTimer:
          slowTorrentInactiveTimer ?? this.slowTorrentInactiveTimer,
      slowTorrentUlRateThreshold:
          slowTorrentUlRateThreshold ?? this.slowTorrentUlRateThreshold,
      socketBacklogSize: socketBacklogSize ?? this.socketBacklogSize,
      ssrfMitigation: ssrfMitigation ?? this.ssrfMitigation,
      startPausedEnabled: startPausedEnabled ?? this.startPausedEnabled,
      stopTrackerTimeout: stopTrackerTimeout ?? this.stopTrackerTimeout,
      tempPath: tempPath ?? this.tempPath,
      tempPathEnabled: tempPathEnabled ?? this.tempPathEnabled,
      torrentChangedTmmEnabled:
          torrentChangedTmmEnabled ?? this.torrentChangedTmmEnabled,
      torrentContentLayout: torrentContentLayout ?? this.torrentContentLayout,
      torrentStopCondition: torrentStopCondition ?? this.torrentStopCondition,
      upLimit: upLimit ?? this.upLimit,
      uploadChokingAlgorithm:
          uploadChokingAlgorithm ?? this.uploadChokingAlgorithm,
      uploadSlotsBehavior: uploadSlotsBehavior ?? this.uploadSlotsBehavior,
      upnp: upnp ?? this.upnp,
      upnpLeaseDuration: upnpLeaseDuration ?? this.upnpLeaseDuration,
      useCategoryPathsInManualMode:
          useCategoryPathsInManualMode ?? this.useCategoryPathsInManualMode,
      useHttps: useHttps ?? this.useHttps,
      utpTcpMixedMode: utpTcpMixedMode ?? this.utpTcpMixedMode,
      validateHttpsTrackerCertificate: validateHttpsTrackerCertificate ??
          this.validateHttpsTrackerCertificate,
      webUiAddress: webUiAddress ?? this.webUiAddress,
      webUiBanDuration: webUiBanDuration ?? this.webUiBanDuration,
      webUiClickjackingProtectionEnabled: webUiClickjackingProtectionEnabled ??
          this.webUiClickjackingProtectionEnabled,
      webUiCsrfProtectionEnabled:
          webUiCsrfProtectionEnabled ?? this.webUiCsrfProtectionEnabled,
      webUiCustomHttpHeaders:
          webUiCustomHttpHeaders ?? this.webUiCustomHttpHeaders,
      webUiDomainList: webUiDomainList ?? this.webUiDomainList,
      webUiHostHeaderValidationEnabled: webUiHostHeaderValidationEnabled ??
          this.webUiHostHeaderValidationEnabled,
      webUiHttpsCertPath: webUiHttpsCertPath ?? this.webUiHttpsCertPath,
      webUiHttpsKeyPath: webUiHttpsKeyPath ?? this.webUiHttpsKeyPath,
      webUiMaxAuthFailCount:
          webUiMaxAuthFailCount ?? this.webUiMaxAuthFailCount,
      webUiPort: webUiPort ?? this.webUiPort,
      webUiReverseProxiesList:
          webUiReverseProxiesList ?? this.webUiReverseProxiesList,
      webUiReverseProxyEnabled:
          webUiReverseProxyEnabled ?? this.webUiReverseProxyEnabled,
      webUiSecureCookieEnabled:
          webUiSecureCookieEnabled ?? this.webUiSecureCookieEnabled,
      webUiSessionTimeout: webUiSessionTimeout ?? this.webUiSessionTimeout,
      webUiUpnp: webUiUpnp ?? this.webUiUpnp,
      webUiUseCustomHttpHeadersEnabled: webUiUseCustomHttpHeadersEnabled ??
          this.webUiUseCustomHttpHeadersEnabled,
      webUiUsername: webUiUsername ?? this.webUiUsername,
    );
  }
}
