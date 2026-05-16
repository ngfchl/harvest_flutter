import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';

import '../widgets/news_bottom_padding.dart';
import '../provider/media_info_settings_provider.dart';
import 'provider/douban_provider.dart';
import 'widgets/douban_card.dart';
import 'widgets/douban_detail_sheet.dart';
import 'widgets/douban_section.dart';

class DoubanPage extends ConsumerWidget {
  final ScrollController? scrollController;

  const DoubanPage({super.key, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      mediaInfoSettingsProvider.select((settings) => settings.doubanEnabled),
    );
    if (!enabled) return const SizedBox.shrink();

    return EasyRefresh(
      onRefresh: () => refreshAll(ref),
      header: appRefreshHeader(context),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(bottom: newsBottomPadding(context)),
        children: [
          _hotMoviesSection(ref, context),
          _hotTvsSection(ref, context),
          _top250Section(ref, context),
          _rankSection(ref, context),
        ],
      ),
    );
  }

  Widget _top250Section(WidgetRef ref, BuildContext context) {
    final async = ref.watch(doubanTop250Provider);
    return DoubanSection(
      title: '豆瓣 Top250',
      isLoading: async.isLoading && !async.hasValue,
      items:
          async.valueOrNull
              ?.map(
                (m) => DoubanCard(
                  title: m.title,
                  posterUrl: m.poster,
                  rating: m.ratingNum.isNotEmpty ? m.ratingNum : null,
                  subtitle: m.quote.isNotEmpty
                      ? m.quote
                      : (m.subtitle.isNotEmpty ? m.subtitle.first : null),
                  badge: '#${m.rank}',
                  cookie: m.cookie.isNotEmpty ? m.cookie : null,
                  // ← 传 cookie
                  onTap: () => openDoubanDetail(context, m.doubanUrl), // ← 加这行
                ),
              )
              .toList() ??
          [],
    );
  }

  Widget _rankSection(WidgetRef ref, BuildContext context) {
    final async = ref.watch(doubanRankMoviesProvider);
    return DoubanSection(
      title: '豆瓣排行榜',
      isLoading: async.isLoading && !async.hasValue,
      items:
          async.valueOrNull
              ?.map(
                (m) => DoubanCard(
                  title: m.title,
                  posterUrl: m.poster,
                  rating: m.score.isNotEmpty ? m.score : null,
                  subtitle: m.types.isNotEmpty ? m.types.join(' / ') : null,
                  badge: '#${m.rank}',
                  cookie: m.cookie?.isNotEmpty == true ? m.cookie : null,
                  // ← 传 cookie
                  onTap: () => openDoubanDetail(context, m.id), // ← 加这行
                ),
              )
              .toList() ??
          [],
    );
  }

  Widget _hotMoviesSection(WidgetRef ref, BuildContext context) {
    final async = ref.watch(doubanHotMoviesProvider);
    return DoubanSection(
      title: '热门电影',
      isLoading: async.isLoading && !async.hasValue,
      items:
          async.valueOrNull
              ?.map(
                (m) => DoubanCard(
                  title: m.title,
                  posterUrl: m.poster,
                  rating: m.rate.isNotEmpty ? m.rate : null,
                  subtitle: m.episodesInfo.isNotEmpty ? m.episodesInfo : null,
                  badge: m.isNew ? '新' : null,
                  cookie: m.cookie.isNotEmpty ? m.cookie : null,
                  // ← 传 cookie
                  onTap: () => openDoubanDetail(context, m.id), // ← 加这行
                ),
              )
              .toList() ??
          [],
    );
  }

  Widget _hotTvsSection(WidgetRef ref, BuildContext context) {
    final async = ref.watch(doubanHotTvsProvider);
    return DoubanSection(
      title: '热门剧集',
      isLoading: async.isLoading && !async.hasValue,
      items:
          async.valueOrNull
              ?.map(
                (m) => DoubanCard(
                  title: m.title,
                  posterUrl: m.poster,
                  rating: m.rate.isNotEmpty ? m.rate : null,
                  subtitle: m.episodesInfo.isNotEmpty ? m.episodesInfo : null,
                  badge: m.isNew ? '新' : null,
                  cookie: m.cookie.isNotEmpty ? m.cookie : null,
                  // ← 传 cookie
                  onTap: () => openDoubanDetail(context, m.id), // ← 加这行
                ),
              )
              .toList() ??
          [],
    );
  }

  static Future<void> refreshAll(WidgetRef ref) async {
    if (!ref.read(mediaInfoSettingsProvider).doubanEnabled) return;

    ref.read(doubanForceRefreshProvider.notifier).state = const {
      doubanHotMoviesCacheKey,
      doubanHotTvsCacheKey,
      doubanTop250CacheKey,
      doubanRankMoviesCacheKey,
    };
    await Future.wait([
      ref.refresh(doubanHotMoviesProvider.future),
      ref.refresh(doubanHotTvsProvider.future),
      ref.refresh(doubanTop250Provider.future),
      ref.refresh(doubanRankMoviesProvider.future),
    ]);
  }
}
