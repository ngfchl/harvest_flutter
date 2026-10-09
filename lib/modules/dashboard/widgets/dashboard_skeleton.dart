import 'package:shadcn_flutter/shadcn_flutter.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _box(context, height: 80),
        const SizedBox(height: 16),
        _box(context, height: 200),
        const SizedBox(height: 16),
        _box(context, height: 200),
      ],
    );
  }

  Widget _box(BuildContext context, {double height = 100}) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.55),
        borderRadius: theme.borderRadiusLg,
      ),
    );
  }
}
