import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/widgets/app_dialog.dart';
import 'package:harvest/widgets/app_header_layout.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../model/rss_models.dart';
import '../provider/rss_provider.dart';
import '../service/rss_service.dart';
import 'dart:async';
import 'package:harvest/widgets/shadcn_compat.dart';

/// qBittorrent 下载器内建 RSS 管理页。
class QbRssManagerPage extends ConsumerStatefulWidget {
  /// 指定初始选中的下载器 ID（可选）。
  final int? initialDownloaderId;

  const QbRssManagerPage({super.key, this.initialDownloaderId});

  @override
  ConsumerState<QbRssManagerPage> createState() => _QbRssManagerPageState();
}

class _QbRssManagerPageState extends ConsumerState<QbRssManagerPage> {
  int? _downloaderId;
  final bool _withData = false;
  bool _autoDownload = false;
  bool _processing = false;
  bool _togglingAuto = false;
  bool _togglingProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final downloadersAsync = ref.watch(downloaderListProvider);
    final downloaders = (downloadersAsync.value ?? const <Downloader>[])
        .where((d) => d.isQb)
        .toList();

    if (_downloaderId == null) {
      final preset = widget.initialDownloaderId;
      if (preset != null && downloaders.any((d) => d.id == preset)) {
        _downloaderId = preset;
      } else if (downloaders.isNotEmpty) {
        _downloaderId = downloaders.first.id;
      }
    }

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: AppBackground(
        child: ColoredBox(
          color: appSurfaceColor(context, cs.background),
          child: Column(
            children: [
              SafeArea(
                bottom: false,
                child: Container(
                  padding: appHeaderPadding(context, left: 12, right: 8),
                  decoration: BoxDecoration(
                    color: appSurfaceColor(context, cs.background),
                    border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      IconButton.ghost(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.arrowLeft, size: 18),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          '下载器 RSS 管理',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (downloaders.isNotEmpty)
                        _DownloaderPicker(
                          downloaders: downloaders,
                          selectedId: _downloaderId,
                          onSelected: (id) => setState(() => _downloaderId = id),
                        ),
                    ],
                  ),
                ),
              ),
              if (_downloaderId != null)
                _buildToolbar()
              else
                Expanded(
                  child: Center(
                    child: Text(
                      '没有可用的 qBittorrent 下载器',
                      style: TextStyle(color: cs.mutedForeground),
                    ),
                  ),
                ),
              if (_downloaderId != null)
                Expanded(
                  child: EasyRefresh(
                    onRefresh: _refresh,
                    header: appRefreshHeader(context),
                    child: _buildBody(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    final id = _downloaderId;
    if (id == null) return;
    ref.invalidate(qbRssItemsProvider);
    ref.invalidate(qbRssRulesProvider);
    await ref.read(qbRssItemsProvider((downloaderId: id, withData: _withData)).future);
  }

  Widget _buildToolbar() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _ToolbarSwitch(
            label: '自动下载',
            value: _autoDownload,
            busy: _togglingAuto,
            onChanged: (v) => _toggleAutoDownload(v),
          ),
          _ToolbarSwitch(
            label: 'RSS 处理',
            value: _processing,
            busy: _togglingProcessing,
            onChanged: (v) => _toggleProcessing(v),
          ),
          Button.outline(
            onPressed: _showAddFeedDialog,
            child: const Text('添加源'),
          ),
          Button.outline(
            onPressed: _showAddFolderDialog,
            child: const Text('新建文件夹'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAutoDownload(bool v) async {
    final id = _downloaderId;
    if (id == null || _togglingAuto) return;
    setState(() => _togglingAuto = true);
    try {
      await RssService.qbSetAutoDownload(id, v);
      setState(() => _autoDownload = v);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _togglingAuto = false);
    }
  }

  Future<void> _toggleProcessing(bool v) async {
    final id = _downloaderId;
    if (id == null || _togglingProcessing) return;
    setState(() => _togglingProcessing = true);
    try {
      await RssService.qbSetProcessing(id, v);
      setState(() => _processing = v);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _togglingProcessing = false);
    }
  }

  Widget _buildBody() {
    final id = _downloaderId;
    if (id == null) return const SizedBox.shrink();
    final treeAsync = ref.watch(
      qbRssItemsProvider((downloaderId: id, withData: _withData)),
    );

    return treeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.circleAlert, size: 32, color: Theme.of(context).colorScheme.destructive),
            const SizedBox(height: 8),
            Text('$e', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Button.primary(
              onPressed: () => ref.invalidate(
                qbRssItemsProvider((downloaderId: id, withData: _withData)),
              ),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (tree) {
        if (tree.roots.isEmpty) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.rss,
                      size: 40,
                      color: Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text('暂无 RSS 数据', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      '点击上方「添加源」向 qBittorrent 添加 RSS 源',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          children: [
            for (final node in tree.roots) ...[
              _QbNodeTile(node: node, downloaderId: id, parentPath: ''),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 12),
            _RulesSection(downloaderId: id),
          ],
        );
      },
    );
  }

  void _showAddFeedDialog() {
    final id = _downloaderId;
    if (id == null) return;
    final urlCtrl = TextEditingController();
    final pathCtrl = TextEditingController();
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加 RSS 源'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShadTextField(controller: urlCtrl, labelText: 'RSS 地址', hintText: 'https://example.com/rss.xml'),
              const SizedBox(height: 12),
              ShadTextField(controller: pathCtrl, labelText: '文件夹路径', hintText: '例如：电影/华语'),
            ],
          ),
        ),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.primary(
            onPressed: () async {
              if (urlCtrl.text.trim().isEmpty || pathCtrl.text.trim().isEmpty) {
                Toast.error('请填写 RSS 地址和文件夹路径');
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await RssService.qbAddFeed(id, urlCtrl.text.trim(), pathCtrl.text.trim());
                Toast.success('RSS 源已添加');
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showAddFolderDialog() {
    final id = _downloaderId;
    if (id == null) return;
    final pathCtrl = TextEditingController();
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建 RSS 文件夹'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ShadTextField(controller: pathCtrl, labelText: '文件夹路径', hintText: '例如：电影'),
        ),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.primary(
            onPressed: () async {
              if (pathCtrl.text.trim().isEmpty) {
                Toast.error('请填写文件夹路径');
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await RssService.qbCreateFolder(id, pathCtrl.text.trim());
                Toast.success('文件夹已创建');
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}


class _ToolbarSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool busy;
  final ValueChanged<bool> onChanged;

  const _ToolbarSwitch({
    required this.label,
    required this.value,
    required this.busy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: value ? cs.primary.withValues(alpha: 0.08) : cs.muted.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? cs.primary.withValues(alpha: 0.25) : cs.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          if (busy)
            const SizedBox(
              width: 16,
              height: 16,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DownloaderPicker extends StatelessWidget {
  final List<Downloader> downloaders;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  const _DownloaderPicker({
    required this.downloaders,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = downloaders.where((d) => d.id == selectedId).fold<String?>(null, (_, d) => d.name);
    return Button.outline(
      onPressed: () => showPopover<void>(
        context: context,
        alignment: Alignment.bottomRight,
        anchorAlignment: Alignment.topRight,
        offset: const Offset(0, 4),
        consumeOutsideTaps: false,
        builder: (ctx) => DropdownMenu(
          children: [
            for (final d in downloaders)
              MenuButton(
                leading: Icon(
                  d.id == selectedId ? LucideIcons.check : LucideIcons.circle,
                  size: 14,
                ),
                onPressed: (_) {
                  onSelected(d.id);
                },
                child: Text(d.name),
              ),
          ],
        ),
      ),
      child: Text(selected ?? '选择下载器'),
    );
  }
}

// ─────────────────── 单个节点（文件夹 / 源） ───────────────────

class _QbNodeTile extends ConsumerStatefulWidget {
  final QbRssNode node;
  final int downloaderId;
  final String parentPath;

  const _QbNodeTile({
    required this.node,
    required this.downloaderId,
    required this.parentPath,
  });

  @override
  ConsumerState<_QbNodeTile> createState() => _QbNodeTileState();
}

class _QbNodeTileState extends ConsumerState<_QbNodeTile> {
  bool _expanded = false;

  String get _path => widget.parentPath.isEmpty
      ? widget.node.name
      : '${widget.parentPath}/${widget.node.name}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final node = widget.node;

    if (node.isFolder) {
      return AppSurfaceContainer(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Icon(
                    _expanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                    size: 16,
                    color: cs.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Icon(LucideIcons.folder, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      node.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${node.children.length} 项',
                    style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    for (final child in node.children) ...[
                      _QbNodeTile(
                        node: child,
                        downloaderId: widget.downloaderId,
                        parentPath: _path,
                      ),
                      const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    final feed = node.feed;
    return AppSurfaceContainer(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: feed == null || feed.articles.isEmpty
                ? null
                : () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Icon(
                  _expanded ? LucideIcons.chevronDown : LucideIcons.chevronRight,
                  size: 16,
                  color: cs.mutedForeground,
                ),
                const SizedBox(width: 6),
                Icon(
                  LucideIcons.rss,
                  size: 16,
                  color: feed?.hasError == true ? cs.destructive : cs.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        node.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                      if (feed != null && feed.url.isNotEmpty)
                        Text(
                          feed.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                        ),
                    ],
                  ),
                ),
                IconButton.ghost(
                  onPressed: () => _showMenu(context),
                  icon: const Icon(LucideIcons.ellipsis, size: 16),
                ),
              ],
            ),
          ),
          if (feed != null && feed.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 22),
              child: Text(
                '该源存在错误',
                style: TextStyle(fontSize: 11, color: cs.destructive),
              ),
            ),
          if (_expanded && feed != null && feed.articles.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: Column(
                children: [
                  for (final article in feed.articles.take(20)) ...[
                    _ArticleRow(article: article, downloaderId: widget.downloaderId, path: _path),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final node = widget.node;
    final id = widget.downloaderId;
    showPopover<void>(
      context: context,
      alignment: Alignment.bottomRight,
      anchorAlignment: Alignment.topRight,
      offset: const Offset(0, 4),
      consumeOutsideTaps: false,
      builder: (_) => DropdownMenu(
        children: [
          MenuButton(
            leading: const Icon(LucideIcons.refreshCw, size: 16),
            onPressed: (ctx) async {
              unawaited(closeOverlay(ctx));
              try {
                await RssService.qbRefreshItem(id, _path);
                Toast.success('已刷新');
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            child: const Text('刷新'),
          ),
          if (!node.isFolder)
            MenuButton(
              leading: const Icon(LucideIcons.pencil, size: 16),
              onPressed: (ctx) {
                unawaited(closeOverlay(ctx));
                _showEditFeedDialog();
              },
              child: const Text('修改地址'),
            ),
          const MenuDivider(),
          MenuButton(
            leading: Icon(LucideIcons.trash2, size: 16, color: Theme.of(context).colorScheme.destructive),
            onPressed: (ctx) {
              unawaited(closeOverlay(ctx));
              _confirmDelete();
            },
            child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.destructive)),
          ),
        ],
      ),
    );
  }

  void _showEditFeedDialog() {
    final node = widget.node;
    final id = widget.downloaderId;
    if (node.isFolder || node.feed == null) return;
    final urlCtrl = TextEditingController(text: node.feed!.url);
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改 RSS 地址'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ShadTextField(controller: urlCtrl, labelText: 'RSS 地址'),
        ),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.primary(
            onPressed: () async {
              if (urlCtrl.text.trim().isEmpty) {
                Toast.error('请填写 RSS 地址');
                return;
              }
              Navigator.of(ctx).pop();
              try {
                await RssService.qbUpdateFeed(id, urlCtrl.text.trim(), _path);
                Toast.success('地址已更新');
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final id = widget.downloaderId;
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「$_path」吗？'),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await RssService.qbRemoveItem(id, _path);
                Toast.success('已删除');
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _ArticleRow extends ConsumerWidget {
  final QbRssArticle article;
  final int downloaderId;
  final String path;

  const _ArticleRow({
    required this.article,
    required this.downloaderId,
    required this.path,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          article.isRead ? LucideIcons.mailOpen : LucideIcons.mail,
          size: 13,
          color: article.isRead ? cs.mutedForeground : cs.primary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: article.isRead ? FontWeight.w400 : FontWeight.w600,
                  color: article.isRead ? cs.mutedForeground : cs.foreground,
                ),
              ),
              if (article.date.isNotEmpty)
                Text(
                  article.date,
                  style: TextStyle(fontSize: 10.5, color: cs.mutedForeground),
                ),
            ],
          ),
        ),
        if (!article.isRead)
          IconButton.ghost(
            onPressed: () async {
              try {
                await RssService.qbMarkRead(downloaderId, path, article.id);
                ref.invalidate(qbRssItemsProvider);
              } catch (_) {}
            },
            icon: Icon(LucideIcons.check, size: 14, color: cs.mutedForeground),
          ),
      ],
    );
  }
}

// ─────────────────── 自动下载规则 ───────────────────

class _RulesSection extends ConsumerWidget {
  final int downloaderId;

  const _RulesSection({required this.downloaderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final rulesAsync = ref.watch(qbRssRulesProvider(downloaderId));

    return AppSurfaceContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.filter, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '自动下载规则',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton.ghost(
                onPressed: () => ref.invalidate(qbRssRulesProvider(downloaderId)),
                icon: const Icon(LucideIcons.refreshCw, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          rulesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (e, _) => Text('规则加载失败：$e', style: const TextStyle(fontSize: 12)),
            data: (rules) {
              if (rules.isEmpty) {
                return Text(
                  '暂无自动下载规则',
                  style: TextStyle(fontSize: 12.5, color: cs.mutedForeground),
                );
              }
              return Column(
                children: [
                  for (final rule in rules) ...[
                    _RuleTile(rule: rule, downloaderId: downloaderId),
                    const SizedBox(height: 6),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends ConsumerWidget {
  final QbRssRule rule;
  final int downloaderId;

  const _RuleTile({required this.rule, required this.downloaderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(
            rule.enabled ? LucideIcons.circleCheck : LucideIcons.circle,
            size: 15,
            color: rule.enabled ? cs.primary : cs.mutedForeground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  [
                    if (rule.mustContain.isNotEmpty) '包含 ${rule.mustContain}',
                    if (rule.mustNotContain.isNotEmpty) '排除 ${rule.mustNotContain}',
                    if (rule.affectedFeeds.isNotEmpty) '${rule.affectedFeeds.length} 个源',
                  ].join(' · ').isEmpty
                      ? '（无条件）'
                      : [
                          if (rule.mustContain.isNotEmpty) '包含 ${rule.mustContain}',
                          if (rule.mustNotContain.isNotEmpty) '排除 ${rule.mustNotContain}',
                          if (rule.affectedFeeds.isNotEmpty) '${rule.affectedFeeds.length} 个源',
                        ].join(' · '),
                  style: TextStyle(fontSize: 11, color: cs.mutedForeground),
                ),
              ],
            ),
          ),
          IconButton.ghost(
            onPressed: () => _confirmDelete(context, ref),
            icon: Icon(LucideIcons.trash2, size: 14, color: cs.destructive),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    appShowDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除规则「${rule.name}」吗？'),
        actions: [
          Button.outline(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')),
          Button.destructive(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await RssService.qbDeleteRule(downloaderId, rule.name);
                Toast.success('规则已删除');
                ref.invalidate(qbRssRulesProvider(downloaderId));
              } catch (_) {}
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
