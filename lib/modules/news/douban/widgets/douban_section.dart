import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';


class DoubanSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  const DoubanSection({
    super.key,
    required this.title,
    required this.items,
    this.onSeeAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = context.isMobile;
    final cardWidth = mobile ? 110.0 : 140.0;
    // 海报(2:3) + 间距4 + 标题~16 + 副标题~16 + 余量
    final cardHeight = cardWidth * 1.5 + 56;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (isLoading)
          SizedBox(
            height: cardHeight,
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
            height: cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: mobile ? 12 : 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => items[i],
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}
