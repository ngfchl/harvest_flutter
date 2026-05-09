import 'dart:async';

import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/shell/widgets/shell_scaffold.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../../download/model/downloader.dart';
import '../model/torrent_action_menu.dart';
import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import '../provider/downloader_provider.dart';
import '../provider/torrent_control_provider.dart';
import 'torrent_context_menu.dart';
import 'torrent_detail_sheet.dart';
import 'torrent_list_status.dart';

class TorrentListMobile extends ConsumerWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Set<String> selectedHashes;
  final ValueChanged<Set<String>> onSelectionChange;

  const TorrentListMobile({
    super.key,
    required this.downloaderId,
    required this.downloaderType,
    required this.selectedHashes,
    required this.onSelectionChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final asyncData = ref.watch(torrentListProvider(downloaderId));
    final torrents = ref.watch(filteredTorrentsProvider(downloaderId));
    final categories = ref.watch(availableCategoriesProvider(downloaderId));
    final tags = ref.watch(availableTagsProvider(downloaderId));
    final matcher = ref.watch(torrentSiteMatcherProvider);
    final selectedTorrents = torrents.where((torrent) => selectedHashes.contains(torrent.hashString)).toList();
    final selectionMode = selectedTorrents.isNotEmpty;

    if (asyncData.isLoading && asyncData.valueOrNull == null) {
      return Center(child: shadcn.CircularProgressIndicator(size: 18));
    }

    if (asyncData is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shadcn.LucideIcons.cloudOff, size: 48, color: cs.foreground.withValues(alpha: 0.2)),
            const SizedBox(height: 12),
            Text('连接失败', style: TextStyle(color: cs.foreground.withValues(alpha: 0.45), fontSize: 14)),
            const SizedBox(height: 12),
            shadcn.Button.primary(
              onPressed: () => ref.read(torrentListProvider(downloaderId).notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (torrents.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shadcn.LucideIcons.inbox, size: 48, color: cs.foreground.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text(
              (asyncData.valueOrNull?.torrents.isEmpty ?? true) ? '暂无种子' : '当前筛选无结果',
              style: TextStyle(color: cs.foreground.withValues(alpha: 0.35), fontSize: 14),
            ),
          ],
        ),
      );
    }

    void toggleSelection(Torrent torrent) {
      final hash = torrent.hashString;
      if (hash.isEmpty) return;
      final next = Set<String>.of(selectedHashes);
      next.contains(hash) ? next.remove(hash) : next.add(hash);
      onSelectionChange(next);
    }

    Future<bool> runAction(String action, Map<String, dynamic> params) async {
      final success = await executeTorrentAction(ref: ref, downloaderId: downloaderId, action: action, params: params);
      if (success) {
        if (action == 'delete' || action == 'remove_torrent') {
          onSelectionChange(const <String>{});
        }
        unawaited(ref.read(torrentListProvider(downloaderId).notifier).refresh());
      }
      return success;
    }

    Future<void> showBatchMenu() async {
      if (selectedTorrents.isEmpty) return;
      final action = await showTorrentBatchContextMenuMobile(
        context: context,
        type: downloaderType,
        count: selectedTorrents.length,
        categories: categories,
        tags: tags,
      );
      if (action == null || !context.mounted) return;
      await handleTorrentBatchContextMenuAction(
        context: context,
        ref: ref,
        downloaderId: downloaderId,
        downloaderType: downloaderType,
        torrents: selectedTorrents,
        action: action,
        onAction: runAction,
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: EdgeInsets.fromLTRB(12, 8, 12, (selectionMode ? 86 : 24) + ShellBottomSpacing.value(context)),
          itemCount: torrents.length,
          itemBuilder: (_, i) {
            final torrent = torrents[i];
            final hash = torrent.hashString;
            return TorrentTile(
              torrent: torrent,
              downloaderId: downloaderId,
              downloaderType: downloaderType,
              siteMatch: matcher.match(torrent),
              categories: categories,
              tags: tags,
              selected: hash.isNotEmpty && selectedHashes.contains(hash),
              selectionMode: selectionMode,
              onToggleSelection: () => toggleSelection(torrent),
              onAction: runAction,
            );
          },
        ),
        if (selectionMode)
          _MobileBatchBar(
            selectedCount: selectedTorrents.length,
            totalCount: torrents.where((torrent) => torrent.hashString.isNotEmpty).length,
            onClear: () => onSelectionChange(const <String>{}),
            onSelectAll: () => onSelectionChange({
              for (final torrent in torrents)
                if (torrent.hashString.isNotEmpty) torrent.hashString,
            }),
            onShowMenu: showBatchMenu,
          ),
      ],
    );
  }
}

class TorrentTile extends ConsumerWidget {
  final Torrent torrent;
  final int downloaderId;
  final DownloaderType downloaderType;
  final TorrentSiteMatch? siteMatch;
  final List<String> categories;
  final List<String> tags;
  final bool selected;
  final bool selectionMode;
  final VoidCallback onToggleSelection;
  final OnTorrentAction onAction;

  const TorrentTile({
    super.key,
    required this.torrent,
    required this.downloaderId,
    required this.downloaderType,
    required this.siteMatch,
    required this.categories,
    required this.tags,
    required this.selected,
    required this.selectionMode,
    required this.onToggleSelection,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final ts = torrent.torrentStatus;
    final color = statusColor(ts, torrent.hasError);
    final trackerLabel = torrent.primaryTracker.isNotEmpty ? torrent.primaryTracker : torrent.primaryTrackerHost;
    final trackerTooltip = torrent.primaryTrackerHost.isNotEmpty ? torrent.primaryTrackerHost : trackerLabel;
    final remainingBytes = _remainingBytes(torrent);
    final etaText = _etaText(torrent, remainingBytes);

    void showDetail() => showAppSheet(
      context: context,
      builder: (_) => TorrentDetailSheet(downloaderId: downloaderId, torrent: torrent, siteMatch: siteMatch),
    );

    void showActionMenu() async {
      final action = await showTorrentContextMenuMobile(
        context: context,
        torrent: torrent,
        type: downloaderType,
        categories: categories,
        tags: tags,
      );
      if (action == null || !context.mounted) return;
      await handleTorrentContextMenuAction(
        context: context,
        ref: ref,
        downloaderId: downloaderId,
        downloaderType: downloaderType,
        torrent: torrent,
        siteMatch: siteMatch,
        action: action,
        onAction: onAction,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: selectionMode ? onToggleSelection : showActionMenu,
        onLongPress: torrent.hashString.isEmpty ? showDetail : onToggleSelection,
        onSecondaryTap: showActionMenu,
        child: shadcn.Card(
          filled: true,
          fillColor: selected ? cs.primary.withValues(alpha: 0.08) : cs.card,
          borderColor: selected ? cs.primary : cs.border,
          borderRadius: shadcn.Theme.of(context).borderRadiusMd,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 名称 ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (selectionMode || selected) ...[_SelectionMark(selected: selected), const SizedBox(width: 10)],
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      torrent.name.isNotEmpty ? torrent.name : '(无名称)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).small.medium.foreground,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── 进度条 ──
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: torrent.percentDone.clamp(0.0, 1.0),
                  backgroundColor: cs.border,
                  color: color,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),

              // ── 数据行 ──
              Row(
                children: [
                  Text(TorrentUtils.formatBytes(torrent.sizeWhenDone)).small.muted,
                  const SizedBox(width: 12),
                  _SpeedChip(
                    icon: shadcn.LucideIcons.arrowDown,
                    value: torrent.rateDownload,
                    color: colorDownloading,
                    mutedColor: cs.foreground.withValues(alpha: 0.25),
                  ),
                  const SizedBox(width: 12),
                  _SpeedChip(
                    icon: shadcn.LucideIcons.arrowUp,
                    value: torrent.rateUpload,
                    color: colorSeeding,
                    mutedColor: cs.foreground.withValues(alpha: 0.25),
                  ),
                  const Spacer(),
                  DefaultTextStyle.merge(
                    style: TextStyle(color: torrent.uploadRatio >= 1.0 ? colorSeeding : null),
                    child: Text('R ${TorrentUtils.formatRatio(torrent.uploadRatio)}').small.medium.muted,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── 信息行 ──
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (trackerLabel.isNotEmpty)
                    _InfoTag(
                      text: trackerLabel,
                      tooltip: trackerTooltip,
                      bg: cs.border,
                      fg: cs.foreground.withValues(alpha: 0.55),
                    ),
                  if (siteMatch != null)
                    _InfoTag(
                      text: siteMatch!.displayName,
                      tooltip: siteMatch!.trackerHost.isNotEmpty ? siteMatch!.trackerHost : siteMatch!.displayName,
                      bg: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                      fg: const Color(0xFF0F766E),
                    ),
                  _InfoTag(text: ts.label, bg: color.withValues(alpha: 0.12), fg: color),
                  if (etaText != null)
                    _InfoTag(text: etaText, bg: colorDownloading.withValues(alpha: 0.12), fg: colorDownloading),
                  if (torrent.hasError)
                    _InfoTag(
                      text: torrent.errorString.isNotEmpty ? torrent.errorString : '错误',
                      bg: colorError.withValues(alpha: 0.12),
                      fg: colorError,
                    ),
                  if (torrent.secondsSeeding > 0)
                    Text('做种 ${TorrentUtils.formatDuration(torrent.secondsSeeding)}').xSmall.muted,
                  Text(TorrentUtils.formatTimeAgo(torrent.activityDate)).xSmall.muted,
                ],
              ),

              // ── 标签 ──
              if (torrent.labels.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: torrent.labels
                      .map(
                        (l) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: cs.primary.withValues(alpha: 0.18), width: 0.5),
                          ),
                          child: Text(
                            l,
                            style: TextStyle(fontSize: 10, color: cs.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  int _remainingBytes(Torrent torrent) {
    if (torrent.leftUntilDone > 0) return torrent.leftUntilDone;
    final total = torrent.sizeWhenDone > 0 ? torrent.sizeWhenDone : torrent.totalSize;
    if (total <= 0) return 0;
    return (total * (1 - torrent.percentDone.clamp(0.0, 1.0))).ceil();
  }

  String? _etaText(Torrent torrent, int remainingBytes) {
    if (remainingBytes <= 0) return null;
    final status = torrent.torrentStatus;
    final isDownloading =
        status == TorrentStatus.downloading || status == TorrentStatus.downloadWait || torrent.rateDownload > 0;
    if (!isDownloading) return null;
    final remainingSize = TorrentUtils.formatBytes(remainingBytes);
    if (torrent.rateDownload <= 0) return '剩余 $remainingSize · --';
    final seconds = (remainingBytes / torrent.rateDownload).ceil();
    return '剩余 $remainingSize · ${TorrentUtils.formatDuration(seconds)}';
  }
}

class _SelectionMark extends StatelessWidget {
  final bool selected;

  const _SelectionMark({required this.selected});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? cs.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? cs.primary : cs.border, width: 1.2),
      ),
      child: selected ? Icon(shadcn.LucideIcons.check, size: 13, color: cs.primaryForeground) : null,
    );
  }
}

class _MobileBatchBar extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onClear;
  final VoidCallback onSelectAll;
  final VoidCallback onShowMenu;

  const _MobileBatchBar({
    required this.selectedCount,
    required this.totalCount,
    required this.onClear,
    required this.onSelectAll,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final bottom = ShellBottomSpacing.value(context);
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12 + bottom,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.border, width: 0.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                shadcn.IconButton.ghost(icon: const Icon(shadcn.LucideIcons.x, size: 18), onPressed: onClear),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '已选择 $selectedCount 个种子',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.foreground, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                shadcn.Button.ghost(
                  onPressed: selectedCount == totalCount ? null : onSelectAll,
                  child: const Text('全选'),
                ),
                const SizedBox(width: 8),
                shadcn.Button.primary(onPressed: onShowMenu, child: const Text('操作')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeedChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final Color mutedColor;

  const _SpeedChip({required this.icon, required this.value, required this.color, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final active = value > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: active ? color : mutedColor),
        const SizedBox(width: 3),
        Text(
          TorrentUtils.formatSpeed(value),
          style: TextStyle(
            fontSize: 11,
            color: active ? color : mutedColor,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String text;
  final String? tooltip;
  final Color bg;
  final Color fg;

  const _InfoTag({required this.text, this.tooltip, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    final tag = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w500),
      ),
    );
    if (tooltip != null && tooltip != text) {
      return shadcn.Tooltip(tooltip: (_) => Text(tooltip!), child: tag);
    }
    return tag;
  }
}
