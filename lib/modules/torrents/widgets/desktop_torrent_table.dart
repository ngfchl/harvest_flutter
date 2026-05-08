import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/feedback/toast.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../../download/model/downloader.dart';
import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import '../provider/downloader_provider.dart';
import '../provider/torrent_control_provider.dart';
import 'desktop_torrent_detail_widgets.dart';
import 'desktop_torrent_row.dart';
import 'torrent_column.dart';
import 'torrent_context_menu.dart';
import 'torrent_detail_sheet.dart';

double desktopTorrentTableWidth(List<TorrentColumn> columns) {
  return columns.fold<double>(24, (sum, c) => sum + c.width);
}

final desktopTorrentColumnsProvider =
StateProvider.autoDispose<Set<TorrentColumn>>(
      (_) => Set<TorrentColumn>.of(TorrentColumn.values),
);

List<TorrentColumn> visibleDesktopTorrentColumns(
    Set<TorrentColumn> configured,
    ) {
  return TorrentColumn.values
      .where((c) => configured.contains(c))
      .toList();
}

class DesktopTorrentTable extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final String? selectedHash;
  final ValueChanged<Torrent> onSelect;

  const DesktopTorrentTable({
    super.key,
    required this.downloaderId,
    required this.downloaderType,
    required this.selectedHash,
    required this.onSelect,
  });

  @override
  ConsumerState<DesktopTorrentTable> createState() =>
      _DesktopTorrentTableState();
}

class _DesktopTorrentTableState
    extends ConsumerState<DesktopTorrentTable> {
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final downloaderId = widget.downloaderId;
    final asyncData = ref.watch(torrentListProvider(downloaderId));
    final torrents = ref.watch(filteredTorrentsProvider(downloaderId));
    final categories =
    ref.watch(availableCategoriesProvider(downloaderId));
    final tags = ref.watch(availableTagsProvider(downloaderId));
    final matcher = ref.watch(torrentSiteMatcherProvider);
    final visibleColumns = visibleDesktopTorrentColumns(
      ref.watch(desktopTorrentColumnsProvider),
    );
    final tableWidth = desktopTorrentTableWidth(visibleColumns);

    if (asyncData.isLoading && asyncData.valueOrNull == null) {
      return Center(
        child: shadcn.CircularProgressIndicator(size: 18),
      );
    }

    if (asyncData is AsyncError) {
      return DesktopEmptyState(
        icon: shadcn.LucideIcons.cloudOff,
        title: '连接失败',
      );
    }

    if (torrents.isEmpty) {
      return DesktopEmptyState(
        icon: shadcn.LucideIcons.inbox,
        title: (asyncData.valueOrNull?.torrents.isEmpty ?? true)
            ? '暂无种子'
            : '当前筛选无结果',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: shadcn.Card(
        filled: true,
        fillColor: cs.card,
        borderColor: cs.border,
        borderWidth: 0.5,
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = max(tableWidth, constraints.maxWidth + 1);
            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              trackVisibility: true,
              notificationPredicate: (n) =>
              n.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: width,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _DesktopTorrentHeader(columns: visibleColumns),
                      Divider(height: 1, color: cs.border),
                      Expanded(
                        child: ListView.separated(
                          itemCount: torrents.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: cs.border.withValues(alpha: 0.6),
                          ),
                          itemBuilder: (context, index) {
                            final torrent = torrents[index];
                            final hash = torrent.hashString;
                            return DesktopTorrentRow(
                              columns: visibleColumns,
                              torrent: torrent,
                              selected: hash.isNotEmpty &&
                                  hash == widget.selectedHash,
                              siteMatch: matcher.match(torrent),
                              onTap: () =>
                                  widget.onSelect(torrent),
                              onDoubleTap: () => _showDetail(
                                context,
                                torrent,
                                matcher.match(torrent),
                              ),
                              onSecondaryTapDown: (details) =>
                                  _showContextMenu(
                                    context,
                                    ref,
                                    details.globalPosition,
                                    torrent,
                                    matcher.match(torrent),
                                    categories,
                                    tags,
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDetail(
      BuildContext context,
      Torrent torrent,
      TorrentSiteMatch? siteMatch,
      ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => TorrentDetailSheet(
        downloaderId: widget.downloaderId,
        torrent: torrent,
        siteMatch: siteMatch,
      ),
    );
  }

  Future<void> _showContextMenu(
      BuildContext context,
      WidgetRef ref,
      Offset position,
      Torrent torrent,
      TorrentSiteMatch? siteMatch,
      List<String> categories,
      List<String> tags,
      ) async {
    widget.onSelect(torrent);
    final action = await showTorrentContextMenu(
      context: context,
      position: position,
      items: torrentContextMenuItems(
        torrent: torrent,
        type: widget.downloaderType,
        categories: categories,
        tags: tags,
      ),
      submenus: {
        torrentCategorySubmenuAction:
        torrentCategorySubmenuItems(
          torrent: torrent,
          categories: categories,
        ),
        torrentTagSubmenuAction: torrentTagSubmenuItems(
          torrent: torrent,
          tags: tags,
        ),
        torrentCopySubmenuAction: torrentCopySubmenuItems(),
      },
    );
    if (!context.mounted || action == null) return;
    await handleTorrentContextMenuAction(
      context: context,
      ref: ref,
      downloaderId: widget.downloaderId,
      downloaderType: widget.downloaderType,
      torrent: torrent,
      siteMatch: siteMatch,
      action: action,
      onAction: (action, params) => executeTorrentAction(
        ref: ref,
        downloaderId: widget.downloaderId,
        action: action,
        params: params,
      ),
    );
  }
}

class _DesktopTorrentHeader extends ConsumerWidget {
  final List<TorrentColumn> columns;

  const _DesktopTorrentHeader({required this.columns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onSecondaryTapDown: (details) =>
          _showColumnMenu(context, ref, details.globalPosition),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            for (final column in columns)
              column.sort == null
                  ? _TableHeaderText(
                label: column.label,
                width: column.width,
              )
                  : _SortableHeader(
                label: column.label,
                width: column.width,
                sort: column.sort!,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showColumnMenu(
      BuildContext context,
      WidgetRef ref,
      Offset position,
      ) async {
    final selected = await _showDesktopColumnMenu(
      context: context,
      position: position,
      selectedColumns: ref.read(desktopTorrentColumnsProvider),
    );
    if (selected == null) return;
    final notifier = ref.read(
      desktopTorrentColumnsProvider.notifier,
    );
    final next = Set<TorrentColumn>.of(notifier.state);
    if (next.contains(selected)) {
      if (next.length == 1) {
        Toast.info('至少保留一列');
        return;
      }
      next.remove(selected);
    } else {
      next.add(selected);
    }
    notifier.state = next;
  }
}

class _TableHeaderText extends StatelessWidget {
  final String label;
  final double width;

  const _TableHeaderText({required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ).xSmall.muted,
    );
  }
}

class _SortableHeader extends ConsumerWidget {
  final String label;
  final double width;
  final TorrentSort sort;

  const _SortableHeader({
    required this.label,
    required this.width,
    required this.sort,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final currentSort = ref.watch(torrentSortProvider);
    final sortAsc = ref.watch(torrentSortAscProvider);
    final active = currentSort == sort;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (active) {
          ref.read(torrentSortAscProvider.notifier).state = !sortAsc;
        } else {
          ref.read(torrentSortProvider.notifier).state = sort;
          ref.read(torrentSortAscProvider.notifier).state = true;
        }
      },
      child: SizedBox(
        width: width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: active
                      ? cs.primary
                      : cs.mutedForeground,
                  fontWeight: active
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 3),
              Icon(
                sortAsc
                    ? shadcn.LucideIcons.arrowUp
                    : shadcn.LucideIcons.arrowDown,
                size: 11,
                color: cs.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<TorrentColumn?> _showDesktopColumnMenu({
  required BuildContext context,
  required Offset position,
  required Set<TorrentColumn> selectedColumns,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<TorrentColumn?>();
  late final OverlayEntry entry;
  var removed = false;

  void close(TorrentColumn? column) {
    if (removed) return;
    removed = true;
    if (!completer.isCompleted) completer.complete(column);
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => close(null),
            onSecondaryTapDown: (_) => close(null),
          ),
        ),
        AppContextMenuPopup(
          anchorContext: context,
          position: position,
          children: [
            shadcn.MenuLabel(child: const Text('显示列').xSmall.muted),
            const shadcn.MenuDivider(),
            for (final column in TorrentColumn.values)
              shadcn.MenuButton(
                leading: Icon(
                  selectedColumns.contains(column)
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 16,
                ),
                onPressed: (_) => close(column),
                child: SizedBox(
                  width: 180,
                  child: Text(column.label).small,
                ),
              ),
          ],
        ),
      ],
    ),
  );
  overlay.insert(entry);
  return completer.future;
}
