// ========================
// pages/task/task_page.dart
// ========================

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/common/style.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
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

    return Stack(
      children: [
        FScaffold(
          childPad: false,
          child: tasksAsync.when(
            loading: () => const Center(child: FProgress.circularIcon()),
            error: (e, _) => _ErrorView(
              error: e,
              onRetry: () => ref.invalidate(scheduleProvider),
            ),
            data: (tasks) => _TaskListView(tasks: tasks),
          ),
        ),
        Positioned(
          right: context.isMobile ? 16 : 24,
          bottom:
              (context.isMobile ? 24 : 32) + ShellBottomSpacing.value(context),
          child: FButton.icon(
            onPress: () => _openAdd(context, ref),
            child: Icon(FIcons.plus, size: context.isMobile ? 22 : 24),
          ),
        ),
      ],
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile;
    final content = _AddChoiceSheet(
      onNormal: () {
        if (isMobile) Navigator.pop(context);
        _openEdit(context, ref, null, isTorrentMove: false);
      },
      onTorrent: () {
        if (isMobile) Navigator.pop(context);
        _openEdit(context, ref, null, isTorrentMove: true);
      },
    );

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => content,
      );
    } else {
      showDialog(context: context, builder: (_) => content);
    }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => sheet,
    );
  } else {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 640),
          child: sheet,
        ),
      ),
    );
  }
}

// ==================== 新增选择 ====================
class _AddChoiceSheet extends StatelessWidget {
  final VoidCallback onNormal;
  final VoidCallback onTorrent;

  const _AddChoiceSheet({required this.onNormal, required this.onTorrent});

  @override
  Widget build(BuildContext context) {
    final tiles = FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FIcons.calendarClock, size: 20),
          title: const Text('普通任务'),
          onPress: onNormal,
        ),
        FTile(
          prefix: const Icon(FIcons.arrowRightLeft, size: 20),
          title: const Text('种子迁移任务'),
          onPress: onTorrent,
        ),
      ],
    );

    if (context.isMobile) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            _handle(context),
            const SizedBox(height: 16),
            tiles,
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '添加任务',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              tiles,
            ],
          ),
        ),
      ),
    );
  }

  static Widget _handle(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.theme.colors.border,
        borderRadius: BorderRadius.circular(99),
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
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FIcons.triangleAlert,
            size: 48,
            color: context.theme.colors.destructive,
          ),
          const SizedBox(height: 16),
          Text('加载失败', style: context.theme.typography.lg),
          const SizedBox(height: 8),
          Text(
            '$error',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),
          FButton(onPress: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

// ==================== 列表视图 ====================
class _TaskListView extends ConsumerStatefulWidget {
  final List<Schedule> tasks;

  const _TaskListView({required this.tasks});

  @override
  ConsumerState<_TaskListView> createState() => _TaskListViewState();
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

  Widget build(BuildContext context) {
    final cacheInfo = ref.watch(scheduleCacheInfoProvider);

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
                          FIcons.calendarOff,
                          size: 48,
                          color: context.theme.colors.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text('暂无计划任务', style: context.theme.typography.lg),
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

    final (icon, color) = _taskIcon(task.task);
    final isMobile = context.isMobile;
    final hasKwargs = task.kwargs.isNotEmpty && task.kwargs != '{}';
    final cs = FTheme.of(context).colors;

    final cardRadius = BorderRadius.circular(12);
    final anchorContext = context;

    return FPopoverMenu.tiles(
      style: fPopoverMenuStyle(context).call,
      spacing: FPortalSpacing.zero,
      menuBuilder: (_, controller, _) =>
          _buildActionGroups(anchorContext, ref, task, controller),
      builder: (context, controller, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: cardRadius,
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
        child: ClipRRect(
          borderRadius: cardRadius,
          child: FTile(
            style: (style) => style.copyWith(
              backgroundColor: FWidgetStateMap<Color?>.all(Colors.transparent),
              decoration: FWidgetStateMap<BoxDecoration?>({
                WidgetState.hovered | WidgetState.pressed: BoxDecoration(
                  color: cs.secondary.withValues(alpha: 0.55),
                  borderRadius: cardRadius,
                ),
                WidgetState.any: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: cardRadius,
                ),
              }),
            ),
            title: Text(
              task.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 14 : 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：图标 + 任务类型 + cron 表达式
                Row(
                  children: [
                    Icon(icon, size: isMobile ? 14 : 15, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.task,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                          fontSize: isMobile ? null : 13,
                        ),
                      ),
                    ),
                    if (express.isNotEmpty)
                      Text(
                        express,
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.primary,
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
            suffix: FSwitch(
              value: task.enabled,
              onChange: (v) =>
                  ref.read(scheduleProvider.notifier).toggle(task.id, v),
            ),
            onPress: () => controller.toggle(),
            onSecondaryPress: () => controller.toggle(),
          ),
        ),
      ),
    );
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
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          parts.join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.theme.typography.xs.copyWith(
            color: context.theme.colors.mutedForeground,
            fontSize: context.isMobile ? 11 : 12,
          ),
        ),
      );
    } catch (_) {
      return const SizedBox.shrink();
    }
  }

  (IconData, Color) _taskIcon(String type) {
    return switch (type) {
      '自动签到任务' || '阿里云签到' => (FIcons.check, Colors.green),
      '批量抓取站点信息' => (FIcons.globe, Colors.blue),
      'RSS订阅' => (FIcons.rss, Colors.orange),
      '下载器辅种任务' => (FIcons.copy, Colors.purple),
      '种子迁移任务' => (FIcons.arrowRightLeft, Colors.indigo),
      '自动清理内存' => (FIcons.trash2, Colors.teal),
      _ => (FIcons.calendarClock, Colors.grey),
    };
  }
}

// ==================== 共用操作列表 ====================
List<FTileGroupMixin> _buildActionGroups(
  BuildContext context,
  WidgetRef ref,
  Schedule task,
  FPopoverController controller,
) {
  return [
    FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FIcons.play, size: 14),
          title: const Text('立即执行'),
          onPress: () async {
            final notifier = ref.read(scheduleProvider.notifier);
            await controller.hide();
            await notifier.runOnce(task.id);
          },
        ),
        FTile(
          prefix: const Icon(FIcons.pencil, size: 14),
          title: const Text('编辑'),
          onPress: () async {
            await controller.hide();
            if (!context.mounted) return;
            _openEdit(context, ref, task);
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
            await controller.hide();
            if (!context.mounted) return;
            _DeleteConfirmDialog.show(context, ref, task);
          },
        ),
      ],
    ),
  ];
}

// ==================== 删除确认 ====================
class _DeleteConfirmDialog {
  static void show(BuildContext context, WidgetRef ref, Schedule task) {
    showDialog(
      context: context,
      builder: (ctx) => FDialog(
        title: const Text('确认删除'),
        body: Text('确定要删除任务「${task.name}」吗？'),
        actions: [
          FButton(
            style: FButtonStyle.outline(),
            onPress: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FButton(
            style: FButtonStyle.destructive(),
            onPress: () async {
              Navigator.of(ctx).pop();
              await ref.read(scheduleProvider.notifier).delete(task.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
