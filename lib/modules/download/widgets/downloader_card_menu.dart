import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:harvest/modules/torrents/qbittorrent/widgets/torrent_action_menu.dart';

import '../../torrents/qbittorrent/widgets/torrent_list_page.dart';
import '../model/downloader.dart';
import 'push_torrent_sheet.dart';
import 'qb_category_tag_manager.dart';
import 'qb_settings_dialog.dart';
import 'tr_settings_dialog.dart';

class DownloaderCardMenu {
  final Downloader downloader;
  final Future<void> Function() hideMenu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onToggleBrush;

  const DownloaderCardMenu({
    required this.downloader,
    required this.hideMenu,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onToggleBrush,
  });

  List<FTileGroupMixin> build(BuildContext context) {
    final d = downloader;
    final isQb = d.isQb;

    return [
      FTileGroup(
        children: [
          FTile(
            prefix: const Icon(FIcons.list, size: 14),
            title: const Text('种子列表'),
            onPress: () async {
              await hideMenu();
              if (!context.mounted) return;
              Navigator.push(
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
            },
          ),
          FTile(
            prefix: const Icon(FIcons.plus, size: 14),
            title: const Text('添加种子'),
            onPress: () async {
              await hideMenu();
              if (!context.mounted) return;
              showFSheet(
                context: context,
                side: FLayout.btt,
                builder: (_) => PushTorrentSheet(downloader: d),
              );
            },
          ),
        ],
      ),
      FTileGroup(
        children: [
          FTile(
            prefix: const Icon(FIcons.pencil, size: 14),
            title: const Text('编辑'),
            onPress: () async {
              await hideMenu();
              onEdit();
            },
          ),
          FTile(
            prefix: Icon(
              FIcons.trash2,
              size: 14,
              color: context.theme.colors.destructive,
            ),
            title: Text(
              '删除',
              style: TextStyle(color: context.theme.colors.destructive),
            ),
            onPress: () async {
              await hideMenu();
              onDelete();
            },
          ),
        ],
      ),
      FTileGroup(
        children: [
          FTile(
            prefix: Icon(d.isActive ? FIcons.pause : FIcons.play, size: 14),
            title: Text(d.isActive ? '停用' : '启用'),
            onPress: () async {
              await hideMenu();
              onToggleActive();
            },
          ),
          FTile(
            prefix: const Icon(FIcons.zap, size: 14),
            title: Text(!d.brush ? '关闭辅种' : '开启辅种'),
            onPress: () async {
              await hideMenu();
              onToggleBrush();
            },
          ),
        ],
      ),
      if (!d.brush)
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FIcons.copy, size: 14),
              title: const Text('执行辅种'),
              onPress: () => hideMenu(),
            ),
          ],
        ),
      FTileGroup(
        children: [
          FTile(
            prefix: const Icon(FIcons.settings, size: 14),
            title: const Text('设置'),
            onPress: () async {
              await hideMenu();
              if (!context.mounted) return;
              if (d.isQb) {
                showDialog(
                  context: context,
                  builder: (_) => QbSettingsDialog(downloader: d),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => TrSettingsDialog(downloader: d),
                );
              }
            },
          ),
          FTile(
            prefix: const Icon(FIcons.gauge, size: 14),
            title: const Text('限速设置'),
            onPress: () async {
              await hideMenu();
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => d.isQb
                    ? QbSettingsDialog(downloader: d, initialIndex: 3)
                    : TrSettingsDialog(downloader: d, initialIndex: 1),
              );
            },
          ),
        ],
      ),
      if (isQb)
        FTileGroup(
          label: const Text('Qbittorrent'),
          children: [
            FTile(
              prefix: const Icon(FIcons.tags, size: 14),
              title: const Text('分类管理'),
              onPress: () async {
                await hideMenu();
                if (!context.mounted) return;
                showFSheet(
                  context: context,
                  side: FLayout.btt,
                  mainAxisMaxRatio: 0.82,
                  builder: (_) => QbCategoryManagerSheet(downloader: d),
                );
              },
            ),
            FTile(
              prefix: const Icon(FIcons.tag, size: 14),
              title: const Text('标签管理'),
              onPress: () async {
                await hideMenu();
                if (!context.mounted) return;
                showFSheet(
                  context: context,
                  side: FLayout.btt,
                  mainAxisMaxRatio: 0.82,
                  builder: (_) => QbTagManagerSheet(downloader: d),
                );
              },
            ),
          ],
        ),
    ];
  }
}
