import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/utils/utils.dart';
import '../shell/provider/screenshot_provider.dart';
import '../../widgets/cache_status_banner.dart';
import 'douban/douban_page.dart';
import 'douban/provider/douban_provider.dart';
import 'provider/media_info_settings_provider.dart';
import 'tmdb/tmdb_page.dart';
import 'tmdb/provider/tmdb_provider.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsToolbar extends StatelessWidget {
  final bool mobile;
  final int tabIndex;
  final bool tmdbEnabled;
  final bool doubanEnabled;
  final DataCacheInfo cacheInfo;
  final ValueChanged<int> onTabChanged;

  const _NewsToolbar({
    required this.mobile,
    required this.tabIndex,
    required this.tmdbEnabled,
    required this.doubanEnabled,
    required this.cacheInfo,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = mobile ? 12.0 : 16.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 6, horizontal, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tmdbEnabled && doubanEnabled) ...[
            shadcn.Tabs(
              index: tabIndex,
              onChanged: onTabChanged,
              children: const [
                shadcn.TabItem(child: Text('TMDB')),
                shadcn.TabItem(child: Text('豆瓣')),
              ],
            ),
            if (cacheInfo.isCached) const SizedBox(height: 6),
          ],
          CacheStatusBanner(info: cacheInfo, margin: EdgeInsets.zero),
        ],
      ),
    );
  }
}

class _NewsPageState extends ConsumerState<NewsPage> {
  int _tabIndex = 0;
  final _scrollController = ScrollController();
  bool _tmdbAutoRefreshStarted = false;
  bool _doubanAutoRefreshStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state =
          _scrollController;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final settings = ref.watch(mediaInfoSettingsProvider);
    final effectiveTabIndex = settings.tmdbEnabled ? 0 : 1;
    final currentTabIndex = settings.tmdbEnabled && settings.doubanEnabled
        ? _tabIndex
        : effectiveTabIndex;
    final cacheInfo = currentTabIndex == 0
        ? _combinedCacheInfo(ref.watch(tmdbCacheInfoProvider), const {
            tmdbPlayingMoviesCacheKey,
            tmdbPopularMoviesCacheKey,
            tmdbUpcomingMoviesCacheKey,
            tmdbTopRatedMoviesCacheKey,
            tmdbAiringTodayTvsCacheKey,
            tmdbOnTheAirTvsCacheKey,
            tmdbPopularTvsCacheKey,
            tmdbTopRatedTvsCacheKey,
          })
        : _combinedCacheInfo(ref.watch(doubanCacheInfoProvider), const {
            doubanHotMoviesCacheKey,
            doubanHotTvsCacheKey,
            doubanTop250CacheKey,
            doubanRankMoviesCacheKey,
          });
    _refreshCachedTabOnce(cacheInfo);

    final cs = shadcn.Theme.of(context).colorScheme;
    final pageBackground = appSurfaceColor(context, cs.background);

    return AppBackground(
      child: shadcn.Scaffold(
        backgroundColor: pageBackground,
        headerBackgroundColor: pageBackground,
        headers: [
          _NewsToolbar(
            mobile: mobile,
            tabIndex: currentTabIndex,
            tmdbEnabled: settings.tmdbEnabled,
            doubanEnabled: settings.doubanEnabled,
            cacheInfo: cacheInfo,
            onTabChanged: (index) => setState(() => _tabIndex = index),
          ),
        ],
        child: IndexedStack(
          index: currentTabIndex,
          children: [
            TmdbPage(
              scrollController: currentTabIndex == 0 ? _scrollController : null,
            ),
            DoubanPage(
              scrollController: currentTabIndex == 1 ? _scrollController : null,
            ),
          ],
        ),
      ),
    );
  }

  DataCacheInfo _combinedCacheInfo(
    Map<String, DataCacheInfo> infos,
    Set<String> visibleKeys,
  ) {
    DateTime? latest;
    for (final key in visibleKeys) {
      final info = infos[key];
      if (info == null) continue;
      if (!info.isCached || info.cachedAt == null) continue;
      if (latest == null || info.cachedAt!.isAfter(latest)) {
        latest = info.cachedAt;
      }
    }
    return latest == null
        ? const DataCacheInfo.none()
        : DataCacheInfo.cached(latest);
  }

  void _refreshCachedTabOnce(DataCacheInfo cacheInfo) {
    if (!cacheInfo.isCached) return;

    final tabIndex = _tabIndex;
    if (tabIndex == 0) {
      if (_tmdbAutoRefreshStarted) return;
      _tmdbAutoRefreshStarted = true;
    } else {
      if (_doubanAutoRefreshStarted) return;
      _doubanAutoRefreshStarted = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (tabIndex == 0) {
        await TmdbPage.refreshAll(ref);
      } else {
        await DoubanPage.refreshAll(ref);
      }
    });
  }
}
