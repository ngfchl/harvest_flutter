import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import 'desktop_torrent_format_utils.dart';
import 'torrent_category_utils.dart';
import 'torrent_column.dart';
import 'torrent_list_status.dart';

// ── 种子行 ──

class DesktopTorrentRow extends StatelessWidget {
  final List<TorrentColumn> columns;
  final Torrent torrent;
  final bool selected;
  final TorrentSiteMatch? siteMatch;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final GestureTapDownCallback onSecondaryTapDown;

  const DesktopTorrentRow({
    super.key,
    required this.columns,
    required this.torrent,
    required this.selected,
    required this.siteMatch,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final color = statusColor(torrent.torrentStatus, torrent.hasError);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapDown: onSecondaryTapDown,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: selected ? cs.primary.withValues(alpha: 0.08) : null,
        child: Row(
          children: [
            for (final column in columns)
              _buildCell(context, column, color),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
      BuildContext context,
      TorrentColumn column,
      Color color,
      ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final hasError = torrent.hasError;
    final errorText = torrent.effectiveErrorMessage.isEmpty
        ? '种子存在错误'
        : torrent.effectiveErrorMessage;
    return switch (column) {
      TorrentColumn.queueId => DesktopCell(
        width: column.width,
        text: '${torrent.id > 0 ? torrent.id : torrent.queuePosition}',
      ),
      TorrentColumn.name => DesktopCell(
        width: column.width,
        child: Row(
          children: [
            StatusDot(color: color),
            const SizedBox(width: 9),
            if (hasError)
              shadcn.Tooltip(
                tooltip: (_) => Text(errorText).xSmall,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: cs.destructive.withValues(alpha: 0.12),
                    borderRadius: shadcn.Theme.of(context).borderRadiusSm,
                    border: Border.all(
                      color: cs.destructive.withValues(alpha: 0.35),
                      width: 0.5,
                    ),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: cs.destructive),
                    child: Text('错').xSmall.medium,
                  ),
                ),
              ),
            Expanded(
              child: hasError
                  ? shadcn.Tooltip(
                tooltip: (_) => Text(errorText).xSmall,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: cs.destructive),
                  child: (selected
                      ? Text(
                    torrent.name.isEmpty
                        ? '(无名称)'
                        : torrent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).small.bold
                      : Text(
                    torrent.name.isEmpty
                        ? '(无名称)'
                        : torrent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).small.medium),
                ),
              )
                  : (selected
                  ? Text(
                torrent.name.isEmpty ? '(无名称)' : torrent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).small.bold.foreground
                  : Text(
                torrent.name.isEmpty ? '(无名称)' : torrent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).small.medium.foreground),
            ),
          ],
        ),
      ),
      TorrentColumn.selectedSize => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.sizeWhenDone),
      ),
      TorrentColumn.totalSize => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(
          torrent.totalSize > 0
              ? torrent.totalSize
              : torrent.sizeWhenDone,
        ),
      ),
      TorrentColumn.status => DesktopCell(
        width: column.width,
        child: StatusPill(
          label: torrent.torrentStatus.label,
          color: color,
        ),
      ),
      TorrentColumn.progress => DesktopCell(
        width: column.width,
        child: InlineProgress(
          value: torrent.percentDone,
          color: color,
        ),
      ),
      TorrentColumn.seeds => DesktopCell(
        width: column.width,
        text: '${torrent.peersGettingFromUs}',
      ),
      TorrentColumn.peers => DesktopCell(
        width: column.width,
        text: '${torrent.peersSendingToUs}',
      ),
      TorrentColumn.download => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatSpeed(torrent.rateDownload),
        color: torrent.rateDownload > 0 ? colorDownloading : null,
      ),
      TorrentColumn.upload => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatSpeed(torrent.rateUpload),
        color: torrent.rateUpload > 0 ? colorSeeding : null,
      ),
      TorrentColumn.eta => DesktopCell(
        width: column.width,
        text: desktopTorrentEta(torrent),
      ),
      TorrentColumn.ratio => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatRatio(torrent.uploadRatio),
      ),
      TorrentColumn.category => DesktopCell(
        width: column.width,
        text: torrentCategoryLabel(torrent).isEmpty
            ? '-'
            : torrentCategoryLabel(torrent),
      ),
      TorrentColumn.tags => DesktopCell(
        width: column.width,
        text: torrent.labels.isEmpty
            ? '-'
            : torrent.labels.join(', '),
      ),
      TorrentColumn.added => DesktopCell(
        width: column.width,
        text: desktopTorrentTime(torrent.addedDate),
      ),
      TorrentColumn.completed => DesktopCell(
        width: column.width,
        text: desktopTorrentTime(torrent.doneDate),
      ),
      TorrentColumn.tracker => DesktopCell(
        width: column.width,
        text: siteMatch?.displayName ??
            desktopTorrentTracker(torrent),
      ),
      TorrentColumn.speedLimit => DesktopCell(
        width: column.width,
        text:
        '↓ ${desktopTorrentSpeedLimit(torrent.downloadLimit)} / ↑ ${desktopTorrentSpeedLimit(torrent.uploadLimit)}',
      ),
      TorrentColumn.downloaded => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.downloadedEver),
      ),
      TorrentColumn.uploaded => DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.uploadedEver),
      ),
      TorrentColumn.sessionTransfer => DesktopCell(
        width: column.width,
        text: '-',
      ),
      TorrentColumn.savePath => DesktopCell(
        width: column.width,
        text: torrent.downloadDir.isEmpty
            ? '-'
            : torrent.downloadDir,
      ),
      TorrentColumn.ratioLimit => DesktopCell(
        width: column.width,
        text: torrent.seedRatioLimit <= 0
            ? '-'
            : TorrentUtils.formatRatio(torrent.seedRatioLimit),
      ),
      TorrentColumn.lastSeenComplete => DesktopCell(
        width: column.width,
        text: '-',
      ),
      TorrentColumn.activity => DesktopCell(
        width: column.width,
        text: desktopTorrentTime(torrent.activityDate),
      ),
    };
  }
}

// ── 单元格 ──

class DesktopCell extends StatelessWidget {
  final double width;
  final String? text;
  final Color? color;
  final Widget? child;

  const DesktopCell({
    super.key,
    required this.width,
    this.text,
    this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final content = Text(
      text ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ).xSmall;
    return SizedBox(
      width: width,
      child: child ??
          (color == null
              ? content.muted
              : DefaultTextStyle.merge(
            style: TextStyle(color: color),
            child: content,
          )),
    );
  }
}

// ── 状态点 ──

class StatusDot extends StatelessWidget {
  final Color color;

  const StatusDot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── 状态胶囊 ──

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: shadcn.Theme.of(context).borderRadiusSm,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).xSmall.medium,
        ),
      ),
    );
  }
}

// ── 内联进度条 ──

class InlineProgress extends StatelessWidget {
  final double value;
  final Color color;

  const InlineProgress({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: shadcn.LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: cs.border,
            color: color,
            minHeight: 5,
            borderRadius: shadcn.Theme.of(context).borderRadiusSm,
          ),
        ),
        const SizedBox(width: 7),
        Text(TorrentUtils.formatPercent(value)).xSmall.muted,
      ],
    );
  }
}
