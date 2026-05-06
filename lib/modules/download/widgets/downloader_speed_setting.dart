import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../provider/downloader_speed_provider.dart';

void showSpeedSettings(BuildContext context, WidgetRef ref) {
  final cs = FTheme.of(context).colors;

  showFSheet(
    context: context,
    side: FLayout.btt,
    builder: (ctx) => SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽条
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cs.foreground.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    FIcons.settings,
                    size: 16,
                    color: cs.foreground.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '刷新设置',
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 自动刷新开关 ──
          _settingRow(
            context,
            icon: FIcons.refreshCw,
            label: '自动刷新数据',
            trailing: FSwitch(
              value: enabled,
              onChange: (v) => ref.read(speedEnabledProvider.notifier).set(v),
            ),
          ),

          if (enabled) ...[
            // ── 刷新间隔 ──
            const SizedBox(height: 12),
            _settingRow(
              context,
              icon: FIcons.timer,
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
            const SizedBox(height: 8),
            _presetChips(
              context,
              ref,
              current: interval,
              presets: const [3, 5, 10, 30],
              unit: 's',
              onTap: (v) => ref.read(speedIntervalProvider.notifier).update(v),
            ),

            // ── 自动停止时长 ──
            const SizedBox(height: 16),
            _settingRow(
              context,
              icon: FIcons.clock,
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
            const SizedBox(height: 8),
            _presetChips(
              context,
              ref,
              current: duration,
              presets: const [1, 3, 5, 10, 30],
              unit: 'min',
              onTap: (v) => ref.read(speedDurationProvider.notifier).update(v),
            ),
          ],
          const SizedBox(height: 8),
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
    final cs = FTheme.of(context).colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.foreground.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: cs.foreground,
              fontSize: 13,
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
    final cs = FTheme.of(context).colors;
    return Row(
      children: [
        const SizedBox(width: 26),
        ...presets.map(
          (v) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onTap(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: current == v
                      ? cs.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: current == v ? cs.primary : cs.border,
                  ),
                ),
                child: Text(
                  '$v$unit',
                  style: TextStyle(
                    color: current == v
                        ? cs.primary
                        : cs.foreground.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: current == v
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
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
    final cs = FTheme.of(context).colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(context, FIcons.minus, value > min, onMinus),
        Container(
          width: 52,
          alignment: Alignment.center,
          child: Text(
            '$value$unit',
            style: TextStyle(
              color: cs.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        _btn(context, FIcons.plus, value < max, onPlus),
      ],
    );
  }

  Widget _btn(
    BuildContext context,
    IconData icon,
    bool enabled,
    VoidCallback onTap,
  ) {
    final cs = FTheme.of(context).colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.border),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled
              ? cs.foreground.withValues(alpha: 0.7)
              : cs.foreground.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
