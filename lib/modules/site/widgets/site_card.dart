import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/modules/site/widgets/site_browser.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../dashboard/provider/privacy_provider.dart';
import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_card_style_provider.dart';
import '../provider/site_provider.dart';
import '../utils/site_level_milestone.dart';
import 'site_action_menu.dart';
import 'site_detail_sheet.dart';
import 'site_level_sheet.dart';
import 'site_theme.dart';

String _maskSiteName(String name, bool privacy) {
  if (!privacy) return name;
  if (name.isEmpty) return name;
  if (name.length <= 1) return '*';
  if (name.length == 2) return '${name[0]}*';
  return '${name[0]}*${name[name.length - 1]}';
}

String _siteLevelDisplayText(WebSite? config, SiteDailyStatus status) {
  final current = status.myLevel.trim();
  if (current.isEmpty) return '';
  final levels = config?.level;
  if (levels == null || levels.isEmpty) return current;

  for (final entry in levels.entries) {
    final level = entry.value;
    if (entry.key == current ||
        level.name.trim() == current ||
        level.level.trim() == current) {
      final display = level.displayName.trim();
      if (display.isNotEmpty) return display;
    }
  }
  return current;
}

/// 获取等级显示的完整文本 name(level)，用于 tooltip
String _siteLevelFullText(WebSite? config, SiteDailyStatus status) {
  final current = status.myLevel.trim();
  if (current.isEmpty) return '';
  final levels = config?.level;
  if (levels == null || levels.isEmpty) return current;

  for (final entry in levels.entries) {
    final level = entry.value;
    if (entry.key == current ||
        level.name.trim() == current ||
        level.level.trim() == current) {
      final name = level.displayName.isNotEmpty ? level.displayName : entry.key;
      final lv = level.level.trim();
      return lv.isNotEmpty ? '$name($lv)' : name;
    }
  }
  return current;
}

class SiteCard extends ConsumerWidget {
  final SiteInfo site;

  const SiteCard({super.key, required this.site});

  (int up, int down) _calcDailyDelta() {
    final statuses = site.status;
    if (statuses == null || statuses.length < 2) return (0, 0);
    final sorted = statuses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final newest = sorted.last.value;
    final prev = sorted[sorted.length - 2].value;
    return (
      newest.uploaded - prev.uploaded,
      newest.downloaded - prev.downloaded,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacy = ref.watch(privacyModeProvider);
    switch (ref.watch(siteCardStyleProvider)) {
      case SiteCardStyle.style2:
        return SiteCard2(site: site, privacy: privacy);
      case SiteCardStyle.style3:
        return SiteCard3(site: site, privacy: privacy);
      case SiteCardStyle.style4:
        return SiteCard4(site: site, privacy: privacy);
      case SiteCardStyle.style1:
        break;
    }

    final status = site.latestStatus;
    final (dailyUp, dailyDown) = _calcDailyDelta();

    // 读取站点配置的满魔值
    final configs = ref.watch(websiteListProvider).value ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final tokens = SiteCardTokens.of(context);

    return SiteActionMenu(
      site: site,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight.isFinite;
          final verticalPadding = compact ? 6.0 : 8.0;
          return Container(
            padding: tokens.symmetric(
              horizontal: 12,
              vertical: verticalPadding,
            ),
            decoration: tokens.cardDecoration(
              borderWidth: 1,
              shadowStrength: 1.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: compact ? 5 : 8),
                _firstRow(context, status, config, privacy),
                SizedBox(height: compact ? 2 : 3),
                _secondRow(context, status, config),
                if (status != null) ...[
                  SizedBox(height: compact ? 2 : 3),
                  _thirdRow(
                    context,
                    status,
                    dailyUp,
                    dailyDown,
                    compact: compact,
                  ),
                ],
                if (status != null) ...[
                  SizedBox(height: compact ? 3 : 4),
                  _fourthRow(context, status, spFull, compact: compact),
                ],
                if (site.tags.isNotEmpty ||
                    site.latestStatusUpdatedText.isNotEmpty) ...[
                  SizedBox(height: compact ? 5 : 8),
                  _fifthRow(context, compact: compact),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  各行布局
  // ═══════════════════════════════════════════

  Widget _firstRow(
    BuildContext context,
    SiteDailyStatus? status,
    WebSite? config,
    bool privacy,
  ) {
    final signStatus = _siteSignStatus(site, config);
    final levelText = status == null
        ? ''
        : _siteLevelDisplayText(config, status);
    final levelTooltip = status == null
        ? ''
        : _siteLevelFullText(config, status);
    final hasRight = levelText.isNotEmpty || signStatus != null;
    return Row(
      children: [
        _siteLogo(context, config, privacy),
        const SizedBox(width: 5),
        _statusDot(context, site.available),
        const SizedBox(width: 5),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _maskSiteName(site.site, privacy),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                if (site.nickname.isNotEmpty && site.nickname != site.site)
                  TextSpan(
                    text: ' ${_maskSiteName(site.nickname, privacy)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: shadcn.Theme.of(
                        context,
                      ).colorScheme.mutedForeground,
                    ),
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (hasRight) ...[
          const SizedBox(width: 6),
          if (levelText.isNotEmpty) _levelBadge(context, levelText, levelTooltip),
          if (signStatus != null) ...[
            const SizedBox(width: 4),
            _signBadge(context, signStatus, onTap: () => openDetail(context, site)),
          ],
        ],
      ],
    );
  }

  Widget _siteLogo(BuildContext context, WebSite? config, bool privacy) =>
      _siteBrowserLogo(
        context: context,
        site: site,
        config: config,
        privacy: privacy,
        size: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: shadcn.Theme.of(context).colorScheme.muted,
          border: Border.all(
            color: shadcn.Theme.of(context).colorScheme.border,
            width: 0.8,
          ),
        ),
        fallbackStyle: TextStyle(
          color: shadcn.Theme.of(context).colorScheme.foreground,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _secondRow(
    BuildContext context,
    SiteDailyStatus? status,
    WebSite? config,
  ) {
    final milestone = _siteLevelMilestone(config, status);
    final hasInvite = (status?.invitation ?? 0) > 0;
    final hasMail = site.mail > 0;
    final hasNotice = site.notice > 0;
    final hasRight = hasMail || hasNotice || hasInvite || milestone != null;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 18,
              child: site.durationText.isEmpty
                  ? const SizedBox.shrink()
                  : _tooltipWrap(
                      context,
                      _siteJoinTooltip(site),
                      _infoTag(context, Icons.access_time, site.durationText),
                    ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 22,
            child: hasRight
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasMail)
                        _pillBadge(
                          context,
                          icon: shadcn.LucideIcons.mail,
                          text: fmtCompact(site.mail.toDouble()),
                          color: siteWarning(context),
                          tooltip: '短消息 ${site.mail}',
                          height: 22,
                          fontSize: 10,
                          iconSize: 12,
                        ),
                      if (hasNotice) ...[
                        if (hasMail) const SizedBox(width: 6),
                        _pillBadge(
                          context,
                          icon: shadcn.LucideIcons.bell,
                          text: fmtCompact(site.notice.toDouble()),
                          color: siteWarning(context),
                          tooltip: '公告通知 ${site.notice}',
                          height: 22,
                          fontSize: 10,
                          iconSize: 12,
                        ),
                      ],
                      if (hasInvite) ...[
                        if (hasMail || hasNotice) const SizedBox(width: 6),
                        _pillBadge(
                          context,
                          icon: Icons.person_outline,
                          text: fmtCompact(
                            (status?.invitation ?? 0).toDouble(),
                          ),
                          color: siteInfo(context),
                          tooltip: '邀请数 ${status?.invitation ?? 0}',
                          height: 22,
                          fontSize: 10,
                          iconSize: 12,
                        ),
                      ],
                      if (milestone != null) ...[
                        if (hasMail || hasNotice || hasInvite)
                          const SizedBox(width: 8),
                        _levelMilestoneBadge(context, milestone),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _thirdRow(
    BuildContext context,
    SiteDailyStatus status,
    int dailyUp,
    int dailyDown, {
    required bool compact,
  }) {
    final statuses = site.status;
    int yesterdaySeedVolume = 0;
    if (statuses != null && statuses.length >= 2) {
      final sorted = statuses.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      yesterdaySeedVolume = sorted[sorted.length - 2].value.seedVolume;
    }

    final cs = shadcn.Theme.of(context).colorScheme;
    final tokens = SiteCardTokens.of(context);

    return Container(
      padding: tokens.symmetric(vertical: compact ? 4 : 7),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.15),
        borderRadius: tokens.panelRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 总量 ──
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '总量',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.mutedForeground.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                _style1TotalTransferLine(
                  context,
                  upValue: fmtBytes(status.uploaded),
                  downValue: fmtBytes(status.downloaded),
                  dailyUp: dailyUp,
                  dailyDown: dailyDown,
                  compact: compact,
                ),
              ],
            ),
          ),
          // 分隔
          Container(
            width: 0.5,
            height: 24,
            color: cs.border.withValues(alpha: 0.4),
          ),
          // ── 做种量对比 ──
          Expanded(
            flex: 1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '做种量',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.mutedForeground.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                _style1SeedVolumeLine(
                  context,
                  previous: fmtBytes(yesterdaySeedVolume),
                  current: fmtBytes(status.seedVolume),
                  compact: compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fourthRow(
    BuildContext context,
    SiteDailyStatus status,
    double spFull, {
    required bool compact,
  }) {
    final magic = _magicMetric(context, status.bonusHour, spFull);
    final metrics = [
      _Style1Metric(
        tooltip: '做种数',
        icon: Icons.eco_outlined,
        value: fmtCompact(status.seed.toDouble()),
        color: siteSuccess(context),
      ),
      _Style1Metric(
        tooltip: '下载数',
        icon: Icons.leak_add_outlined,
        value: fmtCompact(status.leech.toDouble()),
        color: siteInfo(context),
      ),
      _Style1Metric(
        tooltip: '做种积分',
        icon: Icons.star_outline,
        value: fmtCompact(status.myScore),
        color: siteWarning(context),
      ),
      _Style1Metric(
        tooltip: '魔力值',
        icon: Icons.diamond_outlined,
        value: fmtCompact(status.myBonus),
        color: siteAccent(context, 3),
      ),
      _Style1Metric(
        tooltip: '发布数',
        icon: Icons.edit_note,
        value: fmtCompact(status.publish.toDouble()),
        color: siteAccent(context, 6),
      ),
      _Style1Metric(
        tooltip: '分享率',
        icon: Icons.show_chart,
        value: _fmtRatio(status.ratio),
        color: siteAccent(context, 4),
      ),
      _Style1Metric(
        tooltip: '时魔比率',
        icon: Icons.hourglass_bottom_outlined,
        value: magic.value,
        color: magic.color,
      ),
    ];

    return Column(
      children: [
        _style1MetricRow(context, metrics.take(4).toList(), compact: compact),
        SizedBox(height: SiteCardTokens.of(context).size(compact ? 4 : 6)),
        _style1MetricRow(context, metrics.skip(4).toList(), compact: compact),
      ],
    );
  }

  Widget _fifthRow(BuildContext context, {required bool compact}) {
    final updateText = _siteUpdateRelativeText(site);
    final tags = site.tags.take(3).toList();
    final extraTags = site.tags.length - tags.length;
    final theme = shadcn.Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: compact ? 17 : 18,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tags.length + (extraTags > 0 ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: 3),
              itemBuilder: (context, index) {
                final text = index < tags.length ? tags[index] : '+$extraTags';
                return _style1FooterChip(
                  context,
                  text,
                  compact: compact,
                  muted: index >= tags.length,
                );
              },
            ),
          ),
        ),
        if (updateText != '-') ...[
          const SizedBox(width: 6),
          _tooltipWrap(
            context,
            _siteUpdateTooltip(site, label: '最后更新'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.update,
                  size: 11,
                  color: cs.mutedForeground.withValues(alpha: 0.52),
                ),
                const SizedBox(width: 2),
                Text(
                  updateText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 11 : 12,
                    height: 1,
                    color: cs.mutedForeground.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _style1FooterChip(
    BuildContext context,
    String text, {
    required bool compact,
    required bool muted,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final color = muted ? cs.mutedForeground : cs.primary;
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: muted ? 0.06 : 0.07),
        borderRadius: SiteCardTokens.of(context).chipRadius,
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: compact ? 10 : 10.5,
          height: 1,
          color: color.withValues(alpha: muted ? 0.74 : 0.88),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  Tooltip
  // ═══════════════════════════════════════════

  Widget _tooltipWrap(BuildContext context, String tip, Widget child) {
    return Tooltip(message: tip, preferBelow: false, child: child);
  }

  // ═══════════════════════════════════════════
  //  基础组件
  // ═══════════════════════════════════════════

  Widget _statusDot(BuildContext context, bool available) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: available
          ? siteSuccess(context)
          : siteDanger(context, alpha: 0.72),
    ),
  );

  Widget _levelBadge(BuildContext context, String lv, String tooltip) =>
      GestureDetector(
        onTap: () => openLevelInfo(context, site: site),
        child: _pillBadge(
          context,
          icon: Icons.workspace_premium,
          text: lv,
          color: levelColor(lv),
          tooltip: '等级: $tooltip',
          height: 20,
          fontSize: 9,
          iconSize: 11,
        ),
      );

  Widget _levelMilestoneBadge(
    BuildContext context,
    _SiteLevelMilestone milestone,
  ) {
    return _siteLevelMilestoneBadge(
      context,
      milestone,
      fontSize: 9,
      horizontal: 5,
      vertical: 2,
      radius: 5,
      iconSize: 10,
    );
  }

  Widget _signBadge(BuildContext context, String text, {VoidCallback? onTap}) {
    final ok = text.contains('已');
    final color = ok ? siteSuccess(context) : siteWarning(context);
    final badge = _pillBadge(
      context,
      icon: ok ? Icons.check_circle : Icons.pending,
      text: text,
      color: color,
      tooltip: text,
      height: 20,
      fontSize: 9,
      iconSize: 11,
    );
    if (onTap == null) return badge;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: badge,
    );
  }

  Widget _infoTag(BuildContext context, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 9,
        color: shadcn.Theme.of(
          context,
        ).colorScheme.mutedForeground.withValues(alpha: 0.6),
      ),
      const SizedBox(width: 2),
      Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: shadcn.Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
    ],
  );

  Widget _style1TotalTransferLine(
    BuildContext context, {
    required String upValue,
    required String downValue,
    required int dailyUp,
    required int dailyDown,
    required bool compact,
  }) {
    return _fitMetricLine(
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _style1TransferMetric(
            Icons.arrow_circle_up_outlined,
            upValue,
            siteSuccess(context),
            dailyText: _fmtSignedBytes(dailyUp),
          ),
          const SizedBox(width: 12),
          _style1TransferMetric(
            Icons.arrow_circle_down_outlined,
            downValue,
            siteDanger(context),
            dailyText: _fmtSignedBytes(dailyDown),
          ),
        ],
      ),
      height: compact ? 16 : 18,
    );
  }

  Widget _style1TransferMetric(
    IconData icon,
    String value,
    Color color, {
    required String dailyText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        if (dailyText.isNotEmpty) ...[
          const SizedBox(width: 3),
          Text(
            dailyText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 8.5,
              color: color.withValues(alpha: 0.68),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ],
    );
  }

  Widget _style1SeedVolumeLine(
    BuildContext context, {
    required String previous,
    required String current,
    required bool compact,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final previousText = Text(
      previous,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        color: cs.mutedForeground.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
      ),
    );
    final currentText = Text(
      current,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: cs.mutedForeground,
        fontWeight: FontWeight.w700,
      ),
    );

    return _fitMetricLine(
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          previousText,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              Icons.arrow_forward,
              size: 9,
              color: cs.mutedForeground.withValues(alpha: 0.3),
            ),
          ),
          currentText,
        ],
      ),
      height: compact ? 16 : 18,
    );
  }

  Widget _fitMetricLine(Widget child, {double height = 13}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FittedBox(fit: BoxFit.scaleDown, child: child),
    );
  }

  Widget _style1MetricRow(
    BuildContext context,
    List<_Style1Metric> metrics, {
    required bool compact,
  }) {
    return Row(
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          Expanded(
            child: _style1MetricTile(context, metrics[i], compact: compact),
          ),
          if (i != metrics.length - 1)
            SizedBox(width: SiteCardTokens.of(context).size(6)),
        ],
      ],
    );
  }

  Widget _style1MetricTile(
    BuildContext context,
    _Style1Metric metric, {
    required bool compact,
  }) {
    final theme = shadcn.Theme.of(context);
    final tokens = SiteCardTokens.of(context);
    final muted = theme.colorScheme.mutedForeground;
    final color = metric.color;
    return _tooltipWrap(
      context,
      metric.tooltip,
      Container(
        height: tokens.size(compact ? 24 : 30),
        padding: tokens.symmetric(horizontal: 6, vertical: compact ? 3 : 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: tokens.isDark ? 0.12 : 0.08),
          borderRadius: tokens.panelRadius,
          border: Border.all(color: color.withValues(alpha: 0.13), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(metric.icon, size: 13, color: color.withValues(alpha: 0.9)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                metric.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  color: muted,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 时魔比率：当前时魔 / 满魔
  ({String value, Color color}) _magicMetric(
    BuildContext context,
    double current,
    double full,
  ) {
    final ratio = full > 0 ? current / full : 0.0;
    final pct = (ratio * 100).round();
    final color = ratio >= 1.0
        ? siteSuccess(context)
        : ratio >= 0.5
        ? siteWarning(context)
        : siteDanger(context, alpha: 0.82);
    final display = full > 0 && current > 0
        ? '${fmtCompact(current)}($pct%)'
        : fmtCompact(current);
    return (value: display, color: color);
  }
}

class _Style1Metric {
  final String tooltip;
  final IconData icon;
  final String value;
  final Color color;

  const _Style1Metric({
    required this.tooltip,
    required this.icon,
    required this.value,
    required this.color,
  });
}

({int up, int down}) _siteDailyDelta(SiteInfo site) {
  final statuses = site.status;
  if (statuses == null || statuses.length < 2) return (up: 0, down: 0);
  final sorted = statuses.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final newest = sorted.last.value;
  final prev = sorted[sorted.length - 2].value;
  return (
    up: newest.uploaded - prev.uploaded,
    down: newest.downloaded - prev.downloaded,
  );
}

String _fmtSignedBytes(int value) {
  if (value == 0) return '';
  return '${value > 0 ? '+' : '-'}${fmtBytes(value.abs())}';
}

String _fmtMagicWithRatio(double current, double full) {
  if (full <= 0 || current == 0) return fmtCompact(current);
  final pct = ((current / full) * 100).round();
  return '${fmtCompact(current)}($pct%)';
}

String _fmtMagicWithRatioTwoLine(double current, double full) {
  final text = _fmtMagicWithRatio(current, full);
  final index = text.indexOf('(');
  if (index <= 0) return text;
  return '${text.substring(0, index)}\n${text.substring(index)}';
}

String _siteJoinDisplayText(SiteInfo site, {String prefix = ''}) {
  final duration = site.durationText.trim();
  final value = duration.isEmpty ? '-' : duration;
  return prefix.isEmpty ? value : '$prefix：$value';
}

String _siteJoinTooltip(SiteInfo site) {
  final joinedAt = _trimSiteTime(site.timeJoin);
  return joinedAt.isEmpty ? '注册时间：-' : '注册时间：$joinedAt';
}

String _siteUpdateRelativeText(SiteInfo site, {SiteDailyStatus? status}) {
  final raw = _siteUpdateRawTime(site, status: status);
  final ago = formatDateStringAgo(raw);
  return ago.isEmpty ? '-' : '于$ago';
}

String _siteUpdateTooltip(
  SiteInfo site, {
  SiteDailyStatus? status,
  String label = '更新时间',
}) {
  final raw = _siteUpdateRawTime(site, status: status);
  final text = _trimSiteTime(raw);
  return text.isEmpty ? '$label：-' : '$label：$text';
}

String _siteUpdateRawTime(SiteInfo site, {SiteDailyStatus? status}) {
  final statusText = status?.updated_at.trim() ?? '';
  if (statusText.isNotEmpty) return statusText;
  return site.latestStatusUpdatedAt?.trim() ?? '';
}

String _trimSiteTime(String? text) {
  final value = text?.trim() ?? '';
  if (value.isEmpty) return value;
  return value.replaceFirst(RegExp(r'\.(\d+)(?=(?:Z|[+-]\d{2}:?\d{2})?$)'), '');
}

const _localSiteIconExtensions = <String>[
  'png',
  'gif',
  'jpg',
  'jpeg',
  'webp',
  'ico',
];

List<String> _localSiteIconUrls(String siteName) {
  final name = siteName.trim();
  final base = AppConfig.baseUrl.trim();
  if (name.isEmpty || base.isEmpty) return const <String>[];

  final baseUri = Uri.tryParse(base.endsWith('/') ? base : '$base/');
  if (baseUri == null || !baseUri.hasScheme) return const <String>[];
  final encodedName = Uri.encodeComponent(name);
  return [
    for (final ext in _localSiteIconExtensions)
      baseUri.resolve('local/icons/$encodedName.$ext').toString(),
  ];
}

Map<String, String>? _localSiteIconHeaders() {
  final token = HiveManager.get<String>(StorageKeys.accessToken);
  if (token == null || token.isEmpty) return null;
  return {'Authorization': 'Bearer $token'};
}

String _siteLogoUrl(WebSite? config) {
  final logo = config?.logo.trim() ?? '';
  if (logo.isEmpty) return '';
  if (logo.startsWith('//')) return 'https:$logo';
  final logoUri = Uri.tryParse(logo);
  if (logoUri != null && logoUri.hasScheme) return logo;

  final base = config?.url.firstOrNull;
  final baseUri = base == null ? null : Uri.tryParse(base);
  if (baseUri == null || !baseUri.hasScheme) return '';
  return baseUri.resolve(logo).toString();
}

class _SiteLogoImage extends StatelessWidget {
  final String siteName;
  final WebSite? config;
  final double size;
  final BoxDecoration decoration;
  final TextStyle fallbackStyle;
  final String? fallbackText;

  const _SiteLogoImage({
    required this.siteName,
    required this.config,
    required this.size,
    required this.decoration,
    required this.fallbackStyle,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    final localIcons = _localSiteIconUrls(siteName);
    final siteLogo = _siteLogoUrl(config);
    final fallback = _fallback();
    final localHeaders = _localSiteIconHeaders();
    final candidates = [
      for (final url in localIcons)
        _LogoCandidate(url: url, headers: localHeaders),
      if (siteLogo.isNotEmpty) _LogoCandidate(url: siteLogo),
    ];

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: _cachedImageCandidates(candidates, fallback: fallback),
    );
  }

  Widget _cachedImageCandidates(
    List<_LogoCandidate> candidates, {
    required Widget fallback,
    int index = 0,
  }) {
    if (index >= candidates.length) return fallback;
    final candidate = candidates[index];
    if (candidate.url.isEmpty) {
      return _cachedImageCandidates(
        candidates,
        fallback: fallback,
        index: index + 1,
      );
    }
    return CachedNetworkImage(
      imageUrl: candidate.url,
      httpHeaders: candidate.headers,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => _cachedImageCandidates(
        candidates,
        fallback: fallback,
        index: index + 1,
      ),
    );
  }

  Widget _fallback() {
    if (fallbackText != null) {
      return Center(child: Text(fallbackText!, style: fallbackStyle));
    }
    final name = siteName.trim();
    final text = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Center(child: Text(text, style: fallbackStyle));
  }
}

class _LogoCandidate {
  final String url;
  final Map<String, String>? headers;

  const _LogoCandidate({required this.url, this.headers});
}

Widget _siteBrowserLogo({
  required BuildContext context,
  required SiteInfo site,
  required WebSite? config,
  required bool privacy,
  required double size,
  required BoxDecoration decoration,
  required TextStyle fallbackStyle,
}) {
  final logo = _SiteLogoImage(
    siteName: site.site,
    config: config,
    size: size,
    decoration: decoration,
    fallbackStyle: fallbackStyle,
    fallbackText: privacy ? '*' : null,
  );
  final mirror = site.mirror?.trim() ?? '';
  if (mirror.isEmpty) return logo;

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => openSiteBrowser(context, site),
    onLongPress: () => openSiteExternalBrowser(site),
    child: logo,
  );
}

Widget _siteTooltip(String text, Widget child) {
  return Tooltip(message: text, preferBelow: false, child: child);
}

enum _SiteLevelMilestone {
  keepAccount('保号', '已达到保号等级', Icons.verified_user_outlined),
  graduation('毕业', '已达到毕业等级', Icons.school_outlined);

  final String label;
  final String tooltip;
  final IconData icon;

  const _SiteLevelMilestone(this.label, this.tooltip, this.icon);

  Color color(BuildContext context) => switch (this) {
    _SiteLevelMilestone.keepAccount => siteSuccess(context),
    _SiteLevelMilestone.graduation => siteWarning(context),
  };
}

_SiteLevelMilestone? _siteLevelMilestone(
  WebSite? config,
  SiteDailyStatus? status,
) {
  return switch (siteLevelMilestone(config, status)) {
    SiteLevelMilestoneType.keepAccount => _SiteLevelMilestone.keepAccount,
    SiteLevelMilestoneType.graduation => _SiteLevelMilestone.graduation,
    null => null,
  };
}

String? _siteSignStatus(SiteInfo site, WebSite? config) {
  if (config?.signIn != true || !site.signIn) return null;
  final today = DateTime.now();
  final todayKey =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  return site.signInfo?.containsKey(todayKey) == true ? '已签到' : '未签到';
}

/// 统一的 Pill 徽章组件
Widget _pillBadge(
  BuildContext context, {
  required IconData icon,
  required String text,
  required Color color,
  required String tooltip,
  double height = 22,
  double fontSize = 10,
  double iconSize = 12,
}) {
  final tokens = SiteCardTokens.of(context);
  final isDark = shadcn.Theme.of(context).brightness == Brightness.dark;
  return _siteTooltip(
    tooltip,
    Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.10),
        borderRadius: tokens.pillRadius,
        border: Border.all(color: color.withValues(alpha: 0.20), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _siteSignBadge(BuildContext context, String text, {VoidCallback? onTap}) {
  final signed = text == '已签到';
  final color = signed ? siteSuccess(context) : siteWarning(context);
  final badge = _pillBadge(
    context,
    icon: signed ? Icons.check_circle : Icons.pending,
    text: text,
    color: color,
    tooltip: text,
    height: 22,
    fontSize: 10,
    iconSize: 12,
  );
  if (onTap == null) return badge;
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: badge,
  );
}

bool _hasSiteUnread(SiteInfo site) => site.mail > 0 || site.notice > 0;

Widget _siteUnreadIndicators(
  BuildContext context,
  SiteInfo site, {
  double iconSize = 12,
  double fontSize = 10,
  double height = 22,
  double horizontal = 6,
  double gap = 5,
  Color? mailColor,
  Color? noticeColor,
}) {
  final indicators = <Widget>[
    if (site.mail > 0)
      _pillBadge(
        context,
        icon: shadcn.LucideIcons.mail,
        text: fmtCompact(site.mail.toDouble()),
        color: mailColor ?? siteWarning(context),
        tooltip: '短消息 ${site.mail}',
        height: height,
        fontSize: fontSize,
        iconSize: iconSize,
      ),
    if (site.notice > 0)
      _pillBadge(
        context,
        icon: shadcn.LucideIcons.bell,
        text: fmtCompact(site.notice.toDouble()),
        color: noticeColor ?? siteWarning(context),
        tooltip: '公告通知 ${site.notice}',
        height: height,
        fontSize: fontSize,
        iconSize: iconSize,
      ),
  ];

  if (indicators.isEmpty) return const SizedBox.shrink();
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < indicators.length; i++) ...[
        indicators[i],
        if (i != indicators.length - 1) SizedBox(width: gap),
      ],
    ],
  );
}

Widget _siteLevelMilestoneBadge(
  BuildContext context,
  _SiteLevelMilestone milestone, {
  double fontSize = 9,
  double horizontal = 4,
  double vertical = 1,
  double radius = 3,
  double? iconSize,
  double? height,
}) {
  final color = milestone.color(context);
  return _pillBadge(
    context,
    icon: milestone.icon,
    text: milestone.label,
    color: color,
    tooltip: milestone.tooltip,
    height: height ?? 22,
    fontSize: fontSize,
    iconSize: iconSize ?? 12,
  );
}

Widget _siteInvitePill(
  BuildContext context,
  int invitation, {
  double height = 24,
  bool emojiLabel = false,
}) {
  final accent = siteInfo(context);
  final tokens = SiteCardTokens.of(context);
  final isDark = shadcn.Theme.of(context).brightness == Brightness.dark;
  final foreground = shadcn.Theme.of(context).colorScheme.foreground;
  return _siteTooltip(
    '邀请数 $invitation',
    Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.14 : 0.10),
        borderRadius: tokens.pillRadius,
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.22 : 0.16),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (emojiLabel)
            const Text('🎟️', style: TextStyle(fontSize: 11, height: 1))
          else
            Icon(Icons.person, size: 12, color: accent.withValues(alpha: 0.68)),
          SizedBox(width: emojiLabel ? 2 : 4),
          Text(
            emojiLabel
                ? fmtCompact(invitation.toDouble())
                : fmtCompact(invitation.toDouble()),
            style: TextStyle(
              color: foreground.withValues(alpha: 0.80),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

class SiteCard2 extends ConsumerWidget {
  final SiteInfo site;
  final bool privacy;

  const SiteCard2({super.key, required this.site, required this.privacy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = site.latestStatus;
    final configs = ref.watch(websiteListProvider).value ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final delta = _siteDailyDelta(site);
    final tokens = SiteCardTokens.of(context);
    final dividerColor = _dividerColor(context);

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: tokens.edgeFromLTRB(14, 13, 14, 11),
        decoration: tokens.cardDecoration(borderWidth: 0.7),
        child: status == null
            ? _emptyCard(context, config)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, status, config),
                  const SizedBox(height: 9),
                  _mainMetrics(context, status, delta),
                  const SizedBox(height: 6),
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
                  _minorRow(context, [
                    _MinorMetric(
                      Icons.groups_outlined,
                      '做种数',
                      fmtCompact(status.seed.toDouble()),
                      siteColors(context).mutedForeground,
                    ),
                    _MinorMetric(
                      Icons.arrow_downward,
                      '下载数',
                      fmtCompact(status.leech.toDouble()),
                      siteColors(context).mutedForeground,
                    ),
                    _MinorMetric(
                      Icons.arrow_upward,
                      '做种量',
                      fmtBytes(status.seedVolume),
                      siteColors(context).mutedForeground,
                    ),
                  ]),
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
                  _minorRow(context, [
                    _MinorMetric(
                      shadcn.LucideIcons.diamond,
                      '魔力值',
                      fmtCompact(status.myBonus),
                      siteAccent(context, 3),
                    ),
                    _MinorMetric(
                      Icons.star_outline,
                      '做种积分',
                      fmtCompact(status.myScore),
                      siteWarning(context),
                    ),
                    _MinorMetric(
                      Icons.schedule_outlined,
                      '时魔',
                      _fmtMagicWithRatio(status.bonusHour, spFull),
                      siteInfo(context),
                    ),
                  ]),
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
                  const SizedBox(height: 8),
                  _timeRow(context, status),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final centerHeight = bounded
            ? (constraints.maxHeight - 92).clamp(36.0, 92.0).toDouble()
            : 0.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _siteLogo(context, config),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _siteTitle(context)),
                          if (_hasSiteUnread(site)) ...[
                            const SizedBox(width: 8),
                            _siteUnreadIndicators(context, site),
                          ],
                          if (signStatus != null) ...[
                            const SizedBox(width: 8),
                            _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '暂无站点数据',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (bounded)
              SizedBox(
                height: centerHeight,
                child: Center(child: _siteLogo(context, config)),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                shadcn.LucideIcons.chevronRight,
                color: _mutedText(context),
                size: 20,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header(
    BuildContext context,
    SiteDailyStatus status,
    WebSite? config,
  ) {
    final milestone = _siteLevelMilestone(config, status);
    final signStatus = _siteSignStatus(site, config);
    final levelText = _siteLevelDisplayText(config, status);
    final levelTooltip = _siteLevelFullText(config, status);
    final hasInvite = status.invitation > 0;
    final hasSecondary = _hasSiteUnread(site) || hasInvite || milestone != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _siteLogo(context, config),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _statusDot(context, site.available),
                  const SizedBox(width: 8),
                  Expanded(child: _siteTitle(context)),
                  if (levelText.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _levelPill(context, levelText, levelTooltip),
                  ],
                  if (signStatus != null) ...[
                    const SizedBox(width: 6),
                    _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    shadcn.LucideIcons.chevronRight,
                    color: _mutedText(context),
                    size: 20,
                  ),
                ],
              ),
              if (hasSecondary) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_hasSiteUnread(site))
                      _siteUnreadIndicators(context, site),
                    if (hasInvite) ...[
                      const SizedBox(width: 8),
                      _siteInvitePill(context, status.invitation),
                    ],
                    if (milestone != null) ...[
                      const SizedBox(width: 8),
                      _siteLevelMilestoneBadge(
                        context,
                        milestone,
                        fontSize: 11,
                        horizontal: 7,
                        vertical: 2,
                        radius: 5,
                        iconSize: 12,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _timeRow(BuildContext context, SiteDailyStatus status) {
    final joinedText = _siteJoinDisplayText(site, prefix: '注册');
    final refreshDisplay = _siteUpdateRelativeText(site, status: status);
    final style = TextStyle(
      fontSize: 11,
      color: _mutedText(context).withValues(alpha: 0.86),
      height: 1.1,
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(
          child: _siteTooltip(
            _siteJoinTooltip(site),
            Text(
              joinedText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _siteTooltip(
            _siteUpdateTooltip(site, status: status, label: '最后刷新'),
            Text(
              refreshDisplay,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainMetrics(
    BuildContext context,
    SiteDailyStatus status,
    ({int up, int down}) delta,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: _largeMetric(
            context,
            value: fmtBytes(status.uploaded),
            delta: _fmtSignedBytes(delta.up),
            label: '上传量',
            color: siteSuccess(context),
          ),
        ),
        _verticalDivider(context),
        Expanded(
          flex: 4,
          child: _largeMetric(
            context,
            value: fmtBytes(status.downloaded),
            delta: _fmtSignedBytes(delta.down),
            label: '下载量',
            color: siteDanger(context),
          ),
        ),
        _verticalDivider(context),
        Expanded(
          flex: 3,
          child: _largeMetric(
            context,
            value: _fmtRatio(status.ratio),
            label: '分享率',
            color: siteInfo(context),
          ),
        ),
      ],
    );
  }

  Widget _largeMetric(
    BuildContext context, {
    required String value,
    String? delta,
    required String label,
    required Color color,
  }) {
    final parts = _splitValueUnit(value);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 19,
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: parts.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  if (parts.unit.isNotEmpty)
                    TextSpan(
                      text: ' ${parts.unit}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: _mutedText(context),
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (delta != null && delta.isNotEmpty) ...[
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  delta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color.withValues(alpha: 0.72),
                    height: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _minorRow(BuildContext context, List<_MinorMetric> items) {
    final tokens = SiteCardTokens.of(context);
    return Padding(
      padding: tokens.symmetric(vertical: 9),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: _minorMetric(context, items[i])),
            if (i != items.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _minorMetric(BuildContext context, _MinorMetric item) {
    final iconColor = item.color;
    final metric = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 12, color: iconColor),
        const SizedBox(width: 3),
        Flexible(
          flex: 3,
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: _mutedText(context),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 3),
        Flexible(
          flex: 5,
          child: Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: _titleText(context).withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ],
    );
    return _siteTooltip('${item.label}: ${item.value}', metric);
  }

  Widget _siteLogo(BuildContext context, WebSite? config) {
    return _siteBrowserLogo(
      context: context,
      site: site,
      config: config,
      privacy: privacy,
      size: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: siteColors(context).foreground,
        border: Border.all(color: _logoBorder(context), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: siteShadow(context, alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      fallbackStyle: TextStyle(
        color: siteColors(context).background,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _siteTitle(BuildContext context) {
    final title = _maskSiteName(
      site.nickname.isNotEmpty ? site.nickname : site.site,
      privacy,
    );
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: 16,
        height: 1.08,
        color: _titleText(context).withValues(alpha: 0.82),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _statusDot(BuildContext context, bool available) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: available ? siteSuccess(context) : siteDanger(context),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (available ? siteSuccess(context) : siteDanger(context))
              .withValues(alpha: 0.28),
          blurRadius: 6,
        ),
      ],
    ),
  );

  Widget _verticalDivider(BuildContext context) =>
      Container(width: 1, height: 38, color: _dividerColor(context));

  bool _isDark(BuildContext context) => SiteCardTokens.of(context).isDark;

  Color _dividerColor(BuildContext context) =>
      SiteCardTokens.of(context).dividerColor;

  Color _titleText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.foreground
      : siteColors(context).foreground;

  Color _mutedText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.mutedForeground
      : siteColors(context).mutedForeground;

  Color _logoBorder(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.9)
      : siteColors(context).background.withValues(alpha: 0.9);

  Widget _levelPill(BuildContext context, String level, String tooltip) {
    final accent = siteWarning(context);
    return GestureDetector(
      onTap: () => openLevelInfo(context, site: site),
      child: _pillBadge(
        context,
        icon: Icons.workspace_premium,
        text: level,
        color: accent,
        tooltip: '等级: $tooltip',
        height: 22,
        fontSize: 11,
        iconSize: 12,
      ),
    );
  }

  ({String value, String unit}) _splitValueUnit(String text) {
    final index = text.lastIndexOf(' ');
    if (index <= 0 || index == text.length - 1) {
      return (value: text, unit: '');
    }
    return (value: text.substring(0, index), unit: text.substring(index + 1));
  }
}

class _MinorMetric {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MinorMetric(this.icon, this.label, this.value, this.color);
}

class SiteCard3 extends ConsumerWidget {
  final SiteInfo site;
  final bool privacy;

  const SiteCard3({super.key, required this.site, required this.privacy});

  static const double _statusBadgeHeight = 20;
  static const double _statusBadgeIconSize = 11;
  static const double _statusBadgeFontSize = 11;
  static const double _statusBadgeHorizontal = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = site.latestStatus;
    final configs = ref.watch(websiteListProvider).value ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final delta = _siteDailyDelta(site);
    final tokens = SiteCardTokens.of(context);

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: tokens.edgeFromLTRB(10, 10, 10, 8),
        decoration: tokens.cardDecoration(borderWidth: 0.8),
        child: status == null
            ? _emptyCard(context, ref, config)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _top(context, status, config),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _trafficTile(
                          context,
                          label: '上传',
                          value: fmtBytes(status.uploaded),
                          delta: _fmtSignedBytes(delta.up),
                          deltaColor: siteSuccess(context),
                          caption: '总计上传流量',
                          icon: '⬆️',
                          accent: siteInfo(context),
                          background: _softTileColor(
                            context,
                            siteInfo(context, alpha: 0.14),
                            siteInfo(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _trafficTile(
                          context,
                          label: '下载',
                          value: fmtBytes(status.downloaded),
                          delta: _fmtSignedBytes(delta.down),
                          deltaColor: siteDanger(context),
                          caption: '总计下载流量',
                          icon: '⬇️',
                          accent: siteSuccess(context),
                          background: _softTileColor(
                            context,
                            siteSuccess(context, alpha: 0.14),
                            siteSuccess(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  _smallGrid(context, status, spFull),
                  const SizedBox(height: 4),
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: _dividerColor(context),
                  ),
                  const SizedBox(height: 4),
                  _footer(context, ref, status),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WidgetRef ref, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final centerHeight = bounded
            ? (constraints.maxHeight - 120).clamp(56.0, 160.0).toDouble()
            : 0.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _siteLogo(context, config, 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _title(context)),
                            if (signStatus != null) ...[
                              const SizedBox(width: 6),
                              _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '暂无站点数据',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _mutedText(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_hasSiteUnread(site)) ...[
                  const SizedBox(width: 8),
                  _siteUnreadIndicators(
                    context,
                    site,
                    iconSize: _statusBadgeIconSize,
                    fontSize: _statusBadgeFontSize,
                    height: _statusBadgeHeight,
                    horizontal: _statusBadgeHorizontal,
                  ),
                ],
              ],
            ),
            if (bounded)
              SizedBox(
                height: centerHeight,
                child: Center(child: _siteLogo(context, config, 44)),
              ),
          ],
        );
      },
    );
  }

  Widget _top(BuildContext context, SiteDailyStatus status, WebSite? config) {
    final milestone = _siteLevelMilestone(config, status);
    final signStatus = _siteSignStatus(site, config);
    final levelText = _siteLevelDisplayText(config, status);
    final levelTooltip = _siteLevelFullText(config, status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _siteLogo(context, config, 54),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _title(context)),
                  if (levelText.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _levelPill(context, levelText, levelTooltip),
                  ],
                  if (signStatus != null) ...[
                    const SizedBox(width: 6),
                    _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '📅',
                        style: TextStyle(fontSize: 14, height: 1),
                      ),
                      const SizedBox(width: 4),
                      _siteTooltip(
                        _siteJoinTooltip(site),
                        Text(
                          site.durationText.isEmpty ? '-' : site.durationText,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _mutedText(context).withValues(alpha: 0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status.invitation > 0) ...[
                        _invitePill(context, status.invitation),
                      ],
                      if (milestone != null) ...[
                        if (status.invitation > 0) const SizedBox(width: 8),
                        _siteLevelMilestoneBadge(
                          context,
                          milestone,
                          fontSize: _statusBadgeFontSize,
                          horizontal: _statusBadgeHorizontal,
                          vertical: 0,
                          radius: 16,
                          iconSize: _statusBadgeIconSize,
                          height: _statusBadgeHeight,
                        ),
                      ],
                      if (_hasSiteUnread(site)) ...[
                        if (status.invitation > 0 || milestone != null)
                          const SizedBox(width: 8),
                        _siteUnreadIndicators(
                          context,
                          site,
                          iconSize: _statusBadgeIconSize,
                          fontSize: _statusBadgeFontSize,
                          height: _statusBadgeHeight,
                          horizontal: _statusBadgeHorizontal,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trafficTile(
    BuildContext context, {
    required String label,
    required String value,
    required String delta,
    required Color deltaColor,
    required String caption,
    required String icon,
    required Color accent,
    required Color background,
  }) {
    final tooltip = delta.isEmpty
        ? '$label: $value'
        : '$label: $value ($delta)';
    return _siteTooltip(
      tooltip,
      Container(
        height: 70,
        padding: SiteCardTokens.of(
          context,
        ).symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: SiteCardTokens.of(context).tileRadius,
          border: Border.all(color: accent.withValues(alpha: 0.12), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 15, height: 1)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: SizedBox(
                    height: 16,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _titleText(context).withValues(alpha: 0.74),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                if (delta.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        delta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: deltaColor.withValues(alpha: 0.82),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: TextStyle(
                color: _mutedText(context),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallGrid(
    BuildContext context,
    SiteDailyStatus status,
    double spFull,
  ) {
    final tiles = [
      _MetricTile(
        '🌱',
        '做种',
        fmtCompact(status.seed.toDouble()),
        siteSuccess(context),
        _softTileColor(
          context,
          siteSuccess(context, alpha: 0.14),
          siteSuccess(context),
        ),
      ),
      _MetricTile(
        '⬇️',
        '下载中',
        fmtCompact(status.leech.toDouble()),
        siteInfo(context),
        _softTileColor(
          context,
          siteInfo(context, alpha: 0.14),
          siteInfo(context),
        ),
      ),
      _MetricTile(
        '✨',
        '魔力',
        fmtCompact(status.myBonus),
        siteWarning(context),
        _softTileColor(
          context,
          siteWarning(context, alpha: 0.14),
          siteWarning(context),
        ),
      ),
      _MetricTile(
        '💎',
        '积分',
        fmtCompact(status.myScore),
        siteAccent(context, 3),
        _softTileColor(
          context,
          siteAccent(context, 3, alpha: 0.14),
          siteAccent(context, 3),
        ),
      ),
      _MetricTile(
        '⚖️',
        '分享率',
        _fmtRatio(status.ratio),
        siteAccent(context, 4),
        _softTileColor(
          context,
          siteAccent(context, 4, alpha: 0.14),
          siteAccent(context, 4),
        ),
      ),
      _MetricTile(
        '⚡',
        '时魔',
        _fmtMagicWithRatio(status.bonusHour, spFull),
        siteAccent(context, 5),
        _softTileColor(
          context,
          siteAccent(context, 5, alpha: 0.14),
          siteAccent(context, 5),
        ),
      ),
      _MetricTile(
        '🚀',
        '发种',
        fmtCompact(status.publish.toDouble()),
        siteAccent(context, 6),
        _softTileColor(
          context,
          siteAccent(context, 6, alpha: 0.14),
          siteAccent(context, 6),
        ),
      ),
      _MetricTile(
        '💽',
        '做种量',
        fmtBytes(status.seedVolume),
        siteAccent(context, 7),
        _softTileColor(
          context,
          siteAccent(context, 7, alpha: 0.14),
          siteAccent(context, 7),
        ),
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                Expanded(child: _metricTile(context, tiles[row * 4 + col])),
                if (col != 3) const SizedBox(width: 5),
              ],
            ],
          ),
          if (row != 1) const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _metricTile(BuildContext context, _MetricTile item) {
    final tile = Container(
      width: double.infinity,
      height: 46,
      padding: SiteCardTokens.of(context).symmetric(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: SiteCardTokens.of(context).tileRadius,
        border: Border.all(color: item.color.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.icon, style: const TextStyle(fontSize: 13, height: 1)),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _titleText(context).withValues(alpha: 0.74),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
    return _siteTooltip('${item.label}: ${item.value}', tile);
  }

  Widget _footer(BuildContext context, WidgetRef ref, SiteDailyStatus status) {
    final text = _siteUpdateRelativeText(site, status: status);
    return Row(
      children: [
        Expanded(
          child: _siteTooltip(
            _siteUpdateTooltip(site, status: status, label: '同步'),
            Text(
              '同步： $text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _mutedText(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openDetail(context, site),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softTileColor(
                context,
                siteInfo(context, alpha: 0.14),
                siteInfo(context),
              ),
              borderRadius: SiteCardTokens.of(context).pillRadius,
            ),
            child: Text(
              '详情',
              style: TextStyle(
                color: siteInfo(context),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _siteLogo(BuildContext context, WebSite? config, double size) {
    return _siteBrowserLogo(
      context: context,
      site: site,
      config: config,
      privacy: privacy,
      size: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [siteSuccess(context), siteInfo(context)],
        ),
        boxShadow: [
          BoxShadow(
            color: siteSuccess(context, alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      fallbackStyle: TextStyle(
        color: siteColors(context).background,
        fontSize: size * 0.42,
        fontWeight: FontWeight.w900,
        height: 1,
      ),
    );
  }

  Widget _title(BuildContext context) {
    final title = _maskSiteName(
      site.nickname.isNotEmpty ? site.nickname : site.site,
      privacy,
    );
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _titleText(context).withValues(alpha: 0.82),
        fontSize: 19,
        fontWeight: FontWeight.w800,
        height: 1.06,
      ),
    );
  }

  Widget _levelPill(BuildContext context, String level, String tooltip) {
    final accent = siteWarning(context);
    return GestureDetector(
      onTap: () => openLevelInfo(context, site: site),
      child: _pillBadge(
        context,
        icon: Icons.workspace_premium,
        text: level,
        color: accent,
        tooltip: '等级: $tooltip',
        height: SiteCard3._statusBadgeHeight,
        fontSize: SiteCard3._statusBadgeFontSize,
        iconSize: SiteCard3._statusBadgeIconSize,
      ),
    );
  }

  Widget _invitePill(BuildContext context, int invitation) {
    return _siteInvitePill(
      context,
      invitation,
      height: _statusBadgeHeight,
      emojiLabel: true,
    );
  }

  bool _isDark(BuildContext context) => SiteCardTokens.of(context).isDark;

  Color _dividerColor(BuildContext context) =>
      SiteCardTokens.of(context).dividerColor;

  Color _titleText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.foreground
      : siteColors(context).foreground;

  Color _mutedText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.mutedForeground
      : siteColors(context).mutedForeground;

  Color _softTileColor(BuildContext context, Color light, Color accent) {
    if (!_isDark(context)) return light;
    final cs = shadcn.Theme.of(context).colorScheme;
    return Color.alphaBlend(
      accent.withValues(alpha: 0.10),
      Color.alphaBlend(cs.muted.withValues(alpha: 0.06), cs.background),
    );
  }
}

class SiteCard4 extends SiteCard3 {
  const SiteCard4({super.key, required super.site, required super.privacy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = site.latestStatus;
    final configs = ref.watch(websiteListProvider).value ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final tokens = SiteCardTokens.of(context);

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: tokens.edgeFromLTRB(10, 10, 10, 8),
        decoration: tokens.cardDecoration(
          borderWidth: 0.9,
          shadowStrength: 1.1,
        ),
        child: status == null
            ? _emptyCard4(context, ref, config)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _hero(context, status, config),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _trafficPanel(
                          context,
                          icon: Icons.cloud_upload_rounded,
                          label: '上传',
                          value: fmtBytes(status.uploaded),
                          caption: '总计上传流量',
                          accent: siteSuccess(context),
                          background: _softTileColor(
                            context,
                            siteSuccess(context, alpha: 0.10),
                            siteSuccess(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _trafficPanel(
                          context,
                          icon: Icons.cloud_download_rounded,
                          label: '下载',
                          value: fmtBytes(status.downloaded),
                          caption: '总计下载流量',
                          accent: siteInfo(context),
                          background: _softTileColor(
                            context,
                            siteInfo(context, alpha: 0.10),
                            siteInfo(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _metricGrid(context, status, spFull),
                  const SizedBox(height: 4),
                  Divider(
                    height: 1,
                    thickness: 0.7,
                    color: _dividerColor(context),
                  ),
                  const SizedBox(height: 4),
                  _footer4(context, ref, status),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard4(BuildContext context, WidgetRef ref, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - 144).clamp(72.0, 180.0).toDouble()
            : 72.0;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _siteLogo(context, config, 54),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _title(context)),
                            if (signStatus != null) ...[
                              const SizedBox(width: 6),
                              _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '暂无站点数据',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _mutedText(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            if (_hasSiteUnread(site)) ...[
                              const SizedBox(width: 8),
                              _siteUnreadIndicators(
                                context,
                                site,
                                iconSize: SiteCard3._statusBadgeIconSize,
                                fontSize: SiteCard3._statusBadgeFontSize,
                                height: SiteCard3._statusBadgeHeight,
                                horizontal: SiteCard3._statusBadgeHorizontal,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: centerHeight,
              child: Center(child: _siteLogo(context, config, 44)),
            ),
          ],
        );
      },
    );
  }

  Widget _hero(BuildContext context, SiteDailyStatus status, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    final milestone = _siteLevelMilestone(config, status);
    final levelText = _siteLevelDisplayText(config, status);
    final levelTooltip = _siteLevelFullText(config, status);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _siteLogo(context, config, 54),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _title(context)),
                    if (levelText.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _levelPill(context, levelText, levelTooltip),
                    ],
                    if (signStatus != null) ...[
                      const SizedBox(width: 6),
                      _siteSignBadge(context, signStatus, onTap: () => openDetail(context, site)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '📅',
                          style: TextStyle(fontSize: 14, height: 1),
                        ),
                        const SizedBox(width: 5),
                        _siteTooltip(
                          _siteJoinTooltip(site),
                          Text(
                            site.durationText.isEmpty ? '-' : site.durationText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _mutedText(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (milestone != null) ...[
                          _siteLevelMilestoneBadge(
                            context,
                            milestone,
                            fontSize: SiteCard3._statusBadgeFontSize,
                            horizontal: SiteCard3._statusBadgeHorizontal,
                            vertical: 0,
                            radius: 16,
                            iconSize: SiteCard3._statusBadgeIconSize,
                            height: SiteCard3._statusBadgeHeight,
                          ),
                        ],
                        if (_hasSiteUnread(site)) ...[
                          if (milestone != null) const SizedBox(width: 8),
                          _siteUnreadIndicators(
                            context,
                            site,
                            iconSize: SiteCard3._statusBadgeIconSize,
                            fontSize: SiteCard3._statusBadgeFontSize,
                            height: SiteCard3._statusBadgeHeight,
                            horizontal: SiteCard3._statusBadgeHorizontal,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _trafficPanel(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String caption,
    required Color accent,
    required Color background,
  }) {
    return _siteTooltip(
      '$label: $value',
      Container(
        height: 68,
        padding: SiteCardTokens.of(
          context,
        ).symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: SiteCardTokens.of(context).tileRadius,
          border: Border.all(color: accent.withValues(alpha: 0.16), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 14,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 19,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        style: TextStyle(
                          color: _titleText(context).withValues(alpha: 0.78),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 12,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        caption,
                        maxLines: 1,
                        style: TextStyle(
                          color: _mutedText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricGrid(
    BuildContext context,
    SiteDailyStatus status,
    double spFull,
  ) {
    final items = [
      _Card4Metric(
        Icons.spa_outlined,
        '做种',
        fmtCompact(status.seed.toDouble()),
        siteSuccess(context),
        siteSuccess(context, alpha: 0.08),
      ),
      _Card4Metric(
        Icons.arrow_circle_down_rounded,
        '下载中',
        fmtCompact(status.leech.toDouble()),
        siteInfo(context),
        siteInfo(context, alpha: 0.08),
      ),
      _Card4Metric(
        Icons.bolt_rounded,
        '魔力',
        fmtCompact(status.myBonus),
        siteAccent(context, 4),
        siteAccent(context, 4, alpha: 0.08),
      ),
      _Card4Metric(
        shadcn.LucideIcons.diamond,
        '积分',
        fmtCompact(status.myScore),
        siteDanger(context),
        siteDanger(context, alpha: 0.07),
      ),
      _Card4Metric(
        Icons.hub_outlined,
        '分享率',
        _fmtRatio(status.ratio),
        siteAccent(context, 5),
        siteAccent(context, 5, alpha: 0.08),
      ),
      _Card4Metric(
        Icons.timer_outlined,
        '时魔',
        _fmtMagicWithRatioTwoLine(status.bonusHour, spFull),
        siteWarning(context),
        siteWarning(context, alpha: 0.08),
        twoLineValue: true,
      ),
      _Card4Metric(
        Icons.rocket_launch_outlined,
        '发种',
        fmtCompact(status.publish.toDouble()),
        siteInfo(context),
        siteInfo(context, alpha: 0.08),
      ),
      _Card4Metric(
        Icons.storage_rounded,
        '做种量',
        fmtBytes(status.seedVolume),
        _mutedText(context),
        siteColors(context).muted.withValues(alpha: 0.32),
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                Expanded(child: _metricPanel(context, items[row * 4 + col])),
                if (col != 3) const SizedBox(width: 6),
              ],
            ],
          ),
          if (row != 1) const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _metricPanel(BuildContext context, _Card4Metric item) {
    return _siteTooltip(
      '${item.label}: ${item.value}',
      Container(
        height: 46,
        padding: SiteCardTokens.of(
          context,
        ).symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: _softTileColor(context, item.background, item.color),
          borderRadius: SiteCardTokens.of(context).tileRadius,
          border: Border.all(
            color: item.color.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 15),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 12,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: item.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  _dottedDivider(context),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: item.twoLineValue ? 21 : 15,
                    width: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(
                        item.value,
                        maxLines: item.twoLineValue ? 2 : 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _titleText(context).withValues(alpha: 0.78),
                          fontSize: item.twoLineValue ? 15 : 16,
                          fontWeight: FontWeight.w900,
                          height: item.twoLineValue ? 1.05 : 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dottedDivider(BuildContext context) {
    final color = _dividerColor(context).withValues(alpha: 0.72);
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = (constraints.maxWidth / 5).floor().clamp(1, 80);
          return Row(
            children: List.generate(
              count,
              (index) => Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(width: 2, height: 1, color: color),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _footer4(BuildContext context, WidgetRef ref, SiteDailyStatus status) {
    final text = _siteUpdateRelativeText(site, status: status);
    return Row(
      children: [
        Expanded(
          child: _siteTooltip(
            _siteUpdateTooltip(site, status: status, label: '同步'),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '同步： $text',
                maxLines: 1,
                style: TextStyle(
                  color: _mutedText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openDetail(context, site),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _softTileColor(
                context,
                siteInfo(context, alpha: 0.14),
                siteInfo(context),
              ),
              borderRadius: SiteCardTokens.of(context).pillRadius,
            ),
            child: Text(
              '详情',
              style: TextStyle(
                color: siteInfo(context),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _MetricTile(
    this.icon,
    this.label,
    this.value,
    this.color,
    this.background,
  );
}

class _Card4Metric {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
  final bool twoLineValue;

  const _Card4Metric(
    this.icon,
    this.label,
    this.value,
    this.color,
    this.background, {
    this.twoLineValue = false,
  });
}

String _fmtRatio(num value) {
  final number = value.toDouble();
  if (!number.isFinite || number < 0) return '-';
  if (number >= 100000000) {
    return '${formatRatio(number / 100000000, digits: 2)}E';
  }
  if (number >= 1000000) return '${formatRatio(number / 1000000, digits: 2)}M';
  if (number >= 10000) return '${formatRatio(number / 10000, digits: 2)}W';
  if (number >= 1000) return '${formatRatio(number / 1000, digits: 2)}K';
  final digits = number >= 100
      ? 0
      : number >= 10
      ? 1
      : 2;
  return formatRatio(number, digits: digits);
}

double _numVal(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
