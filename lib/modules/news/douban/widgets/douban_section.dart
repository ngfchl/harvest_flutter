import 'package:flutter/material.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

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
              Text(title).base.bold,
              const Spacer(),
              if (onSeeAll != null)
                shadcn.Button.link(
                  onPressed: onSeeAll,
                  child: const Text('查看全部'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          SizedBox(
            height: cardHeight,
            child: const Center(child: shadcn.CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          SizedBox(
            height: 80,
            child: Center(child: const Text('暂无数据').small.muted),
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
