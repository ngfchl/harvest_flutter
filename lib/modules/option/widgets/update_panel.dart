import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/update_log_model.dart';
import '../provider/update_provider.dart';

class UpdateSummaryCard extends ConsumerWidget {
  final VoidCallback onOpen;

  const UpdateSummaryCard({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    final cs = FTheme.of(context).colors;
    final hasUpdate = state.hasAnyUpdate;
    final color = hasUpdate
        ? const Color(0xFFF59E0B)
        : cs.foreground.withOpacity(0.55);
    final summary = state.hasAnyUpdate
        ? (state.updateCount > 0 ? '发现 ${state.updateCount} 条更新' : '发现可用更新')
        : state.isLoading
        ? '正在检查更新'
        : state.allLatest
        ? '当前已是最新版本'
        : '点击查看更新状态';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: hasUpdate ? color.withOpacity(0.08) : cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasUpdate ? color.withOpacity(0.35) : cs.border,
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    hasUpdate ? FIcons.circleAlert : FIcons.refreshCw,
                    size: 18,
                    color: color,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '程序更新',
                          style: TextStyle(
                            color: cs.foreground,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.foreground.withOpacity(0.48),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.foreground.withOpacity(0.45),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: cs.foreground.withOpacity(0.3),
                    ),
                ],
              ),
            ),
          ),
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
          icon: FIcons.package,
          isLoading: state.isBackendLoading,
          maxCommitCount: maxCommitCount,
        ),
        const SizedBox(height: 8),
        _UpdateTargetCard(
          info: state.sites,
          target: UpdateTarget.sites,
          icon: FIcons.fileText,
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
    final cs = FTheme.of(context).colors;
    final color = state.hasAnyUpdate
        ? const Color(0xFFF59E0B)
        : cs.foreground.withOpacity(0.6);
    final summary = state.hasAnyUpdate
        ? (state.updateCount > 0 ? '发现 ${state.updateCount} 条待更新记录' : '发现可用更新')
        : state.allLatest
        ? '后端代码和站点配置均为最新'
        : state.isLoading
        ? '正在检查更新'
        : '更新状态未知';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: state.hasAnyUpdate ? color.withOpacity(0.08) : cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: state.hasAnyUpdate ? color.withOpacity(0.35) : cs.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            state.hasAnyUpdate ? FIcons.circleAlert : FIcons.refreshCw,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '程序更新',
                  style: TextStyle(
                    color: cs.foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
                  style: TextStyle(
                    color: cs.foreground.withOpacity(0.52),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: '检查全部',
            icon: state.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.foreground.withOpacity(0.5),
                    ),
                  )
                : Icon(
                    FIcons.refreshCw,
                    size: 17,
                    color: cs.foreground.withOpacity(0.65),
                  ),
            onPressed: state.isLoading || state.isUpdating
                ? null
                : () => ref.read(updateProvider.notifier).refresh(),
          ),
        ],
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
    final cs = FTheme.of(context).colors;
    final state = ref.watch(updateProvider);
    final current = info;
    final action = target.upgradeAction;
    final isUpdating = state.updatingAction == action;
    final canUpdate =
        current?.needsUpdate == true && !isLoading && !state.isUpdating;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: current?.needsUpdate == true
              ? const Color(0xFFF59E0B).withOpacity(0.35)
              : cs.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.foreground.withOpacity(0.62)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      target.title,
                      style: TextStyle(
                        color: cs.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      current?.detailText ??
                          (isLoading ? '正在获取更新日志' : '还未获取更新日志'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.foreground.withOpacity(0.48),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.foreground.withOpacity(0.45),
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
              child: Center(child: FProgress.circularIcon()),
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
                child: FButton(
                  style: FButtonStyle.outline(_compactUpdateButtonStyle),
                  onPress: isLoading || state.isUpdating
                      ? null
                      : () => ref
                            .read(updateProvider.notifier)
                            .refreshTarget(target),
                  child: const _ButtonContent(
                    icon: FIcons.refreshCw,
                    label: '检查',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FButton(
                  style: FButtonStyle.primary(_compactUpdateButtonStyle),
                  onPress: canUpdate
                      ? () => _runUpgrade(context, ref, action)
                      : null,
                  child: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : _ButtonContent(
                          icon: FIcons.download,
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
    );
  }
}

class _GlobalActions extends ConsumerWidget {
  final UpdateState state;

  const _GlobalActions({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: FTheme.of(context).colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FTheme.of(context).colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '批量操作',
            style: TextStyle(
              color: FTheme.of(context).colors.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FButton(
                  style: FButtonStyle.primary(_compactUpdateButtonStyle),
                  onPress: state.isUpdating
                      ? null
                      : () => _runUpgrade(context, ref, UpgradeAction.all),
                  child: state.updatingAction == UpgradeAction.all
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const _ButtonContent(
                          icon: FIcons.download,
                          label: '更新所有',
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FButton(
                  style: FButtonStyle.outline(_compactUpdateButtonStyle),
                  onPress: state.isUpdating
                      ? null
                      : () => _runUpgrade(context, ref, UpgradeAction.webui),
                  child: state.updatingAction == UpgradeAction.webui
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const _ButtonContent(
                          icon: FIcons.download,
                          label: '更新WEBUI',
                        ),
                ),
              ),
            ],
          ),
        ],
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < visibleCommits.length; i++)
          _CommitLine(
            commit: visibleCommits[i],
            highlighted: currentIndex < 0 ? info.needsUpdate : i < currentIndex,
            currentOrBelow: currentIndex >= 0 && i >= currentIndex,
            current: i == currentIndex,
            isLast: hiddenCount <= 0 && i == visibleCommits.length - 1,
          ),
        if (hiddenCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 19, bottom: 8),
            child: Text(
              '还有 $hiddenCount 条远端记录',
              style: TextStyle(
                color: FTheme.of(context).colors.foreground.withOpacity(0.35),
                fontSize: 11,
              ),
            ),
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
}

class _CommitLine extends StatelessWidget {
  final UpdateCommit commit;
  final bool highlighted;
  final bool currentOrBelow;
  final bool current;
  final bool isLast;

  const _CommitLine({
    required this.commit,
    this.highlighted = false,
    this.currentOrBelow = false,
    this.current = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final accent = current
        ? const Color(0xFF10B981)
        : currentOrBelow
        ? const Color(0xFF10B981)
        : highlighted
        ? const Color(0xFFF59E0B)
        : cs.foreground.withOpacity(0.45);
    final meta = [
      commit.date,
      commit.author,
    ].whereType<String>().where((text) => text.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: highlighted || current
                      ? [
                          BoxShadow(
                            color: accent.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 34,
                  color: currentOrBelow
                      ? const Color(0xFF10B981).withOpacity(0.45)
                      : highlighted
                      ? const Color(0xFFF59E0B).withOpacity(0.45)
                      : cs.border,
                ),
            ],
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: currentOrBelow
                    ? accent.withOpacity(0.08)
                    : highlighted
                    ? accent.withOpacity(0.08)
                    : cs.foreground.withOpacity(0.03),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentOrBelow
                      ? accent.withOpacity(0.25)
                      : highlighted
                      ? accent.withOpacity(0.25)
                      : cs.border.withOpacity(0.7),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (commit.shortHash.isNotEmpty) ...[
                        Text(
                          commit.shortHash,
                          style: TextStyle(
                            color: current ? const Color(0xFF10B981) : accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (current)
                        _MiniBadge(text: '当前', color: accent)
                      else if (highlighted)
                        _MiniBadge(text: '待更新', color: accent),
                    ],
                  ),
                  if (commit.shortHash.isNotEmpty || current || highlighted)
                    const SizedBox(height: 4),
                  Text(
                    commit.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.foreground.withOpacity(0.78),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.foreground.withOpacity(0.36),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final UpdateLogInfo? info;

  const _StatusBadge({required this.info});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final hasUpdate = info?.hasUpdate;
    final color = hasUpdate == true
        ? const Color(0xFFF59E0B)
        : hasUpdate == false
        ? const Color(0xFF10B981)
        : cs.foreground.withOpacity(0.45);
    final text = info?.statusText ?? '待检查';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
      children: [Icon(icon, size: 15), const SizedBox(width: 6), Text(label)],
    );
  }
}

class _EmptyLog extends StatelessWidget {
  final UpdateTarget target;

  const _EmptyLog({required this.target});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.foreground.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${target.title}暂无更新记录',
        style: TextStyle(color: cs.foreground.withOpacity(0.42), fontSize: 12),
      ),
    );
  }
}

class _RawLogBox extends StatelessWidget {
  final String text;

  const _RawLogBox({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.foreground.withOpacity(0.04),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.trim(),
        maxLines: 8,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: cs.foreground.withOpacity(0.58),
          fontSize: 11,
          height: 1.35,
        ),
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
    final cs = FTheme.of(context).colors;
    final color = destructive ? cs.destructive : cs.foreground;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(destructive ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(8),
        border: destructive
            ? Border.all(color: color.withOpacity(0.18), width: 0.5)
            : null,
      ),
      child: Text(
        text,
        maxLines: 6,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color.withOpacity(destructive ? 0.9 : 0.58),
          fontSize: 12,
          height: 1.35,
        ),
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
  final cs = FTheme.of(context).colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: cs.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FIcons.download,
                  size: 19,
                  color: cs.foreground.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    action.label,
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '将调用后端升级接口执行 ${action.tag}。升级过程中服务可能会短暂不可用。',
              style: TextStyle(
                color: cs.foreground.withOpacity(0.65),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FButton(
                    style: FButtonStyle.outline(),
                    onPress: () => Navigator.pop(ctx, false),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FButton(
                    onPress: () => Navigator.pop(ctx, true),
                    child: const Text('确认执行'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

FButtonStyle _compactUpdateButtonStyle(FButtonStyle style) {
  return style.copyWith(
    contentStyle: (content) => content.copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
  );
}
