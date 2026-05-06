import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/downloader_speed.dart';

class DownloaderLiveInfo extends StatelessWidget {
  final DownloaderInfo info;
  final bool isQb;

  const DownloaderLiveInfo({super.key, required this.info, required this.isQb});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colors;
    final typo = context.theme.typography;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.mutedForeground.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // ── 速度 + 版本 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              children: [
                _speedChip(
                  icon: FIcons.arrowDown,
                  color: Colors.blue,
                  text: _formatSpeed(info.downloadSpeed),
                  active: info.downloadSpeed > 0,
                  cs: cs,
                  typo: typo,
                ),
                const SizedBox(width: 6),
                _speedChip(
                  icon: FIcons.arrowUp,
                  color: Colors.green,
                  text: _formatSpeed(info.uploadSpeed),
                  active: info.uploadSpeed > 0,
                  cs: cs,
                  typo: typo,
                ),
                const Spacer(),
                if (info.version.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cs.mutedForeground.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      info.version,
                      style: typo.xs.copyWith(
                        color: cs.mutedForeground.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── 分割线 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Divider(
                height: 0.5,
                color: cs.border.withValues(alpha: 0.3),
              ),
            ),
          ),

          // ── 统计数据 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Row(
              children: [
                _statItem(
                  label: '上传',
                  value: _formatSize(info.uploadedSession),
                  color: Colors.green,
                  cs: cs,
                  typo: typo,
                ),
                const SizedBox(width: 4),
                Container(
                  width: 0.5,
                  height: 24,
                  color: cs.border.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 4),
                _statItem(
                  label: '下载',
                  value: _formatSize(info.downloadedSession),
                  color: Colors.blue,
                  cs: cs,
                  typo: typo,
                ),
                if (isQb && info.hasLimit) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 0.5,
                    height: 24,
                    color: cs.border.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 4),
                  _statItem(
                    label: '限速',
                    value:
                        '${_formatLimit(info.uploadLimit)}/${_formatLimit(info.downloadLimit)}',
                    color: Colors.orange,
                    cs: cs,
                    typo: typo,
                  ),
                ],
                if (!isQb && info.activeTorrentCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 0.5,
                    height: 24,
                    color: cs.border.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 4),
                  _statItem(
                    label: '活跃',
                    value: '${info.activeTorrentCount}',
                    color: Colors.teal,
                    cs: cs,
                    typo: typo,
                  ),
                ],
                if (!isQb && info.totalTorrentCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    width: 0.5,
                    height: 24,
                    color: cs.border.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 4),
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
    );
  }

  Widget _speedChip({
    required IconData icon,
    required Color color,
    required String text,
    required bool active,
    required FColors cs,
    required FTypography typo,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.08)
            : cs.mutedForeground.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: active ? color : cs.mutedForeground.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: typo.xs.copyWith(
              color: active ? color : cs.mutedForeground,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
    required FColors cs,
    required FTypography typo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: typo.xs.copyWith(
            color: cs.mutedForeground.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: typo.xs.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
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
