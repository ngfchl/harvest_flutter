import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';

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
    DesktopTorrentStatusFilter.all => shadcn.LucideIcons.list,
    DesktopTorrentStatusFilter.active => shadcn.LucideIcons.activity,
    DesktopTorrentStatusFilter.downloadingActive => shadcn.LucideIcons.arrowDown,
    DesktopTorrentStatusFilter.uploadingActive => shadcn.LucideIcons.arrowUp,
    DesktopTorrentStatusFilter.waiting => shadcn.LucideIcons.timer,
    DesktopTorrentStatusFilter.downloadWaiting => shadcn.LucideIcons.clock,
    DesktopTorrentStatusFilter.seedWaiting => shadcn.LucideIcons.clock,
    DesktopTorrentStatusFilter.checking => shadcn.LucideIcons.rotateCw,
    DesktopTorrentStatusFilter.checkWaiting => shadcn.LucideIcons.clock,
    DesktopTorrentStatusFilter.paused => shadcn.LucideIcons.pause,
    DesktopTorrentStatusFilter.pausedDownloading => shadcn.LucideIcons.pause,
    DesktopTorrentStatusFilter.pausedCompleted => shadcn.LucideIcons.pause,
    DesktopTorrentStatusFilter.stalledDownloading => shadcn.LucideIcons.circleDashed,
    DesktopTorrentStatusFilter.stalledUploading => shadcn.LucideIcons.circleDashed,
    DesktopTorrentStatusFilter.completed => shadcn.LucideIcons.check,
    DesktopTorrentStatusFilter.error => shadcn.LucideIcons.circleAlert,
  };
}
