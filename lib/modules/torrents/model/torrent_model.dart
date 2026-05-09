import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:harvest/core/utils/utils.dart' as utils;

part 'torrent_model.freezed.dart';
// part 'torrent_model.g.dart';

// ══════════════════════════════════════════════════════
//  Helpers — 安全类型转换 + 多字段兼容
// ══════════════════════════════════════════════════════

int _safeInt(dynamic v) => utils.parseInt(v);

double _safeDouble(dynamic v) => utils.parseDouble(v);

bool _safeBool(dynamic v, [bool def = false]) =>
    utils.parseBool(v, fallback: def);

/// 从 JSON 中按优先级尝试多个 key，返回第一个非 null 值
dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json.containsKey(k) && json[k] != null) return json[k];
  }
  return null;
}

/// 解析 status：Transmission 使用 0-6 数字状态，qBittorrent 使用 state 字符串。
int _parseStatus(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) {
    final state = v.trim();
    final parsed = int.tryParse(state);
    if (parsed != null) return parsed;

    return switch (state) {
      'metaDL' || 'forcedMetaDL' || 'downloading' || 'forcedDL' => 4,
      'queuedDL' || 'stalledDL' => 3,
      'uploading' || 'forcedUP' => 6,
      'queuedUP' || 'stalledUP' => 5,
      'checkingDL' ||
      'checkingUP' ||
      'checkingResumeData' ||
      'allocating' ||
      'moving' => 2,
      'queuedForChecking' || 'checking' => 1,
      'pausedDL' ||
      'pausedUP' ||
      'stoppedDL' ||
      'stoppedUP' ||
      'error' ||
      'missingFiles' ||
      'unknown' => 0,
      _ => 0,
    };
  }
  return 0;
}

int _parseError(Map<String, dynamic> json) {
  final rawError = _safeInt(_pick(json, ['error']));
  if (rawError != 0) return rawError;
  final state = (_pick(json, ['state']) ?? '').toString();
  return switch (state) {
    'error' || 'missingFiles' => 1,
    _ => 0,
  };
}

List<String> _parseLabels(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  if (v is String && v.isNotEmpty) {
    return v
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return [];
}

List<TrackerStat> _parseTrackerStats(dynamic v) {
  if (v is List) {
    return v
        .map((e) => TrackerStat.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

bool _isVirtualTrackerText(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.startsWith('dht') ||
      trimmed.startsWith('pex') ||
      trimmed.startsWith('lsd')) {
    return true;
  }
  final normalized = value.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '',
  );
  return normalized == 'dht' || normalized == 'pex' || normalized == 'lsd';
}

bool _isVirtualTracker(TrackerStat tracker) {
  return _isVirtualTrackerText(tracker.host) ||
      _isVirtualTrackerText(tracker.sitename) ||
      _isVirtualTrackerText(tracker.announce);
}

bool _isSuccessfulTrackerMessage(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized.isEmpty) return true;
  return normalized == 'success' ||
      normalized == 'ok' ||
      normalized == 'working' ||
      normalized.contains('succeeded') ||
      normalized.contains('success') ||
      normalized.contains('成功');
}

// ══════════════════════════════════════════════════════
//  Enums
// ══════════════════════════════════════════════════════

enum TorrentStatus {
  stopped(0, '已停止'),
  checkWait(1, '等待校验'),
  checking(2, '校验中'),
  downloadWait(3, '等待下载'),
  downloading(4, '下载中'),
  seedWait(5, '等待做种'),
  seeding(6, '做种中');

  final int value;
  final String label;

  const TorrentStatus(this.value, this.label);

  static TorrentStatus fromValue(int v) => TorrentStatus.values.firstWhere(
    (s) => s.value == v,
    orElse: () => stopped,
  );
}

enum TorrentFilter {
  all('全部'),
  downloading('下载中'),
  seeding('做种中'),
  waiting('等待中'),
  stopped('已停止'),
  error('错误');

  final String label;

  const TorrentFilter(this.label);
}

enum DesktopTorrentStatusFilter {
  all('全部'),
  active('活动中的'),
  downloadingActive('下载中的'),
  uploadingActive('上传中的'),
  waiting('等待中'),
  downloadWaiting('等待下载'),
  seedWaiting('等待做种'),
  checking('校验中的'),
  checkWaiting('等待校验'),
  paused('暂停的'),
  pausedDownloading('下载中暂停'),
  pausedCompleted('下载完成暂停'),
  stalledDownloading('停滞下载'),
  stalledUploading('停滞上传'),
  completed('已完成'),
  error('错误');

  final String label;

  const DesktopTorrentStatusFilter(this.label);
}

enum TorrentSort {
  queuePosition('队列顺序'),
  name('名称'),
  size('大小'),
  progress('进度'),
  downloadSpeed('下载速度'),
  uploadSpeed('上传速度'),
  ratio('分享率'),
  addedDate('添加时间'),
  activityDate('最后活动');

  final String label;

  const TorrentSort(this.label);
}

// ══════════════════════════════════════════════════════
//  TrackerStat
// ══════════════════════════════════════════════════════

@freezed
abstract class TrackerStat with _$TrackerStat {
  const factory TrackerStat({
    @Default(0) int id,
    @Default('') String host,
    @Default('') String sitename,
    @Default('') String announce,
    @Default(0) int seederCount,
    @Default(0) int leecherCount,
    @Default(0) int downloadCount,
    @Default(false) bool lastAnnounceSucceeded,
    @Default('') String lastAnnounceResult,
    @Default(0) int lastAnnounceTime,
    @Default(0) int nextAnnounceTime,
    @Default(false) bool isBackup,
  }) = _TrackerStat;

  factory TrackerStat.fromJson(Map<String, dynamic> json) {
    return TrackerStat(
      id: _safeInt(_pick(json, ['id'])),
      host: (_pick(json, ['host']) ?? '').toString(),
      sitename: (_pick(json, ['sitename', 'site_name']) ?? '').toString(),
      announce: (_pick(json, ['announce']) ?? '').toString(),
      seederCount: _safeInt(
        _pick(json, ['seederCount', 'seeder_count', 'seeds']),
      ),
      leecherCount: _safeInt(
        _pick(json, ['leecherCount', 'leecher_count', 'leeches']),
      ),
      downloadCount: _safeInt(_pick(json, ['downloadCount', 'download_count'])),
      lastAnnounceSucceeded: _safeBool(_pick(json, ['lastAnnounceSucceeded'])),
      lastAnnounceResult: (_pick(json, ['lastAnnounceResult']) ?? '')
          .toString(),
      lastAnnounceTime: _safeInt(_pick(json, ['lastAnnounceTime'])),
      nextAnnounceTime: _safeInt(_pick(json, ['nextAnnounceTime'])),
      isBackup: _safeBool(_pick(json, ['isBackup'])),
    );
  }
}

// ══════════════════════════════════════════════════════
//  Torrent
// ══════════════════════════════════════════════════════

@freezed
abstract class Torrent with _$Torrent {
  const Torrent._();

  const factory Torrent({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String category,
    @Default('') String hashString,
    @Default(0.0) double percentDone,
    @Default(0.0) double percentComplete,
    @Default(0) int status,
    @Default(0) int rateDownload,
    @Default(0) int rateUpload,
    @Default(0) int sizeWhenDone,
    @Default(0) int totalSize,
    @Default(0) int downloadedEver,
    @Default(0) int uploadedEver,
    @Default(0.0) double uploadRatio,
    @Default(0) int addedDate,
    @Default(0) int activityDate,
    @Default(0) int doneDate,
    @Default(0) int secondsSeeding,
    @Default(0) int secondsDownloading,
    @Default(0) int queuePosition,
    @Default(false) bool isFinished,
    @Default(false) bool isStalled,
    @Default(false) bool downloadLimited,
    @Default(false) bool uploadLimited,
    @Default(false) bool forceStart,
    @Default(false) bool autoTmm,
    @Default(false) bool superSeeding,
    @Default('') String contentPath,
    @Default(0) int downloadLimit,
    @Default(0) int uploadLimit,
    @Default(0.0) double seedRatioLimit,
    @Default(0) int seedRatioMode,
    @Default(0) int leftUntilDone,
    @Default(0) int error,
    @Default('') String errorString,
    @Default('') String downloadDir,
    @Default('') String comment,
    @Default('') String magnetLink,
    @Default('') String torrentFile,
    @Default([]) List<String> labels,
    @Default([]) List<TrackerStat> trackerStats,
    @Default(0) int peersGettingFromUs,
    @Default(0) int peersSendingToUs,
    @Default(0) int bandwidthPriority,
    @Default(0.0) double recheckProgress,
    @Default(0) int startDate,
    @Default('') String trackerUrl,
  }) = _Torrent;

  factory Torrent.fromJson(Map<String, dynamic> json) {
    final rawTrackerStats = _parseTrackerStats(
      _pick(json, ['trackerStats', 'trackers']),
    );
    final trackerUrl = (_pick(json, ['tracker', 'trackerUrl']) ?? '')
        .toString();

    final trackerStats = rawTrackerStats.isNotEmpty
        ? rawTrackerStats
        : _trackerStatsFromUrl(trackerUrl);

    return Torrent(
      id: _safeInt(_pick(json, ['id'])),
      name: (_pick(json, ['name']) ?? '').toString(),
      hashString: (_pick(json, ['hashString', 'hash', 'infohash_v1']) ?? '')
          .toString(),
      percentDone: _safeDouble(
        _pick(json, ['percentDone', 'progress', 'percent_done']),
      ),
      percentComplete: _safeDouble(
        _pick(json, ['percentComplete', 'progress', 'percent_complete']),
      ),
      status: _parseStatus(_pick(json, ['status', 'state'])),
      rateDownload: _safeInt(
        _pick(json, ['rateDownload', 'dlspeed', 'download_speed']),
      ),
      rateUpload: _safeInt(
        _pick(json, ['rateUpload', 'upspeed', 'upload_speed']),
      ),
      sizeWhenDone: _safeInt(
        _pick(json, ['sizeWhenDone', 'size', 'total_size', 'completed']),
      ),
      totalSize: _safeInt(_pick(json, ['totalSize', 'total_size', 'size'])),
      downloadedEver: _safeInt(
        _pick(json, ['downloadedEver', 'downloaded', 'total_downloaded']),
      ),
      uploadedEver: _safeInt(
        _pick(json, ['uploadedEver', 'uploaded', 'total_uploaded']),
      ),
      uploadRatio: _safeDouble(_pick(json, ['uploadRatio', 'ratio'])),
      addedDate: _safeInt(_pick(json, ['addedDate', 'added_on'])),
      activityDate: _safeInt(_pick(json, ['activityDate', 'last_activity'])),
      doneDate: _safeInt(_pick(json, ['doneDate', 'completion_on'])),
      secondsSeeding: _safeInt(_pick(json, ['secondsSeeding', 'seeding_time'])),
      secondsDownloading: _safeInt(
        _pick(json, ['secondsDownloading', 'time_active']),
      ),
      queuePosition: _safeInt(_pick(json, ['queuePosition', 'priority'])),
      isFinished: _safeBool(_pick(json, ['isFinished', 'is_finished'])),
      isStalled: _safeBool(_pick(json, ['isStalled', 'is_stalled'])),
      downloadLimited: _safeBool(
        _pick(json, ['downloadLimited', 'dl_limit_enabled']),
      ),
      uploadLimited: _safeBool(
        _pick(json, ['uploadLimited', 'up_limit_enabled']),
      ),
      downloadLimit: _safeInt(_pick(json, ['downloadLimit', 'dl_limit'])),
      uploadLimit: _safeInt(_pick(json, ['uploadLimit', 'up_limit'])),
      seedRatioLimit: _safeDouble(
        _pick(json, ['seedRatioLimit', 'ratio_limit']),
      ),
      forceStart: _safeBool(_pick(json, ['forceStart', 'force_start'])),
      autoTmm: _safeBool(_pick(json, ['autoTmm', 'auto_tmm'])),
      superSeeding: _safeBool(_pick(json, ['superSeeding', 'super_seeding'])),
      contentPath: (_pick(json, ['contentPath', 'content_path']) ?? '')
          .toString(),
      seedRatioMode: _safeInt(_pick(json, ['seedRatioMode'])),
      leftUntilDone: _safeInt(_pick(json, ['leftUntilDone', 'amount_left'])),
      error: _parseError(json),
      errorString: (_pick(json, ['errorString', 'error_string']) ?? '')
          .toString(),
      downloadDir:
          (_pick(json, ['downloadDir', 'save_path', 'download_path']) ?? '')
              .toString(),
      comment: (_pick(json, ['comment']) ?? '').toString(),
      magnetLink: (_pick(json, ['magnetLink', 'magnet_uri']) ?? '').toString(),
      torrentFile: (_pick(json, ['torrentFile']) ?? '').toString(),
      labels: _parseLabels(_pick(json, ['labels', 'tags'])),
      category: (_pick(json, ['category']) ?? '').toString(),
      trackerStats: trackerStats,
      peersGettingFromUs: _safeInt(
        _pick(json, ['peersGettingFromUs', 'num_seeds']),
      ),
      peersSendingToUs: _safeInt(
        _pick(json, ['peersSendingToUs', 'num_leechs']),
      ),
      bandwidthPriority: _safeInt(
        _pick(json, ['bandwidthPriority', 'priority']),
      ),
      recheckProgress: _safeDouble(
        _pick(json, ['recheckProgress', 'recheck_progress']),
      ),
      startDate: _safeInt(_pick(json, ['startDate', 'added_on'])),
      trackerUrl: trackerUrl,
    );
  }

  static List<TrackerStat> _trackerStatsFromUrl(String url) {
    if (url.isEmpty) return [];
    if (_isVirtualTrackerText(url)) return [];
    try {
      final uri = Uri.parse(url);
      final parts = uri.host.split('.');
      final sitename = parts.length >= 2 ? parts[parts.length - 2] : uri.host;
      return [TrackerStat(sitename: sitename, host: uri.host, announce: url)];
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hashString': hashString,
    'percentDone': percentDone,
    'percentComplete': percentComplete,
    'status': status,
    'rateDownload': rateDownload,
    'rateUpload': rateUpload,
    'sizeWhenDone': sizeWhenDone,
    'totalSize': totalSize,
    'downloadedEver': downloadedEver,
    'uploadedEver': uploadedEver,
    'uploadRatio': uploadRatio,
    'addedDate': addedDate,
    'activityDate': activityDate,
    'doneDate': doneDate,
    'secondsSeeding': secondsSeeding,
    'secondsDownloading': secondsDownloading,
    'queuePosition': queuePosition,
    'isFinished': isFinished,
    'isStalled': isStalled,
    'downloadLimited': downloadLimited,
    'uploadLimited': uploadLimited,
    'downloadLimit': downloadLimit,
    'uploadLimit': uploadLimit,
    'seedRatioLimit': seedRatioLimit,
    'seedRatioMode': seedRatioMode,
    'forceStart': forceStart,
    'autoTmm': autoTmm,
    'superSeeding': superSeeding,
    'contentPath': contentPath,
    'leftUntilDone': leftUntilDone,
    'error': error,
    'errorString': errorString,
    'downloadDir': downloadDir,
    'comment': comment,
    'magnetLink': magnetLink,
    'torrentFile': torrentFile,
    'labels': labels,
    'category': category,
    // 'trackerStats': trackerStats.map((t) => t.toJson()).toList(),
    'peersGettingFromUs': peersGettingFromUs,
    'peersSendingToUs': peersSendingToUs,
    'bandwidthPriority': bandwidthPriority,
    'recheckProgress': recheckProgress,
    'startDate': startDate,
    'trackerUrl': trackerUrl,
  };

  TorrentStatus get torrentStatus => TorrentStatus.fromValue(status);

  bool get hasError => error != 0 || errorString.trim().isNotEmpty;

  String get trackerErrorMessage {
    final seen = <String>{};
    for (final tracker in visibleTrackerStats) {
      final msg = tracker.lastAnnounceResult.trim();
      if (msg.isEmpty) continue;
      if (tracker.lastAnnounceSucceeded) continue;
      if (_isSuccessfulTrackerMessage(msg)) continue;
      if (seen.add(msg)) return msg;
    }
    return '';
  }

  String get effectiveErrorMessage {
    final direct = errorString.trim();
    if (direct.isNotEmpty) return direct;
    final tracker = trackerErrorMessage;
    if (tracker.isNotEmpty) return tracker;
    return hasError ? '未知错误' : '';
  }

  List<TrackerStat> get visibleTrackerStats =>
      trackerStats.where((t) => !_isVirtualTracker(t)).toList();

  String _trackerLabel(TrackerStat tracker) {
    if (tracker.sitename.isNotEmpty) return tracker.sitename;
    if (tracker.host.isNotEmpty) return tracker.host;
    return tracker.announce;
  }

  String _trackerHost(TrackerStat tracker) {
    if (tracker.host.isNotEmpty) return tracker.host;
    if (tracker.announce.isEmpty) return '';
    try {
      final uri = Uri.parse(tracker.announce);
      if (uri.host.isNotEmpty) return uri.host;
    } catch (_) {}
    return tracker.announce;
  }

  String get primaryTracker {
    final trackers = visibleTrackerStats;
    final active = trackers.where((t) => !t.isBackup).toList();
    return active.isNotEmpty
        ? _trackerLabel(active.first)
        : trackers.isNotEmpty
        ? _trackerLabel(trackers.first)
        : '';
  }

  String get primaryTrackerHost {
    final trackers = visibleTrackerStats;
    final active = trackers.where((t) => !t.isBackup).toList();
    return active.isNotEmpty
        ? _trackerHost(active.first)
        : trackers.isNotEmpty
        ? _trackerHost(trackers.first)
        : '';
  }

  int get activeSeeders {
    final active = visibleTrackerStats.where((t) => !t.isBackup).toList();
    return active.isNotEmpty ? active.first.seederCount : 0;
  }

  int get activeLeechers {
    final active = visibleTrackerStats.where((t) => !t.isBackup).toList();
    return active.isNotEmpty ? active.first.leecherCount : 0;
  }
}

// ══════════════════════════════════════════════════════
//  SessionStats
// ══════════════════════════════════════════════════════

@freezed
abstract class SessionStats with _$SessionStats {
  const factory SessionStats({
    @Default(0) int downloadedBytes,
    @Default(0) int uploadedBytes,
    @Default(0) int filesAdded,
    @Default(0) int secondsActive,
    @Default(0) int sessionCount,
  }) = _SessionStats;

  factory SessionStats.fromJson(Map<String, dynamic> json) {
    return SessionStats(
      downloadedBytes: _safeInt(_pick(json, ['downloadedBytes'])),
      uploadedBytes: _safeInt(_pick(json, ['uploadedBytes'])),
      filesAdded: _safeInt(_pick(json, ['filesAdded'])),
      secondsActive: _safeInt(_pick(json, ['secondsActive'])),
      sessionCount: _safeInt(_pick(json, ['sessionCount'])),
    );
  }
}

// ══════════════════════════════════════════════════════
//  DownloaderStatus
// ══════════════════════════════════════════════════════

@freezed
abstract class DownloaderStatus with _$DownloaderStatus {
  const factory DownloaderStatus({
    @Default(0) int activeTorrentCount,
    @Default(0) int pausedTorrentCount,
    @Default(0) int torrentCount,
    @Default(0) int downloadSpeed,
    @Default(0) int uploadSpeed,
    @Default(SessionStats()) SessionStats cumulativeStats,
    @Default(SessionStats()) SessionStats currentStats,
  }) = _DownloaderStatus;

  factory DownloaderStatus.fromJson(Map<String, dynamic> json) {
    return DownloaderStatus(
      activeTorrentCount: _safeInt(_pick(json, ['activeTorrentCount'])),
      pausedTorrentCount: _safeInt(_pick(json, ['pausedTorrentCount'])),
      torrentCount: _safeInt(_pick(json, ['torrentCount'])),
      downloadSpeed: _safeInt(_pick(json, ['downloadSpeed', 'dl_info_speed'])),
      uploadSpeed: _safeInt(_pick(json, ['uploadSpeed', 'up_info_speed'])),
      cumulativeStats: _pick(json, ['cumulative-stats']) is Map<String, dynamic>
          ? SessionStats.fromJson(
              _pick(json, ['cumulative-stats']) as Map<String, dynamic>,
            )
          : const SessionStats(),
      currentStats: _pick(json, ['current-stats']) is Map<String, dynamic>
          ? SessionStats.fromJson(
              _pick(json, ['current-stats']) as Map<String, dynamic>,
            )
          : const SessionStats(),
    );
  }
}

// ══════════════════════════════════════════════════════
//  DownloaderData
// ══════════════════════════════════════════════════════

@freezed
abstract class DownloaderData with _$DownloaderData {
  const factory DownloaderData({
    @Default([]) List<Torrent> torrents,
    DownloaderStatus? status,
  }) = _DownloaderData;

  factory DownloaderData.fromJson(Map<String, dynamic> json) {
    List<Torrent> torrentList = [];
    final raw = json['torrents'];
    if (raw is List) {
      torrentList = raw
          .map((t) => Torrent.fromJson(t as Map<String, dynamic>))
          .toList();
    } else if (raw is Map) {
      torrentList = raw.values
          .map((t) => Torrent.fromJson(t as Map<String, dynamic>))
          .toList();
    }

    DownloaderStatus? status;
    final rawStatus = _pick(json, ['status', 'server_state']);
    if (rawStatus is Map<String, dynamic>) {
      status = DownloaderStatus.fromJson(rawStatus);
    }

    return DownloaderData(torrents: torrentList, status: status);
  }
}

// ══════════════════════════════════════════════════════
//  Utils
// ══════════════════════════════════════════════════════

class TorrentUtils {
  static bool isVirtualTrackerText(String value) =>
      _isVirtualTrackerText(value);

  static String formatBytes(int bytes, [int decimals = 1]) =>
      utils.formatBytes(bytes, decimals: decimals);

  static String formatSpeed(int bps) =>
      bps <= 0 ? '0 B/s' : '${formatBytes(bps)}/s';

  static String formatRatio(double r) => r < 0 ? '-' : r.toStringAsFixed(2);

  static String formatPercent(double v) => '${(v * 100).toStringAsFixed(1)}%';

  static String formatDuration(int sec) {
    if (sec <= 0) return '-';
    final d = sec ~/ 86400;
    final h = (sec % 86400) ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    if (d > 365) return '${(d / 365).floor()}年';
    if (d > 30) return '${(d / 30).floor()}月';
    if (d > 0) return '$d天${h > 0 ? '$h时' : ''}';
    if (h > 0) return '$h时${m > 0 ? '$m分' : ''}';
    if (m > 0) return '$m分';
    return '$sec秒';
  }

  static String formatTimeAgo(int ts) {
    if (ts <= 0) return '-';
    return utils.formatTimeAgo(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
  }
}
