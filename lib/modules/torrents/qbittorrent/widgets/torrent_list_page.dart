import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/model/downloader_category.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart'
    as download_providers;
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:harvest/modules/download/widgets/downloader_speed_setting.dart';
import 'package:harvest/modules/download/widgets/qb_category_tag_manager.dart';
import 'package:harvest/modules/download/widgets/qb_settings_dialog.dart';
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
  late int _currentDownloaderId;
  late DownloaderType _currentDownloaderType;
  String? _selectedTorrentHash;
  bool _desktopDetailExpanded = false;
  double _desktopDetailHeight = 340;
  final List<ProviderSubscription<Object?>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _currentDownloaderId = widget.downloaderId;
    _currentDownloaderType = widget.downloaderType;
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
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activateCurrentDownloader();
    });
  }

  @override
  void didUpdateWidget(covariant TorrentListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.downloaderId != widget.downloaderId) {
      _switchDownloaderId(widget.downloaderId, widget.downloaderType);
    }
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
    final mobile = context.isMobile;
    final downloaders = ref
        .watch(download_providers.downloaderListProvider)
        .valueOrNull;
    final downloader = _findCurrentDownloader(downloaders);
    final currentDownloaderId = _currentDownloaderId;
    final currentDownloaderType = downloader == null
        ? _currentDownloaderType
        : _typeForDownloader(downloader);
    final currentDownloaderName =
        downloader?.name ?? widget.downloaderName ?? '种子管理';
    final currentCount = ref
        .watch(filteredTorrentsProvider(currentDownloaderId))
        .length;

    return EscapeBackScope(
      onBack: () => Navigator.of(context).pop(),
      child: FScaffold(
        childPad: false,
        header: FHeader.nested(
          title: _DownloaderTitleSelector(
            downloaders: downloaders ?? const <Downloader>[],
            currentDownloaderId: currentDownloaderId,
            fallbackTitle: currentDownloaderName,
            onSelect: _switchDownloader,
          ),
          prefixes: [
            FHeaderAction(
              icon: const Icon(FIcons.chevronLeft),
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
          suffixes: [
            _DownloaderHeaderMenu(
              downloaderType: currentDownloaderType,
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
                  currentDownloaderType == DownloaderType.qbittorrent
                  ? () => _showTrackerReplaceDialogForDownloader(
                      context,
                      ref,
                      currentDownloaderId,
                    )
                  : null,
            ),
          ],
        ),
        child: mobile
            ? Column(
                children: [
                  _Toolbar(
                    downloaderId: _currentDownloaderId,
                    downloaderType: currentDownloaderType,
                  ),
                  _TorrentRefreshBar(
                    downloaderId: _currentDownloaderId,
                    onRefresh: _refreshTorrentList,
                    onRefreshStateChanged: _syncTorrentRefreshState,
                  ),
                  _StatsBar(
                    downloaderId: _currentDownloaderId,
                    downloader: downloader,
                    onOpenSpeedSettings: downloader == null
                        ? null
                        : () => _showDownloaderSpeedLimitSettings(downloader),
                    onToggleSpeedMode: downloader == null
                        ? null
                        : (enabled) =>
                              _toggleDownloaderSpeedMode(downloader, enabled),
                  ),
                  Expanded(
                    child: _TorrentList(
                      currentDownloaderType,
                      downloaderId: _currentDownloaderId,
                    ),
                  ),
                ],
              )
            : _DesktopTorrentLayout(
                downloaderId: _currentDownloaderId,
                downloaderType: currentDownloaderType,
                downloader: downloader,
                selectedHash: _selectedTorrentHash,
                detailExpanded: _desktopDetailExpanded,
                detailHeight: _desktopDetailHeight,
                onSelect: (torrent) => setState(() {
                  _selectedTorrentHash = torrent.hashString;
                  _desktopDetailExpanded = true;
                }),
                onToggleDetail: () => setState(
                  () => _desktopDetailExpanded = !_desktopDetailExpanded,
                ),
                onDetailResize: (delta) => setState(() {
                  _desktopDetailHeight = (_desktopDetailHeight - delta).clamp(
                    220,
                    620,
                  );
                }),
                onRefresh: _refreshTorrentList,
                onRefreshStateChanged: _syncTorrentRefreshState,
                onOpenSpeedSettings: downloader == null
                    ? null
                    : () => _showDownloaderSpeedLimitSettings(downloader),
                onToggleSpeedMode: downloader == null
                    ? null
                    : (enabled) =>
                          _toggleDownloaderSpeedMode(downloader, enabled),
              ),
      ),
    );
  }

  List<Torrent> _currentActionTorrents() {
    return ref.read(filteredTorrentsProvider(_currentDownloaderId));
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
    final paused = ref.read(torrentRefreshPausedProvider(_currentDownloaderId));
    ref
        .read(torrentListProvider(_currentDownloaderId).notifier)
        .setWsPaused(!enabled || paused);
    _restartAutoRefresh();
  }

  void _refreshTorrentList() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(_currentDownloaderId).notifier).refresh(),
    );
    Toast.success('已刷新列表');
  }

  void _refreshTorrentListSilently() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(_currentDownloaderId).notifier).refresh(),
    );
  }

  void _restartAutoRefresh() {
    _stopAutoRefresh(resetRemaining: false);
    if (!mounted) return;

    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(_currentDownloaderId));
    if (!enabled || paused) {
      ref
              .read(
                torrentRefreshRemainingProvider(_currentDownloaderId).notifier,
              )
              .state =
          0;
      return;
    }

    final interval = ref.read(speedIntervalProvider);
    final duration = ref.read(speedDurationProvider);
    final totalSeconds = duration * 60;
    ref
            .read(
              torrentRefreshRemainingProvider(_currentDownloaderId).notifier,
            )
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
        torrentRefreshRemainingProvider(_currentDownloaderId),
      );
      if (remaining <= 0) {
        timer.cancel();
        return;
      }
      ref
              .read(
                torrentRefreshRemainingProvider(_currentDownloaderId).notifier,
              )
              .state =
          remaining - 1;
    });

    _autoStopTimer = Timer(Duration(seconds: totalSeconds), () {
      if (!mounted) return;
      _stopAutoRefresh(resetRemaining: true);
      ref
              .read(torrentRefreshPausedProvider(_currentDownloaderId).notifier)
              .state =
          true;
    });
  }

  void _stopAutoRefresh({required bool resetRemaining}) {
    _cancelAutoRefreshTimers();
    if (resetRemaining && mounted) {
      ref
              .read(
                torrentRefreshRemainingProvider(_currentDownloaderId).notifier,
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
      if (downloader.id == _currentDownloaderId) return downloader;
    }
    return null;
  }

  DownloaderType _typeForDownloader(Downloader downloader) {
    if (downloader.isTr) return DownloaderType.transmission;
    return DownloaderType.qbittorrent;
  }

  void _activateCurrentDownloader() {
    final notifier = ref.read(
      torrentListProvider(_currentDownloaderId).notifier,
    );
    _torrentNotifier = notifier;
    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(_currentDownloaderId));
    notifier.setWsPaused(!enabled || paused);
    _restartAutoRefresh();
  }

  void _switchDownloader(Downloader downloader) {
    _switchDownloaderId(downloader.id, _typeForDownloader(downloader));
  }

  void _switchDownloaderId(int downloaderId, DownloaderType downloaderType) {
    if (_currentDownloaderId == downloaderId &&
        _currentDownloaderType == downloaderType) {
      _torrentNotifier?.setWsPaused(true);
      _stopAutoRefresh(resetRemaining: true);
      ref.read(torrentRefreshPausedProvider(downloaderId).notifier).state =
          false;
      ref.read(torrentRefreshRemainingProvider(downloaderId).notifier).state =
          0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _activateCurrentDownloader();
      });
      return;
    }
    _torrentNotifier?.setWsPaused(true);
    _torrentNotifier = null;
    _stopAutoRefresh(resetRemaining: true);
    setState(() {
      _currentDownloaderId = downloaderId;
      _currentDownloaderType = downloaderType;
      _selectedTorrentHash = null;
      _desktopDetailExpanded = false;
    });
    ref.read(torrentSearchProvider.notifier).state = '';
    ref.read(torrentCategoryProvider.notifier).state = '';
    ref.read(torrentTagProvider.notifier).state = '';
    ref.read(torrentSiteFilterProvider.notifier).state = '';
    ref.read(torrentFilterProvider.notifier).state = TorrentFilter.all;
    ref.read(desktopTorrentStatusFilterProvider.notifier).state =
        DesktopTorrentStatusFilter.all;
    ref.read(torrentRefreshPausedProvider(downloaderId).notifier).state = false;
    ref.read(torrentRefreshRemainingProvider(downloaderId).notifier).state = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activateCurrentDownloader();
    });
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
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => downloader.isQb
            ? QbSettingsDialog(downloader: downloader, initialIndex: 3)
            : TrSettingsDialog(downloader: downloader, initialIndex: 1),
      ).whenComplete(() {
        if (!mounted) return;
        ref.read(downloaderSpeedProvider.notifier).refresh();
      }),
    );
  }

  Future<void> _toggleDownloaderSpeedMode(
    Downloader downloader,
    bool enabled,
  ) async {
    try {
      await DownloaderService.toggleSpeedLimitMode(
        downloader.id,
        enabled: enabled,
      );
      final speedNotifier = ref.read(downloaderSpeedProvider.notifier);
      speedNotifier.setAlternativeSpeedMode(
        downloaderId: downloader.id,
        wsKey: downloader.wsKey,
        enabled: enabled,
      );
      speedNotifier.refresh();
      Toast.success(enabled ? '已切换为龟速模式' : '已切换为极速模式');
      await ref.read(torrentListProvider(downloader.id).notifier).refresh();
    } catch (_) {
      Toast.error('切换速度模式失败');
    }
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

    final isQb = _currentDownloaderType == DownloaderType.qbittorrent;
    final success = await executeTorrentAction(
      ref: ref,
      downloaderId: _currentDownloaderId,
      action: isQb ? qbAction : trAction,
      params: isQb ? {'hashes': ids} : {'ids': ids},
    );
    if (!mounted) return;
    if (success) {
      ref.read(torrentListProvider(_currentDownloaderId).notifier).refresh();
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

class _DownloaderTitleSelector extends StatefulWidget {
  final List<Downloader> downloaders;
  final int currentDownloaderId;
  final String fallbackTitle;
  final ValueChanged<Downloader> onSelect;

  const _DownloaderTitleSelector({
    required this.downloaders,
    required this.currentDownloaderId,
    required this.fallbackTitle,
    required this.onSelect,
  });

  @override
  State<_DownloaderTitleSelector> createState() =>
      _DownloaderTitleSelectorState();
}

class _DownloaderTitleSelectorState extends State<_DownloaderTitleSelector> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.downloaders.isEmpty) {
      return Text(widget.fallbackTitle);
    }

    final maxWidth = max(160.0, MediaQuery.sizeOf(context).width - 190);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(
        height: 44,
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final downloader in widget.downloaders) ...[
                    _DownloaderTitleChip(
                      downloader: downloader,
                      selected: downloader.id == widget.currentDownloaderId,
                      onTap: () => widget.onSelect(downloader),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloaderTitleChip extends StatelessWidget {
  final Downloader downloader;
  final bool selected;
  final VoidCallback onTap;

  const _DownloaderTitleChip({
    required this.downloader,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final name = downloader.name.isEmpty ? '未命名下载器' : downloader.name;
    return Tooltip(
      message: downloader.isTr ? '$name · Transmission' : '$name · qBittorrent',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            height: 32,
            constraints: const BoxConstraints(maxWidth: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.mutedForeground.withValues(alpha: 0.06),
              border: Border.all(
                color: selected ? cs.primary : cs.border,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  downloader.isTr ? FIcons.radioTower : FIcons.download,
                  size: 13,
                  color: selected ? cs.primary : cs.mutedForeground,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? cs.primary : cs.foreground,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  final VoidCallback onRefreshStateChanged;

  const _TorrentRefreshBar({
    required this.downloaderId,
    required this.onRefresh,
    required this.onRefreshStateChanged,
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
                    onRefreshStateChanged();
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
  final Downloader? downloader;
  final VoidCallback? onOpenSpeedSettings;
  final ValueChanged<bool>? onToggleSpeedMode;

  const _StatsBar({
    required this.downloaderId,
    this.downloader,
    this.onOpenSpeedSettings,
    this.onToggleSpeedMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;
    final data = ref.watch(torrentListProvider(downloaderId)).valueOrNull;
    final status = data?.status;
    final speedMap = ref.watch(downloaderSpeedProvider);
    var liveInfo = speedMap['$downloaderId']?.info;
    if (liveInfo == null) {
      final id = downloaderId.toString().toLowerCase();
      final wsKey = downloader?.wsKey.toLowerCase();
      for (final entry in speedMap.entries) {
        final key = entry.key.toLowerCase();
        final dataId = entry.value.downloaderId.toLowerCase();
        if (key == id ||
            dataId == id ||
            (wsKey != null && (key == wsKey || dataId == wsKey))) {
          liveInfo = entry.value.info;
          break;
        }
      }
    }
    if (status == null && liveInfo == null && data == null) {
      return const SizedBox.shrink();
    }

    final torrents = data?.torrents ?? const <Torrent>[];
    final activeCount = torrents.isEmpty
        ? liveInfo?.activeTorrentCount ?? status?.activeTorrentCount ?? 0
        : torrents
              .where(
                (torrent) => torrent.rateDownload > 0 || torrent.rateUpload > 0,
              )
              .length;
    final pausedCount =
        status?.pausedTorrentCount ?? liveInfo?.pausedTorrentCount ?? 0;
    final totalCount =
        status?.torrentCount ?? liveInfo?.totalTorrentCount ?? torrents.length;
    final downloadSpeed = liveInfo?.downloadSpeed ?? status?.downloadSpeed ?? 0;
    final uploadSpeed = liveInfo?.uploadSpeed ?? status?.uploadSpeed ?? 0;
    final sessionUploaded = _firstPositive([
      liveInfo?.uploadedSession ?? 0,
      status?.currentStats.uploadedBytes ?? 0,
    ]);
    final sessionDownloaded = _firstPositive([
      liveInfo?.downloadedSession ?? 0,
      status?.currentStats.downloadedBytes ?? 0,
    ]);
    final totalUploaded = _firstPositive([
      status?.cumulativeStats.uploadedBytes ?? 0,
      _sumUploadedEver(torrents),
    ]);
    final totalDownloaded = _firstPositive([
      status?.cumulativeStats.downloadedBytes ?? 0,
      _sumDownloadedEver(torrents),
    ]);
    final uploadLimit = liveInfo?.uploadLimit ?? 0;
    final downloadLimit = liveInfo?.downloadLimit ?? 0;
    final limited = liveInfo?.hasLimit ?? false;
    final slowMode = liveInfo?.alternativeSpeedEnabled ?? false;
    final modeText = '${slowMode ? '龟速' : '极速'} · ${limited ? '限速' : '不限速'}';
    final freeSpace = liveInfo?.freeSpace ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 14,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusBarMetric(
              icon: FIcons.arrowDown,
              label: '下载',
              value: TorrentUtils.formatSpeed(downloadSpeed),
              color: _colorDownloading,
            ),
            _StatusBarMetric(
              icon: FIcons.arrowUp,
              label: '上传',
              value: TorrentUtils.formatSpeed(uploadSpeed),
              color: _colorSeeding,
            ),
            _StatusBarMetric(
              icon: FIcons.activity,
              label: '活动',
              value: '$activeCount',
              color: const Color(0xFF0D9488),
            ),
            _StatusBarMetric(
              icon: FIcons.database,
              label: '本次',
              value: _formatTransferPair(sessionUploaded, sessionDownloaded),
              color: cs.foreground,
            ),
            _StatusBarMetric(
              icon: FIcons.hardDrive,
              label: '总计',
              value: _formatTransferPair(totalUploaded, totalDownloaded),
              color: cs.foreground,
            ),
            _StatusBarMetric(
              icon: FIcons.gauge,
              label: '限速',
              value: _formatLimitPair(uploadLimit, downloadLimit),
              color: limited ? const Color(0xFFD97706) : cs.mutedForeground,
              tooltip: onOpenSpeedSettings == null ? null : '打开限速设置',
              onTap: onOpenSpeedSettings,
            ),
            _StatusBarMetric(
              icon: FIcons.hardDrive,
              label: '剩余',
              value: freeSpace > 0 ? TorrentUtils.formatBytes(freeSpace) : '-',
              color: cs.mutedForeground,
            ),
            _StatusBarMetric(
              icon: FIcons.zap,
              label: '模式',
              value: modeText,
              color: limited ? const Color(0xFFD97706) : _colorDownloading,
              tooltip: onToggleSpeedMode == null
                  ? null
                  : (slowMode ? '切换为极速模式' : '切换为龟速模式'),
              onTap: onToggleSpeedMode == null
                  ? null
                  : () => onToggleSpeedMode!(!slowMode),
            ),
            _StatusBarCount(label: '暂停', count: pausedCount),
            _StatusBarCount(label: '总数', count: totalCount),
          ],
        ),
      ),
    );
  }
}

class _StatusBarMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? tooltip;
  final VoidCallback? onTap;

  const _StatusBarMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final clickable = onTap != null;
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(
          '$label ',
          style: TextStyle(
            color: cs.foreground.withValues(alpha: 0.38),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
    if (clickable) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: child,
          ),
        ),
      );
    }
    if (tooltip != null) {
      child = FTooltip(tipBuilder: (_, __) => Text(tooltip!), child: child);
    }
    return child;
  }
}

class _StatusBarCount extends StatelessWidget {
  final String label;
  final int count;

  const _StatusBarCount({required this.label, required this.count});

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
              color: cs.foreground.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

int _firstPositive(List<int> values) {
  for (final value in values) {
    if (value > 0) return value;
  }
  return 0;
}

int _sumUploadedEver(List<Torrent> torrents) {
  var total = 0;
  for (final torrent in torrents) {
    total += torrent.uploadedEver;
  }
  return total;
}

int _sumDownloadedEver(List<Torrent> torrents) {
  var total = 0;
  for (final torrent in torrents) {
    total += torrent.downloadedEver;
  }
  return total;
}

String _formatTransferPair(int uploaded, int downloaded) {
  return '↑ ${TorrentUtils.formatBytes(uploaded)}  ↓ ${TorrentUtils.formatBytes(downloaded)}';
}

String _formatLimitPair(int uploadLimit, int downloadLimit) {
  return '↑ ${_formatSpeedLimit(uploadLimit)}  ↓ ${_formatSpeedLimit(downloadLimit)}';
}

String _formatSpeedLimit(int bytesPerSecond) {
  if (bytesPerSecond <= 0) return '不限';
  return TorrentUtils.formatSpeed(bytesPerSecond);
}

// ══════════════════════════════════════════════════════════
//  桌面版：后台式 Sidebar + 表格 + 详情区
// ══════════════════════════════════════════════════════════

class _DesktopTorrentLayout extends ConsumerStatefulWidget {
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

  const _DesktopTorrentLayout({
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
  ConsumerState<_DesktopTorrentLayout> createState() =>
      _DesktopTorrentLayoutState();
}

class _DesktopTorrentLayoutState extends ConsumerState<_DesktopTorrentLayout> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final downloaderId = widget.downloaderId;
    final downloaderType = widget.downloaderType;
    final downloader = widget.downloader;
    final selectedHash = widget.selectedHash;
    final detailExpanded = widget.detailExpanded;
    final detailHeight = widget.detailHeight;
    final onSelect = widget.onSelect;
    final onToggleDetail = widget.onToggleDetail;
    final onDetailResize = widget.onDetailResize;
    final onRefresh = widget.onRefresh;

    return ColoredBox(
      color: cs.mutedForeground.withValues(alpha: 0.025),
      child: Column(
        children: [
          _TorrentRefreshBar(
            downloaderId: downloaderId,
            onRefresh: onRefresh,
            onRefreshStateChanged: widget.onRefreshStateChanged,
          ),
          _StatsBar(
            downloaderId: downloaderId,
            downloader: downloader,
            onOpenSpeedSettings: widget.onOpenSpeedSettings,
            onToggleSpeedMode: widget.onToggleSpeedMode,
          ),
          Expanded(
            child: Row(
              children: [
                if (_sidebarCollapsed)
                  _CollapsedDesktopSidebar(
                    onExpand: () => setState(() => _sidebarCollapsed = false),
                  )
                else
                  _DesktopTorrentSidebar(
                    key: ValueKey('desktop-sidebar-$downloaderId'),
                    downloaderId: downloaderId,
                    downloaderType: downloaderType,
                    downloader: downloader,
                    onCollapse: () => setState(() => _sidebarCollapsed = true),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _DesktopTorrentTable(
                          downloaderId: downloaderId,
                          downloaderType: downloaderType,
                          selectedHash: selectedHash,
                          onSelect: onSelect,
                        ),
                      ),
                      _DesktopTorrentDetailPanel(
                        downloaderId: downloaderId,
                        downloaderType: downloaderType,
                        selectedHash: selectedHash,
                        expanded: detailExpanded,
                        height: detailHeight,
                        onToggle: onToggleDetail,
                        onResize: onDetailResize,
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

class _DesktopTorrentSidebar extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final VoidCallback onCollapse;

  const _DesktopTorrentSidebar({
    super.key,
    required this.downloaderId,
    required this.downloaderType,
    required this.downloader,
    required this.onCollapse,
  });

  @override
  ConsumerState<_DesktopTorrentSidebar> createState() =>
      _DesktopTorrentSidebarState();
}

class _CollapsedDesktopSidebar extends StatelessWidget {
  final VoidCallback onExpand;

  const _CollapsedDesktopSidebar({required this.onExpand});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
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
          child: FTooltip(
            tipBuilder: (_, __) => const Text('展开筛选栏'),
            child: FButton.icon(
              style: FButtonStyle.ghost(),
              onPress: onExpand,
              child: const Icon(FIcons.panelLeftOpen, size: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTorrentSidebarState
    extends ConsumerState<_DesktopTorrentSidebar> {
  late final TextEditingController _searchCtrl;
  final Set<String> _collapsedSections = {};
  static const List<String> _sectionIds = ['status', 'category', 'tag', 'site'];
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
    _searchCtrl = TextEditingController(text: ref.read(torrentSearchProvider));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final desktopStatus = ref.watch(desktopTorrentStatusFilterProvider);
    final category = ref.watch(torrentCategoryProvider);
    final tag = ref.watch(torrentTagProvider);
    final site = ref.watch(torrentSiteFilterProvider);
    final categories = ref.watch(
      availableCategoriesProvider(widget.downloaderId),
    );
    final tags = ref.watch(availableTagsProvider(widget.downloaderId));
    final sites = ref.watch(availableTorrentSitesProvider(widget.downloaderId));
    final downloader = widget.downloader;
    final isQb = widget.downloaderType == DownloaderType.qbittorrent;
    final allTorrents =
        ref
            .watch(torrentListProvider(widget.downloaderId))
            .valueOrNull
            ?.torrents ??
        const <Torrent>[];
    final statusCounts = _desktopStatusCounts(allTorrents);
    final categoryCounts = <String, int>{};
    for (final torrent in allTorrents) {
      for (final label in _torrentCategoryFilterLabels(torrent)) {
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
        border: Border(right: BorderSide(color: cs.border, width: 0.5)),
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
                FTooltip(
                  tipBuilder: (_, __) => const Text('收起筛选栏'),
                  child: FButton.icon(
                    style: FButtonStyle.ghost(),
                    onPress: widget.onCollapse,
                    child: const Icon(FIcons.panelLeftClose, size: 15),
                  ),
                ),
                FButton(
                  style: FButtonStyle.ghost(),
                  onPress: _resetFilters,
                  child: const Text('重置'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FTextField(
              controller: _searchCtrl,
              hint: '搜索种子名称...',
              prefixBuilder: (context, styles, child) => const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(FIcons.search, size: 14),
              ),
              onChange: (value) =>
                  ref.read(torrentSearchProvider.notifier).state = value,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sectionHeights = _resolvedSectionHeights(
                  constraints.maxHeight,
                );
                return Column(
                  children: [
                    _DesktopResizableFilterSection(
                      id: 'status',
                      title: '状态',
                      height: sectionHeights['status'] ?? 38,
                      collapsed: _isSectionCollapsed('status'),
                      onToggle: () => _toggleSection('status'),
                      onResize: (delta) => _resizeSection('status', delta),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        children: [
                          _DesktopFilterItem(
                            icon: FIcons.list,
                            label: DesktopTorrentStatusFilter.all.label,
                            count:
                                statusCounts[DesktopTorrentStatusFilter.all] ??
                                0,
                            selected:
                                desktopStatus == DesktopTorrentStatusFilter.all,
                            onTap: () =>
                                ref
                                        .read(
                                          desktopTorrentStatusFilterProvider
                                              .notifier,
                                        )
                                        .state =
                                    DesktopTorrentStatusFilter.all,
                          ),
                          _DesktopStatusGroup(
                            title: '活动中的',
                            icon: FIcons.activity,
                            group: DesktopTorrentStatusFilter.active,
                            children: const [
                              DesktopTorrentStatusFilter.downloadingActive,
                              DesktopTorrentStatusFilter.uploadingActive,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          _DesktopStatusGroup(
                            title: '暂停的',
                            icon: FIcons.pause,
                            group: DesktopTorrentStatusFilter.paused,
                            children: const [
                              DesktopTorrentStatusFilter.pausedDownloading,
                              DesktopTorrentStatusFilter.pausedCompleted,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          _DesktopStatusGroup(
                            title: '等待中',
                            icon: FIcons.timer,
                            group: DesktopTorrentStatusFilter.waiting,
                            children: const [
                              DesktopTorrentStatusFilter.downloadWaiting,
                              DesktopTorrentStatusFilter.seedWaiting,
                              DesktopTorrentStatusFilter.stalledDownloading,
                              DesktopTorrentStatusFilter.stalledUploading,
                            ],
                            selected: desktopStatus,
                            counts: statusCounts,
                            onTap: _setDesktopStatus,
                          ),
                          _DesktopFilterItem(
                            icon: FIcons.rotateCw,
                            label: DesktopTorrentStatusFilter.checking.label,
                            count:
                                statusCounts[DesktopTorrentStatusFilter
                                    .checking] ??
                                0,
                            selected:
                                desktopStatus ==
                                DesktopTorrentStatusFilter.checking,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.checking,
                            ),
                          ),
                          _DesktopFilterItem(
                            icon: FIcons.clock,
                            label:
                                DesktopTorrentStatusFilter.checkWaiting.label,
                            count:
                                statusCounts[DesktopTorrentStatusFilter
                                    .checkWaiting] ??
                                0,
                            selected:
                                desktopStatus ==
                                DesktopTorrentStatusFilter.checkWaiting,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.checkWaiting,
                            ),
                          ),
                          _DesktopFilterItem(
                            icon: FIcons.check,
                            label: DesktopTorrentStatusFilter.completed.label,
                            count:
                                statusCounts[DesktopTorrentStatusFilter
                                    .completed] ??
                                0,
                            selected:
                                desktopStatus ==
                                DesktopTorrentStatusFilter.completed,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.completed,
                            ),
                          ),
                          _DesktopFilterItem(
                            icon: FIcons.circleAlert,
                            label: DesktopTorrentStatusFilter.error.label,
                            count:
                                statusCounts[DesktopTorrentStatusFilter
                                    .error] ??
                                0,
                            selected:
                                desktopStatus ==
                                DesktopTorrentStatusFilter.error,
                            onTap: () => _setDesktopStatus(
                              DesktopTorrentStatusFilter.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _DesktopResizableFilterSection(
                      id: 'category',
                      title: '分类',
                      height: sectionHeights['category'] ?? 38,
                      collapsed: _isSectionCollapsed('category'),
                      onToggle: () => _toggleSection('category'),
                      onResize: (delta) => _resizeSection('category', delta),
                      actions: isQb && downloader != null
                          ? [
                              _DesktopFilterActionButton(
                                icon: FIcons.plus,
                                tooltip: '新增分类',
                                onTap: () => _showCategoryEditor(downloader),
                              ),
                            ]
                          : const [],
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        children: [
                          _DesktopFilterItem(
                            icon: FIcons.folder,
                            label: '全部分类',
                            count: allTorrents.length,
                            selected: category.isEmpty,
                            onTap: () =>
                                ref
                                        .read(torrentCategoryProvider.notifier)
                                        .state =
                                    '',
                          ),
                          ..._desktopCategoryFilterItems(
                            categories: categories,
                            counts: categoryCounts,
                            selectedCategory: category,
                            tree: !isQb,
                            onSelect: (item) =>
                                ref
                                        .read(torrentCategoryProvider.notifier)
                                        .state =
                                    item,
                            trailingActionsBuilder: (item) =>
                                isQb && downloader != null
                                ? [
                                    _DesktopInlineActionButton(
                                      icon: FIcons.pencil,
                                      tooltip: '编辑分类',
                                      onTap: () => _showCategoryEditor(
                                        downloader,
                                        categoryName: item,
                                      ),
                                    ),
                                    _DesktopInlineActionButton(
                                      icon: FIcons.trash2,
                                      tooltip: '删除分类',
                                      destructive: true,
                                      onTap: () => _confirmDeleteCategory(
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
                    _DesktopResizableFilterSection(
                      id: 'tag',
                      title: '标签',
                      height: sectionHeights['tag'] ?? 38,
                      collapsed: _isSectionCollapsed('tag'),
                      onToggle: () => _toggleSection('tag'),
                      onResize: (delta) => _resizeSection('tag', delta),
                      actions: isQb && downloader != null
                          ? [
                              _DesktopFilterActionButton(
                                icon: FIcons.plus,
                                tooltip: '新增标签',
                                onTap: () => _showTagEditor(downloader),
                              ),
                            ]
                          : const [],
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        children: [
                          _DesktopFilterItem(
                            icon: FIcons.tags,
                            label: '全部标签',
                            count: allTorrents.length,
                            selected: tag.isEmpty,
                            onTap: () =>
                                ref.read(torrentTagProvider.notifier).state =
                                    '',
                          ),
                          for (final item in tags)
                            _DesktopFilterItem(
                              icon: FIcons.tag,
                              label: item,
                              count: tagCounts[item] ?? 0,
                              selected: tag == item,
                              onTap: () =>
                                  ref.read(torrentTagProvider.notifier).state =
                                      item,
                              trailingActions: isQb && downloader != null
                                  ? [
                                      _DesktopInlineActionButton(
                                        icon: FIcons.pencil,
                                        tooltip: '编辑标签',
                                        onTap: () => _showTagEditor(
                                          downloader,
                                          oldTag: item,
                                        ),
                                      ),
                                      _DesktopInlineActionButton(
                                        icon: FIcons.trash2,
                                        tooltip: '删除标签',
                                        destructive: true,
                                        onTap: () =>
                                            _confirmDeleteTag(downloader, item),
                                      ),
                                    ]
                                  : const [],
                            ),
                        ],
                      ),
                    ),
                    _DesktopResizableFilterSection(
                      id: 'site',
                      title: '站点',
                      height: sectionHeights['site'] ?? 38,
                      collapsed: _isSectionCollapsed('site'),
                      onToggle: () => _toggleSection('site'),
                      onResize: (delta) => _resizeSection('site', delta),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                        children: [
                          _DesktopFilterItem(
                            icon: FIcons.globe,
                            label: '全部站点',
                            count: allTorrents.length,
                            selected: site.isEmpty,
                            onTap: () =>
                                ref
                                        .read(
                                          torrentSiteFilterProvider.notifier,
                                        )
                                        .state =
                                    '',
                          ),
                          for (final item in sites)
                            _DesktopFilterItem(
                              icon: FIcons.globe,
                              label: item.displayName,
                              count: siteCounts[item.key] ?? 0,
                              selected: site == item.key,
                              onTap: () =>
                                  ref
                                      .read(torrentSiteFilterProvider.notifier)
                                      .state = item
                                      .key,
                            ),
                        ],
                      ),
                    ),
                    if (_collapsedSections.length == _sectionIds.length)
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

  Map<String, double> _resolvedSectionHeights(double availableHeight) {
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
        (availableHeight - _sectionIds.length * _sectionBottomGap).clamp(
          0.0,
          double.infinity,
        );
    final expandedArea =
        (sectionArea - collapsed.length * _collapsedSectionHeight).clamp(
          0.0,
          double.infinity,
        );
    final totalWeight = expanded.fold<double>(
      0,
      (sum, id) => sum + (_sectionWeights[id] ?? 1),
    );

    for (final id in expanded) {
      heights[id] = expandedArea * ((_sectionWeights[id] ?? 1) / totalWeight);
    }

    return heights;
  }

  bool _isSectionCollapsed(String id) => _collapsedSections.contains(id);

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
        .where((sectionId) => !_isSectionCollapsed(sectionId))
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
      final adjustedNeighbor = (neighborWeight - (next - current)).clamp(
        0.35,
        4.0,
      );
      _sectionWeights[id] = next;
      _sectionWeights[neighbor] = adjustedNeighbor;
    });
  }

  void _setDesktopStatus(DesktopTorrentStatusFilter status) {
    ref.read(desktopTorrentStatusFilterProvider.notifier).state = status;
  }

  void _resetFilters() {
    _searchCtrl.clear();
    ref.read(torrentSearchProvider.notifier).state = '';
    ref.read(torrentFilterProvider.notifier).state = TorrentFilter.all;
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
        download_providers.downloaderCategoriesProvider(downloader.id).future,
      );
      for (final item in categories) {
        if (item.name == categoryName) {
          category = item;
          break;
        }
      }
    }
    if (!mounted) return;

    final nameCtrl = TextEditingController(text: categoryName ?? '');
    final pathCtrl = TextEditingController(text: category?.savePath ?? '');
    showDialog(
      context: context,
      builder: (ctx) => _DesktopInputDialog(
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
              download_providers.downloaderCategoriesProvider(downloader.id),
            );
            unawaited(
              ref
                  .read(torrentListProvider(widget.downloaderId).notifier)
                  .refresh(),
            );
            if (ctx.mounted) Navigator.pop(ctx);
            Toast.success(editing ? '分类已更新' : '分类已创建');
          } catch (e, st) {
            AppLogger.error('保存 QB 分类失败', e, st);
            Toast.error('保存分类失败');
          }
        },
      ),
    );
  }

  void _confirmDeleteCategory(Downloader downloader, String category) {
    _showDesktopConfirmDialog(
      context,
      title: '删除分类',
      message: '确定删除「$category」吗？不会删除种子文件。',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteCategory(downloader.id, category);
          ref.invalidate(
            download_providers.downloaderCategoriesProvider(downloader.id),
          );
          if (ref.read(torrentCategoryProvider) == category) {
            ref.read(torrentCategoryProvider.notifier).state = '';
          }
          unawaited(
            ref
                .read(torrentListProvider(widget.downloaderId).notifier)
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
      builder: (ctx) => _DesktopInputDialog(
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
              download_providers.downloaderTagsProvider(downloader.id),
            );
            if (ref.read(torrentTagProvider) == oldTag) {
              ref.read(torrentTagProvider.notifier).state = tag;
            }
            unawaited(
              ref
                  .read(torrentListProvider(widget.downloaderId).notifier)
                  .refresh(),
            );
            if (ctx.mounted) Navigator.pop(ctx);
            Toast.success(editing ? '标签已更新' : '标签已创建');
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
    final torrents =
        ref
            .read(torrentListProvider(widget.downloaderId))
            .valueOrNull
            ?.torrents ??
        const <Torrent>[];
    final hashes = torrents
        .where((torrent) => torrent.labels.contains(oldTag))
        .map((torrent) => torrent.hashString)
        .where((hash) => hash.isNotEmpty)
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
    _showDesktopConfirmDialog(
      context,
      title: '删除标签',
      message: '确定删除「$tag」吗？',
      destructive: true,
      onConfirm: () async {
        try {
          await DownloaderService.deleteTag(downloader.id, tag);
          ref.invalidate(
            download_providers.downloaderTagsProvider(downloader.id),
          );
          if (ref.read(torrentTagProvider) == tag) {
            ref.read(torrentTagProvider.notifier).state = '';
          }
          unawaited(
            ref
                .read(torrentListProvider(widget.downloaderId).notifier)
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

List<String> _torrentPathCategoryLevels(String rawPath) {
  final path = rawPath.trim();
  if (path.isEmpty) return const [];
  final normalized = path.replaceAll('\\', '/');
  final parts = normalized
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return const [];
  return [for (var i = 0; i < parts.length; i++) parts.take(i + 1).join('/')];
}

String _torrentCategoryLabel(Torrent torrent) {
  if (torrent.category.isNotEmpty) return torrent.category;
  final levels = _torrentPathCategoryLevels(torrent.downloadDir);
  return levels.isEmpty ? '' : levels.last;
}

List<String> _torrentCategoryFilterLabels(Torrent torrent) {
  if (torrent.category.isNotEmpty) return [torrent.category];
  return _torrentPathCategoryLevels(torrent.downloadDir);
}

List<Widget> _desktopCategoryFilterItems({
  required List<String> categories,
  required Map<String, int> counts,
  required String selectedCategory,
  required bool tree,
  required ValueChanged<String> onSelect,
  required List<Widget> Function(String item) trailingActionsBuilder,
}) {
  final sorted = List<String>.from(categories)..sort(_compareCategoryPath);
  return [
    for (final item in sorted)
      _DesktopFilterItem(
        icon: tree ? _categoryTreeIcon(item) : FIcons.folder,
        label: tree ? _categoryTreeLabel(item) : item,
        count: counts[item] ?? 0,
        selected: selectedCategory == item,
        onTap: () => onSelect(item),
        indent: tree ? _categoryTreeIndent(item) : 0,
        trailingActions: trailingActionsBuilder(item),
      ),
  ];
}

int _compareCategoryPath(String a, String b) {
  final aParts = a.split('/');
  final bParts = b.split('/');
  for (var i = 0; i < min(aParts.length, bParts.length); i++) {
    final cmp = aParts[i].toLowerCase().compareTo(bParts[i].toLowerCase());
    if (cmp != 0) return cmp;
  }
  return aParts.length.compareTo(bParts.length);
}

String _categoryTreeLabel(String category) {
  final parts = category.split('/').where((part) => part.isNotEmpty).toList();
  return parts.isEmpty ? category : parts.last;
}

double _categoryTreeIndent(String category) {
  final depth = category.split('/').where((part) => part.isNotEmpty).length - 1;
  return max(0, depth) * 14.0;
}

IconData _categoryTreeIcon(String category) {
  final depth = category.split('/').where((part) => part.isNotEmpty).length;
  return depth <= 1 ? FIcons.folder : FIcons.folderOpen;
}

Map<DesktopTorrentStatusFilter, int> _desktopStatusCounts(
  List<Torrent> torrents,
) {
  final counts = {
    for (final filter in DesktopTorrentStatusFilter.values) filter: 0,
  };
  counts[DesktopTorrentStatusFilter.all] = torrents.length;
  for (final torrent in torrents) {
    for (final filter in DesktopTorrentStatusFilter.values) {
      if (filter == DesktopTorrentStatusFilter.all) continue;
      if (matchesDesktopTorrentStatus(torrent, filter)) {
        counts[filter] = (counts[filter] ?? 0) + 1;
      }
    }
  }
  return counts;
}

class _DesktopResizableFilterSection extends StatelessWidget {
  final String id;
  final String title;
  final bool collapsed;
  final double height;
  final VoidCallback onToggle;
  final ValueChanged<double> onResize;
  final List<Widget> actions;
  final Widget child;

  const _DesktopResizableFilterSection({
    required this.id,
    required this.title,
    required this.collapsed,
    required this.height,
    required this.onToggle,
    required this.onResize,
    required this.child,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final expanded = !collapsed;
    final sectionHeight = expanded ? height : 48.0;

    return SizedBox(
      height: sectionHeight,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        decoration: BoxDecoration(
          color: cs.background,
          border: Border.all(color: cs.border, width: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            SizedBox(
              height: 38,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 6, 0),
                    child: Row(
                      children: [
                        Icon(
                          expanded ? FIcons.chevronDown : FIcons.chevronRight,
                          size: 14,
                          color: cs.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.mutedForeground,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (expanded) ...[
              Divider(height: 1, color: cs.border),
              Expanded(child: child),
              MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (details) => onResize(details.delta.dy),
                  child: SizedBox(
                    height: 8,
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: cs.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopFilterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final double indent;
  final List<Widget> trailingActions;

  const _DesktopFilterItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.indent = 0,
    this.trailingActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 34,
          padding: EdgeInsets.only(left: 8 + indent, right: 8),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? cs.primary : cs.mutedForeground,
              ),
              const SizedBox(width: 8),
              Expanded(
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
              const SizedBox(width: 8),
              ...trailingActions,
              if (trailingActions.isNotEmpty) const SizedBox(width: 4),
              Container(
                constraints: const BoxConstraints(minWidth: 22),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.mutedForeground.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? cs.primary : cs.mutedForeground,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _DesktopStatusGroup extends StatefulWidget {
  final String title;
  final IconData icon;
  final DesktopTorrentStatusFilter group;
  final List<DesktopTorrentStatusFilter> children;
  final DesktopTorrentStatusFilter selected;
  final Map<DesktopTorrentStatusFilter, int> counts;
  final ValueChanged<DesktopTorrentStatusFilter> onTap;

  const _DesktopStatusGroup({
    required this.title,
    required this.icon,
    required this.group,
    required this.children,
    required this.selected,
    required this.counts,
    required this.onTap,
  });

  @override
  State<_DesktopStatusGroup> createState() => _DesktopStatusGroupState();
}

class _DesktopStatusGroupState extends State<_DesktopStatusGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final selectedInGroup =
        widget.selected == widget.group ||
        widget.children.contains(widget.selected);
    return Column(
      children: [
        _DesktopFilterItem(
          icon: widget.icon,
          label: widget.title,
          count: widget.counts[widget.group] ?? 0,
          selected: selectedInGroup,
          onTap: () => widget.onTap(widget.group),
          trailingActions: [
            _DesktopInlineActionButton(
              icon: _expanded ? FIcons.chevronDown : FIcons.chevronRight,
              tooltip: _expanded ? '收起子状态' : '展开子状态',
              onTap: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ),
        if (_expanded)
          for (final child in widget.children)
            _DesktopFilterItem(
              icon: _desktopStatusIcon(child),
              label: child.label,
              count: widget.counts[child] ?? 0,
              selected: widget.selected == child,
              onTap: () => widget.onTap(child),
              indent: 18,
            ),
      ],
    );
  }
}

IconData _desktopStatusIcon(DesktopTorrentStatusFilter filter) {
  return switch (filter) {
    DesktopTorrentStatusFilter.all => FIcons.list,
    DesktopTorrentStatusFilter.active => FIcons.activity,
    DesktopTorrentStatusFilter.downloadingActive => FIcons.arrowDown,
    DesktopTorrentStatusFilter.uploadingActive => FIcons.arrowUp,
    DesktopTorrentStatusFilter.waiting => FIcons.timer,
    DesktopTorrentStatusFilter.downloadWaiting => FIcons.clock,
    DesktopTorrentStatusFilter.seedWaiting => FIcons.clock,
    DesktopTorrentStatusFilter.checking => FIcons.rotateCw,
    DesktopTorrentStatusFilter.checkWaiting => FIcons.clock,
    DesktopTorrentStatusFilter.paused => FIcons.pause,
    DesktopTorrentStatusFilter.pausedDownloading => FIcons.pause,
    DesktopTorrentStatusFilter.pausedCompleted => FIcons.pause,
    DesktopTorrentStatusFilter.stalledDownloading => FIcons.circleDashed,
    DesktopTorrentStatusFilter.stalledUploading => FIcons.circleDashed,
    DesktopTorrentStatusFilter.completed => FIcons.check,
    DesktopTorrentStatusFilter.error => FIcons.circleAlert,
  };
}

class _DesktopFilterActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _DesktopFilterActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 26,
            height: 26,
            child: Icon(icon, size: 14, color: cs.mutedForeground),
          ),
        ),
      ),
    );
  }
}

class _DesktopInlineActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool destructive;

  const _DesktopInlineActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 22,
            height: 22,
            child: Icon(
              icon,
              size: 13,
              color: destructive ? cs.destructive : cs.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopInputDialog extends StatelessWidget {
  final String title;
  final String primaryLabel;
  final TextEditingController primaryController;
  final String? secondaryLabel;
  final TextEditingController? secondaryController;
  final bool primaryEnabled;
  final Future<void> Function() onSubmit;

  const _DesktopInputDialog({
    required this.title,
    required this.primaryLabel,
    required this.primaryController,
    required this.onSubmit,
    this.secondaryLabel,
    this.secondaryController,
    this.primaryEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Dialog(
      backgroundColor: cs.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              FTextField(
                controller: primaryController,
                enabled: primaryEnabled,
                label: Text(primaryLabel),
              ),
              if (secondaryController != null && secondaryLabel != null) ...[
                const SizedBox(height: 12),
                FTextField(
                  controller: secondaryController!,
                  label: Text(secondaryLabel!),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    style: FButtonStyle.ghost(),
                    onPress: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  FButton(onPress: onSubmit, child: const Text('保存')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showDesktopConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required Future<void> Function() onConfirm,
  bool destructive = false,
}) {
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 380,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: destructive ? cs.destructive : cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
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
                      style: destructive
                          ? FButtonStyle.destructive()
                          : FButtonStyle.primary(),
                      onPress: () async {
                        Navigator.pop(ctx);
                        await onConfirm();
                      },
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

enum _DesktopTorrentColumn {
  queueId('queueId', '队列ID', 72, TorrentSort.queuePosition),
  name('name', '名称', 320, TorrentSort.name),
  selectedSize('selectedSize', '选定大小', 94, TorrentSort.size),
  totalSize('totalSize', '总大小', 94, TorrentSort.size),
  progress('progress', '进度', 110, TorrentSort.progress),
  status('status', '状态', 86, null),
  seeds('seeds', '种子', 64, null),
  peers('peers', '用户', 64, null),
  download('download', '下载速度', 96, TorrentSort.downloadSpeed),
  upload('upload', '上传速度', 96, TorrentSort.uploadSpeed),
  eta('eta', '剩余时间', 110, null),
  ratio('ratio', '分享率', 72, TorrentSort.ratio),
  category('category', '分类', 110, null),
  tags('tags', '标签', 160, null),
  added('added', '添加于', 92, TorrentSort.addedDate),
  completed('completed', '完成于', 92, null),
  tracker('tracker', 'Tracker（站点）', 130, null),
  speedLimit('speedLimit', '下载/上传限速', 150, null),
  downloaded('downloaded', '已下载', 90, null),
  uploaded('uploaded', '已上传', 90, null),
  sessionTransfer('sessionTransfer', '本次会话上传/下载', 150, null),
  savePath('savePath', '保存路径', 220, null),
  ratioLimit('ratioLimit', '分享率限制', 96, null),
  lastSeenComplete('lastSeenComplete', '最后完整可见', 118, null),
  activity('activity', '最后活动', 92, TorrentSort.activityDate);

  final String id;
  final String label;
  final double width;
  final TorrentSort? sort;

  const _DesktopTorrentColumn(this.id, this.label, this.width, this.sort);
}

const _defaultDesktopTorrentColumns = {
  _DesktopTorrentColumn.queueId,
  _DesktopTorrentColumn.name,
  _DesktopTorrentColumn.progress,
  _DesktopTorrentColumn.status,
  _DesktopTorrentColumn.selectedSize,
  _DesktopTorrentColumn.download,
  _DesktopTorrentColumn.upload,
  _DesktopTorrentColumn.ratio,
  _DesktopTorrentColumn.category,
  _DesktopTorrentColumn.tracker,
  _DesktopTorrentColumn.activity,
};

final _desktopTorrentColumnsProvider =
    StateProvider.autoDispose<Set<_DesktopTorrentColumn>>(
      (_) => Set<_DesktopTorrentColumn>.of(_defaultDesktopTorrentColumns),
    );

List<_DesktopTorrentColumn> _visibleDesktopTorrentColumns(
  Set<_DesktopTorrentColumn> visible,
) {
  final effective = visible.isEmpty ? {_DesktopTorrentColumn.name} : visible;
  return _DesktopTorrentColumn.values
      .where(effective.contains)
      .toList(growable: false);
}

double _desktopTorrentTableWidth(List<_DesktopTorrentColumn> columns) {
  return columns.fold<double>(24, (sum, column) => sum + column.width);
}

class _DesktopTorrentTable extends ConsumerStatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final String? selectedHash;
  final ValueChanged<Torrent> onSelect;

  const _DesktopTorrentTable({
    required this.downloaderId,
    required this.downloaderType,
    required this.selectedHash,
    required this.onSelect,
  });

  @override
  ConsumerState<_DesktopTorrentTable> createState() =>
      _DesktopTorrentTableState();
}

class _DesktopTorrentTableState extends ConsumerState<_DesktopTorrentTable> {
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
    final cs = FTheme.of(context).colors;
    final downloaderId = widget.downloaderId;
    final asyncData = ref.watch(torrentListProvider(downloaderId));
    final torrents = ref.watch(filteredTorrentsProvider(downloaderId));
    final categories = ref.watch(availableCategoriesProvider(downloaderId));
    final tags = ref.watch(availableTagsProvider(downloaderId));
    final matcher = ref.watch(torrentSiteMatcherProvider);
    final visibleColumns = _visibleDesktopTorrentColumns(
      ref.watch(_desktopTorrentColumnsProvider),
    );
    final tableWidth = _desktopTorrentTableWidth(visibleColumns);

    if (asyncData.isLoading && asyncData.valueOrNull == null) {
      return Center(child: FProgress.circularIcon());
    }

    if (asyncData is AsyncError) {
      return _DesktopEmptyState(
        icon: FIcons.cloudOff,
        title: '连接失败',
        actionLabel: '重试',
        onAction: () =>
            ref.read(torrentListProvider(downloaderId).notifier).refresh(),
      );
    }

    if (torrents.isEmpty) {
      return _DesktopEmptyState(
        icon: FIcons.inbox,
        title: (asyncData.valueOrNull?.torrents.isEmpty ?? true)
            ? '暂无种子'
            : '当前筛选无结果',
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border.all(color: cs.border, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = max(tableWidth, constraints.maxWidth + 1);
          return Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            trackVisibility: true,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.horizontal,
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
                          return _DesktopTorrentRow(
                            columns: visibleColumns,
                            torrent: torrent,
                            selected:
                                hash.isNotEmpty && hash == widget.selectedHash,
                            siteMatch: matcher.match(torrent),
                            onTap: () => widget.onSelect(torrent),
                            onDoubleTap: () => _showDetail(
                              context,
                              torrent,
                              matcher.match(torrent),
                            ),
                            onSecondaryTapDown: (details) => _showContextMenu(
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
    );
  }

  void _showDetail(
    BuildContext context,
    Torrent torrent,
    TorrentSiteMatch? siteMatch,
  ) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
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
    final action = await _showDesktopContextMenu(
      context: context,
      position: position,
      items: _desktopContextMenuItems(
        torrent: torrent,
        type: widget.downloaderType,
        categories: categories,
        tags: tags,
      ),
      submenus: {
        _desktopCategorySubmenuAction: _desktopCategorySubmenuItems(
          torrent: torrent,
          categories: categories,
        ),
        _desktopTagSubmenuAction: _desktopTagSubmenuItems(
          torrent: torrent,
          tags: tags,
        ),
        _desktopCopySubmenuAction: _desktopCopySubmenuItems(),
      },
    );
    if (!context.mounted || action == null) return;
    await _handleDesktopContextMenuAction(
      context: context,
      ref: ref,
      downloaderId: widget.downloaderId,
      downloaderType: widget.downloaderType,
      torrent: torrent,
      siteMatch: siteMatch,
      action: action,
    );
  }
}

const _desktopCategorySubmenuAction = '__desktop_category_submenu__';
const _desktopTagSubmenuAction = '__desktop_tag_submenu__';
const _desktopCopySubmenuAction = '__desktop_copy_submenu__';

List<_DesktopContextMenuItem> _desktopContextMenuItems({
  required Torrent torrent,
  required DownloaderType type,
  required List<String> categories,
  required List<String> tags,
}) {
  final isQb = type == DownloaderType.qbittorrent;
  final isPaused = torrent.torrentStatus == TorrentStatus.stopped;
  final items = <_DesktopContextMenuItem>[
    _desktopMenuItem('detail', Icons.info_outline_rounded, '种子详情'),
    const _DesktopContextMenuItem.divider(),
  ];

  if (isQb) {
    items.addAll([
      _desktopMenuItem(
        'start',
        isPaused ? Icons.play_arrow_rounded : Icons.stop_rounded,
        isPaused ? '继续' : '停止',
      ),
      _desktopMenuItem('force', Icons.double_arrow_rounded, '强制启动'),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem(
        'delete',
        Icons.delete_outline_rounded,
        '删除',
        destructive: true,
      ),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('location', Icons.edit_location_outlined, '更改保存位置'),
    ]);
    if (categories.isNotEmpty || tags.isNotEmpty) {
      items.add(const _DesktopContextMenuItem.divider());
      if (categories.isNotEmpty) {
        items.add(
          _desktopSubmenuItem(
            _desktopCategorySubmenuAction,
            Icons.folder_outlined,
            '分类',
          ),
        );
      }
      if (tags.isNotEmpty) {
        items.add(
          _desktopSubmenuItem(
            _desktopTagSubmenuAction,
            Icons.sell_outlined,
            '标签',
          ),
        );
      }
    }
    items.addAll([
      const _DesktopContextMenuItem.divider(),
      _desktopSubmenuItem(_desktopCopySubmenuAction, Icons.copy_rounded, '复制'),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('auto', Icons.auto_mode_outlined, '自动管理'),
      _desktopMenuItem('upload_limit', Icons.upload_outlined, '限制上传速度'),
      _desktopMenuItem('share_limit', Icons.pie_chart_outline_rounded, '限制分享率'),
      _desktopMenuItem('super_seed', Icons.rocket_launch_outlined, '超级做种'),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('recheck', Icons.fact_check_outlined, '重新校验'),
      _desktopMenuItem('reannounce', Icons.campaign_outlined, '重新汇报'),
      _desktopMenuItem('tracker', Icons.language_outlined, '修改 Tracker'),
      _desktopMenuItem('export', Icons.save_alt_outlined, '导出 .torrent'),
    ]);
  } else {
    items.addAll([
      _desktopMenuItem('force_start', Icons.double_arrow_rounded, '强制开始'),
      _desktopMenuItem('start', Icons.play_arrow_rounded, '开始种子'),
      _desktopMenuItem('pause', Icons.pause_rounded, '暂停种子'),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem(
        'delete',
        Icons.delete_outline_rounded,
        '删除种子',
        destructive: true,
      ),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('recheck', Icons.fact_check_outlined, '重新校验'),
      _desktopMenuItem('reannounce', Icons.campaign_outlined, '重新汇报'),
      _desktopMenuItem('location', Icons.folder_outlined, '修改目录'),
      const _DesktopContextMenuItem.divider(),
      _desktopSubmenuItem(_desktopCopySubmenuAction, Icons.copy_rounded, '复制'),
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('queue_top', Icons.vertical_align_top_rounded, '队列顶部'),
      _desktopMenuItem('queue_up', Icons.arrow_upward_rounded, '向上移动'),
      _desktopMenuItem('queue_down', Icons.arrow_downward_rounded, '向下移动'),
      _desktopMenuItem(
        'queue_bottom',
        Icons.vertical_align_bottom_rounded,
        '队列底部',
      ),
    ]);
    if (tags.isNotEmpty) {
      items.add(const _DesktopContextMenuItem.divider());
      items.add(
        _desktopSubmenuItem(
          _desktopTagSubmenuAction,
          Icons.sell_outlined,
          '标签',
        ),
      );
    }
    items.addAll([
      const _DesktopContextMenuItem.divider(),
      _desktopMenuItem('tracker', Icons.language_outlined, '修改 Tracker'),
    ]);
  }

  return items;
}

List<_DesktopContextMenuItem> _desktopCategorySubmenuItems({
  required Torrent torrent,
  required List<String> categories,
}) {
  return [
    _desktopMenuLabel('_category_label', '分类'),
    for (final category in categories)
      _desktopMenuItem(
        'category::$category',
        category == torrent.category
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        category.isEmpty ? '未分类' : category,
      ),
  ];
}

List<_DesktopContextMenuItem> _desktopTagSubmenuItems({
  required Torrent torrent,
  required List<String> tags,
}) {
  return [
    _desktopMenuLabel('_tag_label', '标签'),
    for (final tag in tags)
      _desktopMenuItem(
        'tag::$tag',
        torrent.labels.contains(tag)
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        tag,
      ),
  ];
}

List<_DesktopContextMenuItem> _desktopCopySubmenuItems() {
  return [
    _desktopMenuItem('copy_name', Icons.text_fields_rounded, '复制名称'),
    _desktopMenuItem('copy_hash', Icons.tag_rounded, '复制哈希'),
    _desktopMenuItem('copy_magnet', FIcons.magnet, '复制磁力链接'),
    _desktopMenuItem('copy_tracker', Icons.link_rounded, '复制 Tracker 地址'),
    _desktopMenuItem('copy_path', Icons.folder_outlined, '复制保存路径'),
  ];
}

Future<String?> _showDesktopContextMenu({
  required BuildContext context,
  required Offset position,
  required List<_DesktopContextMenuItem> items,
  required Map<String, List<_DesktopContextMenuItem>> submenus,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<String?>();
  late final OverlayEntry entry;
  var removed = false;

  void close(String? action) {
    if (removed) return;
    removed = true;
    if (!completer.isCompleted) completer.complete(action);
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (context) => _DesktopContextMenuOverlay(
      position: position,
      items: items,
      submenus: submenus,
      onClose: close,
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

_DesktopContextMenuItem _desktopMenuItem(
  String value,
  IconData icon,
  String label, {
  bool destructive = false,
}) {
  return _DesktopContextMenuItem.action(
    value: value,
    icon: icon,
    label: label,
    destructive: destructive,
  );
}

_DesktopContextMenuItem _desktopSubmenuItem(
  String value,
  IconData icon,
  String label,
) {
  return _DesktopContextMenuItem.submenu(
    value: value,
    icon: icon,
    label: label,
  );
}

_DesktopContextMenuItem _desktopMenuLabel(String value, String label) {
  return _DesktopContextMenuItem.label(value: value, label: label);
}

enum _DesktopContextMenuItemType { action, submenu, label, divider }

class _DesktopContextMenuItem {
  final _DesktopContextMenuItemType type;
  final String value;
  final IconData? icon;
  final String label;
  final bool destructive;

  const _DesktopContextMenuItem.action({
    required this.value,
    required this.icon,
    required this.label,
    this.destructive = false,
  }) : type = _DesktopContextMenuItemType.action;

  const _DesktopContextMenuItem.submenu({
    required this.value,
    required this.icon,
    required this.label,
  }) : type = _DesktopContextMenuItemType.submenu,
       destructive = false;

  const _DesktopContextMenuItem.label({
    required this.value,
    required this.label,
  }) : type = _DesktopContextMenuItemType.label,
       icon = null,
       destructive = false;

  const _DesktopContextMenuItem.divider()
    : type = _DesktopContextMenuItemType.divider,
      value = '',
      icon = null,
      label = '',
      destructive = false;
}

class _DesktopContextMenuOverlay extends StatefulWidget {
  final Offset position;
  final List<_DesktopContextMenuItem> items;
  final Map<String, List<_DesktopContextMenuItem>> submenus;
  final ValueChanged<String?> onClose;

  const _DesktopContextMenuOverlay({
    required this.position,
    required this.items,
    required this.submenus,
    required this.onClose,
  });

  @override
  State<_DesktopContextMenuOverlay> createState() =>
      _DesktopContextMenuOverlayState();
}

class _DesktopContextMenuOverlayState
    extends State<_DesktopContextMenuOverlay> {
  String? _activeSubmenu;

  static const double _mainWidth = 210;
  static const double _submenuWidth = 236;
  static const double _gap = 8;
  static const double _margin = 8;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxMenuHeight = max(
      96.0,
      min(size.height * 2 / 3, size.height - _margin * 2),
    );
    final mainX = _clampOffset(
      widget.position.dx,
      _margin,
      size.width - _mainWidth - _margin,
    );
    final mainY = _clampOffset(
      widget.position.dy,
      _margin,
      size.height - maxMenuHeight - _margin,
    );
    final submenuItems = _activeSubmenu == null
        ? null
        : widget.submenus[_activeSubmenu!];
    final submenuOffset = submenuItems == null
        ? Offset.zero
        : _submenuOffset(
            screen: size,
            mainX: mainX,
            mainY: mainY,
            maxMenuHeight: maxMenuHeight,
          );

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onClose(null),
        child: Stack(
          children: [
            Positioned(
              left: mainX,
              top: mainY,
              child: _DesktopContextMenuPanel(
                width: _mainWidth,
                maxHeight: maxMenuHeight,
                items: widget.items,
                activeSubmenu: _activeSubmenu,
                onAction: widget.onClose,
                onSubmenu: (value) => setState(() => _activeSubmenu = value),
              ),
            ),
            if (submenuItems != null)
              Positioned(
                left: submenuOffset.dx,
                top: submenuOffset.dy,
                child: _DesktopContextMenuPanel(
                  width: _submenuWidth,
                  maxHeight: maxMenuHeight,
                  items: submenuItems,
                  activeSubmenu: null,
                  onAction: widget.onClose,
                  onSubmenu: (value) => setState(() => _activeSubmenu = value),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Offset _submenuOffset({
    required Size screen,
    required double mainX,
    required double mainY,
    required double maxMenuHeight,
  }) {
    final rightX = mainX + _mainWidth + _gap;
    final leftX = mainX - _submenuWidth - _gap;
    final x = rightX + _submenuWidth + _margin <= screen.width
        ? rightX
        : _clampOffset(leftX, _margin, screen.width - _submenuWidth - _margin);
    final y = _clampOffset(
      mainY,
      _margin,
      screen.height - maxMenuHeight - _margin,
    );
    return Offset(x, y);
  }
}

class _DesktopContextMenuPanel extends StatefulWidget {
  final double width;
  final double maxHeight;
  final List<_DesktopContextMenuItem> items;
  final String? activeSubmenu;
  final ValueChanged<String?> onAction;
  final ValueChanged<String> onSubmenu;

  const _DesktopContextMenuPanel({
    required this.width,
    required this.maxHeight,
    required this.items,
    required this.activeSubmenu,
    required this.onAction,
    required this.onSubmenu,
  });

  @override
  State<_DesktopContextMenuPanel> createState() =>
      _DesktopContextMenuPanelState();
}

class _DesktopContextMenuPanelState extends State<_DesktopContextMenuPanel> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: cs.background,
            border: Border.all(color: cs.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: widget.width,
              maxWidth: widget.width,
              maxHeight: widget.maxHeight,
            ),
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: widget.items.length > 12,
              child: SingleChildScrollView(
                controller: _controller,
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in widget.items)
                      _DesktopContextMenuRow(
                        item: item,
                        active:
                            item.type == _DesktopContextMenuItemType.submenu &&
                            item.value == widget.activeSubmenu,
                        onAction: widget.onAction,
                        onSubmenu: widget.onSubmenu,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopContextMenuRow extends StatefulWidget {
  final _DesktopContextMenuItem item;
  final bool active;
  final ValueChanged<String?> onAction;
  final ValueChanged<String> onSubmenu;

  const _DesktopContextMenuRow({
    required this.item,
    required this.active,
    required this.onAction,
    required this.onSubmenu,
  });

  @override
  State<_DesktopContextMenuRow> createState() => _DesktopContextMenuRowState();
}

class _DesktopContextMenuRowState extends State<_DesktopContextMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final item = widget.item;
    return switch (item.type) {
      _DesktopContextMenuItemType.divider => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Divider(height: 1, color: cs.border.withValues(alpha: 0.7)),
      ),
      _DesktopContextMenuItemType.label => SizedBox(
        height: 28,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.label,
              style: TextStyle(
                color: cs.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
        ),
      ),
      _ => _buildActionRow(context, item, cs),
    };
  }

  Widget _buildActionRow(
    BuildContext context,
    _DesktopContextMenuItem item,
    FColors cs,
  ) {
    final active = widget.active || _hovered;
    final color = item.destructive ? const Color(0xFFEF4444) : cs.foreground;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (item.type == _DesktopContextMenuItemType.submenu) {
            widget.onSubmenu(item.value);
          } else {
            widget.onAction(item.value);
          }
        },
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: active ? cs.primary.withValues(alpha: 0.08) : null,
          child: Row(
            children: [
              Icon(item.icon, size: 15, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ),
              if (item.type == _DesktopContextMenuItemType.submenu) ...[
                const SizedBox(width: 12),
                Icon(Icons.chevron_right_rounded, size: 15, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

double _clampOffset(double value, double minValue, double maxValue) {
  if (maxValue < minValue) return minValue;
  return value.clamp(minValue, maxValue).toDouble();
}

Future<void> _handleDesktopContextMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  required DownloaderType downloaderType,
  required Torrent torrent,
  required TorrentSiteMatch? siteMatch,
  required String action,
}) async {
  final isQb = downloaderType == DownloaderType.qbittorrent;
  final hash = torrent.hashString;
  if (hash.isEmpty && action != 'detail') {
    Toast.warning('种子缺少 Hash，无法操作');
    return;
  }

  if (action == 'detail') {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
      builder: (_) => TorrentDetailSheet(
        downloaderId: downloaderId,
        torrent: torrent,
        siteMatch: siteMatch,
      ),
    );
    return;
  }
  if (action == 'delete') {
    _confirmDeleteTorrent(context, ref, downloaderId, downloaderType, torrent);
    return;
  }
  if (action == 'location') {
    _showDesktopLocationDialog(
      context,
      ref,
      downloaderId,
      downloaderType,
      torrent,
    );
    return;
  }
  if (action == 'upload_limit') {
    _showDesktopUploadLimitDialog(context, ref, downloaderId, torrent);
    return;
  }
  if (action == 'share_limit') {
    _showDesktopShareLimitDialog(context, ref, downloaderId, torrent);
    return;
  }
  if (action == 'tracker') {
    _showDesktopTrackerDialog(
      context,
      ref,
      downloaderId,
      downloaderType,
      torrent,
    );
    return;
  }

  if (action.startsWith('copy_')) {
    final value = switch (action) {
      'copy_name' => torrent.name,
      'copy_hash' => torrent.hashString,
      'copy_magnet' => torrent.magnetLink,
      'copy_tracker' =>
        torrent.trackerUrl.isNotEmpty
            ? torrent.trackerUrl
            : torrent.visibleTrackerStats
                  .map((tracker) => tracker.announce)
                  .where((announce) => announce.isNotEmpty)
                  .join('\n'),
      'copy_path' => torrent.downloadDir,
      _ => '',
    };
    if (value.isEmpty) {
      Toast.info('暂无可复制内容');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    Toast.success('已复制');
    return;
  }

  if (action.startsWith('category::')) {
    final category = action.substring('category::'.length);
    await _runDesktopRawAction(
      context: context,
      ref: ref,
      downloaderId: downloaderId,
      action: 'set_category',
      params: {
        'hashes': [hash],
        'category': category,
      },
    );
    return;
  }

  if (action.startsWith('tag::')) {
    final tag = action.substring('tag::'.length);
    final labels = List<String>.from(torrent.labels);
    labels.contains(tag) ? labels.remove(tag) : labels.add(tag);
    await _runDesktopRawAction(
      context: context,
      ref: ref,
      downloaderId: downloaderId,
      action: isQb ? 'add_tags' : 'change_torrent',
      params: isQb
          ? {
              'hashes': [hash],
              'tags': labels,
            }
          : {
              'ids': [hash],
              'labels': labels,
            },
    );
    return;
  }

  final rawAction = switch (action) {
    'start' => isQb ? 'resume' : 'start_torrent',
    'pause' => isQb ? 'pause' : 'stop_torrent',
    'force_start' => 'start_torrent_now',
    'force' => 'set_force_start',
    'auto' => 'set_auto_management',
    'super_seed' => 'set_super_seeding',
    'recheck' => isQb ? 'recheck' : 'verify_torrent',
    'reannounce' => isQb ? 'reannounce' : 'reannounce_torrent',
    'export' => 'export',
    'queue_top' || 'queue_up' || 'queue_down' || 'queue_bottom' => action,
    _ => action,
  };

  final params = switch (rawAction) {
    'set_force_start' => {
      'hashes': [hash],
      'enable': !torrent.forceStart,
    },
    'set_auto_management' => {
      'hashes': [hash],
      'enable': !torrent.autoTmm,
    },
    'set_super_seeding' => {
      'hashes': [hash],
      'enable': !torrent.superSeeding,
    },
    'export' => {
      'hashes': [hash],
      'name': torrent.name,
    },
    _ =>
      isQb
          ? {
              'hashes': [hash],
            }
          : {
              'ids': [hash],
            },
  };

  await _runDesktopRawAction(
    context: context,
    ref: ref,
    downloaderId: downloaderId,
    action: rawAction,
    params: params,
  );
}

Future<bool> _runDesktopRawAction({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  required String action,
  required Map<String, dynamic> params,
}) async {
  final success = await executeTorrentAction(
    ref: ref,
    downloaderId: downloaderId,
    action: action,
    params: params,
  );
  if (!context.mounted) return success;
  if (success) {
    ref.read(torrentListProvider(downloaderId).notifier).refresh();
    Toast.success('操作成功');
  } else {
    Toast.error('操作失败');
  }
  return success;
}

void _showDesktopLocationDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType downloaderType,
  Torrent torrent,
) {
  final ctrl = TextEditingController(text: torrent.downloadDir);
  final isQb = downloaderType == DownloaderType.qbittorrent;
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isQb ? '更改保存位置' : '修改目录',
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                torrent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.mutedForeground, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FTextField(controller: ctrl, hint: '保存路径'),
              const SizedBox(height: 20),
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
                      _runDesktopRawAction(
                        context: context,
                        ref: ref,
                        downloaderId: downloaderId,
                        action: isQb ? 'set_location' : 'move_torrent_data',
                        params: isQb
                            ? {
                                'hashes': [torrent.hashString],
                                'savePath': ctrl.text.trim(),
                              }
                            : {
                                'ids': [torrent.hashString],
                                'savePath': ctrl.text.trim(),
                              },
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

void _showDesktopUploadLimitDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  Torrent torrent,
) {
  final ctrl = TextEditingController(
    text: torrent.uploadLimit > 0
        ? (torrent.uploadLimit / 1024).round().toString()
        : '',
  );
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '限制上传速度',
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              FTextField(controller: ctrl, hint: '上传限制 (KiB/s)，0 为不限制'),
              const SizedBox(height: 20),
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
                      _runDesktopRawAction(
                        context: context,
                        ref: ref,
                        downloaderId: downloaderId,
                        action: 'set_upload_limit',
                        params: {
                          'hashes': [torrent.hashString],
                          'limit': (int.tryParse(ctrl.text) ?? 0) * 1024,
                        },
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

void _showDesktopShareLimitDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  Torrent torrent,
) {
  final ratioCtrl = TextEditingController(
    text: torrent.seedRatioLimit > 0
        ? torrent.seedRatioLimit.toString()
        : '2.0',
  );
  final timeCtrl = TextEditingController(
    text: torrent.secondsSeeding > 0
        ? (torrent.secondsSeeding / 3600).round().toString()
        : '',
  );
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '限制分享率',
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              FTextField(
                controller: ratioCtrl,
                hint: '分享率 (如 2.0，-1 为不限制，-2 为全局)',
              ),
              const SizedBox(height: 8),
              FTextField(controller: timeCtrl, hint: '做种时间限制 (小时)，留空为不限'),
              const SizedBox(height: 20),
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
                      _runDesktopRawAction(
                        context: context,
                        ref: ref,
                        downloaderId: downloaderId,
                        action: 'set_share_limits',
                        params: {
                          'hashes': [torrent.hashString],
                          'ratioLimit': double.tryParse(ratioCtrl.text) ?? -2,
                          'seedingTimeLimit':
                              (double.tryParse(timeCtrl.text) ?? 0) * 3600,
                        },
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

void _showDesktopTrackerDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType downloaderType,
  Torrent torrent,
) {
  final isQb = downloaderType == DownloaderType.qbittorrent;
  final ctrl = TextEditingController(
    text: torrent.visibleTrackerStats
        .map((tracker) => tracker.announce)
        .where((announce) => announce.isNotEmpty)
        .join('\n'),
  );
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '修改 Tracker',
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                torrent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.mutedForeground, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FTextField(
                controller: ctrl,
                hint: '每行一个 Tracker 地址',
                maxLines: 6,
              ),
              const SizedBox(height: 20),
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
                      _runDesktopRawAction(
                        context: context,
                        ref: ref,
                        downloaderId: downloaderId,
                        action: isQb ? 'set_tracker' : 'change_torrent',
                        params: isQb
                            ? {
                                'hashes': [torrent.hashString],
                                'trackerList': ctrl.text,
                              }
                            : {
                                'ids': [torrent.hashString],
                                'trackerList': ctrl.text.split('\n'),
                              },
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

class _DesktopTorrentHeader extends ConsumerWidget {
  final List<_DesktopTorrentColumn> columns;

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
                  ? _TableHeaderText(label: column.label, width: column.width)
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
    final selected = await showMenu<_DesktopTorrentColumn>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        for (final column in _DesktopTorrentColumn.values)
          PopupMenuItem<_DesktopTorrentColumn>(
            value: column,
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _CompactColumnMenuItem(
              label: column.label,
              checked: ref
                  .read(_desktopTorrentColumnsProvider)
                  .contains(column),
            ),
          ),
      ],
    );
    if (selected == null) return;
    final notifier = ref.read(_desktopTorrentColumnsProvider.notifier);
    final next = Set<_DesktopTorrentColumn>.of(notifier.state);
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

class _CompactColumnMenuItem extends StatelessWidget {
  final String label;
  final bool checked;

  const _CompactColumnMenuItem({required this.label, required this.checked});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: checked
              ? Icon(FIcons.check, size: 13, color: cs.primary)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.05,
            ),
          ),
        ),
      ],
    );
  }
}

class _SortableHeader extends ConsumerWidget {
  final String label;
  final double? width;
  final TorrentSort sort;

  const _SortableHeader({required this.label, this.width, required this.sort});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(torrentSortProvider);
    final asc = ref.watch(torrentSortAscProvider);
    final active = current == sort;
    final child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (active) {
          ref.read(torrentSortAscProvider.notifier).state = !asc;
        } else {
          ref.read(torrentSortProvider.notifier).state = sort;
          ref.read(torrentSortAscProvider.notifier).state = true;
        }
      },
      child: Row(
        children: [
          Flexible(
            child: _HeaderLabel(label: label, active: active),
          ),
          if (active) ...[
            const SizedBox(width: 4),
            Icon(asc ? FIcons.arrowUp : FIcons.arrowDown, size: 12),
          ],
        ],
      ),
    );

    if (width == null) return child;
    return SizedBox(width: width, child: child);
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
      child: _HeaderLabel(label: label),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String label;
  final bool active;

  const _HeaderLabel({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: active ? cs.primary : cs.mutedForeground,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DesktopTorrentRow extends StatelessWidget {
  final List<_DesktopTorrentColumn> columns;
  final Torrent torrent;
  final bool selected;
  final TorrentSiteMatch? siteMatch;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final GestureTapDownCallback onSecondaryTapDown;

  const _DesktopTorrentRow({
    required this.columns,
    required this.torrent,
    required this.selected,
    required this.siteMatch,
    required this.onTap,
    required this.onDoubleTap,
    required this.onSecondaryTapDown,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final color = _statusColor(torrent.torrentStatus, torrent.hasError);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapDown: onSecondaryTapDown,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: selected ? cs.primary.withValues(alpha: 0.08) : null,
        child: Row(
          children: [
            for (final column in columns) _buildCell(context, column, color),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    _DesktopTorrentColumn column,
    Color color,
  ) {
    final cs = FTheme.of(context).colors;
    return switch (column) {
      _DesktopTorrentColumn.queueId => _DesktopCell(
        width: column.width,
        text: '${torrent.id > 0 ? torrent.id : torrent.queuePosition}',
      ),
      _DesktopTorrentColumn.name => _DesktopCell(
        width: column.width,
        child: Row(
          children: [
            _StatusDot(color: color),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                torrent.name.isEmpty ? '(无名称)' : torrent.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      _DesktopTorrentColumn.selectedSize => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.sizeWhenDone),
      ),
      _DesktopTorrentColumn.totalSize => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(
          torrent.totalSize > 0 ? torrent.totalSize : torrent.sizeWhenDone,
        ),
      ),
      _DesktopTorrentColumn.status => _DesktopCell(
        width: column.width,
        child: _StatusPill(label: torrent.torrentStatus.label, color: color),
      ),
      _DesktopTorrentColumn.progress => _DesktopCell(
        width: column.width,
        child: _InlineProgress(value: torrent.percentDone, color: color),
      ),
      _DesktopTorrentColumn.seeds => _DesktopCell(
        width: column.width,
        text: '${torrent.peersGettingFromUs}',
      ),
      _DesktopTorrentColumn.peers => _DesktopCell(
        width: column.width,
        text: '${torrent.peersSendingToUs}',
      ),
      _DesktopTorrentColumn.download => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatSpeed(torrent.rateDownload),
        color: torrent.rateDownload > 0 ? _colorDownloading : null,
      ),
      _DesktopTorrentColumn.upload => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatSpeed(torrent.rateUpload),
        color: torrent.rateUpload > 0 ? _colorSeeding : null,
      ),
      _DesktopTorrentColumn.eta => _DesktopCell(
        width: column.width,
        text: _desktopTorrentEta(torrent),
      ),
      _DesktopTorrentColumn.ratio => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatRatio(torrent.uploadRatio),
      ),
      _DesktopTorrentColumn.category => _DesktopCell(
        width: column.width,
        text: _torrentCategoryLabel(torrent).isEmpty
            ? '-'
            : _torrentCategoryLabel(torrent),
      ),
      _DesktopTorrentColumn.tags => _DesktopCell(
        width: column.width,
        text: torrent.labels.isEmpty ? '-' : torrent.labels.join(', '),
      ),
      _DesktopTorrentColumn.added => _DesktopCell(
        width: column.width,
        text: _desktopTorrentTime(torrent.addedDate),
      ),
      _DesktopTorrentColumn.completed => _DesktopCell(
        width: column.width,
        text: _desktopTorrentTime(torrent.doneDate),
      ),
      _DesktopTorrentColumn.tracker => _DesktopCell(
        width: column.width,
        text: siteMatch?.displayName ?? _desktopTorrentTracker(torrent),
      ),
      _DesktopTorrentColumn.speedLimit => _DesktopCell(
        width: column.width,
        text:
            '↓ ${_desktopTorrentSpeedLimit(torrent.downloadLimit)} / ↑ ${_desktopTorrentSpeedLimit(torrent.uploadLimit)}',
      ),
      _DesktopTorrentColumn.downloaded => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.downloadedEver),
      ),
      _DesktopTorrentColumn.uploaded => _DesktopCell(
        width: column.width,
        text: TorrentUtils.formatBytes(torrent.uploadedEver),
      ),
      _DesktopTorrentColumn.sessionTransfer => _DesktopCell(
        width: column.width,
        text: '-',
      ),
      _DesktopTorrentColumn.savePath => _DesktopCell(
        width: column.width,
        text: torrent.downloadDir.isEmpty ? '-' : torrent.downloadDir,
      ),
      _DesktopTorrentColumn.ratioLimit => _DesktopCell(
        width: column.width,
        text: torrent.seedRatioLimit <= 0
            ? '-'
            : TorrentUtils.formatRatio(torrent.seedRatioLimit),
      ),
      _DesktopTorrentColumn.lastSeenComplete => _DesktopCell(
        width: column.width,
        text: '-',
      ),
      _DesktopTorrentColumn.activity => _DesktopCell(
        width: column.width,
        text: _desktopTorrentTime(torrent.activityDate),
      ),
    };
  }
}

String _desktopTorrentEta(Torrent torrent) {
  final remaining = _desktopTorrentRemainingBytes(torrent);
  if (remaining <= 0) return '-';
  if (torrent.rateDownload <= 0) return '--';
  return TorrentUtils.formatDuration((remaining / torrent.rateDownload).ceil());
}

int _desktopTorrentRemainingBytes(Torrent torrent) {
  if (torrent.leftUntilDone > 0) return torrent.leftUntilDone;
  final total = torrent.sizeWhenDone > 0
      ? torrent.sizeWhenDone
      : torrent.totalSize;
  if (total <= 0) return 0;
  final progress = torrent.percentDone.clamp(0.0, 1.0);
  return (total * (1 - progress)).ceil();
}

String _desktopTorrentTime(int timestamp) {
  return timestamp <= 0 ? '-' : TorrentUtils.formatTimeAgo(timestamp);
}

String _desktopTorrentSpeedLimit(int bytesPerSecond) {
  return bytesPerSecond <= 0 ? '不限' : TorrentUtils.formatSpeed(bytesPerSecond);
}

String _desktopTorrentTracker(Torrent torrent) {
  final visible = torrent.visibleTrackerStats;
  if (visible.isEmpty) {
    return torrent.trackerUrl.isEmpty ? '-' : torrent.trackerUrl;
  }
  final first = visible.first;
  if (first.sitename.isNotEmpty) return first.sitename;
  if (first.host.isNotEmpty) return first.host;
  return first.announce.isEmpty ? '-' : first.announce;
}

class _DesktopCell extends StatelessWidget {
  final double width;
  final String? text;
  final Color? color;
  final Widget? child;

  const _DesktopCell({required this.width, this.text, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return SizedBox(
      width: width,
      child:
          child ??
          Text(
            text ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? cs.foreground.withValues(alpha: 0.62),
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InlineProgress extends StatelessWidget {
  final double value;
  final Color color;

  const _InlineProgress({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                backgroundColor: cs.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          TorrentUtils.formatPercent(value),
          style: TextStyle(
            color: cs.foreground.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _DesktopTorrentDetailPanel extends ConsumerWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final String? selectedHash;
  final bool expanded;
  final double height;
  final VoidCallback onToggle;
  final ValueChanged<double> onResize;

  const _DesktopTorrentDetailPanel({
    required this.downloaderId,
    required this.downloaderType,
    required this.selectedHash,
    required this.expanded,
    required this.height,
    required this.onToggle,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = FTheme.of(context).colors;
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
        color: cs.background,
        border: Border.all(color: cs.border, width: 0.5),
        borderRadius: BorderRadius.circular(8),
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
                      Icon(FIcons.info, size: 15, color: cs.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.foreground,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      FButton.icon(
                        style: FButtonStyle.ghost(),
                        onPress: selected == null ? null : onToggle,
                        child: Icon(
                          expanded ? FIcons.chevronDown : FIcons.chevronUp,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected != null)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: expanded
                        ? (details) => onResize(details.delta.dy)
                        : null,
                    child: MouseRegion(
                      cursor: expanded
                          ? SystemMouseCursors.resizeUpDown
                          : SystemMouseCursors.basic,
                      child: SizedBox(
                        width: 80,
                        height: 28,
                        child: Center(
                          child: Container(
                            width: 34,
                            height: 4,
                            decoration: BoxDecoration(
                              color: cs.mutedForeground.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(999),
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
                  ? const _DesktopEmptyState(
                      icon: FIcons.info,
                      title: '选择一个种子查看详情',
                    )
                  : _DesktopTorrentDetailContent(
                      downloaderId: downloaderId,
                      downloaderType: downloaderType,
                      torrent: selected,
                      siteMatch: matcher.match(selected),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Torrent? _selectedTorrent(List<Torrent> torrents) {
    if (torrents.isEmpty) return null;
    if (selectedHash != null && selectedHash!.isNotEmpty) {
      for (final torrent in torrents) {
        if (torrent.hashString == selectedHash) return torrent;
      }
    }
    return null;
  }
}

class _DesktopTorrentDetailContent extends StatefulWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const _DesktopTorrentDetailContent({
    required this.downloaderId,
    required this.downloaderType,
    required this.torrent,
    required this.siteMatch,
  });

  @override
  State<_DesktopTorrentDetailContent> createState() =>
      _DesktopTorrentDetailContentState();
}

class _DesktopTorrentDetailContentState
    extends State<_DesktopTorrentDetailContent> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _DesktopTorrentDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.torrent.hashString != widget.torrent.hashString ||
        oldWidget.downloaderId != widget.downloaderId) {
      _future = _load();
    }
  }

  Future<Map<String, dynamic>> _load() {
    return DownloaderService.fetchTorrentDetail(
      widget.downloaderId,
      widget.torrent.hashString,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        final detail = snapshot.data ?? const <String, dynamic>{};
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final properties = _desktopExtractMap(detail, const [
          'properties',
          'props',
        ]);
        final trackers = _desktopExtractList(detail, const [
          'trackers',
          'trackerStats',
        ]);
        final files = _desktopExtractList(detail, const ['files', 'contents']);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 320.0;
            final tabHeight = max(0.0, maxHeight - 64);
            final rawDetail = Map<String, dynamic>.from(detail)
              ..remove('files')
              ..remove('contents')
              ..remove('trackers')
              ..remove('trackerStats');

            return FTabs(
              scrollable: true,
              physics: const BouncingScrollPhysics(),
              children: [
                FTabEntry(
                  label: const Text('概览'),
                  child: SizedBox(
                    height: tabHeight,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      children: [
                        _DesktopSelectedSummary(
                          torrent: widget.torrent,
                          siteMatch: widget.siteMatch,
                        ),
                        const SizedBox(height: 12),
                        _DesktopDetailSection(
                          title: '概览',
                          icon: FIcons.layoutDashboard,
                          child: _DesktopDetailMetrics(
                            torrent: widget.torrent,
                            properties: properties,
                          ),
                        ),
                        if (snapshot.hasError) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cs.destructive.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '详情加载失败：${snapshot.error}',
                              style: TextStyle(
                                color: cs.destructive,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                FTabEntry(
                  label: const Text('属性'),
                  child: SizedBox(
                    height: tabHeight,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      children: [
                        _DesktopDetailSection(
                          title: '种子字段',
                          icon: FIcons.list,
                          child: _DesktopFieldTable(
                            data: widget.torrent.toJson(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DesktopDetailSection(
                          title: '接口属性',
                          icon: FIcons.database,
                          trailing: loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: FProgress.circularIcon(),
                                )
                              : null,
                          child: properties.isEmpty
                              ? const _DesktopMutedLine('暂无接口属性')
                              : _DesktopFieldTable(data: properties),
                        ),
                        const SizedBox(height: 10),
                        _DesktopDetailSection(
                          title: '原始详情',
                          icon: FIcons.braces,
                          child: rawDetail.isEmpty
                              ? const _DesktopMutedLine('暂无更多字段')
                              : _DesktopFieldTable(data: rawDetail),
                        ),
                      ],
                    ),
                  ),
                ),
                FTabEntry(
                  label: const Text('Tracker'),
                  child: SizedBox(
                    height: tabHeight,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      children: [
                        _DesktopDetailSection(
                          title: 'Tracker',
                          icon: FIcons.radioTower,
                          trailing: loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: FProgress.circularIcon(),
                                )
                              : null,
                          child: _DesktopTrackerList(
                            torrent: widget.torrent,
                            trackers: trackers,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FTabEntry(
                  label: const Text('文件'),
                  child: SizedBox(
                    height: tabHeight,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      children: [
                        _DesktopDetailSection(
                          title: '文件',
                          icon: FIcons.files,
                          trailing: loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: FProgress.circularIcon(),
                                )
                              : null,
                          child: _DesktopFileList(files: files),
                        ),
                      ],
                    ),
                  ),
                ),
                FTabEntry(
                  label: const Text('操作'),
                  child: SizedBox(
                    height: tabHeight,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: _DesktopSelectedActions(
                        downloaderId: widget.downloaderId,
                        downloaderType: widget.downloaderType,
                        torrent: widget.torrent,
                        siteMatch: widget.siteMatch,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _DesktopDetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _DesktopDetailSection({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.foreground.withValues(alpha: 0.018),
        border: Border.all(color: cs.border, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DesktopDetailMetrics extends StatelessWidget {
  final Torrent torrent;
  final Map<String, dynamic> properties;

  const _DesktopDetailMetrics({
    required this.torrent,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final torrentSizeText = TorrentUtils.formatBytes(torrent.sizeWhenDone);
    final propertyTotalSize = properties.isEmpty
        ? ''
        : _desktopPropertyText(properties, const [
            'total_size',
            'totalSize',
            'total_size_bytes',
          ]);
    final items = [
      _DesktopDetailMetric('大小', torrentSizeText, FIcons.hardDrive),
      _DesktopDetailMetric(
        '下载',
        TorrentUtils.formatSpeed(torrent.rateDownload),
        FIcons.arrowDown,
      ),
      _DesktopDetailMetric(
        '上传',
        TorrentUtils.formatSpeed(torrent.rateUpload),
        FIcons.arrowUp,
      ),
      _DesktopDetailMetric(
        '分享率',
        TorrentUtils.formatRatio(torrent.uploadRatio),
        FIcons.chartPie,
      ),
      _DesktopDetailMetric(
        '分类',
        _torrentCategoryLabel(torrent).isEmpty
            ? '未分类'
            : _torrentCategoryLabel(torrent),
        FIcons.folder,
      ),
      _DesktopDetailMetric(
        '标签',
        torrent.labels.isEmpty ? '无' : torrent.labels.join(', '),
        FIcons.tags,
      ),
      _DesktopDetailMetric(
        '保存路径',
        torrent.downloadDir.isEmpty ? '-' : torrent.downloadDir,
        FIcons.folderOpen,
      ),
      _DesktopDetailMetric(
        '内容路径',
        torrent.contentPath.isEmpty ? '-' : torrent.contentPath,
        FIcons.file,
      ),
      _DesktopDetailMetric(
        '添加时间',
        TorrentUtils.formatTimeAgo(torrent.addedDate),
        FIcons.calendarPlus,
      ),
      _DesktopDetailMetric(
        '活动时间',
        TorrentUtils.formatTimeAgo(torrent.activityDate),
        FIcons.clock,
      ),
      if (propertyTotalSize.isNotEmpty &&
          propertyTotalSize != '-' &&
          propertyTotalSize != torrentSizeText)
        _DesktopDetailMetric('总大小', propertyTotalSize, FIcons.database),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => item).toList(growable: false),
    );
  }
}

class _DesktopDetailMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DesktopDetailMetric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      width: 146,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: cs.mutedForeground),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.mutedForeground, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFieldTable extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DesktopFieldTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    if (entries.isEmpty) return const _DesktopMutedLine('暂无字段');

    return Column(
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          _DesktopFieldRow(
            name: entries[i].key,
            value: _desktopFieldValue(entries[i].value),
          ),
          if (i != entries.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DesktopFieldRow extends StatelessWidget {
  final String name;
  final String value;

  const _DesktopFieldRow({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.mutedForeground,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SelectableText(
              value,
              maxLines: 4,
              style: TextStyle(color: cs.foreground, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

String _desktopFieldValue(dynamic value) {
  if (value == null) return '-';
  if (value is Iterable) return value.map(_desktopFieldValue).join(', ');
  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key}: ${_desktopFieldValue(entry.value)}')
        .join('; ');
  }
  final text = value.toString();
  return text.isEmpty ? '-' : text;
}

class _DesktopTrackerList extends StatelessWidget {
  final Torrent torrent;
  final List<Map<String, dynamic>> trackers;

  const _DesktopTrackerList({required this.torrent, required this.trackers});

  @override
  Widget build(BuildContext context) {
    final apiTrackers = trackers
        .where((tracker) => !_desktopIsVirtualTrackerData(tracker))
        .toList();
    final fallback = torrent.visibleTrackerStats
        .map(
          (tracker) => {
            'announce': tracker.announce,
            'host': tracker.host,
            'msg': tracker.lastAnnounceResult,
            'seeds': tracker.seederCount,
            'leeches': tracker.leecherCount,
          },
        )
        .toList();
    final list = apiTrackers.isNotEmpty ? apiTrackers : fallback;
    if (list.isEmpty) return const _DesktopMutedLine('暂无 Tracker 信息');

    return Column(
      children: [
        for (var i = 0; i < list.length; i++) ...[
          _DesktopTrackerRow(data: list[i]),
          if (i != list.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DesktopTrackerRow extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DesktopTrackerRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final url = _desktopValue(data, const ['announce', 'url']);
    final host = _desktopValue(data, const ['host']);
    final msg = _desktopValue(data, const [
      'msg',
      'message',
      'lastAnnounceResult',
    ]);
    final seeds = _desktopValue(data, const [
      'seeds',
      'seederCount',
      'num_seeds',
    ]);
    final leeches = _desktopValue(data, const [
      'leeches',
      'leecherCount',
      'num_leeches',
    ]);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(FIcons.radioTower, size: 14, color: cs.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.isNotEmpty ? host : url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (url.isNotEmpty && url != host) ...[
                  const SizedBox(height: 3),
                  Text(
                    url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: cs.mutedForeground, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'S $seeds  L $leeches${msg.isNotEmpty ? '  $msg' : ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: cs.mutedForeground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DesktopFileList extends StatelessWidget {
  final List<Map<String, dynamic>> files;

  const _DesktopFileList({required this.files});

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) return const _DesktopMutedLine('暂无文件详情');
    return Column(
      children: [
        for (var i = 0; i < files.length; i++) ...[
          _DesktopFileRow(data: files[i]),
          if (i != files.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _DesktopFileRow extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DesktopFileRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final name = _desktopValue(data, const ['name', 'path']);
    final size = _desktopIntValue(data, const ['size', 'length']);
    final progress = _desktopDoubleValue(data, const [
      'progress',
      'availability',
    ]);

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.border.withValues(alpha: 0.7), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(FIcons.file, size: 14, color: cs.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '(未命名文件)' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 3,
                  backgroundColor: cs.border,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            TorrentUtils.formatBytes(size),
            style: TextStyle(color: cs.mutedForeground, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DesktopMutedLine extends StatelessWidget {
  final String text;

  const _DesktopMutedLine(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Text(
      text,
      style: TextStyle(color: cs.mutedForeground, fontSize: 12),
    );
  }
}

List<Map<String, dynamic>> _desktopExtractList(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }
    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
    }
  }
  return const <Map<String, dynamic>>[];
}

Map<String, dynamic> _desktopExtractMap(
  Map<String, dynamic> data,
  List<String> keys,
) {
  for (final key in keys) {
    final value = data[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

String _desktopPropertyText(Map<String, dynamic> data, List<String> keys) {
  final value = _desktopValue(data, keys);
  final parsed = int.tryParse(value);
  if (parsed == null) return value.isEmpty ? '-' : value;
  return TorrentUtils.formatBytes(parsed);
}

String _desktopValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value != null && value.toString().isNotEmpty) return value.toString();
  }
  return '';
}

int _desktopIntValue(Map<String, dynamic> data, List<String> keys) {
  final value = _desktopValue(data, keys);
  return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? 0;
}

double _desktopDoubleValue(Map<String, dynamic> data, List<String> keys) {
  final value = _desktopValue(data, keys);
  return double.tryParse(value) ?? 0;
}

bool _desktopIsVirtualTrackerData(Map<String, dynamic> data) {
  return TorrentUtils.isVirtualTrackerText(
        _desktopValue(data, const ['announce', 'url']),
      ) ||
      TorrentUtils.isVirtualTrackerText(_desktopValue(data, const ['host'])) ||
      TorrentUtils.isVirtualTrackerText(
        _desktopValue(data, const ['name', 'sitename', 'site_name']),
      );
}

class _DesktopSelectedSummary extends StatelessWidget {
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const _DesktopSelectedSummary({
    required this.torrent,
    required this.siteMatch,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final color = _statusColor(torrent.torrentStatus, torrent.hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _StatusDot(color: color),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                torrent.name.isEmpty ? '(无名称)' : torrent.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TorrentProgressBar(
          value: torrent.percentDone,
          color: color,
          trackColor: cs.border,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoTag(
              text: torrent.torrentStatus.label,
              bg: color.withValues(alpha: 0.12),
              fg: color,
            ),
            if (siteMatch != null)
              _InfoTag(
                text: siteMatch!.displayName,
                bg: const Color(0xFF14B8A6).withValues(alpha: 0.12),
                fg: const Color(0xFF0F766E),
              ),
          ],
        ),
      ],
    );
  }
}

class _DesktopSelectedActions extends ConsumerWidget {
  final int downloaderId;
  final DownloaderType downloaderType;
  final Torrent torrent;
  final TorrentSiteMatch? siteMatch;

  const _DesktopSelectedActions({
    required this.downloaderId,
    required this.downloaderType,
    required this.torrent,
    required this.siteMatch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 244,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ActionButton(
            icon: FIcons.play,
            label: downloaderType == DownloaderType.qbittorrent ? '继续' : '开始',
            onPress: () => _runDesktopTorrentAction(
              context: context,
              ref: ref,
              downloaderId: downloaderId,
              downloaderType: downloaderType,
              torrent: torrent,
              action: 'start',
            ),
          ),
          _ActionButton(
            icon: FIcons.pause,
            label: downloaderType == DownloaderType.qbittorrent ? '停止' : '暂停',
            onPress: () => _runDesktopTorrentAction(
              context: context,
              ref: ref,
              downloaderId: downloaderId,
              downloaderType: downloaderType,
              torrent: torrent,
              action: 'pause',
            ),
          ),
          _ActionButton(
            icon: Icons.fact_check_outlined,
            label: '校验',
            onPress: () => _runDesktopTorrentAction(
              context: context,
              ref: ref,
              downloaderId: downloaderId,
              downloaderType: downloaderType,
              torrent: torrent,
              action: 'recheck',
            ),
          ),
          _ActionButton(
            icon: Icons.campaign_outlined,
            label: '汇报',
            onPress: () => _runDesktopTorrentAction(
              context: context,
              ref: ref,
              downloaderId: downloaderId,
              downloaderType: downloaderType,
              torrent: torrent,
              action: 'reannounce',
            ),
          ),
          _ActionButton(
            icon: FIcons.info,
            label: '详情',
            onPress: () => showFSheet(
              context: context,
              side: FLayout.btt,
              mainAxisMaxRatio: 0.9,
              builder: (_) => TorrentDetailSheet(
                downloaderId: downloaderId,
                torrent: torrent,
                siteMatch: siteMatch,
              ),
            ),
          ),
          _ActionButton(
            icon: FIcons.trash2,
            label: '删除',
            destructive: true,
            onPress: () => _confirmDeleteTorrent(
              context,
              ref,
              downloaderId,
              downloaderType,
              torrent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPress;
  final bool destructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPress,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 34,
      child: FButton(
        style: destructive
            ? FButtonStyle.destructive()
            : FButtonStyle.outline(),
        onPress: onPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _DesktopEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _DesktopEmptyState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: cs.foreground.withValues(alpha: 0.18)),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(color: cs.mutedForeground, fontSize: 13),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            FButton(onPress: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

Future<void> _runDesktopTorrentAction({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  required DownloaderType downloaderType,
  required Torrent torrent,
  required String action,
  bool deleteFiles = false,
}) async {
  final hash = torrent.hashString;
  if (hash.isEmpty) {
    Toast.warning('种子缺少 Hash，无法操作');
    return;
  }

  final isQb = downloaderType == DownloaderType.qbittorrent;
  final command = switch (action) {
    'start' => isQb ? 'resume' : 'start_torrent',
    'pause' => isQb ? 'pause' : 'stop_torrent',
    'recheck' => isQb ? 'recheck' : 'verify_torrent',
    'reannounce' => isQb ? 'reannounce' : 'reannounce_torrent',
    'delete' => isQb ? 'delete' : 'remove_torrent',
    _ => action,
  };
  final params = isQb
      ? {
          'hashes': [hash],
          if (action == 'delete') 'deleteFiles': deleteFiles,
        }
      : {
          'ids': [hash],
          if (action == 'delete') 'deleteFiles': deleteFiles,
        };
  final success = await executeTorrentAction(
    ref: ref,
    downloaderId: downloaderId,
    action: command,
    params: params,
  );
  if (!context.mounted) return;
  if (success) {
    ref.read(torrentListProvider(downloaderId).notifier).refresh();
    Toast.success('操作成功');
  } else {
    Toast.error('操作失败');
  }
}

void _confirmDeleteTorrent(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType downloaderType,
  Torrent torrent,
) {
  var deleteFiles = false;
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = FTheme.of(ctx).colors;
      return StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
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
                  '删除种子',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  torrent.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '同时删除文件',
                        style: TextStyle(color: cs.foreground, fontSize: 13),
                      ),
                    ),
                    Switch(
                      value: deleteFiles,
                      onChanged: (value) =>
                          setDialogState(() => deleteFiles = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      style: FButtonStyle.destructive(),
                      onPress: () {
                        Navigator.pop(ctx);
                        _runDesktopTorrentAction(
                          context: context,
                          ref: ref,
                          downloaderId: downloaderId,
                          downloaderType: downloaderType,
                          torrent: torrent,
                          action: 'delete',
                          deleteFiles: deleteFiles,
                        );
                      },
                      child: const Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
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
