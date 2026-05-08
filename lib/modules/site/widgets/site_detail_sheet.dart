import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/browser_page.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'site_theme.dart';

import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_level_sheet.dart';
import 'site_sign_details.dart';

// ──────────────────── 打开详情 ────────────────────

void openDetail(BuildContext context, SiteInfo site) {
  if (context.isMobile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.45,
        expand: false,
        builder: (ctx, scrollCtrl) =>
            SiteDetailSheet(site: site, scrollController: scrollCtrl),
      ),
    );
  } else {
    showDialog<void>(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
          child: SiteDetailSheet(site: site),
        ),
      ),
    );
  }
}

// ──────────────────── 详情内容 ────────────────────

class SiteDetailSheet extends ConsumerWidget {
  final SiteInfo site;
  final ScrollController? scrollController;

  const SiteDetailSheet({super.key, required this.site, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = site.latestStatus;
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = configs.firstWhereOrNull((c) => c.name == site.site);
    final spFull = _numVal(config?.spFull);
    final cs = shadcn.Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      child: Material(
        color: cs.background,
        borderRadius: context.isMobile
            ? BorderRadius.vertical(top: siteRadius(context, size: "xl").topLeft)
            : siteRadius(context, size: "xl"),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(context, cs),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                children: [
                  // ── 用户信息卡片 ──
                  _buildUserCard(context, cs, spFull),
                  const SizedBox(height: 12),
                  // ── 功能开关 ──
                  _section(context, '功能开关', shadcn.LucideIcons.settings, [
                    _buildFlagsGrid(context, cs),
                  ]),
                  // ── 站点状态详情 ──
                  if (status != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailStats(context, cs, status, spFull),
                  ],
                  const SizedBox(height: 12),
                  // ── 基本信息 ──
                  _section(context, '基本信息', shadcn.LucideIcons.info, [
                    _row(context, '站点名称', site.site),
                    _row(
                      context,
                      '昵称',
                      site.nickname.isEmpty ? '-' : site.nickname,
                    ),
                    _row(context, '排序 ID', '${site.sortId}'),
                    _row(
                      context,
                      '标签',
                      site.tags.isEmpty ? '-' : site.tags.join(', '),
                    ),
                    if (site.durationText.isNotEmpty)
                      _row(context, '注册时长', site.durationText),
                  ]),
                  const SizedBox(height: 12),

                  // ── 用户信息 ──
                  _section(context, '账号信息', shadcn.LucideIcons.user, [
                    _row(context, '用户 ID', site.userId ?? '-'),
                    _row(context, '用户名', site.username ?? '-'),
                    _row(context, '邮箱', site.email ?? '-'),
                    _row(context, 'Passkey', maskKey(site.passkey)),
                    _row(context, 'Authkey', maskKey(site.authkey)),
                  ]),
                  const SizedBox(height: 12),

                  // ── 连接设置 ──
                  _section(context, '连接设置', shadcn.LucideIcons.link, [
                    _row(context, '代理', site.proxy ?? '-'),
                    _row(context, '镜像', site.mirror ?? '-'),
                    _row(
                      context,
                      'RSS',
                      site.rss?.isEmpty ?? true ? '-' : site.rss!,
                    ),
                    _row(
                      context,
                      '种子地址',
                      site.torrents?.isEmpty ?? true ? '-' : site.torrents!,
                    ),
                    _row(context, 'Cookie', _truncate(site.cookie, 40)),
                    _row(context, 'User-Agent', _truncate(site.userAgent, 50)),
                  ]),
                  const SizedBox(height: 12),

                  // ── 数据统计 ──
                  _section(context, '数据统计', shadcn.LucideIcons.chartBar, [
                    _row(context, '注册时间', fmtDate(site.timeJoin)),
                    _row(
                      context,
                      '最后访问',
                      site.latestActiveText.isEmpty
                          ? '-'
                          : site.latestActiveText,
                    ),
                    _row(context, '短消息', '${site.mail}'),
                    _row(context, '公告', '${site.notice}'),
                  ]),

                  // ── 签到信息 ──
                  if (site.signInText != null) ...[
                    const SizedBox(height: 12),
                    _buildSignInSection(context, cs),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 详细数据 ──

  Widget _buildDetailStats(
    BuildContext context,
    shadcn.ColorScheme cs,
    SiteDailyStatus status,
    double spFull,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(
              shadcn.LucideIcons.activity,
              size: 14,
              color: cs.foreground.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 6),
            Text(
              '详细数据',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.foreground.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            if (status.updated_at.isNotEmpty)
              Text(
                formatTime(status.updated_at),
                style: TextStyle(
                  fontSize: 10,
                  color: cs.foreground.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // ── 站点（原"其他"，移到顶部） ──
        _groupLabel(context, '站点'),
        const SizedBox(height: 4),
        Row(
          children: [
            _statCard(
              context,
              '等级',
              status.myLevel.isEmpty ? '-' : status.myLevel,
              shadcn.LucideIcons.award,
              levelColor(status.myLevel),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '发布',
              '${status.publish}',
              shadcn.LucideIcons.fileText,
              siteAccent(context, 2),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '邀请',
              '${status.invitation}',
              shadcn.LucideIcons.userPlus,
              siteAccent(context, 3),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── 传输数据 ──
        _groupLabel(context, '传输'),
        const SizedBox(height: 4),
        Row(
          children: [
            _statCard(
              context,
              '上传量',
              fmtBytes(status.uploaded),
              shadcn.LucideIcons.arrowUp,
              siteSuccess(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '下载量',
              fmtBytes(status.downloaded),
              shadcn.LucideIcons.arrowDown,
              siteInfo(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '分享率',
              status.ratio.toStringAsFixed(2),
              shadcn.LucideIcons.scale,
              _ratioColor(context, status.ratio),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── 做种数据 ──
        _groupLabel(context, '做种'),
        const SizedBox(height: 4),
        Row(
          children: [
            _statCard(
              context,
              '做种数',
              '${status.seed}',
              shadcn.LucideIcons.leaf,
              siteSuccess(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '下载数',
              '${status.leech}',
              shadcn.LucideIcons.arrowDown,
              siteDanger(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '做种量',
              fmtBytes(status.seedVolume),
              shadcn.LucideIcons.hardDrive,
              siteAccent(context, 4),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // ── 积分数据 ──
        _groupLabel(context, '积分'),
        const SizedBox(height: 4),
        Row(
          children: [
            _statCard(
              context,
              '魔力值',
              fmtCompact(status.myBonus),
              shadcn.LucideIcons.diamond,
              siteWarning(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '做种积分',
              fmtCompact(status.myScore),
              shadcn.LucideIcons.star,
              siteWarning(context),
            ),
            const SizedBox(width: 6),
            _statCard(
              context,
              '时魔',
              _fmtMagicWithRatio(status.bonusHour, spFull),
              shadcn.LucideIcons.zap,
              siteDanger(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _groupLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: shadcn.Theme.of(
          context,
        ).colorScheme.foreground.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: cs.background,
          borderRadius: siteRadius(context, size: "md"),
          border: Border.all(color: cs.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 10, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: cs.foreground.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInSection(BuildContext context, shadcn.ColorScheme cs) {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayInfo = site.signInfo?[todayKey] as Map<String, dynamic>?;
    final signed = todayInfo != null;
    final todayText = todayInfo?['info']?.toString() ?? '';
    final todayTime = todayInfo?['updated_at']?.toString() ?? '';

    // 截取签到内容
    String displayText = '';
    if (todayText.isNotEmpty) {
      final colonIndex = todayText.indexOf('签到返回信息：');
      displayText = colonIndex >= 0
          ? todayText.substring(colonIndex + 6).trim()
          : todayText;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 标题行 ──
        Row(
          children: [
            Icon(
              shadcn.LucideIcons.calendarCheck,
              size: 14,
              color: cs.foreground.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 6),
            Text(
              '签到信息',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.foreground.withValues(alpha: 0.6),
              ),
            ),
            const Spacer(),
            // 签到历史
            GestureDetector(
              onTap: () => _openSignInHistory(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: siteRadius(context, size: "sm"),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      shadcn.LucideIcons.history,
                      size: 12,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '签到历史',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ── 签到状态卡片 ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: siteRadius(context, size: "md"),
            border: Border.all(color: cs.border, width: 0.5),
          ),
          child: signed
              ? _buildSignedDetail(context, cs, displayText, todayTime)
              : _buildNotSigned(cs, context),
        ),
      ],
    );
  }

  // ── 已签到：显示签到详情 ──

  Widget _buildSignedDetail(BuildContext context, shadcn.ColorScheme cs, String text, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (time.isNotEmpty)
              Text(
                formatTime(time),
                style: TextStyle(
                  fontSize: 10,
                  color: cs.foreground.withValues(alpha: 0.35),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: siteSuccess(context).withValues(alpha: 0.1),
                borderRadius: siteRadius(context, size: "xs"),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    shadcn.LucideIcons.check,
                    size: 11,
                    color: siteSuccess(context),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '今日已签到',
                    style: TextStyle(
                      fontSize: 11,
                      color: siteSuccess(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: cs.foreground.withValues(alpha: 0.65),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  // ── 未签到：显示签到按钮 ──

  Widget _buildNotSigned(shadcn.ColorScheme cs, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: siteWarning(context).withValues(alpha: 0.1),
            borderRadius: siteRadius(context, size: "xs"),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                shadcn.LucideIcons.x,
                size: 11,
                color: siteWarning(context),
              ),
              const SizedBox(width: 3),
              Text(
                '今日未签到',
                style: TextStyle(
                  fontSize: 11,
                  color: siteWarning(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        shadcn.Button.outline(
          onPressed: site.signIn ? () => _doSignIn(context) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(shadcn.LucideIcons.check, size: 14),
              const SizedBox(width: 4),
              const Text('签到'),
            ],
          ),
        ),
      ],
    );
  }

  // ── 执行签到 ──

  Future<void> _doSignIn(BuildContext context) async {
    try {
      final message = await ProviderScope.containerOf(
        context,
      ).read(siteInfoListProvider.notifier).signIn(site.id);
      if (context.mounted) {
        Toast.success(message);
      }
    } catch (e) {
      if (context.mounted) {
        Toast.error('签到失败: $e');
      }
    }
  }

  void _openSignInHistory(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 600;

    if (mobile) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: siteTransparent(context),
        builder: (ctx) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75,
          child: SignInHistorySheet(siteId: site.id),
        ),
      );
    } else {
      shadcn.showDialog(
        context: context,
        builder: (ctx) => shadcn.AlertDialog(
          content: SizedBox(
            width: 480,
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: SignInHistorySheet(siteId: site.id),
          ),
        ),
      );
    }
  }

  // ────────────────── Header ──────────────────

  PreferredSizeWidget _buildHeader(
    BuildContext context,
    shadcn.ColorScheme cs,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(52),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                child: Icon(
                  shadcn.LucideIcons.arrowLeft,
                  size: 20,
                  color: cs.foreground,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: site.available
                    ? siteSuccess(context)
                    : siteDanger(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    site.site,
                    style: TextStyle(
                      color: cs.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (site.nickname.isNotEmpty)
                    Text(
                      site.nickname,
                      style: TextStyle(
                        color: cs.foreground.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (site.mirror != null && site.mirror!.isNotEmpty)
              GestureDetector(
                onTap: () => BrowserPage.open(
                  context,
                  url: site.mirror!,
                  title: site.site,
                  cookie: site.cookie,
                  userAgent: site.userAgent,
                ),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: siteRadius(context, size: "md"),
                  ),
                  child: Icon(
                    shadcn.LucideIcons.globe,
                    size: 16,
                    color: cs.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────────── 用户卡片 ──────────────────

  Widget _buildUserCard(
    BuildContext context,
    shadcn.ColorScheme cs,
    double spFull,
  ) {
    final status = site.latestStatus;
    final hasUser = site.username != null && site.username!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: siteRadius(context, size: "lg"),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Column(
        children: [
          // 头像 + 名称
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: siteRadius(context, size: "md"),
                ),
                child: Center(
                  child: Text(
                    hasUser ? site.username![0].toUpperCase() : '?',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasUser ? site.username! : '未配置',
                      style: TextStyle(
                        color: cs.foreground,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      site.email ?? '-',
                      style: TextStyle(
                        color: cs.foreground.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // 等级
              if (status != null && status.myLevel.isNotEmpty)
                GestureDetector(
                  onTap: () => openLevelInfo(context, site: site),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor(status.myLevel).withValues(alpha: 0.12),
                      borderRadius: siteRadius(context, size: "sm"),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.myLevel,
                          style: TextStyle(
                            color: levelColor(status.myLevel),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 14,
                          color: levelColor(
                            status.myLevel,
                          ).withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // 签到 + 时魔 + HR
          if (site.signInText != null || status != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // HR
                if (status != null &&
                    status.myHr != '0/0/0' &&
                    status.myHr != '0') ...[
                  _miniBadge(
                    context,
                    shadcn.LucideIcons.triangleAlert,
                    'HR ${status.myHr}',
                    siteDanger(context),
                  ),
                  if (site.signInText != null || status.bonusHour > 0)
                    const SizedBox(width: 8),
                ],
                // 签到状态
                if (site.signInText != null)
                  _miniBadge(
                    context,
                    site.signInText == '已签到'
                        ? shadcn.LucideIcons.check
                        : shadcn.LucideIcons.x,
                    site.signInText!,
                    site.signInText == '已签到'
                        ? siteSuccess(context)
                        : siteDanger(context),
                  ),
                // 时魔
                if (status != null) ...[
                  if (site.signInText != null) const SizedBox(width: 8),
                  _miniBadge(
                    context,
                    shadcn.LucideIcons.zap,
                    '${_fmtMagicWithRatio(status.bonusHour, spFull)}/h',
                    siteWarning(context),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniBadge(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: siteRadius(context, size: "sm"),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _ratioColor(BuildContext context, double ratio) {
    if (ratio >= 2.0) return siteSuccess(context);
    if (ratio >= 1.0) return siteInfo(context);
    if (ratio >= 0.5) return siteWarning(context);
    return siteDanger(context);
  }

  // ────────────────── Section ──────────────────

  Widget _section(
    BuildContext ctx,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final cs = shadcn.Theme.of(ctx).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 14, color: cs.foreground.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cs.background,
            borderRadius: siteRadius(ctx, size: "md"),
            border: Border.all(color: cs.border, width: 0.5),
          ),
          child: ClipRRect(
            borderRadius: siteRadius(ctx, size: "md"),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(children.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 14,
                    color: cs.border,
                  );
                }
                return children[i ~/ 2];
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────── 行 ──────────────────

  Widget _row(BuildContext context, String label, String value) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: cs.foreground.withValues(alpha: 0.45),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: cs.foreground,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────── 功能开关网格 ──────────────────

  Widget _buildFlagsGrid(BuildContext context, shadcn.ColorScheme cs) {
    final flags = [
      _FlagItem('可用', site.available, shadcn.LucideIcons.check),
      _FlagItem('签到', site.signIn, shadcn.LucideIcons.calendarCheck),
      _FlagItem('信息', site.getInfo, shadcn.LucideIcons.info),
      _FlagItem('辅种', site.repeatTorrents, shadcn.LucideIcons.copy),
      _FlagItem('刷流', site.brushFree, shadcn.LucideIcons.download),
      _FlagItem('RSS', site.brushRss, shadcn.LucideIcons.rss),
      _FlagItem('拆包', site.packageFile, shadcn.LucideIcons.package),
      _FlagItem('HR', site.hrDiscern, shadcn.LucideIcons.triangleAlert),
      _FlagItem('搜索', site.searchTorrents, shadcn.LucideIcons.search),
      _FlagItem('首页', site.showInDash, shadcn.LucideIcons.layoutDashboard),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: flags.map((f) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: f.on
                  ? siteSuccess(context).withValues(alpha: 0.08)
                  : cs.foreground.withValues(alpha: 0.03),
              borderRadius: siteRadius(context, size: "md"),
              border: Border.all(
                color: f.on
                    ? siteSuccess(context).withValues(alpha: 0.2)
                    : cs.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  f.icon,
                  size: 12,
                  color: f.on
                      ? siteSuccess(context)
                      : cs.foreground.withValues(alpha: 0.25),
                ),
                const SizedBox(width: 5),
                Text(
                  f.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: f.on
                        ? siteSuccess(context)
                        : cs.foreground.withValues(alpha: 0.4),
                    fontWeight: f.on ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _truncate(String? value, int max) {
    if (value == null || value.isEmpty) return '-';
    return value.length > max ? '${value.substring(0, max)}...' : value;
  }

  String _fmtMagicWithRatio(double current, double full) {
    final value = current.toStringAsFixed(1);
    if (full <= 0) return value;
    final pct = ((current / full) * 100).round();
    return '$value($pct%)';
  }

  double _numVal(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

// ── 辅助类 ──

class _FlagItem {
  final String label;
  final bool on;
  final IconData icon;

  const _FlagItem(this.label, this.on, this.icon);
}
