import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/config/app_config.dart';
import 'package:harvest/core/storage/hive_manager.dart';
import 'package:harvest/core/storage/storage_keys.dart';
import 'package:harvest/core/utils/utils.dart';

import '../model/site_config.dart';
import '../model/site_info.dart';
import '../provider/site_card_style_provider.dart';
import '../provider/site_provider.dart';
import 'site_action_menu.dart';
import 'site_level_sheet.dart';

class SiteCard extends ConsumerWidget {
  final SiteInfo site;

  const SiteCard({super.key, required this.site});

  (int up, int down) _calcDailyDelta() {
    final statuses = site.status;
    if (statuses == null || statuses.length < 2) return (0, 0);
    final sorted = statuses.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final newest = sorted.last.value;
    final prev = sorted[sorted.length - 2].value;
    return (newest.uploaded - prev.uploaded, newest.downloaded - prev.downloaded);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(siteCardStyleProvider)) {
      case SiteCardStyle.style2:
        return SiteCard2(site: site);
      case SiteCardStyle.style3:
        return SiteCard3(site: site);
      case SiteCardStyle.style1:
        break;
    }

    final status = site.latestStatus;
    final (dailyUp, dailyDown) = _calcDailyDelta();

    // 读取站点配置的满魔值
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final cs = FTheme.of(context).colors;

    return SiteActionMenu(
      site: site,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: BorderRadius.circular(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _firstRow(context, status, config),
            const SizedBox(height: 3),
            _secondRow(context, status),
            if (status != null) ...[const SizedBox(height: 3), _thirdRow(context, status, dailyUp, dailyDown)],
            if (status != null) ...[const SizedBox(height: 4), _fourthRow(context, status, spFull)],
            if (site.tags.isNotEmpty || site.latestStatusUpdatedText.isNotEmpty) ...[
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

  Widget _firstRow(BuildContext context, SiteDailyStatus? status, WebSite? config) {
    final hasRight = (status != null && status.myLevel.isNotEmpty) || site.signInText != null;
    return Row(
      children: [
        _siteLogo(context, config),
        const SizedBox(width: 5),
        _statusDot(site.available),
        const SizedBox(width: 5),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: site.site,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                if (site.nickname.isNotEmpty && site.nickname != site.site)
                  TextSpan(
                    text: ' ${site.nickname}',
                    style: TextStyle(fontSize: 11, color: context.theme.colors.mutedForeground),
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (hasRight) ...[
          const SizedBox(width: 6),
          if (status != null && status.myLevel.isNotEmpty) _levelBadge(context, status.myLevel),
          if (site.signInText != null) ...[const SizedBox(width: 4), _signBadge(context, site.signInText!)],
        ],
      ],
    );
  }

  Widget _siteLogo(BuildContext context, WebSite? config) => _SiteLogoImage(
    siteName: site.site,
    config: config,
    size: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.theme.colors.muted,
      border: Border.all(color: context.theme.colors.border, width: 0.8),
    ),
    fallbackStyle: TextStyle(color: context.theme.colors.foreground, fontSize: 10, fontWeight: FontWeight.w800),
  );

  Widget _secondRow(BuildContext context, SiteDailyStatus? status) {
    return Row(
      children: [
        if (site.durationText.isNotEmpty)
          _tooltipWrap(context, '注册时长', _infoTag(context, Icons.access_time, site.durationText)),
        const Spacer(),
        if (site.mail > 0) _tooltipWrap(context, '短消息', _indicator(FIcons.mail, fmtCompact(site.mail.toDouble()), Colors.blue)),
        if (site.notice > 0) ...[
          const SizedBox(width: 6),
          _tooltipWrap(context, '公告通知', _indicator(FIcons.bell, fmtCompact(site.notice.toDouble()), Colors.orange)),
        ],
      ],
    );
  }

  Widget _thirdRow(BuildContext context, SiteDailyStatus status, int dailyUp, int dailyDown) {
    final statuses = site.status;
    final hasDailyDelta = dailyUp != 0 || dailyDown != 0;
    int yesterdaySeedVolume = 0;
    if (statuses != null && statuses.length >= 2) {
      final sorted = statuses.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      yesterdaySeedVolume = sorted[sorted.length - 2].value.seedVolume;
    }

    final cs = context.theme.colors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(color: cs.muted.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 总量 ──
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('总量', style: TextStyle(fontSize: 8, color: cs.mutedForeground.withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _miniStat(Icons.arrow_circle_up_outlined, fmtBytes(status.uploaded), Colors.green.shade700),
                    const SizedBox(width: 6),
                    _miniStat(Icons.arrow_circle_down_outlined, fmtBytes(status.downloaded), Colors.red.shade600),
                  ],
                ),
              ],
            ),
          ),
          // 分隔
          Container(width: 0.5, height: 24, color: cs.border.withValues(alpha: 0.4)),
          // ── 今日增量 ──
          if (hasDailyDelta) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('今日', style: TextStyle(fontSize: 8, color: cs.primary.withValues(alpha: 0.7))),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _miniStat(Icons.arrow_circle_up_outlined, _fmtSignedBytes(dailyUp), Colors.green.shade700),
                      const SizedBox(width: 6),
                      _miniStat(Icons.arrow_circle_down_outlined, _fmtSignedBytes(dailyDown), Colors.red.shade600),
                    ],
                  ),
                ],
              ),
            ),
            // 分隔
            Container(width: 0.5, height: 24, color: cs.border.withValues(alpha: 0.4)),
          ],
          // ── 做种量对比 ──
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('做种量', style: TextStyle(fontSize: 8, color: cs.mutedForeground.withValues(alpha: 0.6))),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      fmtBytes(yesterdaySeedVolume),
                      style: TextStyle(fontSize: 10, color: cs.mutedForeground.withValues(alpha: 0.5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(Icons.arrow_forward, size: 9, color: cs.mutedForeground.withValues(alpha: 0.3)),
                    ),
                    Text(
                      fmtBytes(status.seedVolume),
                      style: TextStyle(fontSize: 10, color: cs.mutedForeground, fontWeight: FontWeight.w500),
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

  Widget _fourthRow(BuildContext context, SiteDailyStatus status, double spFull) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tooltipWrap(context, '做种数', _labeledStat(context, Icons.eco_outlined, fmtCompact(status.seed.toDouble()))),
        _tooltipWrap(context, '下载数', _labeledStat(context, Icons.leak_add_outlined, fmtCompact(status.leech.toDouble()))),
        _tooltipWrap(context, '做种积分', _labeledStat(context, Icons.star_outline, fmtCompact(status.myScore))),
        _tooltipWrap(context, '魔力值', _labeledStat(context, Icons.diamond_outlined, fmtCompact(status.myBonus))),
        _tooltipWrap(context, '发布数', _labeledStat(context, Icons.edit_note, fmtCompact(status.publish.toDouble()))),
        _tooltipWrap(context, '分享率', _labeledStat(context, Icons.show_chart, _fmtRatio(status.ratio))),
        _tooltipWrap(context, '时魔比率', _magicBadge(context, status.bonusHour, spFull)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: context.theme.colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 9, color: context.theme.colors.primary)),
                  ),
                )
                .toList(),
          ),
        ),
        if (updateText.isNotEmpty) ...[
          const SizedBox(width: 8),
          _tooltipWrap(
            context,
            updateAt == null || updateAt.isEmpty ? '最后更新：$updateText' : '最后更新：$updateAt',
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

  Widget _statusDot(bool available) => Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(shape: BoxShape.circle, color: available ? Colors.green : Colors.red.shade300),
  );

  Widget _levelBadge(BuildContext context, String lv) => GestureDetector(
    onTap: () => openLevelInfo(context, site: site),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: levelColor(lv).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(3)),
      child: Text(
        lv,
        style: TextStyle(fontSize: 9, color: levelColor(lv), fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _signBadge(BuildContext context, String text) {
    final ok = text.contains('已');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: (ok ? Colors.green : Colors.orange).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          color: ok ? Colors.green.shade700 : Colors.orange.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoTag(BuildContext context, IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 9, color: context.theme.colors.mutedForeground.withValues(alpha: 0.6)),
      const SizedBox(width: 2),
      Text(text, style: TextStyle(fontSize: 10, color: context.theme.colors.mutedForeground)),
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
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _labeledStat(BuildContext context, IconData icon, String value) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: context.theme.colors.mutedForeground.withValues(alpha: 0.6)),
      const SizedBox(width: 1),
      Text(value, style: TextStyle(fontSize: 10, color: context.theme.colors.mutedForeground)),
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
        ? Colors.green
        : ratio >= 0.5
        ? Colors.orange
        : Colors.red.shade400;
    final display = full > 0 ? '${fmtCompact(current)}($pct%)' : fmtCompact(current);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(3)),
      child: Text(
        display,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

({int up, int down}) _siteDailyDelta(SiteInfo site) {
  final statuses = site.status;
  if (statuses == null || statuses.length < 2) return (up: 0, down: 0);
  final sorted = statuses.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  final newest = sorted.last.value;
  final prev = sorted[sorted.length - 2].value;
  return (up: newest.uploaded - prev.uploaded, down: newest.downloaded - prev.downloaded);
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
  return baseUri.resolve('local/icons/${Uri.encodeComponent(name)}.png').toString();
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

  const _SiteLogoImage({
    required this.siteName,
    required this.config,
    required this.size,
    required this.decoration,
    required this.fallbackStyle,
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
              errorWidget: (_, __, ___) => _cachedImage(siteLogo, fallback: fallback),
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
    final name = siteName.trim();
    final text = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Center(child: Text(text, style: fallbackStyle));
  }
}

Widget _siteTooltip(String text, Widget child) {
  return FTooltip(
    longPress: false,
    tipBuilder: (_, __) => Text(text),
    child: child,
  );
}

class SiteCard2 extends ConsumerWidget {
  final SiteInfo site;

  const SiteCard2({super.key, required this.site});

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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor(context), width: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDark(context) ? 0.22 : 0.07),
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
                  _header(context, config),
                  const SizedBox(height: 9),
                  _mainMetrics(context, status, delta),
                  const SizedBox(height: 8),
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
                  _minorRow(context, [
                    _MinorMetric(Icons.groups_outlined, '做种数', fmtCompact(status.seed.toDouble()), const Color(0xFF53658B)),
                    _MinorMetric(Icons.arrow_downward, '下载数', fmtCompact(status.leech.toDouble()), const Color(0xFF53658B)),
                    _MinorMetric(Icons.arrow_upward, '做种量', fmtBytes(status.seedVolume), const Color(0xFF53658B)),
                  ]),
                  Divider(height: 1, thickness: 0.6, color: dividerColor),
                  _minorRow(context, [
                    _MinorMetric(FIcons.diamond, '魔力值', fmtCompact(status.myBonus), const Color(0xFF7C3AED)),
                    _MinorMetric(Icons.star_outline, '做种积分', fmtCompact(status.myScore), const Color(0xFFFF8A00)),
                    _MinorMetric(Icons.schedule_outlined, '时魔', _fmtMagicWithRatio(status.bonusHour, spFull), const Color(0xFF1D6BFF)),
                  ]),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WebSite? config) {
    return Row(
      children: [
        _siteLogo(context, config),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _siteTitle(context),
              const SizedBox(height: 4),
              Text('暂无站点数据', style: TextStyle(fontSize: 12, color: _mutedText(context))),
            ],
          ),
        ),
        Icon(FIcons.chevronRight, color: _mutedText(context), size: 20),
      ],
    );
  }

  Widget _header(BuildContext context, WebSite? config) {
    final cs = context.theme.colors;
    final updateText = site.latestStatusUpdatedText;

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
                  _statusDot(site.available),
                  const SizedBox(width: 8),
                  Expanded(child: _siteTitle(context)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      site.timeJoin == null || site.timeJoin!.trim().isEmpty
                          ? '注册于 -'
                          : '注册于 ${_dateOnly(site.timeJoin!)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: _mutedText(context).withValues(alpha: 0.86), height: 1.1),
                    ),
                  ),
                  for (final tag in site.tags.take(1)) ...[const SizedBox(width: 6), _tagBadge(context, tag)],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _siteTooltip(
          updateText.isEmpty ? '-' : '更新于 ${site.latestStatusUpdatedAt ?? updateText}',
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 96),
            child: Text(
              updateText.isEmpty ? '-' : '更新于 $updateText',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, color: cs.mutedForeground),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Icon(FIcons.chevronRight, color: _mutedText(context), size: 20),
      ],
    );
  }

  Widget _mainMetrics(BuildContext context, SiteDailyStatus status, ({int up, int down}) delta) {
    return Row(
      children: [
        Expanded(
          child: _largeMetric(
            context,
            value: fmtBytes(status.uploaded),
            delta: _fmtSignedBytes(delta.up),
            label: '上传量',
            color: const Color(0xFF16A34A),
          ),
        ),
        _verticalDivider(context),
        Expanded(
          child: _largeMetric(
            context,
            value: fmtBytes(status.downloaded),
            delta: _fmtSignedBytes(delta.down),
            label: '下载量',
            color: const Color(0xFFFF2D2D),
          ),
        ),
        _verticalDivider(context),
        Expanded(
          child: _largeMetric(context, value: _fmtRatio(status.ratio), label: '分享率', color: const Color(0xFF1D6BFF)),
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
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: color, height: 1),
              ),
              if (parts.unit.isNotEmpty)
                TextSpan(
                  text: ' ${parts.unit}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color, height: 1),
                ),
              if (delta != null && delta.isNotEmpty)
                TextSpan(
                  text: ' $delta',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.72), height: 1),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: _mutedText(context), height: 1, fontWeight: FontWeight.w500),
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
    final iconColor = _isDark(context) && item.color == const Color(0xFF53658B)
        ? _mutedText(context)
        : item.color;
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 15, color: iconColor),
        const SizedBox(width: 4),
        Flexible(
          flex: 3,
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: _mutedText(context), fontWeight: FontWeight.w600, height: 1.1),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          flex: 4,
          child: Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: _titleText(context), fontWeight: FontWeight.w800, height: 1.1),
          ),
        ),
      ],
    );
    return _siteTooltip('${item.label}: ${item.value}', row);
  }

  Widget _siteLogo(BuildContext context, WebSite? config) {
    return _SiteLogoImage(
      siteName: site.site,
      config: config,
      size: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF17233F),
        border: Border.all(color: _logoBorder(context), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      fallbackStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
    );
  }

  Widget _siteTitle(BuildContext context) {
    final title = site.nickname.isNotEmpty ? site.nickname : site.site;
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(fontSize: 18, height: 1.05, color: _titleText(context), fontWeight: FontWeight.w800),
    );
  }

  Widget _statusDot(bool available) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      color: available ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (available ? const Color(0xFF22C55E) : const Color(0xFFEF4444)).withValues(alpha: 0.28),
          blurRadius: 6,
        ),
      ],
    ),
  );

  Widget _tagBadge(BuildContext context, String tag) {
    final color = _tagColor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(5)),
      child: Text(
        tag,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, height: 1.1),
      ),
    );
  }

  Color _tagColor(String tag) {
    if (tag.contains('官')) return const Color(0xFF16A34A);
    if (tag.contains('二次元')) return const Color(0xFF1D6BFF);
    if (tag.contains('影视')) return const Color(0xFF7C3AED);
    if (tag.contains('原')) return const Color(0xFFFF3B30);
    return const Color(0xFF7C3AED);
  }

  Widget _verticalDivider(BuildContext context) => Container(width: 1, height: 38, color: _dividerColor(context));

  bool _isDark(BuildContext context) => context.theme.colors.brightness == Brightness.dark;

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.muted.withValues(alpha: 0.38) : Colors.white;

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.border.withValues(alpha: 0.82) : const Color(0xFFE8EDF6);

  Color _dividerColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.border.withValues(alpha: 0.62) : const Color(0xFFE7ECF5);

  Color _titleText(BuildContext context) =>
      _isDark(context) ? context.theme.colors.foreground : const Color(0xFF0F1B3D);

  Color _mutedText(BuildContext context) =>
      _isDark(context) ? context.theme.colors.mutedForeground : const Color(0xFF66769A);

  Color _logoBorder(BuildContext context) =>
      _isDark(context) ? context.theme.colors.border.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9);

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

  const SiteCard3({super.key, required this.site});

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
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderColor(context), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDark(context) ? 0.24 : 0.06),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: status == null
            ? _emptyCard(context, config)
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
                          deltaColor: const Color(0xFF16A34A),
                          caption: '总计上传流量',
                          icon: '☁',
                          accent: const Color(0xFF4779BE),
                          background: _softTileColor(context, const Color(0xFFEAF3FF), const Color(0xFF4779BE)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _trafficTile(
                          context,
                          label: '下载',
                          value: fmtBytes(status.downloaded),
                          delta: _fmtSignedBytes(delta.down),
                          deltaColor: const Color(0xFFFF2D2D),
                          caption: '总计下载流量',
                          icon: '📥',
                          accent: const Color(0xFF16A36A),
                          background: _softTileColor(context, const Color(0xFFE9F8EF), const Color(0xFF16A36A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  _smallGrid(context, status, spFull),
                  const SizedBox(height: 8),
                  Divider(height: 1, thickness: 0.6, color: _dividerColor(context)),
                  const SizedBox(height: 8),
                  _footer(context, status),
                ],
              ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context, WebSite? config) {
    return Row(
      children: [
        _siteLogo(config, 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context),
              const SizedBox(height: 5),
              Text(
                '暂无站点数据',
                style: TextStyle(color: _mutedText(context), fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        _moreCircle(context),
      ],
    );
  }

  Widget _top(BuildContext context, SiteDailyStatus status, WebSite? config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _siteLogo(config, 54),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.badge_outlined, size: 14, color: _mutedText(context)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      site.durationText.isEmpty ? '-' : site.durationText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _mutedText(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (status.myLevel.isNotEmpty) _levelPill(context, status.myLevel),
            const SizedBox(height: 6),
            _invitePill(context, status.invitation),
          ],
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
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.12), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14, height: 1)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(color: accent, fontSize: 14, fontWeight: FontWeight.w800, height: 1),
              ),
            ],
          ),
          const SizedBox(height: 7),
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
                  style: TextStyle(color: _titleText(context), fontSize: 20, fontWeight: FontWeight.w900, height: 1),
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
                      style: TextStyle(color: deltaColor.withValues(alpha: 0.82), fontSize: 10, fontWeight: FontWeight.w800, height: 1),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: TextStyle(color: _mutedText(context), fontSize: 13, fontWeight: FontWeight.w500, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _smallGrid(BuildContext context, SiteDailyStatus status, double spFull) {
    final tiles = [
      _MetricTile(
        '🌱',
        '做种',
        fmtCompact(status.seed.toDouble()),
        const Color(0xFF19A765),
        _softTileColor(context, const Color(0xFFE9F8F1), const Color(0xFF19A765)),
      ),
      _MetricTile(
        '⬇',
        '下载中',
        fmtCompact(status.leech.toDouble()),
        const Color(0xFF159B67),
        _softTileColor(context, const Color(0xFFE8F7F0), const Color(0xFF159B67)),
      ),
      _MetricTile(
        '🪙',
        '魔力',
        fmtCompact(status.myBonus),
        const Color(0xFFD49420),
        _softTileColor(context, const Color(0xFFFFF5E4), const Color(0xFFD49420)),
      ),
      _MetricTile(
        '💎',
        '积分',
        fmtCompact(status.myScore),
        const Color(0xFFD12C84),
        _softTileColor(context, const Color(0xFFFFEEF7), const Color(0xFFD12C84)),
      ),
      _MetricTile(
        '📊',
        '分享率',
        _fmtRatio(status.ratio),
        const Color(0xFF7C4DD1),
        _softTileColor(context, const Color(0xFFF2ECFF), const Color(0xFF7C4DD1)),
      ),
      _MetricTile(
        '⌛',
        '时魔',
        _fmtMagicWithRatio(status.bonusHour, spFull),
        const Color(0xFFC68B25),
        _softTileColor(context, const Color(0xFFFFF4E7), const Color(0xFFC68B25)),
      ),
      _MetricTile(
        '🚀',
        '发种',
        fmtCompact(status.publish.toDouble()),
        const Color(0xFF22AEB7),
        _softTileColor(context, const Color(0xFFEAFBFC), const Color(0xFF22AEB7)),
      ),
      _MetricTile(
        '💿',
        '做种量',
        fmtBytes(status.seedVolume),
        const Color(0xFF249E85),
        _softTileColor(context, const Color(0xFFEAF8F4), const Color(0xFF249E85)),
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
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      decoration: BoxDecoration(
        color: item.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.10), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item.icon, style: const TextStyle(fontSize: 15, height: 1)),
          const SizedBox(height: 4),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w800, height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: _titleText(context), fontSize: 13, fontWeight: FontWeight.w900, height: 1),
          ),
        ],
      ),
    );
    return _siteTooltip('${item.label}: ${item.value}', tile);
  }

  Widget _footer(BuildContext context, SiteDailyStatus status) {
    final text = status.updated_at.trim().isNotEmpty ? status.updated_at.trim() : (site.latestStatusUpdatedAt ?? '').trim();
    return Row(
      children: [
        Expanded(
          child: _siteTooltip(
            text.isEmpty ? '同步： -' : '同步： $text',
            Text(
              '同步： ${text.isEmpty ? '-' : text}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _mutedText(context), fontSize: 13, fontWeight: FontWeight.w600, height: 1),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _softTileColor(context, const Color(0xFFEAF0FF), const Color(0xFF3F6FCB)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            '详情',
            style: TextStyle(color: Color(0xFF3F6FCB), fontSize: 14, fontWeight: FontWeight.w700, height: 1),
          ),
        ),
        const SizedBox(width: 10),
        _moreCircle(context),
      ],
    );
  }

  Widget _siteLogo(WebSite? config, double size) {
    return _SiteLogoImage(
      siteName: site.site,
      config: config,
      size: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF27E481), Color(0xFF18C6A1)],
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2DDC8D).withValues(alpha: 0.22), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      fallbackStyle: TextStyle(color: Colors.white, fontSize: size * 0.42, fontWeight: FontWeight.w900, height: 1),
    );
  }

  Widget _title(BuildContext context) {
    final title = site.nickname.isNotEmpty ? site.nickname : site.site;
    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: _titleText(context), fontSize: 22, fontWeight: FontWeight.w900, height: 1.05),
    );
  }

  Widget _levelPill(BuildContext context, String level) {
    final accent = const Color(0xFFC66B1D);
    return GestureDetector(
      onTap: () => openLevelInfo(context, site: site),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _softTileColor(context, const Color(0xFFFFF6EE), accent),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isDark(context) ? accent.withValues(alpha: 0.35) : const Color(0xFFE8CBB3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 16, color: accent),
            const SizedBox(width: 5),
            Text(
              level,
              style: const TextStyle(color: Color(0xFFB8641C), fontSize: 15, fontWeight: FontWeight.w900, height: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _invitePill(BuildContext context, int invitation) {
    final accent = const Color(0xFF3B7DDF);
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _softTileColor(context, const Color(0xFFEFF4FF), accent),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isDark(context) ? accent.withValues(alpha: 0.35) : const Color(0xFFD5E1FF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person, size: 14, color: accent),
          const SizedBox(width: 5),
          Text(
            '邀请 ${fmtCompact(invitation.toDouble())}',
            style: const TextStyle(color: Color(0xFF3B7DDF), fontSize: 14, fontWeight: FontWeight.w800, height: 1),
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
        border: Border.all(color: _isDark(context) ? context.theme.colors.border : const Color(0xFFBFD2F8), width: 1.4),
      ),
      child: Icon(
        Icons.more_horiz,
        size: 20,
        color: _isDark(context) ? context.theme.colors.mutedForeground : const Color(0xFF3F6FCB),
      ),
    );
  }

  bool _isDark(BuildContext context) => context.theme.colors.brightness == Brightness.dark;

  Color _cardColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.muted.withValues(alpha: 0.36) : Colors.white;

  Color _borderColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.border.withValues(alpha: 0.82) : const Color(0xFFECEFF6);

  Color _dividerColor(BuildContext context) =>
      _isDark(context) ? context.theme.colors.border.withValues(alpha: 0.62) : const Color(0xFFE7EAF1);

  Color _titleText(BuildContext context) =>
      _isDark(context) ? context.theme.colors.foreground : const Color(0xFF050914);

  Color _mutedText(BuildContext context) =>
      _isDark(context) ? context.theme.colors.mutedForeground : const Color(0xFF8B8F99);

  Color _softTileColor(BuildContext context, Color light, Color accent) {
    if (!_isDark(context)) return light;
    return Color.alphaBlend(accent.withValues(alpha: 0.13), context.theme.colors.background);
  }

  String _timeOnly(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
    }
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(text);
    if (match == null) return text.length > 5 ? text.substring(0, 5) : text;
    return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)!}';
  }

}

class _MetricTile {
  final String icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _MetricTile(this.icon, this.label, this.value, this.color, this.background);
}

String _fmtRatio(num value) => fmtRatio(value);

double _numVal(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}
