import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _box(height: 80),
        const SizedBox(height: 16),
        _box(height: 200),
        const SizedBox(height: 16),
        _box(height: 200),
      ],
    );
  }

  Widget _box({double height = 100}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}