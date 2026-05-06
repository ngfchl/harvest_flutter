import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/utils/utils.dart';
import '../shell/provider/screenshot_provider.dart';
import '../../widgets/cache_status_banner.dart';
import 'douban/douban_page.dart';
import 'douban/provider/douban_provider.dart';
import 'tmdb/tmdb_page.dart';
import 'tmdb/provider/tmdb_provider.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
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
    final cacheInfo = _tabIndex == 0
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

    return Column(
      children: [
        // Tab 切换
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 12 : 16,
            vertical: 4,
          ),
          child: Row(
            children: [
              _tabBtn('TMDB', 0),
              const SizedBox(width: 4),
              _tabBtn('豆瓣', 1),
            ],
          ),
        ),
        CacheStatusBanner(
          info: cacheInfo,
          margin: EdgeInsets.fromLTRB(mobile ? 12 : 16, 0, mobile ? 12 : 16, 6),
        ),

        // 内容
        Expanded(
          child: IndexedStack(
            index: _tabIndex,
            children: [
              TmdbPage(
                scrollController: _tabIndex == 0 ? _scrollController : null,
              ),
              DoubanPage(
                scrollController: _tabIndex == 1 ? _scrollController : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = index == _tabIndex;
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? cs.primary.withValues(alpha: 0.3)
                : cs.border.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: typo.sm.copyWith(
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? cs.primary : cs.mutedForeground,
          ),
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
