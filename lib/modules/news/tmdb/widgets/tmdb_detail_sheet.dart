import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../../../search/model/search_mode.dart';
import '../../../search/unified_search_page.dart';
import '../model/media_item.dart';
import '../model/movie_detail.dart';
import '../model/tv_show_detail.dart';
import '../provider/tmdb_provider.dart';
import '../service/tmdb_service.dart';

void openTmdbDetail(BuildContext context, MediaItem item) {
  if (context.isMobile) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 1.1,
      style: FSheetStyle(flingVelocity: 700, closeProgressThreshold: 0.75).call,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) => _TmdbDetailSheet(item: item),
      ),
    );
  } else {
    showFDialog(
      context: context,
      builder: (context, _, __) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
          child: _TmdbDetailSheet(item: item),
        ),
      ),
    );
  }
}

class _TmdbDetailSheet extends ConsumerWidget {
  final MediaItem item;

  const _TmdbDetailSheet({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMovie = item.mediaType == 'movie';

    final content = isMovie ? ref.watch(movieDetailProvider(item.id)) : ref.watch(tvShowDetailProvider(item.id));

    String title;
    if (content.hasValue) {
      final d = content.value!;
      title = (d as dynamic).title ?? item.title;
    } else {
      title = item.title;
    }

    final body = content.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e')),
      data: (detail) => _buildContent(context, detail),
    );

    return FScaffold(
      childPad: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部栏
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    child: Icon(FIcons.arrowLeft, size: 20),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.theme.typography.base.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          FDivider(
            style: FDividerStyle(
              color: context.theme.colors.border,
              padding: const EdgeInsets.symmetric(vertical: 6),
            ).call,
          ),
          // 内容
          Flexible(child: body),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic detail) {
    final backdropUrl = TmdbService.imageUrl(detail.backdropPath, size: 'w780');
    final posterUrl = TmdbService.imageUrl(detail.posterPath, size: 'w342');

    String imdbId = detail.imdbId ?? '';
    String title = detail.title ?? '';
    String year = '';
    List<String> genres = [];
    String overview = detail.overview ?? '';
    double voteAverage = detail.voteAverage ?? 0;
    int voteCount = detail.voteCount ?? 0;

    if (detail is MovieDetail) {
      year = detail.releaseDate.length >= 4 ? detail.releaseDate.substring(0, 4) : '';
      genres = detail.genres.map((g) => g.name).toList();
    } else if (detail is TvShowDetail) {
      year = (detail.releaseDate ?? '').length >= 4 ? detail.releaseDate!.substring(0, 4) : '';
      genres = detail.genres.map((g) => g.name).toList();
    }

    final searchQuery = imdbId.isNotEmpty ? '$imdbId||$title' : title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (backdropUrl.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: backdropUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 180,
                color: context.theme.colors.muted,
                child: const Center(
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              ),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (posterUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: posterUrl,
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 100,
                          height: 150,
                          color: context.theme.colors.muted,
                          child: const Center(
                            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 100,
                          height: 150,
                          color: context.theme.colors.muted,
                          child: Icon(FIcons.film, color: context.theme.colors.mutedForeground.withValues(alpha: 0.3)),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: context.theme.typography.lg.copyWith(fontWeight: FontWeight.w700)),
                        if (year.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            year,
                            style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground),
                          ),
                        ],
                        if (genres.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: genres
                                .map(
                                  (g) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: context.theme.colors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(g, style: TextStyle(fontSize: 11, color: context.theme.colors.primary)),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (voteAverage > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(FIcons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                voteAverage.toStringAsFixed(1),
                                style: context.theme.typography.base.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($voteCount 票)',
                                style: context.theme.typography.xs.copyWith(
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (detail is MovieDetail) ...[
                const SizedBox(height: 16),
                _infoRow(context, '时长', '${detail.runtime} 分钟'),
                _infoRow(context, '状态', detail.status),
                if (detail.originCountry.isNotEmpty) _infoRow(context, '国家', detail.originCountry.join(', ')),
                _infoRow(context, '语言', detail.originalLanguage),
                if (detail.budget > 0) _infoRow(context, '预算', '\$${detail.budget}'),
                if (detail.revenue > 0) _infoRow(context, '票房', '\$${detail.revenue}'),
              ] else if (detail is TvShowDetail) ...[
                const SizedBox(height: 16),
                _infoRow(context, '状态', detail.status),
                _infoRow(context, '季数', '${detail.numberOfSeasons}'),
                _infoRow(context, '集数', '${detail.numberOfEpisodes}'),
                if (detail.originCountry.isNotEmpty) _infoRow(context, '国家', detail.originCountry.join(', ')),
                if (detail.networks.isNotEmpty) _infoRow(context, '网络', detail.networks.map((n) => n.name).join(', ')),
              ],

              if (overview.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('简介', style: context.theme.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  overview,
                  style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground, height: 1.5),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FButton(
                onPress: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnifiedSearchPage(initialQuery: searchQuery, initialMode: SearchMode.resource),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(FIcons.search, size: 16), const SizedBox(width: 6), const Text('搜索资源')],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: context.theme.typography.xs.copyWith(color: context.theme.colors.mutedForeground),
            ),
          ),
          Expanded(child: Text(value, style: context.theme.typography.xs)),
        ],
      ),
    );
  }
}
