import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:harvest/core/http/http.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/app_menu.dart';
import 'package:harvest/widgets/app_sheet.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/site_info.dart';
import '../provider/site_provider.dart';
import 'site_browser.dart';
import 'site_level_sheet.dart';
import 'site_theme.dart';

// ──────────────────── 打开详情 ────────────────────

void openDetail(BuildContext context, SiteInfo site) {
  if (context.isMobile) {
    showAppSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: siteTransparent(context),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.45,
        expand: false,
        builder: (ctx, scrollCtrl) => SiteDetailSheet(site: site, scrollController: scrollCtrl),
      ),
    );
  } else {
    shadcn.showDialog<void>(
      context: context,
      builder: (_) => shadcn.AlertDialog(
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
          child: SiteDetailSheet(site: site),
        ),
      ),
    );
  }
}

// ──────────────────── 详情内容 ────────────────────

class SiteDetailSheet extends ConsumerStatefulWidget {
  final SiteInfo site;
  final ScrollController? scrollController;

  const SiteDetailSheet({super.key, required this.site, this.scrollController});

  @override
  ConsumerState<SiteDetailSheet> createState() => _SiteDetailSheetState();
}

class _SiteDetailSheetState extends ConsumerState<SiteDetailSheet> {
  static const _defaultVisibleDays = 15;
  static const _defaultVisibleMonths = 6;

  SiteInfo? _activeSite;
  SiteInfo? _fetchedSite;
  int _tabIndex = 0;
  int _selectedDays = _defaultVisibleDays;
  int _selectedMonths = _defaultVisibleMonths;
  int _signPageIndex = 0;
  final Set<String> _hiddenChartKeys = {};
  bool _refreshingDetail = false;
  bool _savingFlag = false;
  String? _savingFlagKey;
  String? _detailError;
  Offset? _tooltipPosition;
  OverlayEntry? _tooltipEntry;
  Timer? _tooltipTimer;

  SiteInfo get site => _activeSite ?? widget.site;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refreshDetail);
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  Future<void> _refreshDetail() async {
    if (_refreshingDetail) return;
    setState(() {
      _refreshingDetail = true;
      _detailError = null;
    });
    try {
      final data = await Http.get<Map<String, dynamic>>('/api/mysite/mysite/${widget.site.id}');
      final detail = SiteInfo.fromJson(Map<String, dynamic>.from(data));
      if (mounted) {
        setState(() => _fetchedSite = detail);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _detailError = '$e');
      }
    } finally {
      if (mounted) {
        setState(() => _refreshingDetail = false);
      }
    }
  }

  Future<void> _toggleFlag(_FlagItem flag) async {
    if (_savingFlag) return;
    final previousSite = site;
    final nextValue = !flag.on;
    final nextSite = switch (flag.key) {
      'available' => site.copyWith(available: nextValue),
      'signIn' => site.copyWith(signIn: nextValue),
      'getInfo' => site.copyWith(getInfo: nextValue),
      'repeatTorrents' => site.copyWith(repeatTorrents: nextValue),
      'brushFree' => site.copyWith(brushFree: nextValue),
      'brushRss' => site.copyWith(brushRss: nextValue),
      'packageFile' => site.copyWith(packageFile: nextValue),
      'hrDiscern' => site.copyWith(hrDiscern: nextValue),
      'searchTorrents' => site.copyWith(searchTorrents: nextValue),
      'showInDash' => site.copyWith(showInDash: nextValue),
      _ => site,
    };
    setState(() {
      _savingFlag = true;
      _savingFlagKey = flag.key;
      _fetchedSite = nextSite;
    });
    try {
      await ref.read(siteInfoListProvider.notifier).updateSite(nextSite);
      if (mounted) Toast.success('${flag.label}已${nextValue ? '开启' : '关闭'}');
    } catch (e) {
      if (mounted) {
        setState(() => _fetchedSite = previousSite);
        Toast.error('${flag.label}更新失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _savingFlag = false;
          _savingFlagKey = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sites = ref.watch(siteInfoListProvider).valueOrNull;
    final providerSite = sites?.firstWhereOrNull((item) => item.id == widget.site.id);
    _activeSite = _fetchedSite ?? providerSite ?? widget.site;
    final status = site.latestStatus;
    final statusPoints = _buildStatusPoints(site);
    final configs = ref.watch(websiteListProvider).valueOrNull ?? [];
    final config = findSiteWebsiteConfig(site, configs);
    final spFull = _numVal(config?.spFull);
    final cs = shadcn.Theme.of(context).colorScheme;
    final refreshing = _refreshingDetail || ref.watch(siteRefreshingIdsProvider).contains(widget.site.id);
    final tabLabels = ['基础信息', '状态图表', if (site.signIn) '签到信息'];
    final activeTab = _tabIndex.clamp(0, tabLabels.length - 1).toInt();

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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: shadcn.Tabs(
                  index: activeTab,
                  onChanged: (index) => setState(() => _tabIndex = index),
                  children: [for (final label in tabLabels) shadcn.TabItem(child: Text(label))],
                ),
              ),
            ),
            Expanded(
              child: [
                _buildBasicTab(context, cs, spFull),
                _buildStatusTab(context, cs, statusPoints, refreshing, status, spFull),
                if (site.signIn) _buildSignInTab(context, cs),
              ][activeTab],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabList(BuildContext context, List<Widget> children) {
    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 24),
      children: children,
    );
  }

  Widget _buildBasicTab(BuildContext context, shadcn.ColorScheme cs, double spFull) {
    return _buildTabList(context, [
      _buildUserCard(context, cs, spFull),
      const SizedBox(height: 12),
      _section(context, '功能开关', shadcn.LucideIcons.settings, [_buildFlagsGrid(context, cs)]),
      const SizedBox(height: 12),
      _section(context, '基本信息', shadcn.LucideIcons.info, [
        _row(context, '站点名称', site.site),
        _row(context, '昵称', site.nickname.isEmpty ? '-' : site.nickname),
        _row(context, '排序 ID', '${site.sortId}'),
        _row(context, '标签', site.tags.isEmpty ? '-' : site.tags.join(', ')),
        if (site.durationText.isNotEmpty) _row(context, '注册时长', site.durationText),
      ]),
      const SizedBox(height: 12),
      _section(context, '账号信息', shadcn.LucideIcons.user, [
        _row(context, '用户 ID', site.userId ?? '-'),
        _row(context, '用户名', site.username ?? '-'),
        _row(context, '邮箱', site.email ?? '-'),
        _row(context, 'Passkey', maskKey(site.passkey)),
        _row(context, 'Authkey', maskKey(site.authkey)),
      ]),
      const SizedBox(height: 12),
      _section(context, '连接设置', shadcn.LucideIcons.link, [
        _row(context, '代理', site.proxy ?? '-'),
        _row(context, '镜像', site.mirror ?? '-'),
        _row(context, 'RSS', site.rss?.isEmpty ?? true ? '-' : site.rss!),
        _row(context, '种子地址', site.torrents?.isEmpty ?? true ? '-' : site.torrents!),
        _row(context, 'Cookie', _truncate(site.cookie, 40)),
        _row(context, 'User-Agent', _truncate(site.userAgent, 50)),
      ]),
    ]);
  }

  Widget _buildStatusTab(
    BuildContext context,
    shadcn.ColorScheme cs,
    List<_SiteStatusPoint> statusPoints,
    bool refreshing,
    SiteDailyStatus? status,
    double spFull,
  ) {
    return _buildTabList(context, [
      if (status != null) ...[_buildDetailStats(context, cs, status, spFull), const SizedBox(height: 12)],
      _buildStatusTrendSection(context, cs, statusPoints, refreshing),
    ]);
  }

  Widget _buildSignInTab(BuildContext context, shadcn.ColorScheme cs) {
    return _buildTabList(context, [_buildSignInSection(context, cs)]);
  }

  // ── 状态趋势 ──

  List<_SiteStatusPoint> _buildStatusPoints(SiteInfo site) {
    final status = site.status;
    if (status == null || status.isEmpty) return const [];
    final entries = status.entries.toList()
      ..sort((a, b) {
        final dateCompare = _statusDate(a.key).compareTo(_statusDate(b.key));
        return dateCompare == 0 ? a.key.compareTo(b.key) : dateCompare;
      });

    final points = <_SiteStatusPoint>[];
    SiteDailyStatus? previous;
    for (final entry in entries) {
      final current = entry.value.copyWith(date: entry.key);
      points.add(
        _SiteStatusPoint(
          date: entry.key,
          label: _statusDayLabel(entry.key),
          uploaded: current.uploaded.toDouble(),
          downloaded: current.downloaded.toDouble(),
          bonus: current.myBonus,
          score: current.myScore,
          uploadDelta: previous == null ? 0 : (current.uploaded - previous.uploaded).toDouble(),
          downloadDelta: previous == null ? 0 : (current.downloaded - previous.downloaded).toDouble(),
          bonusDelta: previous == null ? 0 : current.myBonus - previous.myBonus,
          scoreDelta: previous == null ? 0 : current.myScore - previous.myScore,
          seed: current.seed.toDouble(),
          leech: current.leech.toDouble(),
          publish: current.publish.toDouble(),
          invitation: current.invitation.toDouble(),
          ratio: current.ratio,
          seedVolume: current.seedVolume.toDouble(),
          seedDays: current.seedDays.toDouble(),
          bonusHour: current.bonusHour,
          seedVolumeDelta: previous == null ? 0 : (current.seedVolume - previous.seedVolume).toDouble(),
          seedDaysDelta: previous == null ? 0 : (current.seedDays - previous.seedDays).toDouble(),
        ),
      );
      previous = current;
    }
    return points;
  }

  Widget _buildStatusTrendSection(
    BuildContext context,
    shadcn.ColorScheme cs,
    List<_SiteStatusPoint> points,
    bool refreshing,
  ) {
    final visiblePoints = _visibleStatusPoints(points);
    final monthPoints = _buildMonthPoints(points);
    final visibleMonthPoints = _visibleMonthPoints(monthPoints);
    final totalDays = points.length;
    final visibleDays = visiblePoints.length;
    final totalMonths = monthPoints.length;
    final visibleMonths = visibleMonthPoints.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(shadcn.LucideIcons.chartNoAxesCombined, size: 14, color: cs.foreground.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text(
              '状态趋势',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.foreground.withValues(alpha: 0.6)),
            ),
            const Spacer(),
            if (refreshing)
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.6, color: cs.primary))
            else if (_detailError != null)
              Text('刷新失败', style: TextStyle(fontSize: 10, color: siteDanger(context))),
          ],
        ),
        const SizedBox(height: 8),
        if (points.isEmpty)
          _chartCard(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    refreshing ? '正在获取状态数据...' : '暂无状态历史',
                    style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.45)),
                  ),
                ),
              ),
            ],
          )
        else ...[
          if (monthPoints.isNotEmpty) ...[
            _chartCard(
              context,
              title: '月度数据',
              subtitle: '按月汇总状态变化',
              children: [
                _buildMonthsControl(context, totalMonths, visibleMonths, visibleMonthPoints),
                const SizedBox(height: 14),
                _buildChartLegendBar(context, monthly: true),
                const SizedBox(height: 14),
                if (_chartVisible('delta')) ...[
                  _chartTitle(context, '月度增量', '当月最后一条 - 第一条'),
                  const SizedBox(height: 8),
                  _buildMonthlyChart(context, visibleMonthPoints),
                  const SizedBox(height: 14),
                ],
                _chartTitle(context, '月度趋势', '每月最后一条状态数据'),
                const SizedBox(height: 8),
                _buildMonthlyTrendChart(context, visibleMonthPoints),
              ],
            ),
            const SizedBox(height: 12),
          ],
          _chartCard(
            context,
            title: '按日数据',
            subtitle: '按日状态明细',
            children: [
              _buildDaysControl(context, totalDays, visibleDays, visiblePoints),
              const SizedBox(height: 14),
              _buildChartLegendBar(context, monthly: false),
              const SizedBox(height: 14),
              if (_chartVisible('delta')) ...[
                _chartTitle(context, '每日增量', '上传 / 下载 / 魔力 / 积分'),
                const SizedBox(height: 8),
                _buildDeltaChart(context, visiblePoints),
                const SizedBox(height: 14),
              ],
              _chartTitle(context, '每日总量', '上传 / 下载 / 魔力 / 积分'),
              const SizedBox(height: 8),
              _buildTotalChart(context, visiblePoints),
              const SizedBox(height: 14),
              _chartTitle(context, '活跃数据', '做种 / 下载 / 发布 / 邀请'),
              const SizedBox(height: 8),
              _buildActivityChart(context, visiblePoints),
              const SizedBox(height: 14),
              _chartTitle(context, '做种效率', '分享率 / 做种量 / 做种天数 / 时魔'),
              const SizedBox(height: 8),
              _buildEfficiencyChart(context, visiblePoints),
            ],
          ),
        ],
      ],
    );
  }

  Widget _chartCard(BuildContext context, {String? title, String? subtitle, required List<Widget> children}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: cs.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cs.foreground),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.42)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _chartTitle(BuildContext context, String title, String subtitle) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.foreground),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.42)),
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendBar(BuildContext context, {required bool monthly}) {
    final items = monthly
        ? const [
            _ChartLegendItem('delta', '增量', shadcn.LucideIcons.plus, Color(0xFF64748B)),
            _ChartLegendItem('upload', '上传', shadcn.LucideIcons.arrowUp, Color(0xFF22C55E)),
            _ChartLegendItem('download', '下载', shadcn.LucideIcons.arrowDown, Color(0xFF38BDF8)),
            _ChartLegendItem('bonus', '魔力', shadcn.LucideIcons.diamond, Color(0xFFF59E0B)),
            _ChartLegendItem('score', '积分', shadcn.LucideIcons.star, Color(0xFFEF4444)),
          ]
        : const [
            _ChartLegendItem('delta', '增量', shadcn.LucideIcons.plus, Color(0xFF64748B)),
            _ChartLegendItem('upload', '上传', shadcn.LucideIcons.arrowUp, Color(0xFF22C55E)),
            _ChartLegendItem('download', '下载', shadcn.LucideIcons.arrowDown, Color(0xFF38BDF8)),
            _ChartLegendItem('bonus', '魔力', shadcn.LucideIcons.diamond, Color(0xFFF59E0B)),
            _ChartLegendItem('score', '积分', shadcn.LucideIcons.star, Color(0xFFEF4444)),
            _ChartLegendItem('seed', '做种', shadcn.LucideIcons.leaf, Color(0xFF16A34A)),
            _ChartLegendItem('leech', '下载数', shadcn.LucideIcons.arrowDownToLine, Color(0xFFDC2626)),
            _ChartLegendItem('publish', '发布', shadcn.LucideIcons.fileText, Color(0xFF0EA5E9)),
            _ChartLegendItem('invitation', '邀请', shadcn.LucideIcons.userPlus, Color(0xFF8B5CF6)),
            _ChartLegendItem('ratio', '分享率', shadcn.LucideIcons.scale, Color(0xFF06B6D4)),
            _ChartLegendItem('seedVolume', '做种量', shadcn.LucideIcons.hardDrive, Color(0xFF22C55E)),
            _ChartLegendItem('seedDays', '做种天数', shadcn.LucideIcons.calendar, Color(0xFFEF4444)),
            _ChartLegendItem('bonusHour', '时魔', shadcn.LucideIcons.zap, Color(0xFFF59E0B)),
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items) _chartLegendChip(context, item),
      ],
    );
  }

  Widget _chartLegendChip(BuildContext context, _ChartLegendItem item) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final hidden = !_chartVisible(item.key);
    return GestureDetector(
      onTap: () => setState(() {
        if (hidden) {
          _hiddenChartKeys.remove(item.key);
        } else {
          _hiddenChartKeys.add(item.key);
        }
      }),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: hidden ? cs.foreground.withValues(alpha: 0.025) : item.color.withValues(alpha: 0.1),
          borderRadius: siteRadius(context, size: "sm"),
          border: Border.all(color: hidden ? cs.border : item.color.withValues(alpha: 0.28), width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 12, color: hidden ? cs.foreground.withValues(alpha: 0.28) : item.color),
            const SizedBox(width: 5),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: hidden ? FontWeight.w500 : FontWeight.w700,
                color: hidden ? cs.foreground.withValues(alpha: 0.42) : cs.foreground.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _chartVisible(String key) => !_hiddenChartKeys.contains(key);

  Widget _buildDeltaChart(BuildContext context, List<_SiteStatusPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 240 : 220,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _bytesAxis(context),
          axes: [_numberAxis(context, 'pointAxis')],
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteStatusPoint, String>>[
            if (_chartVisible('upload'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '上传',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.uploadDelta,
              color: siteSuccess(context).withValues(alpha: 0.78),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('download'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '下载',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.downloadDelta,
              color: siteInfo(context).withValues(alpha: 0.74),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('bonus'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '魔力',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.bonusDelta,
              yAxisName: 'pointAxis',
              color: siteWarning(context).withValues(alpha: 0.72),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('score'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '积分',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.scoreDelta,
              yAxisName: 'pointAxis',
              color: siteAccent(context, 3).withValues(alpha: 0.72),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, List<_SiteMonthPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 250 : 230,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _bytesAxis(context),
          axes: [_numberAxis(context, 'pointAxis')],
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteMonthPoint, String>>[
            if (_chartVisible('upload'))
            ColumnSeries<_SiteMonthPoint, String>(
              name: '上传',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.uploadDelta,
              color: siteSuccess(context).withValues(alpha: 0.78),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('download'))
            ColumnSeries<_SiteMonthPoint, String>(
              name: '下载',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.downloadDelta,
              color: siteInfo(context).withValues(alpha: 0.74),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('bonus'))
            ColumnSeries<_SiteMonthPoint, String>(
              name: '魔力',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.bonusDelta,
              yAxisName: 'pointAxis',
              color: siteWarning(context).withValues(alpha: 0.72),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('score'))
            ColumnSeries<_SiteMonthPoint, String>(
              name: '积分',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.scoreDelta,
              yAxisName: 'pointAxis',
              color: siteAccent(context, 3).withValues(alpha: 0.72),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendChart(BuildContext context, List<_SiteMonthPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 250 : 230,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _bytesAxis(context),
          axes: [_numberAxis(context, 'pointAxis')],
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteMonthPoint, String>>[
            if (_chartVisible('upload'))
            LineSeries<_SiteMonthPoint, String>(
              name: '上传',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.uploaded,
              color: siteSuccess(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('download'))
            LineSeries<_SiteMonthPoint, String>(
              name: '下载',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.downloaded,
              color: siteInfo(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('bonus'))
            LineSeries<_SiteMonthPoint, String>(
              name: '魔力',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.bonus,
              yAxisName: 'pointAxis',
              color: siteWarning(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('score'))
            LineSeries<_SiteMonthPoint, String>(
              name: '积分',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.score,
              yAxisName: 'pointAxis',
              color: siteAccent(context, 3),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalChart(BuildContext context, List<_SiteStatusPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 240 : 220,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _bytesAxis(context),
          axes: [_numberAxis(context, 'pointAxis')],
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteStatusPoint, String>>[
            if (_chartVisible('upload'))
            LineSeries<_SiteStatusPoint, String>(
              name: '上传',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.uploaded,
              color: siteSuccess(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('download'))
            LineSeries<_SiteStatusPoint, String>(
              name: '下载',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.downloaded,
              color: siteInfo(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('bonus'))
            LineSeries<_SiteStatusPoint, String>(
              name: '魔力',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.bonus,
              yAxisName: 'pointAxis',
              color: siteWarning(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('score'))
            LineSeries<_SiteStatusPoint, String>(
              name: '积分',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.score,
              yAxisName: 'pointAxis',
              color: siteAccent(context, 3),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context, List<_SiteStatusPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 240 : 220,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _numberAxis(context, null),
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteStatusPoint, String>>[
            if (_chartVisible('seed'))
            LineSeries<_SiteStatusPoint, String>(
              name: '做种',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.seed,
              color: siteSuccess(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('leech'))
            LineSeries<_SiteStatusPoint, String>(
              name: '下载',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.leech,
              color: siteDanger(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('publish'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '发布',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.publish,
              color: siteInfo(context).withValues(alpha: 0.58),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
            if (_chartVisible('invitation'))
            ColumnSeries<_SiteStatusPoint, String>(
              name: '邀请',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.invitation,
              color: siteAccent(context, 4).withValues(alpha: 0.58),
              borderRadius: BorderRadius.vertical(top: siteRadius(context, size: "xs").topLeft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEfficiencyChart(BuildContext context, List<_SiteStatusPoint> points) {
    return Listener(
      onPointerDown: _rememberTooltipPosition,
      child: SizedBox(
        height: context.isMobile ? 250 : 230,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          margin: EdgeInsets.zero,
          legend: _chartLegend(context),
          primaryXAxis: _chartXAxis(context),
          primaryYAxis: _numberAxis(context, null),
          axes: [_bytesAxis(context, name: 'bytesAxis')],
          tooltipBehavior: _tooltipBehavior(),
          series: <CartesianSeries<_SiteStatusPoint, String>>[
            if (_chartVisible('ratio'))
            LineSeries<_SiteStatusPoint, String>(
              name: '分享率',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.ratio,
              color: siteInfo(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('bonusHour'))
            LineSeries<_SiteStatusPoint, String>(
              name: '时魔',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.bonusHour,
              color: siteWarning(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('seedDays'))
            LineSeries<_SiteStatusPoint, String>(
              name: '做种天数',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.seedDays,
              color: siteAccent(context, 3),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
            if (_chartVisible('seedVolume'))
            LineSeries<_SiteStatusPoint, String>(
              name: '做种量',
              dataSource: points,
              xValueMapper: (point, _) => point.label,
              yValueMapper: (point, _) => point.seedVolume,
              yAxisName: 'bytesAxis',
              color: siteSuccess(context),
              width: 2,
              markerSettings: const MarkerSettings(isVisible: true, height: 4, width: 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysControl(BuildContext context, int totalDays, int visibleDays, List<_SiteStatusPoint> visiblePoints) {
    final cs = shadcn.Theme.of(context).colorScheme;
    if (totalDays <= 2) {
      return Text(
        '状态历史 $totalDays 天',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.45)),
      );
    }

    final quickDays = const [7, 15, 30, 60, 90, 180].where((day) => day <= totalDays).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '显示最近 $visibleDays 天',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cs.foreground.withValues(alpha: 0.72)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${visiblePoints.first.date} - ${visiblePoints.last.date} / 共 $totalDays 天',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.46)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            min: 2,
            max: totalDays.toDouble(),
            divisions: totalDays - 2,
            value: visibleDays.toDouble(),
            onChanged: (value) => setState(() => _selectedDays = value.round()),
          ),
        ),
        if (quickDays.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final day in quickDays)
                _quickRangeButton(
                  context,
                  label: '$day天',
                  selected: day == visibleDays,
                  onTap: () => setState(() => _selectedDays = day),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMonthsControl(
    BuildContext context,
    int totalMonths,
    int visibleMonths,
    List<_SiteMonthPoint> visiblePoints,
  ) {
    final cs = shadcn.Theme.of(context).colorScheme;
    if (totalMonths <= 1) {
      return Text(
        '月度历史 $totalMonths 个月',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.45)),
      );
    }

    final quickMonths = <({String label, int months})>[
      (label: '3个月', months: 3),
      (label: '六个月', months: 6),
      (label: '一年', months: 12),
      (label: '两年', months: 24),
    ].where((item) => item.months <= totalMonths).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '显示最近 $visibleMonths 个月',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: cs.foreground.withValues(alpha: 0.72)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${visiblePoints.first.month} - ${visiblePoints.last.month} / 共 $totalMonths 个月',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.46)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slider(
            min: 1,
            max: totalMonths.toDouble(),
            divisions: totalMonths - 1,
            value: visibleMonths.toDouble(),
            onChanged: (value) => setState(() => _selectedMonths = value.round()),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in quickMonths)
              _quickRangeButton(
                context,
                label: item.label,
                selected: item.months == visibleMonths,
                onTap: () => setState(() => _selectedMonths = item.months),
              ),
            _quickRangeButton(
              context,
              label: '全部',
              selected: visibleMonths == totalMonths,
              onTap: () => setState(() => _selectedMonths = totalMonths),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickRangeButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.12) : cs.foreground.withValues(alpha: 0.03),
          borderRadius: siteRadius(context, size: "sm"),
          border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.28) : cs.border, width: 0.6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.foreground.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }

  Legend _chartLegend(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return Legend(
      isVisible: false,
      position: LegendPosition.bottom,
      textStyle: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.55)),
      iconHeight: 8,
      iconWidth: 8,
    );
  }

  CategoryAxis _chartXAxis(BuildContext context) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return CategoryAxis(
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: AxisLine(width: 0.5, color: cs.border),
      labelStyle: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.42)),
      labelRotation: context.isMobile ? -35 : 0,
    );
  }

  NumericAxis _bytesAxis(BuildContext context, {String? name}) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return NumericAxis(
      name: name,
      opposedPosition: name != null && name.isNotEmpty,
      majorGridLines: MajorGridLines(width: 0.6, color: cs.border.withValues(alpha: 0.55)),
      axisLine: const AxisLine(width: 0),
      labelStyle: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.42)),
      axisLabelFormatter: (details) => ChartAxisLabel(_fmtBytesValue(details.value), details.textStyle),
    );
  }

  NumericAxis _numberAxis(BuildContext context, String? name) {
    final cs = shadcn.Theme.of(context).colorScheme;
    return NumericAxis(
      name: name,
      opposedPosition: name != null && name.isNotEmpty,
      majorGridLines: const MajorGridLines(width: 0),
      axisLine: const AxisLine(width: 0),
      labelStyle: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.42)),
      axisLabelFormatter: (details) => ChartAxisLabel(_fmtCompactValue(details.value), details.textStyle),
    );
  }

  TooltipBehavior _tooltipBehavior() {
    return TooltipBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      header: '',
      canShowMarker: false,
      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
        if (data is _SiteStatusPoint) {
          _scheduleTooltip(_statusTooltipText(data));
        } else if (data is _SiteMonthPoint) {
          _scheduleTooltip(_monthTooltipText(data));
        }
        return const SizedBox.shrink();
      },
    );
  }

  List<_SiteStatusPoint> _visibleStatusPoints(List<_SiteStatusPoint> points) {
    if (points.isEmpty) return const [];
    final minDays = points.length > 1 ? 2 : 1;
    final days = _selectedDays.clamp(minDays, points.length).toInt();
    return points.skip(points.length - days).toList();
  }

  List<_SiteMonthPoint> _visibleMonthPoints(List<_SiteMonthPoint> points) {
    if (points.isEmpty) return const [];
    final months = _selectedMonths.clamp(1, points.length).toInt();
    return points.skip(points.length - months).toList();
  }

  List<_SiteMonthPoint> _buildMonthPoints(List<_SiteStatusPoint> points) {
    if (points.isEmpty) return const [];
    final grouped = <String, List<_SiteStatusPoint>>{};
    for (final point in points) {
      final month = _statusMonthKey(point.date);
      if (month.isEmpty) continue;
      grouped.putIfAbsent(month, () => <_SiteStatusPoint>[]).add(point);
    }

    return grouped.entries.map((entry) {
      final monthPoints = entry.value;
      final first = monthPoints.first;
      final last = monthPoints.last;
      return _SiteMonthPoint(
        month: entry.key,
        label: _statusMonthLabel(entry.key),
        firstDate: first.date,
        lastDate: last.date,
        days: monthPoints.length,
        uploaded: last.uploaded,
        downloaded: last.downloaded,
        bonus: last.bonus,
        score: last.score,
        uploadDelta: last.uploaded - first.uploaded,
        downloadDelta: last.downloaded - first.downloaded,
        bonusDelta: last.bonus - first.bonus,
        scoreDelta: last.score - first.score,
        seed: last.seed,
        leech: last.leech,
        publish: last.publish,
        invitation: last.invitation,
        ratio: last.ratio,
        seedVolume: last.seedVolume,
        seedDays: last.seedDays,
        bonusHour: last.bonusHour,
        seedVolumeDelta: last.seedVolume - first.seedVolume,
        seedDaysDelta: last.seedDays - first.seedDays,
        seedDelta: last.seed - first.seed,
        leechDelta: last.leech - first.leech,
        publishDelta: last.publish - first.publish,
        invitationDelta: last.invitation - first.invitation,
        ratioDelta: last.ratio - first.ratio,
        bonusHourDelta: last.bonusHour - first.bonusHour,
      );
    }).toList();
  }

  DateTime _statusDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _statusMonthKey(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value.length >= 7 ? value.substring(0, 7) : '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  String _statusMonthLabel(String value) {
    final date = DateTime.tryParse('$value-01');
    if (date == null) return value;
    return '${date.year.toString().substring(2)}-${date.month.toString().padLeft(2, '0')}';
  }

  String _statusDayLabel(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _fmtBytesValue(num value) {
    final sign = value < 0 ? '-' : '';
    return '$sign${fmtBytes(value.abs().round())}';
  }

  String _fmtSignedBytes(num value) {
    if (value == 0) return fmtBytes(0);
    final sign = value > 0 ? '+' : '-';
    return '$sign${fmtBytes(value.abs().round())}';
  }

  String _fmtCompactValue(num value) {
    final sign = value < 0 ? '-' : '';
    return '$sign${fmtCompact(value.abs().toDouble())}';
  }

  String _fmtSignedCompact(num value) {
    if (value == 0) return fmtCompact(0);
    final sign = value > 0 ? '+' : '-';
    return '$sign${fmtCompact(value.abs().toDouble())}';
  }

  String _statusTooltipText(_SiteStatusPoint point) {
    return [
      point.date,
      '上传增量\t${_fmtSignedBytes(point.uploadDelta)}',
      '下载增量\t${_fmtSignedBytes(point.downloadDelta)}',
      '魔力增量\t${_fmtSignedCompact(point.bonusDelta)}',
      '积分增量\t${_fmtSignedCompact(point.scoreDelta)}',
      '做种量增量\t${_fmtSignedBytes(point.seedVolumeDelta)}',
      '做种天数增量\t${_fmtSignedCompact(point.seedDaysDelta)}',
      '上传总量\t${_fmtBytesValue(point.uploaded)}',
      '下载总量\t${_fmtBytesValue(point.downloaded)}',
      '魔力总量\t${_fmtCompactValue(point.bonus)}',
      '积分总量\t${_fmtCompactValue(point.score)}',
      '做种数\t${_fmtCompactValue(point.seed)}',
      '下载数\t${_fmtCompactValue(point.leech)}',
      '发布数\t${_fmtCompactValue(point.publish)}',
      '邀请数\t${_fmtCompactValue(point.invitation)}',
      '分享率\t${point.ratio.toStringAsFixed(2)}',
      '做种量\t${_fmtBytesValue(point.seedVolume)}',
      '做种天数\t${_fmtCompactValue(point.seedDays)}',
      '时魔\t${point.bonusHour.toStringAsFixed(1)}/h',
    ].join('\n');
  }

  String _monthTooltipText(_SiteMonthPoint point) {
    return [
      '${point.month} 月度',
      '统计区间\t${point.firstDate} - ${point.lastDate}',
      '记录天数\t${point.days}天',
      '上传增量\t${_fmtSignedBytes(point.uploadDelta)}',
      '下载增量\t${_fmtSignedBytes(point.downloadDelta)}',
      '魔力增量\t${_fmtSignedCompact(point.bonusDelta)}',
      '积分增量\t${_fmtSignedCompact(point.scoreDelta)}',
      '做种量增量\t${_fmtSignedBytes(point.seedVolumeDelta)}',
      '做种天数增量\t${_fmtSignedCompact(point.seedDaysDelta)}',
      '做种数变化\t${_fmtSignedCompact(point.seedDelta)}',
      '下载数变化\t${_fmtSignedCompact(point.leechDelta)}',
      '发布数变化\t${_fmtSignedCompact(point.publishDelta)}',
      '邀请数变化\t${_fmtSignedCompact(point.invitationDelta)}',
      '分享率变化\t${point.ratioDelta >= 0 ? '+' : ''}${point.ratioDelta.toStringAsFixed(2)}',
      '时魔变化\t${point.bonusHourDelta >= 0 ? '+' : ''}${point.bonusHourDelta.toStringAsFixed(1)}/h',
      '月末上传\t${_fmtBytesValue(point.uploaded)}',
      '月末下载\t${_fmtBytesValue(point.downloaded)}',
      '月末魔力\t${_fmtCompactValue(point.bonus)}',
      '月末积分\t${_fmtCompactValue(point.score)}',
      '月末做种\t${_fmtCompactValue(point.seed)}',
      '月末下载数\t${_fmtCompactValue(point.leech)}',
      '月末发布\t${_fmtCompactValue(point.publish)}',
      '月末邀请\t${_fmtCompactValue(point.invitation)}',
      '月末分享率\t${point.ratio.toStringAsFixed(2)}',
      '月末做种量\t${_fmtBytesValue(point.seedVolume)}',
      '月末做种天数\t${_fmtCompactValue(point.seedDays)}',
      '月末时魔\t${point.bonusHour.toStringAsFixed(1)}/h',
    ].join('\n');
  }

  void _rememberTooltipPosition(PointerDownEvent event) {
    _tooltipPosition = event.position;
  }

  void _scheduleTooltip(String text) {
    if (text.trim().isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showTooltip(text);
    });
  }

  void _showTooltip(String text) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(context);
    const margin = 12.0;
    final availableWidth = (size.width - margin * 2).clamp(160.0, size.width).toDouble();
    final availableHeight = (size.height - padding.top - padding.bottom - margin * 2)
        .clamp(160.0, size.height)
        .toDouble();
    final tooltipWidth = availableWidth.clamp(160.0, 430.0).toDouble();
    final tooltipHeight = _tooltipPreferredHeight(text, availableHeight);
    final position = _tooltipPosition ?? Offset(size.width / 2, size.height / 2);
    final minTop = padding.top + margin;
    final maxTop = (size.height - padding.bottom - tooltipHeight - margin).clamp(minTop, size.height).toDouble();
    final aboveTop = position.dy - tooltipHeight - 14;
    final belowTop = position.dy + 14;
    final top = (aboveTop >= minTop ? aboveTop : belowTop).clamp(minTop, maxTop).toDouble();
    final minLeft = margin;
    final maxLeft = (size.width - tooltipWidth - margin).clamp(minLeft, size.width).toDouble();
    final left = (position.dx - tooltipWidth / 2).clamp(minLeft, maxLeft).toDouble();

    _hideTooltip();
    _tooltipEntry = OverlayEntry(
      builder: (_) => Positioned.fill(
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideTooltip,
                  child: const SizedBox.expand(),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: tooltipWidth,
                height: tooltipHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: _SitePagedTooltip(text: text, onClose: _hideTooltip),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_tooltipEntry!);
    _tooltipTimer = Timer(const Duration(seconds: 12), _hideTooltip);
  }

  double _tooltipPreferredHeight(String text, double availableHeight) {
    final lines = text.split('\n');
    final bodyLines = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    final summaryCount = bodyLines.where(_isSiteTooltipSummaryLine).length;
    final detailCount = bodyLines.where((line) => !_isSiteTooltipSummaryLine(line)).length;
    final visibleDetails = detailCount.clamp(1, _SitePagedTooltipState.linesPerPage).toInt();
    final summaryHeight = summaryCount > 0 ? 34.0 : 0.0;
    final pagerHeight = detailCount > _SitePagedTooltipState.linesPerPage ? 36.0 : 0.0;
    final preferred = 58.0 + summaryHeight + visibleDetails * 22.0 + pagerHeight;
    return preferred.clamp(132.0, availableHeight.clamp(132.0, 620.0)).toDouble();
  }

  void _hideTooltip() {
    _tooltipTimer?.cancel();
    _tooltipTimer = null;
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  // ── 详细数据 ──

  Widget _buildDetailStats(BuildContext context, shadcn.ColorScheme cs, SiteDailyStatus status, double spFull) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Row(
          children: [
            Icon(shadcn.LucideIcons.activity, size: 14, color: cs.foreground.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text(
              '详细数据',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.foreground.withValues(alpha: 0.6)),
            ),
            const Spacer(),
            if (status.updated_at.isNotEmpty)
              Text(
                formatTime(status.updated_at),
                style: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.3)),
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
            _statCard(context, '发布', '${status.publish}', shadcn.LucideIcons.fileText, siteAccent(context, 2)),
            const SizedBox(width: 6),
            _statCard(context, '邀请', '${status.invitation}', shadcn.LucideIcons.userPlus, siteAccent(context, 3)),
          ],
        ),
        const SizedBox(height: 8),

        // ── 传输数据 ──
        _groupLabel(context, '传输'),
        const SizedBox(height: 4),
        Row(
          children: [
            _statCard(context, '上传量', fmtBytes(status.uploaded), shadcn.LucideIcons.arrowUp, siteSuccess(context)),
            const SizedBox(width: 6),
            _statCard(context, '下载量', fmtBytes(status.downloaded), shadcn.LucideIcons.arrowDown, siteInfo(context)),
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
            _statCard(context, '做种数', '${status.seed}', shadcn.LucideIcons.leaf, siteSuccess(context)),
            const SizedBox(width: 6),
            _statCard(context, '下载数', '${status.leech}', shadcn.LucideIcons.arrowDown, siteDanger(context)),
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
            _statCard(context, '魔力值', fmtCompact(status.myBonus), shadcn.LucideIcons.diamond, siteWarning(context)),
            const SizedBox(width: 6),
            _statCard(context, '做种积分', fmtCompact(status.myScore), shadcn.LucideIcons.star, siteWarning(context)),
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
        color: shadcn.Theme.of(context).colorScheme.foreground.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon, Color color) {
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
                Text(label, style: TextStyle(fontSize: 9, color: cs.foreground.withValues(alpha: 0.4))),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.foreground),
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
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(shadcn.LucideIcons.calendarCheck, size: 14, color: cs.foreground.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text(
              '签到信息',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.foreground.withValues(alpha: 0.6)),
            ),
            const Spacer(),
            Text(
              '共 ${site.signInfo?.length ?? 0} 条',
              style: TextStyle(fontSize: 11, color: cs.foreground.withValues(alpha: 0.38)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildSignInTimeline(context, cs, todayKey),
      ],
    );
  }

  Widget _buildSignInTimeline(BuildContext context, shadcn.ColorScheme cs, String todayKey) {
    final entries = _signEntries();
    if (entries.isEmpty) {
      return _chartCard(
        context,
        title: '签到记录',
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text('暂无签到记录', style: TextStyle(fontSize: 12, color: cs.foreground.withValues(alpha: 0.45))),
            ),
          ),
        ],
      );
    }

    final pageSize = _signPageSize(context);
    final pageCount = (entries.length / pageSize).ceil().clamp(1, entries.length).toInt();
    final pageIndex = _signPageIndex.clamp(0, pageCount - 1).toInt();
    if (pageIndex != _signPageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _signPageIndex = pageIndex);
      });
    }
    final start = pageIndex * pageSize;
    final end = (start + pageSize).clamp(0, entries.length).toInt();
    final visible = entries.sublist(start, end);

    return _chartCard(
      context,
      title: '签到记录',
      subtitle: '第 ${pageIndex + 1} / $pageCount 页',
      children: [
        SizedBox(
          height: _signTimelineHeight(context, visible.length, pageCount > 1),
          child: shadcn.ComponentTheme(
            data: shadcn.TimelineTheme(
              timeConstraints: const BoxConstraints.tightFor(width: 0),
              spacing: 12,
              dotSize: 10,
              connectorThickness: 1.2,
              color: cs.border,
              rowGap: 10,
            ),
            child: SingleChildScrollView(
              child: shadcn.Timeline(data: [for (final entry in visible) _signTimelineData(context, entry, todayKey)]),
            ),
          ),
        ),
        if (pageCount > 1) ...[
          SizedBox(height: _signPagerTopGap(context, visible.length, pageCount > 1)),
          Divider(height: 16, color: cs.border.withValues(alpha: 0.55)),
          Row(
            children: [
              shadcn.IconButton.ghost(
                onPressed: pageIndex > 0 ? () => setState(() => _signPageIndex = pageIndex - 1) : null,
                icon: Icon(
                  shadcn.LucideIcons.chevronLeft,
                  size: 16,
                  color: pageIndex > 0 ? cs.foreground : cs.mutedForeground,
                ),
              ),
              Expanded(
                child: Text(
                  '${start + 1}-$end / ${entries.length}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.foreground.withValues(alpha: 0.5),
                  ),
                ),
              ),
              shadcn.IconButton.ghost(
                onPressed: pageIndex < pageCount - 1 ? () => setState(() => _signPageIndex = pageIndex + 1) : null,
                icon: Icon(
                  shadcn.LucideIcons.chevronRight,
                  size: 16,
                  color: pageIndex < pageCount - 1 ? cs.foreground : cs.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  List<_SignEntry> _signEntries() {
    final signInfo = site.signInfo;
    if (signInfo == null || signInfo.isEmpty) return const [];
    final entries = signInfo.entries.map((entry) {
      final value = entry.value is Map ? Map<String, dynamic>.from(entry.value as Map) : <String, dynamic>{};
      return _SignEntry(date: entry.key, info: value);
    }).toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  int _signPageSize(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final estimated = ((height - (context.isMobile ? 330 : 260)) / 86).floor();
    return estimated.clamp(3, 9).toInt();
  }

  double _signTimelineHeight(BuildContext context, int visibleCount, bool hasPager) {
    final height = MediaQuery.sizeOf(context).height;
    final reserved = context.isMobile ? 285.0 : 230.0;
    final maxHeight = (height - reserved - (hasPager ? 58.0 : 0.0)).clamp(190.0, 560.0).toDouble();
    return (visibleCount * 86.0).clamp(110.0, maxHeight).toDouble();
  }

  double _signPagerTopGap(BuildContext context, int visibleCount, bool hasPager) {
    if (!hasPager) return 0;
    final timelineHeight = _signTimelineHeight(context, visibleCount, hasPager);
    final contentHeight = visibleCount * 86.0;
    return (timelineHeight - contentHeight).clamp(10.0, 36.0).toDouble();
  }

  shadcn.TimelineData _signTimelineData(BuildContext context, _SignEntry entry, String todayKey) {
    final cs = shadcn.Theme.of(context).colorScheme;
    final isToday = entry.date == todayKey;
    final color = isToday ? cs.primary : cs.mutedForeground.withValues(alpha: 0.45);

    return shadcn.TimelineData(
      color: color,
      time: const SizedBox.shrink(),
      title: Row(
        children: [
          Text(
            _compactSignDate(entry.date),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? cs.primary : cs.foreground.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isToday ? '今日签到' : '签到',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
                color: isToday ? cs.primary : cs.foreground,
              ),
            ),
          ),
          if (entry.updatedAt.isNotEmpty)
            Text(
              formatTime(entry.updatedAt),
              style: TextStyle(fontSize: 10, color: cs.foreground.withValues(alpha: 0.36)),
            ),
        ],
      ),
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isToday ? cs.primary.withValues(alpha: 0.08) : cs.foreground.withValues(alpha: 0.025),
          borderRadius: siteRadius(context, size: "sm"),
          border: Border.all(color: isToday ? cs.primary.withValues(alpha: 0.2) : cs.border, width: 0.6),
        ),
        child: Text(
          entry.displayText.isEmpty ? '-' : entry.displayText,
          style: TextStyle(
            fontSize: 11,
            height: 1.35,
            color: isToday ? cs.foreground : cs.foreground.withValues(alpha: 0.62),
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  String _compactSignDate(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return '${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  // ── 执行签到 ──

  Future<void> _doSignIn(BuildContext context) async {
    try {
      final message = await ProviderScope.containerOf(context).read(siteInfoListProvider.notifier).signIn(site.id);
      if (context.mounted) {
        Toast.success(message);
      }
    } catch (e) {
      if (context.mounted) {
        Toast.error('签到失败: $e');
      }
    }
  }

  // ────────────────── Header ──────────────────

  PreferredSizeWidget _buildHeader(BuildContext context, shadcn.ColorScheme cs) {
    final configs = ref.read(websiteListProvider).valueOrNull ?? [];
    final website = findSiteWebsiteConfig(site, configs);
    final browseTargets = buildSiteBrowseTargets(site, website);

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
              onTap: () => closeAppSheet(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(shadcn.LucideIcons.arrowLeft, size: 20, color: cs.foreground),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: site.available ? siteSuccess(context) : siteDanger(context),
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
                    style: TextStyle(color: cs.foreground, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  if (site.nickname.isNotEmpty)
                    Text(site.nickname, style: TextStyle(color: cs.foreground.withValues(alpha: 0.4), fontSize: 11)),
                ],
              ),
            ),
            if (browseTargets.isNotEmpty)
              Builder(
                builder: (buttonContext) => GestureDetector(
                  onTap: () => _showBrowseMenu(buttonContext, browseTargets),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: siteRadius(context, size: "md"),
                    ),
                    child: Icon(shadcn.LucideIcons.globe, size: 16, color: cs.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBrowseMenu(BuildContext context, List<SiteBrowseTarget> targets) {
    final menuKey = GlobalKey();
    shadcn.showPopover<void>(
      context: context,
      alignment: Alignment.topRight,
      anchorAlignment: Alignment.bottomRight,
      offset: const Offset(0, 8),
      widthConstraint: shadcn.PopoverConstraint.intrinsic,
      consumeOutsideTaps: false,
      regionGroupId: menuKey,
      handler: const shadcn.PopoverOverlayHandler(),
      overlayBarrier: shadcn.OverlayBarrier(
        borderRadius: BorderRadius.circular(shadcn.Theme.of(context).radiusMd),
      ),
      builder: (_) => shadcn.Data.inherit(
        data: shadcn.DropdownMenuData(menuKey),
        child: AppDropdownMenu(
          children: [
            for (final target in targets)
              shadcn.MenuButton(
                leading: Icon(target.icon),
                onPressed: (overlayContext) async {
                  await shadcn.closeOverlay(overlayContext);
                  if (!mounted) return;
                  openSiteInternalBrowser(
                    this.context,
                    site,
                    url: target.url,
                    title: '${site.nickname.isNotEmpty ? site.nickname : site.site} · ${target.label}',
                  );
                },
                child: Text(target.label),
              ),
          ],
        ),
      ),
    );
  }

  // ────────────────── 用户卡片 ──────────────────

  Widget _buildUserCard(BuildContext context, shadcn.ColorScheme cs, double spFull) {
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
                    style: TextStyle(color: cs.primary, fontSize: 18, fontWeight: FontWeight.w700),
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
                      style: TextStyle(color: cs.foreground, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      site.email ?? '-',
                      style: TextStyle(color: cs.foreground.withValues(alpha: 0.4), fontSize: 12),
                    ),
                  ],
                ),
              ),
              // 等级
              if (status != null && status.myLevel.isNotEmpty)
                GestureDetector(
                  onTap: () => openLevelInfo(context, site: site),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          color: levelColor(status.myLevel).withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // 签到 + 消息 + 时魔 + HR
          if (site.signInText != null || status != null || site.mail > 0 || site.notice > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // HR
                if (status != null && status.myHr != '0/0/0' && status.myHr != '0')
                  _miniBadge(context, shadcn.LucideIcons.triangleAlert, 'HR ${status.myHr}', siteDanger(context)),
                // 签到状态
                if (site.signInText != null)
                  _miniBadge(
                    context,
                    site.signInText == '已签到' ? shadcn.LucideIcons.check : shadcn.LucideIcons.x,
                    site.signInText!,
                    site.signInText == '已签到' ? siteSuccess(context) : siteDanger(context),
                  ),
                _miniIconBadge(context, shadcn.LucideIcons.mail, '${site.mail}', siteInfo(context), '短消息 ${site.mail}'),
                _miniIconBadge(
                  context,
                  shadcn.LucideIcons.bell,
                  '${site.notice}',
                  siteWarning(context),
                  '公告 ${site.notice}',
                ),
                // 时魔
                if (status != null)
                  _miniBadge(
                    context,
                    shadcn.LucideIcons.zap,
                    '${_fmtMagicWithRatio(status.bonusHour, spFull)}/h',
                    siteWarning(context),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildTimeMetaRow(context, cs),
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
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _miniIconBadge(BuildContext context, IconData icon, String text, Color color, String tooltip) {
    return shadcn.Tooltip(
      tooltip: (_) => Text(tooltip),
      child: Container(
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
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetaRow(BuildContext context, shadcn.ColorScheme cs) {
    final registerTime = fmtDate(site.timeJoin);
    final latestActive = site.latestActiveText.isEmpty ? '-' : site.latestActiveText;
    final style = TextStyle(color: cs.foreground.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w500);

    return Row(
      children: [
        Expanded(
          child: Text('注册 $registerTime', maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '最后登录 $latestActive',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
    );
  }

  Color _ratioColor(BuildContext context, double ratio) {
    if (ratio >= 2.0) return siteSuccess(context);
    if (ratio >= 1.0) return siteInfo(context);
    if (ratio >= 0.5) return siteWarning(context);
    return siteDanger(context);
  }

  // ────────────────── Section ──────────────────

  Widget _section(BuildContext ctx, String title, IconData icon, List<Widget> children) {
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
                  return Divider(height: 0.5, thickness: 0.5, indent: 14, color: cs.border);
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
            child: Text(label, style: TextStyle(color: cs.foreground.withValues(alpha: 0.45), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: cs.foreground, fontSize: 13, fontWeight: FontWeight.w500),
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
      _FlagItem('可用', site.available, shadcn.LucideIcons.check, 'available'),
      _FlagItem('签到', site.signIn, shadcn.LucideIcons.calendarCheck, 'signIn'),
      _FlagItem('信息', site.getInfo, shadcn.LucideIcons.info, 'getInfo'),
      _FlagItem('辅种', site.repeatTorrents, shadcn.LucideIcons.copy, 'repeatTorrents'),
      _FlagItem('刷流', site.brushFree, shadcn.LucideIcons.download, 'brushFree'),
      _FlagItem('RSS', site.brushRss, shadcn.LucideIcons.rss, 'brushRss'),
      _FlagItem('拆包', site.packageFile, shadcn.LucideIcons.package, 'packageFile'),
      _FlagItem('HR', site.hrDiscern, shadcn.LucideIcons.triangleAlert, 'hrDiscern'),
      _FlagItem('搜索', site.searchTorrents, shadcn.LucideIcons.search, 'searchTorrents'),
      _FlagItem('首页', site.showInDash, shadcn.LucideIcons.layoutDashboard, 'showInDash'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final columns = constraints.maxWidth < 360
              ? 2
              : constraints.maxWidth < 520
              ? 3
              : 5;
          final itemWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: flags.map((f) {
              final saving = _savingFlagKey == f.key;
              return SizedBox(
                width: itemWidth,
                child: GestureDetector(
                  onTap: _savingFlag ? null : () => _toggleFlag(f),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: f.on ? siteSuccess(context).withValues(alpha: 0.1) : cs.foreground.withValues(alpha: 0.03),
                      borderRadius: siteRadius(context, size: "md"),
                      border: Border.all(color: f.on ? siteSuccess(context).withValues(alpha: 0.26) : cs.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (saving)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.4, color: cs.primary),
                          )
                        else
                          Icon(
                            f.icon,
                            size: 12,
                            color: f.on ? siteSuccess(context) : cs.foreground.withValues(alpha: 0.28),
                          ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            f.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: f.on ? siteSuccess(context) : cs.foreground.withValues(alpha: 0.45),
                              fontWeight: f.on ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
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
  final String key;

  const _FlagItem(this.label, this.on, this.icon, this.key);
}

class _ChartLegendItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _ChartLegendItem(this.key, this.label, this.icon, this.color);
}

class _SiteStatusPoint {
  final String date;
  final String label;
  final double uploaded;
  final double downloaded;
  final double bonus;
  final double score;
  final double uploadDelta;
  final double downloadDelta;
  final double bonusDelta;
  final double scoreDelta;
  final double seed;
  final double leech;
  final double publish;
  final double invitation;
  final double ratio;
  final double seedVolume;
  final double seedDays;
  final double bonusHour;
  final double seedVolumeDelta;
  final double seedDaysDelta;

  const _SiteStatusPoint({
    required this.date,
    required this.label,
    required this.uploaded,
    required this.downloaded,
    required this.bonus,
    required this.score,
    required this.uploadDelta,
    required this.downloadDelta,
    required this.bonusDelta,
    required this.scoreDelta,
    required this.seed,
    required this.leech,
    required this.publish,
    required this.invitation,
    required this.ratio,
    required this.seedVolume,
    required this.seedDays,
    required this.bonusHour,
    required this.seedVolumeDelta,
    required this.seedDaysDelta,
  });
}

class _SiteMonthPoint {
  final String month;
  final String label;
  final String firstDate;
  final String lastDate;
  final int days;
  final double uploaded;
  final double downloaded;
  final double bonus;
  final double score;
  final double uploadDelta;
  final double downloadDelta;
  final double bonusDelta;
  final double scoreDelta;
  final double seed;
  final double leech;
  final double publish;
  final double invitation;
  final double ratio;
  final double seedVolume;
  final double seedDays;
  final double bonusHour;
  final double seedVolumeDelta;
  final double seedDaysDelta;
  final double seedDelta;
  final double leechDelta;
  final double publishDelta;
  final double invitationDelta;
  final double ratioDelta;
  final double bonusHourDelta;

  const _SiteMonthPoint({
    required this.month,
    required this.label,
    required this.firstDate,
    required this.lastDate,
    required this.days,
    required this.uploaded,
    required this.downloaded,
    required this.bonus,
    required this.score,
    required this.uploadDelta,
    required this.downloadDelta,
    required this.bonusDelta,
    required this.scoreDelta,
    required this.seed,
    required this.leech,
    required this.publish,
    required this.invitation,
    required this.ratio,
    required this.seedVolume,
    required this.seedDays,
    required this.bonusHour,
    required this.seedVolumeDelta,
    required this.seedDaysDelta,
    required this.seedDelta,
    required this.leechDelta,
    required this.publishDelta,
    required this.invitationDelta,
    required this.ratioDelta,
    required this.bonusHourDelta,
  });
}

class _SignEntry {
  final String date;
  final Map<String, dynamic> info;

  const _SignEntry({required this.date, required this.info});

  String get updatedAt => info['updated_at']?.toString() ?? '';

  String get displayText {
    final text = info['info']?.toString() ?? '';
    if (text.isEmpty) return '';
    final colonIndex = text.indexOf('签到返回信息：');
    return colonIndex >= 0 ? text.substring(colonIndex + 6).trim() : text;
  }
}

bool _isSiteTooltipSummaryLine(String line) {
  final tabIndex = line.indexOf('\t');
  if (tabIndex <= 0) return false;
  return line.substring(0, tabIndex).endsWith('增量');
}

class _SitePagedTooltip extends StatefulWidget {
  final String text;
  final VoidCallback onClose;

  const _SitePagedTooltip({required this.text, required this.onClose});

  @override
  State<_SitePagedTooltip> createState() => _SitePagedTooltipState();
}

class _SitePagedTooltipState extends State<_SitePagedTooltip> {
  static const linesPerPage = 32;

  late final PageController _pageController;
  late final String _title;
  late final List<String> _summaryLines;
  late final List<List<String>> _pages;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    final rawLines = widget.text.split('\n');
    _title = rawLines.isNotEmpty && rawLines.first.trim().isNotEmpty ? rawLines.first : '详情';
    final bodyLines = rawLines.skip(1).where((line) => line.trim().isNotEmpty).toList();
    _summaryLines = bodyLines.where(_isSiteTooltipSummaryLine).toList();
    _pages = _chunkLines(bodyLines.where((line) => !_isSiteTooltipSummaryLine(line)).toList());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<List<String>> _chunkLines(List<String> lines) {
    final pages = <List<String>>[];
    for (var i = 0; i < lines.length; i += linesPerPage) {
      final end = (i + linesPerPage).clamp(0, lines.length).toInt();
      pages.add(lines.sublist(i, end));
    }
    return pages;
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _pages.length) return;
    _pageController.animateToPage(page, duration: const Duration(milliseconds: 180), curve: Curves.easeOutCubic);
  }

  Widget _buildLine(BuildContext context, String line) {
    final theme = shadcn.Theme.of(context);
    final tabIndex = line.indexOf('\t');
    if (tabIndex > 0) {
      final name = line.substring(0, tabIndex);
      final value = line.substring(tabIndex + 1);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Flexible(
              flex: 2,
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(line, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
    );
  }

  Widget _buildSummaryChip(BuildContext context, String line) {
    final theme = shadcn.Theme.of(context);
    final tabIndex = line.indexOf('\t');
    final label = tabIndex > 0 ? line.substring(0, tabIndex) : line;
    final value = tabIndex > 0 ? line.substring(tabIndex + 1) : '';
    final icon = _summaryIcon(label);
    final detail = value.isEmpty ? label : '$label: $value';

    return shadcn.Tooltip(
      tooltip: (_) => Text(detail),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: siteRadius(context, size: "sm"),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.12), width: 0.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: theme.colorScheme.primary),
            if (value.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                value,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _summaryIcon(String label) {
    if (label.contains('上传')) return shadcn.LucideIcons.arrowUp;
    if (label.contains('下载')) return shadcn.LucideIcons.arrowDown;
    if (label.contains('魔力')) return shadcn.LucideIcons.diamond;
    if (label.contains('积分')) return shadcn.LucideIcons.star;
    if (label.contains('做种量')) return shadcn.LucideIcons.hardDrive;
    if (label.contains('做种天数')) return shadcn.LucideIcons.calendar;
    if (label.contains('做种')) return shadcn.LucideIcons.leaf;
    if (label.contains('发布')) return shadcn.LucideIcons.fileText;
    if (label.contains('邀请')) return shadcn.LucideIcons.userPlus;
    if (label.contains('分享率')) return shadcn.LucideIcons.scale;
    if (label.contains('时魔')) return shadcn.LucideIcons.zap;
    return shadcn.LucideIcons.info;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final hasDetails = _pages.isNotEmpty;
    final hasPager = _pages.length > 1;
    final canPrev = _page > 0;
    final canNext = _page < _pages.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.background.withValues(alpha: 0.98),
        borderRadius: siteRadius(context, size: "md"),
        border: Border.all(color: theme.colorScheme.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.foreground.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: _summaryLines.isEmpty ? 1 : 4,
                child: Text(
                  _title,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_summaryLines.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  flex: 5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _summaryLines.length; i++) ...[
                          if (i > 0) const SizedBox(width: 6),
                          _buildSummaryChip(context, _summaryLines[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onClose,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(shadcn.LucideIcons.x, size: 15, color: theme.colorScheme.mutedForeground),
                ),
              ),
            ],
          ),
          if (hasDetails) ...[
            Divider(height: 14, color: theme.colorScheme.border.withValues(alpha: 0.45)),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: _pages[index].map((line) => _buildLine(context, line)).toList(),
                    ),
                  );
                },
              ),
            ),
            if (hasPager) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  shadcn.IconButton.ghost(
                    onPressed: canPrev ? () => _goToPage(_page - 1) : null,
                    icon: Icon(
                      shadcn.LucideIcons.chevronLeft,
                      size: 16,
                      color: canPrev ? theme.colorScheme.foreground : theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_page + 1} / ${_pages.length}',
                      textAlign: TextAlign.center,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  shadcn.IconButton.ghost(
                    onPressed: canNext ? () => _goToPage(_page + 1) : null,
                    icon: Icon(
                      shadcn.LucideIcons.chevronRight,
                      size: 16,
                      color: canNext ? theme.colorScheme.foreground : theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
