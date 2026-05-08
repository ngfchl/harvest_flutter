import '../model/torrent_model.dart';

String desktopTorrentEta(Torrent torrent) {
  final remaining = desktopTorrentRemainingBytes(torrent);
  if (remaining <= 0) return '-';
  if (torrent.rateDownload <= 0) return '--';
  return TorrentUtils.formatDuration((remaining / torrent.rateDownload).ceil());
}

int desktopTorrentRemainingBytes(Torrent torrent) {
  if (torrent.leftUntilDone > 0) return torrent.leftUntilDone;
  final total = torrent.sizeWhenDone > 0 ? torrent.sizeWhenDone : torrent.totalSize;
  if (total <= 0) return 0;
  final progress = torrent.percentDone.clamp(0.0, 1.0);
  return (total * (1 - progress)).ceil();
}

String desktopTorrentTime(int timestamp) {
  return timestamp <= 0 ? '-' : TorrentUtils.formatTimeAgo(timestamp);
}

String desktopTorrentSpeedLimit(int bytesPerSecond) {
  return bytesPerSecond <= 0 ? '不限' : TorrentUtils.formatSpeed(bytesPerSecond);
}

String desktopTorrentTracker(Torrent torrent) {
  final visible = torrent.visibleTrackerStats;
  if (visible.isEmpty) {
    return torrent.trackerUrl.isEmpty ? '-' : torrent.trackerUrl;
  }
  final first = visible.first;
  if (first.sitename.isNotEmpty) return first.sitename;
  if (first.host.isNotEmpty) return first.host;
  return first.announce.isEmpty ? '-' : first.announce;
}

Map<String, dynamic> desktopExtractMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

List<dynamic> desktopExtractList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) return value;
  }
  return const [];
}

String desktopPropertyText(Map<String, dynamic> properties, List<String> keys) {
  for (final key in keys) {
    final value = properties[key];
    if (value != null) return '$value';
  }
  return '';
}

String desktopFieldValue(dynamic value) {
  if (value == null) return '-';
  if (value is bool) return value ? '是' : '否';
  if (value is Map || value is List) return '${value.length} 项';
  return '$value';
}
