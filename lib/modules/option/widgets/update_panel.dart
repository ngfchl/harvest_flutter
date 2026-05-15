import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/theme/app_surface.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show IconExtension, TextExtension;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:harvest/core/utils/utils.dart';

import '../model/update_log_model.dart';
import '../provider/update_provider.dart';

class UpdateSummaryCard extends ConsumerWidget {
  final VoidCallback onOpen;

  const UpdateSummaryCard({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    final hasUpdate = state.hasAnyUpdate;
    final summary = state.hasAnyUpdate
        ? (state.updateCount > 0 ? '发现 ${state.updateCount} 条更新' : '发现可用更新')
        : state.isLoading
        ? '正在检查更新'
        : state.allLatest
        ? '当前已是最新版本'
        : '点击查看更新状态';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: shadcn.CardButton(
        onPressed: onOpen,
        child: Row(
          children: [
            hasUpdate
                ? const Icon(
                    shadcn.LucideIcons.circleAlert,
                  ).iconSmall.iconPrimary
                : const Icon(
                    shadcn.LucideIcons.refreshCw,
                  ).iconSmall.iconMutedForeground,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('程序更新').small.semiBold,
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ).xSmall.muted,
                ],
              ),
            ),
            if (state.isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: const shadcn.CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                shadcn.LucideIcons.chevronRight,
              ).iconSmall.iconMutedForeground,
          ],
        ),
      ),
    );
  }
}

class UpdatePanel extends ConsumerWidget {
  final int maxCommitCount;

  const UpdatePanel({super.key, this.maxCommitCount = 12});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UpdateOverview(state: state),
        const SizedBox(height: 8),
        _UpdateTargetCard(
          info: state.backend,
          target: UpdateTarget.backend,
          icon: shadcn.LucideIcons.package,
          isLoading: state.isBackendLoading,
          maxCommitCount: maxCommitCount,
        ),
        const SizedBox(height: 8),
        _UpdateTargetCard(
          info: state.sites,
          target: UpdateTarget.sites,
          icon: shadcn.LucideIcons.fileText,
          isLoading: state.isSitesLoading,
          maxCommitCount: maxCommitCount,
        ),
        if (state.error != null && state.error!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _MessageBox(text: state.error!, destructive: true),
        ],
        if (state.updateMessage != null && state.updateMessage!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _MessageBox(text: state.updateMessage!),
        ],
        const SizedBox(height: 8),
        _GlobalActions(state: state),
      ],
    );
  }
}

class _UpdateOverview extends ConsumerWidget {
  final UpdateState state;

  const _UpdateOverview({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final summary = state.hasAnyUpdate
        ? (state.updateCount > 0 ? '发现 ${state.updateCount} 条待更新记录' : '发现可用更新')
        : state.allLatest
        ? '后端代码和站点配置均为最新'
        : state.isLoading
        ? '正在检查更新'
        : '更新状态未知';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AppSurfaceCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        color: state.hasAnyUpdate ? cs.primary.withValues(alpha: 0.10) : null,
        borderColor: state.hasAnyUpdate
            ? cs.primary.withValues(alpha: 0.35)
            : null,
        child: Row(
          children: [
            (state.hasAnyUpdate
                    ? const Icon(shadcn.LucideIcons.circleAlert)
                    : const Icon(shadcn.LucideIcons.refreshCw))
                .iconSmall
                .iconPrimary,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('程序更新').base.bold,
                  const SizedBox(height: 2),
                  Text(summary).xSmall.muted,
                ],
              ),
            ),
            shadcn.Tooltip(
              tooltip: (_) => const Text('检查全部'),
              child: shadcn.IconButton.ghost(
                size: shadcn.ButtonSize.small,
                density: shadcn.ButtonDensity.iconDense,
                icon: state.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: const shadcn.CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(shadcn.LucideIcons.refreshCw).iconSmall,
                onPressed: state.isLoading || state.isUpdating
                    ? null
                    : () => ref.read(updateProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateTargetCard extends ConsumerWidget {
  final UpdateLogInfo? info;
  final UpdateTarget target;
  final IconData icon;
  final bool isLoading;
  final int maxCommitCount;

  const _UpdateTargetCard({
    required this.info,
    required this.target,
    required this.icon,
    required this.isLoading,
    required this.maxCommitCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final state = ref.watch(updateProvider);
    final current = info;
    final action = target.upgradeAction;
    final isUpdating = state.updatingAction == action;
    final canUpdate =
        current?.needsUpdate == true && !isLoading && !state.isUpdating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AppSurfaceCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        color: current?.needsUpdate == true
            ? cs.primary.withValues(alpha: 0.08)
            : null,
        borderColor: current?.needsUpdate == true
            ? cs.primary.withValues(alpha: 0.35)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon).iconSmall.iconMutedForeground,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(target.title).small.bold,
                      const SizedBox(height: 2),
                      Text(
                        current?.detailText ??
                            (isLoading ? '正在获取更新日志' : '还未获取更新日志'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).xSmall.muted,
                    ],
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: shadcn.CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.mutedForeground,
                    ),
                  )
                else
                  _StatusBadge(info: current),
              ],
            ),
            const SizedBox(height: 10),
            if (current == null && isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: shadcn.CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (current != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: SingleChildScrollView(
                  child: _CommitTimeline(
                    info: current,
                    maxCommitCount: maxCommitCount,
                  ),
                ),
              )
            else
              _EmptyLog(target: target),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: shadcn.Button.outline(
                    onPressed: isLoading || state.isUpdating
                        ? null
                        : () => ref
                              .read(updateProvider.notifier)
                              .refreshTarget(target),
                    child: const _ButtonContent(
                      icon: shadcn.LucideIcons.refreshCw,
                      label: '检查',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: shadcn.Button.primary(
                    onPressed: canUpdate
                        ? () => _runUpgrade(context, ref, action)
                        : null,
                    child: isUpdating
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primaryForeground,
                            ),
                          )
                        : _ButtonContent(
                            icon: shadcn.LucideIcons.download,
                            label: current == null
                                ? '更新'
                                : current.needsUpdate
                                ? '更新'
                                : '已最新',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GlobalActions extends ConsumerWidget {
  final UpdateState state;

  const _GlobalActions({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AppSurfaceCard(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('批量操作').small.bold,
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: shadcn.Button.outline(
                    onPressed: state.isUpdating
                        ? null
                        : () => _runUpgrade(context, ref, UpgradeAction.webui),
                    child: state.updatingAction == UpgradeAction.webui
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const _ButtonContent(
                            icon: shadcn.LucideIcons.download,
                            label: '更新WEBUI',
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: shadcn.Button.primary(
                    onPressed: state.isUpdating
                        ? null
                        : () => _runUpgrade(context, ref, UpgradeAction.all),
                    child: state.updatingAction == UpgradeAction.all
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: shadcn.CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.primaryForeground,
                            ),
                          )
                        : const _ButtonContent(
                            icon: shadcn.LucideIcons.download,
                            label: '更新所有',
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommitTimeline extends StatelessWidget {
  final UpdateLogInfo info;
  final int maxCommitCount;

  const _CommitTimeline({required this.info, required this.maxCommitCount});

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final currentIndex = info.currentCommitIndex;
    final displayCount = _displayCommitCount(
      total: info.commits.length,
      currentIndex: currentIndex,
      maxCommitCount: maxCommitCount,
    );
    final visibleCommits = info.commits.take(displayCount).toList();
    final hiddenCount = info.commits.length - visibleCommits.length;

    if (visibleCommits.isEmpty &&
        (info.rawText == null || info.rawText!.trim().isEmpty)) {
      return _EmptyLog(target: info.target);
    }

    final timelineData = <shadcn.TimelineData>[
      for (var i = 0; i < visibleCommits.length; i++)
        _timelineDataForCommit(
          context,
          commit: visibleCommits[i],
          highlighted: currentIndex < 0 ? info.needsUpdate : i < currentIndex,
          currentOrBelow: currentIndex >= 0 && i >= currentIndex,
          current: i == currentIndex,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        shadcn.ComponentTheme(
          data: shadcn.TimelineTheme(
            timeConstraints: const BoxConstraints.tightFor(width: 0),
            spacing: 12,
            dotSize: 10,
            connectorThickness: 1.2,
            color: cs.border,
            rowGap: 10,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: shadcn.Timeline(data: timelineData),
          ),
        ),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 46, top: 4, bottom: 8),
            child: Text('还有 $hiddenCount 条远端记录').xSmall.muted,
          ),
        if (info.rawText != null &&
            info.rawText!.trim().isNotEmpty &&
            visibleCommits.isEmpty) ...[
          const SizedBox(height: 8),
          _RawLogBox(text: info.rawText!),
        ],
      ],
    );
  }

  int _displayCommitCount({
    required int total,
    required int currentIndex,
    required int maxCommitCount,
  }) {
    if (total <= maxCommitCount) return total;
    if (currentIndex < 0) return maxCommitCount;
    final countWithCurrentAndBelow = currentIndex + 4;
    if (countWithCurrentAndBelow > total) return total;
    return countWithCurrentAndBelow > maxCommitCount
        ? countWithCurrentAndBelow
        : maxCommitCount;
  }

  shadcn.TimelineData _timelineDataForCommit(
    BuildContext context, {
    required UpdateCommit commit,
    required bool highlighted,
    required bool currentOrBelow,
    required bool current,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final successColor = cs.chart2;
    final color = highlighted
        ? cs.primary
        : currentOrBelow
        ? successColor
        : cs.mutedForeground.withValues(alpha: 0.36);

    return shadcn.TimelineData(
      color: color,
      time: const SizedBox.shrink(),
      title: _CommitTimelineTitle(
        timeText: _timeTextForCommit(commit),
        author: commit.author,
        current: current,
        highlighted: highlighted,
        currentOrBelow: currentOrBelow,
      ),
      content: _CommitTimelineContent(
        message: commit.message,
        highlighted: highlighted,
        currentOrBelow: currentOrBelow,
      ),
    );
  }

  String _timeTextForCommit(UpdateCommit commit) {
    final date = commit.date?.trim();
    final parts = [
      if (date != null && date.isNotEmpty) date,
      if (commit.shortHash.isNotEmpty) commit.shortHash,
    ];
    return parts.isEmpty ? '远端' : parts.join('  ');
  }
}

class _CommitTimelineTitle extends StatelessWidget {
  final String timeText;
  final String? author;
  final bool current;
  final bool highlighted;
  final bool currentOrBelow;

  const _CommitTimelineTitle({
    required this.timeText,
    required this.author,
    required this.current,
    required this.highlighted,
    required this.currentOrBelow,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final authorText = author?.trim();
    final timeColor = highlighted
        ? cs.primary
        : currentOrBelow
        ? cs.chart2
        : cs.mutedForeground;
    final authorColor = currentOrBelow ? cs.chart2 : cs.mutedForeground;
    final time = Text(timeText, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: highlighted
                  ? time.xSmall.bold(color: timeColor)
                  : time.xSmall.medium(color: timeColor),
            ),
            if (highlighted) const SizedBox(width: 6),
            if (highlighted) const shadcn.PrimaryBadge(child: Text('待更新')),
            if (current) const SizedBox(width: 6),
            if (current) const shadcn.SecondaryBadge(child: Text('当前')),
          ],
        ),
        if (authorText != null && authorText.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            authorText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).xSmall.medium(color: authorColor),
        ],
      ],
    );
  }
}

class _CommitTimelineContent extends StatelessWidget {
  final String message;
  final bool highlighted;
  final bool currentOrBelow;

  const _CommitTimelineContent({
    required this.message,
    required this.highlighted,
    required this.currentOrBelow,
  });

  @override
  Widget build(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final content = Text(message, maxLines: 3, overflow: TextOverflow.ellipsis);
    final successColor = cs.chart2;

    return shadcn.Card(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      filled: currentOrBelow || highlighted,
      fillColor: currentOrBelow
          ? successColor.withValues(alpha: 0.08)
          : cs.primary.withValues(alpha: 0.06),
      borderColor: currentOrBelow
          ? successColor.withValues(alpha: 0.22)
          : highlighted
          ? cs.primary.withValues(alpha: 0.25)
          : null,
      child: highlighted
          ? content.small.semiBold
          : content.small.medium(color: successColor),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final UpdateLogInfo? info;

  const _StatusBadge({required this.info});

  @override
  Widget build(BuildContext context) {
    final hasUpdate = info?.hasUpdate;
    final text = info?.statusText ?? '待检查';

    if (hasUpdate == true) {
      return shadcn.PrimaryBadge(child: Text(text));
    }
    if (hasUpdate == false || text == '已是最新') {
      return shadcn.SecondaryBadge(
        style: _successBadgeStyle(context),
        child: Text(text),
      );
    }
    return shadcn.OutlineBadge(child: Text(text));
  }
}

shadcn.AbstractButtonStyle _successBadgeStyle(BuildContext context) {
  final successColor = shadcn.Theme.of(context).colorScheme.chart2;
  return const shadcn.ButtonStyle.secondary(
        size: shadcn.ButtonSize.small,
        density: shadcn.ButtonDensity.dense,
        shape: shadcn.ButtonShape.rectangle,
      )
      .withBackgroundColor(color: successColor.withValues(alpha: 0.10))
      .withForegroundColor(color: successColor)
      .withBorder(
        border: Border.all(
          color: successColor.withValues(alpha: 0.24),
          width: 0.5,
        ),
      );
}

class _ButtonContent extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ButtonContent({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon).iconSmall, const SizedBox(width: 6), Text(label)],
    );
  }
}

class _EmptyLog extends StatelessWidget {
  final UpdateTarget target;

  const _EmptyLog({required this.target});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(12),
        child: Text('${target.title}暂无更新记录').small.muted,
      ),
    );
  }
}

class _RawLogBox extends StatelessWidget {
  final String text;

  const _RawLogBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppSurfaceCard(
        padding: const EdgeInsets.all(8),
        child: Text(
          text.trim(),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
        ).xSmall.muted,
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String text;
  final bool destructive;

  const _MessageBox({required this.text, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final content = Text(
      text,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    ).small;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: destructive
          ? shadcn.Alert.destructive(content: content)
          : shadcn.Alert(
              content: Text(
                text,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ).small.muted,
            ),
    );
  }
}

Future<void> _runUpgrade(
  BuildContext context,
  WidgetRef ref,
  UpgradeAction action,
) async {
  final confirmed = await _confirmUpdate(context, action);
  if (!confirmed) return;

  final success = await ref.read(updateProvider.notifier).runUpdate(action);
  if (success) {
    Toast.success('${action.label}命令执行完成');
  } else {
    Toast.error('${action.label}失败');
  }
}

Future<bool> _confirmUpdate(BuildContext context, UpgradeAction action) async {
  final result = await shadcn.showDialog<bool>(
    context: context,
    builder: (ctx) => shadcn.AlertDialog(
      leading: const Icon(
        shadcn.LucideIcons.download,
      ).iconSmall.iconMutedForeground,
      title: Text(action.label),
      content: SizedBox(
        width: 360,
        child: Text('将调用后端升级接口执行 ${action.tag}。升级过程中服务可能会短暂不可用。').small.muted,
      ),
      actions: [
        shadcn.Button.outline(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('取消'),
        ),
        shadcn.Button.primary(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('确认执行'),
        ),
      ],
    ),
  );
  return result ?? false;
}
