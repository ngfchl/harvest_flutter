import 'package:flutter/material.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class CacheStatusBanner extends StatelessWidget {
  final DataCacheInfo info;
  final EdgeInsetsGeometry margin;

  const CacheStatusBanner({
    super.key,
    required this.info,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (!info.isCached) return const SizedBox.shrink();

    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final text = info.cachedAt == null
        ? '当前页使用缓存数据'
        : '当前页使用缓存数据 · ${formatDateTimeMinute(info.cachedAt!)}';

    return Padding(
      padding: margin,
      child: SizedBox(
        width: double.infinity,
        child: shadcn.Card(
          filled: true,
          fillColor: cs.primary.withValues(alpha: 0.08),
          borderColor: cs.primary.withValues(alpha: 0.22),
          padding: EdgeInsets.symmetric(
            horizontal: theme.density.baseGap * theme.scaling,
            vertical: theme.density.baseGap * theme.scaling * 0.6,
          ),
          child: Row(
            children: [
              Icon(
                shadcn.LucideIcons.database,
                size: theme.scaling * 12,
                color: cs.primary,
              ),
              SizedBox(width: theme.density.baseGap * theme.scaling * 0.75),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
