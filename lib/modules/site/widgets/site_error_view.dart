import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class SiteErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const SiteErrorView({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FIcons.triangleAlert, size: 48, color: context.theme.colors.mutedForeground),
          const SizedBox(height: 16),
          Text('加载失败', style: context.theme.typography.lg),
          const SizedBox(height: 8),
          Text(
            '请检查网络或登录状态',
            style: context.theme.typography.sm.copyWith(color: context.theme.colors.mutedForeground),
          ),
          const SizedBox(height: 24),
          FButton(onPress: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
