import 'package:flutter/material.dart';

import '../model/torrent_model.dart';

const colorDownloading = Color(0xFF60A5FA);
const colorSeeding = Color(0xFF4ADE80);
const colorWaiting = Color(0xFFFBBF24);
const colorStopped = Color(0xFF9CA3AF);
const colorError = Color(0xFFEF4444);

Color statusColor(TorrentStatus s, bool hasError) {
  if (hasError) return colorError;
  return switch (s) {
    TorrentStatus.downloading || TorrentStatus.downloadWait => colorDownloading,
    TorrentStatus.seeding || TorrentStatus.seedWait => colorSeeding,
    TorrentStatus.checking || TorrentStatus.checkWait => colorWaiting,
    TorrentStatus.stopped => colorStopped,
  };
}
