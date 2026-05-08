import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/media_item.dart';
import '../service/tmdb_service.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;
  final double width;

  const MediaCard({
    super.key,
    required this.item,
    this.onTap,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    return shadcn.Clickable(
      onPressed: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(context),
            const SizedBox(height: 6),
            SizedBox(
              height: 48,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shadcn.Tooltip(
                    tooltip: (_) => Text(item.title).small,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).small.semiBold,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (item.releaseDate.isNotEmpty)
                        Flexible(
                          child: Text(
                            item.releaseDate.length >= 4
                                ? item.releaseDate.substring(0, 4)
                                : item.releaseDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).xSmall.muted,
                        ),
                      if (item.mediaType.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        _typeBadge(context),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    final url = TmdbService.imageUrl(item.posterPath, size: 'w342');
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: shadcn.Theme.of(context).borderRadiusMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => _posterPlaceholder(context),
              )
            else
              _posterPlaceholder(context),
            if (item.voteAverage != null && item.voteAverage! > 0)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: shadcn.Theme.of(
                      context,
                    ).colorScheme.popover.withValues(alpha: 0.86),
                    borderRadius: shadcn.Theme.of(context).borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        shadcn.LucideIcons.star,
                        size: 10,
                        color: shadcn.Theme.of(context).colorScheme.chart4,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item.voteAverage!.toStringAsFixed(1),
                      ).xSmall.semiBold.primaryForeground,
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _posterPlaceholder(BuildContext context) => ColoredBox(
    color: shadcn.Theme.of(context).colorScheme.muted,
    child: Center(
      child: Icon(
        shadcn.LucideIcons.film,
        size: 32,
        color: shadcn.Theme.of(
          context,
        ).colorScheme.mutedForeground.withValues(alpha: 0.3),
      ),
    ),
  );

  Widget _typeBadge(BuildContext context) {
    final isMovie = item.mediaType == 'movie';
    return isMovie
        ? const shadcn.SecondaryBadge(child: Text('电影'))
        : const shadcn.OutlineBadge(child: Text('剧集'));
  }
}
