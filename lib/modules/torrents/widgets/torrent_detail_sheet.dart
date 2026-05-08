import 'package:flutter/material.dart';
import 'package:harvest/core/utils/formatters/file_size_formatter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../../download/service/downloader_service.dart';
import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';

class TorrentDetailSheet extends StatefulWidget {
  final int downloaderId;
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const TorrentDetailSheet({super.key, required this.downloaderId, required this.torrent, this.siteMatch});

  @override
  State<TorrentDetailSheet> createState() => _TorrentDetailSheetState();
}

class _TorrentDetailSheetState extends State<TorrentDetailSheet> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = DownloaderService.fetchTorrentDetail(widget.downloaderId, widget.torrent.hashString);
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.86,
        child: shadcn.Scaffold(
          backgroundColor: cs.background,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              final detail = snapshot.data ?? const <String, dynamic>{};
              final loading = snapshot.connectionState == ConnectionState.waiting;
              final files = _extractList(detail, const ['files', 'contents']);
              final trackers = _extractList(detail, const ['trackers', 'trackerStats']);
              final properties = _extractMap(detail, const ['properties', 'props']);

              return Column(
                children: [
                  _DetailHeader(
                    torrent: widget.torrent,
                    siteMatch: widget.siteMatch,
                    loading: loading,
                    onRefresh: () => setState(() {
                      _future = DownloaderService.fetchTorrentDetail(widget.downloaderId, widget.torrent.hashString);
                    }),
                  ),
                  Divider(height: 1, color: cs.border),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                      children: [
                        _SummaryPanel(torrent: widget.torrent, properties: properties),
                        const SizedBox(height: 10),
                        _TrackerPanel(torrent: widget.torrent, trackers: trackers),
                        const SizedBox(height: 10),
                        _FilePanel(files: files),
                        if (snapshot.hasError) ...[
                          const SizedBox(height: 10),
                          _ErrorPanel(error: snapshot.error.toString()),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;
  final bool loading;
  final VoidCallback onRefresh;

  const _DetailHeader({required this.torrent, required this.siteMatch, required this.loading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final color = _statusColor(torrent);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(shadcn.LucideIcons.download, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  torrent.name.isEmpty ? '(无名称)' : torrent.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).base.bold.foreground,
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniChip(icon: shadcn.LucideIcons.activity, text: torrent.torrentStatus.label, color: color),
                    if (siteMatch != null)
                      _MiniChip(
                        icon: shadcn.LucideIcons.globe,
                        text: siteMatch!.displayName,
                        color: const Color(0xFF14B8A6),
                      ),
                    _MiniChip(
                      icon: shadcn.LucideIcons.percent,
                      text: TorrentUtils.formatPercent(torrent.percentDone),
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          shadcn.IconButton.ghost(
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox(width: 16, height: 16, child: shadcn.CircularProgressIndicator(size: 18))
                : const Icon(shadcn.LucideIcons.refreshCw, size: 16),
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  final Torrent torrent;
  final Map<String, dynamic> properties;

  const _SummaryPanel({required this.torrent, required this.properties});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DetailItem('大小', TorrentUtils.formatBytes(torrent.sizeWhenDone), shadcn.LucideIcons.hardDrive),
      _DetailItem('下载', TorrentUtils.formatSpeed(torrent.rateDownload), shadcn.LucideIcons.arrowDown),
      _DetailItem('上传', TorrentUtils.formatSpeed(torrent.rateUpload), shadcn.LucideIcons.arrowUp),
      _DetailItem('分享率', TorrentUtils.formatRatio(torrent.uploadRatio), shadcn.LucideIcons.chartPie),
      _DetailItem('分类', torrent.category.isEmpty ? '未分类' : torrent.category, shadcn.LucideIcons.folder),
      _DetailItem('标签', torrent.labels.isEmpty ? '无' : torrent.labels.join(', '), shadcn.LucideIcons.tags),
      _DetailItem('保存路径', torrent.downloadDir.isEmpty ? '-' : torrent.downloadDir, shadcn.LucideIcons.folderOpen),
      _DetailItem('内容路径', torrent.contentPath.isEmpty ? '-' : torrent.contentPath, shadcn.LucideIcons.file),
      _DetailItem('添加时间', TorrentUtils.formatTimeAgo(torrent.addedDate), shadcn.LucideIcons.calendarPlus),
      _DetailItem('活动时间', TorrentUtils.formatTimeAgo(torrent.activityDate), shadcn.LucideIcons.clock),
      if (properties.isNotEmpty)
        _DetailItem(
          '总大小',
          _propertyText(properties, const ['total_size', 'totalSize', 'total_size_bytes']),
          shadcn.LucideIcons.database,
        ),
    ];

    return _SectionCard(
      title: '概览',
      icon: shadcn.LucideIcons.layoutDashboard,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) => _DetailMetric(item: item)).toList(growable: false),
      ),
    );
  }
}

class _TrackerPanel extends StatelessWidget {
  final Torrent torrent;
  final List<Map<String, dynamic>> trackers;

  const _TrackerPanel({required this.torrent, required this.trackers});

  @override
  Widget build(BuildContext context) {
    final apiTrackers = trackers.where((tracker) => !_isVirtualTrackerData(tracker)).toList();
    final fallback = torrent.visibleTrackerStats
        .map(
          (tracker) => {
            'announce': tracker.announce,
            'host': tracker.host,
            'status': tracker.lastAnnounceSucceeded ? '正常' : '',
            'msg': tracker.lastAnnounceResult,
            'seeds': tracker.seederCount,
            'leeches': tracker.leecherCount,
          },
        )
        .toList();
    final list = apiTrackers.isNotEmpty ? apiTrackers : fallback;

    return _SectionCard(
      title: 'Tracker',
      icon: shadcn.LucideIcons.radioTower,
      child: list.isEmpty
          ? const _EmptyLine(text: '暂无 Tracker 信息')
          : Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  _TrackerRow(data: list[i]),
                  if (i != list.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
    );
  }
}

bool _isVirtualTrackerData(Map<String, dynamic> data) {
  return TorrentUtils.isVirtualTrackerText(_value(data, const ['announce', 'url'])) ||
      TorrentUtils.isVirtualTrackerText(_value(data, const ['host'])) ||
      TorrentUtils.isVirtualTrackerText(_value(data, const ['name', 'sitename', 'site_name']));
}

class _FilePanel extends StatelessWidget {
  final List<Map<String, dynamic>> files;

  const _FilePanel({required this.files});

  @override
  Widget build(BuildContext context) {
    final tree = _buildFileTree(files);

    return _SectionCard(
      title: '文件',
      icon: shadcn.LucideIcons.files,
      child: files.isEmpty
          ? const _EmptyLine(text: '暂无文件详情')
          : Column(
              children: [
                for (var i = 0; i < tree.children.length; i++) ...[
                  _FileTreeEntry(node: tree.children[i], depth: 0),
                  if (i != tree.children.length - 1) const SizedBox(height: 6),
                ],
              ],
            ),
    );
  }
}

class _TrackerRow extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TrackerRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final url = _value(data, const ['announce', 'url']);
    final host = _value(data, const ['host']);
    final msg = _value(data, const ['msg', 'message', 'lastAnnounceResult']);
    final seeds = _value(data, const ['seeds', 'seederCount', 'num_seeds']);
    final leeches = _value(data, const ['leeches', 'leecherCount', 'num_leeches']);

    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(host.isNotEmpty ? host : url, maxLines: 1, overflow: TextOverflow.ellipsis).small.medium.foreground,
          if (url.isNotEmpty && url != host) ...[
            const SizedBox(height: 3),
            Text(url, maxLines: 1, overflow: TextOverflow.ellipsis).xSmall.muted,
          ],
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [_TinyText('S $seeds'), _TinyText('L $leeches'), if (msg.isNotEmpty) _TinyText(msg)],
          ),
        ],
      ),
    );
  }
}

class _FileTreeEntry extends StatelessWidget {
  final _FileTreeNode node;
  final int depth;

  const _FileTreeEntry({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    return node.isFile ? _FileLeaf(node: node, depth: depth) : _FolderNode(node: node, depth: depth);
  }
}

class _FolderNode extends StatefulWidget {
  final _FileTreeNode node;
  final int depth;

  const _FolderNode({required this.node, required this.depth});

  @override
  State<_FolderNode> createState() => _FolderNodeState();
}

class _FolderNodeState extends State<_FolderNode> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.depth < 2;
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final node = widget.node;
    final depth = widget.depth;

    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: EdgeInsets.fromLTRB(10 + depth * 14, 8, 10, 8),
              child: Row(
                children: [
                  Icon(
                    _expanded ? shadcn.LucideIcons.chevronDown : shadcn.LucideIcons.chevronRight,
                    size: 14,
                    color: cs.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Icon(shadcn.LucideIcons.folder, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis).small.medium.foreground,
                        const SizedBox(height: 5),
                        shadcn.LinearProgressIndicator(
                          value: node.progress.clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: cs.border,
                          borderRadius: shadcn.Theme.of(context).borderRadiusXs,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(TorrentUtils.formatBytes(node.size)).xSmall.muted,
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: Column(
                      children: [
                        for (var i = 0; i < node.children.length; i++) ...[
                          _FileTreeEntry(node: node.children[i], depth: depth + 1),
                          if (i != node.children.length - 1) const SizedBox(height: 6),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _FileLeaf extends StatelessWidget {
  final _FileTreeNode node;
  final int depth;

  const _FileLeaf({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: EdgeInsets.fromLTRB(10 + depth * 14, 10, 10, 10),
      child: Row(
        children: [
          Icon(shadcn.LucideIcons.file, size: 16, color: cs.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.name, maxLines: 1, overflow: TextOverflow.ellipsis).small.medium.foreground,
                const SizedBox(height: 4),
                shadcn.LinearProgressIndicator(
                  value: node.progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: cs.border,
                  borderRadius: shadcn.Theme.of(context).borderRadiusXs,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(TorrentUtils.formatBytes(node.size)).xSmall.muted,
        ],
      ),
    );
  }
}

class _FileTreeNode {
  final String name;
  final bool isFile;
  final List<_FileTreeNode> children;
  int size;
  double progress;

  _FileTreeNode.folder(this.name) : isFile = false, children = [], size = 0, progress = 0;

  _FileTreeNode.file({required this.name, required this.size, required this.progress}) : isFile = true, children = [];

  _FileTreeNode folderChild(String name) {
    for (final child in children) {
      if (!child.isFile && child.name == name) return child;
    }
    final child = _FileTreeNode.folder(name);
    children.add(child);
    return child;
  }

  void addFile(_FileTreeNode file) {
    children.add(file);
  }
}

_FileTreeNode _buildFileTree(List<Map<String, dynamic>> files) {
  final root = _FileTreeNode.folder('');
  for (final file in files) {
    final path = _value(file, const ['name', 'path']);
    final parts = path.split(RegExp(r'[\\/]+')).map((part) => part.trim()).where((part) => part.isNotEmpty).toList();
    final normalizedParts = parts.isEmpty ? ['(未命名文件)'] : parts;
    var parent = root;
    for (final folder in normalizedParts.take(normalizedParts.length - 1)) {
      parent = parent.folderChild(folder);
    }
    parent.addFile(
      _FileTreeNode.file(
        name: normalizedParts.last,
        size: _intValue(file, const ['size', 'length']),
        progress: _doubleValue(file, const ['progress', 'availability']),
      ),
    );
  }
  _finalizeFileTree(root);
  return root;
}

void _finalizeFileTree(_FileTreeNode node) {
  if (node.isFile) return;
  for (final child in node.children) {
    _finalizeFileTree(child);
  }
  node.children.sort((a, b) {
    if (a.isFile != b.isFile) return a.isFile ? 1 : -1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  node.size = node.children.fold(0, (sum, child) => sum + child.size);
  if (node.size <= 0) {
    node.progress = node.children.isEmpty
        ? 0
        : node.children.fold(0.0, (sum, child) => sum + child.progress) / node.children.length;
    return;
  }
  final completed = node.children.fold<double>(0, (sum, child) => sum + child.size * child.progress.clamp(0.0, 1.0));
  node.progress = completed / node.size;
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({required this.title, required this.icon, required this.child});

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
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  final _DetailItem item;

  const _DetailMetric({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: shadcn.Card(
        filled: true,
        fillColor: cs.background,
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, size: 13, color: cs.mutedForeground),
                const SizedBox(width: 5),
                Expanded(child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis).xSmall.muted),
              ],
            ),
            const SizedBox(height: 6),
            Text(item.value, maxLines: 2, overflow: TextOverflow.ellipsis).small.medium.foreground,
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return shadcn.SecondaryBadge(
      leading: Icon(icon, size: 12, color: color),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: color),
        child: Text(text).xSmall.medium,
      ),
    );
  }
}

class _TinyText extends StatelessWidget {
  final String text;

  const _TinyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text).xSmall.muted;
  }
}

class _EmptyLine extends StatelessWidget {
  final String text;

  const _EmptyLine({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text).small.muted;
  }
}

class _ErrorPanel extends StatelessWidget {
  final String error;

  const _ErrorPanel({required this.error});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return shadcn.Card(
      filled: true,
      fillColor: cs.destructive.withValues(alpha: 0.08),
      borderRadius: shadcn.Theme.of(context).borderRadiusMd,
      padding: const EdgeInsets.all(12),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: cs.destructive),
        child: Text('详情加载失败：$error').xSmall,
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem(this.label, this.value, this.icon);
}

List<Map<String, dynamic>> _extractList(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) {
      return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (value is Map) {
      return value.values.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> _extractMap(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String _propertyText(Map<String, dynamic> data, List<String> keys) {
  final value = _value(data, keys);
  final parsed = int.tryParse(value);
  return parsed == null ? (value.isEmpty ? '-' : value) : formatBytes(parsed);
}

String _value(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) return value.toString();
  }
  return '';
}

int _intValue(Map<String, dynamic> data, List<String> keys) {
  final value = _value(data, keys);
  return int.tryParse(value) ?? 0;
}

double _doubleValue(Map<String, dynamic> data, List<String> keys) {
  final value = _value(data, keys);
  return double.tryParse(value) ?? 0;
}

Color _statusColor(Torrent torrent) {
  if (torrent.hasError) return const Color(0xFFEF4444);
  return switch (torrent.torrentStatus) {
    TorrentStatus.downloading || TorrentStatus.downloadWait => const Color(0xFF60A5FA),
    TorrentStatus.seeding || TorrentStatus.seedWait => const Color(0xFF4ADE80),
    TorrentStatus.checking || TorrentStatus.checkWait => const Color(0xFFFBBF24),
    TorrentStatus.stopped => const Color(0xFF9CA3AF),
  };
}
