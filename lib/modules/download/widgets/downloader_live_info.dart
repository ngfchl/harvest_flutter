import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:harvest/core/utils/utils.dart';

import '../model/downloader_speed.dart';

class DownloaderLiveInfo extends StatelessWidget {
  final DownloaderInfo info;
  final bool isQb;

  const DownloaderLiveInfo({super.key, required this.info, required this.isQb});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final primary = cs.primary;
    final destructive = cs.destructive;
    final warning = Color.lerp(cs.primary, cs.destructive, 0.45)!;

    return SizedBox(
      width: double.infinity,
      child: shadcn.Card(
        padding: EdgeInsets.zero,
        filled: true,
        fillColor: cs.muted.withValues(alpha: 0.28),
        child: Column(
          children: [
            // ── 速度 + 版本 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                theme.density.baseContentPadding * theme.scaling * 0.65,
                theme.density.baseGap * theme.scaling,
                theme.density.baseContentPadding * theme.scaling * 0.65,
                0,
              ),
              child: Row(
                children: [
                  _speedChip(
                    icon: shadcn.LucideIcons.arrowDown,
                    color: primary,
                    text: _formatSpeed(info.downloadSpeed),
                    active: info.downloadSpeed > 0,
                    theme: theme,
                    cs: cs,
                    typo: typo,
                  ),
                  SizedBox(width: theme.density.baseGap * theme.scaling * 0.75),
                  _speedChip(
                    icon: shadcn.LucideIcons.arrowUp,
                    color: destructive,
                    text: _formatSpeed(info.uploadSpeed),
                    active: info.uploadSpeed > 0,
                    theme: theme,
                    cs: cs,
                    typo: typo,
                  ),
                  const Spacer(),
                  if (info.version.isNotEmpty)
                    shadcn.OutlineBadge(child: Text(info.version)),
                ],
              ),
            ),

            // ── 分割线 ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    theme.density.baseContentPadding * theme.scaling * 0.65,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: theme.density.baseGap * theme.scaling,
                ),
                child: Divider(height: 1, color: cs.border),
              ),
            ),

            // ── 统计数据 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                theme.density.baseContentPadding * theme.scaling * 0.65,
                theme.density.baseGap * theme.scaling,
                theme.density.baseContentPadding * theme.scaling * 0.65,
                theme.density.baseGap * theme.scaling,
              ),
              child: Row(
                children: [
                  _statItem(
                    label: '上传',
                    value: _formatSize(info.uploadedSession),
                    color: destructive,
                    cs: cs,
                    typo: typo,
                  ),
                  SizedBox(width: theme.density.baseGap * theme.scaling * 0.5),
                  _statDivider(theme, cs),
                  SizedBox(width: theme.density.baseGap * theme.scaling * 0.5),
                  _statItem(
                    label: '下载',
                    value: _formatSize(info.downloadedSession),
                    color: primary,
                    cs: cs,
                    typo: typo,
                  ),
                  if (isQb && info.hasLimit) ...[
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statDivider(theme, cs),
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statItem(
                      label: '限速',
                      value:
                          '${_formatLimit(info.uploadLimit)}/${_formatLimit(info.downloadLimit)}',
                      color: warning,
                      cs: cs,
                      typo: typo,
                    ),
                  ],
                  if (!isQb && info.activeTorrentCount > 0) ...[
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statDivider(theme, cs),
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statItem(
                      label: '活跃',
                      value: '${info.activeTorrentCount}',
                      color: primary,
                      cs: cs,
                      typo: typo,
                    ),
                  ],
                  if (!isQb && info.totalTorrentCount > 0) ...[
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statDivider(theme, cs),
                    SizedBox(
                      width: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    _statItem(
                      label: '总数',
                      value: '${info.totalTorrentCount}',
                      color: cs.mutedForeground,
                      cs: cs,
                      typo: typo,
                    ),
                  ],
                  const Spacer(),
                  if (info.freeSpace > 0)
                    _statItem(
                      label: '剩余',
                      value: _formatSize(info.freeSpace),
                      color: cs.mutedForeground,
                      cs: cs,
                      typo: typo,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speedChip({
    required IconData icon,
    required Color color,
    required String text,
    required bool active,
    required shadcn.ThemeData theme,
    required shadcn.ColorScheme cs,
    required shadcn.Typography typo,
  }) {
    return shadcn.Card(
      padding: EdgeInsets.symmetric(
        horizontal: theme.density.baseGap * theme.scaling,
        vertical: theme.density.baseGap * theme.scaling * 0.5,
      ),
      filled: true,
      fillColor: active
          ? color.withValues(alpha: 0.08)
          : cs.mutedForeground.withValues(alpha: 0.04),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: theme.scaling * 12,
            color: active ? color : cs.mutedForeground.withValues(alpha: 0.4),
          ),
          SizedBox(width: theme.density.baseGap * theme.scaling * 0.5),
          Text(
            text,
            style: typo.xSmall.copyWith(
              color: active ? color : cs.mutedForeground,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(shadcn.ThemeData theme, shadcn.ColorScheme cs) {
    return SizedBox(
      height: theme.scaling * 24,
      child: VerticalDivider(width: 1, thickness: 1, color: cs.border),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
    required shadcn.ColorScheme cs,
    required shadcn.Typography typo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: typo.xSmall.copyWith(color: cs.mutedForeground)),
        const SizedBox(height: 1),
        Text(
          value,
          style: typo.xSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static String _formatSpeed(int bps) => formatBytes(bps, suffix: '/s');

  static String _formatSize(int bytes) => formatBytes(bytes);

  static String _formatLimit(int bps) =>
      formatBytes(bps, suffix: '/s', showZero: false);
}
