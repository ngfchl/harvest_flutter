import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/widgets/push_torrent_sheet.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:harvest/widgets/debug_theme_button.dart';
import 'package:harvest/widgets/escape_back_scope.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../widgets/browser_page.dart';
import '../news/douban/model/search_result.dart';
import '../news/douban/service/douban_service.dart';
import '../news/douban/widgets/douban_detail_sheet.dart';
import '../news/tmdb/model/media_item.dart';
import '../news/tmdb/service/tmdb_service.dart';
import '../news/tmdb/widgets/tmdb_detail_sheet.dart';
import '../shell/provider/screenshot_provider.dart';
import '../site/model/site_info.dart';
import '../site/provider/site_provider.dart';
import 'model/search_history_manager.dart';
import 'model/search_mode.dart';
import 'model/search_settings.dart';
import 'model/search_torrent_info.dart';
import 'provider/resource_search_provider.dart';
import 'widgets/downloader_select_sheet.dart';
import 'widgets/search_bar.dart';
import 'widgets/search_settings_sheet.dart';

enum _ResourceSortField { title, subtitle, size, seeders, published }

const _resourceResolutionValues = ['720P', '1080P', '2160P', '4K', '8K'];

class UnifiedSearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  final SearchMode initialMode;

  const UnifiedSearchPage({super.key, this.initialQuery, this.initialMode = SearchMode.media});

  @override
  ConsumerState<UnifiedSearchPage> createState() => _UnifiedSearchPageState();
}

class _UnifiedSearchPageState extends ConsumerState<UnifiedSearchPage> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  SearchMode _mode = SearchMode.media;
  String _query = '';
  String _submittedQuery = '';
  SearchMode? _submittedMode;
  String _mediaQuery = '';
  String _resourceQuery = '';
  String _mediaSubmittedQuery = '';
  String _resourceSubmittedQuery = '';
  int _mediaSearchSerial = 0;
  _ResourceSortField _resourceSortField = _ResourceSortField.published;
  bool _resourceSortAscending = false;
  final Set<String> _resourceFilterSites = {};
  final Set<String> _resourceFilterSales = {};
  final Set<String> _resourceFilterCategories = {};
  final Set<String> _resourceFilterResolutions = {};
  final Set<String> _resourceFilterTags = {};
  final Set<String> _resourceFilterSeasons = {};
  final Set<String> _resourceFilterEpisodes = {};
  bool _resourceFilterHrOnly = false;
  bool _resourceFilterSizeEnabled = false;
  RangeValues _resourceFilterSizeGb = const RangeValues(0, 100);
  OverlayEntry? _resourceFilterOverlay;

  _ResourceFilterData _resourceFilterData() {
    final results = ref.read(resourceSearchProvider).results;
    return _ResourceFilterData(
      sites: _resourceFilterOptions(results, (item) => item.siteId),
      sales: _resourceFilterOptions(results, _resourceSaleValue),
      categories: _resourceFilterOptions(results, (item) => item.category),
      resolutions: _resourceResolutionOptions(results),
      tags: _resourceTagOptions(results),
      seasons: _resourceSeasonOptions(results),
      episodes: _resourceEpisodeOptions(results),
    );
  }

  bool _mediaLoading = false;
  List<MediaItem> _tmdbResults = [];
  List<DoubanSearchResult> _doubanResults = [];

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    final initialQuery = widget.initialQuery?.trim() ?? '';

    if (initialQuery.isNotEmpty) {
      _ctrl.text = initialQuery;
      _query = initialQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _submitSearch(initialQuery, mode: _mode, updateController: false);
        _bindActiveScrollController();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
        _bindActiveScrollController();
      });
    }
  }

  @override
  void dispose() {
    _closeResourceFilterPopover();
    _ctrl.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════
  // 核心逻辑
  // ═══════════════════════════════════════════════

  void _bindActiveScrollController() {
    ref.read(activeScrollControllerProvider.notifier).state = _scrollController;
  }

  void _onTextChanged(String value) {
    final q = value.trim();
    setState(() {
      _query = q;
      _setModeQuery(_mode, q);
      if (q.isEmpty) {
        _clearActiveSubmittedState();
      } else if (_mode == SearchMode.media && q != _mediaSubmittedQuery && _mediaLoading) {
        _mediaSearchSerial++;
        _mediaLoading = false;
      }
    });

    if (_mode == SearchMode.resource &&
        (q.isEmpty || (q != _resourceSubmittedQuery && _submittedMode == SearchMode.resource))) {
      ref.read(resourceSearchProvider.notifier).clear();
    }
  }

  void _doSearch(String query) {
    _submitSearch(query);
  }

  void _submitSearch(String query, {SearchMode? mode, bool updateController = true}) {
    final q = query.trim();
    if (q.isEmpty) return;
    final targetMode = mode ?? _mode;

    if (updateController && _ctrl.text != q) {
      _ctrl.value = TextEditingValue(
        text: q,
        selection: TextSelection.collapsed(offset: q.length),
      );
    }
    _focusNode.unfocus();

    setState(() {
      _mode = targetMode;
      _query = q;
      _setModeQuery(targetMode, q);
      _setModeSubmittedQuery(targetMode, q);
      _submittedQuery = q;
      _submittedMode = targetMode;

      if (targetMode == SearchMode.media) {
        _tmdbResults = [];
        _doubanResults = [];
      } else {
        _resetResourceFilters();
      }
    });

    SearchHistoryManager.addHistory(q);

    if (targetMode == SearchMode.media) {
      _searchMedia(q);
    } else {
      _searchResource(q);
    }
  }

  Future<void> _searchMedia(String q) async {
    final serial = ++_mediaSearchSerial;
    AppLogger.debug('[Search][media] start serial=$serial query="$q"');
    setState(() => _mediaLoading = true);
    final results = await Future.wait([
      TmdbService.search(q).catchError((e, st) {
        AppLogger.error('[Search][media][TMDB] failed query="$q"', e, st);
        return <MediaItem>[];
      }),
      DoubanService.search(q).catchError((e, st) {
        AppLogger.error('[Search][media][Douban] failed query="$q"', e, st);
        return <DoubanSearchResult>[];
      }),
    ]);
    if (!mounted || serial != _mediaSearchSerial) {
      AppLogger.debug('[Search][media] discard serial=$serial current=$_mediaSearchSerial mounted=$mounted query="$q"');
      return;
    }

    final tmdb = results[0] as List<MediaItem>;
    final douban = results[1] as List<DoubanSearchResult>;
    AppLogger.debug(
      '[Search][media] complete serial=$serial query="$q" '
      'tmdb=${tmdb.length} douban=${douban.length}',
    );
    for (var i = 0; i < tmdb.length && i < 8; i++) {
      _debugTmdbItem('state#$i', tmdb[i]);
    }

    setState(() {
      _tmdbResults = tmdb;
      _doubanResults = douban;
      _mediaLoading = false;
    });
  }

  void _debugTmdbItem(String stage, MediaItem item) {
    AppLogger.debug(
      '[Search][media][TMDB][$stage] '
      'id=${item.id} mediaType=${item.mediaType} '
      'title="${item.title}" original="${item.originalTitle}" '
      'releaseDate="${item.releaseDate}" poster="${item.posterPath}" '
      'backdrop="${item.backdropPath}" vote=${item.voteAverage} '
      'voteCount=${item.voteCount} overview_len=${item.overview.length} '
      'genres=${item.genreIds} country=${item.originCountry}',
    );
  }

  void _searchResource(String q) {
    final settings = SearchSettings.load();
    ref
        .read(resourceSearchProvider.notifier)
        .search(q, maxCount: settings.maxCount, sites: _normalizedSearchSiteIds(settings.sites));
  }

  void _switchMode(SearchMode mode) {
    if (mode == _mode) return;
    final savedQuery = _modeQuery(mode);
    final nextQuery = savedQuery.isNotEmpty ? savedQuery : _query;
    final nextSubmittedQuery = _modeSubmittedQuery(mode);
    setState(() {
      _mode = mode;
      _query = nextQuery;
      _setModeQuery(mode, nextQuery);
      _submittedQuery = nextSubmittedQuery;
      _submittedMode = nextSubmittedQuery.isEmpty ? null : mode;
      _ctrl.value = TextEditingValue(
        text: nextQuery,
        selection: TextSelection.collapsed(offset: nextQuery.length),
      );
    });
  }

  void _onClear() {
    _ctrl.clear();
    setState(() {
      _query = '';
      _setModeQuery(_mode, '');
      _clearActiveSubmittedState();
    });
    if (_mode == SearchMode.resource) {
      ref.read(resourceSearchProvider.notifier).clear();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _goResourceSearch(String query) {
    _submitSearch(query, mode: SearchMode.resource);
  }

  String _modeQuery(SearchMode mode) {
    return mode == SearchMode.media ? _mediaQuery : _resourceQuery;
  }

  void _setModeQuery(SearchMode mode, String query) {
    if (mode == SearchMode.media) {
      _mediaQuery = query;
    } else {
      _resourceQuery = query;
    }
  }

  String _modeSubmittedQuery(SearchMode mode) {
    return mode == SearchMode.media ? _mediaSubmittedQuery : _resourceSubmittedQuery;
  }

  void _setModeSubmittedQuery(SearchMode mode, String query) {
    if (mode == SearchMode.media) {
      _mediaSubmittedQuery = query;
    } else {
      _resourceSubmittedQuery = query;
    }
  }

  void _clearActiveSubmittedState() {
    _submittedQuery = '';
    _submittedMode = null;
    _setModeSubmittedQuery(_mode, '');
    if (_mode == SearchMode.media) {
      _mediaLoading = false;
      _tmdbResults = [];
      _doubanResults = [];
      _mediaSearchSerial++;
    } else {
      _resetResourceFilters();
    }
  }

  String _cleanKeyword(String keyword) {
    final idx = keyword.indexOf('||');
    if (idx >= 0) {
      final cleaned = keyword.substring(idx + 2).trim();
      if (cleaned.isNotEmpty) return cleaned;
    }
    return keyword;
  }

  void _onHistoryTap(String keyword) {
    showAppSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = shadcn.Theme.of(ctx).colorScheme;
        final typo = shadcn.Theme.of(ctx).typography;

        return Container(
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: cs.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.mutedForeground.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.border.withValues(alpha: 0.3)),
                ),
                child: Text(
                  keyword,
                  style: typo.small.copyWith(color: cs.foreground),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              _SheetOptionTile(
                icon: shadcn.LucideIcons.film,
                iconColor: Colors.blue,
                title: '搜索信息',
                subtitle: '从 TMDB / 豆瓣搜索影视信息',
                onTap: () {
                  closeAppSheet(ctx);
                  _submitSearch(_cleanKeyword(keyword), mode: SearchMode.media);
                },
              ),
              const SizedBox(height: 4),
              _SheetOptionTile(
                icon: shadcn.LucideIcons.download,
                iconColor: Colors.green,
                title: '搜索资源',
                subtitle: '从已配置站点搜索种子资源',
                onTap: () {
                  closeAppSheet(ctx);
                  _submitSearch(keyword, mode: SearchMode.resource);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: shadcn.Button.outline(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchSettings() {
    showAppSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SearchSettingsSheet(),
    );
  }

  // ═══════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final resourceState = ref.watch(resourceSearchProvider);
    final cs = shadcn.Theme.of(context).colorScheme;
    final history = SearchHistoryManager.getHistory();
    final showHistory = _query.isEmpty && history.isNotEmpty;
    final showResourceProgress =
        _mode == SearchMode.resource &&
        _resourceSubmittedQuery.isNotEmpty &&
        _query == _resourceSubmittedQuery &&
        resourceState.query == _resourceSubmittedQuery &&
        resourceState.searching;

    return EscapeBackScope(
      onBack: () => closeAppSheet(context),
      // ← 加这一层
      child: shadcn.OverlayManagerLayer(
        popoverHandler: const shadcn.PopoverOverlayHandler(),
        tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
        menuHandler: const shadcn.PopoverOverlayHandler(),
        child: Scaffold(
          backgroundColor: cs.background,
          appBar: AppBar(
            backgroundColor: cs.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: shadcn.IconButton.ghost(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: cs.foreground),
              onPressed: () => closeAppSheet(context),
            ),
            leadingWidth: 48,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: UnifiedSearchBar(
                controller: _ctrl,
                focusNode: _focusNode,
                onChanged: _onTextChanged,
                onSubmit: _doSearch,
                onClear: _onClear,
                hint: _mode == SearchMode.media ? '搜索电影、剧集...' : '搜索种子资源...',
              ),
            ),
            actions: [
              const DebugThemeButton.material(),
              if (_mode == SearchMode.resource)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: shadcn.IconButton.ghost(
                    icon: Icon(shadcn.LucideIcons.settings, size: 19, color: cs.foreground),
                    onPressed: _showSearchSettings,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              _buildModeSwitcher(),
              Container(height: 0.5, color: cs.border.withValues(alpha: 0.3)),
              if (showResourceProgress) _buildResourceProgress(resourceState),
              if (showHistory) _buildHistorySuggestions(),
              Expanded(child: _buildBody(context, resourceState)),
            ],
          ),
        ),
      ), // ← OverlayManagerLayer 结束
    );
  }

  // ═══════════════════════════════════════════════
  // 模式切换
  // ═══════════════════════════════════════════════

  Widget _buildModeSwitcher() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: SearchMode.values.map((mode) {
          final active = _mode == mode;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchMode(mode),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: typo.small.copyWith(
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? cs.primaryForeground : cs.mutedForeground,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 资源搜索进度
  // ═══════════════════════════════════════════════

  Widget _buildResourceProgress(ResourceSearchState state) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final msg = state.messages.isNotEmpty ? state.messages.last.text : '搜索中...';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14, height: 14, child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: typo.xSmall.copyWith(color: cs.mutedForeground),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${state.results.length} 条',
            style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
          if (state.results.isNotEmpty) ...[const SizedBox(width: 8), _buildResourceFilterButton()],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 搜索历史
  // ═══════════════════════════════════════════════

  Widget _buildHistorySuggestions() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final history = SearchHistoryManager.getHistory();

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.4), width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Icon(shadcn.LucideIcons.clock, size: 14, color: cs.mutedForeground),
                const SizedBox(width: 6),
                Text(
                  '搜索历史',
                  style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    SearchHistoryManager.clearHistory();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('清除', style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: history.length,
              itemBuilder: (_, i) {
                final keyword = history[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _onHistoryTap(keyword),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                      child: Row(
                        children: [
                          Icon(shadcn.LucideIcons.clock, size: 14, color: cs.mutedForeground.withValues(alpha: 0.4)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(keyword, style: typo.small)),
                          GestureDetector(
                            onTap: () {
                              SearchHistoryManager.removeHistory(keyword);
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                shadcn.LucideIcons.x,
                                size: 14,
                                color: cs.mutedForeground.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 主体
  // ═══════════════════════════════════════════════

  Widget _buildBody(BuildContext context, ResourceSearchState resourceState) {
    if (_query.isEmpty) {
      return _buildEmptyHint('输入${_mode == SearchMode.media ? '影视名称' : '资源关键词'}开始搜索');
    }
    final activeSubmittedQuery = _modeSubmittedQuery(_mode);
    if (activeSubmittedQuery.isEmpty || _query != activeSubmittedQuery) {
      return _buildEmptyHint('按回车开始搜索');
    }
    if (_mode == SearchMode.media) return _buildMediaBody(context);
    return _buildResourceBody(context, resourceState);
  }

  Widget _buildEmptyHint(String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shadcn.LucideIcons.search,
            size: 48,
            color: shadcn.Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: shadcn.Theme.of(
              context,
            ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 影视结果
  // ═══════════════════════════════════════════════

  Widget _buildMediaBody(BuildContext context) {
    if (_mediaLoading) {
      return const Center(child: shadcn.CircularProgressIndicator());
    }
    if (_tmdbResults.isEmpty && _doubanResults.isEmpty) {
      return Center(
        child: Text(
          '没有找到「$_mediaSubmittedQuery」',
          style: shadcn.Theme.of(
            context,
          ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
        ),
      );
    }
    final mobile = context.isMobile;
    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 16, 8, mobile ? 12 : 16, 80),
      children: [
        if (_tmdbResults.isNotEmpty) ..._tmdbResults.map((item) => _buildTmdbTile(context, item)),
        if (_doubanResults.isNotEmpty) ...[
          if (_tmdbResults.isNotEmpty) const SizedBox(height: 4),
          ..._doubanResults.map((item) => _buildDoubanTile(context, item)),
        ],
      ],
    );
  }

  Widget _buildPosterWithBadge({
    required BuildContext context,
    required String imageUrl,
    required String source,
    required Color color,
    Map<String, String>? headers,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 46,
        height: 69,
        child: Stack(
          children: [
            Positioned.fill(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      httpHeaders: headers,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: shadcn.CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                      errorWidget: (_, __, ___) => _posterPh(context),
                    )
                  : _posterPh(context),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3)),
                ),
                child: Text(
                  source,
                  style: const TextStyle(fontSize: 7.5, color: Colors.white, fontWeight: FontWeight.w700, height: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTmdbTile(BuildContext context, MediaItem item) {
    _debugTmdbItem('tile', item);
    final posterUrl = TmdbService.imageUrl(item.posterPath, size: 'w92');
    AppLogger.debug(
      '[Search][media][TMDB][tile] display title="${item.title}" '
      'subtitleDate="${item.releaseDate}" posterUrl="$posterUrl"',
    );
    return _searchResultTile(
      leading: _buildPosterWithBadge(context: context, imageUrl: posterUrl, source: 'TMDB', color: Colors.blue),
      title: item.title,
      subtitle: _tmdbSubtitle(context, item),
      trailing: IconButton(
        icon: Icon(shadcn.LucideIcons.search, size: 16, color: shadcn.Theme.of(context).colorScheme.primary),
        onPressed: () => _goResourceSearch(item.title),
        tooltip: '搜索资源',
      ),
      onTap: () => openTmdbDetail(context, item),
    );
  }

  Widget _tmdbSubtitle(BuildContext context, MediaItem item) {
    AppLogger.debug(
      '[Search][media][TMDB][subtitle] '
      'id=${item.id} date="${item.releaseDate}" vote=${item.voteAverage} type=${item.mediaType}',
    );
    return Row(
      children: [
        if (item.releaseDate.isNotEmpty)
          Text(
            item.releaseDate,
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
          ),
        if (item.voteAverage != null && item.voteAverage! > 0) ...[
          const SizedBox(width: 6),
          Icon(shadcn.LucideIcons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            item.voteAverage!.toStringAsFixed(1),
            style: shadcn.Theme.of(
              context,
            ).typography.xSmall.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
          ),
        ],
        if (item.mediaType.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
            decoration: BoxDecoration(
              color: (item.mediaType == 'movie' ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              item.mediaType == 'movie' ? '电影' : '剧集',
              style: TextStyle(
                fontSize: 9,
                color: item.mediaType == 'movie' ? Colors.blue : Colors.purple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDoubanTile(BuildContext context, DoubanSearchResult item) {
    final target = item.target;
    final hasRating = target.rating.value > 0;
    final ratingText = hasRating ? target.rating.value.toStringAsFixed(1) : '';
    final subjectId = target.id.isNotEmpty ? target.id : item.targetId;
    final isTv = item.targetType == 'tv';

    return _searchResultTile(
      leading: _buildPosterWithBadge(
        context: context,
        imageUrl: target.coverUrl,
        source: '豆瓣',
        color: Colors.green,
        headers: const {'Referer': 'https://movie.douban.com/'},
      ),
      title: target.title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (target.year.isNotEmpty)
                Text(
                  target.year,
                  style: shadcn.Theme.of(
                    context,
                  ).typography.xSmall.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
                ),
              if (ratingText.isNotEmpty) ...[
                const SizedBox(width: 6),
                Icon(shadcn.LucideIcons.star, size: 11, color: Colors.amber),
                const SizedBox(width: 2),
                Text(
                  ratingText,
                  style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                    color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (item.typeName.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: (isTv ? Colors.purple : Colors.blue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    item.typeName,
                    style: TextStyle(
                      fontSize: 9,
                      color: isTv ? Colors.purple : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              if (target.hasLinewatch) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    '可播放',
                    style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
          if (target.cardSubtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              target.cardSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                color: shadcn.Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
          if (!hasRating && target.nullRatingReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                target.nullRatingReason,
                style: shadcn.Theme.of(context).typography.xSmall.copyWith(
                  color: shadcn.Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(shadcn.LucideIcons.search, size: 16, color: shadcn.Theme.of(context).colorScheme.primary),
        onPressed: () => _goResourceSearch(target.title),
        tooltip: '搜索资源',
      ),
      onTap: () {
        if (subjectId.isNotEmpty) openDoubanDetail(context, subjectId);
      },
    );
  }

  Widget _posterPh(BuildContext ctx) => Container(
    color: shadcn.Theme.of(ctx).colorScheme.muted,
    child: Center(
      child: Icon(
        shadcn.LucideIcons.film,
        size: 20,
        color: shadcn.Theme.of(ctx).colorScheme.mutedForeground.withValues(alpha: 0.3),
      ),
    ),
  );

  Widget _searchResultTile({
    required Widget leading,
    required String title,
    required Widget subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final typo = shadcn.Theme.of(context).typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.small.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      subtitle,
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 资源结果
  // ═══════════════════════════════════════════════

  Widget _buildResourceBody(BuildContext context, ResourceSearchState state) {
    if (state.query != _resourceSubmittedQuery) {
      return _buildEmptyHint('按回车开始搜索');
    }

    if (state.results.isEmpty && !state.searching) {
      return Center(
        child: Text(
          '没有找到「$_resourceSubmittedQuery」相关资源',
          style: shadcn.Theme.of(
            context,
          ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
        ),
      );
    }
    return Column(
      children: [
        if (!state.searching && state.messages.isNotEmpty) _buildResourceDoneSummary(state),
        if (state.results.isNotEmpty) _buildResourceSortBar(state),
        Expanded(child: _buildResourceList(state)),
      ],
    );
  }

  Widget _buildResourceDoneSummary(ResourceSearchState state) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final msg = state.messages.last;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.3), width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Row(
          children: [
            Icon(
              msg.isError ? shadcn.LucideIcons.circleAlert : shadcn.LucideIcons.check,
              size: 14,
              color: msg.isError ? Colors.red : Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg.text,
                style: typo.xSmall.copyWith(color: cs.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${state.results.length} 条',
              style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
            ),
            if (state.results.isNotEmpty) ...[const SizedBox(width: 8), _buildResourceFilterButton()],
          ],
        ),
        children: [_buildMessagesList(state)],
      ),
    );
  }

  Widget _buildMessagesList(ResourceSearchState state) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: List.generate(state.messages.length, (i) {
          final msg = state.messages[state.messages.length - 1 - i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  msg.isError ? shadcn.LucideIcons.circleAlert : shadcn.LucideIcons.check,
                  size: 12,
                  color: msg.isError ? Colors.red : Colors.green.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    msg.text,
                    style: typo.xSmall.copyWith(color: msg.isError ? Colors.red : cs.mutedForeground, fontSize: 11),
                  ),
                ),
                Text(
                  '${msg.time.hour.toString().padLeft(2, '0')}:'
                  '${msg.time.minute.toString().padLeft(2, '0')}:'
                  '${msg.time.second.toString().padLeft(2, '0')}',
                  style: typo.xSmall.copyWith(color: cs.mutedForeground.withValues(alpha: 0.4), fontSize: 10),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResourceList(ResourceSearchState state) {
    final mobile = context.isMobile;
    final results = _sortedResourceResults(_filteredResourceResults(state.results));
    if (results.isEmpty) {
      if (state.searching) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 22, height: 22, child: shadcn.CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(height: 12),
              Text(
                '正在搜索资源...',
                style: shadcn.Theme.of(
                  context,
                ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Text(
          '没有符合筛选条件的资源',
          style: shadcn.Theme.of(
            context,
          ).typography.small.copyWith(color: shadcn.Theme.of(context).colorScheme.mutedForeground),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(mobile ? 8 : 16, 8, mobile ? 8 : 16, 80),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) => _buildTorrentCard(results[i]),
    );
  }

  Widget _buildResourceSortBar(ResourceSearchState state) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final filteredCount = _filteredResourceResults(state.results).length;

    return Container(
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border.withValues(alpha: 0.25), width: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
        child: Row(
          children: [
            for (final field in _ResourceSortField.values) ...[
              _buildResourceSortChip(field),
              if (field != _ResourceSortField.values.last) const SizedBox(width: 6),
            ],
            const SizedBox(width: 10),
            _buildResourceFilterResultCount(filteredCount),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceFilterResultCount(int count) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: cs.border.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$count 条',
        style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildResourceFilterButton() {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final count = _resourceFilterCount;
    final active = count > 0;

    return Builder(
      builder: (buttonContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showResourceFilterPopover(buttonContext),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: active ? cs.primary.withValues(alpha: 0.12) : cs.mutedForeground.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: active ? cs.primary.withValues(alpha: 0.55) : cs.border.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shadcn.LucideIcons.listFilter, size: 12, color: active ? cs.primary : cs.foreground),
              const SizedBox(width: 4),
              Text(
                active ? '筛选 $count' : '筛选',
                style: typo.xSmall.copyWith(
                  color: active ? cs.primary : cs.foreground,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResourceFilterPopover(BuildContext anchorContext) {
    if (_resourceFilterOverlay != null) {
      _closeResourceFilterPopover();
      return;
    }

    final overlay = Overlay.of(anchorContext, rootOverlay: true);
    final anchorBox = anchorContext.findRenderObject() as RenderBox?;
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (anchorBox == null || overlayBox == null || !anchorBox.hasSize || !overlayBox.hasSize) return;

    final anchorOffset = anchorBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final anchorSize = anchorBox.size;
    final overlaySize = overlayBox.size;
    final compact = overlaySize.width < 600;
    final belowTop = anchorOffset.dy + anchorSize.height + 8;
    final belowSpace = overlaySize.height - belowTop - 12;
    final aboveBottom = overlaySize.height - anchorOffset.dy + 8;
    final aboveSpace = anchorOffset.dy - 12;
    final showAbove = !compact && belowSpace < 280 && aboveSpace > belowSpace;
    final panelMaxHeight = (showAbove ? aboveSpace : belowSpace)
        .clamp(compact ? 160.0 : 220.0, compact ? overlaySize.height - 24 : 520.0)
        .toDouble();
    final panelLeft = compact ? 12.0 : null;
    final panelRight = compact
        ? 12.0
        : (overlaySize.width - anchorOffset.dx - anchorSize.width).clamp(8.0, overlaySize.width);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeResourceFilterPopover,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: showAbove ? null : belowTop,
              bottom: showAbove ? aboveBottom : null,
              left: panelLeft,
              right: panelRight,
              child: StatefulBuilder(
                builder: (popoverContext, popoverSetState) {
                  void update(VoidCallback fn) {
                    setState(fn);
                    popoverSetState(() {});
                  }

                  return _ResourceFilterPanel(
                    data: _resourceFilterData(),
                    selectedSites: _resourceFilterSites,
                    selectedSales: _resourceFilterSales,
                    selectedCategories: _resourceFilterCategories,
                    selectedResolutions: _resourceFilterResolutions,
                    selectedTags: _resourceFilterTags,
                    selectedSeasons: _resourceFilterSeasons,
                    selectedEpisodes: _resourceFilterEpisodes,
                    hrOnly: _resourceFilterHrOnly,
                    sizeEnabled: _resourceFilterSizeEnabled,
                    sizeGb: _resourceFilterSizeGb,
                    maxHeight: panelMaxHeight,
                    siteLabel: _siteLabel,
                    categoryLabel: _categoryLabel,
                    onToggleSite: (value) => update(() => _toggleFilterValue(_resourceFilterSites, value)),
                    onToggleSale: (value) => update(() => _toggleFilterValue(_resourceFilterSales, value)),
                    onToggleCategory: (value) => update(() => _toggleFilterValue(_resourceFilterCategories, value)),
                    onToggleResolution: (value) => update(() => _toggleFilterValue(_resourceFilterResolutions, value)),
                    onToggleTag: (value) => update(() => _toggleFilterValue(_resourceFilterTags, value)),
                    onToggleSeason: (value) => update(() => _toggleFilterValue(_resourceFilterSeasons, value)),
                    onToggleEpisode: (value) => update(() => _toggleFilterValue(_resourceFilterEpisodes, value)),
                    onToggleHr: () => update(() => _resourceFilterHrOnly = !_resourceFilterHrOnly),
                    onToggleSize: () => update(() => _resourceFilterSizeEnabled = !_resourceFilterSizeEnabled),
                    onSizeChanged: (value) => update(() => _resourceFilterSizeGb = value),
                    onClear: () => update(_resetResourceFilters),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
    _resourceFilterOverlay = entry;
    overlay.insert(entry);
  }

  void _closeResourceFilterPopover() {
    _resourceFilterOverlay?.remove();
    _resourceFilterOverlay = null;
  }

  Widget _buildResourceSortChip(_ResourceSortField field) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final active = _resourceSortField == field;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _setResourceSort(field),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.12) : cs.mutedForeground.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: active ? cs.primary.withValues(alpha: 0.55) : cs.border.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _resourceSortLabel(field),
              style: typo.xSmall.copyWith(
                color: active ? cs.primary : cs.foreground,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 3),
              Icon(
                _resourceSortAscending ? shadcn.LucideIcons.arrowUp : shadcn.LucideIcons.arrowDown,
                size: 11,
                color: cs.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _setResourceSort(_ResourceSortField field) {
    setState(() {
      if (_resourceSortField == field) {
        _resourceSortAscending = !_resourceSortAscending;
      } else {
        _resourceSortField = field;
        _resourceSortAscending = _defaultResourceSortAscending(field);
      }
    });
  }

  bool _defaultResourceSortAscending(_ResourceSortField field) {
    switch (field) {
      case _ResourceSortField.title:
      case _ResourceSortField.subtitle:
        return true;
      case _ResourceSortField.size:
      case _ResourceSortField.seeders:
      case _ResourceSortField.published:
        return false;
    }
  }

  String _resourceSortLabel(_ResourceSortField field) {
    switch (field) {
      case _ResourceSortField.title:
        return '标题';
      case _ResourceSortField.subtitle:
        return '副标题';
      case _ResourceSortField.size:
        return '大小';
      case _ResourceSortField.seeders:
        return '做种';
      case _ResourceSortField.published:
        return '发布时间';
    }
  }

  List<SearchTorrentInfo> _sortedResourceResults(List<SearchTorrentInfo> results) {
    final sorted = List<SearchTorrentInfo>.of(results);
    sorted.sort(_compareResourceItems);
    return sorted;
  }

  int _compareResourceItems(SearchTorrentInfo a, SearchTorrentInfo b) {
    final result = switch (_resourceSortField) {
      _ResourceSortField.title => _compareText(a.title, b.title),
      _ResourceSortField.subtitle => _compareText(a.subtitle, b.subtitle),
      _ResourceSortField.size => _compareInt(a.size, b.size),
      _ResourceSortField.seeders => _compareInt(a.seeders, b.seeders),
      _ResourceSortField.published => _compareDate(a.published, b.published),
    };
    if (result != 0) return result;

    final fallback = _compareDate(a.published, b.published);
    if (fallback != 0) return fallback;
    return _compareText(a.title, b.title);
  }

  int _compareText(String a, String b) {
    final av = a.trim().toLowerCase();
    final bv = b.trim().toLowerCase();
    final empty = _compareEmptyLast(av, bv);
    if (empty != null) return empty;
    final result = av.compareTo(bv);
    return _resourceSortAscending ? result : -result;
  }

  int _compareInt(int a, int b) {
    final empty = _compareZeroLast(a, b);
    if (empty != null) return empty;
    final result = a.compareTo(b);
    return _resourceSortAscending ? result : -result;
  }

  int _compareDate(String a, String b) {
    final av = a.trim();
    final bv = b.trim();
    final empty = _compareEmptyLast(av, bv);
    if (empty != null) return empty;
    final result = parseDateTimeOrEpoch(av).compareTo(parseDateTimeOrEpoch(bv));
    return _resourceSortAscending ? result : -result;
  }

  int? _compareEmptyLast(String a, String b) {
    final aEmpty = a.isEmpty;
    final bEmpty = b.isEmpty;
    if (aEmpty == bEmpty) return null;
    return aEmpty ? 1 : -1;
  }

  int? _compareZeroLast(int a, int b) {
    final aEmpty = a == 0;
    final bEmpty = b == 0;
    if (aEmpty == bEmpty) return null;
    return aEmpty ? 1 : -1;
  }

  int get _resourceFilterCount =>
      _resourceFilterSites.length +
      _resourceFilterSales.length +
      _resourceFilterCategories.length +
      _resourceFilterResolutions.length +
      _resourceFilterTags.length +
      _resourceFilterSeasons.length +
      _resourceFilterEpisodes.length +
      (_resourceFilterSizeEnabled ? 1 : 0) +
      (_resourceFilterHrOnly ? 1 : 0);

  void _resetResourceFilters() {
    _resourceFilterSites.clear();
    _resourceFilterSales.clear();
    _resourceFilterCategories.clear();
    _resourceFilterResolutions.clear();
    _resourceFilterTags.clear();
    _resourceFilterSeasons.clear();
    _resourceFilterEpisodes.clear();
    _resourceFilterHrOnly = false;
    _resourceFilterSizeEnabled = false;
    _resourceFilterSizeGb = const RangeValues(0, 100);
  }

  List<SearchTorrentInfo> _filteredResourceResults(List<SearchTorrentInfo> results) {
    if (_resourceFilterCount == 0) return results;
    return results.where(_matchesResourceFilters).toList();
  }

  bool _matchesResourceFilters(SearchTorrentInfo item) {
    if (_resourceFilterSites.isNotEmpty && !_resourceFilterSites.contains(item.siteId)) {
      return false;
    }
    if (_resourceFilterSales.isNotEmpty && !_resourceFilterSales.contains(_resourceSaleValue(item))) {
      return false;
    }
    if (_resourceFilterCategories.isNotEmpty && !_resourceFilterCategories.contains(item.category)) {
      return false;
    }
    if (_resourceFilterResolutions.isNotEmpty &&
        _extractResourceResolutions(item).intersection(_resourceFilterResolutions).isEmpty) {
      return false;
    }
    if (_resourceFilterTags.isNotEmpty && item.tags.toSet().intersection(_resourceFilterTags).isEmpty) {
      return false;
    }
    if (_resourceFilterSeasons.isNotEmpty &&
        _extractResourceSeasons(item).intersection(_resourceFilterSeasons).isEmpty) {
      return false;
    }
    if (_resourceFilterEpisodes.isNotEmpty &&
        _extractResourceEpisodes(item).intersection(_resourceFilterEpisodes).isEmpty) {
      return false;
    }
    if (_resourceFilterSizeEnabled && !_matchesResourceSizeRange(item)) {
      return false;
    }
    if (_resourceFilterHrOnly && !item.hr) return false;
    return true;
  }

  String _resourceSaleValue(SearchTorrentInfo item) {
    final value = item.saleStatus.trim();
    return value.isEmpty ? '无优惠' : value;
  }

  Set<String> _extractResourceResolutions(SearchTorrentInfo item) {
    final text = '${item.title} ${item.subtitle}'.toUpperCase();
    final values = <String>{};
    for (final resolution in _resourceResolutionValues) {
      if (text.contains(resolution.toUpperCase())) {
        values.add(resolution);
      }
    }
    return values;
  }

  Set<String> _extractResourceSeasons(SearchTorrentInfo item) {
    final text = '${item.title} ${item.subtitle}'.toUpperCase();
    final values = <String>{};
    final pattern = RegExp(r'(^|[^A-Z0-9])S(\d{1,2})(?=[^0-9]|$)');
    for (final match in pattern.allMatches(text)) {
      final number = int.tryParse(match.group(2) ?? '');
      if (number != null && number >= 0) values.add('S${number.toString().padLeft(2, '0')}');
    }
    return values;
  }

  Set<String> _extractResourceEpisodes(SearchTorrentInfo item) {
    final text = '${item.title} ${item.subtitle}'.toUpperCase();
    final values = <String>{};
    final rangePattern = RegExp(
      r'(^|[^A-Z0-9])(?:S\d{1,2})?E(?:P)?(\d{1,3})\s*[-~－–—]\s*(?:(?:S\d{1,2})?E(?:P)?)?(\d{1,3}|\*\*)(?=[^A-Z0-9]|$)',
    );
    for (final match in rangePattern.allMatches(text)) {
      final start = int.tryParse(match.group(2) ?? '');
      final endRaw = match.group(3) ?? '';
      final end = int.tryParse(endRaw);
      if (start == null || start <= 0) continue;
      if (end == null || end < start || end - start > 80) {
        values.add('E${start.toString().padLeft(2, '0')}');
        continue;
      }
      for (var number = start; number <= end; number++) {
        values.add('E${number.toString().padLeft(2, '0')}');
      }
    }

    final pattern = RegExp(r'(^|[^A-Z0-9])(?:S\d{1,2})?E(?:P)?(\d{1,3})(?=[^0-9]|$)');
    for (final match in pattern.allMatches(text)) {
      final number = int.tryParse(match.group(2) ?? '');
      if (number != null && number > 0) values.add('E${number.toString().padLeft(2, '0')}');
    }
    return values;
  }

  bool _matchesResourceSizeRange(SearchTorrentInfo item) {
    if (item.size <= 0) return false;
    final sizeGb = item.size / (1024 * 1024 * 1024);
    return sizeGb >= _resourceFilterSizeGb.start && sizeGb <= _resourceFilterSizeGb.end;
  }

  List<String> _resourceFilterOptions(List<SearchTorrentInfo> results, String Function(SearchTorrentInfo item) pick) {
    final values = <String>{};
    for (final item in results) {
      final value = pick(item).trim();
      if (value.isNotEmpty) values.add(value);
    }
    return values.toList()..sort();
  }

  List<String> _resourceResolutionOptions(List<SearchTorrentInfo> results) {
    return _resourceResolutionValues
        .where((resolution) => results.any((item) => _extractResourceResolutions(item).contains(resolution)))
        .toList();
  }

  List<String> _resourceTagOptions(List<SearchTorrentInfo> results) {
    final values = <String>{};
    for (final item in results) {
      for (final tag in item.tags) {
        final value = tag.trim();
        if (value.isNotEmpty) values.add(value);
      }
    }
    return values.toList()..sort();
  }

  List<String> _resourceSeasonOptions(List<SearchTorrentInfo> results) {
    final values = <String>{};
    for (final item in results) {
      values.addAll(_extractResourceSeasons(item));
    }
    return values.toList()..sort(_compareSeasonEpisodeLabel);
  }

  List<String> _resourceEpisodeOptions(List<SearchTorrentInfo> results) {
    final values = <String>{};
    for (final item in results) {
      values.addAll(_extractResourceEpisodes(item));
    }
    return values.toList()..sort(_compareSeasonEpisodeLabel);
  }

  int _compareSeasonEpisodeLabel(String a, String b) {
    final av = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final bv = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return av.compareTo(bv);
  }

  void _toggleFilterValue(Set<String> values, String value) {
    if (values.contains(value)) {
      values.remove(value);
    } else {
      values.add(value);
    }
  }

  List<String> _normalizedSearchSiteIds(List<String> sites) {
    final siteInfos = ref.read(siteInfoListProvider).valueOrNull ?? [];
    final byId = {for (final site in siteInfos) site.id.toString(): site};
    final byName = {for (final site in siteInfos) site.site: site};
    final normalized = <String>[];
    for (final raw in sites) {
      final value = raw.trim();
      if (value.isEmpty) continue;
      final site = byId[value] ?? byName[value];
      final id = site?.id.toString() ?? value;
      if (!normalized.contains(id)) normalized.add(id);
    }
    return normalized;
  }

  String _siteLabel(String siteId) {
    final sites = ref.read(siteInfoListProvider).valueOrNull ?? [];
    for (final site in sites) {
      if (site.id.toString() == siteId || site.site == siteId) {
        return site.nickname.isNotEmpty ? site.nickname : site.site;
      }
    }
    return siteId;
  }

  Widget _buildTorrentCard(SearchTorrentInfo item) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    final site = _siteFor(item.siteId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _onTorrentTap(item),
        onLongPress: () => BrowserPage.open(
          context,
          url: item.detailUrl,
          title: item.title,
          cookie: site?.cookie,
          userAgent: site?.userAgent,
          siteId: site?.site ?? item.siteId,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typo.small.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (item.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: typo.xSmall.copyWith(color: cs.mutedForeground.withValues(alpha: 0.6), fontSize: 10),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatBytes(item.size),
                          style: typo.xSmall.copyWith(fontWeight: FontWeight.w600, color: cs.foreground),
                        ),
                        _seedRow(item),
                        _badge(item.siteId, cs.primary),
                        if (item.category.isNotEmpty && item.category != '无分类')
                          _badge(_categoryLabel(item.category), cs.mutedForeground),
                        if (!item.hr) _badge('HR', Colors.orange),
                        if (item.saleStatus.isNotEmpty && item.saleStatus != '无优惠')
                          _badge(item.saleStatus, Colors.green),
                        if (item.published.isNotEmpty)
                          Text(
                            formatMonthDay(item.published),
                            style: TextStyle(fontSize: 10, color: cs.mutedForeground.withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(shadcn.LucideIcons.download, size: 16, color: cs.primary),
                onPressed: () => _onTorrentTap(item),
                tooltip: '下载',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seedRow(SearchTorrentInfo item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(shadcn.LucideIcons.arrowUp, size: 10, color: Colors.green),
        const SizedBox(width: 1),
        Text(
          '${item.seeders}',
          style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        const Icon(shadcn.LucideIcons.arrowDown, size: 10, color: Colors.red),
        const SizedBox(width: 1),
        Text(
          '${item.leechers}',
          style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 4),
        const Icon(shadcn.LucideIcons.check, size: 10, color: Colors.grey),
        const SizedBox(width: 1),
        Text(
          '${item.completers}',
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
      child: Text(
        text,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  SiteInfo? _siteFor(String siteId) {
    final sites = ref.watch(siteInfoListProvider).valueOrNull ?? [];
    for (final site in sites) {
      if (site.id.toString() == siteId || site.site == siteId) return site;
    }
    return null;
  }

  // ═══════════════════════════════════════════════
  // 下载
  // ═══════════════════════════════════════════════

  void _onTorrentTap(SearchTorrentInfo item) {
    showAppSheet(
      context: context, // 直接用页面 context，不要用 navigatorKey
      title: '选择下载器',
      showDefaultHeader: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        maxWidth: DownloaderSelectSheet.desktopWidth,
      ),
      builder: (ctx) => DownloaderSelectSheet(
        useDefaultHeader: true,
        onSelected: (downloader) {
          closeAppSheet(ctx);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            showAppSheet<void>(
              context: context, // 这里也一样
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              constraints: const BoxConstraints(
                maxWidth: PushTorrentSheet.desktopWidth,
              ),
              builder: (_) => PushTorrentSheet(torrent: item, downloader: downloader),
            );
          });
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // 工具
  // ═══════════════════════════════════════════════

  String _categoryLabel(String c) {
    switch (c) {
      case 'movies':
        return '电影';
      case 'tv':
        return '剧集';
      case 'anime':
        return '动漫';
      case 'music':
        return '音乐';
      case 'software':
        return '软件';
      case 'games':
        return '游戏';
      case 'ebook':
        return '电子书';
      default:
        return c;
    }
  }
}

class _ResourceFilterData {
  final List<String> sites;
  final List<String> sales;
  final List<String> categories;
  final List<String> resolutions;
  final List<String> tags;
  final List<String> seasons;
  final List<String> episodes;

  const _ResourceFilterData({
    required this.sites,
    required this.sales,
    required this.categories,
    required this.resolutions,
    required this.tags,
    required this.seasons,
    required this.episodes,
  });
}

class _ResourceFilterPanel extends StatefulWidget {
  final _ResourceFilterData data;
  final Set<String> selectedSites;
  final Set<String> selectedSales;
  final Set<String> selectedCategories;
  final Set<String> selectedResolutions;
  final Set<String> selectedTags;
  final Set<String> selectedSeasons;
  final Set<String> selectedEpisodes;
  final bool hrOnly;
  final bool sizeEnabled;
  final RangeValues sizeGb;
  final double maxHeight;
  final String Function(String value) siteLabel;
  final String Function(String value) categoryLabel;
  final ValueChanged<String> onToggleSite;
  final ValueChanged<String> onToggleSale;
  final ValueChanged<String> onToggleCategory;
  final ValueChanged<String> onToggleResolution;
  final ValueChanged<String> onToggleTag;
  final ValueChanged<String> onToggleSeason;
  final ValueChanged<String> onToggleEpisode;
  final VoidCallback onToggleHr;
  final VoidCallback onToggleSize;
  final ValueChanged<RangeValues> onSizeChanged;
  final VoidCallback onClear;

  const _ResourceFilterPanel({
    required this.data,
    required this.selectedSites,
    required this.selectedSales,
    required this.selectedCategories,
    required this.selectedResolutions,
    required this.selectedTags,
    required this.selectedSeasons,
    required this.selectedEpisodes,
    required this.hrOnly,
    required this.sizeEnabled,
    required this.sizeGb,
    this.maxHeight = 520,
    required this.siteLabel,
    required this.categoryLabel,
    required this.onToggleSite,
    required this.onToggleSale,
    required this.onToggleCategory,
    required this.onToggleResolution,
    required this.onToggleTag,
    required this.onToggleSeason,
    required this.onToggleEpisode,
    required this.onToggleHr,
    required this.onToggleSize,
    required this.onSizeChanged,
    required this.onClear,
  });

  @override
  State<_ResourceFilterPanel> createState() => _ResourceFilterPanelState();
}

class _ResourceFilterPanelState extends State<_ResourceFilterPanel> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final mediaWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = mediaWidth < 600 ? double.infinity : (mediaWidth - 24).clamp(280.0, 520.0).toDouble();
    final activeCount =
        widget.selectedSites.length +
        widget.selectedSales.length +
        widget.selectedCategories.length +
        widget.selectedResolutions.length +
        widget.selectedTags.length +
        widget.selectedSeasons.length +
        widget.selectedEpisodes.length +
        (widget.sizeEnabled ? 1 : 0) +
        (widget.hrOnly ? 1 : 0);

    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border.withValues(alpha: 0.42)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
              child: Row(
                children: [
                  Icon(shadcn.LucideIcons.listFilter, size: 16, color: cs.foreground),
                  const SizedBox(width: 8),
                  Text(
                    '筛选资源',
                    style: typo.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w700),
                  ),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '$activeCount 项',
                      style: typo.xSmall.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ],
                  const Spacer(),
                  if (activeCount > 0) shadcn.Button.outline(onPressed: widget.onClear, child: const Text('清除')),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: cs.border.withValues(alpha: 0.35)),
            Flexible(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollController,
                  shrinkWrap: true,
                  primary: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  children: [
                    _ResourceFilterSwitchTile(label: '不看 HR', value: widget.hrOnly, onToggle: widget.onToggleHr),
                    _ResourceSizeRangeFilter(
                      enabled: widget.sizeEnabled,
                      value: widget.sizeGb,
                      onToggle: widget.onToggleSize,
                      onChanged: widget.onSizeChanged,
                    ),
                    _ResourceFilterSection(
                      title: '站点',
                      values: widget.data.sites,
                      selected: widget.selectedSites,
                      labelOf: widget.siteLabel,
                      onToggle: widget.onToggleSite,
                    ),
                    _ResourceFilterSection(
                      title: '优惠',
                      values: widget.data.sales,
                      selected: widget.selectedSales,
                      onToggle: widget.onToggleSale,
                    ),
                    _ResourceFilterSection(
                      title: '分类',
                      values: widget.data.categories,
                      selected: widget.selectedCategories,
                      labelOf: widget.categoryLabel,
                      onToggle: widget.onToggleCategory,
                    ),
                    _ResourceFilterSection(
                      title: '分辨率',
                      values: widget.data.resolutions,
                      selected: widget.selectedResolutions,
                      onToggle: widget.onToggleResolution,
                    ),
                    _ResourceHorizontalFilterSection(
                      title: '季',
                      values: widget.data.seasons,
                      selected: widget.selectedSeasons,
                      onToggle: widget.onToggleSeason,
                    ),
                    _ResourceHorizontalFilterSection(
                      title: '集',
                      values: widget.data.episodes,
                      selected: widget.selectedEpisodes,
                      onToggle: widget.onToggleEpisode,
                    ),
                    _ResourceFilterSection(
                      title: '标签',
                      values: widget.data.tags,
                      selected: widget.selectedTags,
                      onToggle: widget.onToggleTag,
                      prefix: '#',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResourceFilterSwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final VoidCallback onToggle;

  const _ResourceFilterSwitchTile({required this.label, required this.value, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: typo.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Switch(value: value, onChanged: (_) => onToggle()),
        ],
      ),
    );
  }
}

class _ResourceFilterSection extends StatelessWidget {
  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final String Function(String value)? labelOf;
  final String prefix;

  const _ResourceFilterSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onToggle,
    this.labelOf,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: values.map((value) {
              return _ResourceFilterChip(
                label: '$prefix${labelOf?.call(value) ?? value}',
                selected: selected.contains(value),
                onTap: () => onToggle(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ResourceHorizontalFilterSection extends StatelessWidget {
  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _ResourceHorizontalFilterSection({
    required this.title,
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: typo.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < values.length; i++) ...[
                  _ResourceFilterChip(
                    label: values[i],
                    selected: selected.contains(values[i]),
                    onTap: () => onToggle(values[i]),
                  ),
                  if (i != values.length - 1) const SizedBox(width: 7),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResourceSizeRangeFilter extends StatelessWidget {
  final bool enabled;
  final RangeValues value;
  final VoidCallback onToggle;
  final ValueChanged<RangeValues> onChanged;

  const _ResourceSizeRangeFilter({
    required this.enabled,
    required this.value,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;
    final start = value.start.round();
    final end = value.end.round();

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '种子大小',
                style: typo.small.copyWith(color: cs.foreground, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                enabled ? '$start-$end GB' : '不限',
                style: typo.xSmall.copyWith(
                  color: enabled ? cs.primary : cs.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Switch(value: enabled, onChanged: (_) => onToggle()),
            ],
          ),
          RangeSlider(
            values: value,
            min: 0,
            max: 100,
            divisions: 100,
            labels: RangeLabels('$start GB', '$end GB'),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _ResourceFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ResourceFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.12) : cs.mutedForeground.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.55) : cs.border.withValues(alpha: 0.45)),
        ),
        child: Text(
          label,
          style: typo.xSmall.copyWith(
            color: selected ? cs.primary : cs.foreground,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Bottom Sheet 选项行
// ═══════════════════════════════════════════════════════════════

class _SheetOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final typo = shadcn.Theme.of(context).typography;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: typo.small.copyWith(fontWeight: FontWeight.w500)),
                  Text(subtitle, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
                ],
              ),
            ),
            Icon(shadcn.LucideIcons.chevronRight, size: 16, color: cs.mutedForeground),
          ],
        ),
      ),
    );
  }
}
