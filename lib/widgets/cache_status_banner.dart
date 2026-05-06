import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/utils/utils.dart';

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

    final cs = FTheme.of(context).colors;
    final text = info.cachedAt == null
        ? '当前页使用缓存数据'
        : '当前页使用缓存数据 · ${formatDateTimeMinute(info.cachedAt!)}';

    return Padding(
      padding: margin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.22),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(FIcons.database, size: 12, color: cs.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FTheme.of(context).typography.xs.copyWith(
                  color: cs.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
