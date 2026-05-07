import 'dart:collection';
import 'dart:math' as math;

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:harvest/core/cache/session_cache.dart';
import 'package:harvest/core/http/api.dart';
import 'package:harvest/core/http/hooks.dart';
import 'package:harvest/core/utils/utils.dart';
import 'package:harvest/widgets/cache_status_banner.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/kv/kv.dart';
import '../../shell/provider/screenshot_provider.dart';
import '../../shell/widgets/shell_scaffold.dart';
import '../../site/provider/site_provider.dart';
import '../model/dashboard_data.dart';
import '../provider/dashboard_provider.dart';
import '../provider/privacy_provider.dart';

class DesktopDashboardPage extends ConsumerStatefulWidget {
  const DesktopDashboardPage({super.key});

  @override
  ConsumerState<DesktopDashboardPage> createState() => _DesktopDashboardPageState();
}

class _DesktopDashboardPageState extends ConsumerState<DesktopDashboardPage> {
  static const _bg = Color(0xFF07111F);
  static const _panel = Color(0xFF0D1B2E);
  static const _panelSoft = Color(0xFF10243B);
  static const _line = Color(0xFF1D3757);
  static const _text = Color(0xFFEAF2FF);
  static const _muted = Color(0xFF88A4C4);
  static const _cyan = Color(0xFF22D3EE);
  static const _green = Color(0xFF34D399);
  static const _amber = Color(0xFFFBBF24);
  static const _red = Color(0xFFFB7185);
  static const _blue = Color(0xFF60A5FA);
  static const _violet = Color(0xFFA78BFA);
  static const _orange = Color(0xFFFB923C);
  static const _bottomGap = 84.0;

  static const _designations = <int, String>{
    1: '初窥门径',
    10: '星辰初现',
    20: '光耀九天',
    30: '龙腾九霄',
    50: '纵横天下',
    100: '天命之子',
    150: '九天霸主',
    200: '万界之尊',
  };

  final _refreshController = EasyRefreshController(controlFinishRefresh: true);
  final _scrollController = ScrollController();
  bool _refreshingDashboard = false;
  bool _refreshingSites = false;
  bool _signingIn = false;
  bool _showWeeks = false;
  _ChartTooltipData? _trendTooltip;
  Offset? _trendTooltipPosition;
  bool _trendTooltipHovering = false;

  bool get _busy => _refreshingDashboard || _refreshingSites || _signingIn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardNotifierProvider.notifier).refresh();
      if (mounted) {
        ref.read(activeScrollControllerProvider.notifier).state = _scrollController;
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(dashboardNotifierProvider.notifier).refresh();
    _refreshController.finishRefresh();
  }

  String _taskEndpoint(String api) => api.endsWith('/') ? api.substring(0, api.length - 1) : api;

  Future<void> _refreshDashboard() async {
    if (_busy) return;
    setState(() => _refreshingDashboard = true);
    try {
      await ref.read(dashboardNotifierProvider.notifier).refresh();
      Toast.success('刷新数据完成');
    } catch (e, st) {
      AppLogger.error('刷新首页数据失败', e, st);
      Toast.error('刷新数据失败');
    } finally {
      if (mounted) setState(() => _refreshingDashboard = false);
    }
  }

  Future<void> _refreshSiteData() async {
    if (_busy) return;
    setState(() => _refreshingSites = true);
    try {
      await fetchBasic(_taskEndpoint(API.MYSITE_STATUS_OPERATE));
      await ref.read(siteInfoListProvider.notifier).refresh();
      await ref.read(dashboardNotifierProvider.notifier).refresh();
      Toast.success('站点数据任务已执行');
    } catch (e, st) {
      AppLogger.error('执行站点数据刷新任务失败', e, st);
      Toast.error('站点数据刷新失败');
    } finally {
      if (mounted) setState(() => _refreshingSites = false);
    }
  }

  Future<void> _signInSites() async {
    if (_busy) return;
    setState(() => _signingIn = true);
    try {
      await fetchBasic(_taskEndpoint(API.MYSITE_SIGNIN_OPERATE));
      await ref.read(siteInfoListProvider.notifier).refresh();
      await ref.read(dashboardNotifierProvider.notifier).refresh();
      Toast.success('站点签到任务已执行');
    } catch (e, st) {
      AppLogger.error('执行站点签到任务失败', e, st);
      Toast.error('站点签到失败');
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  String _mask(String name, bool privacy) {
    if (!privacy) return name;
    if (name.length <= 1) return '*';
    if (name.length == 2) return '${name[0]}*';
    return '${name[0]}*${name[name.length - 1]}';
  }

  String _formatCount(num value) {
    return formatCompactNumber(value);
  }

  String _formatMonth(String date) {
    if (date.length < 7) return date;
    final month = int.tryParse(date.substring(5, 7)) ?? 0;
    if (month == 1) return date.substring(2, 7);
    return '$month月';
  }

  String _monthKey(String date) => date.length >= 7 ? date.substring(0, 7) : date;

  String _formatDay(String date) {
    if (date.length >= 10) return date.substring(5, 10);
    return date;
  }

  String _formatYAxis(num bytes) {
    return formatBytes(bytes, decimals: 0);
  }

  String _getDesignation(num siteCount) {
    var result = '无称号';
    for (final entry in _designations.entries) {
      if (siteCount >= entry.key) result = entry.value;
    }
    return result;
  }

  String _accountAge(DashboardData data) {
    final timeJoin = data.earliestSite?.timeJoin;
    if (timeJoin == null || timeJoin.isEmpty) return '0天';
    if (_showWeeks) {
      try {
        return calcWeeksDays(timeJoin);
      } catch (_) {
        return '0天';
      }
    }
    final joinedAt = DateTime.tryParse(timeJoin);
    if (joinedAt == null) return '0天';
    final days = DateTime.now().difference(joinedAt).inDays;
    if (days >= 365) {
      final years = days ~/ 365;
      final months = (days % 365) ~/ 30;
      return '$years年${months > 0 ? '$months个月' : ''}';
    }
    if (days >= 30) return '${days ~/ 30}个月';
    return '$days天';
  }

  String _cacheText(DataCacheInfo info, DashboardData data) {
    final time = info.cachedAt ?? DateTime.tryParse(data.updatedAt ?? '');
    if (time == null) return '暂无更新时间';
    final prefix = info.isCached ? '缓存' : '实时';
    return '$prefix ${formatDateStringToMinute(time.toIso8601String())}';
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dashboardNotifierProvider);
    final cacheInfo = ref.watch(dashboardCacheInfoProvider);
    final refreshSerial = ref.watch(dashboardRefreshSerialProvider);
    final privacy = ref.watch(privacyModeProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(color: _bg),
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackdrop()),
          Positioned.fill(
            child: data == null
                ? const Center(child: FProgress.circularIcon())
                : _buildBoard(context, data, cacheInfo, privacy, refreshSerial),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop() {
    return IgnorePointer(child: CustomPaint(painter: _BoardBackdropPainter()));
  }

  Widget _buildBoard(BuildContext context, DashboardData data, DataCacheInfo cacheInfo, bool privacy, int refreshSerial) {
    return EasyRefresh(
      key: ValueKey('desktop-dashboard-$refreshSerial'),
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: appRefreshHeader(context),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, _bottomGap + ShellBottomSpacing.value(context)),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.crossAxisExtent < 1180;
                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(data, cacheInfo, privacy),
                      CacheStatusBanner(
                        info: cacheInfo,
                        margin: const EdgeInsets.only(top: 10),
                      ),
                      const SizedBox(height: 14),
                      _buildKpiStrip(data, constraints.crossAxisExtent),
                      const SizedBox(height: 14),
                      if (compact) _buildCompactContent(data, privacy) else _buildWideContent(data, privacy),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(DashboardData data, DataCacheInfo cacheInfo, bool privacy) {
    return _panelContainer(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _cyan.withValues(alpha: 0.42)),
            ),
            child: const Icon(FIcons.chartNoAxesCombined, color: _cyan),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HARVEST DATA COMMAND CENTER',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 0),
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.siteCount.toInt()} 个站点接入 · ${_cacheText(cacheInfo, data)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _headerAction(icon: FIcons.refreshCw, label: _refreshingDashboard ? '刷新中' : '刷新', onTap: _refreshDashboard),
          const SizedBox(width: 8),
          _headerAction(icon: FIcons.database, label: _refreshingSites ? '执行中' : '站点数据', onTap: _refreshSiteData),
          const SizedBox(width: 8),
          _headerAction(icon: FIcons.checkCheck, label: _signingIn ? '签到中' : '签到', onTap: _signInSites),
          const SizedBox(width: 8),
          _headerAction(
            icon: privacy ? FIcons.eyeOff : FIcons.eye,
            label: privacy ? '隐私' : '明文',
            onTap: () => ref.read(privacyModeProvider.notifier).toggle(),
          ),
        ],
      ),
    );
  }

  Widget _headerAction({required IconData icon, required String label, required VoidCallback onTap}) {
    return FButton(
      style: FButtonStyle.ghost(_dashboardGhostButtonStyle),
      onPress: _busy ? null : onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: _panelSoft.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _line.withValues(alpha: 0.92)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _cyan),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiStrip(DashboardData data, double maxWidth) {
    final items = [
      _Kpi('站点数', data.siteCount.toInt().toString(), '站点接入', _cyan, FIcons.globe),
      _Kpi(
        '总上传',
        formatBytes(data.totalUploaded),
        '今日 +${formatBytes(data.todayUploadIncrement)}',
        _green,
        FIcons.arrowUp,
      ),
      _Kpi(
        '总下载',
        formatBytes(data.totalDownloaded),
        '今日 +${formatBytes(data.todayDownloadIncrement)}',
        _red,
        FIcons.arrowDown,
      ),
      _Kpi('做种体积', formatBytes(data.totalSeedVol), '${_formatCount(data.totalSeeding)} 个做种', _blue, FIcons.hardDrive),
      _Kpi('做种数', _formatCount(data.totalSeeding), '活跃做种任务', const Color(0xFF5EEAD4), FIcons.database),
      _Kpi('下载中', _formatCount(data.totalLeeching), '正在下载任务', _orange, FIcons.download),
      _Kpi('发布总量', _formatCount(data.totalPublished), '累计发布种子', _amber, FIcons.upload),
      _Kpi('P龄', _accountAge(data), data.earliestSite?.site ?? '暂无站点', _violet, FIcons.calendar),
    ];

    Widget row(List<_Kpi> rowItems) {
      return Row(
        children: [
          for (var i = 0; i < rowItems.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _buildKpiTile(
                rowItems[i],
                onTap: rowItems[i].label == 'P龄' ? () => setState(() => _showWeeks = !_showWeeks) : null,
              ),
            ),
          ],
        ],
      );
    }

    if (maxWidth >= 1080) {
      return Column(children: [row(items.take(4).toList()), const SizedBox(height: 10), row(items.skip(4).toList())]);
    }
    return Column(
      children: [
        row(items.take(2).toList()),
        const SizedBox(height: 10),
        row(items.skip(2).take(2).toList()),
        const SizedBox(height: 10),
        row(items.skip(4).take(2).toList()),
        const SizedBox(height: 10),
        row(items.skip(6).toList()),
      ],
    );
  }

  Widget _buildKpiTile(_Kpi item, {VoidCallback? onTap}) {
    final content = _panelContainer(
      height: 128,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: item.color, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              if (onTap != null)
                FButton.icon(
                  style: FButtonStyle.ghost(_dashboardGhostButtonStyle),
                  onPress: onTap,
                  child: Icon(FIcons.refreshCw, size: 14, color: item.color),
                ),
            ],
          ),
          const Spacer(),
          _kpiValue(item),
          const SizedBox(height: 8),
          Text(
            item.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return content;
  }

  Widget _kpiValue(_Kpi item) {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(
          item.value,
          maxLines: 1,
          style: TextStyle(
            color: item.color,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1,
            shadows: [Shadow(color: item.color.withValues(alpha: 0.28), blurRadius: 12)],
          ),
        ),
      ),
    );
  }

  Widget _buildWideContent(DashboardData data, bool privacy) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: _buildTrendPanel(data, privacy)),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildDesignationPanel(data, height: 128),
                  const SizedBox(height: 10),
                  _buildResourcePanel(data, height: 252),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: _buildDistributionRow(data, privacy, stacked: false)),
            const SizedBox(width: 10),
            Expanded(flex: 4, child: _buildAccountPanel(data, privacy, height: 300)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 7, child: _buildTodayPanel(data, privacy, height: 440)),
            const SizedBox(width: 10),
            Expanded(flex: 4, child: _buildRankPanel(data, privacy, height: 440)),
          ],
        ),
        const SizedBox(height: 10),
        _buildMonthlyPublishPanel(data, privacy),
      ],
    );
  }

  Widget _buildCompactContent(DashboardData data, bool privacy) {
    return Column(
      children: [
        _buildDesignationPanel(data),
        const SizedBox(height: 10),
        _buildTrendPanel(data, privacy),
        const SizedBox(height: 10),
        _buildDistributionRow(data, privacy, stacked: true),
        const SizedBox(height: 10),
        _buildResourcePanel(data),
        const SizedBox(height: 10),
        _buildRankPanel(data, privacy),
        const SizedBox(height: 10),
        _buildTodayPanel(data, privacy),
        const SizedBox(height: 10),
        _buildMonthlyPublishPanel(data, privacy),
        const SizedBox(height: 10),
        _buildAccountPanel(data, privacy),
      ],
    );
  }

  Widget _buildDesignationPanel(DashboardData data, {double height = 128}) {
    final siteCount = data.siteCount.toInt();
    final designation = _getDesignation(data.siteCount);
    final progress = _designationProgress(siteCount);
    return _boardPanel(
      title: '称号',
      subtitle: progress.completed
          ? '$siteCount 个站点接入 · 最高等级'
          : '$siteCount 个站点接入 · 下级 ${progress.nextTitle} 还差 ${progress.remaining} 站',
      height: height,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFE11D48).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE11D48).withValues(alpha: 0.42)),
              ),
              child: const Icon(FIcons.award, size: 30, color: Color(0xFFE11D48)),
            ),
            const SizedBox(width: 12),
            _DesignationCard(designation: designation, siteCount: siteCount, width: 190, height: 48, fontSize: 28),
          ],
        ),
      ),
    );
  }

  _DesignationProgress _designationProgress(int siteCount) {
    final levels = _designations.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final first = levels.first;

    if (siteCount < first.key) {
      return _DesignationProgress(
        currentLevel: 0,
        currentTitle: '无称号',
        nextLevel: first.key,
        nextTitle: first.value,
        ratio: 0,
        remaining: first.key - siteCount,
        completed: false,
      );
    }

    var current = first;
    MapEntry<int, String>? next;
    for (final level in levels) {
      if (siteCount >= level.key) {
        current = level;
      } else {
        next = level;
        break;
      }
    }

    if (next == null) {
      return _DesignationProgress(
        currentLevel: current.key,
        currentTitle: current.value,
        nextLevel: current.key,
        nextTitle: current.value,
        ratio: 1,
        remaining: 0,
        completed: true,
      );
    }

    final span = next.key - current.key;
    final gained = (siteCount - current.key).clamp(0, span);
    return _DesignationProgress(
      currentLevel: current.key,
      currentTitle: current.value,
      nextLevel: next.key,
      nextTitle: next.value,
      ratio: span <= 0 ? 1 : (gained / span).toDouble(),
      remaining: next.key - siteCount,
      completed: false,
    );
  }

  Widget _buildTrendPanel(DashboardData data, bool privacy) {
    final month = _monthTrend(data);
    final daily = _dailyUploadTrend(data);
    return _boardPanel(
      title: '吞吐趋势',
      subtitle: '月度上传/下载与近期上传/下载增量',
      height: 390,
      child: MouseRegion(
        onHover: (event) {
          if (!_trendTooltipHovering) {
            _updateTrendTooltipPosition(event.localPosition);
          }
        },
        onExit: (_) {
          if (!_trendTooltipHovering && _trendTooltip != null) {
            setState(() {
              _trendTooltip = null;
              _trendTooltipPosition = null;
            });
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            const tooltipWidth = 292.0;
            const tooltipHeight = 260.0;
            final tooltipPosition = _trendTooltipPosition == null
                ? Offset.zero
                : _floatingTooltipOffset(
                    _trendTooltipPosition!,
                    Size(constraints.maxWidth, constraints.maxHeight),
                    const Size(tooltipWidth, tooltipHeight),
                  );

            return Stack(
              children: [
                Positioned.fill(
                  child: SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    margin: EdgeInsets.zero,
                    primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0), labelStyle: _axisStyle()),
                    primaryYAxis: NumericAxis(
                      opposedPosition: false,
                      majorGridLines: MajorGridLines(width: 0.7, color: _line.withValues(alpha: 0.55)),
                      axisLine: const AxisLine(width: 0),
                      labelStyle: _axisStyle(),
                      axisLabelFormatter: (details) => ChartAxisLabel(_formatYAxis(details.value), _axisStyle()),
                    ),
                    axes: [
                      NumericAxis(
                        name: 'daily',
                        opposedPosition: true,
                        majorGridLines: const MajorGridLines(width: 0),
                        axisLine: const AxisLine(width: 0),
                        labelStyle: _axisStyle(),
                        axisLabelFormatter: (details) => ChartAxisLabel(_formatYAxis(details.value), _axisStyle()),
                      ),
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      textStyle: const TextStyle(color: _muted, fontSize: 11),
                      iconHeight: 8,
                      iconWidth: 8,
                    ),
                    trackballBehavior: TrackballBehavior(
                      enable: true,
                      activationMode: ActivationMode.singleTap,
                      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
                      lineColor: _cyan.withValues(alpha: 0.55),
                      lineWidth: 1,
                      tooltipSettings: const InteractiveTooltip(enable: false),
                      builder: (context, details) {
                        _scheduleTrendTooltip(details, month, daily, data, privacy);
                        return const SizedBox.shrink();
                      },
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<_TrendPoint, String>(
                        name: '月上传',
                        dataSource: month,
                        xValueMapper: (p, _) => _formatMonth(p.label),
                        yValueMapper: (p, _) => p.uploaded,
                        color: _green.withValues(alpha: 0.78),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                      ColumnSeries<_TrendPoint, String>(
                        name: '月下载',
                        dataSource: month,
                        xValueMapper: (p, _) => _formatMonth(p.label),
                        yValueMapper: (p, _) => p.downloaded,
                        color: _red.withValues(alpha: 0.72),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                      SplineAreaSeries<_TrendPoint, String>(
                        name: '近期上传',
                        dataSource: daily,
                        xValueMapper: (p, _) => _formatDay(p.label),
                        yValueMapper: (p, _) => p.uploaded,
                        yAxisName: 'daily',
                        color: _cyan.withValues(alpha: 0.16),
                        borderColor: _cyan,
                        borderWidth: 2,
                      ),
                      SplineAreaSeries<_TrendPoint, String>(
                        name: '近期下载',
                        dataSource: daily,
                        xValueMapper: (p, _) => _formatDay(p.label),
                        yValueMapper: (p, _) => p.downloaded,
                        yAxisName: 'daily',
                        color: _orange.withValues(alpha: 0.13),
                        borderColor: _orange,
                        borderWidth: 2,
                      ),
                    ],
                  ),
                ),
                if (_trendTooltip != null && _trendTooltipPosition != null)
                  Positioned(
                    left: tooltipPosition.dx,
                    top: tooltipPosition.dy,
                    child: MouseRegion(
                      onEnter: (_) {
                        if (!_trendTooltipHovering) {
                          setState(() => _trendTooltipHovering = true);
                        }
                      },
                      onExit: (_) {
                        if (_trendTooltipHovering) {
                          setState(() => _trendTooltipHovering = false);
                        }
                      },
                      child: _chartTooltip(
                        _trendTooltip!.title,
                        _trendTooltip!.rows,
                        width: tooltipWidth,
                        maxHeight: tooltipHeight,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDistributionRow(DashboardData data, bool privacy, {required bool stacked}) {
    if (stacked) {
      return Column(
        children: [
          _buildUploadSharePanel(data, privacy),
          const SizedBox(height: 10),
          _buildSeedSharePanel(data, privacy),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildUploadSharePanel(data, privacy)),
        const SizedBox(width: 10),
        Expanded(child: _buildSeedSharePanel(data, privacy)),
      ],
    );
  }

  Widget _buildUploadSharePanel(DashboardData data, bool privacy) {
    final items = _topStatus(data.statusList, privacy, (record) => record.value.uploaded, limit: 8);
    return _boardPanel(
      title: '上传占比',
      subtitle: '站点累计上传分布',
      height: 300,
      child: _donutChart(items, _green, formatter: formatBytes),
    );
  }

  Widget _buildSeedSharePanel(DashboardData data, bool privacy) {
    final items = _topKv(data.seedDataList, privacy, limit: 8);
    return _boardPanel(
      title: '做种分布',
      subtitle: '活跃做种站点结构',
      height: 300,
      child: _donutChart(items, _blue, formatter: _formatCount),
    );
  }

  Widget _donutChart(
    List<_NameValuePoint> items,
    Color baseColor, {
    required String Function(num) formatter,
  }) {
    if (items.isEmpty) {
      return const Center(
        child: Text('暂无数据', style: TextStyle(color: _muted)),
      );
    }
    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.scroll,
        textStyle: const TextStyle(color: _muted, fontSize: 11),
        iconHeight: 8,
        iconWidth: 8,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        animationDuration: 0,
        duration: 5000,
        elevation: 24,
        opacity: 1,
        color: _panel,
        canShowMarker: false,
        builder: (dataPoint, point, series, pointIndex, seriesIndex) =>
            _donutTooltip(dataPoint, items, formatter),
      ),
      series: <CircularSeries>[
        DoughnutSeries<_NameValuePoint, String>(
          dataSource: items,
          xValueMapper: (p, _) => p.name,
          yValueMapper: (p, _) => p.value,
          pointColorMapper: (_, index) => _palette(index, baseColor),
          radius: '88%',
          innerRadius: '62%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
        ),
      ],
    );
  }

  Widget _buildResourcePanel(DashboardData data, {double height = 300}) {
    return _boardPanel(
      title: '全局资源',
      subtitle: '全部站点实际指标',
      height: height,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _resourceMetric('总上传', formatBytes(data.totalUploaded), _green, FIcons.arrowUp)),
                const SizedBox(width: 8),
                Expanded(child: _resourceMetric('总下载', formatBytes(data.totalDownloaded), _red, FIcons.arrowDown)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _resourceMetric('做种体积', formatBytes(data.totalSeedVol), _blue, FIcons.hardDrive)),
                const SizedBox(width: 8),
                Expanded(child: _resourceMetric('发布数', _formatCount(data.totalPublished), _amber, FIcons.upload)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _resourceMetric(
                    '做种任务',
                    _formatCount(data.totalSeeding),
                    const Color(0xFF5EEAD4),
                    FIcons.database,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _resourceMetric('下载任务', _formatCount(data.totalLeeching), _orange, FIcons.download)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceMetric(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: _panelSoft.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(color: _muted, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      maxLines: 1,
                      style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900, height: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateTrendTooltipPosition(Offset position) {
    final old = _trendTooltipPosition;
    if (old != null && (old - position).distance < 2) {
      return;
    }
    setState(() => _trendTooltipPosition = position);
  }

  Offset _floatingTooltipOffset(Offset cursor, Size bounds, Size tooltip) {
    const gap = 14.0;
    final maxLeft = math.max(0.0, bounds.width - tooltip.width);
    final maxTop = math.max(0.0, bounds.height - tooltip.height);

    var left = cursor.dx + gap;
    if (left + tooltip.width > bounds.width) {
      left = cursor.dx - tooltip.width - gap;
    }

    var top = cursor.dy + gap;
    if (top + tooltip.height > bounds.height) {
      top = cursor.dy - tooltip.height - gap;
    }

    return Offset(
      left.clamp(0.0, maxLeft).toDouble(),
      top.clamp(0.0, maxTop).toDouble(),
    );
  }

  void _scheduleTrendTooltip(
    TrackballDetails details,
    List<_TrendPoint> month,
    List<_TrendPoint> daily,
    DashboardData data,
    bool privacy,
  ) {
    final tooltip = _trendTooltipData(details, month, daily, data, privacy);
    if (tooltip == null || _sameTooltip(_trendTooltip, tooltip)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_sameTooltip(_trendTooltip, tooltip)) {
        setState(() => _trendTooltip = tooltip);
      }
    });
  }

  bool _sameTooltip(_ChartTooltipData? a, _ChartTooltipData b) {
    if (a == null || a.title != b.title || a.rows.length != b.rows.length) {
      return false;
    }
    for (var i = 0; i < a.rows.length; i++) {
      if (a.rows[i].signature != b.rows[i].signature) {
        return false;
      }
    }
    return true;
  }

  _ChartTooltipData? _trendTooltipData(
    TrackballDetails details,
    List<_TrendPoint> month,
    List<_TrendPoint> daily,
    DashboardData data,
    bool privacy,
  ) {
    final info = details.groupingModeInfo;
    if (info == null || info.currentPointIndices.isEmpty) {
      return null;
    }

    _TrendPoint? monthPoint;
    _TrendPoint? dailyPoint;

    for (var i = 0; i < info.currentPointIndices.length; i++) {
      final pointIndex = info.currentPointIndices[i];
      final seriesIndex = info.visibleSeriesIndices[i];
      if (seriesIndex >= 2 && pointIndex >= 0 && pointIndex < daily.length) {
        dailyPoint = daily[pointIndex];
      } else if (pointIndex >= 0 && pointIndex < month.length) {
        monthPoint ??= month[pointIndex];
      }
    }

    if (dailyPoint != null) {
      final rows = <_TooltipLine>[];
      final summary = _transferSegments(
        uploaded: dailyPoint.uploaded,
        downloaded: dailyPoint.downloaded,
        uploadColor: _cyan,
        downloadColor: _orange,
      );
      if (summary.isNotEmpty) {
        rows.add(_TooltipLine.rich('汇总', summary));
      }
      rows.addAll(_dailySiteTransferRows(data, dailyPoint.label, privacy));
      if (rows.isEmpty) return null;
      return _ChartTooltipData(
        _formatDay(dailyPoint.label),
        rows,
      );
    }

    if (monthPoint != null) {
      final rows = <_TooltipLine>[];
      final summary = _transferSegments(
        uploaded: monthPoint.uploaded,
        downloaded: monthPoint.downloaded,
        published: monthPoint.published,
        uploadColor: _green,
        downloadColor: _red,
      );
      if (summary.isNotEmpty) {
        rows.add(_TooltipLine.rich('汇总', summary));
      }
      rows.addAll(_monthlySiteTransferRows(data, monthPoint.label, privacy));
      if (rows.isEmpty) return null;
      return _ChartTooltipData(
        _formatMonth(monthPoint.label),
        rows,
      );
    }

    return null;
  }

  Widget _monthlyTrackballTooltip(
    TrackballDetails details,
    List<_TrendPoint> items,
    DashboardData data,
    bool privacy,
  ) {
    final info = details.groupingModeInfo;
    final pointIndex = info != null && info.currentPointIndices.isNotEmpty
        ? info.currentPointIndices.first
        : details.pointIndex;
    if (pointIndex == null || pointIndex < 0 || pointIndex >= items.length) {
      return const SizedBox.shrink();
    }
    return _monthlyTooltip(items[pointIndex], data, privacy);
  }

  Widget _monthlyTooltip(dynamic dataPoint, DashboardData data, bool privacy) {
    if (dataPoint is! _TrendPoint) {
      return const SizedBox.shrink();
    }
    final rows = <_TooltipLine>[];
    final summary = _transferSegments(
      uploaded: dataPoint.uploaded,
      downloaded: dataPoint.downloaded,
      published: dataPoint.published,
      uploadColor: _green,
      downloadColor: _red,
    );
    if (summary.isNotEmpty) {
      rows.add(_TooltipLine.rich('汇总', summary));
    }
    rows.addAll(
      _monthlySiteRows(
        data,
        dataPoint.label,
        privacy,
        valueOf: (record) => record.published,
        formatter: _formatCount,
      ),
    );

    return _chartTooltip(
      _formatMonth(dataPoint.label),
      rows,
      width: 250,
    );
  }

  Widget _donutTooltip(
    dynamic dataPoint,
    List<_NameValuePoint> items,
    String Function(num) formatter,
  ) {
    if (dataPoint is! _NameValuePoint) {
      return const SizedBox.shrink();
    }

    final total = items.fold<num>(0, (sum, item) => sum + item.value);
    final percent = total <= 0 ? 0 : dataPoint.value / total * 100;
    return _chartTooltip(
      dataPoint.name,
      [
        _TooltipLine('数值', formatter(dataPoint.value), _cyan),
        _TooltipLine('占比', '${percent.toStringAsFixed(1)}%', _amber),
      ],
    );
  }

  List<_TooltipSegment> _transferSegments({
    required num uploaded,
    required num downloaded,
    required Color uploadColor,
    required Color downloadColor,
    num published = 0,
  }) {
    final segments = <_TooltipSegment>[];
    void addSpace() {
      if (segments.isNotEmpty) {
        segments.add(const _TooltipSegment('  ', _muted));
      }
    }

    if (uploaded > 0) {
      segments.add(_TooltipSegment('↑${formatBytes(uploaded)}', uploadColor));
    }
    if (downloaded > 0) {
      addSpace();
      segments.add(_TooltipSegment('↓${formatBytes(downloaded)}', downloadColor));
    }
    if (published > 0) {
      addSpace();
      segments.add(_TooltipSegment('发${_formatCount(published)}', _amber));
    }
    return segments;
  }

  List<_TooltipLine> _dailySiteTransferRows(
    DashboardData data,
    String date,
    bool privacy, {
    int limit = 10,
  }) {
    final rows = <_TrendSitePoint>[];
    for (final site in data.stackChartDataList) {
      num uploaded = 0;
      num downloaded = 0;
      for (final record in site.value) {
        if (record.createdAt == date) {
          uploaded += record.uploaded;
          downloaded += record.downloaded;
        }
      }
      if (uploaded > 0 || downloaded > 0) {
        rows.add(_TrendSitePoint(_mask(site.name, privacy), uploaded, downloaded, 0));
      }
    }

    rows.sort((a, b) => (b.uploaded + b.downloaded).compareTo(a.uploaded + a.downloaded));
    final visible = rows.length > limit ? rows.take(limit).toList() : rows;
    final hidden = rows.length - visible.length;
    return [
      for (final row in visible)
        if (_transferSegments(
          uploaded: row.uploaded,
          downloaded: row.downloaded,
          uploadColor: _cyan,
          downloadColor: _orange,
        ) case final segments when segments.isNotEmpty)
          _TooltipLine.rich(row.name, segments),
      if (hidden > 0) _TooltipLine('其余', '$hidden 项', _muted),
    ];
  }

  List<_TooltipLine> _monthlySiteTransferRows(
    DashboardData data,
    String month,
    bool privacy, {
    int limit = 10,
  }) {
    final rows = <_TrendSitePoint>[];
    for (final site in data.uploadMonthIncrementDataList) {
      num uploaded = 0;
      num downloaded = 0;
      num published = 0;
      for (final record in site.value) {
        if (_monthKey(record.createdAt) == month) {
          uploaded += record.uploaded;
          downloaded += record.downloaded;
          published += record.published;
        }
      }
      if (uploaded > 0 || downloaded > 0 || published > 0) {
        rows.add(_TrendSitePoint(_mask(site.name, privacy), uploaded, downloaded, published));
      }
    }

    rows.sort((a, b) => (b.uploaded + b.downloaded).compareTo(a.uploaded + a.downloaded));
    final visible = rows.length > limit ? rows.take(limit).toList() : rows;
    final hidden = rows.length - visible.length;
    return [
      for (final row in visible)
        if (_transferSegments(
          uploaded: row.uploaded,
          downloaded: row.downloaded,
          published: row.published,
          uploadColor: _green,
          downloadColor: _red,
        ) case final segments when segments.isNotEmpty)
          _TooltipLine.rich(row.name, segments),
      if (hidden > 0) _TooltipLine('其余', '$hidden 项', _muted),
    ];
  }

  List<_TooltipLine> _monthlySiteRows(
    DashboardData data,
    String month,
    bool privacy, {
    required num Function(StatusRecord record) valueOf,
    required String Function(num value) formatter,
    int limit = 8,
  }) {
    final rows = <_NameValuePoint>[];
    for (final site in data.uploadMonthIncrementDataList) {
      num value = 0;
      for (final record in site.value) {
        if (_monthKey(record.createdAt) == month) {
          value += valueOf(record);
        }
      }
      if (value > 0) {
        rows.add(_NameValuePoint(_mask(site.name, privacy), value));
      }
    }

    rows.sort((a, b) => b.value.compareTo(a.value));
    final visible = rows.length > limit ? rows.take(limit).toList() : rows;
    final hidden = rows.length - visible.length;
    return [
      for (final row in visible) _TooltipLine(row.name, formatter(row.value), _text),
      if (hidden > 0) _TooltipLine('其余', '$hidden 项', _muted),
    ];
  }

  Widget _chartTooltip(
    String title,
    List<_TooltipLine> rows, {
    double width = 220,
    double maxHeight = 240,
  }) {
    final hasSummary = rows.isNotEmpty && rows.first.label == '汇总';
    final summary = hasSummary ? rows.first : null;
    final detailRows = hasSummary ? rows.skip(1).toList() : rows;

    return Container(
      width: width,
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cyan.withValues(alpha: 0.42)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hasSummary ? '$title汇总' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
              if (summary != null) ...[
                const SizedBox(width: 12),
                _tooltipValue(summary, fontSize: 11),
              ],
            ],
          ),
          if (detailRows.isNotEmpty) ...[
            SizedBox(height: hasSummary ? 12 : 8),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < detailRows.length; i++) ...[
                      if (i > 0) const SizedBox(height: 5),
                      _tooltipRow(detailRows[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tooltipRow(_TooltipLine row) {
    return Row(
      children: [
        Expanded(
          child: Text(
            row.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Align(
            alignment: Alignment.centerRight,
            child: _tooltipValue(row),
          ),
        ),
      ],
    );
  }

  Widget _tooltipValue(_TooltipLine row, {double fontSize = 11}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: row.segments.isEmpty
          ? Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(color: row.color ?? _text, fontSize: fontSize, fontWeight: FontWeight.w900),
            )
          : RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                children: [
                  for (final segment in row.segments)
                    TextSpan(
                      text: segment.text,
                      style: TextStyle(color: segment.color, fontSize: fontSize, fontWeight: FontWeight.w900),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRankPanel(DashboardData data, bool privacy, {double height = 440}) {
    final uploaded = _topStatus(data.statusList, privacy, (record) => record.value.uploaded, limit: 10);
    final downloaded = _topStatus(data.statusList, privacy, (record) => record.value.downloaded, limit: 10);
    return _boardPanel(
      title: '累计排行',
      subtitle: '站点上传/下载 TOP',
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _rankList(title: '累计上传 TOP', items: uploaded, color: _green, formatter: formatBytes),
          ),
          Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: _line),
          Expanded(
            child: _rankList(title: '累计下载 TOP', items: downloaded, color: _red, formatter: formatBytes),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPanel(DashboardData data, bool privacy, {double height = 360}) {
    final upload = _topKv(data.uploadIncrementDataList, privacy, limit: 10);
    final download = _topKv(data.downloadIncrementDataList, privacy, limit: 10);
    return _boardPanel(
      title: '今日增量',
      subtitle: '站点上传/下载变化',
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _rankList(title: '今日上传 TOP', items: upload, color: _cyan, formatter: formatBytes),
          ),
          Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: _line),
          Expanded(
            child: _rankList(title: '今日下载 TOP', items: download, color: _orange, formatter: formatBytes),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyPublishPanel(DashboardData data, bool privacy) {
    final items = _monthTrend(data);
    return _boardPanel(
      title: '月度发布',
      subtitle: '最近 12 个月发布走势',
      height: 300,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        margin: EdgeInsets.zero,
        primaryXAxis: CategoryAxis(majorGridLines: const MajorGridLines(width: 0), labelStyle: _axisStyle()),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0.7, color: _line.withValues(alpha: 0.55)),
          axisLine: const AxisLine(width: 0),
          labelStyle: _axisStyle(),
          axisLabelFormatter: (details) => ChartAxisLabel(_formatCount(details.value), _axisStyle()),
        ),
        trackballBehavior: TrackballBehavior(
          enable: true,
          activationMode: ActivationMode.singleTap,
          tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
          lineColor: _amber.withValues(alpha: 0.58),
          lineWidth: 1,
          tooltipSettings: const InteractiveTooltip(enable: false),
          builder: (context, details) => _monthlyTrackballTooltip(details, items, data, privacy),
        ),
        series: <CartesianSeries>[
          SplineAreaSeries<_TrendPoint, String>(
            name: '发布',
            dataSource: items,
            xValueMapper: (p, _) => _formatMonth(p.label),
            yValueMapper: (p, _) => p.published,
            color: _amber.withValues(alpha: 0.18),
            borderColor: _amber,
            borderWidth: 2,
          ),
          ColumnSeries<_TrendPoint, String>(
            name: '发布数',
            dataSource: items,
            xValueMapper: (p, _) => _formatMonth(p.label),
            yValueMapper: (p, _) => p.published,
            color: _amber.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPanel(DashboardData data, bool privacy, {double height = 340}) {
    final email = _topKv(data.emailCount, privacy, limit: 8);
    final username = _topKv(data.usernameCount, privacy, limit: 8);
    return _boardPanel(
      title: '账号分布',
      subtitle: '邮箱与用户名复用情况',
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _rankList(title: '邮箱分布', items: email, color: _violet, formatter: _formatCount),
          ),
          Container(width: 1, margin: const EdgeInsets.symmetric(horizontal: 12), color: _line),
          Expanded(
            child: _rankList(title: '用户名分布', items: username, color: _blue, formatter: _formatCount),
          ),
        ],
      ),
    );
  }

  Widget _rankList({
    required String title,
    required List<_NameValuePoint> items,
    required Color color,
    required String Function(num) formatter,
  }) {
    final maxValue = items.fold<num>(0, (max, item) => math.max(max, item.value));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('暂无数据', style: TextStyle(color: _muted)),
                )
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final factor = maxValue > 0 ? item.value / maxValue : 0.0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              child: Text(
                                '${index + 1}'.padLeft(2, '0'),
                                style: TextStyle(
                                  color: index < 3 ? color : _muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatter(item.value),
                              style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        _boardProgressBar(factor, color),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _boardProgressBar(num value, Color color) {
    return Container(
      height: 4,
      decoration: BoxDecoration(color: _line.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(2)),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0).toDouble(),
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
      ),
    );
  }

  Widget _boardPanel({required String title, required String subtitle, required double height, required Widget child}) {
    return _panelContainer(
      height: height,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 15, color: _cyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _panelContainer({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
    double? height,
  }) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line.withValues(alpha: 0.88)),
        boxShadow: [BoxShadow(color: _cyan.withValues(alpha: 0.05), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: child,
    );
  }

  TextStyle _axisStyle() => const TextStyle(color: _muted, fontSize: 10);

  List<_TrendPoint> _monthTrend(DashboardData data) {
    final map = SplayTreeMap<String, _TrendPoint>();
    for (final site in data.uploadMonthIncrementDataList) {
      for (final record in site.value) {
        final label = _monthKey(record.createdAt);
        final old = map[label] ?? _TrendPoint(label, 0, 0, 0);
        map[label] = old.copyWith(
          uploaded: old.uploaded + record.uploaded,
          downloaded: old.downloaded + record.downloaded,
          published: old.published + record.published,
        );
      }
    }
    final values = map.values.toList();
    if (values.length <= 12) return values;
    return values.sublist(values.length - 12);
  }

  List<_TrendPoint> _dailyUploadTrend(DashboardData data) {
    final map = SplayTreeMap<String, _TrendPoint>();
    for (final site in data.stackChartDataList) {
      for (final record in site.value) {
        final old = map[record.createdAt] ?? _TrendPoint(record.createdAt, 0, 0, 0);
        map[record.createdAt] = old.copyWith(
          uploaded: old.uploaded + record.uploaded,
          downloaded: old.downloaded + record.downloaded,
        );
      }
    }
    final values = map.values.toList();
    if (values.length <= 14) return values;
    return values.sublist(values.length - 14);
  }

  List<_NameValuePoint> _topStatus(
    List<SiteStatusData> source,
    bool privacy,
    num Function(SiteStatusData record) valueOf, {
    int limit = 8,
  }) {
    final items =
        source
            .map((record) => _NameValuePoint(_mask(record.name, privacy), valueOf(record)))
            .where((item) => item.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (items.length <= limit) return items;
    return items.take(limit).toList();
  }

  List<_NameValuePoint> _topKv(List<KV> source, bool privacy, {int limit = 8}) {
    final items =
        source
            .map((record) => _NameValuePoint(_mask(record.name, privacy), record.value))
            .where((item) => item.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (items.length <= limit) return items;
    return items.take(limit).toList();
  }

  Color _palette(int index, Color base) {
    const colors = [_cyan, _green, _amber, _red, _blue, _violet, _orange];
    if (index == 0) return base;
    return colors[index % colors.length];
  }
}

FButtonStyle _dashboardGhostButtonStyle(FButtonStyle style) {
  return style.copyWith(
    decoration: FWidgetStateMap.all(const BoxDecoration()),
    contentStyle: (content) => content.copyWith(padding: EdgeInsets.zero),
    iconContentStyle: (content) => content.copyWith(padding: EdgeInsets.zero),
  );
}

class _DesignationCard extends StatefulWidget {
  final String designation;
  final int siteCount;
  final double width;
  final double height;
  final double fontSize;

  const _DesignationCard({
    required this.designation,
    required this.siteCount,
    this.width = 170,
    this.height = 48,
    this.fontSize = 28,
  });

  @override
  State<_DesignationCard> createState() => _DesignationCardState();
}

class _DesignationCardState extends State<_DesignationCard> with TickerProviderStateMixin {
  late FPopoverController _popoverCtrl;
  late AnimationController _animCtrl;

  static const _designations = <int, String>{
    1: '初窥门径',
    10: '星辰初现',
    20: '光耀九天',
    30: '龙腾九霄',
    50: '纵横天下',
    100: '天命之子',
    150: '九天霸主',
    200: '万界之尊',
  };

  static const _gradients = <int, List<Color>>{
    1: [Color(0xFF10B981), Color(0xFF06B6D4), Color(0xFF10B981)],
    10: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF06B6D4)],
    20: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFF3B82F6)],
    30: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF8B5CF6)],
    50: [Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF3B82F6)],
    100: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFFFD93D), Color(0xFFFF6B6B)],
    150: [Color(0xFFE11D48), Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFFE11D48)],
    200: [Color(0xFFFFD700), Color(0xFFE11D48), Color(0xFF9B59B6), Color(0xFFFFD700)],
  };

  @override
  void initState() {
    super.initState();
    _popoverCtrl = FPopoverController(vsync: this);
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _popoverCtrl.dispose();
    super.dispose();
  }

  List<Color> get _colors {
    for (final key in _gradients.keys.toList().reversed) {
      if (widget.siteCount >= key) return _gradients[key]!;
    }
    return _gradients[1]!;
  }

  @override
  Widget build(BuildContext context) {
    final cs = FTheme.of(context).colors;
    final typo = FTheme.of(context).typography;

    return FPopover(
      controller: _popoverCtrl,
      popoverBuilder: (context, _) => _buildPopoverContent(cs, typo),
      child: FButton(
        style: FButtonStyle.ghost(_dashboardGhostButtonStyle),
        onPress: () => _popoverCtrl.toggle(),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: widget.width - 24,
            height: widget.height,
            child: _animatedDesignationText(fontSize: widget.fontSize),
          ),
        ),
      ),
    );
  }

  Widget _animatedDesignationText({required double fontSize}) {
    return AnimatedBuilder(
      animation: _animCtrl,
      builder: (context, child) {
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            shaderCallback: (bounds) {
              final colors = _colors;
              final stops = List.generate(colors.length, (i) => i / (colors.length - 1));
              final offset = _animCtrl.value;
              final animatedStops = stops.map((s) => (s + offset) % 1.0).toList()..sort();

              return LinearGradient(
                colors: colors,
                stops: animatedStops,
                begin: const Alignment(-1.0, 0.0),
                end: const Alignment(1.0, 0.0),
                tileMode: TileMode.mirror,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Stack(
              children: [
                for (final offset in const [
                  Offset.zero,
                  Offset(0.45, 0),
                  Offset(0, 0.35),
                ])
                  Transform.translate(
                    offset: offset,
                    child: Text(
                      widget.designation,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        fontVariations: const [FontVariation('wght', 1000)],
                        height: 1.05,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopoverContent(FColors cs, FTypography typo) {
    final entries = _designations.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final progress = _unlockProgress();
    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.border),
        boxShadow: [
          BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('称号等级', style: typo.sm.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          _buildUnlockProgress(cs, typo, progress),
          const SizedBox(height: 10),
          ...entries.map((entry) {
            final isActive = widget.siteCount >= entry.key;
            final isCurrent = widget.designation == entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFFE11D48) : (isActive ? const Color(0xFF10B981) : cs.border),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${entry.key}站',
                      style: typo.xs.copyWith(
                        color: isActive ? cs.foreground : cs.mutedForeground.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCurrent) ...[
                          Icon(FIcons.check, size: 13, color: const Color(0xFFE11D48)),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            entry.value,
                            textAlign: TextAlign.right,
                            style: typo.xs.copyWith(
                              color: isCurrent
                                  ? const Color(0xFFE11D48)
                                  : (isActive ? cs.foreground : cs.mutedForeground.withValues(alpha: 0.4)),
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  _DesignationProgress _unlockProgress() {
    final levels = _designations.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    var current = levels.first;
    MapEntry<int, String>? next;

    for (final level in levels) {
      if (widget.siteCount >= level.key) {
        current = level;
      } else {
        next = level;
        break;
      }
    }

    if (next == null) {
      return _DesignationProgress(
        currentLevel: current.key,
        currentTitle: current.value,
        nextLevel: current.key,
        nextTitle: current.value,
        ratio: 1,
        remaining: 0,
        completed: true,
      );
    }

    final span = next.key - current.key;
    final gained = (widget.siteCount - current.key).clamp(0, span);
    return _DesignationProgress(
      currentLevel: current.key,
      currentTitle: current.value,
      nextLevel: next.key,
      nextTitle: next.value,
      ratio: span <= 0 ? 1 : (gained / span).toDouble(),
      remaining: next.key - widget.siteCount,
      completed: false,
    );
  }

  Widget _buildUnlockProgress(FColors cs, FTypography typo, _DesignationProgress progress) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.muted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${widget.siteCount}站',
                style: typo.sm.copyWith(color: const Color(0xFFE11D48), fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const Spacer(),
              Text(
                progress.completed ? '已解锁最高称号' : '距 ${progress.nextTitle} 还差 ${progress.remaining}站',
                style: typo.xs.copyWith(color: cs.mutedForeground, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 5,
            decoration: BoxDecoration(color: cs.border.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(3)),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.ratio.clamp(0.0, 1.0).toDouble(),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(3)),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            progress.completed
                ? '当前称号：${progress.currentTitle}'
                : '${progress.currentLevel}站 ${progress.currentTitle} → ${progress.nextLevel}站 ${progress.nextTitle}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typo.xs.copyWith(color: cs.foreground, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DesignationProgress {
  final int currentLevel;
  final String currentTitle;
  final int nextLevel;
  final String nextTitle;
  final double ratio;
  final int remaining;
  final bool completed;

  const _DesignationProgress({
    required this.currentLevel,
    required this.currentTitle,
    required this.nextLevel,
    required this.nextTitle,
    required this.ratio,
    required this.remaining,
    required this.completed,
  });
}

class _Kpi {
  final String label;
  final String value;
  final String caption;
  final Color color;
  final IconData icon;

  const _Kpi(this.label, this.value, this.caption, this.color, this.icon);
}

class _TrendPoint {
  final String label;
  final num uploaded;
  final num downloaded;
  final num published;

  const _TrendPoint(this.label, this.uploaded, this.downloaded, this.published);

  _TrendPoint copyWith({num? uploaded, num? downloaded, num? published}) {
    return _TrendPoint(label, uploaded ?? this.uploaded, downloaded ?? this.downloaded, published ?? this.published);
  }
}

class _NameValuePoint {
  final String name;
  final num value;

  const _NameValuePoint(this.name, this.value);
}

class _TrendSitePoint {
  final String name;
  final num uploaded;
  final num downloaded;
  final num published;

  const _TrendSitePoint(this.name, this.uploaded, this.downloaded, this.published);
}

class _ChartTooltipData {
  final String title;
  final List<_TooltipLine> rows;

  const _ChartTooltipData(this.title, this.rows);
}

class _TooltipLine {
  final String label;
  final String value;
  final Color? color;
  final List<_TooltipSegment> segments;

  const _TooltipLine(this.label, this.value, [this.color]) : segments = const [];

  const _TooltipLine.rich(this.label, this.segments)
    : value = '',
      color = null;

  String get signature {
    if (segments.isEmpty) return '$label|$value';
    return '$label|${segments.map((segment) => segment.text).join()}';
  }
}

class _TooltipSegment {
  final String text;
  final Color color;

  const _TooltipSegment(this.text, this.color);
}

class _BoardBackdropPainter extends CustomPainter {
  const _BoardBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF12365A).withValues(alpha: 0.34),
          const Color(0x00000000),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, topWash);

    final sideWash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF22D3EE).withValues(alpha: 0.08),
          const Color(0x00000000),
          const Color(0xFF60A5FA).withValues(alpha: 0.07),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sideWash);

    final fineGridPaint = Paint()
      ..color = const Color(0xFF12365A).withValues(alpha: 0.10)
      ..strokeWidth = 0.45;
    const fineStep = 22.0;
    for (double x = 0; x <= size.width; x += fineStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), fineGridPaint);
    }
    for (double y = 0; y <= size.height; y += fineStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), fineGridPaint);
    }

    final majorGridPaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.12)
      ..strokeWidth = 0.75;
    const majorStep = 88.0;
    for (double x = 0; x <= size.width; x += majorStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), majorGridPaint);
    }
    for (double y = 0; y <= size.height; y += majorStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), majorGridPaint);
    }

    final scanPaint = Paint()
      ..color = const Color(0xFFBFEFFF).withValues(alpha: 0.028)
      ..strokeWidth = 0.5;
    for (double y = 3; y <= size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanPaint);
    }

    _drawDataColumns(canvas, size);
    _drawCircuitTraces(canvas, size);
    _drawCornerBrackets(canvas, size);
  }

  void _drawDataColumns(Canvas canvas, Size size) {
    final pattern = [0.22, 0.46, 0.32, 0.68, 0.28, 0.54, 0.38, 0.74];
    final uploadPaint = Paint()
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.16)
      ..strokeWidth = 1.1;
    final downloadPaint = Paint()
      ..color = const Color(0xFF34D399).withValues(alpha: 0.13)
      ..strokeWidth = 1.1;

    for (double x = 16; x < size.width; x += 34) {
      final index = ((x / 34).floor()) % pattern.length;
      final height = 24 + pattern[index] * 72;
      final base = size.height - 20 - (index.isEven ? 0 : 16);
      final paint = index.isEven ? uploadPaint : downloadPaint;
      final top = math.max(0.0, base - height);
      canvas.drawLine(Offset(x, base), Offset(x, top), paint);
      canvas.drawCircle(Offset(x, top), 1.6, paint);
    }
  }

  void _drawCircuitTraces(Canvas canvas, Size size) {
    final cyanPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.18);
    final bluePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.15);

    final topTrace = Path()
      ..moveTo(size.width * 0.04, size.height * 0.18)
      ..lineTo(size.width * 0.18, size.height * 0.18)
      ..lineTo(size.width * 0.23, size.height * 0.12)
      ..lineTo(size.width * 0.42, size.height * 0.12)
      ..lineTo(size.width * 0.48, size.height * 0.22)
      ..lineTo(size.width * 0.62, size.height * 0.22);
    canvas.drawPath(topTrace, cyanPaint);

    final middleTrace = Path()
      ..moveTo(size.width * 0.92, size.height * 0.28)
      ..lineTo(size.width * 0.74, size.height * 0.28)
      ..lineTo(size.width * 0.69, size.height * 0.38)
      ..lineTo(size.width * 0.56, size.height * 0.38)
      ..lineTo(size.width * 0.50, size.height * 0.48)
      ..lineTo(size.width * 0.34, size.height * 0.48);
    canvas.drawPath(middleTrace, bluePaint);

    final lowerTrace = Path()
      ..moveTo(size.width * 0.07, size.height * 0.72)
      ..lineTo(size.width * 0.18, size.height * 0.72)
      ..lineTo(size.width * 0.23, size.height * 0.64)
      ..lineTo(size.width * 0.37, size.height * 0.64)
      ..lineTo(size.width * 0.42, size.height * 0.76)
      ..lineTo(size.width * 0.57, size.height * 0.76)
      ..lineTo(size.width * 0.62, size.height * 0.68)
      ..lineTo(size.width * 0.82, size.height * 0.68);
    canvas.drawPath(lowerTrace, cyanPaint);

    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.44);
    final nodes = [
      Offset(size.width * 0.23, size.height * 0.12),
      Offset(size.width * 0.48, size.height * 0.22),
      Offset(size.width * 0.69, size.height * 0.38),
      Offset(size.width * 0.50, size.height * 0.48),
      Offset(size.width * 0.23, size.height * 0.64),
      Offset(size.width * 0.42, size.height * 0.76),
      Offset(size.width * 0.62, size.height * 0.68),
    ];
    for (final node in nodes) {
      canvas.drawCircle(node, 2.4, nodePaint);
      canvas.drawCircle(
        node,
        5.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.7
          ..color = const Color(0xFF22D3EE).withValues(alpha: 0.18),
      );
    }
  }

  void _drawCornerBrackets(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF22D3EE).withValues(alpha: 0.24);
    const inset = 20.0;
    const length = 54.0;

    final paths = [
      Path()
        ..moveTo(inset, inset + length)
        ..lineTo(inset, inset)
        ..lineTo(inset + length, inset),
      Path()
        ..moveTo(size.width - inset - length, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + length),
      Path()
        ..moveTo(inset, size.height - inset - length)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + length, size.height - inset),
      Path()
        ..moveTo(size.width - inset - length, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - length),
    ];

    for (final path in paths) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
