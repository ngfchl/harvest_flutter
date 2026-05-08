import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_action_menu.dart';
import '../model/torrent_model.dart';
import 'desktop_torrent_detail_panel.dart';
import 'desktop_torrent_sidebar.dart';
import 'desktop_torrent_table.dart';
import 'torrent_refresh_bar.dart';
import 'torrent_stats_bar.dart';

class DesktopTorrentLayout extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final String? selectedHash;
  final bool detailExpanded;
  final double detailHeight;
  final ValueChanged<Torrent> onSelect;
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
    required this.detailExpanded,
    required this.detailHeight,
    required this.onSelect,
    required this.onToggleDetail,
    required this.onDetailResize,
    required this.onRefresh,
    required this.onRefreshStateChanged,
    this.onOpenSpeedSettings,
    this.onToggleSpeedMode,
  });

  @override
  ConsumerState<DesktopTorrentLayout> createState() => _DesktopTorrentLayoutState();
}

class _DesktopTorrentLayoutState extends ConsumerState<DesktopTorrentLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return ColoredBox(
      color: cs.mutedForeground.withValues(alpha: 0.025),
      child: Column(
        children: [
          TorrentRefreshBar(
            downloaderId: widget.downloaderId,
            onRefresh: widget.onRefresh,
            onRefreshStateChanged: widget.onRefreshStateChanged,
          ),
          StatsBar(
            downloaderId: widget.downloaderId,
            downloader: widget.downloader,
            onOpenSpeedSettings: widget.onOpenSpeedSettings,
            onToggleSpeedMode: widget.onToggleSpeedMode,
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarCollapsed)
                  CollapsedDesktopSidebar(onExpand: () => setState(() => _sidebarCollapsed = false))
                else
                  DesktopTorrentSidebar(
                    key: ValueKey('desktop-sidebar-${widget.downloaderId}'),
                    downloaderId: widget.downloaderId,
                    downloaderType: widget.downloaderType,
                    downloader: widget.downloader,
                    onCollapse: () => setState(() => _sidebarCollapsed = true),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: DesktopTorrentTable(
                          downloaderId: widget.downloaderId,
                          downloaderType: widget.downloaderType,
                          selectedHash: widget.selectedHash,
                          onSelect: widget.onSelect,
                        ),
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
}
