import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../shell/widgets/shell_scaffold.dart';
import 'model/search_results.dart';
import 'provider/tmdb_provider.dart';
import 'widgets/media_section.dart';
import 'widgets/tmdb_detail_sheet.dart';

class TmdbPage extends ConsumerWidget {
  final ScrollController? scrollController;

  const TmdbPage({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EasyRefresh(
      onRefresh: () => refreshAll(ref),
      header: appRefreshHeader(context),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: ShellBottomSpacing.value(context)),
        children: [
          _section(context, ref, '正在热映', playingMoviesProvider),
          _section(context, ref, '热门电影', popularMoviesProvider),
          _section(context, ref, '即将上映', upcomingMoviesProvider),
          _section(context, ref, '高分电影', topRatedMoviesProvider),
          _section(context, ref, '今日播出', airingTodayTvsProvider),
          _section(context, ref, '正在播出', onTheAirTvsProvider),
          _section(context, ref, '热门剧集', popularTvsProvider),
          _section(context, ref, '高分剧集', topRatedTvsProvider),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context,
    WidgetRef ref,
    String title,
    AutoDisposeFutureProvider<SearchResults> provider,
  ) {
    final async = ref.watch(provider);
    return MediaSection(
      title: title,
      items: async.valueOrNull?.results ?? const [],
      isLoading: async.isLoading && !async.hasValue,
      onItemTap: (item) => openTmdbDetail(context, item), // ← 加这行
    );
  }

  static Future<void> refreshAll(WidgetRef ref) async {
    ref.read(tmdbForceRefreshProvider.notifier).state = const {
      tmdbPlayingMoviesCacheKey,
      tmdbPopularMoviesCacheKey,
      tmdbUpcomingMoviesCacheKey,
      tmdbTopRatedMoviesCacheKey,
      tmdbAiringTodayTvsCacheKey,
      tmdbOnTheAirTvsCacheKey,
      tmdbPopularTvsCacheKey,
      tmdbTopRatedTvsCacheKey,
    };
    await Future.wait([
      ref.refresh(playingMoviesProvider.future),
      ref.refresh(popularMoviesProvider.future),
      ref.refresh(upcomingMoviesProvider.future),
      ref.refresh(topRatedMoviesProvider.future),
      ref.refresh(airingTodayTvsProvider.future),
      ref.refresh(onTheAirTvsProvider.future),
      ref.refresh(popularTvsProvider.future),
      ref.refresh(topRatedTvsProvider.future),
    ]);
  }
}
