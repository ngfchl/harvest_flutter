import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/ui/responsive.dart';
import 'package:harvest/core/utils/parsers/size_parser.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/model/downloader_speed.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart'
    as download_providers;
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/download/widgets/downloader_speed_setting.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';
import 'torrent_list_status.dart';
import 'torrent_stats_bar.dart';

class TorrentRefreshBar extends ConsumerWidget {
  final int downloaderId;
  final Downloader? downloader;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshStateChanged;
  final VoidCallback? onOpenSpeedSettings;
  final ValueChanged<bool>? onToggleSpeedMode;
  final bool compact;

  const TorrentRefreshBar({
    super.key,
    required this.downloaderId,
    this.downloader,
    required this.onRefresh,
    required this.onRefreshStateChanged,
    this.onOpenSpeedSettings,
    this.onToggleSpeedMode,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final enabled = ref.watch(speedEnabledProvider);
    final paused = ref.watch(torrentRefreshPausedProvider(downloaderId));
    final remaining = ref.watch(torrentRefreshRemainingProvider(downloaderId));
    final speedMap = ref.watch(downloaderSpeedProvider);
    final prefs = ref
        .watch(download_providers.downloaderPrefsProvider(downloaderId))
        .value;

    final running = enabled && !paused;
    final min = remaining ~/ 60;
    final sec = remaining % 60;
    final countdown = '$min:${sec.toString().padLeft(2, '0')}';
    final liveInfo = _resolveLiveInfo(speedMap);
    final downloadSpeed = liveInfo?.downloadSpeed ?? 0;
    final uploadSpeed = liveInfo?.uploadSpeed ?? 0;
    final freeSpace = _resolveFreeSpace(liveInfo, prefs);
    final slowMode = liveInfo?.alternativeSpeedEnabled ?? false;
    final modeText = slowMode ? '龟速' : '极速';
    final modeColor = slowMode ? const Color(0xFFD97706) : colorDownloading;
    final statusColor = !enabled
        ? cs.mutedForeground.withValues(alpha: 0.45)
        : paused
        ? cs.destructive
        : cs.primary;
    final statusText = running ? countdown : (enabled ? '暂停' : '关闭');
    final compactLayout =
        compact || MediaQuery.sizeOf(context).width < kMobileBreakpoint;
    final statusItems = <Widget>[
      _RefreshStatusMetric(
        icon: running ? shadcn.LucideIcons.radio : shadcn.LucideIcons.pause,
        value: statusText,
        color: statusColor,
        tooltip: running ? '下次刷新倒计时' : statusText,
      ),
      _RefreshStatusMetric(
        icon: shadcn.LucideIcons.zap,
        value: modeText,
        color: modeColor,
        tooltip: onToggleSpeedMode == null
            ? modeText
            : (slowMode ? '切换为极速模式' : '切换为龟速模式'),
        onTap: onToggleSpeedMode == null
            ? null
            : () => onToggleSpeedMode!(!slowMode),
      ),
      StatusBarMetric(
        icon: shadcn.LucideIcons.arrowUp,
        label: '上传',
        value: TorrentUtils.formatSpeed(uploadSpeed),
        color: colorSeeding,
        tooltip: '上传',
        showLabel: false,
      ),
      StatusBarMetric(
        icon: shadcn.LucideIcons.arrowDown,
        label: '下载',
        value: TorrentUtils.formatSpeed(downloadSpeed),
        color: colorDownloading,
        tooltip: '下载',
        showLabel: false,
      ),
      _RefreshStatusMetric(
        icon: shadcn.LucideIcons.hardDrive,
        value: freeSpace > 0 ? TorrentUtils.formatBytes(freeSpace) : '-',
        color: cs.mutedForeground,
        tooltip: '剩余空间',
      ),
      if (onOpenSpeedSettings != null)
        ...buildTorrentStatsBarItems(
          context: context,
          ref: ref,
          downloaderId: downloaderId,
          downloader: downloader,
          onOpenSpeedSettings: onOpenSpeedSettings,
        ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        compactLayout ? 10 : 16,
        8,
        compactLayout ? 8 : 12,
        8,
      ),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: compactLayout
                ? StatusBarInlineRow(
                    spacing: 7,
                    height: 18,
                    children: statusItems,
                  )
                : Wrap(
                    spacing: 14,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: statusItems,
                  ),
          ),
          SizedBox(width: compactLayout ? 6 : 8),
          StatusBarIconButton(
            onTap: onRefresh,
            icon: shadcn.LucideIcons.refreshCw,
            tooltip: '刷新',
            color: cs.mutedForeground,
            compact: compactLayout,
          ),
          StatusBarIconButton(
            onTap: () => showSpeedSettings(context, ref),
            icon: shadcn.LucideIcons.settings,
            tooltip: '刷新设置',
            color: cs.mutedForeground,
            compact: compactLayout,
          ),
          StatusBarIconButton(
            onTap: enabled
                ? () {
                    final nextPaused = !paused;
                    ref
                            .read(
                              torrentRefreshPausedProvider(
                                downloaderId,
                              ).notifier,
                            )
                            .state =
                        nextPaused;
                    ref
                        .read(torrentListProvider(downloaderId).notifier)
                        .setWsPaused(nextPaused);
                    onRefreshStateChanged();
                  }
                : null,
            icon: paused ? shadcn.LucideIcons.play : shadcn.LucideIcons.pause,
            tooltip: paused ? '恢复自动刷新' : '暂停自动刷新',
            color: cs.mutedForeground,
            compact: compactLayout,
          ),
        ],
      ),
    );
  }

  DownloaderInfo? _resolveLiveInfo(Map<String, DownloaderSpeedData> speedMap) {
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
    return liveInfo;
  }

  int _resolveFreeSpace(DownloaderInfo? liveInfo, Map<String, dynamic>? prefs) {
    for (final value in [
      liveInfo?.freeSpace ?? 0,
      _pickFreeSpace(prefs),
      _pickFreeSpace(downloader?.status),
      _pickFreeSpace(downloader?.prefs),
    ]) {
      if (value > 0) return value;
    }
    return 0;
  }

  int _pickFreeSpace(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return 0;
    for (final key in const [
      'free_space_on_disk',
      'freeSpaceOnDisk',
      'free_space',
      'freeSpace',
      'download-dir-free-space',
      'downloadDirFreeSpace',
      'download_dir_free_space',
      'downloadDirFree',
      'downloadDirFreeSpaceBytes',
      'freeSpaceBytes',
      'free_space_bytes',
      'disk_free_space',
      'diskFreeSpace',
      'available_space',
      'availableSpace',
    ]) {
      final value = _safeInt(data[key]);
      if (value > 0) return value;
    }
    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        final nested = _pickFreeSpace(value);
        if (nested > 0) return nested;
      } else if (value is Map) {
        final nested = _pickFreeSpace(Map<String, dynamic>.from(value));
        if (nested > 0) return nested;
      } else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            final nested = _pickFreeSpace(item);
            if (nested > 0) return nested;
          } else if (item is Map) {
            final nested = _pickFreeSpace(Map<String, dynamic>.from(item));
            if (nested > 0) return nested;
          }
        }
      }
    }
    return 0;
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ??
          double.tryParse(value)?.toInt() ??
          parseSizeToBytes(value);
    }
    return 0;
  }
}

class _RefreshStatusMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  const _RefreshStatusMetric({
    required this.icon,
    required this.value,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
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

    final child = onTap == null
        ? content
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: content,
          );

    return shadcn.Tooltip(tooltip: (_) => Text(tooltip), child: child);
  }
}
