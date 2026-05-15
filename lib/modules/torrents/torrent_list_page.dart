import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart'
    as download_providers;
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/download/service/downloader_service.dart';
import 'package:harvest/modules/download/widgets/qb_category_tag_manager.dart';
import 'package:harvest/modules/download/widgets/qb_settings_dialog.dart';
import 'package:harvest/modules/download/widgets/tr_settings_dialog.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:harvest/widgets/shad_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'model/torrent_model.dart';
import 'provider/downloader_provider.dart';
import 'provider/torrent_control_provider.dart';
import 'widgets/desktop_torrent_layout.dart';
import 'widgets/downloader_header_menu.dart';
import 'widgets/downloader_title_selector.dart';
import 'widgets/torrent_list_dialogs.dart';
import 'widgets/torrent_list_mobile.dart';
import 'widgets/torrent_list_refresh_mixin.dart';
import 'widgets/torrent_list_toolbar.dart';
import 'widgets/torrent_refresh_bar.dart';
import 'widgets/torrent_stats_bar.dart';

// re-export 状态颜色供下游使用
export 'widgets/torrent_list_status.dart';

class TorrentListPage extends ConsumerStatefulWidget {
  final int downloaderId;
  final String? downloaderName;
  final DownloaderType downloaderType;

  const TorrentListPage({
    super.key,
    required this.downloaderId,
    this.downloaderName,
    required this.downloaderType,
  });

  @override
  ConsumerState<TorrentListPage> createState() => _TorrentListPageState();
}

class _TorrentListPageState extends ConsumerState<TorrentListPage>
    with TorrentListRefreshMixin {
  TorrentListNotifier? _torrentNotifier;
  late int _currentDownloaderId;
  late DownloaderType _currentDownloaderType;
  String? _selectedTorrentHash;
  Set<String> _selectedTorrentHashes = const {};
  bool _desktopDetailExpanded = false;
  double _desktopDetailHeight = 340;

  @override
  int get currentDownloaderId => _currentDownloaderId;

  @override
  void onRefreshSilently() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(_currentDownloaderId).notifier).refresh(),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentDownloaderId = widget.downloaderId;
    _currentDownloaderType = widget.downloaderType;
    initRefreshListeners();
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
    disposeRefreshTimers();
    _torrentNotifier?.setWsPaused(true);
    _torrentNotifier = null;
    super.dispose();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);
    final downloaders = ref
        .watch(download_providers.downloaderListProvider)
        .valueOrNull;
    final downloader = _findCurrentDownloader(downloaders);
    final currentDownloaderType = downloader == null
        ? _currentDownloaderType
        : _typeForDownloader(downloader);
    final currentDownloaderName =
        downloader?.name ?? widget.downloaderName ?? '种子管理';
    final currentCount = ref
        .watch(filteredTorrentsProvider(_currentDownloaderId))
        .length;

    return EscapeBackScope(
      onBack: () => closeAppSheet(context),
      child: AppBackground(
        child: shadcn.Scaffold(
          backgroundColor: pageBackground,
          headerBackgroundColor: pageBackground,
          headers: [
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: shadcn.IconButton.ghost(
                        icon: const Icon(shadcn.LucideIcons.chevronLeft),
                        onPressed: () => closeAppSheet(context),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52),
                        child: DownloaderTitleSelector(
                          downloaders: downloaders ?? const <Downloader>[],
                          currentDownloaderId: _currentDownloaderId,
                          fallbackTitle: currentDownloaderName,
                          onSelect: _switchDownloader,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: DownloaderHeaderMenu(
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
                            : () =>
                                  _showDownloaderSpeedLimitSettings(downloader),
                        onReplaceTrackers:
                            currentDownloaderType == DownloaderType.qbittorrent
                            ? () => _showTrackerReplaceDialogForDownloader(
                                context,
                                ref,
                                _currentDownloaderId,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: mobile
              ? Column(
                  children: [
                    TorrentListToolbar(
                      downloaderId: _currentDownloaderId,
                      downloaderType: currentDownloaderType,
                    ),
                    TorrentRefreshBar(
                      downloaderId: _currentDownloaderId,
                      onRefresh: _refreshTorrentList,
                      onRefreshStateChanged: syncTorrentRefreshState,
                    ),
                    StatsBar(
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
                      child: TorrentListMobile(
                        downloaderId: _currentDownloaderId,
                        downloaderType: currentDownloaderType,
                        selectedHashes: _selectedTorrentHashes,
                        onSelectionChange: (hashes) => setState(
                          () => _selectedTorrentHashes = Set<String>.of(hashes),
                        ),
                      ),
                    ),
                  ],
                )
              : DesktopTorrentLayout(
                  downloaderId: _currentDownloaderId,
                  downloaderType: currentDownloaderType,
                  downloader: downloader,
                  selectedHash: _selectedTorrentHash,
                  selectedHashes: _selectedTorrentHashes,
                  detailExpanded: _desktopDetailExpanded,
                  detailHeight: _desktopDetailHeight,
                  onSelect: (torrent) => setState(() {
                    _selectedTorrentHash = torrent.hashString;
                    _desktopDetailExpanded = true;
                  }),
                  onSelectionChange: (hashes) => setState(
                    () => _selectedTorrentHashes = Set<String>.of(hashes),
                  ),
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
                  onRefreshStateChanged: syncTorrentRefreshState,
                  onOpenSpeedSettings: downloader == null
                      ? null
                      : () => _showDownloaderSpeedLimitSettings(downloader),
                  onToggleSpeedMode: downloader == null
                      ? null
                      : (enabled) =>
                            _toggleDownloaderSpeedMode(downloader, enabled),
                ),
        ),
      ),
    );
  }

  void _showTrackerReplaceDialogForDownloader(
    BuildContext context,
    WidgetRef ref,
    int downloaderId,
  ) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final theme = shadcn.Theme.of(ctx);
        final cs = theme.colorScheme;
        return Dialog(
          backgroundColor: appSurfaceColor(ctx, cs.background),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 460,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '替换 Tracker',
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '将当前列表中所有匹配的 Tracker URL 替换为新地址',
                    style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '原始 Tracker',
                    style: TextStyle(
                      color: cs.mutedForeground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShadTextField(
                    controller: oldCtrl,
                    hintText: '要替换的 Tracker URL',
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '新 Tracker',
                    style: TextStyle(
                      color: cs.mutedForeground,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ShadTextField(
                    controller: newCtrl,
                    hintText: '替换后的 Tracker URL',
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      shadcn.Button.ghost(
                        onPressed: () => closeAppSheet(ctx),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      shadcn.Button.primary(
                        onPressed: () async {
                          final oldUrl = oldCtrl.text.trim();
                          final newUrl = newCtrl.text.trim();
                          if (oldUrl.isEmpty || newUrl.isEmpty) {
                            Toast.warning('请填写完整的 Tracker URL');
                            return;
                          }
                          closeAppSheet(ctx);
                          await _executeTrackerReplace(
                            downloaderId,
                            oldUrl,
                            newUrl,
                          );
                        },
                        child: const Text('替换'),
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

  Future<void> _executeTrackerReplace(
    int downloaderId,
    String oldUrl,
    String newUrl,
  ) async {
    try {
      final torrents = _currentActionTorrents();
      final hashes = torrents
          .map((t) => t.hashString)
          .where((h) => h.isNotEmpty)
          .toList();
      if (hashes.isEmpty) {
        Toast.info('当前列表没有可操作种子');
        return;
      }

      final success = await executeTorrentAction(
        ref: ref,
        downloaderId: downloaderId,
        action: 'edit_tracker',
        params: {'hashes': hashes, 'origUrl': oldUrl, 'newUrl': newUrl},
      );
      if (!mounted) return;
      if (success) {
        ref.read(torrentListProvider(downloaderId).notifier).refresh();
        Toast.success('Tracker 替换已提交');
      } else {
        Toast.error('Tracker 替换失败');
      }
    } catch (e) {
      Toast.error('Tracker 替换失败');
    }
  }

  // ── 种子操作 ──

  List<Torrent> _currentActionTorrents() =>
      ref.read(filteredTorrentsProvider(_currentDownloaderId));

  List<String> _currentActionIds() => _currentActionTorrents()
      .map((t) => t.hashString)
      .where((h) => h.isNotEmpty)
      .toList();

  void _refreshTorrentList() {
    if (!mounted) return;
    unawaited(
      ref.read(torrentListProvider(_currentDownloaderId).notifier).refresh(),
    );
    Toast.success('已刷新列表');
  }

  // ── 下载器切换 ──

  Downloader? _findCurrentDownloader(List<Downloader>? downloaders) {
    if (downloaders == null) return null;
    for (final d in downloaders) {
      if (d.id == _currentDownloaderId) return d;
    }
    return null;
  }

  DownloaderType _typeForDownloader(Downloader d) =>
      d.isTr ? DownloaderType.transmission : DownloaderType.qbittorrent;

  void _activateCurrentDownloader() {
    final notifier = ref.read(
      torrentListProvider(_currentDownloaderId).notifier,
    );
    _torrentNotifier = notifier;
    final enabled = ref.read(speedEnabledProvider);
    final paused = ref.read(torrentRefreshPausedProvider(_currentDownloaderId));
    notifier.setWsPaused(!enabled || paused);
    restartAutoRefresh();
  }

  void _switchDownloader(Downloader downloader) {
    _switchDownloaderId(downloader.id, _typeForDownloader(downloader));
  }

  void _switchDownloaderId(int downloaderId, DownloaderType downloaderType) {
    if (_currentDownloaderId == downloaderId &&
        _currentDownloaderType == downloaderType) {
      _torrentNotifier?.setWsPaused(true);
      stopAutoRefresh(resetRemaining: true);
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
    stopAutoRefresh(resetRemaining: true);

    // ── 清空种子列表 ──
    ref.invalidate(torrentListProvider(downloaderId));

    setState(() {
      _currentDownloaderId = downloaderId;
      _currentDownloaderType = downloaderType;
      _selectedTorrentHash = null;
      _selectedTorrentHashes = const {};
      _desktopDetailExpanded = false;
    });

    ref.read(torrentSearchProvider.notifier).state = '';
    ref.read(torrentCategoryProvider.notifier).state = '';
    ref.read(torrentTagProvider.notifier).state = '';
    ref.read(torrentSiteFilterProvider.notifier).state = '';
    ref.read(torrentErrorDetailFilterProvider.notifier).state = '';
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

  // ── 对话框 ──

  void _showQbCategoryManager(Downloader downloader) {
    showAppSheet(
      context: context,
      builder: (_) => QbCategoryManagerSheet(downloader: downloader),
    );
  }

  void _showQbTagManager(Downloader downloader) {
    showAppSheet(
      context: context,
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

  // ── 批量操作 ──

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
    showRecheckConfirmDialog(context, count: count).then((confirmed) {
      if (confirmed) {
        _runBatchAction(
          label: '重新校验',
          qbAction: 'recheck',
          trAction: 'verify_torrent',
        );
      }
    });
  }
}
