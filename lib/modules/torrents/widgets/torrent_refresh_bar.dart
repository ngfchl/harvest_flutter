import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/modules/download/provider/downloader_speed_provider.dart';
import 'package:harvest/modules/download/widgets/downloader_speed_setting.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../provider/downloader_provider.dart';
import 'torrent_stats_bar.dart';

class TorrentRefreshBar extends ConsumerWidget {
  final int downloaderId;
  final VoidCallback onRefresh;
  final VoidCallback onRefreshStateChanged;

  const TorrentRefreshBar({
    super.key,
    required this.downloaderId,
    required this.onRefresh,
    required this.onRefreshStateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final enabled = ref.watch(speedEnabledProvider);
    final paused = ref.watch(torrentRefreshPausedProvider(downloaderId));
    final remaining = ref.watch(torrentRefreshRemainingProvider(downloaderId));

    final running = enabled && !paused;
    final min = remaining ~/ 60;
    final sec = remaining % 60;
    final countdown = remaining > 0
        ? '$min:${sec.toString().padLeft(2, '0')}'
        : '';
    final pauseButtonColor = !enabled
        ? cs.mutedForeground.withValues(alpha: 0.35)
        : paused
        ? const Color(0xFF10B981)
        : const Color(0xFFF59E0B);
    final pauseButtonBg = !enabled
        ? cs.foreground.withValues(alpha: 0.04)
        : pauseButtonColor.withValues(alpha: 0.1);

    final surfaceOpacity = (shadcn.Theme.of(context).surfaceOpacity ?? 1.0).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
      decoration: BoxDecoration(
        color: cs.background.withValues(alpha: surfaceOpacity),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: running
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            running
                ? '种子数据自动刷新中'
                : enabled
                ? '种子数据已暂停'
                : '自动刷新已关闭',
            style: typo.xSmall.copyWith(
              color: cs.mutedForeground.withValues(alpha: 0.55),
              fontSize: 11,
            ),
          ),
          if (running && countdown.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: remaining <= 60
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                    : cs.foreground.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    shadcn.LucideIcons.timer,
                    size: 10,
                    color: remaining <= 60
                        ? const Color(0xFFF59E0B)
                        : cs.mutedForeground.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    countdown,
                    style: typo.xSmall.copyWith(
                      fontSize: 10,
                      color: remaining <= 60
                          ? const Color(0xFFF59E0B)
                          : cs.mutedForeground.withValues(alpha: 0.5),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          StatusBarIconButton(
            onTap: onRefresh,
            icon: shadcn.LucideIcons.refreshCw,
            tooltip: '刷新',
          ),
          StatusBarIconButton(
            onTap: () => showSpeedSettings(context, ref),
            icon: shadcn.LucideIcons.settings,
            tooltip: '刷新设置',
          ),
          StatusBarPillButton(
            onTap: enabled
                ? () {
                    final nextPaused = !paused;
                    ref
                            .read(
                              torrentRefreshPausedProvider(
                                downloaderId,
                              ).notifier,
                            )
                            .state =
                        nextPaused;
                    ref
                        .read(torrentListProvider(downloaderId).notifier)
                        .setWsPaused(nextPaused);
                    onRefreshStateChanged();
                  }
                : null,
            icon: paused ? shadcn.LucideIcons.play : shadcn.LucideIcons.pause,
            label: paused ? '恢复' : '暂停',
            color: pauseButtonColor,
            backgroundColor: pauseButtonBg,
            tooltip: paused ? '恢复自动刷新' : '暂停自动刷新',
          ),
        ],
      ),
    );
  }
}
