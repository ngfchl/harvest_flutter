import 'package:cached_network_image/cached_network_image.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class DoubanCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String? rating;
  final String? subtitle;
  final String? badge;
  final String? cookie;
  final VoidCallback? onTap;
  final double width;

  const DoubanCard({
    super.key,
    required this.title,
    required this.posterUrl,
    this.rating,
    this.subtitle,
    this.badge,
    this.cookie,
    this.onTap,
    this.width = 120,
  });

  // 删掉 static const _headers，改为方法
  Map<String, String> _buildHeaders() => {
    'Referer': 'https://movie.douban.com/',
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36',
    'cookie': cookie ?? '',
  };

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onPressed: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 海报
            _buildPoster(context),

            const SizedBox(height: 6),

            // 标题
            Tooltip(
              tooltip: (_) => Text(title.isEmpty ? '-' : title).small,
              child: SizedBox(
                height: 16,
                child: Text(title.isEmpty ? '-' : title, maxLines: 1, overflow: TextOverflow.ellipsis).small.semiBold,
              ),
            ),

            // 副标题
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Tooltip(
                tooltip: (_) => Text(subtitle!).small,
                child: SizedBox(
                  height: 14,
                  child: Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis).xSmall.muted,
                ),
              ),
            ],

            // 无副标题时补一个占位，保证对齐
            if (subtitle == null || subtitle!.isEmpty) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: Theme.of(context).borderRadiusMd,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _posterImage(context),
            if (rating != null && rating!.isNotEmpty)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.popover.withValues(alpha: 0.86),
                    borderRadius: Theme.of(context).borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.star, size: 10, color: Theme.of(context).colorScheme.chart4),
                      const SizedBox(width: 2),
                      Text(rating!).xSmall.semiBold.primaryForeground,
                    ],
                  ),
                ),
              ),
            if (badge != null && badge!.isNotEmpty)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: PrimaryBadge(child: Text(badge!)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _posterImage(BuildContext context) {
    if (posterUrl.isEmpty) return _placeholder(context);

    return CachedNetworkImage(
      imageUrl: posterUrl,
      httpHeaders: _buildHeaders(),
      fit: BoxFit.cover,
      placeholder: (_, _) =>
          const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      errorWidget: (_, _, _) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.muted,
    child: Center(
      child: Icon(
        LucideIcons.film,
        size: 32,
        color: Theme.of(context).colorScheme.mutedForeground.withValues(alpha: 0.3),
      ),
    ),
  );
}
