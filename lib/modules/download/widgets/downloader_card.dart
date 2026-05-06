import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';

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

class _DownloaderCardState extends ConsumerState<DownloaderCard>
    with TickerProviderStateMixin {
  late FPopoverController _popoverCtrl;

  @override
  void initState() {
    super.initState();
    _popoverCtrl = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    _popoverCtrl.dispose();
    super.dispose();
  }

  Downloader get d => widget.downloader;

  bool get isQb => d.isQb;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final cs = theme.colors;
    final typo = theme.typography;
    final categoryColor = isQb
        ? const Color(0xFF3B82F6)
        : const Color(0xFFEF4444);

    // 实时数据
    final speedMap = ref.watch(downloaderSpeedProvider);
    DownloaderInfo? liveInfo;
    for (final entry in speedMap.entries) {
      if (entry.key.toLowerCase() == d.wsKey.toLowerCase()) {
        liveInfo = entry.value.info;
        break;
      }
    }

    final menu = DownloaderCardMenu(
      downloader: d,
      hideMenu: _popoverCtrl.hide,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onToggleActive: widget.onToggleActive,
      onToggleBrush: widget.onToggleBrush,
    );

    return FPopoverMenu.tiles(
      popoverController: _popoverCtrl,
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menu: menu.build(context),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _popoverCtrl.toggle(),
        onLongPress: () => _popoverCtrl.toggle(),
        onSecondaryTap: () => _popoverCtrl.toggle(),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.border, width: 1),
            boxShadow: [
              // 主阴影：更大的扩散和偏移
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
              // 边缘光：让卡片底部有微妙的深色边缘
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 顶部：图标 + 名称 + 状态标签 ──
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          isQb ? 'QB' : 'TR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: categoryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: typo.sm.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              // 连接状态
                              _statusDot(
                                active: liveInfo != null,
                                color: liveInfo != null
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                liveInfo != null ? '已连接' : '未连接',
                                style: typo.xs.copyWith(
                                  fontSize: 10,
                                  color: liveInfo != null
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              // 启用状态
                              const SizedBox(width: 8),
                              _statusDot(
                                active: d.isActive,
                                color: d.isActive
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                d.isActive ? '运行中' : '已停用',
                                style: typo.xs.copyWith(
                                  fontSize: 10,
                                  color: d.isActive
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              // 辅种标签
                              if (!d.brush) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '辅种',
                                    style: typo.xs.copyWith(
                                      fontSize: 9,
                                      color: const Color(0xFFF59E0B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── 连接信息 ──
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.mutedForeground.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FIcons.globe,
                        size: 11,
                        color: cs.mutedForeground.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${d.protocol}://${d.host}:${d.port}',
                          style: typo.xs.copyWith(
                            color: cs.mutedForeground.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        FIcons.folder,
                        size: 11,
                        color: cs.mutedForeground.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        d.torrentPath,
                        style: typo.xs.copyWith(
                          color: cs.mutedForeground.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── 实时数据 ──
                if (liveInfo != null) ...[
                  const SizedBox(height: 10),
                  DownloaderLiveInfo(info: liveInfo, isQb: isQb),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusDot({required bool active, required Color color}) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: active ? color : color.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
