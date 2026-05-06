import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/media_item.dart';
import 'media_card.dart';

class MediaSection extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final ValueChanged<MediaItem>? onItemTap;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  const MediaSection({
    super.key,
    required this.title,
    required this.items,
    this.onItemTap,
    this.onSeeAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final cardWidth = mobile ? 110.0 : 140.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 16),
          child: Row(
            children: [
              Text(title, style: context.theme.typography.base.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (onSeeAll != null)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Text('查看全部', style: context.theme.typography.sm.copyWith(color: context.theme.colors.primary)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 内容
        if (isLoading)
          SizedBox(
            height: cardWidth * 1.5 + 40,
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          SizedBox(
            height: 80,
            child: Center(
              child: Text('暂无数据', style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground)),
            ),
          )
        else
          SizedBox(
            height: cardWidth * 1.5 + 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => MediaCard(
                item: items[i],
                width: cardWidth,
                onTap: onItemTap != null ? () => onItemTap!(items[i]) : null,
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
