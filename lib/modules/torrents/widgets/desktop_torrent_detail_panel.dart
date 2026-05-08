import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import '../provider/downloader_provider.dart';
import 'desktop_torrent_detail_widgets.dart';
import 'desktop_torrent_format_utils.dart';

class DesktopTorrentDetailPanel extends ConsumerWidget {
  final int downloaderId;
  final String? selectedHash;
  final bool expanded;
  final double height;
  final VoidCallback onToggle;
  final ValueChanged<double> onResize;

  const DesktopTorrentDetailPanel({
    super.key,
    required this.downloaderId,
    required this.selectedHash,
    required this.expanded,
    required this.height,
    required this.onToggle,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final torrents = ref.watch(filteredTorrentsProvider(downloaderId));
    final matcher = ref.watch(torrentSiteMatcherProvider);
    final selected = _selectedTorrent(torrents);
    final title = selected == null
        ? '选择一个种子查看详情'
        : selected.name.isEmpty
        ? '(无名称)'
        : selected.name;
    final panelHeight = expanded ? height : 48.0;
    final showBody = expanded && panelHeight > 72;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: panelHeight,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: cs.card,
        border: Border.all(color: cs.border, width: 0.5),
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 47,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
                  child: Row(
                    children: [
                      Icon(shadcn.LucideIcons.info, size: 15, color: cs.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis).small.bold.foreground),
                      shadcn.IconButton.ghost(
                        onPressed: selected == null ? null : onToggle,
                        icon: Icon(expanded ? shadcn.LucideIcons.chevronDown : shadcn.LucideIcons.chevronUp, size: 16),
                      ),
                    ],
                  ),
                ),
                if (selected != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: expanded ? (d) => onResize(d.delta.dy) : null,
                    child: MouseRegion(
                      cursor: expanded ? SystemMouseCursors.resizeUpDown : SystemMouseCursors.basic,
                      child: SizedBox(
                        width: 80,
                        height: 28,
                        child: Center(
                          child: Container(
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              color: cs.mutedForeground.withValues(alpha: 0.35),
                              borderRadius: shadcn.Theme.of(context).borderRadiusXxl,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showBody) ...[
            Divider(height: 1, color: cs.border),
            Expanded(
              child: selected == null
                  ? const DesktopEmptyState(icon: shadcn.LucideIcons.info, title: '选择一个种子查看详情')
                  : _DetailBody(downloaderId: downloaderId, torrent: selected, siteMatch: matcher.match(selected)),
            ),
          ],
        ],
      ),
    );
  }

  Torrent? _selectedTorrent(List<Torrent> torrents) {
    if (torrents.isEmpty) return null;
    if (selectedHash != null && selectedHash!.isNotEmpty) {
      for (final t in torrents) {
        if (t.hashString == selectedHash) return t;
      }
    }
    return null;
  }
}

class _DetailBody extends StatefulWidget {
  final int downloaderId;
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const _DetailBody({required this.downloaderId, required this.torrent, required this.siteMatch});

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  late Future<Map<String, dynamic>> _future;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _DetailBody old) {
    super.didUpdateWidget(old);
    if (old.torrent.hashString != widget.torrent.hashString || old.downloaderId != widget.downloaderId) {
      _future = _load();
    }
  }

  Future<Map<String, dynamic>> _load() {
    return DownloaderService.fetchTorrentDetail(widget.downloaderId, widget.torrent.hashString);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final detail = snapshot.data ?? const <String, dynamic>{};
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final properties = desktopExtractMap(detail, const ['properties', 'props']);
        final trackers = desktopExtractList(detail, const ['trackers', 'trackerStats']);
        final files = desktopExtractList(detail, const ['files', 'contents']);
        final rawDetail = Map<String, dynamic>.from(detail)
          ..remove('files')
          ..remove('contents')
          ..remove('trackers')
          ..remove('trackerStats');

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0;
            final tabHeight = max(0.0, maxHeight - 64);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: shadcn.Tabs(
                    index: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                    children: const [
                      shadcn.TabItem(child: Text('概览')),
                      shadcn.TabItem(child: Text('属性')),
                      shadcn.TabItem(child: Text('Tracker')),
                      shadcn.TabItem(child: Text('文件')),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      _buildOverview(tabHeight, properties, snapshot),
                      _buildProperties(tabHeight, properties, loading, rawDetail),
                      _buildTrackers(tabHeight, trackers, loading),
                      _buildFiles(tabHeight, files, loading),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOverview(double h, Map<String, dynamic> properties, AsyncSnapshot snapshot) {
    return SizedBox(
      height: h,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        children: [
          DesktopSelectedSummary(torrent: widget.torrent, siteMatch: widget.siteMatch),
          const SizedBox(height: 12),
          DesktopDetailSection(
            title: '概览',
            icon: shadcn.LucideIcons.layoutDashboard,
            child: DesktopDetailMetrics(torrent: widget.torrent, properties: properties),
          ),
          if (snapshot.hasError) ...[
            const SizedBox(height: 10),
            shadcn.Card(
              filled: true,
              fillColor: shadcn.Theme.of(context).colorScheme.destructive.withValues(alpha: 0.08),
              borderRadius: shadcn.Theme.of(context).borderRadiusMd,
              padding: const EdgeInsets.all(10),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: shadcn.Theme.of(context).colorScheme.destructive),
                child: Text('详情加载失败：${snapshot.error}').xSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProperties(double h, Map<String, dynamic> properties, bool loading, Map<String, dynamic> rawDetail) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final torrentData = widget.torrent.toJson();

    return SizedBox(
      height: h,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        children: [
          // ── 种子字段（按分类分组） ──
          _PropertyGroup(
            title: '基本信息',
            icon: shadcn.LucideIcons.fileText,
            accent: cs.primary,
            entries: _filterKeys(torrentData, const [
              'name',
              'hashString',
              'magnetURI',
              'comment',
              'torrentFile',
              'downloadDir',
              'contentPath',
              'creator',
              'dateCreated',
            ]),
          ),
          const SizedBox(height: 10),
          _PropertyGroup(
            title: '大小与进度',
            icon: shadcn.LucideIcons.hardDrive,
            accent: const Color(0xFF60A5FA),
            entries: _filterKeys(torrentData, const [
              'totalSize',
              'sizeWhenDone',
              'leftUntilDone',
              'desiredAvailable',
              'haveValid',
              'haveUnchecked',
              'percentDone',
              'recheckProgress',
            ]),
            formatters: {
              'totalSize': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'sizeWhenDone': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'leftUntilDone': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'desiredAvailable': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'haveValid': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'haveUnchecked': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'percentDone': (v) => TorrentUtils.formatPercent(_parseDouble(v)),
              'recheckProgress': (v) => TorrentUtils.formatPercent(_parseDouble(v)),
            },
          ),
          const SizedBox(height: 10),
          _PropertyGroup(
            title: '传输速度',
            icon: shadcn.LucideIcons.activity,
            accent: const Color(0xFF4ADE80),
            entries: _filterKeys(torrentData, const [
              'rateDownload',
              'rateUpload',
              'downloadLimit',
              'uploadLimit',
              'downloadedEver',
              'uploadedEver',
              'uploadRatio',
              'seedRatioLimit',
              'seedRatioMode',
              'peersGettingFromUs',
              'peersSendingToUs',
              'webSeedsSendingToUs',
            ]),
            formatters: {
              'rateDownload': (v) => TorrentUtils.formatSpeed(_parseInt(v)),
              'rateUpload': (v) => TorrentUtils.formatSpeed(_parseInt(v)),
              'downloadLimit': (v) => _parseInt(v) <= 0 ? '不限' : TorrentUtils.formatSpeed(_parseInt(v)),
              'uploadLimit': (v) => _parseInt(v) <= 0 ? '不限' : TorrentUtils.formatSpeed(_parseInt(v)),
              'downloadedEver': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'uploadedEver': (v) => TorrentUtils.formatBytes(_parseInt(v)),
              'uploadRatio': (v) => TorrentUtils.formatRatio(_parseDouble(v)),
              'seedRatioLimit': (v) => _parseDouble(v) <= 0 ? '不限' : TorrentUtils.formatRatio(_parseDouble(v)),
            },
          ),
          const SizedBox(height: 10),
          _PropertyGroup(
            title: '状态与时间',
            icon: shadcn.LucideIcons.clock,
            accent: const Color(0xFFFBBF24),
            entries: _filterKeys(torrentData, const [
              'status',
              'torrentStatus',
              'error',
              'errorString',
              'addedDate',
              'doneDate',
              'activityDate',
              'startDate',
              'secondsSeeding',
              'secondsDownloading',
              'queuePosition',
              'priority',
            ]),
            formatters: {
              'addedDate': (v) => _formatTimestamp(_parseInt(v)),
              'doneDate': (v) => _formatTimestamp(_parseInt(v)),
              'activityDate': (v) => _formatTimestamp(_parseInt(v)),
              'startDate': (v) => _formatTimestamp(_parseInt(v)),
              'secondsSeeding': (v) => TorrentUtils.formatDuration(_parseInt(v)),
              'secondsDownloading': (v) => TorrentUtils.formatDuration(_parseInt(v)),
            },
          ),
          const SizedBox(height: 10),
          _PropertyGroup(
            title: '做种与标签',
            icon: shadcn.LucideIcons.tags,
            accent: const Color(0xFFA78BFA),
            entries: _filterKeys(torrentData, const [
              'labels',
              'category',
              'autoTmm',
              'forceStart',
              'superSeeding',
              'isFinished',
              'isPrivate',
              'isStalled',
              'maxConnectedPeers',
              'peerLimit',
            ]),
            formatters: {'labels': (v) => (v is List && v.isEmpty) ? '无' : '$v'},
          ),

          const SizedBox(height: 16),
          Divider(color: cs.border, height: 1),
          const SizedBox(height: 16),

          // ── 接口属性 ──
          DesktopDetailSection(
            title: '接口属性',
            icon: shadcn.LucideIcons.database,
            trailing: loading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: shadcn.CircularProgressIndicator(size: 18, color: cs.mutedForeground),
                  )
                : null,
            child: properties.isEmpty ? const DesktopMutedLine('暂无接口属性') : DesktopFieldTable(data: properties),
          ),

          const SizedBox(height: 10),

          // ── 原始详情 ──
          DesktopDetailSection(
            title: '原始详情',
            icon: shadcn.LucideIcons.braces,
            child: rawDetail.isEmpty ? const DesktopMutedLine('暂无更多字段') : _CollapsibleFieldTable(data: rawDetail),
          ),
        ],
      ),
    );
  }

  // ── 按 key 过滤 ──

  Map<String, dynamic> _filterKeys(Map<String, dynamic> source, List<String> keys) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      if (source.containsKey(key)) {
        result[key] = source[key];
      }
    }
    return result;
  }

  int _parseInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

  double _parseDouble(dynamic v) => v is double ? v : double.tryParse('$v') ?? 0;

  String _formatTimestamp(int ts) {
    if (ts <= 0) return '-';
    return TorrentUtils.formatTimeAgo(ts);
  }

  Widget _buildTrackers(double h, List<dynamic> trackers, bool loading) {
    return SizedBox(
      height: h,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        children: [
          DesktopDetailSection(
            title: 'Tracker',
            icon: shadcn.LucideIcons.radioTower,
            trailing: loading
                ? const SizedBox(width: 14, height: 14, child: shadcn.CircularProgressIndicator(size: 18))
                : null,
            child: DesktopTrackerList(torrent: widget.torrent, trackers: trackers),
          ),
        ],
      ),
    );
  }

  Widget _buildFiles(double h, List<dynamic> files, bool loading) {
    return SizedBox(
      height: h,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        children: [
          DesktopDetailSection(
            title: '文件',
            icon: shadcn.LucideIcons.files,
            trailing: loading
                ? const SizedBox(width: 14, height: 14, child: shadcn.CircularProgressIndicator(size: 18))
                : null,
            child: DesktopFileList(files: files),
          ),
        ],
      ),
    );
  }
}

class _PropertyGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Map<String, dynamic> entries;
  final Map<String, String Function(dynamic)>? formatters;

  const _PropertyGroup({
    required this.title,
    required this.icon,
    required this.accent,
    required this.entries,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: cs.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 标题栏 ──
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.06),
              border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, size: 12, color: accent),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: cs.foreground, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.mutedForeground.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${entries.length}',
                    style: TextStyle(fontSize: 10, color: cs.mutedForeground, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // ── 字段行 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              children: [
                for (final entry in entries.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) ...[
                  _PropertyRow(
                    name: entry.key,
                    value: formatters?[entry.key]?.call(entry.value) ?? desktopFieldValue(entry.value),
                  ),
                  if (entry.key != entries.keys.last)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Divider(height: 1, color: cs.border.withValues(alpha: 0.4)),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String name;
  final String value;

  const _PropertyRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            _humanizeFieldName(name),
            style: TextStyle(fontSize: 11, color: cs.mutedForeground, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: cs.foreground,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  String _humanizeFieldName(String name) {
    // camelCase → 人类可读
    final result = name
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}')
        .replaceAllMapped(RegExp(r'^([a-z])'), (m) => m.group(1)!.toUpperCase());
    return result;
  }
}

// ── 可折叠的原始字段表 ──

class _CollapsibleFieldTable extends StatefulWidget {
  final Map<String, dynamic> data;

  const _CollapsibleFieldTable({required this.data});

  @override
  State<_CollapsibleFieldTable> createState() => _CollapsibleFieldTableState();
}

class _CollapsibleFieldTableState extends State<_CollapsibleFieldTable> {
  static const _initialCount = 12;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final entries = widget.data.entries.toList()..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    if (entries.isEmpty) return const DesktopMutedLine('暂无字段');

    final visibleEntries = _expanded ? entries : entries.take(_initialCount).toList();
    final hasMore = entries.length > _initialCount;

    return Column(
      children: [
        for (final entry in visibleEntries) ...[
          _PropertyRow(name: entry.key, value: desktopFieldValue(entry.value)),
          if (entry != visibleEntries.last)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Divider(height: 1, color: cs.border.withValues(alpha: 0.4)),
            ),
        ],
        if (hasMore) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _expanded ? shadcn.LucideIcons.chevronUp : shadcn.LucideIcons.chevronDown,
                    size: 13,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _expanded ? '收起' : '展开全部 ${entries.length} 项',
                    style: TextStyle(fontSize: 11, color: cs.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
