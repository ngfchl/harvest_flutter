import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';
import 'desktop_torrent_detail_panel.dart';
import 'desktop_torrent_sidebar.dart';
import 'desktop_torrent_table.dart';
import 'torrent_refresh_bar.dart';

class DesktopTorrentLayout extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final String? selectedHash;
  final Set<String> selectedHashes;
  final bool detailExpanded;
  final double detailHeight;
  final ValueChanged<Torrent> onSelect;
  final ValueChanged<Set<String>> onSelectionChange;
  final VoidCallback onToggleDetail;
  final ValueChanged<double> onDetailResize;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshStateChanged;
  final VoidCallback? onOpenSpeedSettings;
  final ValueChanged<bool>? onToggleSpeedMode;

  const DesktopTorrentLayout({
    super.key,
    required this.downloaderId,
    required this.downloaderType,
    required this.downloader,
    required this.selectedHash,
    required this.selectedHashes,
    required this.detailExpanded,
    required this.detailHeight,
    required this.onSelect,
    required this.onSelectionChange,
    required this.onToggleDetail,
    required this.onDetailResize,
    required this.onRefresh,
    required this.onRefreshStateChanged,
    this.onOpenSpeedSettings,
    this.onToggleSpeedMode,
  });

  @override
  ConsumerState<DesktopTorrentLayout> createState() =>
      _DesktopTorrentLayoutState();
}

class _DesktopTorrentLayoutState extends ConsumerState<DesktopTorrentLayout> {
  static const List<int> _pageSizeOptions = [20, 30, 50, 100, 200, 500, 1000];

  bool _sidebarCollapsed = false;
  double _sidebarWidth = 280;
  int _page = 1;
  int _pageSize = 100;
  static const double _minSidebarWidth = 220;
  static const double _maxSidebarWidth = 460;

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final torrents = ref.watch(filteredTorrentsProvider(widget.downloaderId));
    final queueEnabled = _downloaderQueueEnabled(widget.downloader);
    final pageData = _pageData(torrents);

    return ColoredBox(
      color: cs.mutedForeground.withValues(alpha: 0.025),
      child: Column(
        children: [
          TorrentRefreshBar(
            downloaderId: widget.downloaderId,
            downloader: widget.downloader,
            onRefresh: widget.onRefresh,
            onRefreshStateChanged: widget.onRefreshStateChanged,
            onOpenSpeedSettings: widget.onOpenSpeedSettings,
            onToggleSpeedMode: widget.onToggleSpeedMode,
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarCollapsed)
                  CollapsedDesktopSidebar(
                    onExpand: () => setState(() => _sidebarCollapsed = false),
                  )
                else
                  DesktopTorrentSidebar(
                    key: ValueKey('desktop-sidebar-${widget.downloaderId}'),
                    downloaderId: widget.downloaderId,
                    downloaderType: widget.downloaderType,
                    downloader: widget.downloader,
                    onCollapse: () => setState(() => _sidebarCollapsed = true),
                    width: _sidebarWidth,
                  ),
                if (!_sidebarCollapsed)
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _sidebarWidth = (_sidebarWidth + details.delta.dx)
                              .clamp(_minSidebarWidth, _maxSidebarWidth);
                        });
                      },
                      child: SizedBox(
                        width: 8,
                        child: Center(
                          child: Container(
                            width: 2,
                            height: 56,
                            decoration: BoxDecoration(
                              color: cs.border.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DesktopTorrentTable(
                          downloaderId: widget.downloaderId,
                          downloaderType: widget.downloaderType,
                          queueEnabled: queueEnabled,
                          selectedHash: widget.selectedHash,
                          selectedHashes: widget.selectedHashes,
                          torrents: pageData.items,
                          onSelect: widget.onSelect,
                          onSelectionChange: widget.onSelectionChange,
                        ),
                      ),
                      if (torrents.isNotEmpty)
                        _DesktopTorrentPaginationBar(
                          totalItems: torrents.length,
                          pageStart: pageData.start,
                          pageEnd: pageData.end,
                          page: pageData.page,
                          totalPages: pageData.totalPages,
                          pageSize: _pageSize,
                          pageSizeOptions: _pageSizeOptions,
                          onPageChanged: (page) => setState(() {
                            _page = page;
                            widget.onSelectionChange(const <String>{});
                          }),
                          onPageSizeChanged: (pageSize) => setState(() {
                            _pageSize = pageSize;
                            _page = 1;
                            widget.onSelectionChange(const <String>{});
                          }),
                        ),
                      DesktopTorrentDetailPanel(
                        downloaderId: widget.downloaderId,
                        selectedHash: widget.selectedHash,
                        expanded: widget.detailExpanded,
                        height: widget.detailHeight,
                        onToggle: widget.onToggleDetail,
                        onResize: widget.onDetailResize,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _DesktopTorrentPageData _pageData(List<Torrent> torrents) {
    if (torrents.isEmpty) {
      return const _DesktopTorrentPageData(
        items: <Torrent>[],
        page: 1,
        totalPages: 1,
        start: 0,
        end: 0,
      );
    }

    final totalPages = ((torrents.length + _pageSize - 1) / _pageSize)
        .floor()
        .clamp(1, 1 << 31);
    final page = _page.clamp(1, totalPages).toInt();
    if (page != _page) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _page == page) return;
        setState(() => _page = page);
      });
    }

    final startIndex = (page - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, torrents.length);
    return _DesktopTorrentPageData(
      items: torrents.sublist(startIndex, endIndex),
      page: page,
      totalPages: totalPages,
      start: startIndex + 1,
      end: endIndex,
    );
  }

  bool _downloaderQueueEnabled(Downloader? downloader) {
    if (downloader == null) return false;
    if (downloader.isQb) {
      return _pickBool(downloader.prefs, const [
            'queueing_enabled',
            'queueingEnabled',
          ]) ??
          false;
    }
    if (downloader.isTr) {
      return true;
    }
    return false;
  }

  bool? _pickBool(Map<String, dynamic>? map, List<String> keys) {
    if (map == null) return null;
    for (final key in keys) {
      final value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
    }
    return null;
  }
}

class _DesktopTorrentPageData {
  final List<Torrent> items;
  final int page;
  final int totalPages;
  final int start;
  final int end;

  const _DesktopTorrentPageData({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.start,
    required this.end,
  });
}

class _DesktopTorrentPaginationBar extends StatelessWidget {
  final int totalItems;
  final int pageStart;
  final int pageEnd;
  final int page;
  final int totalPages;
  final int pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onPageSizeChanged;

  const _DesktopTorrentPaginationBar({
    required this.totalItems,
    required this.pageStart,
    required this.pageEnd,
    required this.page,
    required this.totalPages,
    required this.pageSize,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onPageSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: cs.card.withValues(alpha: 0.7),
        border: Border(top: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            totalItems == 0
                ? '共 0 条'
                : '显示 $pageStart-$pageEnd / 共 $totalItems 条',
            style: theme.typography.xSmall.copyWith(
              color: cs.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '每页',
            style: theme.typography.xSmall.copyWith(
              color: cs.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: shadcn.Select<int>(
              value: pageSize,
              itemBuilder: (_, value) => Text('$value'),
              popup: shadcn.SelectPopup<int>(
                items: shadcn.SelectItemList(
                  children: [
                    for (final value in pageSizeOptions)
                      shadcn.SelectItemButton<int>(
                        value: value,
                        child: Text('$value'),
                      ),
                  ],
                ),
              ).call,
              onChanged: (value) {
                if (value == null || value == pageSize) return;
                onPageSizeChanged(value);
              },
            ),
          ),
          const SizedBox(width: 16),
          shadcn.Pagination(
            page: page,
            totalPages: totalPages,
            maxPages: 5,
            showLabel: false,
            hidePreviousOnFirstPage: true,
            hideNextOnLastPage: true,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    );
  }
}
