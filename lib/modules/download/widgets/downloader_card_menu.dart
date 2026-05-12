import 'package:flutter/material.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../torrents/torrent_list_page.dart';
import '../model/downloader.dart';
import '../service/downloader_service.dart';
import 'push_torrent_sheet.dart';
import 'qb_category_tag_manager.dart';
import 'qb_settings_dialog.dart';
import 'tr_settings_dialog.dart';

class DownloaderCardMenu {
  final Downloader downloader;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleBrush;

  const DownloaderCardMenu({
    required this.downloader,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleBrush,
  });

  List<shadcn.MenuItem> buildContextMenuItems(BuildContext hostContext) {
    final d = downloader;
    final isQb = d.isQb;
    final theme = shadcn.Theme.of(hostContext);
    final cs = theme.colorScheme;

    shadcn.MenuButton item({
      required IconData icon,
      required String title,
      required Future<void> Function(BuildContext menuContext) onPressed,
      bool destructive = false,
    }) {
      final color = destructive ? cs.destructive : cs.foreground;
      return shadcn.MenuButton(
        leading: Icon(icon, size: theme.scaling * 15, color: color),
        onPressed: onPressed,
        child: SizedBox(
          width: 168,
          child: Text(title, style: theme.typography.small.copyWith(color: color)),
        ),
      );
    }

    Future<void> close(BuildContext menuContext) {
      return shadcn.closeOverlay(menuContext);
    }

    return [
      shadcn.MenuLabel(child: Text(d.name).small),
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.list,
        title: '种子列表',
        onPressed: (ctx) async {
          await close(ctx);
          if (!hostContext.mounted) return;
          Navigator.push(
            hostContext,
            MaterialPageRoute(
              builder: (_) => TorrentListPage(
                downloaderId: d.id,
                downloaderName: d.name,
                downloaderType: d.isQb ? DownloaderType.qbittorrent : DownloaderType.transmission,
              ),
            ),
          );
        },
      ),
      item(
        icon: shadcn.LucideIcons.plus,
        title: '添加种子',
        onPressed: (ctx) async {
          await close(ctx);
          if (!hostContext.mounted) return;
          showAppSheet<void>(
            context: hostContext,
            isScrollControlled: true,
            backgroundColor: cs.background,
            builder: (_) => PushTorrentSheet(downloader: d),
          );
        },
      ),
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.pencil,
        title: '编辑',
        onPressed: (ctx) async {
          await close(ctx);
          onEdit();
        },
      ),
      item(
        icon: shadcn.LucideIcons.trash2,
        title: '删除',
        destructive: true,
        onPressed: (ctx) async {
          await close(ctx);
          onDelete();
        },
      ),
      const shadcn.MenuDivider(),
      item(
        icon: d.isActive ? shadcn.LucideIcons.pause : shadcn.LucideIcons.play,
        title: d.isActive ? '停用' : '启用',
        onPressed: (ctx) async {
          await close(ctx);
          onToggleActive();
        },
      ),
      item(
        icon: shadcn.LucideIcons.zap,
        title: !d.brush ? '关闭辅种' : '开启辅种',
        onPressed: (ctx) async {
          await close(ctx);
          onToggleBrush();
        },
      ),
      if (!d.brush)
        item(
          icon: shadcn.LucideIcons.copy,
          title: '执行辅种',
          onPressed: (ctx) async {
            await close(ctx);
            if (!hostContext.mounted) return;
            shadcn.showDialog(
              context: hostContext,
              builder: (dialogContext) => shadcn.AlertDialog(
                title: const Text('确认执行辅种'),
                content: Text('确定对下载器「${d.name}」执行辅种任务吗？'),
                actions: [
                  shadcn.Button.outline(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('取消'),
                  ),
                  shadcn.Button.primary(
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      try {
                        final msg = await DownloaderService.runRepeatTask(d.id);
                        Toast.success(msg);
                      } catch (e, st) {
                        AppLogger.error('执行下载器辅种失败', e, st);
                        Toast.error('执行辅种失败: $e');
                      }
                    },
                    child: const Text('执行'),
                  ),
                ],
              ),
            );
          },
        ),
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.settings,
        title: '设置',
        onPressed: (ctx) async {
          await close(ctx);
          if (!hostContext.mounted) return;
          shadcn.showDialog(
            context: hostContext,
            builder: (_) => d.isQb ? QbSettingsDialog(downloader: d) : TrSettingsDialog(downloader: d),
          );
        },
      ),
      item(
        icon: shadcn.LucideIcons.gauge,
        title: '限速设置',
        onPressed: (ctx) async {
          await close(ctx);
          if (!hostContext.mounted) return;
          shadcn.showDialog(
            context: hostContext,
            builder: (_) => d.isQb
                ? QbSettingsDialog(downloader: d, initialIndex: 3)
                : TrSettingsDialog(downloader: d, initialIndex: 1),
          );
        },
      ),
      if (isQb) ...[
        const shadcn.MenuDivider(),
        shadcn.MenuLabel(child: Text('Qbittorrent').xSmall),
        item(
          icon: shadcn.LucideIcons.tags,
          title: '分类管理',
          onPressed: (ctx) async {
            await close(ctx);
            if (!hostContext.mounted) return;
            showAppSheet<void>(
              context: hostContext,
              isScrollControlled: true,
              backgroundColor: cs.background,
              builder: (_) => QbCategoryManagerSheet(downloader: d),
            );
          },
        ),
        item(
          icon: shadcn.LucideIcons.tag,
          title: '标签管理',
          onPressed: (ctx) async {
            await close(ctx);
            if (!hostContext.mounted) return;
            showAppSheet<void>(
              context: hostContext,
              isScrollControlled: true,
              backgroundColor: cs.background,
              builder: (_) => QbTagManagerSheet(downloader: d),
            );
          },
        ),
      ],
    ];
  }
}
