import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../provider/downloader_speed_provider.dart';

void showSpeedSettings(BuildContext context, WidgetRef ref) {
  final theme = shadcn.Theme.of(context);
  final cs = shadcn.Theme.of(context).colorScheme;
  final sheetBackground = cs.background;

  showAppSheet<void>(
    context: context,
    backgroundColor: sheetBackground,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      top: false,
      child: shadcn.Card(
        filled: true,
        fillColor: sheetBackground,
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
            _sliderSetting(
              context,
              icon: shadcn.LucideIcons.timer,
              label: '刷新间隔',
              valueLabel: '${interval}s',
              value: interval.toDouble(),
              min: kMinInterval.toDouble(),
              max: kMaxInterval.toDouble(),
              divisions: kMaxInterval - kMinInterval,
              onChanged: (v) =>
                  ref.read(speedIntervalProvider.notifier).update(v.round()),
            ),
            SizedBox(height: theme.density.baseGap * theme.scaling),

            // ── 自动停止时长 ──
            SizedBox(height: theme.density.baseGap * theme.scaling * 2),
            _sliderSetting(
              context,
              icon: shadcn.LucideIcons.clock,
              label: '自动停止',
              valueLabel: '${duration}min',
              value: duration.toDouble(),
              min: kMinDuration.toDouble(),
              max: kMaxDuration.toDouble(),
              divisions: kMaxDuration - kMinDuration,
              onChanged: (v) =>
                  ref.read(speedDurationProvider.notifier).update(v.round()),
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

  Widget _sliderSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String valueLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final theme = shadcn.Theme.of(context);

    return Column(
      children: [
        Row(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                valueLabel,
                style: theme.typography.xSmall.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.density.baseGap * theme.scaling),
        shadcn.Slider(
          value: shadcn.SliderValue.single(value),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: (v) => onChanged(v.value),
        ),
      ],
    );
  }

  Widget _presetChips(
    BuildContext context, {
    required int current,
    required List<int> presets,
    required String unit,
    required ValueChanged<int> onTap,
  }) {
    final theme = shadcn.Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: theme.scaling * 26),
      child: Wrap(
        spacing: theme.density.baseGap * theme.scaling,
        runSpacing: theme.density.baseGap * theme.scaling * 0.5,
        children: presets
            .map(
              (v) => current == v
                  ? shadcn.Button.secondary(
                      onPressed: () => onTap(v),
                      child: Text('$v$unit'),
                    )
                  : shadcn.Button.outline(
                      onPressed: () => onTap(v),
                      child: Text('$v$unit'),
                    ),
            )
            .toList(),
      ),
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
