// ========================
// pages/task/task_page.dart
// ========================

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/widgets/app_menu.dart';

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import '../torrents/widgets/torrent_stats_bar.dart';
import 'model/schedule.dart';
import 'provider/crontab_provider.dart';
import 'provider/schedule_provider.dart';
import 'widgets/schedule_edit_sheet.dart';
import 'widgets/torrent_move_edit_sheet.dart';

class TaskPage extends ConsumerWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(scheduleProvider);
    final theme = shadcn.Theme.of(context);

    return shadcn.Scaffold(
      backgroundColor: theme.colorScheme.background,
      child: tasksAsync.when(
        loading: () => const Center(
          child: shadcn.CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (e, _) => _ErrorView(
          error: e,
          onRetry: () => ref.invalidate(scheduleProvider),
        ),
        data: (tasks) => _TaskListView(
          tasks: tasks,
          onAdd: (buttonContext) => _openAdd(buttonContext, ref),
        ),
      ),
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) {
    shadcn.showDropdown<void>(
      context: context,
      alignment: Alignment.topCenter,
      offset: const Offset(0, 8),
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      heightConstraint: shadcn.PopoverConstraint.intrinsic,
      consumeOutsideTaps: false,
      builder: (_) => shadcn.DropdownMenu(
        children: [
          shadcn.MenuLabel(child: const Text('添加任务')),
          const shadcn.MenuDivider(),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.calendarClock),
            onPressed: (overlayContext) async {
              await shadcn.closeOverlay(overlayContext);
              if (!context.mounted) return;
              _openEdit(context, ref, null, isTorrentMove: false);
            },
            child: const Text('普通任务'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.arrowRightLeft),
            onPressed: (overlayContext) async {
              await shadcn.closeOverlay(overlayContext);
              if (!context.mounted) return;
              _openEdit(context, ref, null, isTorrentMove: true);
            },
            child: const Text('种子迁移任务'),
          ),
        ],
      ),
    );
  }
}

/// 打开编辑
void _openEdit(
  BuildContext context,
  WidgetRef ref,
  Schedule? task, {
  bool? isTorrentMove,
}) {
  final useTorrentMove = isTorrentMove ?? task?.task.contains('种子迁移') ?? false;
  final isMobile = context.isMobile;

  final sheet = useTorrentMove
      ? TorrentMoveEditSheet(task: task)
      : ScheduleEditSheet(task: task);

  if (isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: shadcn.Theme.of(context).colorScheme.background,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => sheet,
    );
  } else {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: shadcn.Theme.of(context).colorScheme.background,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: sheet,
        ),
      ),
    );
  }
}

// ==================== 错误视图 ====================
class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            shadcn.LucideIcons.triangleAlert,
            size: 48,
            color: shadcn.Theme.of(context).colorScheme.destructive,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: shadcn.Theme.of(context).typography.large),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: shadcn.Theme.of(context).typography.small.copyWith(
              color: shadcn.Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          shadcn.Button.primary(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

// ==================== 列表视图 ====================
class _TaskListView extends ConsumerStatefulWidget {
  final List<Schedule> tasks;
  final ValueChanged<BuildContext> onAdd;

  const _TaskListView({required this.tasks, required this.onAdd});

  @override
  ConsumerState<_TaskListView> createState() => _TaskListViewState();
}

class _TaskStatusBar extends StatelessWidget {
  final int enabledCount;
  final int disabledCount;
  final ValueChanged<BuildContext> onAdd;

  const _TaskStatusBar({
    required this.enabledCount,
    required this.disabledCount,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final horizontalInset = context.isMobile ? 12.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalInset, 10, horizontalInset, 4),
      child: Row(
        children: [
          Icon(
            shadcn.LucideIcons.circle,
            size: 8,
            color: enabledCount > 0 ? cs.primary : cs.mutedForeground,
          ),
          const SizedBox(width: 6),
          Text(
            '任务状态',
            style: theme.typography.xSmall.copyWith(color: cs.mutedForeground),
          ),
          const SizedBox(width: 8),
          shadcn.SecondaryBadge(child: Text('启用 $enabledCount')),
          const SizedBox(width: 6),
          shadcn.OutlineBadge(child: Text('禁用 $disabledCount')),
          const Spacer(),
          shadcn.OverlayManagerLayer(
            popoverHandler: const shadcn.PopoverOverlayHandler(),
            tooltipHandler: const shadcn.FixedTooltipOverlayHandler(),
            menuHandler: const shadcn.PopoverOverlayHandler(),
            child: Builder(
              builder: (buttonContext) => StatusBarIconButton(
                onTap: () => onAdd(buttonContext),
                icon: shadcn.LucideIcons.plus,
                tooltip: '添加任务',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskListViewState extends ConsumerState<_TaskListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activeScrollControllerProvider.notifier).state =
          _scrollController;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cacheInfo = ref.watch(scheduleCacheInfoProvider);
    final enabledCount = widget.tasks.where((task) => task.enabled).length;
    final disabledCount = widget.tasks.length - enabledCount;

    if (widget.tasks.isEmpty) {
      return Column(
        children: [
          CacheStatusBanner(
            info: cacheInfo,
            margin: EdgeInsets.fromLTRB(
              context.isMobile ? 12 : 16,
              8,
              context.isMobile ? 12 : 16,
              6,
            ),
          ),
          _TaskStatusBar(
            enabledCount: enabledCount,
            disabledCount: disabledCount,
            onAdd: widget.onAdd,
          ),
          Expanded(
            child: EasyRefresh(
              onRefresh: _refresh,
              header: appRefreshHeader(context),
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 16 + ShellBottomSpacing.value(context),
                ),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          shadcn.LucideIcons.calendarOff,
                          size: 48,
                          color: shadcn.Theme.of(
                            context,
                          ).colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无计划任务',
                          style: shadcn.Theme.of(context).typography.large,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        CacheStatusBanner(
          info: cacheInfo,
          margin: EdgeInsets.fromLTRB(
            context.isMobile ? 12 : 16,
            8,
            context.isMobile ? 12 : 16,
            2,
          ),
        ),
        _TaskStatusBar(
          enabledCount: enabledCount,
          disabledCount: disabledCount,
          onAdd: widget.onAdd,
        ),
        Expanded(
          child: EasyRefresh(
            onRefresh: _refresh,
            header: appRefreshHeader(context),
            child: context.isDesktop
                ? _buildDesktopGrid(context)
                : _buildMobileList(context),
          ),
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    await ref.read(scheduleProvider.notifier).refresh();
    if (!mounted) return;
    ref.invalidate(crontabListProvider);
    ref.invalidate(downloaderListProvider);
  }

  /// 手机端：单列 ListView，统一间距
  Widget _buildMobileList(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        16 + ShellBottomSpacing.value(context),
      ),
      itemCount: widget.tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildTile(context, widget.tasks[index]),
    );
  }

  /// 桌面端：网格布局，列数随屏幕宽度自适应
  Widget _buildDesktopGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = (width / 320).floor().clamp(2, 6).toInt();
        const spacing = 8.0;
        final itemWidth =
            (width - 32 - (crossAxisCount - 1) * spacing) / crossAxisCount;

        return ListView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + ShellBottomSpacing.value(context),
          ),
          children: [
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final task in widget.tasks)
                  SizedBox(width: itemWidth, child: _buildTile(context, task)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, Schedule task) {
    final crontabList = ref.watch(crontabListProvider).valueOrNull ?? [];
    final express =
        crontabList.firstWhereOrNull((c) => c.id == task.crontabId)?.express ??
        '';

    final icon = _taskIcon(task.task);
    final isMobile = context.isMobile;
    final hasKwargs = task.kwargs.isNotEmpty && task.kwargs != '{}';
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;

    return AppContextMenu(
      items: _taskMenuItems(context, task),
      child: shadcn.Card(
        filled: true,
        fillColor: cs.card,
        borderColor: cs.border,
        borderRadius: BorderRadius.circular(theme.radiusLg),
        padding: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            theme.density.baseContentPadding * theme.scaling,
            theme.density.baseGap * theme.scaling,
            theme.density.baseContentPadding * theme.scaling,
            theme.density.baseGap * theme.scaling,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.name,
                      style: typo.small.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: theme.density.baseGap * theme.scaling * 0.5,
                    ),
                    Row(
                      children: [
                        Icon(icon, size: isMobile ? 14 : 15, color: cs.primary),
                        SizedBox(
                          width: theme.density.baseGap * theme.scaling * 0.5,
                        ),
                        Expanded(
                          child: Text(
                            task.task,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.xSmall.copyWith(
                              color: cs.mutedForeground,
                              fontSize: isMobile ? null : 13,
                            ),
                          ),
                        ),
                        if (express.isNotEmpty)
                          Text(
                            express,
                            style: typo.xSmall.copyWith(
                              color: cs.primary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w500,
                              fontSize: isMobile ? null : 13,
                            ),
                          ),
                      ],
                    ),
                    if (hasKwargs) _buildKwargsBadge(context, task),
                  ],
                ),
              ),
              SizedBox(width: theme.density.baseGap * theme.scaling),
              shadcn.Switch(
                value: task.enabled,
                onChanged: (v) =>
                    ref.read(scheduleProvider.notifier).toggle(task.id, v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<shadcn.MenuItem> _taskMenuItems(BuildContext context, Schedule task) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    shadcn.MenuButton item({
      required IconData icon,
      required String title,
      required Future<void> Function(BuildContext overlayContext) onPressed,
      bool destructive = false,
    }) {
      final color = destructive ? cs.destructive : cs.foreground;
      return shadcn.MenuButton(
        leading: Icon(icon, size: theme.scaling * 15, color: color),
        onPressed: onPressed,
        child: SizedBox(
          width: 140,
          child: Text(
            title,
            style: theme.typography.small.copyWith(color: color),
          ),
        ),
      );
    }

    return [
      item(
        icon: shadcn.LucideIcons.play,
        title: '立即执行',
        onPressed: (ctx) async {
          await shadcn.closeOverlay(ctx);
          await ref.read(scheduleProvider.notifier).runOnce(task.id);
        },
      ),
      item(
        icon: shadcn.LucideIcons.pencil,
        title: '编辑',
        onPressed: (ctx) async {
          await shadcn.closeOverlay(ctx);
          if (!context.mounted) return;
          _openEdit(context, ref, task);
        },
      ),
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.trash2,
        title: '删除',
        destructive: true,
        onPressed: (ctx) async {
          await shadcn.closeOverlay(ctx);
          if (!context.mounted) return;
          _DeleteConfirmDialog.show(context, ref, task);
        },
      ),
    ];
  }

  Widget _buildKwargsBadge(BuildContext context, Schedule task) {
    final downloaders = ref.watch(downloaderListProvider).valueOrNull ?? [];

    try {
      final kwargs = jsonDecode(task.kwargs) as Map<String, dynamic>;
      final parts = <String>[];

      if (task.task.contains('种子迁移')) {
        final srcId = kwargs['source_downloader_id'];
        final distId = kwargs['dist_downloader_id'];
        final srcName =
            downloaders.firstWhereOrNull((d) => d.id == srcId)?.name ??
            '#$srcId';
        final distName =
            downloaders.firstWhereOrNull((d) => d.id == distId)?.name ??
            '#$distId';
        parts.add('$srcName → $distName');

        final folders = kwargs['folder_map'] as List?;
        if (folders != null && folders.isNotEmpty) {
          parts.add('${folders.first}');
        }
        if (kwargs['remove_source_torrents'] == true) parts.add('删除源种子');
      }

      if (parts.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(
          top:
              shadcn.Theme.of(context).density.baseGap *
              shadcn.Theme.of(context).scaling *
              0.4,
        ),
        child: shadcn.SecondaryBadge(
          child: Text(
            parts.join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: shadcn.Theme.of(context).typography.xSmall.copyWith(
              color: shadcn.Theme.of(context).colorScheme.mutedForeground,
              fontSize: context.isMobile ? 11 : 12,
            ),
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  IconData _taskIcon(String type) {
    return switch (type) {
      '自动签到任务' || '阿里云签到' => shadcn.LucideIcons.check,
      '批量抓取站点信息' => shadcn.LucideIcons.globe,
      'RSS订阅' => shadcn.LucideIcons.rss,
      '下载器辅种任务' => shadcn.LucideIcons.copy,
      '种子迁移任务' => shadcn.LucideIcons.arrowRightLeft,
      '自动清理内存' => shadcn.LucideIcons.trash2,
      _ => shadcn.LucideIcons.calendarClock,
    };
  }
}

// ==================== 删除确认 ====================
class _DeleteConfirmDialog {
  static void show(BuildContext context, WidgetRef ref, Schedule task) {
    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        leading: const Icon(shadcn.LucideIcons.trash2),
        title: const Text('确认删除'),
        content: Text('确定要删除任务「${task.name}」吗？'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () async {
              closeAppSheet(ctx);
              await ref.read(scheduleProvider.notifier).delete(task.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
