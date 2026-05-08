import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;


class SiteErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const SiteErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shadcn.LucideIcons.triangleAlert,
            size: 48,
            color: cs.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: theme.typography.large),
          const SizedBox(height: 8),
          Text(
            '请检查网络或登录状态',
            style: theme.typography.small.copyWith(color: cs.mutedForeground),
          ),
          const SizedBox(height: 24),
          shadcn.Button.primary(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
