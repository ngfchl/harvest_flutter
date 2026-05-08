import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';
import 'torrent_list_status.dart';

class StatsBar extends ConsumerWidget {
  final int downloaderId;
  final Downloader? downloader;
  final VoidCallback? onOpenSpeedSettings;
  final ValueChanged<bool>? onToggleSpeedMode;

  const StatsBar({
    super.key,
    required this.downloaderId,
    this.downloader,
    this.onOpenSpeedSettings,
    this.onToggleSpeedMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final data = ref.watch(torrentListProvider(downloaderId)).valueOrNull;
    final status = data?.status;
    final speedMap = ref.watch(downloaderSpeedProvider);

    var liveInfo = speedMap['$downloaderId']?.info;
    if (liveInfo == null) {
      final id = downloaderId.toString().toLowerCase();
      final wsKey = downloader?.wsKey.toLowerCase();
      for (final entry in speedMap.entries) {
        final key = entry.key.toLowerCase();
        final dataId = entry.value.downloaderId.toLowerCase();
        if (key == id ||
            dataId == id ||
            (wsKey != null && (key == wsKey || dataId == wsKey))) {
          liveInfo = entry.value.info;
          break;
        }
      }
    }

    if (status == null && liveInfo == null && data == null) {
      return const SizedBox.shrink();
    }

    final torrents = data?.torrents ?? const <Torrent>[];
    final activeCount = torrents.isEmpty
        ? liveInfo?.activeTorrentCount ??
        status?.activeTorrentCount ??
        0
        : torrents
        .where(
          (t) => t.rateDownload > 0 || t.rateUpload > 0,
    )
        .length;
    final pausedCount = status?.pausedTorrentCount ??
        liveInfo?.pausedTorrentCount ??
        0;
    final totalCount = status?.torrentCount ??
        liveInfo?.totalTorrentCount ??
        torrents.length;
    final downloadSpeed =
        liveInfo?.downloadSpeed ?? status?.downloadSpeed ?? 0;
    final uploadSpeed =
        liveInfo?.uploadSpeed ?? status?.uploadSpeed ?? 0;
    final sessionUploaded = _firstPositive([
      liveInfo?.uploadedSession ?? 0,
      status?.currentStats.uploadedBytes ?? 0,
    ]);
    final sessionDownloaded = _firstPositive([
      liveInfo?.downloadedSession ?? 0,
      status?.currentStats.downloadedBytes ?? 0,
    ]);
    final totalUploaded = _firstPositive([
      status?.cumulativeStats.uploadedBytes ?? 0,
      _sumUploadedEver(torrents),
    ]);
    final totalDownloaded = _firstPositive([
      status?.cumulativeStats.downloadedBytes ?? 0,
      _sumDownloadedEver(torrents),
    ]);
    final uploadLimit = liveInfo?.uploadLimit ?? 0;
    final downloadLimit = liveInfo?.downloadLimit ?? 0;
    final limited = liveInfo?.hasLimit ?? false;
    final slowMode = liveInfo?.alternativeSpeedEnabled ?? false;
    final modeText =
        '${slowMode ? '龟速' : '极速'} · ${limited ? '限速' : '不限速'}';
    final freeSpace = liveInfo?.freeSpace ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(
          bottom: BorderSide(color: cs.border, width: 0.5),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusBarMetric(
              icon: shadcn.LucideIcons.arrowDown,
              label: '下载',
              value: TorrentUtils.formatSpeed(downloadSpeed),
              color: colorDownloading,
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.arrowUp,
              label: '上传',
              value: TorrentUtils.formatSpeed(uploadSpeed),
              color: colorSeeding,
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.activity,
              label: '活动',
              value: '$activeCount',
              color: const Color(0xFF0D9488),
            ),
            StatusBarCount(label: '暂停', count: pausedCount),
            StatusBarCount(label: '总数', count: totalCount),
            StatusBarMetric(
              icon: shadcn.LucideIcons.database,
              label: '本次',
              value: _formatTransferPair(
                sessionUploaded,
                sessionDownloaded,
              ),
              color: cs.foreground,
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.hardDrive,
              label: '总计',
              value: _formatTransferPair(
                totalUploaded,
                totalDownloaded,
              ),
              color: cs.foreground,
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.zap,
              label: '模式',
              value: modeText,
              color: limited
                  ? const Color(0xFFD97706)
                  : colorDownloading,
              tooltip: onToggleSpeedMode == null
                  ? null
                  : (slowMode ? '切换为极速模式' : '切换为龟速模式'),
              onTap: onToggleSpeedMode == null
                  ? null
                  : () => onToggleSpeedMode!(!slowMode),
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.gauge,
              label: '限速',
              value: _formatLimitPair(uploadLimit, downloadLimit),
              color: limited
                  ? const Color(0xFFD97706)
                  : cs.mutedForeground,
              tooltip: onOpenSpeedSettings == null
                  ? null
                  : '打开限速设置',
              onTap: onOpenSpeedSettings,
            ),
            StatusBarMetric(
              icon: shadcn.LucideIcons.hardDrive,
              label: '剩余',
              value: freeSpace > 0
                  ? TorrentUtils.formatBytes(freeSpace)
                  : '-',
              color: cs.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 工具函数 ──

int _firstPositive(List<int> values) {
  for (final v in values) {
    if (v > 0) return v;
  }
  return 0;
}

int _sumUploadedEver(List<Torrent> torrents) {
  var sum = 0;
  for (final t in torrents) {
    sum += t.uploadedEver;
  }
  return sum;
}

int _sumDownloadedEver(List<Torrent> torrents) {
  var sum = 0;
  for (final t in torrents) {
    sum += t.downloadedEver;
  }
  return sum;
}

String _formatTransferPair(int up, int down) {
  return '↑${TorrentUtils.formatBytes(up)} ↓${TorrentUtils.formatBytes(down)}';
}

String _formatLimitPair(int upLimit, int downLimit) {
  final up = upLimit <= 0 ? '不限' : TorrentUtils.formatSpeed(upLimit);
  final down =
  downLimit <= 0 ? '不限' : TorrentUtils.formatSpeed(downLimit);
  return '↑$up ↓$down';
}

// ── 子组件 ──

class StatusBarMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? tooltip;
  final VoidCallback? onTap;

  const StatusBarMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: TextStyle(fontSize: 11, color: cs.mutedForeground),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    if (tooltip != null && onTap != null) {
      return shadcn.Tooltip(
        tooltip: (_) => Text(tooltip!),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }
    return content;
  }
}

class StatusBarCount extends StatelessWidget {
  final String label;
  final int count;

  const StatusBarCount({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(fontSize: 11, color: cs.mutedForeground),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 11,
            color: cs.foreground,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
