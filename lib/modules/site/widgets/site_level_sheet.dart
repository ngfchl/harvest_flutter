import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_provider.dart';

// ═══════════════════════════════════════════════════
//  公共入口
// ═══════════════════════════════════════════════════

void openLevelInfo(BuildContext context, {required SiteInfo site}) {
  if (context.isMobile) {
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 1,
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
    showFSheet(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 1,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 700),
          child: _LevelInfoSheet(site: site),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════
//  Sheet
// ═══════════════════════════════════════════════════

class _LevelInfoSheet extends ConsumerWidget {
  final SiteInfo site;
  final ScrollController? scrollController;

  const _LevelInfoSheet({required this.site, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final status = site.latestStatus;

    // ── 等级列表（按 levelId 降序，高等级在上） ──
    final levelMap = config?.level ?? <String, SiteLevel>{};
    final levels = levelMap.entries.toList()
      ..sort((a, b) {
        final aid = a.value.levelId;
        final bid = b.value.levelId;
        if (aid == 0 && bid != 0) return -1;
        if (bid == 0 && aid != 0) return 1;
        return bid.compareTo(aid);
      });

    // ── 定位当前等级 ──
    final currentName = status?.myLevel ?? '';
    final currentIdx = levels.indexWhere((e) => e.key == currentName);
    final hasNext = currentIdx > 0;
    final nextEntry = hasNext ? levels[currentIdx - 1] : null;

    final cs = FTheme.of(context).colors;

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
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(FIcons.arrowLeft, size: 20, color: cs.foreground),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '等级信息 · ${site.site}',
              style: TextStyle(
                color: cs.foreground,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // 当前等级徽章
          if (status != null && status.myLevel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: levelColor(status.myLevel).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                status.myLevel,
                style: TextStyle(
                  color: levelColor(status.myLevel),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );

    // ── 内容 ──
    final content = ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      children: [
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

        // ── 统一等级列表 ──
        if (levels.isNotEmpty) ...[
          _sectionTitle(context, '等级体系'),
          _buildUnifiedLevels(context, levels, currentName, status, nextEntry),
        ],
      ],
    );

    return PopScope(
      canPop: true,
      child: FScaffold(header: header, childPad: false, child: content),
    );
  }

  // ────────────── 统一等级列表 ──────────────

  Widget _buildUnifiedLevels(
    BuildContext context,
    List<MapEntry<String, SiteLevel>> levels,
    String currentName,
    SiteDailyStatus? status,
    MapEntry<String, SiteLevel>? nextEntry,
  ) {
    final currentIdx = levels.indexWhere((e) => e.key == currentName);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.theme.colors.border.withValues(alpha: 0.4),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: List.generate(levels.length, (i) {
            final entry = levels[i];
            final name = entry.key;
            final lv = entry.value;
            final isVip = lv.levelId == 0;
            final isCurrent = name == currentName;
            final isNext = nextEntry?.key == name;
            final isBelowCurrent = currentIdx >= 0 && i > currentIdx;
            final color = levelColor(name);
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

            return Container(
              decoration: BoxDecoration(
                color: isCurrent
                    ? color.withValues(alpha: 0.08)
                    : isNext
                    ? context.theme.colors.muted.withValues(alpha: 0.08)
                    : null,
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: context.theme.colors.border.withValues(
                            alpha: 0.2,
                          ),
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
                            borderRadius: BorderRadius.circular(5),
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
                        if (isCurrent)
                          _statusTag('当前', color, true)
                        else if (isNext)
                          _statusTag('下一个', Colors.orange, false)
                        else if (isBelowCurrent)
                          _statusTag('已解锁', Colors.green, false)
                        else if (currentIdx >= 0 && i < currentIdx)
                          _statusTag(
                            '未解锁',
                            context.theme.colors.mutedForeground.withOpacity(
                              0.4,
                            ),
                            false,
                          ),

                        const SizedBox(width: 8),
                        if (isVip)
                          _statusTag('无需求', Colors.amber, false)
                        else
                          Flexible(
                            child: FTooltip(
                              tipBuilder: (_, _) => Text(_levelSummary(lv)),
                              child: Text(
                                _levelSummary(lv),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // ── VIP 说明 ──
                    if (isVip) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isCurrent ? 'VIP 等级，享有全部权限' : 'VIP 等级，可享有全部权限',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── 下一等级的详细进度（VIP 不显示） ──
                    if (isNext && status != null && !isVip) ...[
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
            );
          }),
        ),
      ),
    );
  }

  Widget _statusTag(String text, Color color, bool bold) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
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
      if (progressItems.isNotEmpty)
        progressItems.add(const SizedBox(height: 8));
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
          '做种数',
          status.seed,
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
        color: context.theme.colors.muted.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '升级进度',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.theme.colors.foreground.withValues(alpha: 0.7),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已享权利',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.theme.colors.foreground.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        ..._buildRightsRows(context, rights, Colors.green),
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
        borderRadius: BorderRadius.circular(6),
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

  // ────────────── 小标题 ──────────────

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.theme.colors.foreground,
        ),
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
    final met = current >= required;
    final ratio = required > 0 ? (current / required).clamp(0.0, 1.0) : 1.0;
    final barColor = met ? Colors.green : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const Spacer(),
            Text(
              '${fmt(current)} / ${fmt(required)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: met
                    ? context.theme.colors.foreground
                    : Colors.orange.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              size: 13,
              color: met ? Colors.green : Colors.orange.shade700,
            ),
          ],
        ),
        const SizedBox(height: 3),
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: context.theme.colors.muted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────── 时间要求 ──────────────

  Widget _timeItem(BuildContext context, int requiredWeeks) {
    final durationText = site.durationText;
    final currentWeeks = _parseDurationWeeks(durationText);
    final met = currentWeeks >= requiredWeeks;

    return Row(
      children: [
        Text(
          '注册时长',
          style: TextStyle(
            fontSize: 11,
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Spacer(),
        Text(
          '$durationText / $requiredWeeks周',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: met
                ? context.theme.colors.foreground
                : Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 13,
          color: met ? Colors.green : Colors.orange.shade700,
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
    final met = current >= required;
    return Row(
      children: [
        Text(
          '分享率',
          style: TextStyle(
            fontSize: 11,
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Spacer(),
        Text(
          '${current.toStringAsFixed(2)} / ${required.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: met
                ? context.theme.colors.foreground
                : Colors.orange.shade700,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          met ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          size: 13,
          color: met ? Colors.green : Colors.orange.shade700,
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
                      color: context.theme.colors.foreground.withValues(
                        alpha: 0.7,
                      ),
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
    if (lv.torrents > 0) parts.add('做种${lv.torrents}');
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  bool _hasEffectiveRight(String value) {
    final right = value.trim();
    return right.isNotEmpty && right != '无' && right != '同上';
  }
}
