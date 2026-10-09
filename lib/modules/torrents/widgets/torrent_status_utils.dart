import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';

String torrentIdentityKey(Torrent torrent) {
  if (torrent.hashString.isNotEmpty) return torrent.hashString;
  if (torrent.id != 0) return 'id:${torrent.id}';
  return 'name:${torrent.name}:${torrent.addedDate}';
}

Map<DesktopTorrentStatusFilter, int> desktopStatusCounts(List<Torrent> torrents) {
  final counts = {for (final filter in DesktopTorrentStatusFilter.values) filter: 0};
  counts[DesktopTorrentStatusFilter.all] = torrents.length;
  for (final torrent in torrents) {
    for (final filter in DesktopTorrentStatusFilter.values) {
      if (filter == DesktopTorrentStatusFilter.all) continue;
      if (matchesDesktopTorrentStatus(torrent, filter)) {
        counts[filter] = (counts[filter] ?? 0) + 1;
      }
    }
  }
  return counts;
}

IconData desktopStatusIcon(DesktopTorrentStatusFilter filter) {
  return switch (filter) {
    DesktopTorrentStatusFilter.all => LucideIcons.list,
    DesktopTorrentStatusFilter.active => LucideIcons.activity,
    DesktopTorrentStatusFilter.downloadingActive => LucideIcons.arrowDown,
    DesktopTorrentStatusFilter.uploadingActive => LucideIcons.arrowUp,
    DesktopTorrentStatusFilter.waiting => LucideIcons.timer,
    DesktopTorrentStatusFilter.downloadWaiting => LucideIcons.clock,
    DesktopTorrentStatusFilter.seedWaiting => LucideIcons.clock,
    DesktopTorrentStatusFilter.checking => LucideIcons.rotateCw,
    DesktopTorrentStatusFilter.checkWaiting => LucideIcons.clock,
    DesktopTorrentStatusFilter.paused => LucideIcons.pause,
    DesktopTorrentStatusFilter.pausedDownloading => LucideIcons.pause,
    DesktopTorrentStatusFilter.pausedCompleted => LucideIcons.pause,
    DesktopTorrentStatusFilter.stalledDownloading => LucideIcons.circleDashed,
    DesktopTorrentStatusFilter.stalledUploading => LucideIcons.circleDashed,
    DesktopTorrentStatusFilter.completed => LucideIcons.check,
    DesktopTorrentStatusFilter.error => LucideIcons.circleAlert,
  };
}
