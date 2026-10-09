import 'package:harvest/modules/download/model/downloader.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/shadcn_compat.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter_material/shadcn_flutter_material.dart';

class HeaderMenuAction {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const HeaderMenuAction(this.id, this.icon, this.label, this.onTap);
}

class DownloaderHeaderMenu extends StatelessWidget {
  final DownloaderType downloaderType;
  final Downloader? downloader;
  final int currentCount;
  final VoidCallback onRefresh;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReannounce;
  final VoidCallback onRecheck;
  final VoidCallback? onCategoryManagement;
  final VoidCallback? onTagManagement;
  final VoidCallback? onSpeedLimitSettings;
  final VoidCallback? onReplaceTrackers;

  const DownloaderHeaderMenu({
    super.key,
    required this.downloaderType,
    required this.downloader,
    required this.currentCount,
    required this.onRefresh,
    required this.onStart,
    required this.onPause,
    required this.onReannounce,
    required this.onRecheck,
    required this.onCategoryManagement,
    required this.onTagManagement,
    required this.onSpeedLimitSettings,
    this.onReplaceTrackers,
  });

  @override
  Widget build(BuildContext context) {
    final isQb = downloaderType == DownloaderType.qbittorrent;

    final actions = <HeaderMenuAction>[
      HeaderMenuAction('refresh', LucideIcons.refreshCw, '刷新列表', onRefresh),
      HeaderMenuAction('start', LucideIcons.play, '开始当前列表', currentCount > 0 ? onStart : null),
      HeaderMenuAction('pause', LucideIcons.pause, '暂停当前列表', currentCount > 0 ? onPause : null),
      HeaderMenuAction('reannounce', Icons.campaign_outlined, '重新汇报当前列表', currentCount > 0 ? onReannounce : null),
      HeaderMenuAction('recheck', Icons.fact_check_outlined, '重新校验当前列表', currentCount > 0 ? onRecheck : null),
      HeaderMenuAction('speed', LucideIcons.gauge, '限速设置', downloader != null ? onSpeedLimitSettings : null),
      if (isQb) ...[
        HeaderMenuAction('category', LucideIcons.tags, '分类管理', downloader != null ? onCategoryManagement : null),
        HeaderMenuAction('tag', LucideIcons.tag, '标签管理', downloader != null ? onTagManagement : null),
        HeaderMenuAction('trackers', LucideIcons.replace, '批量替换 Tracker', onReplaceTrackers),
      ],
    ];

    return Builder(
      builder: (anchorContext) => Tooltip(
        tooltip: (_) => const Text('更多操作'),
        child: IconButton.ghost(
          icon: const Icon(LucideIcons.ellipsisVertical),
          onPressed: () => _showMenu(anchorContext, actions),
        ),
      ),
    );
  }

  void _showMenu(BuildContext anchorContext, List<HeaderMenuAction> actions) {
    final menuKey = GlobalKey();
    showPopover<void>(
      context: anchorContext,
      alignment: Alignment.topRight,
      anchorAlignment: Alignment.bottomRight,
      widthConstraint: PopoverConstraint.intrinsic,
      offset: const Offset(0, 8),
      consumeOutsideTaps: false,
      regionGroupId: menuKey,
      overlayBarrier: OverlayBarrier(borderRadius: BorderRadius.circular(Theme.of(anchorContext).radiusMd)),
      builder: (_) => Data.inherit(
        data: DropdownMenuData(menuKey),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: appMenu(
            children: [
              MenuLabel(child: Text('当前列表 $currentCount 个种子').small),
              const MenuDivider(),
              for (final action in actions)
                MenuButton(
                  leading: Icon(action.icon, size: 16),
                  enabled: action.onTap != null,
                  onPressed: (_) => action.onTap?.call(),
                  child: SizedBox(width: 180, child: Text(action.label).small),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
