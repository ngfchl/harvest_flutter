import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/ui/responsive.dart';
import 'package:harvest/modules/torrents/torrent_list_page.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/downloader.dart';
import '../model/downloader_speed.dart';
import '../provider/downloader_speed_provider.dart';
import 'downloader_card_menu.dart';
import 'downloader_live_info.dart';

class DownloaderCard extends ConsumerStatefulWidget {
  final Downloader downloader;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleBrush;

  const DownloaderCard({
    super.key,
    required this.downloader,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleBrush,
  });

  @override
  ConsumerState<DownloaderCard> createState() => _DownloaderCardState();
}

class _DownloaderCardState extends ConsumerState<DownloaderCard> {
  Downloader get d => widget.downloader;

  bool get isQb => d.isQb;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final categoryColor = isQb ? cs.primary : cs.destructive;
    final successColor = cs.primary;
    final inactiveColor = cs.destructive;

    // 实时数据
    final speedMap = ref.watch(downloaderSpeedProvider);
    DownloaderInfo? liveInfo;
    for (final entry in speedMap.entries) {
      final key = entry.key.toLowerCase();
      if (key == d.wsKey.toLowerCase() || key == d.id.toString()) {
        liveInfo = entry.value.info;
        break;
      }
    }

    final menu = DownloaderCardMenu(
      downloader: d,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onToggleActive: widget.onToggleActive,
      onToggleBrush: widget.onToggleBrush,
    );

    final card = AppContextMenu(
      items: menu.buildContextMenuItems(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: _openTorrentList,
        child: shadcn.Card(
          padding: EdgeInsets.zero,
          filled: true,
          fillColor: cs.card,
          child: Padding(
            padding: EdgeInsets.all(
              theme.density.baseContentPadding * theme.scaling * 0.85,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 顶部：图标 + 名称 + 状态标签 ──
                Row(
                  children: [
                    shadcn.SecondaryBadge(
                      child: Text(
                        isQb ? 'QB' : 'TR',
                        style: typo.xSmall.copyWith(
                          color: categoryColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SizedBox(width: theme.density.baseGap * theme.scaling),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: typo.small.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(
                            height:
                                theme.density.baseGap * theme.scaling * 0.35,
                          ),
                          Row(
                            children: [
                              // 连接状态
                              _statusDot(
                                active: liveInfo != null,
                                color: liveInfo != null
                                    ? successColor
                                    : inactiveColor,
                              ),
                              SizedBox(
                                width:
                                    theme.density.baseGap * theme.scaling * 0.5,
                              ),
                              Text(
                                liveInfo != null ? '已连接' : '未连接',
                                style: typo.xSmall.copyWith(
                                  color: liveInfo != null
                                      ? successColor
                                      : inactiveColor,
                                ),
                              ),
                              // 启用状态
                              SizedBox(
                                width: theme.density.baseGap * theme.scaling,
                              ),
                              _statusDot(
                                active: d.isActive,
                                color: d.isActive
                                    ? successColor
                                    : inactiveColor,
                              ),
                              SizedBox(
                                width:
                                    theme.density.baseGap * theme.scaling * 0.5,
                              ),
                              Text(
                                d.isActive ? '运行中' : '已停用',
                                style: typo.xSmall.copyWith(
                                  color: d.isActive
                                      ? successColor
                                      : inactiveColor,
                                ),
                              ),
                              // 辅种标签
                              if (!d.brush) ...[
                                SizedBox(
                                  width: theme.density.baseGap * theme.scaling,
                                ),
                                const shadcn.OutlineBadge(child: Text('辅种')),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── 连接信息 ──
                SizedBox(height: theme.density.baseGap * theme.scaling),
                SizedBox(
                  width: double.infinity,
                  child: shadcn.Card(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          theme.density.baseContentPadding *
                          theme.scaling *
                          0.65,
                      vertical: theme.density.baseGap * theme.scaling * 0.75,
                    ),
                    filled: true,
                    fillColor: cs.muted.withValues(alpha: 0.35),
                    child: Row(
                      children: [
                        Icon(
                          shadcn.LucideIcons.globe,
                          size: theme.scaling * 12,
                          color: cs.mutedForeground,
                        ),
                        SizedBox(
                          width: theme.density.baseGap * theme.scaling * 0.75,
                        ),
                        Expanded(
                          child: Text(
                            '${d.protocol}://${d.host}:${d.port}',
                            style: typo.xSmall.copyWith(
                              color: cs.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          shadcn.LucideIcons.folder,
                          size: theme.scaling * 12,
                          color: cs.mutedForeground,
                        ),
                        SizedBox(
                          width: theme.density.baseGap * theme.scaling * 0.5,
                        ),
                        Text(
                          d.torrentPath,
                          style: typo.xSmall.copyWith(
                            color: cs.mutedForeground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── 实时数据 ──
                if (liveInfo != null) ...[
                  SizedBox(height: theme.density.baseGap * theme.scaling),
                  DownloaderLiveInfo(info: liveInfo, isQb: isQb),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (!context.isMobile) return card;

    return shadcn.OverlayManagerLayer(
      popoverHandler: const shadcn.PopoverOverlayHandler(),
      tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
      menuHandler: const shadcn.PopoverOverlayHandler(),
      child: card,
    );
  }

  Future<void> _openTorrentList() async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TorrentListPage(
          downloaderId: d.id,
          downloaderName: d.name,
          downloaderType: d.isQb
              ? DownloaderType.qbittorrent
              : DownloaderType.transmission,
        ),
      ),
    );
  }

  Widget _statusDot({required bool active, required Color color}) {
    final size = shadcn.Theme.of(context).scaling * 7;
    return Icon(
      shadcn.LucideIcons.circle,
      size: size,
      color: active ? color : color.withValues(alpha: 0.4),
    );
  }
}
