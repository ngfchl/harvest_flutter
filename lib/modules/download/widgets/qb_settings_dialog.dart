import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader.dart';
import '../model/qbittorrent_preferences.dart';
import '../service/downloader_service.dart';

class QbSettingsDialog extends ConsumerStatefulWidget {
  final Downloader downloader;
  final int initialIndex;

  const QbSettingsDialog({
    super.key,
    required this.downloader,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<QbSettingsDialog> createState() => _QbSettingsDialogState();
}

class _QbSettingsDialogState extends ConsumerState<QbSettingsDialog> {
  bool _loading = true, _saving = false;
  String? _error;
  QbittorrentPreferences? _prefs;
  int _tabIndex = 0;

  Downloader get d => widget.downloader;

  bool get _isMobile => PlatformTool.isSmallScreenPortrait();

  // ── 行为 ──
  String _locale = "zh_CN";
  bool _confirmTorrentDeletion = true, _confirmTorrentRecheck = true;
  bool _fileLogEnabled = true,
      _fileLogBackupEnabled = true,
      _fileLogDeleteOld = true;
  final _fileLogPathCtrl = TextEditingController(),
      _fileLogMaxSizeCtrl = TextEditingController(),
      _fileLogAgeCtrl = TextEditingController();
  int _fileLogAgeType = 1;
  bool _performanceWarning = false, _statusBarExternalIp = false;

  // ── 下载 ──
  String _torrentContentLayout = 'Original', _torrentStopCondition = 'None';
  bool _addToTopOfQueue = false,
      _addStoppedEnabled = false,
      _mergeTrackers = false;
  bool _preallocateAll = false,
      _incompleteFilesExt = false,
      _useUnwantedFolder = false;
  bool _autoTmmEnabled = false,
      _categoryChangedTmmEnabled = true,
      _savePathChangedTmmEnabled = true;
  bool _torrentChangedTmmEnabled = true,
      _useSubcategories = false,
      _useCategoryPathsInManualMode = false;
  final _savePathCtrl = TextEditingController(),
      _tempPathCtrl = TextEditingController();
  bool _tempPathEnabled = false;
  final _exportDirCtrl = TextEditingController(),
      _exportDirFinCtrl = TextEditingController();
  bool _excludedFileNamesEnabled = false;
  final _excludedFileNamesCtrl = TextEditingController();
  bool _mailNotificationEnabled = false, _mailNotificationSslEnabled = false;
  final _mailNotificationEmailCtrl = TextEditingController(),
      _mailNotificationSmtpCtrl = TextEditingController();
  final _mailNotificationUsernameCtrl = TextEditingController(),
      _mailNotificationPasswordCtrl = TextEditingController();
  bool _autorunEnabled = false, _autorunOnTorrentAddedEnabled = false;
  final _autorunProgramCtrl = TextEditingController(),
      _autorunOnTorrentAddedProgramCtrl = TextEditingController();

  // ── 连接 ──
  final _listenPortCtrl = TextEditingController();
  bool _upnp = false, _randomPort = false;
  final _maxConnecCtrl = TextEditingController(),
      _maxConnecPerTorrentCtrl = TextEditingController();
  final _maxUploadsCtrl = TextEditingController(),
      _maxUploadsPerTorrentCtrl = TextEditingController();
  final _outgoingPortsMinCtrl = TextEditingController(),
      _outgoingPortsMaxCtrl = TextEditingController();
  String _proxyType = 'None';
  final _proxyIpCtrl = TextEditingController(),
      _proxyPortCtrl = TextEditingController();
  bool _proxyAuthEnabled = false,
      _proxyPeerConnections = false,
      _proxyHostnameLookup = false;
  bool _proxyBittorrent = true, _proxyRss = true, _proxyMisc = true;
  final _proxyUsernameCtrl = TextEditingController(),
      _proxyPasswordCtrl = TextEditingController();

  // ── 速度 ──
  final _dlLimitCtrl = TextEditingController(),
      _upLimitCtrl = TextEditingController();
  final _altDlLimitCtrl = TextEditingController(),
      _altUpLimitCtrl = TextEditingController();
  bool _schedulerEnabled = false;
  final _scheduleFromHourCtrl = TextEditingController(),
      _scheduleFromMinCtrl = TextEditingController();
  final _scheduleToHourCtrl = TextEditingController(),
      _scheduleToMinCtrl = TextEditingController();
  int _schedulerDays = 0;
  bool _limitUtpRate = false, _limitTcpOverhead = false, _limitLanPeers = false;

  // ── BitTorrent ──
  bool _dht = false, _pex = false, _lsd = false, _anonymousMode = false;
  int _encryption = 0, _maxActiveCheckingTorrents = 1, _maxRatioAct = 0;
  bool _queueingEnabled = false;
  final _maxActiveDownloadsCtrl = TextEditingController(),
      _maxActiveUploadsCtrl = TextEditingController(),
      _maxActiveTorrentsCtrl = TextEditingController();
  final _slowTorrentDlRateThresholdCtrl = TextEditingController(),
      _slowTorrentUlRateThresholdCtrl = TextEditingController(),
      _slowTorrentInactiveTimerCtrl = TextEditingController();
  bool _maxRatioEnabled = false,
      _maxSeedingTimeEnabled = false,
      _maxInactiveSeedingTimeEnabled = false;
  final _maxRatioCtrl = TextEditingController(),
      _maxSeedingTimeCtrl = TextEditingController(),
      _maxInactiveSeedingTimeCtrl = TextEditingController();
  bool _addTrackersEnabled = false, _addTrackersFromUrlEnabled = false;
  final _addTrackersCtrl = TextEditingController(),
      _addTrackersUrlCtrl = TextEditingController();
  bool _enableEmbeddedTracker = false, _embeddedTrackerPortForwarding = false;
  final _embeddedTrackerPortCtrl = TextEditingController();

  // ── RSS ──
  bool _rssProcessingEnabled = false,
      _rssAutoDownloadingEnabled = false,
      _rssDownloadRepackProperEpisodes = false;
  final _rssRefreshIntervalCtrl = TextEditingController(),
      _rssFetchDelayCtrl = TextEditingController(),
      _rssMaxArticlesPerFeedCtrl = TextEditingController(),
      _rssSmartEpisodeFiltersCtrl = TextEditingController();

  // ── WebUI ──
  final _webUiAddressCtrl = TextEditingController(),
      _webUiPortCtrl = TextEditingController();
  bool _webUiUpnp = false, _useHttps = false;
  final _webUiHttpsCertPathCtrl = TextEditingController(),
      _webUiHttpsKeyPathCtrl = TextEditingController();
  final _webUiUsernameCtrl = TextEditingController(),
      _webUiPasswordCtrl = TextEditingController();
  bool _bypassLocalAuth = false, _bypassAuthSubnetWhitelistEnabled = false;
  final _bypassAuthSubnetWhitelistCtrl = TextEditingController();
  final _webUiMaxAuthFailCountCtrl = TextEditingController(),
      _webUiBanDurationCtrl = TextEditingController(),
      _webUiSessionTimeoutCtrl = TextEditingController();
  bool _alternativeWebuiEnabled = false;
  final _alternativeWebuiPathCtrl = TextEditingController();
  bool _webUiClickjackingProtectionEnabled = false,
      _webUiCsrfProtectionEnabled = false;
  bool _webUiSecureCookieEnabled = false,
      _webUiHostHeaderValidationEnabled = false;
  final _webUiDomainListCtrl = TextEditingController();
  bool _webUiUseCustomHttpHeadersEnabled = false;
  final _webUiCustomHttpHeadersCtrl = TextEditingController();
  bool _webUiReverseProxyEnabled = false;
  final _webUiReverseProxiesListCtrl = TextEditingController();
  bool _dyndnsEnabled = false;
  int _dyndnsService = 0;
  final _dyndnsDomainCtrl = TextEditingController(),
      _dyndnsUsernameCtrl = TextEditingController(),
      _dyndnsPasswordCtrl = TextEditingController();

  // ── 高级 ──
  String _resumeDataStorageType = 'Legacy',
      _torrentContentRemoveOption = 'Delete';
  final _memoryWorkingSetLimitCtrl = TextEditingController();
  final _saveResumeDataIntervalCtrl = TextEditingController(),
      _saveStatisticsIntervalCtrl = TextEditingController(),
      _torrentFileSizeLimitCtrl = TextEditingController();
  bool _resolvePeerCountries = false,
      _reannounceWhenAddressChanged = false,
      _ignoreSslErrors = false;
  final _pythonExecutablePathCtrl = TextEditingController(),
      _refreshIntervalCtrl = TextEditingController(),
      _appInstanceNameCtrl = TextEditingController();
  final _bdecodeDepthLimitCtrl = TextEditingController(),
      _bdecodeTokenLimitCtrl = TextEditingController();
  final _asyncIoThreadsCtrl = TextEditingController(),
      _hashingThreadsCtrl = TextEditingController(),
      _filePoolSizeCtrl = TextEditingController();
  final _checkingMemoryUseCtrl = TextEditingController(),
      _diskQueueSizeCtrl = TextEditingController();
  int _diskIoType = 0, _diskIoReadMode = 0, _diskIoWriteMode = 0;
  bool _enableCoalesceReadWrite = false, _enableUploadSuggestions = false;
  final _sendBufferWatermarkCtrl = TextEditingController(),
      _sendBufferLowWatermarkCtrl = TextEditingController(),
      _sendBufferWatermarkFactorCtrl = TextEditingController();
  final _connectionSpeedCtrl = TextEditingController(),
      _socketSendBufferSizeCtrl = TextEditingController(),
      _socketReceiveBufferSizeCtrl = TextEditingController(),
      _socketBacklogSizeCtrl = TextEditingController();
  final _upnpLeaseDurationCtrl = TextEditingController(),
      _peerTosCtrl = TextEditingController();
  int _utpTcpMixedMode = 0,
      _uploadChokingAlgorithm = 0,
      _uploadSlotsBehavior = 0;
  bool _idnSupportEnabled = false,
      _enableMultiConnectionsFromSameIp = false,
      _validateHttpsTrackerCertificate = false;
  bool _ssrfMitigation = false, _blockPeersOnPrivilegedPorts = false;
  bool _announceToAllTrackers = false, _announceToAllTiers = false;
  final _announceIpCtrl = TextEditingController(),
      _announcePortCtrl = TextEditingController();
  final _maxConcurrentHttpAnnouncesCtrl = TextEditingController(),
      _stopTrackerTimeoutCtrl = TextEditingController();
  final _peerTurnoverCtrl = TextEditingController(),
      _peerTurnoverCutoffCtrl = TextEditingController(),
      _peerTurnoverIntervalCtrl = TextEditingController(),
      _requestQueueSizeCtrl = TextEditingController();
  final _dhtBootstrapNodesCtrl = TextEditingController();
  bool _i2pEnabled = false, _i2pMixedMode = false;
  final _i2pAddressCtrl = TextEditingController(),
      _i2pPortCtrl = TextEditingController();
  final _i2pInboundQuantityCtrl = TextEditingController(),
      _i2pOutboundQuantityCtrl = TextEditingController();
  final _i2pInboundLengthCtrl = TextEditingController(),
      _i2pOutboundLengthCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialIndex.clamp(0, 7).toInt();
    _loadPrefs();
  }

  @override
  void dispose() {
    for (final c in [
      _fileLogPathCtrl,
      _fileLogMaxSizeCtrl,
      _fileLogAgeCtrl,
      _savePathCtrl,
      _tempPathCtrl,
      _exportDirCtrl,
      _exportDirFinCtrl,
      _excludedFileNamesCtrl,
      _mailNotificationEmailCtrl,
      _mailNotificationSmtpCtrl,
      _mailNotificationUsernameCtrl,
      _mailNotificationPasswordCtrl,
      _autorunProgramCtrl,
      _autorunOnTorrentAddedProgramCtrl,
      _listenPortCtrl,
      _maxConnecCtrl,
      _maxConnecPerTorrentCtrl,
      _maxUploadsCtrl,
      _maxUploadsPerTorrentCtrl,
      _outgoingPortsMinCtrl,
      _outgoingPortsMaxCtrl,
      _proxyIpCtrl,
      _proxyPortCtrl,
      _proxyUsernameCtrl,
      _proxyPasswordCtrl,
      _dlLimitCtrl,
      _upLimitCtrl,
      _altDlLimitCtrl,
      _altUpLimitCtrl,
      _scheduleFromHourCtrl,
      _scheduleFromMinCtrl,
      _scheduleToHourCtrl,
      _scheduleToMinCtrl,
      _maxActiveDownloadsCtrl,
      _maxActiveUploadsCtrl,
      _maxActiveTorrentsCtrl,
      _slowTorrentDlRateThresholdCtrl,
      _slowTorrentUlRateThresholdCtrl,
      _slowTorrentInactiveTimerCtrl,
      _maxRatioCtrl,
      _maxSeedingTimeCtrl,
      _maxInactiveSeedingTimeCtrl,
      _addTrackersCtrl,
      _addTrackersUrlCtrl,
      _embeddedTrackerPortCtrl,
      _rssRefreshIntervalCtrl,
      _rssFetchDelayCtrl,
      _rssMaxArticlesPerFeedCtrl,
      _rssSmartEpisodeFiltersCtrl,
      _webUiAddressCtrl,
      _webUiPortCtrl,
      _webUiHttpsCertPathCtrl,
      _webUiHttpsKeyPathCtrl,
      _webUiUsernameCtrl,
      _webUiPasswordCtrl,
      _bypassAuthSubnetWhitelistCtrl,
      _webUiMaxAuthFailCountCtrl,
      _webUiBanDurationCtrl,
      _webUiSessionTimeoutCtrl,
      _alternativeWebuiPathCtrl,
      _webUiDomainListCtrl,
      _webUiCustomHttpHeadersCtrl,
      _webUiReverseProxiesListCtrl,
      _dyndnsDomainCtrl,
      _dyndnsUsernameCtrl,
      _dyndnsPasswordCtrl,
      _memoryWorkingSetLimitCtrl,
      _saveResumeDataIntervalCtrl,
      _saveStatisticsIntervalCtrl,
      _torrentFileSizeLimitCtrl,
      _pythonExecutablePathCtrl,
      _refreshIntervalCtrl,
      _appInstanceNameCtrl,
      _bdecodeDepthLimitCtrl,
      _bdecodeTokenLimitCtrl,
      _asyncIoThreadsCtrl,
      _hashingThreadsCtrl,
      _filePoolSizeCtrl,
      _checkingMemoryUseCtrl,
      _diskQueueSizeCtrl,
      _sendBufferWatermarkCtrl,
      _sendBufferLowWatermarkCtrl,
      _sendBufferWatermarkFactorCtrl,
      _connectionSpeedCtrl,
      _socketSendBufferSizeCtrl,
      _socketReceiveBufferSizeCtrl,
      _socketBacklogSizeCtrl,
      _upnpLeaseDurationCtrl,
      _peerTosCtrl,
      _announceIpCtrl,
      _announcePortCtrl,
      _maxConcurrentHttpAnnouncesCtrl,
      _stopTrackerTimeoutCtrl,
      _peerTurnoverCtrl,
      _peerTurnoverCutoffCtrl,
      _peerTurnoverIntervalCtrl,
      _requestQueueSizeCtrl,
      _dhtBootstrapNodesCtrl,
      _i2pAddressCtrl,
      _i2pPortCtrl,
      _i2pInboundQuantityCtrl,
      _i2pOutboundQuantityCtrl,
      _i2pInboundLengthCtrl,
      _i2pOutboundLengthCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await DownloaderService.fetchPrefs(d.id);
      if (prefs == null) {
        setState(() {
          _loading = false;
          _error = '无法获取设置';
        });
        return;
      }
      _prefs = QbittorrentPreferences.fromJson(prefs);
      _fillAll();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '加载失败: $e';
      });
    }
  }

  void _fillAll() {
    final p = _prefs!;
    _confirmTorrentDeletion = p.confirmTorrentDeletion;
    _confirmTorrentRecheck = p.confirmTorrentRecheck;
    _fileLogEnabled = p.fileLogEnabled;
    _fileLogPathCtrl.text = p.fileLogPath;
    _fileLogMaxSizeCtrl.text = p.fileLogMaxSize.toString();
    _fileLogBackupEnabled = p.fileLogBackupEnabled;
    _fileLogDeleteOld = p.fileLogDeleteOld;
    _fileLogAgeCtrl.text = p.fileLogAge.toString();
    _fileLogAgeType = p.fileLogAgeType;
    _performanceWarning = p.performanceWarning;
    _statusBarExternalIp = p.statusBarExternalIp;
    _torrentContentLayout = p.torrentContentLayout;
    _addToTopOfQueue = p.addToTopOfQueue;
    _addStoppedEnabled = p.addStoppedEnabled;
    _torrentStopCondition = p.torrentStopCondition;
    _mergeTrackers = p.mergeTrackers;
    _preallocateAll = p.preallocateAll;
    _incompleteFilesExt = p.incompleteFilesExt;
    _useUnwantedFolder = p.useUnwantedFolder;
    _autoTmmEnabled = p.autoTmmEnabled;
    _categoryChangedTmmEnabled = p.categoryChangedTmmEnabled;
    _savePathChangedTmmEnabled = p.savePathChangedTmmEnabled;
    _torrentChangedTmmEnabled = p.torrentChangedTmmEnabled;
    _useSubcategories = p.useSubcategories;
    _useCategoryPathsInManualMode = p.useCategoryPathsInManualMode;
    _savePathCtrl.text = p.savePath;
    _tempPathEnabled = p.tempPathEnabled;
    _tempPathCtrl.text = p.tempPath;
    _exportDirCtrl.text = p.exportDir;
    _exportDirFinCtrl.text = p.exportDirFin;
    _excludedFileNamesEnabled = p.excludedFileNamesEnabled;
    _excludedFileNamesCtrl.text = p.excludedFileNames;
    _mailNotificationEnabled = p.mailNotificationEnabled;
    _mailNotificationEmailCtrl.text = p.mailNotificationEmail;
    _mailNotificationSmtpCtrl.text = p.mailNotificationSmtp;
    _mailNotificationSslEnabled = p.mailNotificationSslEnabled;
    _mailNotificationUsernameCtrl.text = p.mailNotificationUsername;
    _mailNotificationPasswordCtrl.text = p.mailNotificationPassword;
    _autorunEnabled = p.autorunEnabled;
    _autorunProgramCtrl.text = p.autorunProgram;
    _autorunOnTorrentAddedEnabled = p.autorunOnTorrentAddedEnabled;
    _autorunOnTorrentAddedProgramCtrl.text = p.autorunOnTorrentAddedProgram;
    _listenPortCtrl.text = p.listenPort.toString();
    _upnp = p.upnp;
    _randomPort = p.randomPort;
    _maxConnecCtrl.text = p.maxConnec.toString();
    _maxConnecPerTorrentCtrl.text = p.maxConnecPerTorrent.toString();
    _maxUploadsCtrl.text = p.maxUploads.toString();
    _maxUploadsPerTorrentCtrl.text = p.maxUploadsPerTorrent.toString();
    _outgoingPortsMinCtrl.text = p.outgoingPortsMin.toString();
    _outgoingPortsMaxCtrl.text = p.outgoingPortsMax.toString();
    _proxyType = p.proxyType;
    _proxyIpCtrl.text = p.proxyIp;
    _proxyPortCtrl.text = p.proxyPort.toString();
    _proxyAuthEnabled = p.proxyAuthEnabled;
    _proxyUsernameCtrl.text = p.proxyUsername;
    _proxyPasswordCtrl.text = p.proxyPassword;
    _proxyPeerConnections = p.proxyPeerConnections;
    _proxyHostnameLookup = p.proxyHostnameLookup;
    _proxyBittorrent = p.proxyBittorrent;
    _proxyRss = p.proxyRss;
    _proxyMisc = p.proxyMisc;
    _dlLimitCtrl.text = p.dlLimit.toString();
    _upLimitCtrl.text = p.upLimit.toString();
    _altDlLimitCtrl.text = p.altDlLimit.toString();
    _altUpLimitCtrl.text = p.altUpLimit.toString();
    _schedulerEnabled = p.schedulerEnabled;
    _scheduleFromHourCtrl.text = p.scheduleFromHour.toString();
    _scheduleFromMinCtrl.text = p.scheduleFromMin.toString();
    _scheduleToHourCtrl.text = p.scheduleToHour.toString();
    _scheduleToMinCtrl.text = p.scheduleToMin.toString();
    _schedulerDays = p.schedulerDays;
    _limitUtpRate = p.limitUtpRate;
    _limitTcpOverhead = p.limitTcpOverhead;
    _limitLanPeers = p.limitLanPeers;
    _dht = p.dht;
    _pex = p.pex;
    _lsd = p.lsd;
    _encryption = p.encryption;
    _anonymousMode = p.anonymousMode;
    _maxActiveCheckingTorrents = p.maxActiveCheckingTorrents;
    _queueingEnabled = p.queueingEnabled;
    _maxActiveDownloadsCtrl.text = p.maxActiveDownloads.toString();
    _maxActiveUploadsCtrl.text = p.maxActiveUploads.toString();
    _maxActiveTorrentsCtrl.text = p.maxActiveTorrents.toString();
    _slowTorrentDlRateThresholdCtrl.text = p.slowTorrentDlRateThreshold
        .toString();
    _slowTorrentUlRateThresholdCtrl.text = p.slowTorrentUlRateThreshold
        .toString();
    _slowTorrentInactiveTimerCtrl.text = p.slowTorrentInactiveTimer.toString();
    _maxRatioEnabled = p.maxRatioEnabled;
    _maxRatioCtrl.text = p.maxRatio.toString();
    _maxSeedingTimeEnabled = p.maxSeedingTimeEnabled;
    _maxSeedingTimeCtrl.text = p.maxSeedingTime.toString();
    _maxInactiveSeedingTimeEnabled = p.maxInactiveSeedingTimeEnabled;
    _maxInactiveSeedingTimeCtrl.text = p.maxInactiveSeedingTime.toString();
    _maxRatioAct = p.maxRatioAct;
    _addTrackersEnabled = p.addTrackersEnabled;
    _addTrackersCtrl.text = p.addTrackers;
    _addTrackersFromUrlEnabled = p.addTrackersFromUrlEnabled;
    _addTrackersUrlCtrl.text = p.addTrackersUrl;
    _enableEmbeddedTracker = p.enableEmbeddedTracker;
    _embeddedTrackerPortCtrl.text = p.embeddedTrackerPort.toString();
    _embeddedTrackerPortForwarding = p.embeddedTrackerPortForwarding;
    _rssProcessingEnabled = p.rssProcessingEnabled;
    _rssRefreshIntervalCtrl.text = p.rssRefreshInterval.toString();
    _rssFetchDelayCtrl.text = p.rssFetchDelay.toString();
    _rssMaxArticlesPerFeedCtrl.text = p.rssMaxArticlesPerFeed.toString();
    _rssAutoDownloadingEnabled = p.rssAutoDownloadingEnabled;
    _rssDownloadRepackProperEpisodes = p.rssDownloadRepackProperEpisodes;
    _rssSmartEpisodeFiltersCtrl.text = p.rssSmartEpisodeFilters;
    _webUiAddressCtrl.text = p.webUiAddress;
    _webUiPortCtrl.text = p.webUiPort.toString();
    _webUiUpnp = p.webUiUpnp;
    _useHttps = p.useHttps;
    _webUiHttpsCertPathCtrl.text = p.webUiHttpsCertPath;
    _webUiHttpsKeyPathCtrl.text = p.webUiHttpsKeyPath;
    _webUiUsernameCtrl.text = p.webUiUsername;
    _bypassLocalAuth = p.bypassLocalAuth;
    _bypassAuthSubnetWhitelistEnabled = p.bypassAuthSubnetWhitelistEnabled;
    _bypassAuthSubnetWhitelistCtrl.text = p.bypassAuthSubnetWhitelist;
    _webUiMaxAuthFailCountCtrl.text = p.webUiMaxAuthFailCount.toString();
    _webUiBanDurationCtrl.text = p.webUiBanDuration.toString();
    _webUiSessionTimeoutCtrl.text = p.webUiSessionTimeout.toString();
    _alternativeWebuiEnabled = p.alternativeWebuiEnabled;
    _alternativeWebuiPathCtrl.text = p.alternativeWebuiPath;
    _webUiClickjackingProtectionEnabled = p.webUiClickjackingProtectionEnabled;
    _webUiCsrfProtectionEnabled = p.webUiCsrfProtectionEnabled;
    _webUiSecureCookieEnabled = p.webUiSecureCookieEnabled;
    _webUiHostHeaderValidationEnabled = p.webUiHostHeaderValidationEnabled;
    _webUiDomainListCtrl.text = p.webUiDomainList;
    _webUiUseCustomHttpHeadersEnabled = p.webUiUseCustomHttpHeadersEnabled;
    _webUiCustomHttpHeadersCtrl.text = p.webUiCustomHttpHeaders;
    _webUiReverseProxyEnabled = p.webUiReverseProxyEnabled;
    _webUiReverseProxiesListCtrl.text = p.webUiReverseProxiesList;
    _dyndnsEnabled = p.dyndnsEnabled;
    _dyndnsService = p.dyndnsService;
    _dyndnsDomainCtrl.text = p.dyndnsDomain;
    _dyndnsUsernameCtrl.text = p.dyndnsUsername;
    _dyndnsPasswordCtrl.text = p.dyndnsPassword;
    _resumeDataStorageType = p.resumeDataStorageType;
    _torrentContentRemoveOption = p.torrentContentRemoveOption;
    _memoryWorkingSetLimitCtrl.text = p.memoryWorkingSetLimit.toString();
    _saveResumeDataIntervalCtrl.text = p.saveResumeDataInterval.toString();
    _saveStatisticsIntervalCtrl.text = p.saveStatisticsInterval.toString();
    _torrentFileSizeLimitCtrl.text = p.torrentFileSizeLimit.toString();
    _resolvePeerCountries = p.resolvePeerCountries;
    _reannounceWhenAddressChanged = p.reannounceWhenAddressChanged;
    _ignoreSslErrors = p.ignoreSslErrors;
    _pythonExecutablePathCtrl.text = p.pythonExecutablePath;
    _refreshIntervalCtrl.text = p.refreshInterval.toString();
    _appInstanceNameCtrl.text = p.appInstanceName;
    _bdecodeDepthLimitCtrl.text = p.bdecodeDepthLimit.toString();
    _bdecodeTokenLimitCtrl.text = p.bdecodeTokenLimit.toString();
    _asyncIoThreadsCtrl.text = p.asyncIoThreads.toString();
    _hashingThreadsCtrl.text = p.hashingThreads.toString();
    _filePoolSizeCtrl.text = p.filePoolSize.toString();
    _checkingMemoryUseCtrl.text = p.checkingMemoryUse.toString();
    _diskQueueSizeCtrl.text = p.diskQueueSize.toString();
    _diskIoType = p.diskIoType;
    _diskIoReadMode = p.diskIoReadMode;
    _diskIoWriteMode = p.diskIoWriteMode;
    _enableCoalesceReadWrite = p.enableCoalesceReadWrite;
    _enableUploadSuggestions = p.enableUploadSuggestions;
    _sendBufferWatermarkCtrl.text = p.sendBufferWatermark.toString();
    _sendBufferLowWatermarkCtrl.text = p.sendBufferLowWatermark.toString();
    _sendBufferWatermarkFactorCtrl.text = p.sendBufferWatermarkFactor
        .toString();
    _connectionSpeedCtrl.text = p.connectionSpeed.toString();
    _socketSendBufferSizeCtrl.text = p.socketSendBufferSize.toString();
    _socketReceiveBufferSizeCtrl.text = p.socketReceiveBufferSize.toString();
    _socketBacklogSizeCtrl.text = p.socketBacklogSize.toString();
    _upnpLeaseDurationCtrl.text = p.upnpLeaseDuration.toString();
    _peerTosCtrl.text = p.peerTos.toString();
    _utpTcpMixedMode = p.utpTcpMixedMode;
    _idnSupportEnabled = p.idnSupportEnabled;
    _enableMultiConnectionsFromSameIp = p.enableMultiConnectionsFromSameIp;
    _validateHttpsTrackerCertificate = p.validateHttpsTrackerCertificate;
    _ssrfMitigation = p.ssrfMitigation;
    _blockPeersOnPrivilegedPorts = p.blockPeersOnPrivilegedPorts;
    _uploadChokingAlgorithm = p.uploadChokingAlgorithm;
    _uploadSlotsBehavior = p.uploadSlotsBehavior;
    _announceToAllTrackers = p.announceToAllTrackers;
    _announceToAllTiers = p.announceToAllTiers;
    _announceIpCtrl.text = p.announceIp;
    _announcePortCtrl.text = p.announcePort.toString();
    _maxConcurrentHttpAnnouncesCtrl.text = p.maxConcurrentHttpAnnounces
        .toString();
    _stopTrackerTimeoutCtrl.text = p.stopTrackerTimeout.toString();
    _peerTurnoverCtrl.text = p.peerTurnover.toString();
    _peerTurnoverCutoffCtrl.text = p.peerTurnoverCutoff.toString();
    _peerTurnoverIntervalCtrl.text = p.peerTurnoverInterval.toString();
    _requestQueueSizeCtrl.text = p.requestQueueSize.toString();
    _dhtBootstrapNodesCtrl.text = p.dhtBootstrapNodes;
    _i2pEnabled = p.i2pEnabled;
    _i2pAddressCtrl.text = p.i2pAddress;
    _i2pPortCtrl.text = p.i2pPort.toString();
    _i2pInboundQuantityCtrl.text = p.i2pInboundQuantity.toString();
    _i2pOutboundQuantityCtrl.text = p.i2pOutboundQuantity.toString();
    _i2pInboundLengthCtrl.text = p.i2pInboundLength.toString();
    _i2pOutboundLengthCtrl.text = p.i2pOutboundLength.toString();
    _i2pMixedMode = p.i2pMixedMode;
  }

  // ── helpers ──
  Widget _sec(shadcn.ThemeData t, String s) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(
      s,
      style: t.typography.small.copyWith(
        fontWeight: FontWeight.w700,
        color: t.colorScheme.primary,
      ),
    ),
  );

  Widget _sw(String title, bool v, ValueChanged<bool> fn) => Builder(
    builder: (context) {
      final cs = shadcn.Theme.of(context).colorScheme;
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: cs.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
            const SizedBox(width: 12),
            Switch(value: v, onChanged: fn),
          ],
        ),
      );
    },
  );

  Widget _tf(
    TextEditingController c,
    String l, {
    String? h,
    TextInputType? k,
    List<TextInputFormatter>? f,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ShadTextField(
      controller: c,
      labelText: l,
      hintText: h,
      keyboardType: k,
      inputFormatters: f,
    ),
  );

  Widget _num(TextEditingController c, String l, {String? h}) => _tf(
    c,
    l,
    h: h,
    k: TextInputType.number,
    f: [FilteringTextInputFormatter.digitsOnly],
  );

  Widget _row(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ],
  );

  Widget _sel(
    String l,
    String v,
    List<String> opts,
    ValueChanged<String?> fn,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: DropdownButtonFormField<String>(
      initialValue: opts.contains(v) ? v : null,
      hint: Text(""),
      items: opts
          .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
          .toList(),
      onChanged: fn,
    ),
  );

  Widget _note(shadcn.ThemeData t, String s) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Text(
      s,
      style: t.typography.xSmall.copyWith(color: t.colorScheme.mutedForeground),
    ),
  );

  int _pi(TextEditingController c, int d) => int.tryParse(c.text.trim()) ?? d;

  double _pd(TextEditingController c, double d) =>
      double.tryParse(c.text.trim()) ?? d;

  String _ps(TextEditingController c) => c.text.trim();

  // ━━━━━━━━━━━━━ 行为 ━━━━━━━━━━━━━
  Widget _behaviorContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, '语言'),
      _sel('用户界面语言', _locale, [
        'zh_CN',
        'en',
        'ja',
        'ko',
      ], (v) => setState(() => _locale = v ?? _locale)),
      // _sec(t, '界面'),
      // _sel('配色方案', _colorScheme, ['自动', '浅色', '深色'],
      _sec(t, '传输列表'),
      _sw(
        '删除 Torrent 时提示确认',
        _confirmTorrentDeletion,
        (v) => setState(() => _confirmTorrentDeletion = v),
      ),
      _sw(
        'Torrent 重新校验确认',
        _confirmTorrentRecheck,
        (v) => setState(() => _confirmTorrentRecheck = v),
      ),
      _sw(
        '在状态栏展示外部 IP',
        _statusBarExternalIp,
        (v) => setState(() => _statusBarExternalIp = v),
      ),
      _sw(
        '记录性能警报',
        _performanceWarning,
        (v) => setState(() => _performanceWarning = v),
      ),
      _sec(t, '日志文件'),
      _sw(
        '启用日志文件',
        _fileLogEnabled,
        (v) => setState(() => _fileLogEnabled = v),
      ),
      if (_fileLogEnabled) ...[
        _tf(_fileLogPathCtrl, '保存路径', h: '/config/qBittorrent/logs'),
        _num(_fileLogMaxSizeCtrl, '当大于指定大小时备份日志文件 (KiB)', h: '65'),
        _sw(
          '删除旧的备份日志',
          _fileLogDeleteOld,
          (v) => setState(() => _fileLogDeleteOld = v),
        ),
        if (_fileLogDeleteOld) ...[
          _num(_fileLogAgeCtrl, '删除早于指定时间的备份', h: '1'),
          _sel(
            '时间单位',
            _fileLogAgeType == 0
                ? '天'
                : _fileLogAgeType == 1
                ? '月'
                : '年',
            ['天', '月', '年'],
            (v) => setState(
              () => _fileLogAgeType = v == '天'
                  ? 0
                  : v == '年'
                  ? 2
                  : 1,
            ),
          ),
        ],
        _sw(
          '启用日志文件备份',
          _fileLogBackupEnabled,
          (v) => setState(() => _fileLogBackupEnabled = v),
        ),
      ],
    ],
  );

  // ━━━━━━━━━━━━━ 下载 ━━━━━━━━━━━━━
  Widget _downloadContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, '添加 Torrent 时'),
      _sel(
        'Torrent 内容布局',
        _torrentContentLayout,
        ['Original', 'Subfolder', 'NoSubfolder'],
        (v) =>
            setState(() => _torrentContentLayout = v ?? _torrentContentLayout),
      ),
      _sw(
        '添加到队列顶部',
        _addToTopOfQueue,
        (v) => setState(() => _addToTopOfQueue = v),
      ),
      _sw(
        '不要自动开始下载',
        _addStoppedEnabled,
        (v) => setState(() => _addStoppedEnabled = v),
      ),
      _sel(
        'Torrent 停止条件',
        _torrentStopCondition,
        ['None', 'MetadataReceived', 'FilesChecked'],
        (v) =>
            setState(() => _torrentStopCondition = v ?? _torrentStopCondition),
      ),
      _sec(t, '当添加重复的 Torrent 时'),
      _sw(
        '合并 tracker 到现有 torrent',
        _mergeTrackers,
        (v) => setState(() => _mergeTrackers = v),
      ),
      _sw(
        '为所有文件预分配磁盘空间',
        _preallocateAll,
        (v) => setState(() => _preallocateAll = v),
      ),
      _sw(
        '为不完整的文件添加扩展名 .!qB',
        _incompleteFilesExt,
        (v) => setState(() => _incompleteFilesExt = v),
      ),
      _sw(
        '将未选中的文件保留在 .unwanted 文件夹中',
        _useUnwantedFolder,
        (v) => setState(() => _useUnwantedFolder = v),
      ),
      _sec(t, '保存管理'),
      _sel(
        '默认 Torrent 管理模式',
        _autoTmmEnabled ? '自动' : '手动',
        ['自动', '手动'],
        (v) => setState(() => _autoTmmEnabled = v == '自动'),
      ),
      _sel(
        '当 Torrent 分类修改时',
        _categoryChangedTmmEnabled ? '重新定位 Torrent' : '不操作',
        ['重新定位 Torrent', '不操作'],
        (v) => setState(() => _categoryChangedTmmEnabled = v == '重新定位 Torrent'),
      ),
      _sel(
        '当默认保存路径修改时',
        _savePathChangedTmmEnabled ? '重新定位受影响的 Torrent' : '不操作',
        ['重新定位受影响的 Torrent', '不操作'],
        (v) => setState(
          () => _savePathChangedTmmEnabled = v == '重新定位受影响的 Torrent',
        ),
      ),
      _sel(
        '当分类保存路径修改时',
        _torrentChangedTmmEnabled ? '重新定位受影响的 Torrent' : '不操作',
        ['重新定位受影响的 Torrent', '不操作'],
        (v) =>
            setState(() => _torrentChangedTmmEnabled = v == '重新定位受影响的 Torrent'),
      ),
      _sw(
        '启用子分类',
        _useSubcategories,
        (v) => setState(() => _useSubcategories = v),
      ),
      _sw(
        '在手动模式下使用分类路径',
        _useCategoryPathsInManualMode,
        (v) => setState(() => _useCategoryPathsInManualMode = v),
      ),
      const SizedBox(height: 8),
      _tf(_savePathCtrl, '默认保存路径', h: '/downloads'),
      _sw(
        '保存未完成的 torrent 到',
        _tempPathEnabled,
        (v) => setState(() => _tempPathEnabled = v),
      ),
      if (_tempPathEnabled)
        _tf(_tempPathCtrl, '临时路径', h: '/downloads/incomplete'),
      _tf(_exportDirCtrl, '复制 .torrent 文件到'),
      _tf(_exportDirFinCtrl, '复制下载完成的 .torrent 文件到'),
      _sec(t, '排除文件名'),
      _sw(
        '启用排除文件名',
        _excludedFileNamesEnabled,
        (v) => setState(() => _excludedFileNamesEnabled = v),
      ),
      if (_excludedFileNamesEnabled)
        _tf(_excludedFileNamesCtrl, '排除的文件名模式', h: '每行一个'),
      _sec(t, '邮件通知'),
      _sw(
        '下载完成时发送电子邮件通知',
        _mailNotificationEnabled,
        (v) => setState(() => _mailNotificationEnabled = v),
      ),
      if (_mailNotificationEnabled) ...[
        _tf(_mailNotificationEmailCtrl, '收件人'),
        _tf(_mailNotificationSmtpCtrl, 'SMTP 服务器'),
        _sw(
          '该服务器需要安全链接 (SSL)',
          _mailNotificationSslEnabled,
          (v) => setState(() => _mailNotificationSslEnabled = v),
        ),
        _tf(_mailNotificationUsernameCtrl, '用户名'),
        _tf(_mailNotificationPasswordCtrl, '密码'),
      ],
      _sec(t, '运行外部程序'),
      _sw(
        '新增 Torrent 时运行',
        _autorunOnTorrentAddedEnabled,
        (v) => setState(() => _autorunOnTorrentAddedEnabled = v),
      ),
      if (_autorunOnTorrentAddedEnabled)
        _tf(_autorunOnTorrentAddedProgramCtrl, '程序路径'),
      _sw(
        'Torrent 完成时运行',
        _autorunEnabled,
        (v) => setState(() => _autorunEnabled = v),
      ),
      if (_autorunEnabled) _tf(_autorunProgramCtrl, '程序路径'),
      _sec(t, '支持的参数 (区分大小写)'),
      _note(
        t,
        '%N: Torrent 名称  %L: 分类  %G: 标签\n%F: 内容路径  %R: 根目录  %D: 保存路径\n%C: 文件数  %Z: Torrent 大小 (字节)\n%T: 当前 tracker  %I: 信息哈希值 v1\n%J: 信息哈希值 v2  %K: Torrent ID\n提示: 使用引号将参数扩起以防止文本被空白符分割',
      ),
    ],
  );

  // ━━━━━━━━━━━━━ 连接 ━━━━━━━━━━━━━
  Widget _connectionContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, '监听端口'),
      _num(_listenPortCtrl, '传入连接端口', h: '45923'),
      _sw('使用 UPnP / NAT-PMP 转发端口', _upnp, (v) => setState(() => _upnp = v)),
      _sw('使用随机端口', _randomPort, (v) => setState(() => _randomPort = v)),
      _sec(t, '连接限制'),
      _row(
        _num(_maxConnecCtrl, '全局最大连接数', h: '500'),
        _num(_maxConnecPerTorrentCtrl, '每 Torrent 最大连接', h: '100'),
      ),
      _row(
        _num(_maxUploadsCtrl, '全局最大上传数', h: '20'),
        _num(_maxUploadsPerTorrentCtrl, '每 Torrent 最大上传', h: '10'),
      ),
      _sec(t, '传出端口'),
      _row(
        _num(_outgoingPortsMinCtrl, '下限 [0: 禁用]', h: '0'),
        _num(_outgoingPortsMaxCtrl, '上限 [0: 禁用]', h: '0'),
      ),
      _sec(t, '代理服务器'),
      _sel('类型', _proxyType, [
        'None',
        'SOCKS4',
        'SOCKS5',
        'HTTP',
      ], (v) => setState(() => _proxyType = v ?? _proxyType)),
      if (_proxyType != 'None') ...[
        _tf(_proxyIpCtrl, 'IP 地址', h: '127.0.0.1'),
        _num(_proxyPortCtrl, '端口', h: '8080'),
        _sw(
          '认证',
          _proxyAuthEnabled,
          (v) => setState(() => _proxyAuthEnabled = v),
        ),
        if (_proxyAuthEnabled) ...[
          _tf(_proxyUsernameCtrl, '用户名'),
          _tf(_proxyPasswordCtrl, '密码'),
        ],
        _sw(
          '对 Peer 连接使用代理',
          _proxyPeerConnections,
          (v) => setState(() => _proxyPeerConnections = v),
        ),
        _sw(
          '使用代理进行主机名查询',
          _proxyHostnameLookup,
          (v) => setState(() => _proxyHostnameLookup = v),
        ),
        _sw(
          '对 BitTorrent 使用代理',
          _proxyBittorrent,
          (v) => setState(() => _proxyBittorrent = v),
        ),
        _sw('对 RSS 使用代理', _proxyRss, (v) => setState(() => _proxyRss = v)),
        _sw('对其他请求使用代理', _proxyMisc, (v) => setState(() => _proxyMisc = v)),
      ],
    ],
  );

  // ━━━━━━━━━━━━━ 速度 ━━━━━━━━━━━━━
  Widget _speedContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, '全局速度限制'),
      _row(_num(_upLimitCtrl, '上传 (KiB/s)'), _num(_dlLimitCtrl, '下载 (KiB/s)')),
      _note(t, '0 为无限制'),
      _sec(t, '备用速度限制'),
      _row(
        _num(_altUpLimitCtrl, '上传 (KiB/s)'),
        _num(_altDlLimitCtrl, '下载 (KiB/s)'),
      ),
      _note(t, '0 为无限制'),
      _sec(t, '计划备用速度限制的启用时间'),
      _row(
        _num(_scheduleFromHourCtrl, '从 (时)', h: '08'),
        _num(_scheduleFromMinCtrl, '从 (分)', h: '00'),
      ),
      _row(
        _num(_scheduleToHourCtrl, '到 (时)', h: '20'),
        _num(_scheduleToMinCtrl, '到 (分)', h: '00'),
      ),
      _sel(
        '时间',
        _schedulerDays == 0 ? '每天' : '自定义',
        ['每天', '工作日', '周末'],
        (v) => setState(
          () => _schedulerDays = v == '工作日'
              ? 62
              : v == '周末'
              ? 65
              : 0,
        ),
      ),
      _sw(
        '启用计划',
        _schedulerEnabled,
        (v) => setState(() => _schedulerEnabled = v),
      ),
      _sec(t, '设置速度限制'),
      _sw(
        '对 µTP 协议进行速度限制',
        _limitUtpRate,
        (v) => setState(() => _limitUtpRate = v),
      ),
      _sw(
        '对传送总开销进行速度限制',
        _limitTcpOverhead,
        (v) => setState(() => _limitTcpOverhead = v),
      ),
      _sw(
        '对本地网络用户进行速度限制',
        _limitLanPeers,
        (v) => setState(() => _limitLanPeers = v),
      ),
    ],
  );

  // ━━━━━━━━━━━━━ BitTorrent ━━━━━━━━━━━━━
  Widget _btContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, '隐私'),
      _sw('启用 DHT (去中心化网络) 以找到更多用户', _dht, (v) => setState(() => _dht = v)),
      _sw('启用用户交换 (PeX) 以找到更多用户', _pex, (v) => setState(() => _pex = v)),
      _sw('启用本地用户发现以找到更多用户', _lsd, (v) => setState(() => _lsd = v)),
      _sel(
        '加密模式',
        ['允许加密', '强制加密', '禁用加密'][_encryption],
        ['允许加密', '强制加密', '禁用加密'],
        (v) => setState(
          () => _encryption = v == '强制加密'
              ? 1
              : v == '禁用加密'
              ? 2
              : 0,
        ),
      ),
      _sw('启用匿名模式', _anonymousMode, (v) => setState(() => _anonymousMode = v)),
      const SizedBox(height: 8),
      _num(
        TextEditingController(text: _maxActiveCheckingTorrents.toString()),
        '最大活跃检查 Torrent 数',
      ),
      _sec(t, 'Torrent 排队'),
      _sw(
        '启用队列管理',
        _queueingEnabled,
        (v) => setState(() => _queueingEnabled = v),
      ),
      _num(_maxActiveDownloadsCtrl, '最大活动的下载数', h: '3'),
      _num(_maxActiveUploadsCtrl, '最大活动的上传数', h: '3'),
      _num(_maxActiveTorrentsCtrl, '最大活动的 torrent 数', h: '5'),
      _sec(t, '慢速 torrent 不计入限制内'),
      _row(
        _num(_slowTorrentDlRateThresholdCtrl, '下载速度阈值 (KiB/s)', h: '2'),
        _num(_slowTorrentUlRateThresholdCtrl, '上传速度阈值 (KiB/s)', h: '2'),
      ),
      _num(_slowTorrentInactiveTimerCtrl, 'Torrent 非活动计时器 (秒)', h: '60'),
      _sec(t, '做种限制'),
      _sw(
        '当分享率达到',
        _maxRatioEnabled,
        (v) => setState(() => _maxRatioEnabled = v),
      ),
      if (_maxRatioEnabled)
        _tf(
          _maxRatioCtrl,
          '分享率',
          h: '1',
          k: const TextInputType.numberWithOptions(decimal: true),
        ),
      _sw(
        '达到总做种时间时',
        _maxSeedingTimeEnabled,
        (v) => setState(() => _maxSeedingTimeEnabled = v),
      ),
      if (_maxSeedingTimeEnabled)
        _num(_maxSeedingTimeCtrl, '做种时间 (分钟)', h: '1440'),
      _sw(
        '达到不活跃做种时间时',
        _maxInactiveSeedingTimeEnabled,
        (v) => setState(() => _maxInactiveSeedingTimeEnabled = v),
      ),
      if (_maxInactiveSeedingTimeEnabled)
        _num(_maxInactiveSeedingTimeCtrl, '不活跃做种时间 (分钟)', h: '1440'),
      _sel(
        '然后',
        _maxRatioAct == 0 ? '停止 torrent' : '删除 torrent',
        ['停止 torrent', '删除 torrent'],
        (v) => setState(() => _maxRatioAct = v == '删除 torrent' ? 1 : 0),
      ),
      _sec(t, '自动附加这些 tracker 到新下载'),
      _sw(
        '启用',
        _addTrackersEnabled,
        (v) => setState(() => _addTrackersEnabled = v),
      ),
      if (_addTrackersEnabled) _tf(_addTrackersCtrl, 'Tracker 列表', h: '每行一个'),
      _sec(t, '自动附加 URL 的 trackers 到新的下载'),
      _sw(
        '启用',
        _addTrackersFromUrlEnabled,
        (v) => setState(() => _addTrackersFromUrlEnabled = v),
      ),
      if (_addTrackersFromUrlEnabled) _tf(_addTrackersUrlCtrl, 'Tracker URL'),
      _sec(t, '获取 tracker'),
      _sw(
        '启用内置 Tracker',
        _enableEmbeddedTracker,
        (v) => setState(() => _enableEmbeddedTracker = v),
      ),
      if (_enableEmbeddedTracker) ...[
        _num(_embeddedTrackerPortCtrl, '内置 tracker 端口', h: '9000'),
        _sw(
          '对嵌入的 tracker 启用端口转发',
          _embeddedTrackerPortForwarding,
          (v) => setState(() => _embeddedTrackerPortForwarding = v),
        ),
      ],
    ],
  );

  // ━━━━━━━━━━━━━ RSS ━━━━━━━━━━━━━
  Widget _rssContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, 'RSS 阅读器'),
      _sw(
        '启用获取 RSS 订阅',
        _rssProcessingEnabled,
        (v) => setState(() => _rssProcessingEnabled = v),
      ),
      if (_rssProcessingEnabled) ...[
        _num(_rssRefreshIntervalCtrl, 'RSS 订阅源更新间隔 (分钟)', h: '30'),
        _num(_rssFetchDelayCtrl, '相同的主机请求延迟 (秒)', h: '2'),
        _num(_rssMaxArticlesPerFeedCtrl, '每个订阅源文章数目最大值', h: '50'),
      ],
      _sec(t, 'RSS Torrent 自动下载器'),
      _sw(
        '启用 RSS Torrent 自动下载',
        _rssAutoDownloadingEnabled,
        (v) => setState(() => _rssAutoDownloadingEnabled = v),
      ),
      _sec(t, 'RSS 智能剧集过滤器'),
      _sw(
        '下载 REPACK / PROPER 版剧集',
        _rssDownloadRepackProperEpisodes,
        (v) => setState(() => _rssDownloadRepackProperEpisodes = v),
      ),
      _tf(_rssSmartEpisodeFiltersCtrl, '过滤器', h: '每行一个正则'),
    ],
  );

  // ━━━━━━━━━━━━━ WebUI ━━━━━━━━━━━━━
  Widget _webUiContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, 'Web 用户界面 (远程控制)'),
      _tf(_webUiAddressCtrl, 'IP 地址', h: '*'),
      _num(_webUiPortCtrl, '端口', h: '8999'),
      _sw(
        '使用 UPnP / NAT-PMP 功能来转发端口',
        _webUiUpnp,
        (v) => setState(() => _webUiUpnp = v),
      ),
      _sec(t, 'HTTPS'),
      _sw('使用 HTTPS 而不是 HTTP', _useHttps, (v) => setState(() => _useHttps = v)),
      if (_useHttps) ...[
        _tf(_webUiHttpsCertPathCtrl, '证书路径'),
        _tf(_webUiHttpsKeyPathCtrl, '密钥路径'),
      ],
      _sec(t, '认证'),
      _tf(_webUiUsernameCtrl, '用户名'),
      _tf(_webUiPasswordCtrl, '密码'),
      _sw(
        '对本地主机上的客户端跳过身份验证',
        _bypassLocalAuth,
        (v) => setState(() => _bypassLocalAuth = v),
      ),
      _sw(
        '对 IP 子网白名单中的客户端跳过身份验证',
        _bypassAuthSubnetWhitelistEnabled,
        (v) => setState(() => _bypassAuthSubnetWhitelistEnabled = v),
      ),
      if (_bypassAuthSubnetWhitelistEnabled)
        _tf(_bypassAuthSubnetWhitelistCtrl, '子网白名单', h: '每行一个'),
      _row(
        _num(_webUiMaxAuthFailCountCtrl, '连续失败后禁止客户端', h: '5'),
        _num(_webUiBanDurationCtrl, '禁止 (秒)', h: '3600'),
      ),
      _num(_webUiSessionTimeoutCtrl, '会话超时 (秒)', h: '3600'),
      _sec(t, '备选 WebUI'),
      _sw(
        '使用备选 WebUI',
        _alternativeWebuiEnabled,
        (v) => setState(() => _alternativeWebuiEnabled = v),
      ),
      if (_alternativeWebuiEnabled) _tf(_alternativeWebuiPathCtrl, '文件路径'),
      _sec(t, '安全'),
      _sw(
        '启用"点击劫持"保护',
        _webUiClickjackingProtectionEnabled,
        (v) => setState(() => _webUiClickjackingProtectionEnabled = v),
      ),
      _sw(
        '启用跨站请求伪造 (CSRF) 保护',
        _webUiCsrfProtectionEnabled,
        (v) => setState(() => _webUiCsrfProtectionEnabled = v),
      ),
      _sw(
        '启用 cookie 安全标志 (需要 HTTPS 或本地连接)',
        _webUiSecureCookieEnabled,
        (v) => setState(() => _webUiSecureCookieEnabled = v),
      ),
      _sw(
        '启用 Host header 属性验证',
        _webUiHostHeaderValidationEnabled,
        (v) => setState(() => _webUiHostHeaderValidationEnabled = v),
      ),
      if (_webUiHostHeaderValidationEnabled)
        _tf(_webUiDomainListCtrl, '服务器域名', h: '*'),
      _sw(
        '添加自定义 HTTP headers',
        _webUiUseCustomHttpHeadersEnabled,
        (v) => setState(() => _webUiUseCustomHttpHeadersEnabled = v),
      ),
      if (_webUiUseCustomHttpHeadersEnabled)
        _tf(_webUiCustomHttpHeadersCtrl, 'Header: value', h: '每行一个'),
      _sec(t, '反向代理'),
      _sw(
        '启用反向代理支持',
        _webUiReverseProxyEnabled,
        (v) => setState(() => _webUiReverseProxyEnabled = v),
      ),
      if (_webUiReverseProxyEnabled)
        _tf(_webUiReverseProxiesListCtrl, '受信任的代理列表'),
      _sec(t, '动态域名 (DynDNS)'),
      _sw(
        '更新我的动态域名',
        _dyndnsEnabled,
        (v) => setState(() => _dyndnsEnabled = v),
      ),
      if (_dyndnsEnabled) ...[
        _sel(
          '服务商',
          _dyndnsService == 0 ? 'DynDNS' : 'NoIP',
          ['DynDNS', 'NoIP'],
          (v) => setState(() => _dyndnsService = v == 'NoIP' ? 1 : 0),
        ),
        _tf(_dyndnsDomainCtrl, '域名', h: 'changeme.dyndns.org'),
        _tf(_dyndnsUsernameCtrl, '用户名'),
        _tf(_dyndnsPasswordCtrl, '密码'),
      ],
    ],
  );

  // ━━━━━━━━━━━━━ 高级 ━━━━━━━━━━━━━
  Widget _advancedContent(shadcn.ThemeData t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sec(t, 'qBittorrent 相关'),
      _sel(
        '恢复数据存储类型',
        _resumeDataStorageType,
        ['Legacy', 'SQLite'],
        (v) => setState(
          () => _resumeDataStorageType = v ?? _resumeDataStorageType,
        ),
      ),
      _sel(
        'Torrent 内容删除模式',
        _torrentContentRemoveOption,
        ['Delete', 'MoveToTrash'],
        (v) => setState(
          () => _torrentContentRemoveOption = v ?? _torrentContentRemoveOption,
        ),
      ),
      _num(_memoryWorkingSetLimitCtrl, '物理内存 (RAM) 使用限制 (MiB)', h: '4096'),
      _num(_saveResumeDataIntervalCtrl, '保存恢复数据间隔 (分钟)', h: '60'),
      _num(_saveStatisticsIntervalCtrl, '保存统计数据间隔 (分钟)', h: '15'),
      _num(_torrentFileSizeLimitCtrl, '.torrent 文件大小限制 (MiB)', h: '100'),
      _sw(
        '解析用户所在国家',
        _resolvePeerCountries,
        (v) => setState(() => _resolvePeerCountries = v),
      ),
      _sw(
        '当 IP 或端口更改时重新通知所有 trackers',
        _reannounceWhenAddressChanged,
        (v) => setState(() => _reannounceWhenAddressChanged = v),
      ),
      _sw(
        '忽略 SSL 错误',
        _ignoreSslErrors,
        (v) => setState(() => _ignoreSslErrors = v),
      ),
      _tf(_pythonExecutablePathCtrl, 'Python 可执行文件路径', h: '假如为空，自动检测'),
      _tf(_appInstanceNameCtrl, '定制程序实例名'),
      _num(_refreshIntervalCtrl, '刷新间隔 (毫秒)', h: '1500'),
      _sec(t, 'libTorrent 相关'),
      _num(_bdecodeDepthLimitCtrl, 'Bdecode 深度限制', h: '100'),
      _num(_bdecodeTokenLimitCtrl, 'Bdecode 令牌限制', h: '10000000'),
      _num(_asyncIoThreadsCtrl, '异步 I/O 线程数', h: '10'),
      _num(_hashingThreadsCtrl, '散列线程', h: '1'),
      _num(_filePoolSizeCtrl, '文件池大小', h: '100'),
      _num(_checkingMemoryUseCtrl, '校验时内存使用扩增量 (MiB)', h: '32'),
      _num(_diskQueueSizeCtrl, '磁盘队列大小 (KiB)', h: '1024'),
      _sec(t, '磁盘 IO'),
      _sel(
        '磁盘 IO 类型',
        ['默认', 'mmap'][_diskIoType],
        ['默认', 'mmap'],
        (v) => setState(() => _diskIoType = v == 'mmap' ? 1 : 0),
      ),
      _sel(
        '磁盘 IO 读取模式',
        ['禁用 OS 缓存', '启用 OS 缓存'][_diskIoReadMode],
        ['禁用 OS 缓存', '启用 OS 缓存'],
        (v) => setState(() => _diskIoReadMode = v == '启用 OS 缓存' ? 1 : 0),
      ),
      _sel(
        '磁盘 IO 写入模式',
        ['禁用 OS 缓存', '启用 OS 缓存'][_diskIoWriteMode],
        ['禁用 OS 缓存', '启用 OS 缓存'],
        (v) => setState(() => _diskIoWriteMode = v == '启用 OS 缓存' ? 1 : 0),
      ),
      _sw(
        '启用相连文件块下载模式',
        _enableCoalesceReadWrite,
        (v) => setState(() => _enableCoalesceReadWrite = v),
      ),
      _sw(
        '发送分块上传建议',
        _enableUploadSuggestions,
        (v) => setState(() => _enableUploadSuggestions = v),
      ),
      _sec(t, '缓冲区'),
      _row(
        _num(_sendBufferWatermarkCtrl, '发送缓冲上限 (KiB)', h: '500'),
        _num(_sendBufferLowWatermarkCtrl, '发送缓冲下限 (KiB)', h: '10'),
      ),
      _num(_sendBufferWatermarkFactorCtrl, '发送缓冲增长系数 (%)', h: '50'),
      _sec(t, '连接高级'),
      _num(_connectionSpeedCtrl, '每秒传出连接数', h: '30'),
      _row(
        _num(_socketSendBufferSizeCtrl, 'Socket 发送缓存 [0:系统默认] (KiB)'),
        _num(_socketReceiveBufferSizeCtrl, 'Socket 接收缓存 [0:系统默认] (KiB)'),
      ),
      _num(_socketBacklogSizeCtrl, 'Socket backlog 大小', h: '30'),
      _num(_upnpLeaseDurationCtrl, 'UPnP 租期 [0:永久] (秒)', h: '0'),
      _sec(t, 'Peer'),
      _num(_peerTosCtrl, 'ToS 值', h: '4'),
      _sel(
        'µTP - TCP 混合模式策略',
        ['优先使用 TCP', '优先使用 µTP', '仅 TCP'][_utpTcpMixedMode],
        ['优先使用 TCP', '优先使用 µTP', '仅 TCP'],
        (v) => setState(
          () => _utpTcpMixedMode = v == '优先使用 µTP'
              ? 1
              : v == '仅 TCP'
              ? 2
              : 0,
        ),
      ),
      _sw(
        '支持国际化域名 (IDN)',
        _idnSupportEnabled,
        (v) => setState(() => _idnSupportEnabled = v),
      ),
      _sw(
        '允许来自同一 IP 地址的多个连接',
        _enableMultiConnectionsFromSameIp,
        (v) => setState(() => _enableMultiConnectionsFromSameIp = v),
      ),
      _sw(
        '验证 HTTPS tracker 证书',
        _validateHttpsTrackerCertificate,
        (v) => setState(() => _validateHttpsTrackerCertificate = v),
      ),
      _sw(
        '服务器端请求伪造 (SSRF) 攻击缓解',
        _ssrfMitigation,
        (v) => setState(() => _ssrfMitigation = v),
      ),
      _sw(
        '禁止连接到特权端口上的 Peer',
        _blockPeersOnPrivilegedPorts,
        (v) => setState(() => _blockPeersOnPrivilegedPorts = v),
      ),
      _num(_requestQueueSizeCtrl, '单一 peer 的最大未完成请求', h: '500'),
      _sec(t, '上传窗口策略'),
      _sel(
        '策略',
        ['固定窗口数', '反阻塞'][_uploadChokingAlgorithm],
        ['固定窗口数', '反阻塞'],
        (v) => setState(() => _uploadChokingAlgorithm = v == '反阻塞' ? 1 : 0),
      ),
      _sw(
        '总是向同级的所有 Tracker 汇报',
        _announceToAllTrackers,
        (v) => setState(() => _announceToAllTrackers = v),
      ),
      _sw(
        '总是向所有等级的 Tracker 汇报',
        _announceToAllTiers,
        (v) => setState(() => _announceToAllTiers = v),
      ),
      _tf(_announceIpCtrl, 'IP 地址已报告给 Trackers', h: '需要重启'),
      _num(_announcePortCtrl, '报告给 trackers 的端口 [0:监听端口]', h: '0'),
      _num(_maxConcurrentHttpAnnouncesCtrl, '最大并行 HTTP 汇报', h: '50'),
      _num(_stopTrackerTimeoutCtrl, '停止 tracker 超时 [0:禁用] (秒)', h: '2'),
      _sec(t, 'Peer 进出'),
      _row(
        _num(_peerTurnoverCtrl, '断开百分比 (%)', h: '4'),
        _num(_peerTurnoverCutoffCtrl, '阈值百分比 (%)', h: '90'),
      ),
      _num(_peerTurnoverIntervalCtrl, '断开间隔 (秒)', h: '300'),
      _sec(t, 'DHT'),
      _tf(_dhtBootstrapNodesCtrl, 'DHT Bootstrap 节点'),
      _sec(t, 'I2P'),
      _sw('启用 I2P', _i2pEnabled, (v) => setState(() => _i2pEnabled = v)),
      if (_i2pEnabled) ...[
        _row(
          _tf(_i2pAddressCtrl, 'I2P 地址', h: '127.0.0.1'),
          _num(_i2pPortCtrl, 'I2P 端口', h: '7656'),
        ),
        _row(
          _num(_i2pInboundQuantityCtrl, 'I2P 传入量', h: '3'),
          _num(_i2pOutboundQuantityCtrl, 'I2P 传出量', h: '3'),
        ),
        _row(
          _num(_i2pInboundLengthCtrl, 'I2P 传入长度', h: '3'),
          _num(_i2pOutboundLengthCtrl, 'I2P 传出长度', h: '3'),
        ),
        _sw(
          'I2P 混合模式',
          _i2pMixedMode,
          (v) => setState(() => _i2pMixedMode = v),
        ),
      ],
    ],
  );

  // ━━━━━━━━━━━━━ 构建 ━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    final t = shadcn.Theme.of(context);
    return Dialog(
      insetPadding: _isMobile
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * (_isMobile ? 0.95 : 0.9),
          maxWidth: _isMobile ? double.infinity : 640,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      shadcn.LucideIcons.download,
                      size: 14,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${d.name} · Qbittorrent',
                      style: t.typography.small.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(shadcn.LucideIcons.x, size: 16),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: t.colorScheme.border),
            Expanded(
              child: _loading
                  ? const Center(
                      child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            shadcn.LucideIcons.circleAlert,
                            size: 32,
                            color: t.colorScheme.mutedForeground.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _error!,
                            style: t.typography.small.copyWith(
                              color: t.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isMobile
                  ? _buildAccordion(t)
                  : _buildTabs(t),
            ),
            if (!_loading && _error == null)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: t.colorScheme.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: shadcn.Button.outline(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Center(child: Text('取消')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: shadcn.Button.primary(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: shadcn.CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Center(child: Text('保存')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(shadcn.ThemeData t) => LayoutBuilder(
    builder: (context, constraints) {
      final availableHeight = constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : MediaQuery.of(context).size.height * 0.7;
      final bodyHeight = (availableHeight - 76)
          .clamp(120.0, double.infinity)
          .toDouble();

      final pages = [
        _scroll(_behaviorContent(t), bodyHeight),
        _scroll(_downloadContent(t), bodyHeight),
        _scroll(_connectionContent(t), bodyHeight),
        _scroll(_speedContent(t), bodyHeight),
        _scroll(_btContent(t), bodyHeight),
        _scroll(_rssContent(t), bodyHeight),
        _scroll(_webUiContent(t), bodyHeight),
        _scroll(_advancedContent(t), bodyHeight),
      ];

      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: shadcn.Tabs(
                index: _tabIndex,
                onChanged: (i) => setState(() => _tabIndex = i),
                children: [
                  shadcn.TabItem(child: Text('行为')),
                  shadcn.TabItem(child: Text('下载')),
                  shadcn.TabItem(child: Text('连接')),
                  shadcn.TabItem(child: Text('速度')),
                  shadcn.TabItem(child: Text('BitTorrent')),
                  shadcn.TabItem(child: Text('RSS')),
                  shadcn.TabItem(child: Text('WebUI')),
                  shadcn.TabItem(child: Text('高级')),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(index: _tabIndex, children: pages),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildAccordion(shadcn.ThemeData t) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    child: shadcn.Accordion(
      items: [
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 0,
          trigger: const shadcn.AccordionTrigger(child: Text('行为')),
          content: _behaviorContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 1,
          trigger: const shadcn.AccordionTrigger(child: Text('下载')),
          content: _downloadContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 2,
          trigger: const shadcn.AccordionTrigger(child: Text('连接')),
          content: _connectionContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 3,
          trigger: const shadcn.AccordionTrigger(child: Text('速度')),
          content: _speedContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 4,
          trigger: const shadcn.AccordionTrigger(child: Text('BitTorrent')),
          content: _btContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 5,
          trigger: const shadcn.AccordionTrigger(child: Text('RSS')),
          content: _rssContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 6,
          trigger: const shadcn.AccordionTrigger(child: Text('WebUI')),
          content: _webUiContent(t),
        ),
        shadcn.AccordionItem(
          expanded: widget.initialIndex == 7,
          trigger: const shadcn.AccordionTrigger(child: Text('高级')),
          content: _advancedContent(t),
        ),
      ],
    ),
  );

  Widget _scroll(Widget child, double height) => SizedBox(
    height: height,
    child: Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 18),
        physics: const BouncingScrollPhysics(),
        child: child,
      ),
    ),
  );

  // ━━━━━━━━━━━━━ 保存 ━━━━━━━━━━━━━
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await DownloaderService.savePrefs(d.id, _buildSaveData());
      if (mounted) {
        Navigator.of(context).pop();
        Toast.success('设置已保存');
      }
    } catch (e) {
      String msg = "QB 设置保存失败！$e";

      Toast.error(msg);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Map<String, dynamic> _buildSaveData() => {
    'confirm_torrent_deletion': _confirmTorrentDeletion,
    'confirm_torrent_recheck': _confirmTorrentRecheck,
    'file_log_enabled': _fileLogEnabled,
    'file_log_path': _ps(_fileLogPathCtrl),
    'file_log_max_size': _pi(_fileLogMaxSizeCtrl, 65),
    'file_log_backup_enabled': _fileLogBackupEnabled,
    'file_log_delete_old': _fileLogDeleteOld,
    'file_log_age': _pi(_fileLogAgeCtrl, 1),
    'file_log_age_type': _fileLogAgeType,
    'performance_warning': _performanceWarning,
    'status_bar_external_ip': _statusBarExternalIp,
    'torrent_content_layout': _torrentContentLayout,
    'add_to_top_of_queue': _addToTopOfQueue,
    'add_stopped_enabled': _addStoppedEnabled,
    'torrent_stop_condition': _torrentStopCondition,
    'merge_trackers': _mergeTrackers,
    'preallocate_all': _preallocateAll,
    'incomplete_files_ext': _incompleteFilesExt,
    'use_unwanted_folder': _useUnwantedFolder,
    'auto_tmm_enabled': _autoTmmEnabled,
    'category_changed_tmm_enabled': _categoryChangedTmmEnabled,
    'save_path_changed_tmm_enabled': _savePathChangedTmmEnabled,
    'torrent_changed_tmm_enabled': _torrentChangedTmmEnabled,
    'use_subcategories': _useSubcategories,
    'use_category_paths_in_manual_mode': _useCategoryPathsInManualMode,
    'save_path': _ps(_savePathCtrl),
    'temp_path_enabled': _tempPathEnabled,
    'temp_path': _ps(_tempPathCtrl),
    'export_dir': _ps(_exportDirCtrl),
    'export_dir_fin': _ps(_exportDirFinCtrl),
    'excluded_file_names_enabled': _excludedFileNamesEnabled,
    'excluded_file_names': _ps(_excludedFileNamesCtrl),
    'mail_notification_enabled': _mailNotificationEnabled,
    'mail_notification_email': _ps(_mailNotificationEmailCtrl),
    'mail_notification_smtp': _ps(_mailNotificationSmtpCtrl),
    'mail_notification_ssl_enabled': _mailNotificationSslEnabled,
    'mail_notification_username': _ps(_mailNotificationUsernameCtrl),
    'mail_notification_password': _ps(_mailNotificationPasswordCtrl),
    'autorun_enabled': _autorunEnabled,
    'autorun_program': _ps(_autorunProgramCtrl),
    'autorun_on_torrent_added_enabled': _autorunOnTorrentAddedEnabled,
    'autorun_on_torrent_added_program': _ps(_autorunOnTorrentAddedProgramCtrl),
    'listen_port': _pi(_listenPortCtrl, 6881),
    'upnp': _upnp,
    'random_port': _randomPort,
    'max_connec': _pi(_maxConnecCtrl, 500),
    'max_connec_per_torrent': _pi(_maxConnecPerTorrentCtrl, 100),
    'max_uploads': _pi(_maxUploadsCtrl, 20),
    'max_uploads_per_torrent': _pi(_maxUploadsPerTorrentCtrl, 10),
    'outgoing_ports_min': _pi(_outgoingPortsMinCtrl, 0),
    'outgoing_ports_max': _pi(_outgoingPortsMaxCtrl, 0),
    'proxy_type': _proxyType,
    'proxy_ip': _ps(_proxyIpCtrl),
    'proxy_port': _pi(_proxyPortCtrl, 8080),
    'proxy_auth_enabled': _proxyAuthEnabled,
    'proxy_username': _ps(_proxyUsernameCtrl),
    'proxy_password': _ps(_proxyPasswordCtrl),
    'proxy_peer_connections': _proxyPeerConnections,
    'proxy_hostname_lookup': _proxyHostnameLookup,
    'proxy_bittorrent': _proxyBittorrent,
    'proxy_rss': _proxyRss,
    'proxy_misc': _proxyMisc,
    'dl_limit': _pi(_dlLimitCtrl, 0),
    'up_limit': _pi(_upLimitCtrl, 0),
    'alt_dl_limit': _pi(_altDlLimitCtrl, 0),
    'alt_up_limit': _pi(_altUpLimitCtrl, 0),
    'scheduler_enabled': _schedulerEnabled,
    'schedule_from_hour': _pi(_scheduleFromHourCtrl, 8),
    'schedule_from_min': _pi(_scheduleFromMinCtrl, 0),
    'schedule_to_hour': _pi(_scheduleToHourCtrl, 20),
    'schedule_to_min': _pi(_scheduleToMinCtrl, 0),
    'scheduler_days': _schedulerDays,
    'limit_utp_rate': _limitUtpRate,
    'limit_tcp_overhead': _limitTcpOverhead,
    'limit_lan_peers': _limitLanPeers,
    'dht': _dht,
    'pex': _pex,
    'lsd': _lsd,
    'encryption': _encryption,
    'anonymous_mode': _anonymousMode,
    'queueing_enabled': _queueingEnabled,
    'max_active_downloads': _pi(_maxActiveDownloadsCtrl, 3),
    'max_active_uploads': _pi(_maxActiveUploadsCtrl, 3),
    'max_active_torrents': _pi(_maxActiveTorrentsCtrl, 5),
    'slow_torrent_dl_rate_threshold': _pi(_slowTorrentDlRateThresholdCtrl, 2),
    'slow_torrent_ul_rate_threshold': _pi(_slowTorrentUlRateThresholdCtrl, 2),
    'slow_torrent_inactive_timer': _pi(_slowTorrentInactiveTimerCtrl, 60),
    'max_ratio_enabled': _maxRatioEnabled,
    'max_ratio': _pd(_maxRatioCtrl, -1),
    'max_seeding_time_enabled': _maxSeedingTimeEnabled,
    'max_seeding_time': _pi(_maxSeedingTimeCtrl, -1),
    'max_inactive_seeding_time_enabled': _maxInactiveSeedingTimeEnabled,
    'max_inactive_seeding_time': _pi(_maxInactiveSeedingTimeCtrl, -1),
    'max_ratio_act': _maxRatioAct,
    'add_trackers': _ps(_addTrackersCtrl),
    'add_trackers_enabled': _addTrackersEnabled,
    'add_trackers_url': _ps(_addTrackersUrlCtrl),
    'add_trackers_from_url_enabled': _addTrackersFromUrlEnabled,
    'enable_embedded_tracker': _enableEmbeddedTracker,
    'embedded_tracker_port': _pi(_embeddedTrackerPortCtrl, 9000),
    'embedded_tracker_port_forwarding': _embeddedTrackerPortForwarding,
    'rss_processing_enabled': _rssProcessingEnabled,
    'rss_refresh_interval': _pi(_rssRefreshIntervalCtrl, 30),
    'rss_fetch_delay': _pi(_rssFetchDelayCtrl, 2),
    'rss_max_articles_per_feed': _pi(_rssMaxArticlesPerFeedCtrl, 50),
    'rss_auto_downloading_enabled': _rssAutoDownloadingEnabled,
    'rss_download_repack_proper_episodes': _rssDownloadRepackProperEpisodes,
    'rss_smart_episode_filters': _ps(_rssSmartEpisodeFiltersCtrl),
    'web_ui_address': _ps(_webUiAddressCtrl),
    'web_ui_port': _pi(_webUiPortCtrl, 8080),
    'web_ui_upnp': _webUiUpnp,
    'use_https': _useHttps,
    'web_ui_https_cert_path': _ps(_webUiHttpsCertPathCtrl),
    'web_ui_https_key_path': _ps(_webUiHttpsKeyPathCtrl),
    'web_ui_username': _ps(_webUiUsernameCtrl),
    'bypass_local_auth': _bypassLocalAuth,
    'bypass_auth_subnet_whitelist_enabled': _bypassAuthSubnetWhitelistEnabled,
    'bypass_auth_subnet_whitelist': _ps(_bypassAuthSubnetWhitelistCtrl),
    'web_ui_max_auth_fail_count': _pi(_webUiMaxAuthFailCountCtrl, 5),
    'web_ui_ban_duration': _pi(_webUiBanDurationCtrl, 3600),
    'web_ui_session_timeout': _pi(_webUiSessionTimeoutCtrl, 3600),
    'alternative_webui_enabled': _alternativeWebuiEnabled,
    'alternative_webui_path': _ps(_alternativeWebuiPathCtrl),
    'web_ui_clickjacking_protection_enabled':
        _webUiClickjackingProtectionEnabled,
    'web_ui_csrf_protection_enabled': _webUiCsrfProtectionEnabled,
    'web_ui_secure_cookie_enabled': _webUiSecureCookieEnabled,
    'web_ui_host_header_validation_enabled': _webUiHostHeaderValidationEnabled,
    'web_ui_domain_list': _ps(_webUiDomainListCtrl),
    'web_ui_use_custom_http_headers_enabled': _webUiUseCustomHttpHeadersEnabled,
    'web_ui_custom_http_headers': _ps(_webUiCustomHttpHeadersCtrl),
    'web_ui_reverse_proxy_enabled': _webUiReverseProxyEnabled,
    'web_ui_reverse_proxies_list': _ps(_webUiReverseProxiesListCtrl),
    'dyndns_enabled': _dyndnsEnabled,
    'dyndns_service': _dyndnsService,
    'dyndns_domain': _ps(_dyndnsDomainCtrl),
    'dyndns_username': _ps(_dyndnsUsernameCtrl),
    'dyndns_password': _ps(_dyndnsPasswordCtrl),
    'resume_data_storage_type': _resumeDataStorageType,
    'torrent_content_remove_option': _torrentContentRemoveOption,
    'memory_working_set_limit': _pi(_memoryWorkingSetLimitCtrl, 4096),
    'save_resume_data_interval': _pi(_saveResumeDataIntervalCtrl, 60),
    'save_statistics_interval': _pi(_saveStatisticsIntervalCtrl, 15),
    'torrent_file_size_limit': _pi(_torrentFileSizeLimitCtrl, 104857600),
    'resolve_peer_countries': _resolvePeerCountries,
    'reannounce_when_address_changed': _reannounceWhenAddressChanged,
    'ignore_ssl_errors': _ignoreSslErrors,
    'python_executable_path': _ps(_pythonExecutablePathCtrl),
    'app_instance_name': _ps(_appInstanceNameCtrl),
    'refresh_interval': _pi(_refreshIntervalCtrl, 1500),
    'bdecode_depth_limit': _pi(_bdecodeDepthLimitCtrl, 100),
    'bdecode_token_limit': _pi(_bdecodeTokenLimitCtrl, 10000000),
    'async_io_threads': _pi(_asyncIoThreadsCtrl, 10),
    'hashing_threads': _pi(_hashingThreadsCtrl, 1),
    'file_pool_size': _pi(_filePoolSizeCtrl, 100),
    'checking_memory_use': _pi(_checkingMemoryUseCtrl, 32),
    'disk_queue_size': _pi(_diskQueueSizeCtrl, 1024),
    'disk_io_type': _diskIoType,
    'disk_io_read_mode': _diskIoReadMode,
    'disk_io_write_mode': _diskIoWriteMode,
    'enable_coalesce_read_write': _enableCoalesceReadWrite,
    'enable_upload_suggestions': _enableUploadSuggestions,
    'send_buffer_watermark': _pi(_sendBufferWatermarkCtrl, 500),
    'send_buffer_low_watermark': _pi(_sendBufferLowWatermarkCtrl, 10),
    'send_buffer_watermark_factor': _pi(_sendBufferWatermarkFactorCtrl, 50),
    'connection_speed': _pi(_connectionSpeedCtrl, 30),
    'socket_send_buffer_size': _pi(_socketSendBufferSizeCtrl, 0),
    'socket_receive_buffer_size': _pi(_socketReceiveBufferSizeCtrl, 0),
    'socket_backlog_size': _pi(_socketBacklogSizeCtrl, 30),
    'upnp_lease_duration': _pi(_upnpLeaseDurationCtrl, 0),
    'peer_tos': _pi(_peerTosCtrl, 4),
    'utp_tcp_mixed_mode': _utpTcpMixedMode,
    'idn_support_enabled': _idnSupportEnabled,
    'enable_multi_connections_from_same_ip': _enableMultiConnectionsFromSameIp,
    'validate_https_tracker_certificate': _validateHttpsTrackerCertificate,
    'ssrf_mitigation': _ssrfMitigation,
    'block_peers_on_privileged_ports': _blockPeersOnPrivilegedPorts,
    'upload_choking_algorithm': _uploadChokingAlgorithm,
    'upload_slots_behavior': _uploadSlotsBehavior,
    'announce_to_all_trackers': _announceToAllTrackers,
    'announce_to_all_tiers': _announceToAllTiers,
    'announce_ip': _ps(_announceIpCtrl),
    'announce_port': _pi(_announcePortCtrl, 0),
    'max_concurrent_http_announces': _pi(_maxConcurrentHttpAnnouncesCtrl, 50),
    'stop_tracker_timeout': _pi(_stopTrackerTimeoutCtrl, 2),
    'peer_turnover': _pi(_peerTurnoverCtrl, 4),
    'peer_turnover_cutoff': _pi(_peerTurnoverCutoffCtrl, 90),
    'peer_turnover_interval': _pi(_peerTurnoverIntervalCtrl, 300),
    'request_queue_size': _pi(_requestQueueSizeCtrl, 500),
    'dht_bootstrap_nodes': _ps(_dhtBootstrapNodesCtrl),
    'i2p_enabled': _i2pEnabled,
    'i2p_address': _ps(_i2pAddressCtrl),
    'i2p_port': _pi(_i2pPortCtrl, 7656),
    'i2p_inbound_quantity': _pi(_i2pInboundQuantityCtrl, 3),
    'i2p_outbound_quantity': _pi(_i2pOutboundQuantityCtrl, 3),
    'i2p_inbound_length': _pi(_i2pInboundLengthCtrl, 3),
    'i2p_outbound_length': _pi(_i2pOutboundLengthCtrl, 3),
    'i2p_mixed_mode': _i2pMixedMode,
  };
}
