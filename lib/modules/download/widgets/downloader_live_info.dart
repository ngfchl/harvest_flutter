import 'package:flutter/material.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader_speed.dart';

class DownloaderLiveInfo extends StatelessWidget {
  final DownloaderInfo info;
  final bool isQb;
  final bool compact;

  const DownloaderLiveInfo({super.key, required this.info, required this.isQb, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final uploadColor = cs.primary;
    final downloadColor = cs.destructive;
    final tokens = _DownloaderLiveInfoTokens.of(context, compact: compact);
    final extraMetrics = <Widget>[
      if (info.activeTorrentCount > 0)
        _metricPill(context, label: '活跃', value: '${info.activeTorrentCount}', color: uploadColor),
      if (info.totalTorrentCount > 0)
        _metricPill(context, label: '总数', value: '${info.totalTorrentCount}', color: cs.mutedForeground),
      if (info.freeSpace > 0)
        _metricPill(context, label: '剩余', value: _formatSize(info.freeSpace), color: cs.mutedForeground),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: _primaryMetricTile(
                context,
                icon: shadcn.LucideIcons.arrowUp,
                label: '已上传',
                value: _formatSessionSize(info.uploadedSession),
                speed: _formatSpeed(info.uploadSpeed),
                limitLabel: _limitLabel(info.uploadLimit * (isQb ? 1 : 1000)),
                color: uploadColor,
                active: info.uploadSpeed > 0,
              ),
            ),
            SizedBox(width: tokens.size(compact ? 6 : 10)),
            Expanded(
              child: _primaryMetricTile(
                context,
                icon: shadcn.LucideIcons.arrowDown,
                label: '已下载',
                value: _formatSessionSize(info.downloadedSession),
                speed: _formatSpeed(info.downloadSpeed),
                limitLabel: _limitLabel(info.downloadLimit),
                color: downloadColor,
                active: info.downloadSpeed > 0,
              ),
            ),
          ],
        ),
        if (extraMetrics.isNotEmpty) ...[
          SizedBox(height: tokens.size(7)),
          Row(
            children: [
              for (var i = 0; i < extraMetrics.length; i++) ...[
                if (i > 0) SizedBox(width: tokens.size(6)),
                Expanded(child: extraMetrics[i]),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _primaryMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String speed,
    required String limitLabel,
    required Color color,
    required bool active,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderLiveInfoTokens.of(context, compact: compact);
    final effectiveColor = color;

    return Container(
      constraints: BoxConstraints(minHeight: tokens.size(48)),
      padding: tokens.edgeSymmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.035), cs.muted.withValues(alpha: 0.10)),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(color: active ? color.withValues(alpha: 0.22) : cs.border.withValues(alpha: 0.58)),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.size(34),
            height: tokens.size(34),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: active ? 0.12 : 0.075),
              borderRadius: BorderRadius.circular(theme.radiusSm),
              border: Border.all(color: effectiveColor.withValues(alpha: active ? 0.20 : 0.12)),
            ),
            child: Icon(icon, size: tokens.icon(20), color: effectiveColor),
          ),
          SizedBox(width: tokens.size(8)),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xSmall.copyWith(
                          color: cs.foreground.withValues(alpha: 0.70),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (limitLabel.isNotEmpty) ...[
                      SizedBox(width: tokens.size(6)),
                      Flexible(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: tokens.size(compact ? 56 : 64)),
                            child: _limitBadge(context, label: limitLabel, color: color),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: tokens.size(3)),
                _metricValueLine(context, text: '$value ($speed)', color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricValueLine(BuildContext context, {required String text, required Color color}) {
    final theme = shadcn.Theme.of(context);
    final style = theme.typography.small.copyWith(color: color, fontWeight: FontWeight.w800);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxWidth.isFinite) {
          return Text(text, maxLines: 1, softWrap: false, style: style);
        }

        return SizedBox(
          width: constraints.maxWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(text, maxLines: 1, softWrap: false, style: style),
          ),
        );
      },
    );
  }

  Widget _limitBadge(BuildContext context, {required String label, required Color color}) {
    final theme = shadcn.Theme.of(context);
    final tokens = _DownloaderLiveInfoTokens.of(context, compact: compact);
    return Container(
      alignment: Alignment.center,
      padding: tokens.edgeSymmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.xSmall.copyWith(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _metricPill(BuildContext context, {required String label, required String value, required Color color}) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final tokens = _DownloaderLiveInfoTokens.of(context, compact: compact);
    return Container(
      padding: tokens.edgeSymmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: cs.border.withValues(alpha: 0.58)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.typography.xSmall.copyWith(color: cs.mutedForeground, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: tokens.size(4)),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(color: color, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSpeed(int bps) => formatBytes(bps, suffix: '/s');

  String _formatSize(int bytes) => formatBytes(bytes);

  String _formatSessionSize(int bytes) => formatBytes(bytes, decimals: 0);

  String _formatLimit(int bps) =>
      formatBytes(bps, suffix: '/s', showZero: false, decimals: 0, unit: isQb ? 1024 : 1000);

  String _limitLabel(int bps) {
    if (!info.hasLimit || bps <= 0) return '';
    final prefix = info.alternativeSpeedEnabled ? '备用 ' : '';
    return '$prefix${_formatLimit(bps)}';
  }
}

class _DownloaderLiveInfoTokens {
  final double densityScale;
  final double iconScale;

  const _DownloaderLiveInfoTokens._({required this.densityScale, required this.iconScale});

  factory _DownloaderLiveInfoTokens.of(BuildContext context, {required bool compact}) {
    final theme = shadcn.Theme.of(context);
    final densityScale = ((theme.density.baseContentPadding / 16.0) * theme.scaling * (compact ? 0.92 : 1.0))
        .clamp(0.68, 1.28)
        .toDouble();
    return _DownloaderLiveInfoTokens._(
      densityScale: densityScale,
      iconScale: theme.scaling.clamp(0.82, 1.24).toDouble(),
    );
  }

  double size(num value) => value * densityScale;

  double icon(num value) => value * iconScale;

  EdgeInsets edgeSymmetric({num horizontal = 0, num vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: size(horizontal), vertical: size(vertical));
}
