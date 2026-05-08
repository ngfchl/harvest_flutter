import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/model/downloader_category.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart'
as download_providers;
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/torrent_action_menu.dart';
import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';
import '../provider/torrent_control_provider.dart';
import 'desktop_dialogs.dart';
import 'desktop_filter_item.dart';
import 'torrent_category_utils.dart';
import 'torrent_status_utils.dart';

class CollapsedDesktopSidebar extends StatelessWidget {
  final VoidCallback onExpand;

  const CollapsedDesktopSidebar({super.key, required this.onExpand});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      width: 42,
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(right: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: shadcn.Tooltip(
            tooltip: (_) => const Text('展开筛选栏'),
            child: shadcn.IconButton.ghost(
              onPressed: onExpand,
              icon: const Icon(shadcn.LucideIcons.panelLeftOpen, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopTorrentSidebar extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final VoidCallback onCollapse;

  const DesktopTorrentSidebar({
    super.key,
    required this.downloaderId,
    required this.downloaderType,
    required this.downloader,
    required this.onCollapse,
  });

  @override
  ConsumerState<DesktopTorrentSidebar> createState() =>
      _DesktopTorrentSidebarState();
}

class _DesktopTorrentSidebarState
    extends ConsumerState<DesktopTorrentSidebar> {
  late final TextEditingController _searchCtrl;
  final Set<String> _collapsedSections = {};
  static const List<String> _sectionIds = [
    'status',
    'category',
    'tag',
    'site',
  ];
  static const double _sectionBottomGap = 8;
  static const double _collapsedSectionHeight = 38;
  final Map<String, double> _sectionWeights = {
    'status': 1.25,
    'category': 1,
    'tag': 1,
    'site': 1,
  };

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(torrentSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final desktopStatus = ref.watch(desktopTorrentStatusFilterProvider);
    final category = ref.watch(torrentCategoryProvider);
    final tag = ref.watch(torrentTagProvider);
    final site = ref.watch(torrentSiteFilterProvider);
    final categories = ref.watch(
      availableCategoriesProvider(widget.downloaderId),
    );
    final tags = ref.watch(
      availableTagsProvider(widget.downloaderId),
    );
    final sites = ref.watch(
      availableTorrentSitesProvider(widget.downloaderId),
    );
    final downloader = widget.downloader;
    final isQb =
        widget.downloaderType == DownloaderType.qbittorrent;
    final allTorrents = ref
        .watch(torrentListProvider(widget.downloaderId))
        .valueOrNull
        ?.torrents ??
        const <Torrent>[];
    final statusCounts = desktopStatusCounts(allTorrents);

    final categoryCounts = <String, int>{};
    for (final torrent in allTorrents) {
      for (final label in torrentCategoryFilterLabels(torrent)) {
        categoryCounts[label] = (categoryCounts[label] ?? 0) + 1;
      }
    }
    final tagCounts = <String, int>{};
    for (final torrent in allTorrents) {
      for (final label in torrent.labels) {
        tagCounts[label] = (tagCounts[label] ?? 0) + 1;
      }
    }
    final matcher = ref.watch(torrentSiteMatcherProvider);
    final siteCounts = <String, int>{};
    for (final torrent in allTorrents) {
      final match = matcher.match(torrent);
      if (match != null) {
        siteCounts[match.key] = (siteCounts[match.key] ?? 0) + 1;
      }
    }

    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(
          right: BorderSide(color: cs.border, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                Text(
                  '筛选',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                shadcn.Tooltip(
                  tooltip: (_) => const Text('收起筛选栏'),
                  child: shadcn.IconButton.ghost(
                    onPressed: widget.onCollapse,
                    icon: const Icon(
                      shadcn.LucideIcons.panelLeftClose,
                      size: 15,
                    ),
                  ),
                ),
                shadcn.Button.ghost(
                  onPressed: _resetFilters,
                  child: const Text('重置'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: '搜索种子名称...',
                prefixIcon: Icon(shadcn.LucideIcons.search, size: 14),
              ),
              onChanged: (v) =>
              ref.read(torrentSearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sectionHeights =
                _resolvedSectionHeights(constraints.maxHeight);
                return Column(
                  children: [
                    DesktopResizableFilterSection(
                      title: '状态',
                      height: sectionHeights['status'] ?? 38,
                      collapsed: _isSectionCollapsed('status'),
                      onToggle: () => _toggleSection('status'),
                      onResize: (d) => _resizeSection('status', d),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          4,
                          10,
                          10,
                        ),
                        children: [
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.list,
                            label:
                            DesktopTorrentStatusFilter.all.label,
                            count: statusCounts[
                            DesktopTorrentStatusFilter.all] ??
                                0,
                            selected: desktopStatus ==
                                DesktopTorrentStatusFilter.all,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.all,
                            ),
                          ),
                          DesktopStatusGroup(
                            title: '活动中的',
                            icon: shadcn.LucideIcons.activity,
                            group: DesktopTorrentStatusFilter.active,
                            children: const [
                              DesktopTorrentStatusFilter
                                  .downloadingActive,
                              DesktopTorrentStatusFilter
                                  .uploadingActive,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          DesktopStatusGroup(
                            title: '暂停的',
                            icon: shadcn.LucideIcons.pause,
                            group: DesktopTorrentStatusFilter.paused,
                            children: const [
                              DesktopTorrentStatusFilter
                                  .pausedDownloading,
                              DesktopTorrentStatusFilter
                                  .pausedCompleted,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          DesktopStatusGroup(
                            title: '等待中',
                            icon: shadcn.LucideIcons.timer,
                            group: DesktopTorrentStatusFilter.waiting,
                            children: const [
                              DesktopTorrentStatusFilter
                                  .downloadWaiting,
                              DesktopTorrentStatusFilter.seedWaiting,
                              DesktopTorrentStatusFilter
                                  .stalledDownloading,
                              DesktopTorrentStatusFilter
                                  .stalledUploading,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.rotateCw,
                            label: DesktopTorrentStatusFilter
                                .checking.label,
                            count: statusCounts[
                            DesktopTorrentStatusFilter
                                .checking] ??
                                0,
                            selected: desktopStatus ==
                                DesktopTorrentStatusFilter.checking,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.checking,
                            ),
                          ),
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.clock,
                            label: DesktopTorrentStatusFilter
                                .checkWaiting.label,
                            count: statusCounts[
                            DesktopTorrentStatusFilter
                                .checkWaiting] ??
                                0,
                            selected: desktopStatus ==
                                DesktopTorrentStatusFilter
                                    .checkWaiting,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.checkWaiting,
                            ),
                          ),
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.check,
                            label: DesktopTorrentStatusFilter
                                .completed.label,
                            count: statusCounts[
                            DesktopTorrentStatusFilter
                                .completed] ??
                                0,
                            selected: desktopStatus ==
                                DesktopTorrentStatusFilter.completed,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.completed,
                            ),
                          ),
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.circleAlert,
                            label: DesktopTorrentStatusFilter
                                .error.label,
                            count: statusCounts[
                            DesktopTorrentStatusFilter.error] ??
                                0,
                            selected: desktopStatus ==
                                DesktopTorrentStatusFilter.error,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DesktopResizableFilterSection(
                      title: '分类',
                      height: sectionHeights['category'] ?? 38,
                      collapsed: _isSectionCollapsed('category'),
                      onToggle: () => _toggleSection('category'),
                      onResize: (d) =>
                          _resizeSection('category', d),
                      actions: isQb && downloader != null
                          ? [
                        DesktopFilterActionButton(
                          icon: shadcn.LucideIcons.plus,
                          tooltip: '新增分类',
                          onTap: () =>
                              _showCategoryEditor(downloader),
                        ),
                      ]
                          : const [],
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          4,
                          10,
                          10,
                        ),
                        children: [
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.folder,
                            label: '全部分类',
                            count: allTorrents.length,
                            selected: category.isEmpty,
                            onTap: () => ref
                                .read(
                              torrentCategoryProvider.notifier,
                            )
                                .state = '',
                          ),
                          ...desktopCategoryFilterItems(
                            categories: categories,
                            counts: categoryCounts,
                            selectedCategory: category,
                            tree: !isQb,
                            onSelect: (item) => ref
                                .read(
                              torrentCategoryProvider.notifier,
                            )
                                .state = item,
                            trailingActionsBuilder: (item) =>
                            isQb && downloader != null
                                ? [
                              DesktopInlineActionButton(
                                icon:
                                shadcn.LucideIcons.pencil,
                                tooltip: '编辑分类',
                                onTap: () =>
                                    _showCategoryEditor(
                                      downloader,
                                      categoryName: item,
                                    ),
                              ),
                              DesktopInlineActionButton(
                                icon:
                                shadcn.LucideIcons.trash2,
                                tooltip: '删除分类',
                                destructive: true,
                                onTap: () =>
                                    _confirmDeleteCategory(
                                      downloader,
                                      item,
                                    ),
                              ),
                            ]
                                : const [],
                          ),
                        ],
                      ),
                    ),
                    DesktopResizableFilterSection(
                      title: '标签',
                      height: sectionHeights['tag'] ?? 38,
                      collapsed: _isSectionCollapsed('tag'),
                      onToggle: () => _toggleSection('tag'),
                      onResize: (d) => _resizeSection('tag', d),
                      actions: isQb && downloader != null
                          ? [
                        DesktopFilterActionButton(
                          icon: shadcn.LucideIcons.plus,
                          tooltip: '新增标签',
                          onTap: () =>
                              _showTagEditor(downloader),
                        ),
                      ]
                          : const [],
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          4,
                          10,
                          10,
                        ),
                        children: [
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.tags,
                            label: '全部标签',
                            count: allTorrents.length,
                            selected: tag.isEmpty,
                            onTap: () => ref
                                .read(torrentTagProvider.notifier)
                                .state = '',
                          ),
                          for (final item in tags)
                            DesktopFilterItem(
                              icon: shadcn.LucideIcons.tag,
                              label: item,
                              count: tagCounts[item] ?? 0,
                              selected: tag == item,
                              onTap: () => ref
                                  .read(torrentTagProvider.notifier)
                                  .state = item,
                              trailingActions:
                              isQb && downloader != null
                                  ? [
                                DesktopInlineActionButton(
                                  icon: shadcn
                                      .LucideIcons.pencil,
                                  tooltip: '编辑标签',
                                  onTap: () =>
                                      _showTagEditor(
                                        downloader,
                                        oldTag: item,
                                      ),
                                ),
                                DesktopInlineActionButton(
                                  icon: shadcn
                                      .LucideIcons.trash2,
                                  tooltip: '删除标签',
                                  destructive: true,
                                  onTap: () =>
                                      _confirmDeleteTag(
                                        downloader,
                                        item,
                                      ),
                                ),
                              ]
                                  : const [],
                            ),
                        ],
                      ),
                    ),
                    DesktopResizableFilterSection(
                      title: '站点',
                      height: sectionHeights['site'] ?? 38,
                      collapsed: _isSectionCollapsed('site'),
                      onToggle: () => _toggleSection('site'),
                      onResize: (d) => _resizeSection('site', d),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          10,
                          4,
                          10,
                          10,
                        ),
                        children: [
                          DesktopFilterItem(
                            icon: shadcn.LucideIcons.globe,
                            label: '全部站点',
                            count: allTorrents.length,
                            selected: site.isEmpty,
                            onTap: () => ref
                                .read(
                              torrentSiteFilterProvider.notifier,
                            )
                                .state = '',
                          ),
                          for (final item in sites)
                            DesktopFilterItem(
                              icon: shadcn.LucideIcons.globe,
                              label: item.displayName,
                              count: siteCounts[item.key] ?? 0,
                              selected: site == item.key,
                              onTap: () => ref
                                  .read(
                                torrentSiteFilterProvider
                                    .notifier,
                              )
                                  .state = item.key,
                            ),
                        ],
                      ),
                    ),
                    if (_collapsedSections.length ==
                        _sectionIds.length)
                      const Spacer(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _resolvedSectionHeights(
      double availableHeight,
      ) {
    final expanded = _sectionIds
        .where((id) => !_isSectionCollapsed(id))
        .toList();
    final collapsed = _sectionIds
        .where((id) => _isSectionCollapsed(id))
        .toList();
    final heights = <String, double>{
      for (final id in collapsed) id: _collapsedSectionHeight,
    };

    if (expanded.isEmpty) return heights;

    final sectionArea =
    (availableHeight - _sectionIds.length * _sectionBottomGap)
        .clamp(0.0, double.infinity);
    final expandedArea =
    (sectionArea - collapsed.length * _collapsedSectionHeight)
        .clamp(0.0, double.infinity);
    final totalWeight = expanded.fold<double>(
      0,
          (sum, id) => sum + (_sectionWeights[id] ?? 1),
    );

    for (final id in expanded) {
      heights[id] =
          expandedArea * ((_sectionWeights[id] ?? 1) / totalWeight);
    }

    return heights;
  }

  bool _isSectionCollapsed(String id) =>
      _collapsedSections.contains(id);

  void _toggleSection(String id) {
    setState(() {
      _isSectionCollapsed(id)
          ? _collapsedSections.remove(id)
          : _collapsedSections.add(id);
    });
  }

  void _resizeSection(String id, double delta) {
    if (_isSectionCollapsed(id)) return;
    final expanded = _sectionIds
        .where((s) => !_isSectionCollapsed(s))
        .toList();
    if (expanded.length <= 1) return;
    final index = expanded.indexOf(id);
    if (index == -1) return;
    final neighbor = index < expanded.length - 1
        ? expanded[index + 1]
        : expanded[index - 1];
    const sensitivity = 180.0;
    final weightDelta = delta / sensitivity;
    setState(() {
      final current = _sectionWeights[id] ?? 1;
      final neighborWeight = _sectionWeights[neighbor] ?? 1;
      final next = (current + weightDelta).clamp(0.35, 4.0);
      _sectionWeights[id] = next;
      _sectionWeights[neighbor] =
          (neighborWeight - (next - current)).clamp(0.35, 4.0);
    });
  }

  void _setDesktopStatus(DesktopTorrentStatusFilter status) {
    ref.read(desktopTorrentStatusFilterProvider.notifier).state =
        status;
  }

  void _resetFilters() {
    _searchCtrl.clear();
    ref.read(torrentSearchProvider.notifier).state = '';
    ref.read(torrentFilterProvider.notifier).state =
        TorrentFilter.all;
    ref.read(desktopTorrentStatusFilterProvider.notifier).state =
        DesktopTorrentStatusFilter.all;
    ref.read(torrentCategoryProvider.notifier).state = '';
    ref.read(torrentTagProvider.notifier).state = '';
    ref.read(torrentSiteFilterProvider.notifier).state = '';
  }

  Future<void> _showCategoryEditor(
      Downloader downloader, {
        String? categoryName,
      }) async {
    final editing = categoryName != null;
    DownloaderCategory? category;
    if (editing) {
      final categories = await ref.read(
        download_providers
            .downloaderCategoriesProvider(downloader.id)
            .future,
      );
      for (final item in categories) {
        if (item.name == categoryName) {
          category = item;
          break;
        }
      }
    }
    if (!mounted) return;
    final nameCtrl =
    TextEditingController(text: categoryName ?? '');
    final pathCtrl =
    TextEditingController(text: category?.savePath ?? '');
    showDialog(
      context: context,
      builder: (ctx) => DesktopInputDialog(
        title: editing ? '编辑分类' : '新增分类',
        primaryLabel: '分类名称',
        primaryController: nameCtrl,
        primaryEnabled: !editing,
        secondaryLabel: '保存路径',
        secondaryController: pathCtrl,
        onSubmit: () async {
          final name = nameCtrl.text.trim();
          if (name.isEmpty) {
            Toast.warning('请输入分类名称');
            return;
          }
          try {
            if (editing) {
              await DownloaderService.editCategory(
                downloader.id,
                category: name,
                savePath: pathCtrl.text.trim(),
              );
            } else {
              await DownloaderService.createCategory(
                downloader.id,
                category: name,
                savePath: pathCtrl.text.trim(),
              );
            }
            ref.invalidate(
              download_providers
                  .downloaderCategoriesProvider(downloader.id),
            );
            unawaited(
              ref
                  .read(
                torrentListProvider(widget.downloaderId)
                    .notifier,
              )
                  .refresh(),
            );
            if (ctx.mounted) Navigator.pop(ctx);
            Toast.success(
              editing ? '分类已更新' : '分类已创建',
            );
          } catch (e, st) {
            AppLogger.error('保存 QB 分类失败', e, st);
            Toast.error('保存分类失败');
          }
        },
      ),
    );
  }

  void _confirmDeleteCategory(
      Downloader downloader,
      String category,
      ) {
    showDesktopConfirmDialog(
      context,
      title: '删除分类',
      message: '确定删除「$category」吗？不会删除种子文件。',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteCategory(
            downloader.id,
            category,
          );
          ref.invalidate(
            download_providers
                .downloaderCategoriesProvider(downloader.id),
          );
          if (ref.read(torrentCategoryProvider) == category) {
            ref.read(torrentCategoryProvider.notifier).state = '';
          }
          unawaited(
            ref
                .read(
              torrentListProvider(widget.downloaderId).notifier,
            )
                .refresh(),
          );
          Toast.success('分类已删除');
        } catch (e, st) {
          AppLogger.error('删除 QB 分类失败', e, st);
          Toast.error('删除分类失败');
        }
      },
    );
  }

  void _showTagEditor(Downloader downloader, {String? oldTag}) {
    final editing = oldTag != null;
    final tagCtrl = TextEditingController(text: oldTag ?? '');
    showDialog(
      context: context,
      builder: (ctx) => DesktopInputDialog(
        title: editing ? '编辑标签' : '新增标签',
        primaryLabel: '标签名称',
        primaryController: tagCtrl,
        onSubmit: () async {
          final tag = tagCtrl.text.trim();
          if (tag.isEmpty) {
            Toast.warning('请输入标签名称');
            return;
          }
          try {
            if (editing && oldTag != tag) {
              await _replaceTag(downloader, oldTag, tag);
            } else if (!editing) {
              await DownloaderService.createTag(downloader.id, tag);
            }
            ref.invalidate(
              download_providers
                  .downloaderTagsProvider(downloader.id),
            );
            if (ref.read(torrentTagProvider) == oldTag) {
              ref.read(torrentTagProvider.notifier).state = tag;
            }
            unawaited(
              ref
                  .read(
                torrentListProvider(widget.downloaderId)
                    .notifier,
              )
                  .refresh(),
            );
            if (ctx.mounted) Navigator.pop(ctx);
            Toast.success(
              editing ? '标签已更新' : '标签已创建',
            );
          } catch (e, st) {
            AppLogger.error('保存 QB 标签失败', e, st);
            Toast.error('保存标签失败');
          }
        },
      ),
    );
  }

  Future<void> _replaceTag(
      Downloader downloader,
      String oldTag,
      String newTag,
      ) async {
    await DownloaderService.createTag(downloader.id, newTag);
    final torrents = ref
        .read(torrentListProvider(widget.downloaderId))
        .valueOrNull
        ?.torrents ??
        const <Torrent>[];
    final hashes = torrents
        .where((t) => t.labels.contains(oldTag))
        .map((t) => t.hashString)
        .where((h) => h.isNotEmpty)
        .toList();
    if (hashes.isNotEmpty) {
      await executeTorrentAction(
        ref: ref,
        downloaderId: widget.downloaderId,
        action: 'add_tags',
        params: {
          'hashes': hashes,
          'tags': [newTag],
        },
      );
    }
    await DownloaderService.deleteTag(downloader.id, oldTag);
  }

  void _confirmDeleteTag(Downloader downloader, String tag) {
    showDesktopConfirmDialog(
      context,
      title: '删除标签',
      message: '确定删除「$tag」吗？',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteTag(downloader.id, tag);
          ref.invalidate(
            download_providers
                .downloaderTagsProvider(downloader.id),
          );
          if (ref.read(torrentTagProvider) == tag) {
            ref.read(torrentTagProvider.notifier).state = '';
          }
          unawaited(
            ref
                .read(
              torrentListProvider(widget.downloaderId)
                  .notifier,
            )
                .refresh(),
          );
          Toast.success('标签已删除');
        } catch (e, st) {
          AppLogger.error('删除 QB 标签失败', e, st);
          Toast.error('删除标签失败');
        }
      },
    );
  }
}
