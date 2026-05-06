import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../model/media_item.dart';
import '../service/tmdb_service.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback? onTap;
  final double width;

  const MediaCard({super.key, required this.item, this.onTap, this.width = 120});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(context),
            const SizedBox(height: 6),
            Tooltip(
              message: item.title,
              waitDuration: const Duration(milliseconds: 400),
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (item.releaseDate.isNotEmpty)
                  Text(
                    item.releaseDate.length >= 4 ? item.releaseDate.substring(0, 4) : item.releaseDate,
                    style: context.theme.typography.xs.copyWith(color: context.theme.colors.mutedForeground),
                  ),
                if (item.mediaType.isNotEmpty) ...[const SizedBox(width: 4), _typeBadge(context)],
              ],
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
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.isNotEmpty)
              CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FIcons.star, size: 10, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        item.voteAverage!.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _posterPlaceholder(BuildContext context) => Container(
    color: context.theme.colors.muted,
    child: Center(
      child: Icon(FIcons.film, size: 32, color: context.theme.colors.mutedForeground.withValues(alpha: 0.3)),
    ),
  );

  Widget _typeBadge(BuildContext context) {
    final isMovie = item.mediaType == 'movie';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
      decoration: BoxDecoration(
        color: (isMovie ? context.theme.colors.primary : context.theme.colors.destructive).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        isMovie ? '电影' : '剧集',
        style: TextStyle(
          fontSize: 8,
          color: isMovie ? context.theme.colors.primary : context.theme.colors.destructive,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
