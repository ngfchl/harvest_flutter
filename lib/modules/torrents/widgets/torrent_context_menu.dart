import 'dart:async';
import 'package:harvest/widgets/shad_text_field.dart';

import 'package:flutter/material.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/feedback/toast.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:shadcn_flutter/shadcn_flutter.dart' show TextExtension;

import '../../download/model/downloader.dart';
import '../model/torrent_action_menu.dart';
import '../model/torrent_model.dart';
import '../model/torrent_site_matcher.dart';
import '../provider/downloader_provider.dart';
import 'torrent_detail_sheet.dart';
import 'torrent_delete_helper.dart';

// ══════════════════════════════════════════════════════════
//  菜单项模型
// ══════════════════════════════════════════════════════════

enum TorrentContextMenuItemType { action, submenu, label, divider }

class TorrentContextMenuItem {
  final TorrentContextMenuItemType type;
  final String value;
  final IconData? icon;
  final String label;
  final bool destructive;

  const TorrentContextMenuItem.action({
    required this.value,
    required this.icon,
    required this.label,
    this.destructive = false,
  }) : type = TorrentContextMenuItemType.action;

  const TorrentContextMenuItem.submenu({required this.value, required this.icon, required this.label})
    : type = TorrentContextMenuItemType.submenu,
      destructive = false;

  const TorrentContextMenuItem.label({required this.value, required this.label})
    : type = TorrentContextMenuItemType.label,
      icon = null,
      destructive = false;

  const TorrentContextMenuItem.divider()
    : type = TorrentContextMenuItemType.divider,
      value = '',
      icon = null,
      label = '',
      destructive = false;
}

// ══════════════════════════════════════════════════════════
//  子菜单 action 常量
// ══════════════════════════════════════════════════════════

const torrentCategorySubmenuAction = '__category_submenu__';
const torrentTagSubmenuAction = '__tag_submenu__';
const torrentCopySubmenuAction = '__copy_submenu__';

bool _loadDeleteFilesWhenUnpreservedPref() {
  return HiveManager.get<bool>(
        StorageKeys.torrentDeleteFilesWhenUnpreserved,
      ) ??
      true;
}

void _saveDeleteFilesWhenUnpreservedPref(bool value) {
  unawaited(
    HiveManager.set(
      StorageKeys.torrentDeleteFilesWhenUnpreserved,
      value,
    ),
  );
}

// ══════════════════════════════════════════════════════════
//  构建菜单项
// ══════════════════════════════════════════════════════════

TorrentContextMenuItem _menuItem(String value, IconData icon, String label, {bool destructive = false}) {
  return TorrentContextMenuItem.action(value: value, icon: icon, label: label, destructive: destructive);
}

TorrentContextMenuItem _submenuItem(String value, IconData icon, String label) {
  return TorrentContextMenuItem.submenu(value: value, icon: icon, label: label);
}

List<TorrentContextMenuItem> torrentContextMenuItems({
  required Torrent torrent,
  required DownloaderType type,
  required List<String> categories,
  required List<String> tags,
}) {
  final isQb = type == DownloaderType.qbittorrent;
  final isPaused = torrent.torrentStatus == TorrentStatus.stopped;
  final items = <TorrentContextMenuItem>[
    _menuItem('detail', Icons.info_outline_rounded, '种子详情'),
    const TorrentContextMenuItem.divider(),
  ];

  if (isQb) {
    items.addAll([
      _menuItem('start', isPaused ? Icons.play_arrow_rounded : Icons.stop_rounded, isPaused ? '继续' : '停止'),
      _menuItem('force', Icons.double_arrow_rounded, '强制启动'),
      const TorrentContextMenuItem.divider(),
      _menuItem('delete', Icons.delete_outline_rounded, '删除', destructive: true),
      const TorrentContextMenuItem.divider(),
      _menuItem('location', Icons.edit_location_outlined, '更改保存位置'),
    ]);
    if (categories.isNotEmpty || tags.isNotEmpty) {
      items.add(const TorrentContextMenuItem.divider());
      if (categories.isNotEmpty) {
        items.add(_submenuItem(torrentCategorySubmenuAction, Icons.folder_outlined, '分类'));
      }
      if (tags.isNotEmpty) {
        items.add(_submenuItem(torrentTagSubmenuAction, Icons.sell_outlined, '标签'));
      }
    }
    items.addAll([
      const TorrentContextMenuItem.divider(),
      _submenuItem(torrentCopySubmenuAction, Icons.copy_rounded, '复制'),
      const TorrentContextMenuItem.divider(),
      _menuItem('auto', Icons.auto_mode_outlined, '自动管理'),
      _menuItem('upload_limit', Icons.upload_outlined, '限制上传速度'),
      _menuItem('share_limit', Icons.pie_chart_outline_rounded, '限制分享率'),
      _menuItem('super_seed', Icons.rocket_launch_outlined, '超级做种'),
      const TorrentContextMenuItem.divider(),
      _menuItem('recheck', Icons.fact_check_outlined, '重新校验'),
      _menuItem('reannounce', Icons.campaign_outlined, '重新汇报'),
      _menuItem('tracker', Icons.language_outlined, '修改 Tracker'),
      _menuItem('export', Icons.save_alt_outlined, '导出 .torrent'),
    ]);
  } else {
    items.addAll([
      _menuItem('force_start', Icons.double_arrow_rounded, '强制开始'),
      _menuItem('start', Icons.play_arrow_rounded, '开始种子'),
      _menuItem('pause', Icons.pause_rounded, '暂停种子'),
      const TorrentContextMenuItem.divider(),
      _menuItem('delete', Icons.delete_outline_rounded, '删除种子', destructive: true),
      const TorrentContextMenuItem.divider(),
      _menuItem('recheck', Icons.fact_check_outlined, '重新校验'),
      _menuItem('reannounce', Icons.campaign_outlined, '重新汇报'),
      _menuItem('location', Icons.folder_outlined, '修改目录'),
      const TorrentContextMenuItem.divider(),
      _submenuItem(torrentCopySubmenuAction, Icons.copy_rounded, '复制'),
      const TorrentContextMenuItem.divider(),
      _menuItem('queue_top', Icons.vertical_align_top_rounded, '队列顶部'),
      _menuItem('queue_up', Icons.arrow_upward_rounded, '向上移动'),
      _menuItem('queue_down', Icons.arrow_downward_rounded, '向下移动'),
      _menuItem('queue_bottom', Icons.vertical_align_bottom_rounded, '队列底部'),
    ]);
    if (tags.isNotEmpty) {
      items.add(const TorrentContextMenuItem.divider());
      items.add(_submenuItem(torrentTagSubmenuAction, Icons.sell_outlined, '标签'));
    }
    items.addAll([const TorrentContextMenuItem.divider(), _menuItem('tracker', Icons.language_outlined, '修改 Tracker')]);
  }

  return items;
}

List<TorrentContextMenuItem> torrentCategorySubmenuItems({required Torrent torrent, required List<String> categories}) {
  return [
    TorrentContextMenuItem.label(value: '_category_label', label: '分类'),
    for (final category in categories)
      _menuItem(
        'category::$category',
        category == torrent.category ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
        category.isEmpty ? '未分类' : category,
      ),
  ];
}

List<TorrentContextMenuItem> torrentTagSubmenuItems({required Torrent torrent, required List<String> tags}) {
  return [
    TorrentContextMenuItem.label(value: '_tag_label', label: '标签'),
    for (final tag in tags)
      _menuItem(
        'tag::$tag',
        torrent.labels.contains(tag) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
        tag,
      ),
  ];
}

List<TorrentContextMenuItem> torrentCopySubmenuItems() {
  return [
    TorrentContextMenuItem.label(value: '_copy_label', label: '复制'),
    _menuItem('copy_name', Icons.text_fields, '名称'),
    _menuItem('copy_hash', Icons.tag, 'Hash'),
    _menuItem('copy_magnet', Icons.link, '磁力链接'),
    _menuItem('copy_tracker', Icons.language, 'Tracker'),
    _menuItem('copy_path', Icons.folder, '保存路径'),
  ];
}

List<TorrentContextMenuItem> torrentBatchContextMenuItems({
  required DownloaderType type,
  required int count,
  required List<String> categories,
  required List<String> tags,
}) {
  final isQb = type == DownloaderType.qbittorrent;
  final items = <TorrentContextMenuItem>[
    TorrentContextMenuItem.label(value: '_batch_label', label: '已选择 $count 个种子'),
    const TorrentContextMenuItem.divider(),
    _menuItem('start', Icons.play_arrow_rounded, isQb ? '继续' : '开始种子'),
    _menuItem('pause', Icons.pause_rounded, isQb ? '暂停' : '暂停种子'),
    const TorrentContextMenuItem.divider(),
    _menuItem('delete', Icons.delete_outline_rounded, isQb ? '删除' : '删除种子', destructive: true),
    const TorrentContextMenuItem.divider(),
    _menuItem('location', isQb ? Icons.edit_location_outlined : Icons.folder_outlined, isQb ? '更改保存位置' : '修改目录'),
  ];

  if (isQb && (categories.isNotEmpty || tags.isNotEmpty)) {
    items.add(const TorrentContextMenuItem.divider());
    if (categories.isNotEmpty) {
      items.add(_submenuItem(torrentCategorySubmenuAction, Icons.folder_outlined, '分类'));
    }
    if (tags.isNotEmpty) {
      items.add(_submenuItem(torrentTagSubmenuAction, Icons.sell_outlined, '添加标签'));
    }
  }

  if (isQb) {
    items.addAll([
      const TorrentContextMenuItem.divider(),
      _menuItem('upload_limit', Icons.upload_outlined, '限制上传速度'),
      _menuItem('share_limit', Icons.pie_chart_outline_rounded, '限制分享率'),
    ]);
  }

  items.addAll([
    const TorrentContextMenuItem.divider(),
    _menuItem('recheck', Icons.fact_check_outlined, '重新校验'),
    _menuItem('reannounce', Icons.campaign_outlined, '重新汇报'),
  ]);

  if (!isQb) {
    items.addAll([
      const TorrentContextMenuItem.divider(),
      _menuItem('queue_top', Icons.vertical_align_top_rounded, '队列顶部'),
      _menuItem('queue_up', Icons.arrow_upward_rounded, '向上移动'),
      _menuItem('queue_down', Icons.arrow_downward_rounded, '向下移动'),
      _menuItem('queue_bottom', Icons.vertical_align_bottom_rounded, '队列底部'),
    ]);
  }

  return items;
}

List<TorrentContextMenuItem> torrentBatchCategorySubmenuItems({required List<String> categories}) {
  return [
    TorrentContextMenuItem.label(value: '_category_label', label: '分类'),
    for (final category in categories)
      _menuItem('category::$category', Icons.folder_outlined, category.isEmpty ? '未分类' : category),
  ];
}

List<TorrentContextMenuItem> torrentBatchTagSubmenuItems({required List<String> tags}) {
  return [
    TorrentContextMenuItem.label(value: '_tag_label', label: '添加标签'),
    for (final tag in tags) _menuItem('tag::$tag', Icons.sell_outlined, tag),
  ];
}

// ══════════════════════════════════════════════════════════
//  桌面端：Overlay 弹出菜单
// ══════════════════════════════════════════════════════════

Future<String?> showTorrentContextMenu({
  required BuildContext context,
  required Offset position,
  required List<TorrentContextMenuItem> items,
  required Map<String, List<TorrentContextMenuItem>> submenus,
}) {
  final overlay = Overlay.of(context);
  final completer = Completer<String?>();
  late final OverlayEntry entry;
  var removed = false;

  void close(String? action) {
    if (removed) return;
    removed = true;
    if (!completer.isCompleted) completer.complete(action);
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => close(null),
            onSecondaryTapDown: (_) => close(null),
          ),
        ),
        AppContextMenuPopup(
          anchorContext: context,
          position: position,
          children: _contextMenuEntries(items: items, submenus: submenus, onSelect: close),
        ),
      ],
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

List<shadcn.MenuItem> _contextMenuEntries({
  required List<TorrentContextMenuItem> items,
  required Map<String, List<TorrentContextMenuItem>> submenus,
  required ValueChanged<String?> onSelect,
}) {
  return [
    for (final item in items)
      switch (item.type) {
        TorrentContextMenuItemType.divider => const shadcn.MenuDivider(),
        TorrentContextMenuItemType.label => shadcn.MenuLabel(child: Text(item.label).xSmall.muted),
        TorrentContextMenuItemType.submenu => shadcn.MenuButton(
          leading: Icon(item.icon ?? Icons.chevron_right, size: 16),
          subMenu: _contextMenuEntries(items: submenus[item.value] ?? const [], submenus: submenus, onSelect: onSelect),
          child: SizedBox(width: 150, child: Text(item.label).small),
        ),
        TorrentContextMenuItemType.action => shadcn.MenuButton(
          leading: Icon(item.icon ?? Icons.circle, size: 16),
          onPressed: (_) => onSelect(item.value),
          child: SizedBox(width: 150, child: Text(item.label).small),
        ),
      },
  ];
}

// ══════════════════════════════════════════════════════════
//  移动端：BottomSheet 菜单
// ══════════════════════════════════════════════════════════

Future<String?> showTorrentContextMenuMobile({
  required BuildContext context,
  required Torrent torrent,
  required DownloaderType type,
  required List<String> categories,
  required List<String> tags,
}) {
  final items = torrentContextMenuItems(torrent: torrent, type: type, categories: categories, tags: tags);
  final submenus = {
    torrentCategorySubmenuAction: torrentCategorySubmenuItems(torrent: torrent, categories: categories),
    torrentTagSubmenuAction: torrentTagSubmenuItems(torrent: torrent, tags: tags),
    torrentCopySubmenuAction: torrentCopySubmenuItems(),
  };

  return showAppSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _MobileContextMenu(items: items, submenus: submenus),
  );
}

Future<String?> showTorrentBatchContextMenuMobile({
  required BuildContext context,
  required DownloaderType type,
  required int count,
  required List<String> categories,
  required List<String> tags,
}) {
  final items = torrentBatchContextMenuItems(type: type, count: count, categories: categories, tags: tags);
  final submenus = {
    torrentCategorySubmenuAction: torrentBatchCategorySubmenuItems(categories: categories),
    torrentTagSubmenuAction: torrentBatchTagSubmenuItems(tags: tags),
  };

  return showAppSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _MobileContextMenu(items: items, submenus: submenus),
  );
}

class _MobileContextMenu extends StatefulWidget {
  final List<TorrentContextMenuItem> items;
  final Map<String, List<TorrentContextMenuItem>> submenus;

  const _MobileContextMenu({required this.items, required this.submenus});

  @override
  State<_MobileContextMenu> createState() => _MobileContextMenuState();
}

class _MobileContextMenuState extends State<_MobileContextMenu> {
  final List<List<TorrentContextMenuItem>> _stack = [];

  List<TorrentContextMenuItem> get _items => _stack.isEmpty ? widget.items : _stack.last;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.65;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_stack.isNotEmpty) _buildBackRow(context),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(0, _stack.isEmpty ? 8 : 0, 0, 16),
                itemCount: _items.length,
                itemBuilder: (context, index) => _buildItem(context, _items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackRow(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(shadcn.LucideIcons.chevronLeft, size: 20, color: cs.foreground),
      title: Text('返回', style: TextStyle(fontSize: 14, color: cs.foreground, fontWeight: FontWeight.w600)),
      onTap: () => setState(() => _stack.removeLast()),
    );
  }

  Widget _buildItem(BuildContext context, TorrentContextMenuItem item) {
    final cs = shadcn.Theme.of(context).colorScheme;

    return switch (item.type) {
      TorrentContextMenuItemType.divider => const Divider(height: 1),
      TorrentContextMenuItemType.label => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text(
          item.label,
          style: TextStyle(fontSize: 12, color: cs.mutedForeground, fontWeight: FontWeight.w600),
        ),
      ),
      TorrentContextMenuItemType.submenu => ListTile(
        leading: Icon(item.icon ?? Icons.chevron_right, size: 20, color: cs.foreground),
        title: Text(item.label, style: TextStyle(fontSize: 14, color: cs.foreground)),
        trailing: Icon(Icons.chevron_right, size: 18, color: cs.mutedForeground),
        onTap: () => _showSubmenu(context, item),
      ),
      TorrentContextMenuItemType.action => ListTile(
        leading: Icon(item.icon ?? Icons.circle, size: 20, color: item.destructive ? cs.destructive : cs.foreground),
        title: Text(
          item.label,
          style: TextStyle(fontSize: 14, color: item.destructive ? cs.destructive : cs.foreground),
        ),
        onTap: () => closeAppSheet(context, item.value),
      ),
    };
  }

  void _showSubmenu(BuildContext context, TorrentContextMenuItem submenuItem) {
    final subItems = widget.submenus[submenuItem.value] ?? const <TorrentContextMenuItem>[];
    if (subItems.isEmpty) return;
    setState(() => _stack.add(subItems));
  }
}

// ══════════════════════════════════════════════════════════
//  统一 action 处理
// ══════════════════════════════════════════════════════════

Future<void> handleTorrentBatchContextMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  required DownloaderType downloaderType,
  required List<Torrent> torrents,
  required String action,
  required OnTorrentAction onAction,
}) async {
  final isQb = downloaderType == DownloaderType.qbittorrent;
  final ids = torrents.map((torrent) => torrent.hashString).where((hash) => hash.isNotEmpty).toList();
  if (ids.isEmpty) {
    Toast.warning('选中的种子缺少可操作 ID');
    return;
  }

  if (action == 'delete') {
    _confirmDeleteTorrents(context, ref, downloaderId, downloaderType, torrents, onAction);
    return;
  }

  if (action == 'location') {
    _showBatchLocationDialog(context, downloaderType, ids, onAction);
    return;
  }

  if (action == 'upload_limit') {
    if (!isQb) return;
    _showBatchUploadLimitDialog(context, ids, onAction);
    return;
  }

  if (action == 'share_limit') {
    if (!isQb) return;
    _showBatchShareLimitDialog(context, ids, onAction);
    return;
  }

  if (action.startsWith('category::')) {
    if (!isQb) return;
    final category = action.substring('category::'.length);
    await _runBatchMenuAction(
      label: '分类设置',
      onAction: onAction,
      action: 'set_category',
      params: {'hashes': ids, 'category': category},
    );
    return;
  }

  if (action.startsWith('tag::')) {
    if (!isQb) return;
    final tag = action.substring('tag::'.length);
    await _runBatchMenuAction(
      label: '标签添加',
      onAction: onAction,
      action: 'add_tags',
      params: {
        'hashes': ids,
        'tags': [tag],
      },
    );
    return;
  }

  final rawAction = switch (action) {
    'start' => isQb ? 'resume' : 'start_torrent',
    'pause' => isQb ? 'pause' : 'stop_torrent',
    'recheck' => isQb ? 'recheck' : 'verify_torrent',
    'reannounce' => isQb ? 'reannounce' : 'reannounce_torrent',
    _ => action,
  };
  await _runBatchMenuAction(
    label: _batchActionLabel(action),
    onAction: onAction,
    action: rawAction,
    params: isQb ? {'hashes': ids} : {'ids': ids},
  );
}

String _batchActionLabel(String action) {
  return switch (action) {
    'start' => '开始',
    'pause' => '暂停',
    'recheck' => '重新校验',
    'reannounce' => '重新汇报',
    'queue_top' => '队列顶部',
    'queue_up' => '向上移动',
    'queue_down' => '向下移动',
    'queue_bottom' => '队列底部',
    _ => '操作',
  };
}

Future<void> _runBatchMenuAction({
  required String label,
  required OnTorrentAction onAction,
  required String action,
  required Map<String, dynamic> params,
}) async {
  final success = await onAction(action, params);
  success ? Toast.success('$label已提交') : Toast.error('$label失败');
}

List<Torrent> _currentTorrentSnapshot(WidgetRef ref, int downloaderId) {
  return ref.read(torrentListProvider(downloaderId)).valueOrNull?.torrents ?? const <Torrent>[];
}

Future<void> _deleteTorrentsWithOptionalFiles({
  required DownloaderType type,
  required List<Torrent> torrents,
  required List<Torrent> allTorrents,
  required bool deleteFilesWhenUnpreserved,
  required OnTorrentAction onAction,
}) async {
  final summary = await deleteTorrentsWithOptionalFiles(
    type: type,
    torrents: torrents,
    allTorrents: allTorrents,
    deleteFilesWhenUnpreserved: deleteFilesWhenUnpreserved,
    onAction: onAction,
  );

  if (!summary.success) {
    Toast.error('删除失败');
    return;
  }

  if (deleteFilesWhenUnpreserved && summary.metadataOnlyCount > 0) {
    Toast.success('删除已提交，${summary.metadataOnlyCount} 个种子保留文件');
  } else {
    Toast.success('删除已提交');
  }
}

Future<void> handleTorrentContextMenuAction({
  required BuildContext context,
  required WidgetRef ref,
  required int downloaderId,
  required DownloaderType downloaderType,
  required Torrent torrent,
  required TorrentSiteMatch? siteMatch,
  required String action,
  required OnTorrentAction onAction,
}) async {
  final isQb = downloaderType == DownloaderType.qbittorrent;
  final hash = torrent.hashString;

  if (hash.isEmpty && action != 'detail') {
    Toast.warning('种子缺少 Hash，无法操作');
    return;
  }

  if (action == 'detail') {
    showAppSheet(
      context: context,
      builder: (_) => TorrentDetailSheet(downloaderId: downloaderId, torrent: torrent, siteMatch: siteMatch),
    );
    return;
  }

  if (action == 'delete') {
    _confirmDeleteTorrent(context, ref, downloaderId, downloaderType, torrent, onAction);
    return;
  }

  if (action == 'location') {
    _showLocationDialog(context, ref, downloaderId, downloaderType, torrent, onAction);
    return;
  }

  if (action == 'upload_limit') {
    _showUploadLimitDialog(context, ref, downloaderId, torrent, onAction);
    return;
  }

  if (action == 'share_limit') {
    _showShareLimitDialog(context, ref, downloaderId, torrent, onAction);
    return;
  }

  if (action == 'tracker') {
    _showTrackerDialog(context, ref, downloaderId, downloaderType, torrent, onAction);
    return;
  }

  if (action.startsWith('copy_')) {
    final value = switch (action) {
      'copy_name' => torrent.name,
      'copy_hash' => torrent.hashString,
      'copy_magnet' => torrent.magnetLink,
      'copy_tracker' =>
        torrent.trackerUrl.isNotEmpty
            ? torrent.trackerUrl
            : torrent.visibleTrackerStats.map((t) => t.announce).where((a) => a.isNotEmpty).join('\n'),
      'copy_path' => torrent.downloadDir,
      _ => '',
    };
    if (value.isEmpty) {
      Toast.info('暂无可复制内容');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    Toast.success('已复制');
    return;
  }

  if (action.startsWith('category::')) {
    final category = action.substring('category::'.length);
    await onAction('set_category', {
      'hashes': [hash],
      'category': category,
    });
    return;
  }

  if (action.startsWith('tag::')) {
    final tag = action.substring('tag::'.length);
    final labels = List<String>.from(torrent.labels);
    labels.contains(tag) ? labels.remove(tag) : labels.add(tag);
    await onAction(
      isQb ? 'add_tags' : 'change_torrent',
      isQb
          ? {
              'hashes': [hash],
              'tags': labels,
            }
          : {
              'ids': [hash],
              'labels': labels,
            },
    );
    return;
  }

  final rawAction = switch (action) {
    'start' => isQb ? 'resume' : 'start_torrent',
    'pause' => isQb ? 'pause' : 'stop_torrent',
    'force_start' => 'start_torrent_now',
    'force' => 'set_force_start',
    'auto' => 'set_auto_management',
    'super_seed' => 'set_super_seeding',
    'recheck' => isQb ? 'recheck' : 'verify_torrent',
    'reannounce' => isQb ? 'reannounce' : 'reannounce_torrent',
    'export' => 'export',
    _ => action,
  };

  final params = switch (rawAction) {
    'set_force_start' => {
      'hashes': [hash],
      'enable': !torrent.forceStart,
    },
    'set_auto_management' => {
      'hashes': [hash],
      'enable': !torrent.autoTmm,
    },
    'set_super_seeding' => {
      'hashes': [hash],
      'enable': !torrent.superSeeding,
    },
    'export' => {
      'hashes': [hash],
      'name': torrent.name,
    },
    _ =>
      isQb
          ? {
              'hashes': [hash],
            }
          : {
              'ids': [hash],
            },
  };

  await onAction(rawAction, params);
}

// ══════════════════════════════════════════════════════════
//  对话框
// ══════════════════════════════════════════════════════════

void _confirmDeleteTorrents(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType type,
  List<Torrent> torrents,
  OnTorrentAction onAction,
) {
  var deleteFilesWhenUnpreserved = _loadDeleteFilesWhenUnpreservedPref();
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('删除种子', style: TextStyle(color: cs.destructive)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定删除选中的 ${torrents.length} 个种子吗？'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('无其他站点保种时删除文件', style: TextStyle(color: cs.foreground, fontSize: 13)),
                  ),
                  shadcn.Switch(
                    value: deleteFilesWhenUnpreserved,
                    onChanged: (value) => setDialogState(() {
                      deleteFilesWhenUnpreserved = value;
                      _saveDeleteFilesWhenUnpreservedPref(value);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('开启后会检查相同内容路径是否还有其他做种种子，有则仅删除种子。', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
            ],
          ),
          actions: [
            shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
            shadcn.Button.destructive(
              onPressed: () async {
                closeAppSheet(ctx);
                await _deleteTorrentsWithOptionalFiles(
                  type: type,
                  torrents: torrents,
                  allTorrents: _currentTorrentSnapshot(ref, downloaderId),
                  deleteFilesWhenUnpreserved: deleteFilesWhenUnpreserved,
                  onAction: onAction,
                );
              },
              child: const Text('删除'),
            ),
          ],
        ),
      );
    },
  );
}

void _showBatchLocationDialog(BuildContext context, DownloaderType type, List<String> ids, OnTorrentAction onAction) {
  final isQb = type == DownloaderType.qbittorrent;
  final ctrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isQb ? '更改保存位置' : '修改目录',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('将应用到选中的 ${ids.length} 个种子', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: '保存路径',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        final path = ctrl.text.trim();
                        if (path.isEmpty) {
                          Toast.warning('保存路径不能为空');
                          return;
                        }
                        closeAppSheet(ctx);
                        await _runBatchMenuAction(
                          label: isQb ? '保存位置设置' : '目录修改',
                          onAction: onAction,
                          action: isQb ? 'set_location' : 'move_torrent_data',
                          params: isQb ? {'hashes': ids, 'savePath': path} : {'ids': ids, 'savePath': path},
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showBatchUploadLimitDialog(BuildContext context, List<String> hashes, OnTorrentAction onAction) {
  final ctrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限制上传速度',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '单位 KB/s，留空或 0 为不限；将应用到 ${hashes.length} 个种子',
                  style: TextStyle(color: cs.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: 'KB/s',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        final value = int.tryParse(ctrl.text.trim()) ?? 0;
                        await _runBatchMenuAction(
                          label: '上传速度限制',
                          onAction: onAction,
                          action: 'set_upload_limit',
                          params: {'hashes': hashes, 'limit': value * 1024},
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showBatchShareLimitDialog(BuildContext context, List<String> hashes, OnTorrentAction onAction) {
  final ratioCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限制分享率',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('留空或 0 为不限；将应用到 ${hashes.length} 个种子', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ratioCtrl,
                  hintText: '分享率 (如 2.0)',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 8),
                ShadTextField(
                  controller: timeCtrl,
                  hintText: '做种时间限制 (小时，可选)',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        final ratio = double.tryParse(ratioCtrl.text.trim()) ?? -1.0;
                        final seedSeconds = (double.tryParse(timeCtrl.text.trim()) ?? 0) * 3600;
                        await _runBatchMenuAction(
                          label: '分享率限制',
                          onAction: onAction,
                          action: 'set_share_limits',
                          params: {
                            'hashes': hashes,
                            'ratioLimit': ratio <= 0 ? -1.0 : ratio,
                            'seedingTimeLimit': seedSeconds <= 0 ? -1.0 : seedSeconds,
                          },
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _confirmDeleteTorrent(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType type,
  Torrent torrent,
  OnTorrentAction onAction,
) {
  var deleteFilesWhenUnpreserved = _loadDeleteFilesWhenUnpreservedPref();
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('删除种子', style: TextStyle(color: cs.destructive)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定删除「${torrent.name}」吗？'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text('无其他站点保种时删除文件', style: TextStyle(color: cs.foreground, fontSize: 13)),
                  ),
                  shadcn.Switch(
                    value: deleteFilesWhenUnpreserved,
                    onChanged: (value) => setDialogState(() {
                      deleteFilesWhenUnpreserved = value;
                      _saveDeleteFilesWhenUnpreservedPref(value);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('开启后会检查相同内容路径是否还有其他做种种子，有则仅删除种子。', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
            ],
          ),
          actions: [
            shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
            shadcn.Button.destructive(
              onPressed: () async {
                closeAppSheet(ctx);
                await _deleteTorrentsWithOptionalFiles(
                  type: type,
                  torrents: [torrent],
                  allTorrents: _currentTorrentSnapshot(ref, downloaderId),
                  deleteFilesWhenUnpreserved: deleteFilesWhenUnpreserved,
                  onAction: onAction,
                );
              },
              child: const Text('删除'),
            ),
          ],
        ),
      );
    },
  );
}

void _showLocationDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType type,
  Torrent torrent,
  OnTorrentAction onAction,
) {
  final isQb = type == DownloaderType.qbittorrent;
  final ctrl = TextEditingController(text: torrent.downloadDir);
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '更改保存位置',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: '保存路径',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        await onAction(
                          isQb ? 'set_location' : 'move_torrent',
                          isQb
                              ? {
                                  'hashes': [torrent.hashString],
                                  'location': ctrl.text.trim(),
                                }
                              : {
                                  'ids': [torrent.hashString],
                                  'location': ctrl.text.trim(),
                                },
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showUploadLimitDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  Torrent torrent,
  OnTorrentAction onAction,
) {
  final ctrl = TextEditingController(text: torrent.uploadLimit > 0 ? '${torrent.uploadLimit ~/ 1024}' : '');
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限制上传速度',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('单位 KB/s，留空或 0 为不限', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: 'KB/s',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        final value = int.tryParse(ctrl.text.trim()) ?? 0;
                        await onAction('set_upload_limit', {
                          'hashes': [torrent.hashString],
                          'limit': value * 1024,
                        });
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showShareLimitDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  Torrent torrent,
  OnTorrentAction onAction,
) {
  final ctrl = TextEditingController(text: torrent.seedRatioLimit > 0 ? torrent.seedRatioLimit.toStringAsFixed(2) : '');
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '限制分享率',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('留空或 0 为不限', style: TextStyle(color: cs.mutedForeground, fontSize: 12)),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: '分享率',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        final value = double.tryParse(ctrl.text.trim()) ?? 0;
                        await onAction('set_share_limit', {
                          'hashes': [torrent.hashString],
                          'ratioLimit': value,
                        });
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showTrackerDialog(
  BuildContext context,
  WidgetRef ref,
  int downloaderId,
  DownloaderType type,
  Torrent torrent,
  OnTorrentAction onAction,
) {
  final isQb = type == DownloaderType.qbittorrent;
  final ctrl = TextEditingController(text: torrent.trackerUrl);
  showDialog(
    context: context,
    builder: (ctx) {
      final cs = shadcn.Theme.of(ctx).colorScheme;
      return Dialog(
        backgroundColor: cs.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '修改 Tracker',
                  style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                ShadTextField(
                  controller: ctrl,
                  hintText: 'Tracker URL',
                  onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    shadcn.Button.ghost(onPressed: () => closeAppSheet(ctx), child: const Text('取消')),
                    const SizedBox(width: 8),
                    shadcn.Button.primary(
                      onPressed: () async {
                        closeAppSheet(ctx);
                        await onAction(
                          isQb ? 'edit_tracker' : 'change_torrent',
                          isQb
                              ? {'hash': torrent.hashString, 'origUrl': torrent.trackerUrl, 'newUrl': ctrl.text.trim()}
                              : {
                                  'ids': [torrent.hashString],
                                  'trackerURL': ctrl.text.trim(),
                                },
                        );
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
