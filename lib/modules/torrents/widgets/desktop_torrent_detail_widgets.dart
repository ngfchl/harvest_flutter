import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import 'desktop_torrent_format_utils.dart';
import 'torrent_category_utils.dart';

// ── 空状态 ──

class DesktopEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;

  const DesktopEmptyState({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: cs.mutedForeground.withValues(alpha: 0.4)),
          const SizedBox(height: 8),
          Text(title).xSmall.muted,
        ],
      ),
    );
  }
}

// ── 通用区段 ──

class DesktopDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const DesktopDetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Card(
      filled: true,
      fillColor: cs.card,
      borderColor: cs.border,
      borderWidth: 0.5,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(title).small.bold.foreground,
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// ── 概览摘要 ──

class DesktopSelectedSummary extends StatelessWidget {
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const DesktopSelectedSummary({
    super.key,
    required this.torrent,
    required this.siteMatch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final errorText = torrent.effectiveErrorMessage.isEmpty
        ? '种子存在错误'
        : torrent.effectiveErrorMessage;
    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderColor: cs.border,
      borderWidth: 0.5,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            torrent.name.isEmpty ? '(无名称)' : torrent.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ).small.bold.foreground,
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              if (siteMatch != null)
                Text(siteMatch!.displayName).xSmall.muted,
              if (torrent.category.isNotEmpty)
                Text(torrent.category).xSmall.muted,
              if (torrent.labels.isNotEmpty)
                Text(torrent.labels.join(', ')).xSmall.muted,
              Text(torrent.torrentStatus.label).xSmall.muted,
            ],
          ),
          if (torrent.hasError) ...[
            const SizedBox(height: 10),
            shadcn.Tooltip(
              tooltip: (_) => Text(errorText).xSmall,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cs.destructive.withValues(alpha: 0.1),
                  border: Border.all(
                    color: cs.destructive.withValues(alpha: 0.35),
                    width: 0.6,
                  ),
                  borderRadius: shadcn.Theme.of(context).borderRadiusSm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      shadcn.LucideIcons.circleAlert,
                      size: 14,
                      color: cs.destructive,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: cs.destructive),
                        child: Text(
                          errorText,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ).xSmall.medium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 指标卡片 ──

class DesktopDetailMetrics extends StatelessWidget {
  final Torrent torrent;
  final Map<String, dynamic> properties;

  const DesktopDetailMetrics({
    super.key,
    required this.torrent,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final torrentSizeText = TorrentUtils.formatBytes(torrent.sizeWhenDone);
    final propertyTotalSize = properties.isEmpty
        ? ''
        : desktopPropertyText(
      properties,
      const ['total_size', 'totalSize', 'total_size_bytes'],
    );

    final items = [
      _metric('大小', torrentSizeText, shadcn.LucideIcons.hardDrive),
      _metric(
        '下载',
        TorrentUtils.formatSpeed(torrent.rateDownload),
        shadcn.LucideIcons.arrowDown,
      ),
      _metric(
        '上传',
        TorrentUtils.formatSpeed(torrent.rateUpload),
        shadcn.LucideIcons.arrowUp,
      ),
      _metric(
        '分享率',
        TorrentUtils.formatRatio(torrent.uploadRatio),
        shadcn.LucideIcons.chartPie,
      ),
      _metric(
        '分类',
        torrentCategoryLabel(torrent).isEmpty
            ? '未分类'
            : torrentCategoryLabel(torrent),
        shadcn.LucideIcons.folder,
      ),
      _metric(
        '标签',
        torrent.labels.isEmpty ? '无' : torrent.labels.join(', '),
        shadcn.LucideIcons.tags,
      ),
      _metric(
        '保存路径',
        torrent.downloadDir.isEmpty ? '-' : torrent.downloadDir,
        shadcn.LucideIcons.folderOpen,
      ),
      _metric(
        '内容路径',
        torrent.contentPath.isEmpty ? '-' : torrent.contentPath,
        shadcn.LucideIcons.file,
      ),
      _metric(
        '添加时间',
        TorrentUtils.formatTimeAgo(torrent.addedDate),
        shadcn.LucideIcons.calendarPlus,
      ),
      _metric(
        '活动时间',
        TorrentUtils.formatTimeAgo(torrent.activityDate),
        shadcn.LucideIcons.clock,
      ),
      if (propertyTotalSize.isNotEmpty &&
          propertyTotalSize != '-' &&
          propertyTotalSize != torrentSizeText)
        _metric('总大小', propertyTotalSize, shadcn.LucideIcons.database),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items,
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return _DesktopDetailMetric(label, value, icon);
  }
}

class _DesktopDetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DesktopDetailMetric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: 146,
      child: shadcn.Card(
        filled: true,
        fillColor: cs.background,
        borderColor: cs.border,
        borderWidth: 0.5,
        borderRadius: shadcn.Theme.of(context).borderRadiusSm,
        padding: const EdgeInsets.all(9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: cs.mutedForeground),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).xSmall.muted,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).xSmall.bold.foreground,
          ],
        ),
      ),
    );
  }
}

// ── 字段表 ──

class DesktopFieldTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const DesktopFieldTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort(
            (a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()),
      );
    if (entries.isEmpty) return const DesktopMutedLine('暂无字段');
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _DesktopFieldRow(
            name: entries[i].key,
            value: desktopFieldValue(entries[i].value),
          ),
          if (i != entries.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DesktopFieldRow extends StatelessWidget {
  final String name;
  final String value;

  const _DesktopFieldRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).xSmall.muted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ).xSmall.foreground,
        ),
      ],
    );
  }
}

// ── 静默提示行 ──

class DesktopMutedLine extends StatelessWidget {
  final String text;

  const DesktopMutedLine(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text).xSmall.muted,
    );
  }
}

// ── Tracker 列表 ──

class DesktopTrackerList extends StatelessWidget {
  final Torrent torrent;
  final List<dynamic> trackers;

  const DesktopTrackerList({
    super.key,
    required this.torrent,
    required this.trackers,
  });

  @override
  Widget build(BuildContext context) {
    if (trackers.isEmpty) {
      return const DesktopMutedLine('暂无 Tracker 信息');
    }
    return Column(
      children: [
        for (var i = 0; i < trackers.length; i++) ...[
          _DesktopTrackerRow(tracker: trackers[i]),
          if (i != trackers.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DesktopTrackerRow extends StatelessWidget {
  final dynamic tracker;

  const _DesktopTrackerRow({required this.tracker});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final map = tracker is Map
        ? Map<String, dynamic>.from(tracker)
        : <String, dynamic>{};
    final sitename = '${map['sitename'] ?? map['siteName'] ?? ''}';
    final host = '${map['host'] ?? ''}';
    final announce = '${map['announce'] ?? ''}';
    final label = sitename.isNotEmpty
        ? sitename
        : host.isNotEmpty
        ? host
        : announce;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: shadcn.Theme.of(context).borderRadiusSm,
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.isEmpty ? '(未知)' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).xSmall.bold.foreground,
          if (announce.isNotEmpty && announce != label) ...[
            const SizedBox(height: 2),
            Text(announce, maxLines: 1, overflow: TextOverflow.ellipsis)
                .xSmall
                .muted,
          ],
        ],
      ),
    );
  }
}

// ── 文件列表 ──

class DesktopFileList extends StatelessWidget {
  final List<dynamic> files;

  const DesktopFileList({super.key, required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const DesktopMutedLine('暂无文件信息');
    return Column(
      children: [
        for (var i = 0; i < files.length; i++) ...[
          _DesktopFileRow(file: files[i]),
          if (i != files.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _DesktopFileRow extends StatelessWidget {
  final dynamic file;

  const _DesktopFileRow({required this.file});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final map = file is Map
        ? Map<String, dynamic>.from(file)
        : <String, dynamic>{};
    final name = '${map['name'] ?? ''}';
    final length = map['length'] ?? map['size'] ?? 0;
    final bytesCompleted = map['bytesCompleted'] ?? 0;
    final total = length is int ? length : int.tryParse('$length') ?? 0;
    final done = bytesCompleted is int
        ? bytesCompleted
        : int.tryParse('$bytesCompleted') ?? 0;
    final progress = total > 0
        ? (done / total).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: shadcn.Theme.of(context).borderRadiusSm,
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? '(未知文件)' : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).xSmall.foreground,
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: shadcn.LinearProgressIndicator(
                  value: progress,
                  backgroundColor: cs.border,
                  color: cs.primary,
                  minHeight: 4,
                  borderRadius:
                  shadcn.Theme.of(context).borderRadiusSm,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(progress * 100).toStringAsFixed(0)}%')
                  .xSmall
                  .muted,
            ],
          ),
        ],
      ),
    );
  }
}
