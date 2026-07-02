import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_theme.dart';

// ═══════════════════════════════════════════════════
//  公共入口
// ═══════════════════════════════════════════════════

void openLevelInfo(BuildContext context, {required SiteInfo site}) {
  if (context.isMobile) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollCtrl) =>
            _LevelInfoSheet(site: site, scrollController: scrollCtrl),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (dialogContext) {
        final media = MediaQuery.of(dialogContext);
        final availableHeight = media.size.height - media.padding.vertical - 64;
        final maxHeight = availableHeight.clamp(360.0, 760.0).toDouble();
        final cs = shadcn.Theme.of(dialogContext).colorScheme;

        return Dialog(
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          backgroundColor: cs.background,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: siteRadius(dialogContext, size: "lg"),
            side: BorderSide(color: cs.border.withValues(alpha: 0.65)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
            child: _LevelInfoSheet(site: site),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════
//  Sheet
// ═══════════════════════════════════════════════════

class _LevelInfoSheet extends ConsumerStatefulWidget {
  final SiteInfo site;
  final ScrollController? scrollController;

  const _LevelInfoSheet({required this.site, this.scrollController});

  @override
  ConsumerState<_LevelInfoSheet> createState() => _LevelInfoSheetState();
}

class _LevelInfoSheetState extends ConsumerState<_LevelInfoSheet>
    with SingleTickerProviderStateMixin {
  String? _expandedLevelName;
  late final AnimationController _milestoneController;

  @override
  void initState() {
    super.initState();
    _milestoneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _milestoneController.dispose();
    super.dispose();
  }

  Color _levelColorForEntry(
    MapEntry<String, SiteLevel> entry, {
    List<WebSite> allConfigs = const [],
  }) {
    final level = entry.value.level.trim();
    final localKey = level.isNotEmpty ? level : entry.key;
    if (entry.value.levelId == 0) return levelColor(localKey);
    final npConfig = allConfigs.firstWhereOrNull(
      (c) => c.name == 'NP模板',
    );
    if (npConfig != null) {
      final npEntry = npConfig.level.entries.firstWhereOrNull(
        (e) => e.value.levelId == entry.value.levelId,
      );
      if (npEntry != null) {
        final npKey = npEntry.value.level.trim();
        if (npKey.isNotEmpty) return levelColor(npKey);
      }
    }
    return levelColor(localKey);
  }

  Color _levelColorForText(
    String text,
    List<MapEntry<String, SiteLevel>> levels, {
    List<WebSite> allConfigs = const [],
  }) {
    final current = text.trim();
    final entry = levels.firstWhereOrNull(
      (e) =>
          e.key == current ||
          e.value.displayName == current ||
          e.value.name == current ||
          e.value.level == current,
    );
    if (entry != null) return _levelColorForEntry(entry, allConfigs: allConfigs);
    return levelColor(current);
  }

  @override
  Widget build(BuildContext context) {
    final configs = ref.watch(websiteListProvider).value ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == widget.site.site);
    final status = widget.site.latestStatus;

    // ── 等级列表（按 levelId 降序，排除 VIP(levelId==0)，高等级在上） ──
    final levelMap = config?.level ?? <String, SiteLevel>{};
    final levels = levelMap.entries.where((e) => e.value.levelId != 0).toList()
      ..sort((a, b) {
        final aid = a.value.levelId;
        final bid = b.value.levelId;
        if (aid == 0 && bid != 0) return -1;
        if (bid == 0 && aid != 0) return 1;
        return bid.compareTo(aid);
      });

    // ── 定位当前等级 ──
    final currentName = status?.myLevel ?? '';
    final currentIdx = levels.indexWhere(
      (e) =>
          e.key == currentName ||
          e.value.displayName == currentName ||
          e.value.level == currentName,
    );
    final hasNext = currentIdx > 0;
    final nextEntry = hasNext ? levels[currentIdx - 1] : null;

    final cs = shadcn.Theme.of(context).colorScheme;
    final currentLevelColor = _levelColorForText(
      currentName,
      levels,
      allConfigs: configs,
    );

    // ── 保号/毕业里程碑 ──
    final milestone = _siteLevelMilestone(config, status);

    // ── Header 显示 name(level) ──
    final headerBadge = _buildHeaderBadge(
      context,
      currentName,
      levels,
      currentLevelColor,
      allConfigs: configs,
    );

    // ── Header ──
    final header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.background,
        border: Border(bottom: BorderSide(color: cs.border, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => closeAppSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                shadcn.LucideIcons.arrowLeft,
                size: 20,
                color: cs.foreground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '等级信息 · ${widget.site.site}',
              style: TextStyle(
                color: cs.foreground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 当前等级徽章
          if (status != null && status.myLevel.isNotEmpty) headerBadge,
        ],
      ),
    );

    // ── 内容 ──
    final content = ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      children: [
        // ── 里程碑标志 ──
        if (milestone != null) ...[
          _milestoneBanner(context, milestone),
          const SizedBox(height: 14),
        ],

        // ── 无配置 ──
        if (levels.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                '暂无等级配置',
                style: TextStyle(fontSize: 14, color: cs.mutedForeground),
              ),
            ),
          ),

        // ── 等级列表 ──
        if (levels.isNotEmpty)
          _buildUnifiedLevels(
            context,
            levels,
            currentName,
            status,
            nextEntry,
            allConfigs: configs,
          ),
      ],
    );

    return PopScope(
      canPop: true,
      child: Material(
        color: cs.background,
        child: Column(
          children: [
            header,
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  // ────────────── 统一等级列表 ──────────────

  Widget _buildUnifiedLevels(
    BuildContext context,
    List<MapEntry<String, SiteLevel>> levels,
    String currentName,
    SiteDailyStatus? status,
    MapEntry<String, SiteLevel>? nextEntry, {
    List<WebSite> allConfigs = const [],
  }) {
    final currentIdx = levels.indexWhere(
      (e) =>
          e.key == currentName ||
          e.value.displayName == currentName ||
          e.value.level == currentName,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: shadcn.Theme.of(
            context,
          ).colorScheme.border.withValues(alpha: 0.4),
        ),
        borderRadius: siteRadius(context, size: "md"),
      ),
      child: ClipRRect(
        borderRadius: siteRadius(context, size: "md"),
        child: Column(
          children: List.generate(levels.length, (i) {
            final entry = levels[i];
            final name = entry.value.displayName.isNotEmpty
                ? entry.value.displayName
                : entry.key;
            final lv = entry.value;
            final isVip = lv.levelId == 0;
            final isCurrent =
                entry.key == currentName ||
                lv.displayName == currentName ||
                lv.level == currentName;
            final isNext = nextEntry?.key == entry.key;
            final isBelowCurrent = currentIdx >= 0 && i > currentIdx;
            final canShowProgress = status != null && !isVip;
            final isExpanded =
                canShowProgress &&
                (_expandedLevelName == name ||
                    (isNext && _expandedLevelName == null));
            final color = _levelColorForEntry(entry, allConfigs: allConfigs);
            final isLast = i == levels.length - 1;
            final nextNewRights = <String>[];
            if (isNext && currentIdx >= 0) {
              final currentRights = <String>[];
              for (var j = currentIdx; j < levels.length; j++) {
                final r = levels[j].value.rights;
                if (_hasEffectiveRight(r)) currentRights.add(r.trim());
              }
              final r = lv.rights;
              final right = r.trim();
              if (_hasEffectiveRight(right) && !currentRights.contains(right)) {
                nextNewRights.add(right);
              }
            }

            return InkWell(
              onTap: canShowProgress
                  ? () => setState(() {
                      _expandedLevelName = _expandedLevelName == name
                          ? null
                          : name;
                    })
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? color.withValues(alpha: 0.08)
                      : isExpanded
                      ? color.withValues(alpha: 0.045)
                      : isNext
                      ? shadcn.Theme.of(
                          context,
                        ).colorScheme.muted.withValues(alpha: 0.08)
                      : null,
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: shadcn.Theme.of(
                              context,
                            ).colorScheme.border.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 等级标题行 ──
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: siteRadius(context, size: "xs"),
                            ),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (canShowProgress)
                            Icon(
                              isExpanded
                                  ? shadcn.LucideIcons.chevronDown
                                  : shadcn.LucideIcons.chevronRight,
                              size: 14,
                              color: shadcn.Theme.of(
                                context,
                              ).colorScheme.mutedForeground,
                            ),
                          if (canShowProgress) const SizedBox(width: 6),
                          if (isCurrent)
                            _statusTag(context, '当前', color, true)
                          else if (isNext)
                            _statusTag(
                              context,
                              '下一个',
                              siteWarning(context),
                              false,
                            )
                          else if (isBelowCurrent)
                            _statusTag(
                              context,
                              '已解锁',
                              siteSuccess(context),
                              false,
                            )
                          else if (currentIdx >= 0 && i < currentIdx)
                            _statusTag(
                              context,
                              '未解锁',
                              shadcn.Theme.of(context)
                                  .colorScheme
                                  .mutedForeground
                                  .withValues(alpha: 0.4),
                              false,
                            ),

                          const SizedBox(width: 8),
                          if (isVip)
                            _statusTag(
                              context,
                              '无需求',
                              siteWarning(context),
                              false,
                            )
                          else
                            Flexible(
                              child: shadcn.Tooltip(
                                tooltip: (_) => Text(_levelSummary(lv)),
                                child: Text(
                                  _levelSummary(lv),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: shadcn.Theme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _levelIdentityRow(
                        context,
                        entry,
                        allConfigs: allConfigs,
                      ),

                      // ── 下一等级的详细进度 ──
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        _buildProgressSection(context, status, lv),
                      ],

                      // ── 下一个等级可新增获得的权利 ──
                      if (nextNewRights.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildNextRights(context, nextNewRights, color),
                      ],

                      // ── 当前等级的权利 ──
                      if (isCurrent && currentIdx >= 0) ...[
                        const SizedBox(height: 8),
                        _buildCurrentRights(context, levels, currentIdx),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _levelIdentityRow(
    BuildContext context,
    MapEntry<String, SiteLevel> entry, {
    List<WebSite> allConfigs = const [],
  }) {
    final lv = entry.value;
    final displayName = lv.displayName.isNotEmpty ? lv.displayName : entry.key;
    final name = lv.name.trim().isNotEmpty ? lv.name.trim() : displayName;
    final level = lv.level.trim().isNotEmpty ? lv.level.trim() : entry.key;
    final cs = shadcn.Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _levelMetaChip(context, '等级名称', name, cs.foreground),
        _levelMetaChip(
          context,
          '等级字段',
          level,
          _levelColorForEntry(entry, allConfigs: allConfigs),
        ),
      ],
    );
  }

  Widget _levelMetaChip(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.16),
        borderRadius: siteRadius(context, size: "xs"),
        border: Border.all(
          color: cs.border.withValues(alpha: 0.28),
          width: 0.6,
        ),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          color: cs.mutedForeground,
          fontWeight: FontWeight.w500,
          height: 1.15,
        ),
      ),
    );
  }

  Widget _statusTag(BuildContext context, String text, Color color, bool bold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: siteRadius(context, size: "xs"),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    SiteDailyStatus status,
    SiteLevel nextLevel,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final cfgUp = parseSize(nextLevel.uploaded);
    final cfgDl = parseSize(nextLevel.downloaded);
    final ratio = nextLevel.ratio;

    num requiredUp;
    if (cfgUp > 0) {
      requiredUp = cfgUp;
    } else if (cfgDl > 0 && ratio > 0) {
      final effectiveDl = status.downloaded >= cfgDl
          ? status.downloaded
          : cfgDl;
      requiredUp = (effectiveDl * ratio).round();
    } else {
      requiredUp = 0;
    }

    final progressItems = <Widget>[];
    void addProgressItem(Widget item) {
      if (progressItems.isNotEmpty) {
        progressItems.add(const SizedBox(height: 8));
      }
      progressItems.add(item);
    }

    if (requiredUp > 0) {
      addProgressItem(
        _progressItem(
          context,
          '上传量',
          status.uploaded,
          requiredUp,
          (v) => fmtBytes(v.toInt()),
        ),
      );
    }
    if (cfgDl > 0) {
      addProgressItem(
        _progressItem(
          context,
          '下载量',
          status.downloaded,
          cfgDl,
          (v) => fmtBytes(v.toInt()),
        ),
      );
    }
    if (nextLevel.score > 0) {
      addProgressItem(
        _progressItem(
          context,
          '做种积分',
          status.myScore,
          nextLevel.score,
          (v) => fmtCompact(v.toDouble()),
        ),
      );
    }
    if (nextLevel.bonus > 0) {
      addProgressItem(
        _progressItem(
          context,
          '魔力值',
          status.myBonus,
          nextLevel.bonus,
          (v) => fmtCompact(v.toDouble()),
        ),
      );
    }
    if (nextLevel.torrents > 0) {
      addProgressItem(
        _progressItem(
          context,
          '发种数',
          status.publish,
          nextLevel.torrents,
          (v) => '$v',
        ),
      );
    }
    if (nextLevel.days > 0) {
      addProgressItem(_timeItem(context, nextLevel.days));
    }
    if (nextLevel.ratio > 0) {
      addProgressItem(_ratioItem(context, status.ratio, nextLevel.ratio));
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.15),
        borderRadius: siteRadius(context, size: "md"),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '升级条件',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.foreground.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          ...progressItems,
        ],
      ),
    );
  }

  Widget _buildCurrentRights(
    BuildContext context,
    List<MapEntry<String, SiteLevel>> levels,
    int currentIdx,
  ) {
    final rights = <String>[];
    for (var i = currentIdx; i < levels.length; i++) {
      final r = levels[i].value.rights;
      if (_hasEffectiveRight(r)) rights.add(r.trim());
    }
    if (rights.isEmpty) return const SizedBox.shrink();
    final cs = shadcn.Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已享权利',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.foreground.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        ..._buildRightsRows(context, rights, siteSuccess(context)),
      ],
    );
  }

  Widget _buildNextRights(
    BuildContext context,
    List<String> rights,
    Color levelColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.07),
        borderRadius: siteRadius(context, size: "sm"),
        border: Border.all(color: levelColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '即将获得新增权利',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: levelColor,
            ),
          ),
          const SizedBox(height: 6),
          ..._buildRightsRows(context, rights, levelColor),
        ],
      ),
    );
  }

  // ────────────── 进度条 ──────────────

  Widget _progressItem(
    BuildContext context,
    String label,
    num current,
    num required,
    String Function(num) fmt,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final met = current >= required;
    final ratio = required > 0 ? (current / required).clamp(0.0, 1.0) : 1.0;
    final barColor = met ? siteSuccess(context) : siteWarning(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: cs.mutedForeground),
            ),
            const Spacer(),
            Text(
              '${fmt(current)} / ${fmt(required)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: met ? cs.foreground : siteWarning(context),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              size: 13,
              color: met ? siteSuccess(context) : siteWarning(context),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: cs.muted.withValues(alpha: 0.4),
            borderRadius: siteRadius(context, size: "xs"),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: siteRadius(context, size: "xs"),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────── 时间要求 ──────────────

  Widget _timeItem(BuildContext context, int requiredWeeks) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final durationText = widget.site.durationText;
    final currentWeeks = _parseDurationWeeks(durationText);
    final met = currentWeeks >= requiredWeeks;

    return Row(
      children: [
        Text('注册时长', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
        const Spacer(),
        Text(
          '$durationText / $requiredWeeks周',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: met ? cs.foreground : siteWarning(context),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 13,
          color: met ? siteSuccess(context) : siteWarning(context),
        ),
      ],
    );
  }

  int _parseDurationWeeks(String text) {
    final m = RegExp(r'(\d+)周(\d+)天').firstMatch(text);
    if (m != null) return int.parse(m.group(1)!);
    final m2 = RegExp(r'(\d+)周').firstMatch(text);
    if (m2 != null) return int.parse(m2.group(1)!);
    return 0;
  }

  // ────────────── 分享率要求 ──────────────

  Widget _ratioItem(BuildContext context, double current, double required) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final met = current >= required;
    return Row(
      children: [
        Text('分享率', style: TextStyle(fontSize: 11, color: cs.mutedForeground)),
        const Spacer(),
        Text(
          '${current.toStringAsFixed(2)} / ${required.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: met ? cs.foreground : siteWarning(context),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 13,
          color: met ? siteSuccess(context) : siteWarning(context),
        ),
      ],
    );
  }

  // ────────────── 权利列表 ──────────────

  List<Widget> _buildRightsRows(
    BuildContext context,
    List<String> rights,
    Color markerColor,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return rights
        .map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: markerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    r,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.foreground.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  // ────────────── 工具 ──────────────

  String _levelSummary(SiteLevel lv) {
    if (lv.levelId == 0) return '无需求';
    final parts = <String>[];
    if (lv.days > 0) parts.add('${lv.days}周');
    final dl = parseSize(lv.downloaded);
    final cfgUp = parseSize(lv.uploaded);

    num requiredUp;
    if (cfgUp > 0) {
      requiredUp = cfgUp;
    } else if (dl > 0 && lv.ratio > 0) {
      requiredUp = (dl * lv.ratio).round();
    } else {
      requiredUp = 0;
    }

    if (requiredUp > 0) parts.add('↑${fmtBytes(requiredUp.toInt())}');
    if (dl > 0) parts.add('↓${fmtBytes(dl)}');
    if (lv.score > 0) parts.add('做种积分${fmtCompact(lv.score.toDouble())}');
    if (lv.bonus > 0) parts.add('魔力${fmtCompact(lv.bonus)}');
    if (lv.torrents > 0) parts.add('发种${lv.torrents}');
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  bool _hasEffectiveRight(String value) {
    final right = value.trim();
    return right.isNotEmpty && right != '无' && right != '同上';
  }

  // ────────────── Header 徽章 name(level) ──────────────

  Widget _buildHeaderBadge(
    BuildContext context,
    String currentName,
    List<MapEntry<String, SiteLevel>> levels,
    Color fallbackColor, {
    List<WebSite> allConfigs = const [],
  }) {
    final entry = levels.firstWhereOrNull(
      (e) =>
          e.key == currentName ||
          e.value.displayName == currentName ||
          e.value.name == currentName ||
          e.value.level == currentName,
    );
    final lv = entry?.value;
    final name = lv?.displayName.isNotEmpty == true
        ? lv!.displayName
        : currentName;
    final levelText = lv?.level.trim() ?? '';
    final display = levelText.isNotEmpty ? '$name($levelText)' : name;
    final color = entry != null
        ? _levelColorForEntry(entry, allConfigs: allConfigs)
        : fallbackColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: siteRadius(context, size: "xs"),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ────────────── 里程碑横幅 ──────────────

  Widget _milestoneBanner(BuildContext context, dynamic milestone) {
    final isGraduation = milestone == 'graduation';
    final label = isGraduation ? '毕业' : '保号';
    final icon = isGraduation
        ? Icons.school_outlined
        : Icons.verified_user_outlined;
    final color = isGraduation ? siteWarning(context) : siteSuccess(context);

    return AnimatedBuilder(
      animation: _milestoneController,
      builder: (context, child) {
        final pulse = (_milestoneController.value * 0.15).clamp(0.0, 0.15);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGraduation
                    ? [
                        siteWarning(context).withValues(alpha: 0.10 + pulse),
                        siteAccent(
                          context,
                          4,
                        ).withValues(alpha: 0.06 + pulse * 0.5),
                        siteWarning(context).withValues(alpha: 0.10 + pulse),
                      ]
                    : [
                        siteSuccess(context).withValues(alpha: 0.10 + pulse),
                        siteInfo(context).withValues(alpha: 0.06 + pulse * 0.5),
                        siteSuccess(context).withValues(alpha: 0.10 + pulse),
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: siteRadius(context, size: "md"),
              border: Border.all(
                color: color.withValues(alpha: 0.25 + pulse),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12 + pulse),
                  blurRadius: 16 + pulse * 40,
                  spreadRadius: 2 + pulse * 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Text(
                  '🎉 恭喜！已达到 $label 等级',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: color, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }

  // ────────────── 里程碑类型判断 ──────────────

  String? _siteLevelMilestone(WebSite? config, SiteDailyStatus? status) {
    if (config == null || status == null || status.myLevel.trim().isEmpty) {
      return null;
    }
    final currentName = status.myLevel.trim();
    final levelMap = config.level;
    if (levelMap.isEmpty) return null;

    MapEntry<String, SiteLevel>? currentEntry;
    for (final entry in levelMap.entries) {
      if (entry.key == currentName ||
          entry.value.displayName == currentName ||
          entry.value.level == currentName) {
        currentEntry = entry;
        break;
      }
    }
    if (currentEntry == null) return null;

    final currentId = currentEntry.value.levelId;
    final achievedLevels = levelMap.entries
        .where((entry) {
          final levelId = entry.value.levelId;
          if (currentId > 0 && levelId > 0) return levelId <= currentId;
          return entry.key == currentEntry?.key;
        })
        .map((entry) => entry.value)
        .toList();

    if (achievedLevels.any((level) => level.graduation)) {
      return 'graduation';
    }
    if (achievedLevels.any((level) => level.keepAccount)) {
      return 'keepAccount';
    }
    return null;
  }
}
