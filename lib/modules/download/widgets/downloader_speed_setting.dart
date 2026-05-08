import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../provider/downloader_speed_provider.dart';

void showSpeedSettings(BuildContext context, WidgetRef ref) {
  final theme = shadcn.Theme.of(context);
  final cs = shadcn.Theme.of(context).colorScheme;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: cs.background,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: shadcn.Card(
        filled: true,
        fillColor: cs.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radiusLg),
        ),
        padding: EdgeInsets.fromLTRB(
          theme.density.baseContentPadding * theme.scaling,
          theme.density.baseGap * theme.scaling,
          theme.density.baseContentPadding * theme.scaling,
          theme.density.baseContentPadding * theme.scaling,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽条
            shadcn.SecondaryBadge(
              child: SizedBox(
                width: theme.scaling * 28,
                height: theme.scaling * 2,
              ),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling),
            // 标题
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: theme.density.baseGap * theme.scaling * 0.5,
              ),
              child: Row(
                children: [
                  Icon(
                    shadcn.LucideIcons.settings,
                    size: theme.scaling * 16,
                    color: cs.mutedForeground,
                  ),
                  SizedBox(width: theme.density.baseGap * theme.scaling),
                  Text(
                    '刷新设置',
                    style: theme.typography.small.copyWith(
                      color: cs.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling),
            // 设置内容
            const DownloaderSpeedSettings(),
          ],
        ),
      ),
    ),
  );
}

class DownloaderSpeedSettings extends ConsumerWidget {
  const DownloaderSpeedSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interval = ref.watch(speedIntervalProvider);
    final duration = ref.watch(speedDurationProvider);
    final enabled = ref.watch(speedEnabledProvider);
    final theme = shadcn.Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.density.baseGap * theme.scaling,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 自动刷新开关 ──
          _settingRow(
            context,
            icon: shadcn.LucideIcons.refreshCw,
            label: '自动刷新数据',
            trailing: shadcn.Switch(
              value: enabled,
              enabled: true,
              onChanged: (v) => ref.read(speedEnabledProvider.notifier).set(v),
            ),
          ),

          if (enabled) ...[
            // ── 刷新间隔 ──
            SizedBox(height: theme.density.baseGap * theme.scaling * 1.5),
            _settingRow(
              context,
              icon: shadcn.LucideIcons.timer,
              label: '刷新间隔',
              trailing: _NumberPicker(
                value: interval,
                unit: 's',
                min: kMinInterval,
                max: kMaxInterval,
                onMinus: () => ref
                    .read(speedIntervalProvider.notifier)
                    .update(interval - 1),
                onPlus: () => ref
                    .read(speedIntervalProvider.notifier)
                    .update(interval + 1),
              ),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling),
            _presetChips(
              context,
              ref,
              current: interval,
              presets: const [3, 5, 10, 30],
              unit: 's',
              onTap: (v) => ref.read(speedIntervalProvider.notifier).update(v),
            ),

            // ── 自动停止时长 ──
            SizedBox(height: theme.density.baseGap * theme.scaling * 2),
            _settingRow(
              context,
              icon: shadcn.LucideIcons.clock,
              label: '自动停止',
              trailing: _NumberPicker(
                value: duration,
                unit: 'min',
                min: kMinDuration,
                max: kMaxDuration,
                onMinus: () => ref
                    .read(speedDurationProvider.notifier)
                    .update(duration - 1),
                onPlus: () => ref
                    .read(speedDurationProvider.notifier)
                    .update(duration + 1),
              ),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling),
            _presetChips(
              context,
              ref,
              current: duration,
              presets: const [1, 3, 5, 10, 30],
              unit: 'min',
              onTap: (v) => ref.read(speedDurationProvider.notifier).update(v),
            ),
          ],
          SizedBox(height: theme.density.baseGap * theme.scaling),
        ],
      ),
    );
  }

  Widget _settingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget trailing,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final theme = shadcn.Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: theme.scaling * 16, color: cs.mutedForeground),
        SizedBox(width: theme.density.baseGap * theme.scaling),
        Expanded(
          child: Text(
            label,
            style: theme.typography.xSmall.copyWith(
              color: cs.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _presetChips(
    BuildContext context,
    WidgetRef ref, {
    required int current,
    required List<int> presets,
    required String unit,
    required ValueChanged<int> onTap,
  }) {
    final theme = shadcn.Theme.of(context);
    return Row(
      children: [
        SizedBox(width: theme.scaling * 26),
        ...presets.map(
          (v) => Padding(
            padding: EdgeInsets.only(
              right: theme.density.baseGap * theme.scaling,
            ),
            child: current == v
                ? shadcn.Button.secondary(
                    onPressed: () => onTap(v),
                    child: Text('$v$unit'),
                  )
                : shadcn.Button.outline(
                    onPressed: () => onTap(v),
                    child: Text('$v$unit'),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── 数字选择器 ──

class _NumberPicker extends StatelessWidget {
  final int value;
  final String unit;
  final int min;
  final int max;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _NumberPicker({
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final theme = shadcn.Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(context, shadcn.LucideIcons.minus, value > min, onMinus),
        SizedBox(
          width: theme.scaling * 52,
          child: Text(
            '$value$unit',
            textAlign: TextAlign.center,
            style: theme.typography.small.copyWith(
              color: cs.foreground,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _btn(context, shadcn.LucideIcons.plus, value < max, onPlus),
      ],
    );
  }

  Widget _btn(
    BuildContext context,
    IconData icon,
    bool enabled,
    VoidCallback onTap,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final theme = shadcn.Theme.of(context);
    return shadcn.IconButton.outline(
      onPressed: enabled ? onTap : null,
      icon: Icon(
        icon,
        size: theme.scaling * 14,
        color: enabled
            ? cs.foreground.withValues(alpha: 0.7)
            : cs.foreground.withValues(alpha: 0.2),
      ),
    );
  }
}
