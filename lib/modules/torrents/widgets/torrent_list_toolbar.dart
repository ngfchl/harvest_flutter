import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../download/model/downloader.dart';
import '../model/torrent_model.dart';
import '../provider/downloader_provider.dart';

class TorrentListToolbar extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;

  const TorrentListToolbar({super.key, required this.downloaderId, required this.downloaderType});

  @override
  ConsumerState<TorrentListToolbar> createState() => _TorrentListToolbarState();
}

class _TorrentListToolbarState extends ConsumerState<TorrentListToolbar> {
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: Row(
          children: [
            Expanded(child: _showSearch ? _buildSearchField(context) : const SizedBox.shrink()),
            _ToolBtn(
              icon: _showSearch ? shadcn.LucideIcons.x : shadcn.LucideIcons.search,
              active: _showSearch,
              onTap: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  ref.read(torrentSearchProvider.notifier).state = '';
                }
              }),
            ),
            _ToolBtn(
              icon: shadcn.LucideIcons.listFilter,
              active: _hasActiveFilter(),
              onTap: () => _showFilterPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: shadcn.TextField(
        controller: _searchCtrl,
        hintText: "",
        onChanged: (v) => ref.read(torrentSearchProvider.notifier).state = v,
      ),
    );
  }

  bool _hasActiveFilter() {
    return ref.watch(torrentFilterProvider) != TorrentFilter.all ||
        ref.watch(torrentCategoryProvider).isNotEmpty ||
        ref.watch(torrentSiteFilterProvider).isNotEmpty ||
        ref.watch(torrentTagProvider).isNotEmpty ||
        ref.watch(torrentSortProvider) != TorrentSort.queuePosition ||
        !ref.watch(torrentSortAscProvider);
  }

  void _showFilterPicker(BuildContext context) {
    final categories = ref.read(availableCategoriesProvider(widget.downloaderId));
    final tags = ref.read(availableTagsProvider(widget.downloaderId));
    final sites = ref.read(availableTorrentSitesProvider(widget.downloaderId));
    var currentStatus = ref.read(torrentFilterProvider);
    var currentCat = ref.read(torrentCategoryProvider);
    var currentTag = ref.read(torrentTagProvider);
    var currentSite = ref.read(torrentSiteFilterProvider);
    var currentSort = ref.read(torrentSortProvider);
    var sortAsc = ref.read(torrentSortAscProvider);

    showAppSheet(
      context: context,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final cs = shadcn.Theme.of(sheetContext).colorScheme;

          void resetFilters() {
            setSheetState(() {
              currentStatus = TorrentFilter.all;
              currentCat = '';
              currentTag = '';
              currentSite = '';
              currentSort = TorrentSort.queuePosition;
              sortAsc = true;
            });
            ref.read(torrentFilterProvider.notifier).state = TorrentFilter.all;
            ref.read(torrentCategoryProvider.notifier).state = '';
            ref.read(torrentTagProvider.notifier).state = '';
            ref.read(torrentSiteFilterProvider.notifier).state = '';
            ref.read(torrentSortProvider.notifier).state = TorrentSort.queuePosition;
            ref.read(torrentSortAscProvider.notifier).state = true;
          }

          return ColoredBox(
            color: cs.background,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sheetHeader(sheetContext, onReset: resetFilters, onClose: () => closeAppSheet(sheetContext)),
                    _chipSection(
                      sheetContext,
                      title: '排序',
                      children: [
                        for (final sort in TorrentSort.values)
                          _sheetChoiceChip(
                            sheetContext,
                            label: sort.label,
                            selected: sort == currentSort,
                            selectedIcon: sortAsc ? shadcn.LucideIcons.arrowUp : shadcn.LucideIcons.arrowDown,
                            onTap: () {
                              setSheetState(() {
                                if (sort == currentSort) {
                                  sortAsc = !sortAsc;
                                } else {
                                  currentSort = sort;
                                  sortAsc = true;
                                }
                              });
                              ref.read(torrentSortProvider.notifier).state = sort;
                              ref.read(torrentSortAscProvider.notifier).state = sortAsc;
                            },
                          ),
                      ],
                    ),
                    _chipSection(
                      sheetContext,
                      title: '状态',
                      children: [
                        for (final filter in TorrentFilter.values)
                          _sheetChoiceChip(
                            sheetContext,
                            label: filter.label,
                            selected: filter == currentStatus,
                            onTap: () {
                              setSheetState(() => currentStatus = filter);
                              ref.read(torrentFilterProvider.notifier).state = filter;
                            },
                          ),
                      ],
                    ),
                    if (categories.isNotEmpty)
                      _chipSection(
                        sheetContext,
                        title: '分类',
                        children: [
                          _sheetChoiceChip(
                            sheetContext,
                            label: '全部',
                            selected: currentCat.isEmpty,
                            onTap: () {
                              setSheetState(() => currentCat = '');
                              ref.read(torrentCategoryProvider.notifier).state = '';
                            },
                          ),
                          for (final category in categories)
                            _sheetChoiceChip(
                              sheetContext,
                              label: category,
                              selected: currentCat == category,
                              onTap: () {
                                setSheetState(() => currentCat = category);
                                ref.read(torrentCategoryProvider.notifier).state = category;
                              },
                            ),
                        ],
                      ),
                    if (sites.isNotEmpty)
                      _chipSection(
                        sheetContext,
                        title: '站点',
                        children: [
                          _sheetChoiceChip(
                            sheetContext,
                            label: '全部',
                            selected: currentSite.isEmpty,
                            onTap: () {
                              setSheetState(() => currentSite = '');
                              ref.read(torrentSiteFilterProvider.notifier).state = '';
                            },
                          ),
                          for (final site in sites)
                            _sheetChoiceChip(
                              sheetContext,
                              label: site.displayName,
                              selected: currentSite == site.key,
                              onTap: () {
                                setSheetState(() => currentSite = site.key);
                                ref.read(torrentSiteFilterProvider.notifier).state = site.key;
                              },
                            ),
                        ],
                      ),
                    if (tags.isNotEmpty)
                      _chipSection(
                        sheetContext,
                        title: '标签',
                        children: [
                          _sheetChoiceChip(
                            sheetContext,
                            label: '全部',
                            selected: currentTag.isEmpty,
                            onTap: () {
                              setSheetState(() => currentTag = '');
                              ref.read(torrentTagProvider.notifier).state = '';
                            },
                          ),
                          for (final tag in tags)
                            _sheetChoiceChip(
                              sheetContext,
                              label: tag,
                              selected: currentTag == tag,
                              onTap: () {
                                setSheetState(() => currentTag = tag);
                                ref.read(torrentTagProvider.notifier).state = tag;
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetHeader(BuildContext context, {required VoidCallback onReset, required VoidCallback onClose}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.foreground.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '筛选与排序',
            style: TextStyle(color: cs.foreground, fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          shadcn.Button.ghost(onPressed: onReset, child: const Text('重置')),
          shadcn.IconButton.ghost(onPressed: onClose, icon: const Icon(shadcn.LucideIcons.x, size: 16)),
        ],
      ),
    );
  }

  Widget _chipSection(BuildContext context, {required String title, required List<Widget> children}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: cs.mutedForeground, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }

  Widget _sheetChoiceChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData selectedIcon = shadcn.LucideIcons.check,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width - 48),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.12) : cs.foreground.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? cs.primary : cs.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[Icon(selectedIcon, size: 13, color: cs.primary), const SizedBox(width: 5)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? cs.primary : cs.foreground,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ToolBtn({required this.icon, this.active = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: active ? cs.primary : cs.mutedForeground),
      ),
    );
  }
}
