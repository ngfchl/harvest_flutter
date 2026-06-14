import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/ui/responsive.dart';
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

  const StatsBar({super.key, required this.downloaderId, this.downloader, this.onOpenSpeedSettings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final items = buildTorrentStatsBarItems(
      context: context,
      ref: ref,
      downloaderId: downloaderId,
      downloader: downloader,
      onOpenSpeedSettings: onOpenSpeedSettings,
    );

    if (items.isEmpty) return const SizedBox.shrink();
    final compactLayout = MediaQuery.sizeOf(context).width < kMobileBreakpoint;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compactLayout ? 10 : 12, vertical: compactLayout ? 6 : 8),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: compactLayout
            ? StatusBarInlineRow(spacing: 7, height: 18, children: items)
            : Wrap(spacing: 14, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: items),
      ),
    );
  }
}

List<Widget> buildTorrentStatsBarItems({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  Downloader? downloader,
  VoidCallback? onOpenSpeedSettings,
}) {
  final cs = shadcn.Theme.of(context).colorScheme;
  final data = ref.watch(torrentListProvider(downloaderId)).value;
  final status = data?.status;
  final speedMap = ref.watch(downloaderSpeedProvider);

  var liveInfo = speedMap['$downloaderId']?.info;
  if (liveInfo == null) {
    final id = downloaderId.toString().toLowerCase();
    final wsKey = downloader?.wsKey.toLowerCase();
    for (final entry in speedMap.entries) {
      final key = entry.key.toLowerCase();
      final dataId = entry.value.downloaderId.toLowerCase();
      if (key == id || dataId == id || (wsKey != null && (key == wsKey || dataId == wsKey))) {
        liveInfo = entry.value.info;
        break;
      }
    }
  }

  if (status == null && liveInfo == null && data == null) return const [];

  final torrents = data?.torrents ?? const <Torrent>[];
  final activeCount = torrents.isEmpty
      ? liveInfo?.activeTorrentCount ?? status?.activeTorrentCount ?? 0
      : torrents.where((t) => t.rateDownload > 0 || t.rateUpload > 0).length;
  final pausedCount = status?.pausedTorrentCount ?? liveInfo?.pausedTorrentCount ?? 0;
  final totalCount = status?.torrentCount ?? liveInfo?.totalTorrentCount ?? torrents.length;
  final sessionUploaded = _firstPositive([liveInfo?.uploadedSession ?? 0, status?.currentStats.uploadedBytes ?? 0]);
  final sessionDownloaded = _firstPositive([
    liveInfo?.downloadedSession ?? 0,
    status?.currentStats.downloadedBytes ?? 0,
  ]);
  final totalUploaded = _firstPositive([status?.cumulativeStats.uploadedBytes ?? 0, _sumUploadedEver(torrents)]);
  final totalDownloaded = _firstPositive([status?.cumulativeStats.downloadedBytes ?? 0, _sumDownloadedEver(torrents)]);
  final uploadLimit = liveInfo?.uploadLimit ?? 0;
  final downloadLimit = liveInfo?.downloadLimit ?? 0;
  final limited = liveInfo?.hasLimit ?? false;

  return [
    StatusBarCount(label: '总数', count: totalCount),
    StatusBarMetric(
      icon: shadcn.LucideIcons.activity,
      label: '活动',
      value: '$activeCount',
      color: const Color(0xFF0D9488),
      tooltip: '活动',
      showLabel: false,
    ),
    StatusBarMetric(
      icon: shadcn.LucideIcons.pause,
      label: '暂停',
      value: '$pausedCount',
      color: cs.mutedForeground,
      tooltip: '暂停',
      showLabel: false,
    ),
    if (limited)
      StatusBarLimitMetric(
        icon: shadcn.LucideIcons.gauge,
        uploadValue: _formatLimitValue(uploadLimit * (downloader?.isQb == true ? 1 : 1000)),
        downloadValue: _formatLimitValue(downloadLimit * (downloader?.isQb == true ? 1 : 1000)),
        tooltip: onOpenSpeedSettings == null ? null : '打开限速设置',
        onTap: onOpenSpeedSettings,
      ),
    StatusBarTrafficGroup(
      uploadValue: _formatTrafficTotal(totalUploaded, sessionUploaded),
      downloadValue: _formatTrafficTotal(totalDownloaded, sessionDownloaded),
    ),
  ];
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

String _formatTrafficTotal(int total, int session) {
  return '${TorrentUtils.formatBytes(total)} (${TorrentUtils.formatBytes(session)})';
}

String _formatLimitValue(int value) => value <= 0 ? '不限' : TorrentUtils.formatSpeed(value);

// ── 子组件 ──

class StatusBarInlineRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double height;
  final AlignmentGeometry alignment;

  const StatusBarInlineRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.height = 18,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: spacing), children[i]],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return SizedBox(
            height: height,
            child: Align(alignment: alignment, child: row),
          );
        }
        return SizedBox(
          width: constraints.maxWidth,
          height: height,
          child: FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: row),
        );
      },
    );
  }
}

class StatusBarMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool showLabel;

  const StatusBarMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.tooltip,
    this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        if (showLabel) Text('$label ', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
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
        : GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);

    if (tooltip != null) {
      return shadcn.Tooltip(tooltip: (_) => Text(tooltip!), child: child);
    }
    return child;
  }
}

class StatusBarLimitMetric extends StatelessWidget {
  final IconData icon;
  final String uploadValue;
  final String downloadValue;
  final String? tooltip;
  final VoidCallback? onTap;

  const StatusBarLimitMetric({
    super.key,
    required this.icon,
    required this.uploadValue,
    required this.downloadValue,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFFD97706)),
        const SizedBox(width: 4),
        Text('限速 ', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
        Text(
          '↑$uploadValue',
          style: const TextStyle(
            fontSize: 11,
            color: colorSeeding,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '↓$downloadValue',
          style: const TextStyle(
            fontSize: 11,
            color: colorDownloading,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );

    final child = onTap == null
        ? content
        : GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);

    if (tooltip != null) {
      return shadcn.Tooltip(tooltip: (_) => Text(tooltip!), child: child);
    }
    return child;
  }
}

class StatusBarTrafficGroup extends StatelessWidget {
  final String uploadValue;
  final String downloadValue;

  const StatusBarTrafficGroup({super.key, required this.uploadValue, required this.downloadValue});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final labelStyle = TextStyle(fontSize: 11, color: cs.mutedForeground, fontWeight: FontWeight.w500);
    const valueStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return shadcn.Tooltip(
      tooltip: (_) => const Text('数据量详情：箭头向上为总上传量（括号内为本次上传），箭头向下为总下载量（括号内为本次下载）'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('数据量', style: labelStyle),
          const SizedBox(width: 8),
          const Icon(shadcn.LucideIcons.arrowUp, size: 12, color: colorSeeding),
          const SizedBox(width: 4),
          Text(uploadValue, style: valueStyle.copyWith(color: colorSeeding)),
          const SizedBox(width: 10),
          const Icon(shadcn.LucideIcons.arrowDown, size: 12, color: colorDownloading),
          const SizedBox(width: 4),
          Text(downloadValue, style: valueStyle.copyWith(color: colorDownloading)),
        ],
      ),
    );
  }
}

class StatusBarCount extends StatelessWidget {
  final String label;
  final int count;

  const StatusBarCount({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
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

class StatusBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final Color? color;
  final bool compact;

  const StatusBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final button = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
        child: Icon(icon, size: 14, color: color ?? cs.mutedForeground.withValues(alpha: onTap == null ? 0.25 : 0.45)),
      ),
    );

    if (tooltip == null) return button;
    return shadcn.Tooltip(tooltip: (_) => Text(tooltip!), child: button);
  }
}

class StatusBarPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final Color? backgroundColor;
  final String? tooltip;

  const StatusBarPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.backgroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final typo = shadcn.Theme.of(context).typography;
    final button = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor ?? color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: typo.xSmall.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 11),
            ),
          ],
        ),
      ),
    );

    if (tooltip == null) return button;
    return shadcn.Tooltip(tooltip: (_) => Text(tooltip!), child: button);
  }
}
