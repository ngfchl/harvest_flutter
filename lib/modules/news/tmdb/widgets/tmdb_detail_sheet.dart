import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../search/model/search_mode.dart';
import '../../../search/unified_search_page.dart';
import '../model/media_item.dart';
import '../model/movie_detail.dart';
import '../model/tv_show_detail.dart';
import '../provider/tmdb_provider.dart';
import '../service/tmdb_service.dart';

void openTmdbDetail(BuildContext context, MediaItem item) {
  if (context.isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shadcn.Theme.of(
        context,
      ).colorScheme.background.withValues(alpha: 0),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollCtrl) => _TmdbDetailSheet(item: item),
      ),
    );
  } else {
    final theme = shadcn.Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: theme.borderRadiusLg),
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
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    final content = isMovie
        ? ref.watch(movieDetailProvider(item.id))
        : ref.watch(tvShowDetailProvider(item.id));

    String title;
    if (content.hasValue) {
      final d = content.value!;
      title = (d as dynamic).title ?? item.title;
    } else {
      title = item.title;
    }

    final body = content.when(
      loading: () => const Center(child: shadcn.CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('加载失败: $e').small.muted),
      data: (detail) => _buildContent(context, detail),
    );

    return shadcn.Card(
      filled: true,
      fillColor: cs.background,
      borderRadius: theme.borderRadiusLg,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                shadcn.IconButton.ghost(
                  icon: const Icon(shadcn.LucideIcons.arrowLeft, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).base.semiBold,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: shadcn.Divider(),
          ),
          Flexible(child: body),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic detail) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
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
      year = detail.releaseDate.length >= 4
          ? detail.releaseDate.substring(0, 4)
          : '';
      genres = detail.genres.map((g) => g.name).toList();
    } else if (detail is TvShowDetail) {
      year = (detail.releaseDate ?? '').length >= 4
          ? detail.releaseDate!.substring(0, 4)
          : '';
      genres = detail.genres.map((g) => g.name).toList();
    }

    final searchQuery = imdbId.isNotEmpty ? '$imdbId||$title' : title;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (backdropUrl.isNotEmpty)
          ClipRRect(
            borderRadius: theme.borderRadiusLg,
            child: CachedNetworkImage(
              imageUrl: backdropUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (_, __) => _loadingBox(height: 180),
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
                      borderRadius: theme.borderRadiusMd,
                      child: CachedNetworkImage(
                        imageUrl: posterUrl,
                        width: 100,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            _loadingBox(width: 100, height: 150),
                        errorWidget: (_, __, ___) => _posterFallback(context),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title).large.bold,
                        if (year.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(year).small.muted,
                        ],
                        if (genres.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: genres
                                .map(
                                  (g) => shadcn.SecondaryBadge(child: Text(g)),
                                )
                                .toList(),
                          ),
                        ],
                        if (voteAverage > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                shadcn.LucideIcons.star,
                                size: 16,
                                color: cs.chart4,
                              ),
                              const SizedBox(width: 4),
                              Text(voteAverage.toStringAsFixed(1)).base.bold,
                              const SizedBox(width: 4),
                              Text('($voteCount 票)').xSmall.muted,
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
                if (detail.originCountry.isNotEmpty)
                  _infoRow(context, '国家', detail.originCountry.join(', ')),
                _infoRow(context, '语言', detail.originalLanguage),
                if (detail.budget > 0)
                  _infoRow(context, '预算', '\$${detail.budget}'),
                if (detail.revenue > 0)
                  _infoRow(context, '票房', '\$${detail.revenue}'),
              ] else if (detail is TvShowDetail) ...[
                const SizedBox(height: 16),
                _infoRow(context, '状态', detail.status),
                _infoRow(context, '季数', '${detail.numberOfSeasons}'),
                _infoRow(context, '集数', '${detail.numberOfEpisodes}'),
                if (detail.originCountry.isNotEmpty)
                  _infoRow(context, '国家', detail.originCountry.join(', ')),
                if (detail.networks.isNotEmpty)
                  _infoRow(
                    context,
                    '网络',
                    detail.networks.map((n) => n.name).join(', '),
                  ),
              ],

              if (overview.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('简介').small.semiBold,
                const SizedBox(height: 6),
                Text(overview).small.muted,
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
              child: shadcn.Button.primary(
                alignment: Alignment.center,
                leading: const Icon(shadcn.LucideIcons.search, size: 16),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UnifiedSearchPage(
                        initialQuery: searchQuery,
                        initialMode: SearchMode.resource,
                      ),
                    ),
                  );
                },
                child: const Text('搜索资源'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingBox({double? width, required double height}) {
    return Builder(
      builder: (context) {
        final cs = shadcn.Theme.of(context).colorScheme;
        return ColoredBox(
          color: cs.muted,
          child: SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: shadcn.CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _posterFallback(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.muted,
      child: SizedBox(
        width: 100,
        height: 150,
        child: Icon(
          shadcn.LucideIcons.film,
          color: cs.mutedForeground.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 56, child: Text(label).xSmall.muted),
          Expanded(child: Text(value).xSmall),
        ],
      ),
    );
  }
}
