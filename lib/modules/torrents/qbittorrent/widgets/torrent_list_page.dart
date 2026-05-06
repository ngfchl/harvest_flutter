import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart'
    as download_providers;
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/download/widgets/downloader_speed_setting.dart';
import 'package:harvest/modules/download/widgets/qb_category_tag_manager.dart';
import 'package:harvest/modules/download/widgets/qb_settings_dialog.dart';
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:harvest/modules/download/widgets/tr_settings_dialog.dart';
import 'package:harvest/modules/shell/widgets/shell_scaffold.dart';
import 'package:harvest/widgets/escape_back_scope.dart';

import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import '../provider/downloader_provider.dart';
import '../provider/torrent_control_provider.dart';
import 'torrent_action_menu.dart';
import 'torrent_detail_sheet.dart';

// ══════════════════════════════════════════════════════════
//  状态颜色（语义色，不跟主题走）
// ══════════════════════════════════════════════════════════

const _colorDownloading = Color(0xFF60A5FA);
const _colorSeeding = Color(0xFF4ADE80);
const _colorWaiting = Color(0xFFFBBF24);
const _colorStopped = Color(0xFF9CA3AF);
const _colorError = Color(0xFFEF4444);

Color _statusColor(TorrentStatus s, bool hasError) {
  if (hasError) return _colorError;
  return switch (s) {
    TorrentStatus.downloading ||
    TorrentStatus.downloadWait => _colorDownloading,
    TorrentStatus.seeding || TorrentStatus.seedWait => _colorSeeding,
    TorrentStatus.checking || TorrentStatus.checkWait => _colorWaiting,
    TorrentStatus.stopped => _colorStopped,
  };
}

// ══════════════════════════════════════════════════════════
//  主页面
// ══════════════════════════════════════════════════════════

class TorrentListPage extends ConsumerStatefulWidget {
  final int downloaderId;
  final String? downloaderName;
  final DownloaderType downloaderType; // 新增

  const TorrentListPage({
    super.key,
    required this.downloaderId,
    this.downloaderName,
    required this.downloaderType,
  });

  @override
  ConsumerState<TorrentListPage> createState() => _TorrentListPageState();
}

class _TorrentListPageState extends ConsumerState<TorrentListPage> {
  Timer? _refreshTimer;
  Timer? _autoStopTimer;
  Timer? _countdownTimer;
  TorrentListNotifier? _torrentNotifier;
  final List<ProviderSubscription<Object?>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      ref.listenManual<int>(
        speedIntervalProvider,
        (_, __) => _restartAutoRefresh(),
      ),
      ref.listenManual<int>(
        speedDurationProvider,
        (_, __) => _restartAutoRefresh(),
      ),
      ref.listenManual<bool>(
        speedEnabledProvider,
        (_, __) => _syncTorrentRefreshState(),
      ),
      ref.listenManual<bool>(
        torrentRefreshPausedProvider(widget.downloaderId),
        (_, __) => _syncTorrentRefreshState(),
      ),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(
        torrentListProvider(widget.downloaderId).notifier,
      );
      _torrentNotifier = notifier;
      notifier.setWsPaused(
        ref.read(torrentRefreshPausedProvider(widget.downloaderId)),
      );
      _restartAutoRefresh();
    });
  }

  @override
  void dispose() {
    _cancelAutoRefreshTimers();
    _torrentNotifier?.setWsPaused(true);
    _torrentNotifier = null;
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCount = ref
        .watch(filteredTorrentsProvider(widget.downloaderId))
        .length;
    final downloader = _findCurrentDownloader(
      ref.watch(download_providers.downloaderListProvider).valueOrNull,
    );

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: Text(widget.downloaderName ?? '种子管理'),
          prefixes: [
            FHeaderAction(
              icon: const Icon(FIcons.chevronLeft),
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
          suffixes: [
            _DownloaderHeaderMenu(
              downloaderType: widget.downloaderType,
              downloader: downloader,
              currentCount: currentCount,
              onRefresh: _refreshTorrentList,
              onStart: () => _runBatchAction(
                label: '开始',
                qbAction: 'resume',
                trAction: 'start_torrent',
              ),
              onPause: () => _runBatchAction(
                label: '暂停',
                qbAction: 'pause',
                trAction: 'stop_torrent',
              ),
              onReannounce: () => _runBatchAction(
                label: '重新汇报',
                qbAction: 'reannounce',
                trAction: 'reannounce_torrent',
              ),
              onRecheck: _confirmRecheckCurrentList,
              onCategoryManagement: downloader == null
                  ? null
                  : () => _showQbCategoryManager(downloader),
              onTagManagement: downloader == null
                  ? null
                  : () => _showQbTagManager(downloader),
              onSpeedLimitSettings: downloader == null
                  ? null
                  : () => _showDownloaderSpeedLimitSettings(downloader),
              onReplaceTrackers:
                  widget.downloaderType == DownloaderType.qbittorrent
                  ? () => _showTrackerReplaceDialogForDownloader(
                      context,
                      ref,
                      widget.downloaderId,
                    )
                  : null,
            ),
          ],
        ),
        child: Column(
          children: [
            _Toolbar(
              downloaderId: widget.downloaderId,
              downloaderType: widget.downloaderType,
            ),
            _TorrentRefreshBar(
              downloaderId: widget.downloaderId,
              onRefresh: _refreshTorrentList,
            ),
            _StatsBar(downloaderId: widget.downloaderId),
            Expanded(
              child: _TorrentList(
                widget.downloaderType,
                downloaderId: widget.downloaderId,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Torrent> _currentActionTorrents() {
    return ref.read(filteredTorrentsProvider(widget.downloaderId));
  }

  List<String> _currentActionIds() {
    return _currentActionTorrents()
        .map((torrent) => torrent.hashString)
        .where((hash) => hash.isNotEmpty)
        .toList();
  }

  void _syncTorrentRefreshState() {
    if (!mounted) return;
    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(widget.downloaderId));
    ref
        .read(torrentListProvider(widget.downloaderId).notifier)
        .setWsPaused(!enabled || paused);
    _restartAutoRefresh();
  }

  void _refreshTorrentList() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(widget.downloaderId).notifier).refresh(),
    );
    Toast.success('已刷新列表');
  }

  void _refreshTorrentListSilently() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(widget.downloaderId).notifier).refresh(),
    );
  }

  void _restartAutoRefresh() {
    _stopAutoRefresh(resetRemaining: false);
    if (!mounted) return;

    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(widget.downloaderId));
    if (!enabled || paused) {
      ref
              .read(
                torrentRefreshRemainingProvider(widget.downloaderId).notifier,
              )
              .state =
          0;
      return;
    }

    final interval = ref.read(speedIntervalProvider);
    final duration = ref.read(speedDurationProvider);
    final totalSeconds = duration * 60;
    ref
            .read(torrentRefreshRemainingProvider(widget.downloaderId).notifier)
            .state =
        totalSeconds;

    _refreshTimer = Timer.periodic(Duration(seconds: interval), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _refreshTorrentListSilently();
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = ref.read(
        torrentRefreshRemainingProvider(widget.downloaderId),
      );
      if (remaining <= 0) {
        timer.cancel();
        return;
      }
      ref
              .read(
                torrentRefreshRemainingProvider(widget.downloaderId).notifier,
              )
              .state =
          remaining - 1;
    });

    _autoStopTimer = Timer(Duration(seconds: totalSeconds), () {
      if (!mounted) return;
      _stopAutoRefresh(resetRemaining: true);
      ref
              .read(torrentRefreshPausedProvider(widget.downloaderId).notifier)
              .state =
          true;
    });
  }

  void _stopAutoRefresh({required bool resetRemaining}) {
    _cancelAutoRefreshTimers();
    if (resetRemaining && mounted) {
      ref
              .read(
                torrentRefreshRemainingProvider(widget.downloaderId).notifier,
              )
              .state =
          0;
    }
  }

  void _cancelAutoRefreshTimers() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _autoStopTimer?.cancel();
    _autoStopTimer = null;
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  Downloader? _findCurrentDownloader(List<Downloader>? downloaders) {
    if (downloaders == null) return null;
    for (final downloader in downloaders) {
      if (downloader.id == widget.downloaderId) return downloader;
    }
    return null;
  }

  void _showQbCategoryManager(Downloader downloader) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      builder: (_) => QbCategoryManagerSheet(downloader: downloader),
    );
  }

  void _showQbTagManager(Downloader downloader) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      builder: (_) => QbTagManagerSheet(downloader: downloader),
    );
  }

  void _showDownloaderSpeedLimitSettings(Downloader downloader) {
    showDialog(
      context: context,
      builder: (_) => downloader.isQb
          ? QbSettingsDialog(downloader: downloader, initialIndex: 3)
          : TrSettingsDialog(downloader: downloader, initialIndex: 1),
    );
  }

  Future<void> _runBatchAction({
    required String label,
    required String qbAction,
    required String trAction,
  }) async {
    final ids = _currentActionIds();
    if (ids.isEmpty) {
      Toast.info('当前列表没有可操作种子');
      return;
    }

    final isQb = widget.downloaderType == DownloaderType.qbittorrent;
    final success = await executeTorrentAction(
      ref: ref,
      downloaderId: widget.downloaderId,
      action: isQb ? qbAction : trAction,
      params: isQb ? {'hashes': ids} : {'ids': ids},
    );
    if (!mounted) return;
    if (success) {
      ref.read(torrentListProvider(widget.downloaderId).notifier).refresh();
    }
    if (success) {
      Toast.success('$label已提交');
    } else {
      Toast.error('$label失败');
    }
  }

  void _confirmRecheckCurrentList() {
    final count = _currentActionIds().length;
    if (count == 0) {
      Toast.info('当前列表没有可操作种子');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = FTheme.of(ctx).colors;
        return Dialog(
          backgroundColor: cs.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '重新校验',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '将对当前列表 $count 个种子执行重新校验。',
                  style: TextStyle(color: cs.mutedForeground, fontSize: 13),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      style: FButtonStyle.ghost(),
                      onPress: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    FButton(
                      onPress: () {
                        Navigator.pop(ctx);
                        _runBatchAction(
                          label: '重新校验',
                          qbAction: 'recheck',
                          trAction: 'verify_torrent',
                        );
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  工具栏（搜索 + 状态 + 排序 + 分类/标签）
// ══════════════════════════════════════════════════════════

class _Toolbar extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;

  const _Toolbar({required this.downloaderId, required this.downloaderType});

  @override
  ConsumerState<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends ConsumerState<_Toolbar> {
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 搜索 + 筛选入口 ──
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 6),
            child: Row(
              children: [
                Expanded(
                  child: _showSearch
                      ? _buildSearchField(context)
                      : const SizedBox.shrink(),
                ),
                _ToolBtn(
                  icon: _showSearch ? FIcons.x : FIcons.search,
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
                  icon: FIcons.listFilter,
                  active: _hasActiveFilter(),
                  onTap: () => _showFilterPicker(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 搜索输入框 ──
  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: FTextField(
        controller: _searchCtrl,
        hint: '搜索种子名称...',
        onChange: (v) => ref.read(torrentSearchProvider.notifier).state = v,
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

  // ── 筛选选择器 ──
  void _showFilterPicker(BuildContext context) {
    final categories = ref.read(
      availableCategoriesProvider(widget.downloaderId),
    );
    final tags = ref.read(availableTagsProvider(widget.downloaderId));
    final sites = ref.read(availableTorrentSitesProvider(widget.downloaderId));
    var currentStatus = ref.read(torrentFilterProvider);
    var currentCat = ref.read(torrentCategoryProvider);
    var currentTag = ref.read(torrentTagProvider);
    var currentSite = ref.read(torrentSiteFilterProvider);
    var currentSort = ref.read(torrentSortProvider);
    var sortAsc = ref.read(torrentSortAscProvider);

    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final cs = FTheme.of(sheetContext).colors;

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
            ref.read(torrentSortProvider.notifier).state =
                TorrentSort.queuePosition;
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
                    _sheetHeader(
                      sheetContext,
                      onReset: resetFilters,
                      onClose: () => Navigator.pop(sheetContext),
                    ),
                    _chipSection(
                      sheetContext,
                      title: '排序',
                      children: [
                        for (final sort in TorrentSort.values)
                          _sheetChoiceChip(
                            sheetContext,
                            label: sort.label,
                            selected: sort == currentSort,
                            selectedIcon: sortAsc
                                ? FIcons.arrowUp
                                : FIcons.arrowDown,
                            onTap: () {
                              setSheetState(() {
                                if (sort == currentSort) {
                                  sortAsc = !sortAsc;
                                } else {
                                  currentSort = sort;
                                  sortAsc = true;
                                }
                              });
                              ref.read(torrentSortProvider.notifier).state =
                                  sort;
                              ref.read(torrentSortAscProvider.notifier).state =
                                  sortAsc;
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
                              ref.read(torrentFilterProvider.notifier).state =
                                  filter;
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
                              ref.read(torrentCategoryProvider.notifier).state =
                                  '';
                            },
                          ),
                          for (final category in categories)
                            _sheetChoiceChip(
                              sheetContext,
                              label: category,
                              selected: currentCat == category,
                              onTap: () {
                                setSheetState(() => currentCat = category);
                                ref
                                        .read(torrentCategoryProvider.notifier)
                                        .state =
                                    category;
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
                              ref
                                      .read(torrentSiteFilterProvider.notifier)
                                      .state =
                                  '';
                            },
                          ),
                          for (final site in sites)
                            _sheetChoiceChip(
                              sheetContext,
                              label: site.displayName,
                              selected: currentSite == site.key,
                              onTap: () {
                                setSheetState(() => currentSite = site.key);
                                ref
                                    .read(torrentSiteFilterProvider.notifier)
                                    .state = site
                                    .key;
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
                                ref.read(torrentTagProvider.notifier).state =
                                    tag;
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

  Widget _sheetHeader(
    BuildContext context, {
    required VoidCallback onReset,
    required VoidCallback onClose,
  }) {
    final cs = FTheme.of(context).colors;
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
            style: TextStyle(
              color: cs.foreground,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          FButton(
            style: FButtonStyle.ghost(),
            onPress: onReset,
            child: const Text('重置'),
          ),
          FButton.icon(
            style: FButtonStyle.ghost(),
            onPress: onClose,
            child: const Icon(FIcons.x, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _chipSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final cs = FTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.mutedForeground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
    IconData selectedIcon = FIcons.check,
  }) {
    final cs = FTheme.of(context).colors;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 48,
      ),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.12)
                : cs.foreground.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? cs.primary : cs.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(selectedIcon, size: 13, color: cs.primary),
                const SizedBox(width: 5),
              ],
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

// ── 工具栏按钮 ──

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _ToolBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: active ? cs.primary : cs.foreground.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _DownloaderHeaderMenu extends StatelessWidget {
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final int currentCount;
  final VoidCallback onRefresh;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReannounce;
  final VoidCallback onRecheck;
  final VoidCallback? onCategoryManagement;
  final VoidCallback? onTagManagement;
  final VoidCallback? onSpeedLimitSettings;
  final VoidCallback? onReplaceTrackers;

  const _DownloaderHeaderMenu({
    required this.downloaderType,
    required this.downloader,
    required this.currentCount,
    required this.onRefresh,
    required this.onStart,
    required this.onPause,
    required this.onReannounce,
    required this.onRecheck,
    required this.onCategoryManagement,
    required this.onTagManagement,
    required this.onSpeedLimitSettings,
    this.onReplaceTrackers,
  });

  @override
  Widget build(BuildContext context) {
    final anchorContext = context;
    final isQb = downloaderType == DownloaderType.qbittorrent;

    return FPopoverMenu.tiles(
      style: fPopoverMenuStyle(context, maxWidth: 230).call,
      spacing: FPortalSpacing.zero,
      maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      menuAnchor: Alignment.topRight,
      childAnchor: Alignment.bottomRight,
      menuBuilder: (_, controller, _) => [
        FTileGroup(
          label: Text('当前列表 $currentCount 个种子'),
          children: [
            _buildMenuTile(
              anchorContext,
              controller,
              icon: FIcons.refreshCw,
              label: '刷新列表',
              onTap: onRefresh,
            ),
          ],
        ),
        FTileGroup(
          children: [
            _buildMenuTile(
              anchorContext,
              controller,
              icon: FIcons.play,
              label: '开始当前列表',
              enabled: currentCount > 0,
              onTap: onStart,
            ),
            _buildMenuTile(
              anchorContext,
              controller,
              icon: FIcons.pause,
              label: '暂停当前列表',
              enabled: currentCount > 0,
              onTap: onPause,
            ),
            _buildMenuTile(
              anchorContext,
              controller,
              icon: Icons.campaign_outlined,
              label: '重新汇报当前列表',
              enabled: currentCount > 0,
              onTap: onReannounce,
            ),
            _buildMenuTile(
              anchorContext,
              controller,
              icon: Icons.fact_check_outlined,
              label: '重新校验当前列表',
              enabled: currentCount > 0,
              onTap: onRecheck,
            ),
          ],
        ),
        FTileGroup(
          label: const Text('下载器'),
          children: [
            _buildMenuTile(
              anchorContext,
              controller,
              icon: FIcons.gauge,
              label: '限速设置',
              enabled: downloader != null,
              onTap: onSpeedLimitSettings,
            ),
          ],
        ),
        if (isQb)
          FTileGroup(
            label: const Text('QBittorrent'),
            children: [
              _buildMenuTile(
                anchorContext,
                controller,
                icon: FIcons.tags,
                label: '分类管理',
                enabled: downloader != null,
                onTap: onCategoryManagement,
              ),
              _buildMenuTile(
                anchorContext,
                controller,
                icon: FIcons.tag,
                label: '标签管理',
                enabled: downloader != null,
                onTap: onTagManagement,
              ),
              _buildMenuTile(
                anchorContext,
                controller,
                icon: FIcons.replace,
                label: '按站点批量替换 Tracker',
                onTap: onReplaceTrackers,
              ),
            ],
          ),
      ],
      builder: (_, controller, _) => FHeaderAction(
        icon: const Icon(FIcons.ellipsisVertical),
        onPress: () => controller.toggle(),
      ),
    );
  }

  FTile _buildMenuTile(
    BuildContext context,
    FPopoverController controller, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    final active = enabled && onTap != null;
    return FTile(
      prefix: Icon(icon, size: 14),
      title: Text(label),
      onPress: active
          ? () async {
              await controller.hide();
              if (!context.mounted) return;
              onTap();
            }
          : null,
    );
  }
}

void _showTrackerReplaceDialogForDownloader(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
) {
  final sites = ref.read(availableTorrentSitesProvider(downloaderId));
  final selectedSite = ref.read(torrentSiteFilterProvider);
  final siteKeys = sites.map((site) => site.key).toSet();
  final initialSite = selectedSite.isNotEmpty && siteKeys.contains(selectedSite)
      ? selectedSite
      : (sites.isNotEmpty ? sites.first.key : '');
  if (initialSite.isEmpty) {
    Toast.info('暂无可识别站点');
    return;
  }

  var siteKey = initialSite;
  final siteNameByKey = {for (final site in sites) site.key: site.displayName};
  var defaultTracker = _randomTrackerForSite(ref, downloaderId, siteKey);
  final trackerCtrl = TextEditingController(text: defaultTracker);

  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          final count = _torrentHashesForSite(
            ref,
            downloaderId,
            siteKey,
          ).length;
          return Dialog(
            backgroundColor: cs.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '批量替换 Tracker',
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '按已识别站点匹配种子，替换该站点下全部种子的 tracker。',
                    style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  FSelect<String>(
                    label: const Text('站点'),
                    initialValue: siteKey,
                    hint: '选择站点',
                    format: (value) => siteNameByKey[value] ?? value,
                    onChange: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        siteKey = value;
                        defaultTracker = _randomTrackerForSite(
                          ref,
                          downloaderId,
                          siteKey,
                        );
                        trackerCtrl.text = defaultTracker;
                        trackerCtrl.selection = TextSelection.collapsed(
                          offset: trackerCtrl.text.length,
                        );
                      });
                    },
                    children: [
                      for (final site in sites)
                        FSelectItem<String>(site.displayName, site.key),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FTextField(
                    controller: trackerCtrl,
                    label: const Text('新 Tracker'),
                    hint: 'https://tracker.example.com/announce',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    defaultTracker.isEmpty
                        ? '将处理 $count 个种子，暂无可用默认 Tracker'
                        : '将处理 $count 个种子，默认取自该站点随机种子',
                    style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FButton(
                        style: FButtonStyle.ghost(),
                        onPress: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      FButton(
                        onPress: count == 0
                            ? null
                            : () async {
                                final tracker = trackerCtrl.text.trim();
                                if (tracker.isEmpty) {
                                  Toast.warning('请输入新 Tracker');
                                  return;
                                }
                                try {
                                  await DownloaderService.replaceTrackers(
                                    downloaderId,
                                    torrentHashes: _torrentHashesForSite(
                                      ref,
                                      downloaderId,
                                      siteKey,
                                    ),
                                    newTracker: tracker,
                                  );
                                  ref
                                      .read(
                                        torrentListProvider(
                                          downloaderId,
                                        ).notifier,
                                      )
                                      .refresh();
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  Toast.success('Tracker 已替换');
                                } catch (e, st) {
                                  AppLogger.error('批量替换 Tracker 失败', e, st);
                                  Toast.error('替换 Tracker 失败');
                                }
                              },
                        child: const Text('替换'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

List<String> _torrentHashesForSite(
  WidgetRef ref,
  int downloaderId,
  String siteKey,
) {
  final data = ref.read(torrentListProvider(downloaderId)).valueOrNull;
  if (data == null) return const <String>[];
  final matcher = ref.read(torrentSiteMatcherProvider);
  return data.torrents
      .where((torrent) => matcher.match(torrent)?.key == siteKey)
      .map((torrent) => torrent.hashString)
      .where((hash) => hash.isNotEmpty)
      .toList();
}

String _randomTrackerForSite(WidgetRef ref, int downloaderId, String siteKey) {
  final data = ref.read(torrentListProvider(downloaderId)).valueOrNull;
  if (data == null) return '';

  final matcher = ref.read(torrentSiteMatcherProvider);
  final random = Random();
  final torrents =
      data.torrents
          .where((torrent) => matcher.match(torrent)?.key == siteKey)
          .toList()
        ..shuffle(random);

  for (final torrent in torrents) {
    final tracker = _defaultTrackerForTorrent(torrent);
    if (tracker.isNotEmpty) return tracker;
  }

  return '';
}

String _defaultTrackerForTorrent(Torrent torrent) {
  final trackers = [
    ...torrent.visibleTrackerStats.where((tracker) => !tracker.isBackup),
    ...torrent.visibleTrackerStats.where((tracker) => tracker.isBackup),
  ];

  for (final tracker in trackers) {
    final announce = tracker.announce.trim();
    if (announce.isNotEmpty) return announce;
  }

  final fallback = torrent.trackerUrl.trim();
  if (fallback.isEmpty || TorrentUtils.isVirtualTrackerText(fallback)) {
    return '';
  }
  return fallback;
}

class _TorrentRefreshBar extends ConsumerWidget {
  final int downloaderId;
  final VoidCallback onRefresh;

  const _TorrentRefreshBar({
    required this.downloaderId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);
    final cs = theme.colors;
    final typo = theme.typography;
    final enabled = ref.watch(speedEnabledProvider);
    final paused = ref.watch(torrentRefreshPausedProvider(downloaderId));
    final remaining = ref.watch(torrentRefreshRemainingProvider(downloaderId));

    final running = enabled && !paused;
    final min = remaining ~/ 60;
    final sec = remaining % 60;
    final countdown = remaining > 0
        ? '$min:${sec.toString().padLeft(2, '0')}'
        : '';
    final pauseButtonColor = !enabled
        ? cs.mutedForeground.withValues(alpha: 0.35)
        : paused
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final pauseButtonBg = !enabled
        ? cs.foreground.withValues(alpha: 0.04)
        : pauseButtonColor.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: running
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            running
                ? '种子数据自动刷新中'
                : enabled
                ? '种子数据已暂停'
                : '自动刷新已关闭',
            style: typo.xs.copyWith(
              color: cs.mutedForeground.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
          if (running && countdown.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: remaining <= 60
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                    : cs.foreground.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FIcons.timer,
                    size: 10,
                    color: remaining <= 60
                        ? const Color(0xFFF59E0B)
                        : cs.mutedForeground.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    countdown,
                    style: typo.xs.copyWith(
                      fontSize: 10,
                      color: remaining <= 60
                          ? const Color(0xFFF59E0B)
                          : cs.mutedForeground.withValues(alpha: 0.5),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onRefresh,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                FIcons.refreshCw,
                size: 14,
                color: cs.mutedForeground.withValues(alpha: 0.45),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showSpeedSettings(context, ref),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                FIcons.settings,
                size: 14,
                color: cs.mutedForeground.withValues(alpha: 0.45),
              ),
            ),
          ),
          GestureDetector(
            onTap: enabled
                ? () {
                    final nextPaused = !paused;
                    ref
                            .read(
                              torrentRefreshPausedProvider(
                                downloaderId,
                              ).notifier,
                            )
                            .state =
                        nextPaused;
                    ref
                        .read(torrentListProvider(downloaderId).notifier)
                        .setWsPaused(nextPaused);
                  }
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pauseButtonBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    paused ? FIcons.play : FIcons.pause,
                    size: 12,
                    color: pauseButtonColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    paused ? '恢复' : '暂停',
                    style: typo.xs.copyWith(
                      color: pauseButtonColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  全局状态栏
// ══════════════════════════════════════════════════════════

class _StatsBar extends ConsumerWidget {
  final int downloaderId;

  const _StatsBar({required this.downloaderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;
    final status = ref.watch(downloaderStatusProvider(downloaderId));
    if (status == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: FIcons.arrowDown,
            value: TorrentUtils.formatSpeed(status.downloadSpeed),
            color: _colorDownloading,
          ),
          const SizedBox(width: 20),
          _StatChip(
            icon: FIcons.arrowUp,
            value: TorrentUtils.formatSpeed(status.uploadSpeed),
            color: _colorSeeding,
          ),
          const Spacer(),
          _CountText(
            label: '活跃',
            count: status.activeTorrentCount,
            color: _colorDownloading,
          ),
          const SizedBox(width: 10),
          _CountText(
            label: '暂停',
            count: status.pausedTorrentCount,
            color: cs.foreground.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 10),
          _CountText(
            label: '总计',
            count: status.torrentCount,
            color: cs.foreground.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _CountText extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _CountText({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: cs.foreground.withValues(alpha: 0.35),
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: '$count',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  种子列表
// ══════════════════════════════════════════════════════════

class _TorrentList extends ConsumerWidget {
  final int downloaderId;
  final DownloaderType downloaderType; // 新增

  const _TorrentList(this.downloaderType, {required this.downloaderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;
    final asyncData = ref.watch(torrentListProvider(downloaderId));
    final torrents = ref.watch(filteredTorrentsProvider(downloaderId));
    final categories = ref.watch(availableCategoriesProvider(downloaderId));
    final tags = ref.watch(availableTagsProvider(downloaderId));
    final matcher = ref.watch(torrentSiteMatcherProvider);
    if (asyncData.isLoading && asyncData.valueOrNull == null) {
      return Center(child: FProgress.circularIcon());
    }

    if (asyncData is AsyncError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FIcons.cloudOff,
              size: 48,
              color: cs.foreground.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              '连接失败',
              style: TextStyle(
                color: cs.foreground.withValues(alpha: 0.45),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            FButton(
              onPress: () => ref
                  .read(torrentListProvider(downloaderId).notifier)
                  .refresh(),
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
            Icon(
              FIcons.inbox,
              size: 48,
              color: cs.foreground.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              (asyncData.valueOrNull?.torrents.isEmpty ?? true)
                  ? '暂无种子'
                  : '当前筛选无结果',
              style: TextStyle(
                color: cs.foreground.withValues(alpha: 0.35),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        24 + ShellBottomSpacing.value(context),
      ),
      itemCount: torrents.length,
      itemBuilder: (_, i) {
        final torrent = torrents[i];
        return _TorrentTile(
          torrent: torrent,
          downloaderId: downloaderId,
          downloaderType: downloaderType,
          siteMatch: matcher.match(torrent),
          categories: categories,
          tags: tags,
          onAction: (action, params) => executeTorrentAction(
            ref: ref,
            downloaderId: downloaderId,
            action: action,
            params: params,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
//  单个种子卡片
// ══════════════════════════════════════════════════════════

class _TorrentTile extends StatelessWidget {
  final Torrent torrent;
  final int downloaderId;
  final DownloaderType downloaderType;
  final TorrentSiteMatch? siteMatch;
  final List<String> categories;
  final List<String> tags;
  final OnTorrentAction onAction;

  const _TorrentTile({
    required this.torrent,
    required this.downloaderId,
    required this.downloaderType,
    required this.siteMatch,
    required this.categories,
    required this.tags,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final ts = torrent.torrentStatus;
    final color = _statusColor(ts, torrent.hasError);
    final trackerLabel = torrent.primaryTracker.isNotEmpty
        ? torrent.primaryTracker
        : torrent.primaryTrackerHost;
    final trackerTooltip = torrent.primaryTrackerHost.isNotEmpty
        ? torrent.primaryTrackerHost
        : trackerLabel;
    final remainingBytes = _torrentRemainingBytes(torrent);
    final etaText = _torrentEtaText(torrent, remainingBytes);

    void showDetail() => showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
      builder: (_) => TorrentDetailSheet(
        downloaderId: downloaderId,
        torrent: torrent,
        siteMatch: siteMatch,
      ),
    );

    void showActionMenu() => TorrentActionMenu.show(
      context,
      torrent: torrent,
      type: downloaderType,
      categories: categories,
      tags: tags,
      onAction: onAction,
      onShowDetail: showDetail,
    );

    return GestureDetector(
      onTap: showActionMenu,
      onLongPress: showDetail,
      onSecondaryTap: showActionMenu,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 名称 ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusDot(color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    torrent.name.isNotEmpty ? torrent.name : '(无名称)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── 进度条 ──
            _TorrentProgressBar(
              value: torrent.percentDone,
              color: color,
              trackColor: cs.border,
            ),
            const SizedBox(height: 8),

            // ── 数据行 ──
            Row(
              children: [
                Text(
                  TorrentUtils.formatBytes(torrent.sizeWhenDone),
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                _SpeedChip(
                  icon: FIcons.arrowDown,
                  value: torrent.rateDownload,
                  color: _colorDownloading,
                  mutedColor: cs.foreground.withValues(alpha: 0.25),
                ),
                const SizedBox(width: 12),
                _SpeedChip(
                  icon: FIcons.arrowUp,
                  value: torrent.rateUpload,
                  color: _colorSeeding,
                  mutedColor: cs.foreground.withValues(alpha: 0.25),
                ),
                const Spacer(),
                Text(
                  'R ${TorrentUtils.formatRatio(torrent.uploadRatio)}',
                  style: TextStyle(
                    color: torrent.uploadRatio >= 1.0
                        ? _colorSeeding
                        : cs.foreground.withValues(alpha: 0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
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
                    tooltip: siteMatch!.trackerHost.isNotEmpty
                        ? siteMatch!.trackerHost
                        : siteMatch!.displayName,
                    bg: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                    fg: const Color(0xFF0F766E),
                  ),
                _InfoTag(
                  text: ts.label,
                  bg: color.withValues(alpha: 0.12),
                  fg: color,
                ),
                if (etaText != null)
                  _InfoTag(
                    text: etaText,
                    bg: _colorDownloading.withValues(alpha: 0.12),
                    fg: _colorDownloading,
                  ),
                if (torrent.hasError)
                  _InfoTag(
                    text: torrent.errorString.isNotEmpty
                        ? torrent.errorString
                        : '错误',
                    bg: _colorError.withValues(alpha: 0.12),
                    fg: _colorError,
                  ),
                if (torrent.secondsSeeding > 0)
                  Text(
                    '做种 ${TorrentUtils.formatDuration(torrent.secondsSeeding)}',
                    style: TextStyle(
                      color: cs.foreground.withValues(alpha: 0.35),
                      fontSize: 11,
                    ),
                  ),
                Text(
                  TorrentUtils.formatTimeAgo(torrent.activityDate),
                  style: TextStyle(
                    color: cs.foreground.withValues(alpha: 0.25),
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            // ── 标签 ──
            if (torrent.labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: torrent.labels
                    .map((l) => _LabelChip(label: l))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _torrentRemainingBytes(Torrent torrent) {
    if (torrent.leftUntilDone > 0) return torrent.leftUntilDone;
    final total = torrent.sizeWhenDone > 0
        ? torrent.sizeWhenDone
        : torrent.totalSize;
    if (total <= 0) return 0;
    final progress = torrent.percentDone.clamp(0.0, 1.0);
    return (total * (1 - progress)).ceil();
  }

  String? _torrentEtaText(Torrent torrent, int remainingBytes) {
    if (remainingBytes <= 0) return null;
    final status = torrent.torrentStatus;
    final isDownloading =
        status == TorrentStatus.downloading ||
        status == TorrentStatus.downloadWait ||
        torrent.rateDownload > 0;
    if (!isDownloading) return null;
    final remainingSize = TorrentUtils.formatBytes(remainingBytes);
    if (torrent.rateDownload <= 0) return '剩余 $remainingSize · --';
    final seconds = (remainingBytes / torrent.rateDownload).ceil();
    return '剩余 $remainingSize · ${TorrentUtils.formatDuration(seconds)}';
  }
}

// ────────────────── 子组件 ──────────────────

class _StatusDot extends StatelessWidget {
  final Color color;

  const _StatusDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }
}

class _TorrentProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color trackColor;

  const _TorrentProgressBar({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: trackColor,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          TorrentUtils.formatPercent(value),
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SpeedChip extends StatelessWidget {
  final IconData icon;
  final int value;
  final Color color;
  final Color mutedColor;

  const _SpeedChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final active = value > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: active ? color : mutedColor),
        const SizedBox(width: 3),
        Text(
          TorrentUtils.formatSpeed(value),
          style: TextStyle(
            color: active ? color : mutedColor,
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            fontFeatures: const [FontFeature.tabularFigures()],
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

  const _InfoTag({
    required this.text,
    this.tooltip,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final message = tooltip?.trim();
    if (message == null || message.isEmpty) return child;
    return Tooltip(message: message, child: child);
  }
}

class _LabelChip extends StatelessWidget {
  final String label;

  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
      ),
      child: Text(label, style: TextStyle(color: cs.primary, fontSize: 11)),
    );
  }
}
