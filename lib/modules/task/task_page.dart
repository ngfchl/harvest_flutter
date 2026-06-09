// ========================
// pages/task/task_page.dart
// ========================

import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/download/provider/downloader_provider.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../widgets/cache_status_banner.dart';
import '../shell/provider/screenshot_provider.dart';
import '../shell/widgets/shell_scaffold.dart';
import '../torrents/widgets/torrent_stats_bar.dart';
import 'model/schedule.dart';
import 'model/task_result.dart';
import 'provider/crontab_provider.dart';
import 'provider/schedule_provider.dart';
import 'service/schedule_service.dart';
import 'widgets/schedule_edit_sheet.dart';
import 'widgets/torrent_move_edit_sheet.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(scheduleProvider);
    final theme = shadcn.Theme.of(context);
    final pageBackground = appSurfaceColor(
      context,
      theme.colorScheme.background,
    );

    return AppBackground(
      child: shadcn.Scaffold(
        backgroundColor: pageBackground,
        child: Column(
          children: [
            _TaskTabBar(
              index: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  tasksAsync.when(
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
                  const _TaskResultListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext buttonContext, WidgetRef ref) {
    final pageContext = context;
    shadcn.showDropdown<void>(
      context: buttonContext,
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
              unawaited(shadcn.closeOverlay(overlayContext));
              if (!pageContext.mounted) return;
              _openEdit(pageContext, ref, null, isTorrentMove: false);
            },
            child: const Text('普通任务'),
          ),
          shadcn.MenuButton(
            leading: const Icon(shadcn.LucideIcons.arrowRightLeft),
            onPressed: (overlayContext) async {
              unawaited(shadcn.closeOverlay(overlayContext));
              if (!pageContext.mounted) return;
              _openEdit(pageContext, ref, null, isTorrentMove: true);
            },
            child: const Text('种子迁移任务'),
          ),
        ],
      ),
    );
  }
}

class _TaskTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _TaskTabBar({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final horizontalInset = context.isMobile ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalInset, 10, horizontalInset, 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: shadcn.Tabs(
          index: index,
          onChanged: onChanged,
          children: const [
            shadcn.TabItem(child: Text('计划任务')),
            shadcn.TabItem(child: Text('执行记录')),
          ],
        ),
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
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
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
    final horizontalInset = context.isMobile ? 12.0 : 24.0;
    final totalCount = enabledCount + disabledCount;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 14,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBarMetric(
                  icon: shadcn.LucideIcons.radio,
                  label: '启用',
                  value: '$enabledCount',
                  color: enabledCount > 0 ? cs.primary : cs.mutedForeground,
                ),
                StatusBarCount(label: '禁用', count: disabledCount),
                StatusBarCount(label: '总数', count: totalCount),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (buttonContext) => StatusBarIconButton(
              onTap: () => onAdd(buttonContext),
              icon: shadcn.LucideIcons.plus,
              tooltip: '添加任务',
              color: cs.mutedForeground,
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
    final taskCrontabExpress = task.crontab?.express.trim() ?? '';
    final matchedCrontabExpress =
        crontabList
            .firstWhereOrNull((c) => c.id == task.crontabId)
            ?.express
            .trim() ??
        '';
    final express = taskCrontabExpress.isNotEmpty
        ? taskCrontabExpress
        : matchedCrontabExpress;

    final icon = _taskIcon(task.task);
    final isMobile = context.isMobile;
    final isDesktop = context.isDesktop;
    final kwargsSummary = _taskKwargsSummary(task);
    final showExtraParamSlot = kwargsSummary != null || isDesktop;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final gap = theme.density.baseGap * theme.scaling;
    final contentPadding = theme.density.baseContentPadding * theme.scaling;
    final heightScale = theme.scaling.clamp(0.92, 1.18).toDouble();
    final iconBadgeSize = (isMobile ? 42.0 : 44.0) * heightScale;
    final switchWidth = 36.0 * theme.scaling;
    final cardHeight =
        (isMobile ? (kwargsSummary == null ? 88.0 : 112.0) : 108.0) *
        heightScale;
    final accent = task.enabled ? cs.primary : cs.mutedForeground;
    final titleColor = task.enabled ? cs.foreground : cs.mutedForeground;
    final cardRadius = BorderRadius.circular(theme.radiusLg);
    final cardColor = task.enabled
        ? appSurfaceColor(context, cs.card)
        : appSurfaceColor(
            context,
            Color.alphaBlend(
              cs.mutedForeground.withValues(alpha: 0.035),
              cs.card,
            ),
          );
    final cardBorderColor = task.enabled
        ? cs.border.withValues(alpha: 0.78)
        : cs.border.withValues(alpha: 0.64);
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.10);

    return AppContextMenu(
      items: _taskMenuItems(context, task),
      openOnTap: isMobile,
      openOnLongPress: !isMobile,
      child: SizedBox(
        height: cardHeight,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: cardRadius,
            border: Border.all(color: cardBorderColor, width: 0.6),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: cs.primary.withValues(alpha: task.enabled ? 0.045 : 0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: cardRadius,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(
                    color: accent.withValues(alpha: task.enabled ? 0.42 : 0.18),
                    child: const SizedBox(width: 3),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    contentPadding,
                    gap * 0.72,
                    contentPadding * 0.85,
                    gap * 0.72,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _buildTaskIconBadge(
                            context,
                            icon,
                            task.enabled,
                            size: iconBadgeSize,
                          ),
                          SizedBox(width: gap * 0.85),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  task.name,
                                  style: typo.small.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: gap * 0.52),
                                _buildTaskParamLine(
                                  context,
                                  task: task,
                                  icon: icon,
                                  express: express,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: gap * 0.8),
                          SizedBox(
                            width: switchWidth,
                            child: Align(
                              alignment: Alignment.center,
                              child: shadcn.Switch(
                                value: task.enabled,
                                onChanged: (v) => ref
                                    .read(scheduleProvider.notifier)
                                    .toggle(task.id, v),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showExtraParamSlot) ...[
                        SizedBox(height: gap * 0.42),
                        Row(
                          children: [
                            SizedBox(width: iconBadgeSize + gap * 0.85),
                            Expanded(
                              child: kwargsSummary != null
                                  ? _buildTaskExtraParamLine(
                                      context,
                                      task,
                                      kwargsSummary,
                                    )
                                  : const SizedBox(height: 22),
                            ),
                            SizedBox(width: gap * 0.8 + switchWidth),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskParamLine(
    BuildContext context, {
    required Schedule task,
    required IconData icon,
    required String express,
  }) {
    final children = <Widget>[
      Flexible(
        flex: 3,
        child: _buildTaskParamPill(
          context,
          icon: icon,
          label: task.task,
          color: _taskTagColor(context, 0),
          enabled: task.enabled,
        ),
      ),
    ];

    if (express.isNotEmpty) {
      children.add(const SizedBox(width: 6));
      children.add(
        Flexible(
          flex: 3,
          child: _buildTaskParamPill(
            context,
            icon: shadcn.LucideIcons.clock3,
            label: express,
            color: _taskTagColor(context, 1),
            enabled: task.enabled,
            monospace: true,
          ),
        ),
      );
    }

    return SizedBox(height: 24, child: Row(children: children));
  }

  Widget _buildTaskExtraParamLine(
    BuildContext context,
    Schedule task,
    String summary,
  ) {
    return SizedBox(
      height: 22,
      child: Align(
        alignment: Alignment.centerLeft,
        child: _buildKwargsBadge(context, task, summary),
      ),
    );
  }

  Widget _buildTaskParamPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool enabled,
    bool monospace = false,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final gap = theme.density.baseGap * theme.scaling;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = enabled
        ? color
        : Color.lerp(cs.mutedForeground, color, 0.58)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: contentColor.withValues(
          alpha: enabled ? (dark ? 0.18 : 0.11) : (dark ? 0.12 : 0.075),
        ),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(
          color: contentColor.withValues(alpha: enabled ? 0.30 : 0.20),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: gap * 0.62,
          vertical: gap * 0.28,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: contentColor),
            SizedBox(width: gap * 0.35),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: contentColor,
                  fontFamily: monospace ? 'monospace' : null,
                  fontWeight: monospace ? FontWeight.w700 : FontWeight.w600,
                  fontSize: context.isMobile ? 10.5 : 11,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _taskTagColor(BuildContext context, int index) {
    final primary = shadcn.Theme.of(context).colorScheme.primary;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hsl = HSLColor.fromColor(primary);
    final saturation = (hsl.saturation * (dark ? 0.88 : 1.0))
        .clamp(0.46, 0.78)
        .toDouble();
    final lightness = dark
        ? hsl.lightness.clamp(0.58, 0.70).toDouble()
        : hsl.lightness.clamp(0.34, 0.50).toDouble();
    const offsets = <double>[0, -72, -144];
    final hue = (hsl.hue + offsets[index % offsets.length]) % 360;

    return hsl
        .withHue(hue < 0 ? hue + 360 : hue)
        .withSaturation(saturation)
        .withLightness(lightness)
        .toColor();
  }

  Widget _buildTaskIconBadge(
    BuildContext context,
    IconData icon,
    bool enabled, {
    required double size,
  }) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final accent = enabled ? cs.primary : cs.mutedForeground;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: enabled ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(theme.radiusMd),
        border: Border.all(
          color: accent.withValues(alpha: enabled ? 0.24 : 0.16),
          width: 0.5,
        ),
      ),
      child: Icon(icon, size: size * 0.5, color: accent),
    );
  }

  List<shadcn.MenuItem> _taskMenuItems(BuildContext context, Schedule task) {
    final pageContext = this.context;
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
        autoClose: false,
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
        title: '执行',
        onPressed: (ctx) async {
          unawaited(shadcn.closeOverlay(ctx));
          await _runTaskOnce(task);
        },
      ),
      item(
        icon: shadcn.LucideIcons.pencil,
        title: '编辑',
        onPressed: (ctx) async {
          unawaited(shadcn.closeOverlay(ctx));
          await Future<void>.delayed(const Duration(milliseconds: 240));
          if (!mounted || !pageContext.mounted) return;
          _openEdit(pageContext, ref, task);
        },
      ),
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.trash2,
        title: '删除',
        destructive: true,
        onPressed: (ctx) async {
          unawaited(shadcn.closeOverlay(ctx));
          await Future<void>.delayed(const Duration(milliseconds: 240));
          if (!mounted || !pageContext.mounted) return;
          _DeleteConfirmDialog.show(pageContext, ref, task);
        },
      ),
    ];
  }

  Future<void> _runTaskOnce(Schedule task) async {
    try {
      await ref.read(scheduleProvider.notifier).runOnce(task.id);
      Toast.success('已发起执行：${task.name}');
      ref.invalidate(taskResultsProvider);
    } catch (e, st) {
      AppLogger.error('手动执行任务失败', e, st);
      Toast.error('任务执行失败');
    }
  }

  Widget _buildKwargsBadge(
    BuildContext context,
    Schedule task,
    String summary,
  ) {
    return _buildTaskParamPill(
      context,
      icon: shadcn.LucideIcons.listTree,
      label: summary,
      color: _taskTagColor(context, 2),
      enabled: task.enabled,
    );
  }

  String? _taskKwargsSummary(Schedule task) {
    final kwargsText = task.kwargs.trim();
    if (kwargsText.isEmpty || kwargsText == '{}') return null;

    final downloaders = ref.watch(downloaderListProvider).valueOrNull ?? [];

    try {
      final kwargs = jsonDecode(kwargsText) as Map<String, dynamic>;
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

      return parts.isEmpty ? null : parts.join(' · ');
    } catch (_) {
      return null;
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

class _TaskResultListView extends ConsumerWidget {
  const _TaskResultListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(taskResultsProvider);

    return resultsAsync.when(
      loading: () => Column(
        children: [
          _TaskResultStatusBar(
            results: const [],
            loading: true,
            onRefresh: () => ref.invalidate(taskResultsProvider),
            onClear: null,
          ),
          const Expanded(
            child: Center(
              child: shadcn.CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
      error: (e, _) => Column(
        children: [
          _TaskResultStatusBar(
            results: const [],
            onRefresh: () => ref.invalidate(taskResultsProvider),
            onClear: null,
          ),
          Expanded(
            child: _ErrorView(
              error: e,
              onRetry: () => ref.invalidate(taskResultsProvider),
            ),
          ),
        ],
      ),
      data: (results) => Column(
        children: [
          _TaskResultStatusBar(
            results: results,
            onRefresh: () => ref.invalidate(taskResultsProvider),
            onClear: results.isEmpty
                ? null
                : () => _TaskResultClearDialog.show(context, ref),
          ),
          Expanded(
            child: EasyRefresh(
              onRefresh: () async => ref.invalidate(taskResultsProvider),
              header: appRefreshHeader(context),
              child: results.isEmpty
                  ? _TaskResultEmptyView(
                      onRefresh: () => ref.invalidate(taskResultsProvider),
                    )
                  : _TaskResultList(results: results),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskResultStatusBar extends StatelessWidget {
  final List<TaskResult> results;
  final VoidCallback onRefresh;
  final VoidCallback? onClear;
  final bool loading;

  const _TaskResultStatusBar({
    required this.results,
    required this.onRefresh,
    required this.onClear,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final horizontalInset = context.isMobile ? 12.0 : 24.0;
    final successCount = results.where((result) => result.isSuccess).length;
    final failureCount = results.where((result) => result.isFailure).length;

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalInset, 8, horizontalInset, 8),
      decoration: BoxDecoration(
        color: appSurfaceColor(context, cs.background),
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 14,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusBarMetric(
                  icon: shadcn.LucideIcons.history,
                  label: '记录',
                  value: loading ? '-' : '${results.length}',
                  color: cs.primary,
                ),
                StatusBarMetric(
                  icon: shadcn.LucideIcons.circleCheck,
                  label: '成功',
                  value: loading ? '-' : '$successCount',
                  color: const Color(0xFF16A34A),
                ),
                StatusBarMetric(
                  icon: shadcn.LucideIcons.circleAlert,
                  label: '失败',
                  value: loading ? '-' : '$failureCount',
                  color: failureCount > 0 ? cs.destructive : cs.mutedForeground,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBarIconButton(
            onTap: onRefresh,
            icon: shadcn.LucideIcons.refreshCw,
            tooltip: '刷新执行记录',
            color: cs.mutedForeground,
          ),
          StatusBarIconButton(
            onTap: onClear,
            icon: shadcn.LucideIcons.trash2,
            tooltip: '清理执行记录',
            color: onClear == null ? null : cs.destructive,
          ),
        ],
      ),
    );
  }
}

class _TaskResultEmptyView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _TaskResultEmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 16 + ShellBottomSpacing.value(context)),
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shadcn.LucideIcons.clipboardList,
                size: 48,
                color: cs.mutedForeground,
              ),
              const SizedBox(height: 16),
              Text('暂无执行记录', style: theme.typography.large),
              const SizedBox(height: 16),
              shadcn.Button.outline(
                onPressed: onRefresh,
                child: const Text('刷新'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaskResultList extends StatelessWidget {
  final List<TaskResult> results;

  const _TaskResultList({required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.isMobile ? 12 : 16,
        12,
        context.isMobile ? 12 : 16,
        16 + ShellBottomSpacing.value(context),
      ),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _TaskResultTile(result: results[index]),
    );
  }
}

class _TaskResultTile extends ConsumerWidget {
  final TaskResult result;

  const _TaskResultTile({required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final typo = theme.typography;
    final statusColor = _taskResultStatusColor(context, result.status);
    final startedAt = _formatTaskResultTime(result.createdAt);
    final finishedAt = _formatTaskResultTime(result.finishedAt);
    final displayTitle = _taskResultDisplayTitle(result);
    final displaySummary = _taskResultDisplaySummary(result);
    final id = result.displayId;

    return AppContextMenu(
      items: _taskResultMenuItems(context, ref, result),
      openOnTap: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _TaskResultDetailDialog.show(context, ref, result),
        child: AppSurfaceContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          borderRadius: BorderRadius.circular(8),
          color: appSurfaceColor(context, cs.card),
          borderColor: cs.border.withValues(alpha: 0.66),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.24),
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  _taskResultStatusIcon(result.status),
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.small.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TaskResultStatusBadge(
                          status: result.status,
                          color: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (startedAt.isNotEmpty)
                          _TaskResultMeta(
                            icon: shadcn.LucideIcons.clock,
                            text: startedAt,
                          ),
                        if (finishedAt.isNotEmpty)
                          _TaskResultMeta(
                            icon: shadcn.LucideIcons.check,
                            text: finishedAt,
                          ),
                        if (id.isNotEmpty)
                          _TaskResultMeta(
                            icon: shadcn.LucideIcons.fileText,
                            text: _shortTaskResultId(id),
                            monospace: true,
                          ),
                      ],
                    ),
                    if (displaySummary.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        displaySummary,
                        maxLines: context.isMobile ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: typo.xSmall.copyWith(color: cs.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                shadcn.LucideIcons.chevronRight,
                size: 16,
                color: cs.mutedForeground.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskResultStatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _TaskResultStatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final label = _taskResultStatusLabel(status);

    return Container(
      constraints: const BoxConstraints(minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.typography.xSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}

class _TaskResultMeta extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool monospace;

  const _TaskResultMeta({
    required this.icon,
    required this.text,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.mutedForeground),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.typography.xSmall.copyWith(
            color: cs.mutedForeground,
            fontFamily: monospace ? 'monospace' : null,
            fontFeatures: monospace
                ? const [FontFeature.tabularFigures()]
                : null,
          ),
        ),
      ],
    );
  }
}

class _TaskResultDetailDialog {
  static void show(BuildContext context, WidgetRef ref, TaskResult result) {
    final taskId = result.displayId.trim();

    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        title: const Text('执行记录详情'),
        content: SizedBox(
          width: context.isMobile ? double.infinity : 680,
          height: context.isMobile ? 520 : 560,
          child: taskId.isEmpty
              ? _TaskResultDetailContent(result: result, loading: false)
              : Consumer(
                  builder: (context, ref, _) {
                    final async = ref.watch(taskResultDetailProvider(taskId));
                    return async.when(
                      loading: () => _TaskResultDetailContent(
                        result: result,
                        loading: true,
                      ),
                      error: (_, __) => _TaskResultDetailContent(
                        result: result,
                        loading: false,
                      ),
                      data: (detail) => _TaskResultDetailContent(
                        result: detail ?? result,
                        fallback: result,
                        loading: false,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

class _TaskResultDetailContent extends StatelessWidget {
  final TaskResult result;
  final TaskResult? fallback;
  final bool loading;

  const _TaskResultDetailContent({
    required this.result,
    this.fallback,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    final statusColor = _taskResultStatusColor(context, result.status);
    final content = _taskResultMarkdownContent(result, fallback);
    final displayTitle = _taskResultDisplayTitle(result);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: shadcn.CircularProgressIndicator(strokeWidth: 2),
              )
            else
              _TaskResultStatusBadge(status: result.status, color: statusColor),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (result.displayId.isNotEmpty)
              _TaskResultMeta(
                icon: shadcn.LucideIcons.fileText,
                text: result.displayId,
                monospace: true,
              ),
            if (result.createdAt != null)
              _TaskResultMeta(
                icon: shadcn.LucideIcons.clock,
                text: '开始 ${_formatTaskResultTime(result.createdAt)}',
              ),
            if (result.finishedAt != null)
              _TaskResultMeta(
                icon: shadcn.LucideIcons.check,
                text: '结束 ${_formatTaskResultTime(result.finishedAt)}',
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AppSurfaceContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: BorderRadius.circular(8),
            color: appSurfaceColor(
              context,
              Color.alphaBlend(
                cs.mutedForeground.withValues(alpha: 0.035),
                cs.card,
              ),
            ),
            borderColor: cs.border.withValues(alpha: 0.64),
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: content,
                selectable: true,
                fitContent: false,
                softLineBreak: true,
                extensionSet: null,
                styleSheet: _taskResultMarkdownStyleSheet(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskResultClearDialog {
  static void show(BuildContext context, WidgetRef ref) {
    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        leading: const Icon(shadcn.LucideIcons.trash2),
        title: const Text('清理执行记录'),
        content: const Text('确定要清理所有任务执行记录吗？'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () async {
              closeAppSheet(ctx);
              try {
                await ScheduleService.clearTaskResults();
                ref.invalidate(taskResultsProvider);
                Toast.success('执行记录已清理');
              } catch (e, st) {
                AppLogger.error('清理执行记录失败', e, st);
                Toast.error('清理执行记录失败');
              }
            },
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }
}

List<shadcn.MenuItem> _taskResultMenuItems(
  BuildContext context,
  WidgetRef ref,
  TaskResult result,
) {
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
      autoClose: false,
      onPressed: onPressed,
      child: SizedBox(
        width: 128,
        child: Text(
          title,
          style: theme.typography.small.copyWith(color: color),
        ),
      ),
    );
  }

  return [
    item(
      icon: shadcn.LucideIcons.fileText,
      title: '任务记录详情',
      onPressed: (ctx) async {
        unawaited(shadcn.closeOverlay(ctx));
        _TaskResultDetailDialog.show(context, ref, result);
      },
    ),
    if (_taskResultCanCancel(result))
      item(
        icon: shadcn.LucideIcons.circleX,
        title: '取消当前任务',
        destructive: true,
        onPressed: (ctx) async {
          unawaited(shadcn.closeOverlay(ctx));
          _TaskResultCancelDialog.show(context, ref, result);
        },
      ),
    if (_taskResultCanDeleteRecord(result)) ...[
      const shadcn.MenuDivider(),
      item(
        icon: shadcn.LucideIcons.trash2,
        title: '删除任务记录',
        destructive: true,
        onPressed: (ctx) async {
          unawaited(shadcn.closeOverlay(ctx));
          _TaskResultDeleteDialog.show(context, ref, result);
        },
      ),
    ],
  ];
}

class _TaskResultDeleteDialog {
  static void show(BuildContext context, WidgetRef ref, TaskResult result) {
    final taskId = result.displayId.trim();
    if (taskId.isEmpty) {
      Toast.warning('缺少任务 ID，无法删除');
      return;
    }

    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        leading: const Icon(shadcn.LucideIcons.trash2),
        title: const Text('删除执行记录'),
        content: Text('确定要删除「${_taskResultDisplayTitle(result)}」这条执行记录吗？'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () async {
              closeAppSheet(ctx);
              try {
                await ScheduleService.deleteTaskResult(taskId);
                ref.invalidate(taskResultsProvider);
                ref.invalidate(taskResultDetailProvider(taskId));
                Toast.success('执行记录已删除');
              } catch (e, st) {
                AppLogger.error('删除执行记录失败', e, st);
                Toast.error('删除执行记录失败');
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _TaskResultCancelDialog {
  static void show(BuildContext context, WidgetRef ref, TaskResult result) {
    final taskId = result.displayId.trim();
    if (taskId.isEmpty) {
      Toast.warning('缺少任务 ID，无法取消');
      return;
    }

    shadcn.showDialog(
      context: context,
      builder: (ctx) => shadcn.AlertDialog(
        leading: const Icon(shadcn.LucideIcons.circleX),
        title: const Text('取消任务'),
        content: Text('确定要取消「${_taskResultDisplayTitle(result)}」吗？'),
        actions: [
          shadcn.Button.outline(
            onPressed: () => closeAppSheet(ctx),
            child: const Text('取消'),
          ),
          shadcn.Button.destructive(
            onPressed: () async {
              closeAppSheet(ctx);
              try {
                await ScheduleService.terminateTaskResult(taskId);
                ref.invalidate(taskResultsProvider);
                ref.invalidate(taskResultDetailProvider(taskId));
                Toast.success('已发起取消');
              } catch (e, st) {
                AppLogger.error('取消任务失败', e, st);
                Toast.error('取消任务失败');
              }
            },
            child: const Text('取消任务'),
          ),
        ],
      ),
    );
  }
}

String _taskResultDisplayTitle(TaskResult result) {
  final title = result.name.trim();
  return title.isEmpty ? '未命名任务' : title;
}

String _taskResultDisplaySummary(TaskResult result) {
  final summary = result.summary.trim();
  if (summary.isEmpty) return '';
  if (_sameTaskResultText(summary, result.name)) return '';
  return summary;
}

bool _sameTaskResultText(String a, String b) {
  final left = a.replaceAll(RegExp(r'\s+'), ' ').trim();
  final right = b.replaceAll(RegExp(r'\s+'), ' ').trim();
  return left.isNotEmpty && left == right;
}

bool _taskResultCanCancel(TaskResult result) {
  return result.displayId.trim().isNotEmpty && _taskResultIsActive(result);
}

bool _taskResultCanDeleteRecord(TaskResult result) {
  return result.displayId.trim().isNotEmpty && _taskResultIsCompleted(result);
}

bool _taskResultIsActive(TaskResult result) {
  return switch (result.status.trim().toLowerCase()) {
    'started' ||
    'running' ||
    'progress' ||
    'retry' ||
    'pending' ||
    'queued' ||
    'received' => true,
    _ => false,
  };
}

bool _taskResultIsCompleted(TaskResult result) {
  return switch (result.status.trim().toLowerCase()) {
    'success' ||
    'succeeded' ||
    'done' ||
    'failure' ||
    'failed' ||
    'error' ||
    'revoked' => true,
    _ => false,
  };
}

String _taskResultMarkdownContent(TaskResult result, TaskResult? fallback) {
  final summary = _taskResultDisplaySummary(result).trim();
  if (summary.isNotEmpty) return summary;

  final raw = result.raw.isNotEmpty ? result.raw : fallback?.raw ?? const {};
  final value = _taskResultContentValue(raw);
  final content = _taskResultValueToMarkdown(value);
  if (_sameTaskResultText(content, _taskResultDisplayTitle(result))) {
    return '暂无结果内容';
  }
  return content.trim().isEmpty ? '暂无结果内容' : content.trim();
}

Object? _taskResultContentValue(Map<String, dynamic> raw) {
  for (final key in const [
    'summary',
    'message',
    'result',
    'retval',
    'error',
    'traceback',
    'output',
    'stdout',
    'stderr',
    'content',
    'detail',
    'details',
  ]) {
    final value = raw[key];
    if (value == null) continue;
    if (value is String && value.trim().isEmpty) continue;
    return value;
  }
  return null;
}

String _taskResultValueToMarkdown(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  if (value is num || value is bool) return '$value';
  return '```json\n${_prettyTaskResultJson(value)}\n```';
}

MarkdownStyleSheet _taskResultMarkdownStyleSheet(BuildContext context) {
  final cs = shadcn.Theme.of(context).colorScheme;
  final typo = shadcn.Theme.of(context).typography;
  final body = typo.small.copyWith(color: cs.foreground, height: 1.55);

  return MarkdownStyleSheet(
    a: body.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
    p: body,
    pPadding: const EdgeInsets.only(bottom: 10),
    h1: typo.xLarge.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h1Padding: const EdgeInsets.only(bottom: 10),
    h2: typo.large.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h2Padding: const EdgeInsets.only(bottom: 8),
    h3: typo.base.copyWith(
      color: cs.foreground,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    h3Padding: const EdgeInsets.only(bottom: 8),
    h4: body.copyWith(fontWeight: FontWeight.w700),
    h5: body.copyWith(fontWeight: FontWeight.w700),
    h6: body.copyWith(fontWeight: FontWeight.w700),
    strong: const TextStyle(fontWeight: FontWeight.w700),
    em: const TextStyle(fontStyle: FontStyle.italic),
    del: const TextStyle(decoration: TextDecoration.lineThrough),
    blockSpacing: 8,
    listIndent: 24,
    listBullet: body.copyWith(color: cs.mutedForeground),
    code: typo.xSmall.copyWith(
      color: cs.foreground,
      fontFamily: 'monospace',
      backgroundColor: cs.muted.withValues(alpha: 0.28),
    ),
    codeblockPadding: const EdgeInsets.all(12),
    codeblockDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.28),
      border: Border.all(color: cs.border.withValues(alpha: 0.6), width: 0.7),
      borderRadius: BorderRadius.circular(6),
    ),
    blockquote: body.copyWith(color: cs.mutedForeground),
    blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    blockquoteDecoration: BoxDecoration(
      color: cs.muted.withValues(alpha: 0.18),
      border: Border(
        left: BorderSide(color: cs.primary.withValues(alpha: 0.55), width: 3),
      ),
    ),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: cs.border, width: 1)),
    ),
    tableBorder: TableBorder.all(color: cs.border, width: 0.7),
    tableHead: body.copyWith(fontWeight: FontWeight.w700),
    tableBody: body,
    tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  );
}

String _formatTaskResultTime(DateTime? value) {
  if (value == null) return '';
  return formatDateTimeMinute(value.toLocal());
}

String _shortTaskResultId(String value) {
  final text = value.trim();
  if (text.length <= 18) return text;
  return '${text.substring(0, 8)}...${text.substring(text.length - 6)}';
}

String _taskResultStatusLabel(String status) {
  final text = status.trim();
  final normalized = text.toLowerCase();
  return switch (normalized) {
    'success' || 'succeeded' || 'done' => '成功',
    'failure' || 'failed' || 'error' => '失败',
    'revoked' => '已撤销',
    'started' || 'running' || 'progress' || 'retry' => '执行中',
    'pending' || 'queued' || 'received' => '等待中',
    _ => text.isEmpty ? '未知' : text,
  };
}

IconData _taskResultStatusIcon(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'success' ||
      normalized == 'succeeded' ||
      normalized == 'done') {
    return shadcn.LucideIcons.circleCheck;
  }
  if (normalized == 'failure' ||
      normalized == 'failed' ||
      normalized == 'error' ||
      normalized == 'revoked') {
    return shadcn.LucideIcons.circleAlert;
  }
  if (normalized == 'started' ||
      normalized == 'running' ||
      normalized == 'progress' ||
      normalized == 'retry') {
    return shadcn.LucideIcons.loaderCircle;
  }
  return shadcn.LucideIcons.clock;
}

Color _taskResultStatusColor(BuildContext context, String status) {
  final cs = shadcn.Theme.of(context).colorScheme;
  final normalized = status.toLowerCase();
  if (normalized == 'success' ||
      normalized == 'succeeded' ||
      normalized == 'done') {
    return const Color(0xFF16A34A);
  }
  if (normalized == 'failure' ||
      normalized == 'failed' ||
      normalized == 'error' ||
      normalized == 'revoked') {
    return cs.destructive;
  }
  if (normalized == 'started' ||
      normalized == 'running' ||
      normalized == 'progress' ||
      normalized == 'retry') {
    return cs.primary;
  }
  if (normalized == 'pending' ||
      normalized == 'queued' ||
      normalized == 'received') {
    return const Color(0xFFD97706);
  }
  return cs.mutedForeground;
}

String _prettyTaskResultJson(Object? value) {
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return '$value';
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
