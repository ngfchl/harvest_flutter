import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'site_theme.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../../dashboard/provider/privacy_provider.dart';
import '../provider/site_card_style_provider.dart';
import '../provider/site_provider.dart';
import '../utils/site_level_milestone.dart';
import 'site_action_menu.dart';
import 'site_detail_sheet.dart';
import 'site_level_sheet.dart';

String _maskSiteName(String name, bool privacy) {
  if (!privacy) return name;
  if (name.isEmpty) return name;
  if (name.length <= 1) return '*';
  if (name.length == 2) return '${name[0]}*';
  return '${name[0]}*${name[name.length - 1]}';
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
      case SiteCardStyle.style1:
        break;
    }

    final status = site.latestStatus;
    final (dailyUp, dailyDown) = _calcDailyDelta();

    // 读取站点配置的满魔值
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final cs = shadcn.Theme.of(context).colorScheme;

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: siteRadius(context, size: "lg"),
          border: Border.all(color: cs.border, width: 1),
          boxShadow: [
            // 主阴影：更大的扩散和偏移
            BoxShadow(
              color: siteShadow(context, alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            // 边缘光：让卡片底部有微妙的深色边缘
            BoxShadow(
              color: siteShadow(context, alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _firstRow(context, status, config, privacy),
            const SizedBox(height: 3),
            _secondRow(context, status, config),
            if (status != null) ...[
              const SizedBox(height: 3),
              _thirdRow(context, status, dailyUp, dailyDown),
            ],
            if (status != null) ...[
              const SizedBox(height: 4),
              _fourthRow(context, status, spFull),
            ],
            if (site.tags.isNotEmpty ||
                site.latestStatusUpdatedText.isNotEmpty) ...[
              const SizedBox(height: 6),
              _fifthRow(context),
            ],
          ],
        ),
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
    final hasRight =
        (status != null && status.myLevel.isNotEmpty) ||
        site.signInText != null;
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
          if (status != null && status.myLevel.isNotEmpty)
            _levelBadge(context, status.myLevel),
          if (site.signInText != null) ...[
            const SizedBox(width: 4),
            _signBadge(context, site.signInText!),
          ],
        ],
      ],
    );
  }

  Widget _siteLogo(BuildContext context, WebSite? config, bool privacy) => _siteBrowserLogo(
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
    final hasMail = site.mail > 0;
    final hasNotice = site.notice > 0;
    final hasRight = hasMail || hasNotice || milestone != null;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: site.durationText.isEmpty
                ? const SizedBox.shrink()
                : _tooltipWrap(
                    context,
                    '注册时长',
                    _infoTag(context, Icons.access_time, site.durationText),
                  ),
          ),
        ),
        if (hasRight)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasMail)
                  _tooltipWrap(
                    context,
                    '短消息',
                    _indicator(
                      shadcn.LucideIcons.mail,
                      fmtCompact(site.mail.toDouble()),
                      siteInfo(context),
                    ),
                  ),
                if (hasNotice) ...[
                  if (hasMail) const SizedBox(width: 6),
                  _tooltipWrap(
                    context,
                    '公告通知',
                    _indicator(
                      shadcn.LucideIcons.bell,
                      fmtCompact(site.notice.toDouble()),
                      siteWarning(context),
                    ),
                  ),
                ],
                if (milestone != null) ...[
                  if (hasMail || hasNotice) const SizedBox(width: 8),
                  _levelMilestoneBadge(context, milestone),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _thirdRow(
    BuildContext context,
    SiteDailyStatus status,
    int dailyUp,
    int dailyDown,
  ) {
    final statuses = site.status;
    final hasDailyDelta = dailyUp != 0 || dailyDown != 0;
    int yesterdaySeedVolume = 0;
    if (statuses != null && statuses.length >= 2) {
      final sorted = statuses.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      yesterdaySeedVolume = sorted[sorted.length - 2].value.seedVolume;
    }

    final cs = shadcn.Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.15),
        borderRadius: siteRadius(context, size: "sm"),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 总量 ──
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '总量',
                  style: TextStyle(
                    fontSize: 8,
                    color: cs.mutedForeground.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniStat(
                      Icons.arrow_circle_up_outlined,
                      fmtBytes(status.uploaded),
                      siteSuccess(context),
                    ),
                    const SizedBox(width: 6),
                    _miniStat(
                      Icons.arrow_circle_down_outlined,
                      fmtBytes(status.downloaded),
                      siteDanger(context),
                    ),
                  ],
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
          // ── 今日增量 ──
          if (hasDailyDelta) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '今日',
                    style: TextStyle(
                      fontSize: 8,
                      color: cs.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniStat(
                        Icons.arrow_circle_up_outlined,
                        _fmtSignedBytes(dailyUp),
                        siteSuccess(context),
                      ),
                      const SizedBox(width: 6),
                      _miniStat(
                        Icons.arrow_circle_down_outlined,
                        _fmtSignedBytes(dailyDown),
                        siteDanger(context),
                      ),
                    ],
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
          ],
          // ── 做种量对比 ──
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '做种量',
                  style: TextStyle(
                    fontSize: 8,
                    color: cs.mutedForeground.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fmtBytes(yesterdaySeedVolume),
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.mutedForeground.withValues(alpha: 0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 9,
                        color: cs.mutedForeground.withValues(alpha: 0.3),
                      ),
                    ),
                    Text(
                      fmtBytes(status.seedVolume),
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.mutedForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
    double spFull,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tooltipWrap(
          context,
          '做种数',
          _labeledStat(
            context,
            Icons.eco_outlined,
            fmtCompact(status.seed.toDouble()),
          ),
        ),
        _tooltipWrap(
          context,
          '下载数',
          _labeledStat(
            context,
            Icons.leak_add_outlined,
            fmtCompact(status.leech.toDouble()),
          ),
        ),
        _tooltipWrap(
          context,
          '做种积分',
          _labeledStat(context, Icons.star_outline, fmtCompact(status.myScore)),
        ),
        _tooltipWrap(
          context,
          '魔力值',
          _labeledStat(
            context,
            Icons.diamond_outlined,
            fmtCompact(status.myBonus),
          ),
        ),
        _tooltipWrap(
          context,
          '发布数',
          _labeledStat(
            context,
            Icons.edit_note,
            fmtCompact(status.publish.toDouble()),
          ),
        ),
        _tooltipWrap(
          context,
          '分享率',
          _labeledStat(context, Icons.show_chart, _fmtRatio(status.ratio)),
        ),
        _tooltipWrap(
          context,
          '时魔比率',
          _magicBadge(context, status.bonusHour, spFull),
        ),
      ],
    );
  }

  Widget _fifthRow(BuildContext context) {
    final updateText = site.latestStatusUpdatedText;
    final updateAt = site.latestStatusUpdatedAt?.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 3,
            runSpacing: 2,
            children: site.tags
                .take(4)
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: shadcn.Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: siteRadius(context, size: "xs"),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontSize: 9,
                        color: shadcn.Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (updateText.isNotEmpty) ...[
          const SizedBox(width: 8),
          _tooltipWrap(
            context,
            updateAt == null || updateAt.isEmpty
                ? '最后更新：$updateText'
                : '最后更新：$updateAt',
            _infoTag(context, Icons.update, updateText),
          ),
        ],
      ],
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
      color: available ? siteSuccess(context) : siteDanger(context, alpha: 0.72),
    ),
  );

  Widget _levelBadge(BuildContext context, String lv) => GestureDetector(
    onTap: () => openLevelInfo(context, site: site),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: levelColor(lv).withValues(alpha: 0.12),
        borderRadius: siteRadius(context, size: "xs"),
      ),
      child: Text(
        lv,
        style: TextStyle(
          fontSize: 9,
          color: levelColor(lv),
          fontWeight: FontWeight.w600,
        ),
      ),
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

  Widget _signBadge(BuildContext context, String text) {
    final ok = text.contains('已');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: (ok ? siteSuccess(context) : siteWarning(context)).withValues(alpha: 0.12),
        borderRadius: siteRadius(context, size: "xs"),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: ok ? siteSuccess(context) : siteWarning(context),
          fontWeight: FontWeight.w600,
        ),
      ),
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

  Widget _miniStat(IconData icon, String value, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _labeledStat(BuildContext context, IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 11,
        color: shadcn.Theme.of(
          context,
        ).colorScheme.mutedForeground.withValues(alpha: 0.6),
      ),
      const SizedBox(width: 1),
      Text(
        value,
        style: TextStyle(
          fontSize: 10,
          color: shadcn.Theme.of(context).colorScheme.mutedForeground,
        ),
      ),
    ],
  );

  Widget _indicator(IconData icon, String v, Color c) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: c),
      const SizedBox(width: 2),
      Text(v, style: TextStyle(fontSize: 10, color: c)),
    ],
  );

  /// 时魔比率：当前时魔 / 满魔
  Widget _magicBadge(BuildContext context, double current, double full) {
    final ratio = full > 0 ? current / full : 0.0;
    final pct = (ratio * 100).round();
    final color = ratio >= 1.0
        ? siteSuccess(context)
        : ratio >= 0.5
        ? siteWarning(context)
        : siteDanger(context, alpha: 0.82);
    final display = full > 0
        ? '${fmtCompact(current)}($pct%)'
        : fmtCompact(current);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: siteRadius(context, size: "xs"),
      ),
      child: Text(
        display,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
  if (full <= 0) return fmtCompact(current);
  final pct = ((current / full) * 100).round();
  return '${fmtCompact(current)}($pct%)';
}

String _localSiteIconUrl(String siteName) {
  final name = siteName.trim();
  final base = AppConfig.baseUrl.trim();
  if (name.isEmpty || base.isEmpty) return '';

  final baseUri = Uri.tryParse(base.endsWith('/') ? base : '$base/');
  if (baseUri == null || !baseUri.hasScheme) return '';
  return baseUri
      .resolve('local/icons/${Uri.encodeComponent(name)}.png')
      .toString();
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
    final localIcon = _localSiteIconUrl(siteName);
    final siteLogo = _siteLogoUrl(config);
    final fallback = _fallback();

    return Container(
      width: size,
      height: size,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: localIcon.isEmpty
          ? _cachedImage(siteLogo, fallback: fallback)
          : CachedNetworkImage(
              imageUrl: localIcon,
              httpHeaders: _localSiteIconHeaders(),
              fit: BoxFit.cover,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) =>
                  _cachedImage(siteLogo, fallback: fallback),
            ),
    );
  }

  Widget _cachedImage(String url, {required Widget fallback}) {
    if (url.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
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
  return shadcn.Tooltip(tooltip: (_) => Text(text), child: child);
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

Widget _siteSignBadge(BuildContext context, String text) {
  final signed = text == '已签到';
  final color = signed ? siteSuccess(context) : siteWarning(context);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: siteRadius(context, size: "xs"),
      border: Border.all(color: color.withValues(alpha: 0.18), width: 0.6),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10,
        color: color,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    ),
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
}) {
  final color = milestone.color(context);
  final isDark = shadcn.Theme.of(context).brightness == Brightness.dark;
  final text = Text(
    milestone.label,
    style: TextStyle(
      fontSize: fontSize,
      color: isDark ? color.withValues(alpha: 0.96) : color,
      fontWeight: FontWeight.w900,
      height: 1.1,
    ),
  );

  return _siteTooltip(
    milestone.tooltip,
    Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: isDark ? 0.22 : 0.16),
            color.withValues(alpha: isDark ? 0.09 : 0.06),
          ],
        ),
        borderRadius: siteRadius(context, size: radius <= 3 ? "xs" : "sm"),
        border: Border.all(color: color.withValues(alpha: 0.32), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.18 : 0.14),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: -3,
          ),
        ],
      ),
      child: iconSize == null
          ? text
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize + 5,
                  height: iconSize + 5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: isDark ? 0.20 : 0.13),
                  ),
                  child: Icon(milestone.icon, size: iconSize, color: color),
                ),
                const SizedBox(width: 4),
                text,
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
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final delta = _siteDailyDelta(site);
    final dividerColor = _dividerColor(context);
    final cardColor = _cardColor(context);

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: siteRadius(context, size: "xl"),
          border: Border.all(color: _borderColor(context), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: _isDark(context)
                  ? Colors.black.withValues(alpha: 0.22)
                  : siteShadow(context, alpha: 0.07),
              blurRadius: 22,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: status == null
            ? _emptyCard(context, config)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, status, config),
                  const SizedBox(height: 9),
                  _mainMetrics(context, status, delta),
                  const SizedBox(height: 8),
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
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    return Row(
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
                  if (signStatus != null) ...[
                    const SizedBox(width: 8),
                    _siteSignBadge(context, signStatus),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '暂无站点数据',
                style: TextStyle(fontSize: 12, color: _mutedText(context)),
              ),
            ],
          ),
        ),
        Icon(
          shadcn.LucideIcons.chevronRight,
          color: _mutedText(context),
          size: 20,
        ),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    SiteDailyStatus status,
    WebSite? config,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final updateText = site.latestStatusUpdatedText;
    final milestone = _siteLevelMilestone(config, status);
    final signStatus = _siteSignStatus(site, config);

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
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: _siteTooltip(
                      updateText.isEmpty
                          ? '-'
                          : '更新于 ${site.latestStatusUpdatedAt ?? updateText}',
                      Text(
                        updateText.isEmpty ? '-' : '更新于 $updateText',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                  if (signStatus != null) ...[
                    const SizedBox(width: 6),
                    _siteSignBadge(context, signStatus),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    shadcn.LucideIcons.chevronRight,
                    color: _mutedText(context),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      site.timeJoin == null || site.timeJoin!.trim().isEmpty
                          ? '注册于 -'
                          : '注册于 ${_dateOnly(site.timeJoin!)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: _mutedText(context).withValues(alpha: 0.86),
                        height: 1.1,
                      ),
                    ),
                  ),
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
        Text.rich(
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
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
          color: (available ? siteSuccess(context) : siteDanger(context)).withValues(alpha: 0.28),
          blurRadius: 6,
        ),
      ],
    ),
  );

  Widget _verticalDivider(BuildContext context) =>
      Container(width: 1, height: 38, color: _dividerColor(context));

  bool _isDark(BuildContext context) =>
      shadcn.Theme.of(context).colorScheme.brightness == Brightness.dark;

  Color _cardColor(BuildContext context) => _isDark(context)
      ? Color.alphaBlend(
          shadcn.Theme.of(context).colorScheme.muted.withValues(alpha: 0.10),
          shadcn.Theme.of(context).colorScheme.background,
        )
      : siteColors(context).background;

  Color _borderColor(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.56)
      : siteColors(context).border;

  Color _dividerColor(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.38)
      : siteColors(context).border.withValues(alpha: 0.74);

  Color _titleText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.foreground
      : siteColors(context).foreground;

  Color _mutedText(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.mutedForeground
      : siteColors(context).mutedForeground;

  Color _logoBorder(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.9)
      : siteColors(context).background.withValues(alpha: 0.9);

  String _dateOnly(String value) {
    final text = value.trim();
    if (text.length >= 10) return text.substring(0, 10);
    return text;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = site.latestStatus;
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final delta = _siteDailyDelta(site);

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: _cardColor(context),
          borderRadius: siteRadius(context, size: "xl"),
          border: Border.all(color: _borderColor(context), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: _isDark(context)
                  ? Colors.black.withValues(alpha: 0.24)
                  : siteShadow(context, alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: status == null
            ? _emptyCard(context, ref, config)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _top(context, status, config),
                  const SizedBox(height: 12),
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
                          icon: shadcn.LucideIcons.cloudUpload,
                          accent: siteInfo(context),
                          background: _softTileColor(
                            context,
                            siteInfo(context, alpha: 0.14),
                            siteInfo(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _trafficTile(
                          context,
                          label: '下载',
                          value: fmtBytes(status.downloaded),
                          delta: _fmtSignedBytes(delta.down),
                          deltaColor: siteDanger(context),
                          caption: '总计下载流量',
                          icon: shadcn.LucideIcons.cloudDownload,
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
                  const SizedBox(height: 5),
                  _smallGrid(context, status, spFull),
                  const SizedBox(height: 8),
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: _dividerColor(context),
                  ),
                  const SizedBox(height: 8),
                  _footer(context, ref, status),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WidgetRef ref, WebSite? config) {
    final signStatus = _siteSignStatus(site, config);
    return Row(
      children: [
        _siteLogo(context, config, 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _title(context)),
                  if (signStatus != null) ...[
                    const SizedBox(width: 8),
                    _siteSignBadge(context, signStatus),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                '暂无站点数据',
                style: TextStyle(
                  color: _mutedText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _actionMenuButton(context, ref),
      ],
    );
  }

  Widget _top(BuildContext context, SiteDailyStatus status, WebSite? config) {
    final milestone = _siteLevelMilestone(config, status);
    final signStatus = _siteSignStatus(site, config);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _siteLogo(context, config, 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _title(context)),
                  if (status.myLevel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _levelPill(context, status.myLevel),
                  ],
                  const SizedBox(width: 6),
                  _invitePill(context, status.invitation),
                  if (signStatus != null) ...[
                    const SizedBox(width: 6),
                    _siteSignBadge(context, signStatus),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 14,
                    color: _mutedText(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      site.durationText.isEmpty ? '-' : site.durationText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _mutedText(context).withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (milestone != null) ...[
                    const SizedBox(width: 8),
                    _siteLevelMilestoneBadge(
                      context,
                      milestone,
                      fontSize: 12,
                      horizontal: 9,
                      vertical: 5,
                      radius: 16,
                      iconSize: 13,
                    ),
                  ],
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
    required IconData icon,
    required Color accent,
    required Color background,
  }) {
    final tooltip = delta.isEmpty
        ? '$label: $value'
        : '$label: $value ($delta)';
    return _siteTooltip(
      tooltip,
      Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: background,
          borderRadius: siteRadius(context, size: "xl"),
          border: Border.all(color: accent.withValues(alpha: 0.12), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 21,
                  height: 21,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: siteRadius(context, size: "sm"),
                  ),
                  child: Icon(icon, size: 13, color: accent),
                ),
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
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _titleText(context).withValues(alpha: 0.86),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                if (delta.isNotEmpty) ...[
                  const SizedBox(width: 5),
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
            const SizedBox(height: 5),
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
        shadcn.LucideIcons.leaf,
        '做种',
        fmtCompact(status.seed.toDouble()),
        siteSuccess(context),
        _softTileColor(context, siteSuccess(context, alpha: 0.14), siteSuccess(context)),
      ),
      _MetricTile(
        shadcn.LucideIcons.arrowDownToLine,
        '下载中',
        fmtCompact(status.leech.toDouble()),
        siteInfo(context),
        _softTileColor(context, siteInfo(context, alpha: 0.14), siteInfo(context)),
      ),
      _MetricTile(
        shadcn.LucideIcons.coins,
        '魔力',
        fmtCompact(status.myBonus),
        siteWarning(context),
        _softTileColor(context, siteWarning(context, alpha: 0.14), siteWarning(context)),
      ),
      _MetricTile(
        shadcn.LucideIcons.gem,
        '积分',
        fmtCompact(status.myScore),
        siteAccent(context, 3),
        _softTileColor(context, siteAccent(context, 3, alpha: 0.14), siteAccent(context, 3)),
      ),
      _MetricTile(
        shadcn.LucideIcons.scale,
        '分享率',
        _fmtRatio(status.ratio),
        siteAccent(context, 4),
        _softTileColor(context, siteAccent(context, 4, alpha: 0.14), siteAccent(context, 4)),
      ),
      _MetricTile(
        shadcn.LucideIcons.zap,
        '时魔',
        _fmtMagicWithRatio(status.bonusHour, spFull),
        siteAccent(context, 5),
        _softTileColor(context, siteAccent(context, 5, alpha: 0.14), siteAccent(context, 5)),
      ),
      _MetricTile(
        shadcn.LucideIcons.rocket,
        '发种',
        fmtCompact(status.publish.toDouble()),
        siteAccent(context, 6),
        _softTileColor(context, siteAccent(context, 6, alpha: 0.14), siteAccent(context, 6)),
      ),
      _MetricTile(
        shadcn.LucideIcons.hardDrive,
        '做种量',
        fmtBytes(status.seedVolume),
        siteAccent(context, 7),
        _softTileColor(context, siteAccent(context, 7, alpha: 0.14), siteAccent(context, 7)),
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          Row(
            children: [
              for (var col = 0; col < 4; col++) ...[
                Expanded(child: _metricTile(context, tiles[row * 4 + col])),
                if (col != 3) const SizedBox(width: 7),
              ],
            ],
          ),
          if (row != 1) const SizedBox(height: 7),
        ],
      ],
    );
  }

  Widget _metricTile(BuildContext context, _MetricTile item) {
    final tile = Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: siteRadius(context, size: "lg"),
        border: Border.all(color: item.color.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 19,
            height: 19,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              borderRadius: siteRadius(context, size: "sm"),
            ),
            child: Icon(item.icon, size: 12, color: item.color),
          ),
          const SizedBox(height: 3),
          Text(
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
          const SizedBox(height: 3),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _titleText(context).withValues(alpha: 0.86),
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
    final text = status.updated_at.trim().isNotEmpty
        ? status.updated_at.trim()
        : (site.latestStatusUpdatedAt ?? '').trim();
    return Row(
      children: [
        Expanded(
          child: _siteTooltip(
            text.isEmpty ? '同步： -' : '同步： $text',
            Text(
              '同步： ${text.isEmpty ? '-' : text}',
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
              borderRadius: siteRadius(context, size: "xl"),
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
        const SizedBox(width: 10),
        _actionMenuButton(context, ref),
      ],
    );
  }

  Widget _actionMenuButton(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (buttonContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final renderObject = buttonContext.findRenderObject();
          final position = renderObject is RenderBox
              ? renderObject.localToGlobal(Offset(renderObject.size.width, 0))
              : Offset.zero;
          showSiteActionMenu(
            context: buttonContext,
            ref: ref,
            site: site,
            position: position,
          );
        },
        child: _moreCircle(context),
      ),
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

  Widget _levelPill(BuildContext context, String level) {
    final accent = siteWarning(context);
    return GestureDetector(
      onTap: () => openLevelInfo(context, site: site),
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: _softTileColor(context, siteWarning(context, alpha: 0.08), accent),
          borderRadius: siteRadius(context, size: "xl"),
          border: Border.all(
            color: _isDark(context)
                ? accent.withValues(alpha: 0.22)
                : siteWarning(context, alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 13, color: accent.withValues(alpha: 0.72)),
            const SizedBox(width: 4),
            Text(
              level,
              style: TextStyle(
                color: _mutedText(context).withValues(alpha: 0.82),
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

  Widget _invitePill(BuildContext context, int invitation) {
    final accent = siteInfo(context);
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _softTileColor(context, siteInfo(context, alpha: 0.08), accent),
        borderRadius: siteRadius(context, size: "xl"),
        border: Border.all(
          color: _isDark(context)
              ? accent.withValues(alpha: 0.22)
              : siteInfo(context, alpha: 0.16),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 12, color: accent.withValues(alpha: 0.68)),
          const SizedBox(width: 4),
          Text(
            '邀请 ${fmtCompact(invitation.toDouble())}',
            style: TextStyle(
              color: _mutedText(context).withValues(alpha: 0.80),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moreCircle(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _isDark(context)
              ? shadcn.Theme.of(context).colorScheme.border
              : siteInfo(context, alpha: 0.34),
          width: 1.4,
        ),
      ),
      child: Icon(
        Icons.more_horiz,
        size: 20,
        color: _isDark(context)
            ? shadcn.Theme.of(context).colorScheme.mutedForeground
            : siteInfo(context),
      ),
    );
  }

  bool _isDark(BuildContext context) =>
      shadcn.Theme.of(context).colorScheme.brightness == Brightness.dark;

  Color _cardColor(BuildContext context) => _isDark(context)
      ? Color.alphaBlend(
          shadcn.Theme.of(context).colorScheme.muted.withValues(alpha: 0.08),
          shadcn.Theme.of(context).colorScheme.background,
        )
      : siteColors(context).background;

  Color _borderColor(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.54)
      : siteColors(context).border;

  Color _dividerColor(BuildContext context) => _isDark(context)
      ? shadcn.Theme.of(context).colorScheme.border.withValues(alpha: 0.36)
      : siteColors(context).border.withValues(alpha: 0.74);

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

class _MetricTile {
  final IconData icon;
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

String _fmtRatio(num value) => fmtRatio(value);

double _numVal(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
